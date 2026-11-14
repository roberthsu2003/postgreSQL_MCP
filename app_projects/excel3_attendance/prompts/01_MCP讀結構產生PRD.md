# 步驟 5｜用 Microsoft Postgres MCP 讀結構產生 PRD

> 你已經親手建立「一對多」的 `employees` 與 `attendance` 兩張表，並用 10 題 `JOIN` 與交易實戰完全驗證通過。  
> 現在透過課程統一安裝好的微軟官方 **`@microsoft/postgres-mcp`**，讓 AI 讀取資料庫的真實結構，結合 [打卡表.xlsx](../打卡表.xlsx) 產出 `PRD.md`。

---

## 步驟 1：確認全域 `@microsoft/postgres-mcp` 設定（免建 `.venv`）

本課程採用微軟官方 **`@microsoft/postgres-mcp`**（透過全域 `~/.gemini/config/mcp_config.json` 以 `npx -y @microsoft/postgres-mcp run` 執行，完全不用建立 Python 虛擬環境）。

### 方法 A｜沿用已設定好的全域 MCP 並切換資料庫（推薦）
若你已完成 [第 1 章設定](../../../raspberry_docker安裝/4_單獨安裝mcp_server.md) 或 [Supabase 設定](../../../supabase安裝/README.md)，直接請 AI 呼叫 `postgres_mcp_connect` 切換到 `attendance` 資料庫即可，免改設定檔。

### 方法 B｜選用：替 `attendance` 建立 `ai_readonly` 唯讀權限
1. 在 DBeaver 連進 `attendance` 資料庫執行 [00_建立唯讀帳號.sql](./00_建立唯讀帳號.sql)。
2. 若想獨立一個唯讀連線，可在 `~/.gemini/config/mcp_config.json` 的 `mcpServers` 加入一組連到 `attendance` 的 Profile（使用 `ai_readonly`），並重開 Antigravity：

```json
    "attendance-readonly": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:你的密碼@主機IP:5432/attendance"
      }
    }
```

---

## 步驟 2：確認 MCP 連得到 `attendance`

```text
請透過 Microsoft Postgres MCP（@microsoft/postgres-mcp）連線到我的 attendance 資料庫，只用唯讀方式確認看得到 employees 和 attendance 兩張表，並查出目前的員工數與打卡筆數。
```

---

## 步驟 3：把下面這段貼給 AI，產生 `PRD.md`

```text
請幫我把「員工打卡查詢小工具」的 PRD（產品需求文件）寫到這個資料夾的 PRD.md。

請務必先透過 Microsoft Postgres MCP（使用 postgres_mcp_connect 連線到 attendance 資料庫，搭配 postgres_mcp_db_context 與唯讀 postgres_mcp_query）直接讀取真實資料表結構與外來鍵關聯；嚴禁呼叫任何修改或寫入工具。

請結合這個資料夾裡的：
1. 打卡表.xlsx（特別是「需求」工作表的 S1～S5）
2. 4_JOIN回答故事.md（我已經手寫驗證過 S1～S5 與 E1～E5 的查詢與結果）

我的條件：
- 我是一般上班族，會一點 SQL，想做本地桌面小工具（Python + Tkinter + psycopg2 + python-dotenv）
- 所有驗收數字以初始狀態「6 位員工、28 筆打卡、5 筆遲到、3 筆忘打卡」為基準
- 這個階段只寫 PRD，不要寫任何程式碼
- 使用繁體中文，條理清楚
```

---

## 下一步

前往 [步驟 6｜從 PRD 產生 todolist](02_PRD產生todolist.md)。
