# 步驟 5｜用 Microsoft Postgres MCP 讀結構產生 PRD

> 你已經親手建立 `devices`（含 `JSONB` 欄位），並完成了 10 題 JSONB 查詢／修改與交易測試。  
> 現在透過課程統一安裝的微軟官方 **`@microsoft/postgres-mcp`**，請 AI 讀取真實資料庫結構，結合 [設備規格表.xlsx](../設備規格表.xlsx) 寫出 `PRD.md`。

---

## 步驟 1：確認全域 `@microsoft/postgres-mcp` 設定（免建 `.venv`）

本課程採用微軟官方 **`@microsoft/postgres-mcp`**（透過全域 `~/.gemini/config/mcp_config.json` 以 `npx -y @microsoft/postgres-mcp run` 啟動，無須建立 Python 虛擬環境）。

### 方法 A｜沿用已設定好的全域 MCP 並指定資料庫（最推薦）
只要你的全域 `~/.gemini/config/mcp_config.json` 已完成 [第 1 章設定](../../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../../supabase安裝/README.md)），在 Prompt 中請 AI 透過 `postgres_mcp_connect` 切換到 `devices` 資料庫即可，不用修改任何設定檔。

### 方法 B｜選用：建立專屬 `ai_readonly` 唯讀 Profile
如果想替 `devices` 加上資料庫層級的唯讀鎖：
1. 在 DBeaver 連進 `devices` 執行 [00_建立唯讀帳號.sql](./00_建立唯讀帳號.sql)。
2. 在全域 `~/.gemini/config/mcp_config.json` 的 `mcpServers` 加入一組 Profile 後重開 Antigravity：

```json
    "devices-readonly": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:請改成你的強密碼@主機IP:5432/devices"
      }
    }
```

---

## 步驟 2：確認 MCP 連得到 `devices`

```text
請透過 Microsoft Postgres MCP（@microsoft/postgres-mcp）連線到我的 devices 資料庫，只用唯讀方式確認看得到 devices 資料表，並告訴我目前共有幾台設備（若已執行過 S4 與 S5 應為 17 台；若重跑過初始交易檔應為 16 台）。
```

---

## 步驟 3：把下面這段貼給 AI，產生 `PRD.md`

```text
請幫我把「IT 設備規格小工具」的 PRD（產品需求文件）寫到這個資料夾的 PRD.md。

請務必先透過 Microsoft Postgres MCP（使用 postgres_mcp_connect 連線到 devices 資料庫，搭配 postgres_mcp_db_context 與唯讀 postgres_mcp_query）直接讀取真實資料表結構與 JSONB 欄位範例；嚴禁呼叫任何修改或寫入工具。

請結合這個資料夾裡的：
1. 設備規格表.xlsx（特別是「需求」工作表的 S1～S5）
2. 4_JSONB回答故事.md（我已經手寫驗證完 10 題 JSONB 查詢與修改）

我的條件：
- 我是會一點 SQL 的上班族，要做一個給資訊／總務用的本地桌面小工具（Python + Tkinter + psycopg2 + python-dotenv）
- 所有驗收數字以初始 16 台設備的狀態為基準（例如 16GB 以上筆電初始 5 台、NB-003 升級後變 6 台、新增 TB-001 後變 17 台）
- 這個階段只要寫 PRD，不要寫程式碼
- 使用繁體中文，條理清楚
```

---

## 下一步

前往 [步驟 6｜從 PRD 產生 todolist](02_PRD產生todolist.md)。
