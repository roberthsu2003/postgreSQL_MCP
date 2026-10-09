#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
所有範例共用的程式:資料庫查詢、token 門禁、稽核紀錄、啟動方式

企業裡通常由 IT 部門寫好這一份「共用安全機制」,
各部門的 MCP Server 只需要專心設計自己的工具。

啟動方式(由環境變數 MCP_TRANSPORT 決定):
    stdio(預設):本機使用,由 Claude Desktop 啟動,和單元 2 相同
    http        :遠端使用,需要 token,和單元 3 相同
"""

import contextvars
import json
import os
import sys
from datetime import datetime
from decimal import Decimal
from pathlib import Path

import psycopg2
import psycopg2.extras

HERE = Path(__file__).parent

# 資料庫連線字串(從環境變數讀取,密碼不要寫死在程式中)
DATABASE_URI = os.environ.get(
    "DATABASE_URI",
    "postgresql://postgres:yourpassword@localhost:5432/practice",
)

# 記錄「這次連線是誰」;本機模式沒有 token,就用 MCP_USER 或「本機使用者」
current_user = contextvars.ContextVar("current_user", default=os.environ.get("MCP_USER", "本機使用者"))


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
    return [{key: _to_json(value) for key, value in row.items()} for row in rows]


def _to_json(value):
    """日期轉成字串、Decimal 轉成數字,方便轉成 JSON 回傳給 AI"""
    if hasattr(value, "isoformat"):
        return value.isoformat(sep=" ") if isinstance(value, datetime) else value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    return value


# ---------------------------------------------------------------------
# 稽核紀錄
# ---------------------------------------------------------------------

def audit(tool, **params):
    """記錄誰在什麼時間呼叫了哪個工具

    注意:要印到 stderr。stdio 模式下 stdout 是和 Claude Desktop 溝通用的,印到 stdout 會造成錯誤
    """
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {current_user.get()} 呼叫 {tool} {params}", file=sys.stderr)


# ---------------------------------------------------------------------
# token 門禁(只有 http 模式使用)
# ---------------------------------------------------------------------

class TokenCheck:
    """每個連線都要帶 Authorization: Bearer <token>,token 不在 tokens.json 內就拒絕"""

    def __init__(self, app, tokens):
        self.app = app
        self.tokens = tokens

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)

        from starlette.responses import JSONResponse

        # mcp-remote 連線前會先詢問有沒有 OAuth 設定(/.well-known/...),本範例沒有,直接回答「沒有」
        if "/.well-known/" in scope["path"]:
            return await JSONResponse({"error": "not found"}, status_code=404)(scope, receive, send)

        headers = dict(scope["headers"])
        token = headers.get(b"authorization", b"").decode().removeprefix("Bearer ").strip()

        if token not in self.tokens:
            print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] 拒絕連線:token 錯誤或沒有提供", file=sys.stderr)
            response = JSONResponse({"error": "未授權:請提供正確的 token"}, status_code=401)
            return await response(scope, receive, send)

        current_user.set(self.tokens[token])
        return await self.app(scope, receive, send)


# ---------------------------------------------------------------------
# 啟動
# ---------------------------------------------------------------------

def run(mcp):
    """依照 MCP_TRANSPORT 決定用本機(stdio)或遠端(http + token)啟動"""
    transport = os.environ.get("MCP_TRANSPORT", "stdio")

    if transport == "stdio":
        mcp.run()
        return

    if transport != "http":
        sys.exit(f"MCP_TRANSPORT 只能是 stdio 或 http,目前是 {transport}")

    import uvicorn

    tokens_file = HERE / "tokens.json"
    if not tokens_file.exists():
        sys.exit("找不到 tokens.json:請複製 tokens.example.json 並填入 token")
    tokens = json.loads(tokens_file.read_text(encoding="utf-8"))

    host = os.environ.get("MCP_HOST", "127.0.0.1")  # 讓其它電腦連線時改成 0.0.0.0
    port = int(os.environ.get("MCP_PORT", "8000"))

    app = TokenCheck(mcp.streamable_http_app(host=host), tokens)
    print(f"MCP Server 已啟動:http://{host}:{port}/mcp(共 {len(tokens)} 組 token)", file=sys.stderr)
    uvicorn.run(app, host=host, port=port)
