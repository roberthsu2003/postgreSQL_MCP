#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
網路商店營運助理 MCP Server(遠端 HTTP 版,需要 token 才能連線)

公司把這個 server 架在內部主機上,員工的 Claude Desktop 帶著自己的 token 連線,
就能用自然語言查詢商品、銷售與庫存。

資料庫:繁體中文範例資料庫的 shop.sql
啟動:uv run server_http.py
網址:http://localhost:8000/mcp
"""

import contextvars
import json
import os
from datetime import date, datetime
from pathlib import Path
from typing import Literal

import psycopg2
import psycopg2.extras
import uvicorn
from mcp.server import MCPServer
from starlette.responses import JSONResponse

# ---------------------------------------------------------------------
# 設定
# ---------------------------------------------------------------------

# 資料庫連線字串(從環境變數讀取,密碼不要寫死在程式中)
DATABASE_URI = os.environ.get(
    "DATABASE_URI",
    "postgresql://postgres:yourpassword@localhost:5432/practice",
)

# token 清單:{"token": "使用者名稱"},放在 tokens.json,不可以放進 git
TOKENS_FILE = Path(__file__).parent / "tokens.json"
TOKENS = json.loads(TOKENS_FILE.read_text(encoding="utf-8"))

HOST = os.environ.get("MCP_HOST", "127.0.0.1")  # 讓其它電腦連線時改成 0.0.0.0
PORT = int(os.environ.get("MCP_PORT", "8000"))

mcp = MCPServer("網路商店營運助理")

# 記錄「這次連線是誰」,讓每個工具都知道呼叫者是誰
current_user = contextvars.ContextVar("current_user", default="未知")


# ---------------------------------------------------------------------
# 門禁:檢查 token
# ---------------------------------------------------------------------

class TokenCheck:
    """每個連線都要帶 Authorization: Bearer <token>,token 不在清單內就拒絕"""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)

        # mcp-remote 連線前會先詢問有沒有 OAuth 設定(/.well-known/...),本範例沒有,直接回答「沒有」
        if "/.well-known/" in scope["path"]:
            return await JSONResponse({"error": "not found"}, status_code=404)(scope, receive, send)

        headers = dict(scope["headers"])
        auth = headers.get(b"authorization", b"").decode()
        token = auth.removeprefix("Bearer ").strip()

        if token not in TOKENS:
            print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] 拒絕連線:token 錯誤或沒有提供")
            response = JSONResponse({"error": "未授權:請提供正確的 token"}, status_code=401)
            return await response(scope, receive, send)

        current_user.set(TOKENS[token])
        return await self.app(scope, receive, send)


def audit(tool, **params):
    """記錄誰在什麼時間呼叫了哪個工具(企業稽核用)"""
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {current_user.get()} 呼叫 {tool} {params}")


# ---------------------------------------------------------------------
# 資料庫查詢
# ---------------------------------------------------------------------

def query(sql, params=None):
    """執行唯讀查詢,回傳 list[dict]"""
    conn = psycopg2.connect(DATABASE_URI)
    try:
        # 設定為唯讀,即使 SQL 寫錯也不會修改資料
        conn.set_session(readonly=True)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
    finally:
        conn.close()
    # 日期轉成字串,方便轉成 JSON 回傳給 AI
    return [
        {key: str(value) if hasattr(value, "isoformat") else value for key, value in row.items()}
        for row in rows
    ]


# ---------------------------------------------------------------------
# 工具
# ---------------------------------------------------------------------

@mcp.tool()
def search_products(keyword: str) -> list[dict]:
    """用關鍵字搜尋商品名稱或分類名稱,回傳商品名稱、分類、售價、庫存"""
    audit("search_products", keyword=keyword)
    sql = """
        SELECT p.name AS 商品名稱, c.name AS 分類, p.price AS 售價, p.stock AS 庫存
        FROM products p
        JOIN categories c ON p.category_id = c.category_id
        WHERE p.name LIKE %s OR c.name LIKE %s
        ORDER BY c.name, p.name
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))


@mcp.tool()
def sales_summary(
    start_date: date,
    end_date: date,
    group_by: Literal["分類", "商品", "月份"] = "分類",
) -> list[dict]:
    """統計一段期間內「已完成」訂單的銷售數量與營業額,可以依分類、商品或月份分組。日期格式為 YYYY-MM-DD"""
    audit("sales_summary", start_date=str(start_date), end_date=str(end_date), group_by=group_by)
    # 分組欄位不能用 %s 傳遞,所以用 Literal 限定只能是這三種,再對應到寫好的 SQL,避免 SQL injection
    group_column = {
        "分類": "c.name",
        "商品": "p.name",
        "月份": "TO_CHAR(o.order_date, 'YYYY-MM')",
    }[group_by]
    sql = f"""
        SELECT {group_column} AS {group_by},
               SUM(oi.quantity) AS 銷售數量,
               SUM(oi.quantity * oi.unit_price) AS 營業額
        FROM order_items oi
        JOIN orders o     ON oi.order_id = o.order_id
        JOIN products p   ON oi.product_id = p.product_id
        JOIN categories c ON p.category_id = c.category_id
        WHERE o.status = '已完成'
          AND o.order_date BETWEEN %s AND %s
        GROUP BY {group_column}
        ORDER BY {"1" if group_by == "月份" else "營業額 DESC"}
    """
    return query(sql, (start_date, end_date))


@mcp.tool()
def low_stock_products(threshold: int = 10) -> list[dict]:
    """列出庫存數量小於等於 threshold 的商品(需要補貨的商品),庫存 0 代表缺貨"""
    audit("low_stock_products", threshold=threshold)
    sql = """
        SELECT p.name AS 商品名稱, c.name AS 分類, p.stock AS 庫存
        FROM products p
        JOIN categories c ON p.category_id = c.category_id
        WHERE p.stock <= %s
        ORDER BY p.stock, p.name
    """
    return query(sql, (threshold,))


@mcp.tool()
def top_customers(year: int = 2025, limit: int = 10) -> list[dict]:
    """某一年消費金額最高的會員排行(只計算已完成訂單),最多回傳 50 筆"""
    audit("top_customers", year=year, limit=limit)
    limit = min(limit, 50)  # 限制最多 50 筆,避免一次取回太多個資
    sql = """
        SELECT cu.name AS 會員姓名, cu.city AS 縣市,
               COUNT(DISTINCT o.order_id) AS 訂單數,
               SUM(oi.quantity * oi.unit_price) AS 消費金額
        FROM orders o
        JOIN customers cu  ON o.customer_id = cu.customer_id
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.status = '已完成'
          AND EXTRACT(YEAR FROM o.order_date) = %s
        GROUP BY cu.customer_id, cu.name, cu.city
        ORDER BY 消費金額 DESC
        LIMIT %s
    """
    return query(sql, (year, limit))


# ---------------------------------------------------------------------
# 啟動
# ---------------------------------------------------------------------

if __name__ == "__main__":
    # 使用 Streamable HTTP 傳輸,外面再包一層 token 檢查
    app = TokenCheck(mcp.streamable_http_app(host=HOST))
    print(f"MCP Server 已啟動:http://{HOST}:{PORT}/mcp(共 {len(TOKENS)} 組 token)")
    uvicorn.run(app, host=HOST, port=PORT)
