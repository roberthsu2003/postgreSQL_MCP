"""測試 MCP Server 的 Token 門禁。

使用方式(MCP Server 要先啟動):
    uv run test_token.py 你的token
"""

import json
import sys
import urllib.error
import urllib.request

URL = "http://localhost:8000/mcp"
BODY = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
        "protocolVersion": "2025-06-18",
        "capabilities": {},
        "clientInfo": {"name": "test_token", "version": "1.0"},
    },
}


def call(token=None):
    """送出連線請求,回傳 HTTP 狀態碼。"""
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(URL, data=json.dumps(BODY).encode(), headers=headers)
    try:
        with urllib.request.urlopen(request) as response:
            return response.status
    except urllib.error.HTTPError as error:
        return error.code


def main():
    if len(sys.argv) != 2:
        print("請在指令後面加上 token,例如:uv run test_token.py 你的token")
        return

    try:
        without_token = call()
        with_token = call(sys.argv[1])
        with_wrong_token = call("wrong-token")
    except urllib.error.URLError:
        print("連不上 MCP Server,請確認另一個視窗的 Server 還開著。")
        return

    print(f"沒有 token:HTTP {without_token}", "✅ 被擋下" if without_token == 401 else "❌ 應該要被擋下")
    print(f"錯誤 token:HTTP {with_wrong_token}", "✅ 被擋下" if with_wrong_token == 401 else "❌ 應該要被擋下")
    print(f"正確 token:HTTP {with_token}", "✅ 可以連線" if with_token == 200 else "❌ 應該要可以連線")


if __name__ == "__main__":
    main()
