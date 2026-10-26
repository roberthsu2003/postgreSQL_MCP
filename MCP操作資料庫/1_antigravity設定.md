# 3-1：在 Antigravity 中設定專案級 Postgres MCP

本課程使用 **Antigravity** 作為 AI 助手。我們採用**「專案級 MCP（Project-level MCP）」**架構：
* **不需進行全域安裝**，不會污染您的個人電腦環境。
* **只有在開啟本專案時，MCP Server 才會自動啟動**；開啟其他專案或關閉時完全不佔用資源。

---

## 1. 專案級設定檔位置

在專案根目錄下，Antigravity 會自動讀取以下設定檔：
```text
.agents/mcp_config.json
```

---

## 2. 設定連線至您的 PostgreSQL

請開啟專案中的 [`.agents/mcp_config.json`](file:///Users/roberthsu2003/Documents/GitHub/postgreSQL_MCP/.agents/mcp_config.json)，依據您的資料庫來源填入對應的 `DATABASE_URI`：

### 情境 A：連線至樹莓派（Raspberry Pi Docker）
```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@<樹莓派IP或主機名稱>:5432/postgres"
      }
    }
  }
}
```
> 將 `<樹莓派IP或主機名稱>` 替換為您的樹莓派 IP（如 `192.168.1.150`）或主機名（如 `pi4robert03012gb.local`）。

### 情境 B：連線至 Supabase 雲端資料庫
```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require"
      }
    }
  }
}
```

> [!TIP]
> **免安裝 Docker 的替代方案（使用 uvx）：**
> 若電腦尚未安裝 Docker，可將 `"command"` 改為 `"uvx"`，`"args"` 改為 `["--with", "mcp<2", "postgres-mcp", "--access-mode=unrestricted"]`。

---

## 3. 在 Antigravity 中提問查庫（一般人模式，不用寫程式）

設定完成後，在 Antigravity 聊天框中，AI 就具備了操作 PostgreSQL 的 MCP 工具。

### 常用中文提問範例：
1. **查看資料表結構**：
   * *「請列出目前資料庫內有哪些資料表？」*
2. **查詢特定業務數據**：
   * *「請幫我查詢最暢銷的商品前 5 名是哪些？各賣了幾件？」*
   * *「目前有哪些商品庫存低於 10 件？」*
3. **讓 AI 協助建表或新增資料**：
   * *「請在資料庫中建立一張會員資料表 members，包含姓名、Email 與註冊日期。」*

AI 會自動調用 MCP 工具在背後執行 SQL，並直接把整理好的表格與答案呈現給您！

---

👉 **下一步：[3-2 第一次用中文查詢資料庫實戰](./2_用中文查詢資料庫/)**
