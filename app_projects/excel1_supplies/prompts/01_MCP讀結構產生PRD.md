# 步驟 5｜用 Microsoft Postgres MCP 讀結構產生 PRD

> 到這裡，你的 `supplies` 資料庫已經**親手建表並完成 10 題 DML ＋ 對帳測試**了。  
> 接下來交給 Antigravity AI：透過課程統一安裝好的微軟官方 **`@microsoft/postgres-mcp`**，直接讀取你資料庫的實際結構與筆數，結合 [耗材庫存表.xlsx](../耗材庫存表.xlsx) 的需求寫出專屬 `PRD.md`。

---

## 步驟 1：確認全域 `@microsoft/postgres-mcp` 設定（不用建 `.venv`）

本課程統一採用微軟官方的 **`@microsoft/postgres-mcp`**（`npx -y @microsoft/postgres-mcp run`），設定位於使用者家目錄的全域設定檔 `~/.gemini/config/mcp_config.json`，**完全不需要建立 Python 虛擬環境（免建 `.venv`）**。

### 方法 A｜直接使用已設定好的全域 MCP（最簡便，推薦）
如果你已經完成課程第 1 章的 [單獨安裝 MCP Server](../../../raspberry_docker安裝/4_單獨安裝mcp_server.md) 或 [Supabase 安裝](../../../supabase安裝/README.md)，你的全域 `~/.gemini/config/mcp_config.json` 已經有以下其中一組連線設定（預設連到 `postgres` 資料庫）：

```json
{
  "mcpServers": {
    "raspberry-postgres": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://帳號:密碼@主機IP:5432/postgres"
      }
    }
  }
}
```

只要在對 AI 下 Prompt 時**明確指定連線資料庫名稱**（例如：「請透過 Microsoft Postgres MCP 連線到 `supplies` 資料庫」），AI 就會呼叫 `postgres_mcp_connect`（帶入 `database: "supplies"`）自動切換過去讀取結構，**不用另外改設定檔**！

### 方法 B｜選用：用專屬唯讀帳號增加雙重防護（最小權限原則）
若你想從資料庫層級徹底鎖死 AI 只能讀不能寫：
1. 在 DBeaver 連到 `supplies` 資料庫執行 [00_建立唯讀帳號.sql](./00_建立唯讀帳號.sql)（請自行更換強密碼）。
2. 在全域 `~/.gemini/config/mcp_config.json` 的 `mcpServers` 中新增一組連線（或暫時將 `POSTGRES_MCP_CONNECTION_STRING` 改成下方唯讀帳號字串），並重開 Antigravity：

```json
    "supplies-readonly": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:請改成你的強密碼@主機IP:5432/supplies"
      }
    }
```

---

## 步驟 2：確認 MCP 連得到 `supplies`

在對話框貼上這句測試：

```text
請透過 Microsoft Postgres MCP（@microsoft/postgres-mcp）連線到我的 supplies 資料庫，只用唯讀方式查出 public schema 底下所有的資料表名稱，並告訴我 supplies 資料表目前有幾筆資料。
```

確定看到 `supplies` 且筆數是 **25 筆**，再進入下一步。

---

## 步驟 3：把下面這段貼給 AI，產生 `PRD.md`

```text
請幫我把「耗材庫存小工具」的 PRD（產品需求文件）寫到這個資料夾的 PRD.md。

請務必先透過 Microsoft Postgres MCP（使用 postgres_mcp_connect 連線到 supplies 資料庫，搭配 postgres_mcp_db_context 與唯讀 postgres_mcp_query）直接讀取我資料庫裡真實的表結構、欄位型別、CHECK 限制與目前資料筆數（25 筆）；嚴禁呼叫任何修改或寫入資料表的工具。

需求與驗收基準請結合這份資料夾裡的：
1. 耗材庫存表.xlsx（特別是「需求」工作表的 S1～S5）
2. 4_DML回答故事.md（我已經手寫驗證過 S1～S5 與 E1～E5 的查詢邏輯與結果）

我的條件：
- 我是一般上班族，會一點 SQL，想做一個本地桌面小工具給總務團隊用（Python + Tkinter + psycopg2 + python-dotenv）
- 所有數字都要對應我目前資料庫的真實狀態（例如 25 筆資料、總金額 66,474）
- 這個階段只要寫 PRD，不要寫任何程式碼
- 請使用繁體中文，條理清楚，讓每個功能都可以對照「要做什麼 → 操作 → 應該看到」來驗收
```

---

## 下一步

看過並滿意 AI 產生的 `PRD.md` 後，前往 [步驟 6｜從 PRD 產生 todolist](02_PRD產生todolist.md)。
