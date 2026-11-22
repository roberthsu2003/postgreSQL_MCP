# 步驟 5｜用 Microsoft Postgres MCP 讀結構產生 PRD

## 先還原 App 驗收基準

步驟 4 的操作會保留部分修改，**即使全部做對，也要先還原再做本步驟**。依 [共用操作指南的還原表](../../學習與操作指南.md#做完-dml進入-app-前先還原)，只清空本專案的練習表，重新執行步驟 3 儲存的 `建立資料.sql`，再跑一次步驟 3 的對帳查詢。門市專案此時只載入第一季，先不要加 4 月。

通過初始對帳後，才請 MCP 讀取資料並產生 PRD。沿用題目中的主鍵、狀態與初始數字，不要把 DML 練習後的數字混進 App 第一次驗收。下一階段請 AI 準備環境、開發功能與協助驗收的 Prompt 見 [桌面 App 實作指南](../../桌面App實作指南.md)。

> 你已經親手建立了 `departments`、`categories`、`employees`、`claims` 四張表，並通過 10 題多表 JOIN 與審核交易實戰。  
> 現在透過課程統一安裝好的微軟官方 **`@microsoft/postgres-mcp`**，讓 AI 讀取四張表的真實結構，寫出 `PRD.md`。

---

## 步驟 1：確認全域 `@microsoft/postgres-mcp` 設定（免建 `.venv`）

本課程統一採用微軟官方 **`@microsoft/postgres-mcp`**（透過全域 `~/.gemini/config/mcp_config.json` 以 `npx -y @microsoft/postgres-mcp run` 執行，不需要建立 Python 虛擬環境）。

### 方法 A｜沿用全域 MCP 並切換至 `expense` 資料庫（推薦）
若已完成 [第 1 章設定](../../../raspberry_docker安裝/4_單獨安裝mcp_server.md) 或 [Supabase 設定](../../../supabase安裝/README.md)，直接請 AI 呼叫 `postgres_mcp_connect` 切換到 `expense` 資料庫即可。

### 方法 B｜選用：替 `expense` 建立專屬 `ai_readonly` 唯讀 Profile
1. 在 DBeaver 連進 `expense` 資料庫執行 [00_建立唯讀帳號.sql](./00_建立唯讀帳號.sql)。
2. 若需獨立 Profile，在 `~/.gemini/config/mcp_config.json` 加入一組連到 `expense` 的連線設定後重開 Antigravity：

```json
    "expense-readonly": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:你的密碼@主機IP:5432/expense"
      }
    }
```

---

## 步驟 2：確認 MCP 連得到 `expense`

```text
請透過 Microsoft Postgres MCP（@microsoft/postgres-mcp）連線到我的 expense 資料庫，只用唯讀方式確認看得到 departments, categories, employees, claims 四張表，並查出各自的筆數。
```

---

## 步驟 3：把下面這段貼給 AI，產生 `PRD.md`

```text
請幫我把「差旅報銷審核小工具」的 PRD（產品需求文件）寫到這個資料夾的 PRD.md。

請務必先透過 Microsoft Postgres MCP（使用 postgres_mcp_connect 連線到 expense 資料庫，搭配 postgres_mcp_db_context 與唯讀 postgres_mcp_query）直接讀取四張表的真實結構、主外來鍵與限制條件；嚴禁呼叫任何修改或寫入工具。

若資料庫裡有我建立的 VIEW（檢視表，名稱以 v_ 開頭），請一併讀取它的欄位；PRD 裡報表類功能的資料來源請優先使用 VIEW，不要在 App 程式裡重寫相同的 JOIN。如果沒有任何 VIEW，就照原本的資料表規劃即可。

請結合這個資料夾裡的：
1. 差旅報銷單.xlsx（特別是「需求」工作表的 S1～S5）
2. 4_多表JOIN回答故事.md（我已經手寫驗證過 S1～S5 與 E1～E5 的查詢與結果）

我的條件：
- 我是一般上班族，會一點 SQL，想做給會計／出納用的本地桌面小工具（Python + Tkinter + psycopg2 + python-dotenv）
- 驗收數字以初始 13 張報銷單（總金額 33,360、待撥款 2 張 5,180、待審核 2 張、業務部已撥款 3,430）為基準
- 這個階段只要寫 PRD，不要寫任何程式碼
- 使用繁體中文，條理清楚
```

---

## 下一步

前往 [步驟 6｜從 PRD 產生 todolist](02_PRD產生todolist.md)。
