# PostgreSQL MCP Server

## 什麼是 MCP?

MCP(Model Context Protocol)是一個讓 AI 助理(例如 Claude Desktop)連接外部工具與資料的標準協定。
透過 MCP Server,AI 可以「看得到」你的 PostgreSQL 資料庫,用自然語言幫你查詢、分析資料。

```
┌────────────────┐   MCP 協定    ┌──────────────┐    SQL     ┌──────────────┐
│ Claude Desktop │ ───────────► │  MCP Server  │ ─────────► │  PostgreSQL  │
│  (MCP Client)  │ ◄─────────── │ (提供 tools) │ ◄───────── │   (資料庫)   │
└────────────────┘              └──────────────┘            └──────────────┘
   使用者用自然語言提問         把問題轉成工具呼叫           真正執行查詢
```

- **MCP Client**:AI 助理本身,本講義使用 Claude Desktop
- **MCP Server**:提供一組「工具(tools)」給 AI 呼叫,例如「列出資料表」、「執行 SQL」
- **PostgreSQL**:我們在前面課程建立的資料庫(繁體中文範例資料庫、台鐵進出站資料)

## 單元目錄

1. [使用 Postgres MCP Pro(安裝和使用)](./1_postgres_mcp_pro/)
2. [自己建立一個 MCP Server(Python + psycopg2)](./2_自建MCP_server/)

## 參考資料

- [MCP 官方網站](https://modelcontextprotocol.io/)
- [Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)

## 補充:舊版官方 Postgres MCP Server(已封存)

> **注意**:[@modelcontextprotocol/server-postgres](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/postgres) 已被官方封存,不再維護,而且只能唯讀查詢。新課程請使用上方的 Postgres MCP Pro。

VS Code(`.vscode/mcp.json`)設定範例,連線到 docker 內的 postgres:

```json
{
  "servers": {
    "vscode_postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://postgres:raspberry@host.docker.internal:5432/postgres"
      ]
    }
  }
}
```
