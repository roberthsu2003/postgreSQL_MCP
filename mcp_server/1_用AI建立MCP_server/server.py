#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
門市營運查詢 MCP Server
提供 AI 查詢 cafe_shop 商品與門市銷售的工具（全部唯讀）
"""

import os
from datetime import date
from typing import Literal

import psycopg2
import psycopg2.extras
from mcp.server import MCPServer

# 資料庫連線字串從環境變數讀取，密碼不寫在程式裡
DATABASE_URI = os.environ["DATABASE_URI"]

# 建立 MCP Server，名稱會顯示在 AI 工具中
mcp = MCPServer("門市營運查詢")


def query(sql, params=None):
    """執行唯讀查詢，回傳 list[dict]"""
    conn = psycopg2.connect(DATABASE_URI)
    try:
        # 設定為唯讀，即使 SQL 寫錯也不會修改資料
        conn.set_session(readonly=True)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
    finally:
        conn.close()
    # 日期轉成字串，方便轉成 JSON 回傳給 AI
    return [
        {key: str(value) if hasattr(value, "isoformat") else value for key, value in row.items()}
        for row in rows
    ]


@mcp.tool()
def search_products(keyword: str) -> list[dict]:
    """用關鍵字搜尋商品（商品名稱或分類名稱），回傳商品編號、名稱、分類、售價"""
    sql = """
        SELECT p.product_id AS 商品編號,
               p.name       AS 商品名稱,
               c.name       AS 分類,
               p.price      AS 售價
        FROM products p
        JOIN categories c ON p.category_id = c.category_id
        WHERE p.name LIKE %s OR c.name LIKE %s
        ORDER BY p.product_id
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))


@mcp.tool()
def get_store_sales(store_name: str, start_date: date, end_date: date) -> list[dict]:
    """查詢某家門市在一段期間內每天的訂單數和營業額，只計算已完成的訂單。日期格式為 YYYY-MM-DD"""
    sql = """
        SELECT o.order_date AS 日期,
               COUNT(DISTINCT o.order_id) AS 訂單數,
               SUM(i.quantity * i.unit_price) AS 營業額
        FROM orders o
        JOIN stores s ON o.store_id = s.store_id
        JOIN order_items i ON o.order_id = i.order_id
        WHERE s.name = %s
          AND o.order_date BETWEEN %s AND %s
          AND o.status = '已完成'
        GROUP BY o.order_date
        ORDER BY o.order_date
    """
    return query(sql, (store_name, start_date, end_date))


@mcp.tool()
def top_products(
    start_date: date,
    end_date: date,
    limit: int = 10,
    order_by: Literal["銷量", "營業額"] = "銷量",
) -> list[dict]:
    """查詢一段期間內賣得最好的商品排行，可以依銷量或營業額排序，只計算已完成的訂單。日期格式為 YYYY-MM-DD"""
    # 欄位名稱不能用 %s 傳遞，所以用 Literal 限定只能是這兩個值，避免 SQL Injection
    sql = f"""
        SELECT p.name AS 商品名稱,
               SUM(i.quantity) AS 銷量,
               SUM(i.quantity * i.unit_price) AS 營業額
        FROM order_items i
        JOIN products p ON i.product_id = p.product_id
        JOIN orders o ON i.order_id = o.order_id
        WHERE o.order_date BETWEEN %s AND %s
          AND o.status = '已完成'
        GROUP BY p.name
        ORDER BY {order_by} DESC
        LIMIT %s
    """
    return query(sql, (start_date, end_date, limit))


if __name__ == "__main__":
    # 預設使用 stdio 傳輸，由 AI 工具啟動並溝通
    mcp.run()
