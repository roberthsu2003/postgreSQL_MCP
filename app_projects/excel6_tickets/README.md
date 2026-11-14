# 實戰 6｜客服案件紀錄：搜尋文字、統計工作量與雙重結案規則

> **對應 Excel**：[客服案件紀錄.xlsx](客服案件紀錄.xlsx)（客服主管彙整的客戶問題通報與結案進度表）
>
> **核心理念**：同一種網路斷線問題，客服在 Excel 裡有的寫 `WiFi`、有的寫 `wifi`、有的寫 `WIFI` 甚至 `Wi-Fi`；還常出現「狀態填已結案卻忘了填結案日」或「結案日比報修日還早」。這一次我們親手寫兩條連動 **`CHECK` 規則**把結案紀律交給資料庫，再用 **`ILIKE`**、**`FILTER`**、**`HAVING`**、**`TO_CHAR`** 做出主管級統計報表！

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：沒有備份 `.sql` 可以點，自己看 ER 圖與雙重結案邏輯，在 DBeaver Query Tool 親手建出三張表（`agents`、`categories`、`tickets`）。
2. **用 AI 建立 Transaction（交易）**：貼上三句建表 DDL 與 `客服案件紀錄.xlsx`，特別交代 AI **原封不動保留 `WiFi`/`Wi-Fi` 大小寫與空白日期轉 `NULL`**，加上 `setval()` 產出 `BEGIN; ... COMMIT;` 交易檔並完成三方對帳。
3. **10 題模糊搜尋與工作量統計 DML ＋ Microsoft Postgres MCP 雙軌驗證**：練習 `ILIKE`、萬用字元 `_`、`FILTER`、`HAVING`、`TO_CHAR`、平均處理天數與錯誤結案日期攔截沙盒，每題皆附 `@microsoft/postgres-mcp` 查詢驗證 Prompt。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且 DBeaver 可順利連線。
- [ ] 已依照 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），設定好全域 `@microsoft/postgres-mcp`。
- [ ] 已確認可透過 `postgres_mcp_connect` 切換到 `tickets` 資料庫（或 Supabase 獨立 Schema）。
- [ ] 已打開 [客服案件紀錄.xlsx](客服案件紀錄.xlsx)，看過 `案件紀錄`（30 筆）、`需求`（S1～S5）與 `有問題的資料`（5 筆）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 剖析拆表與雙結案規則 | [1_拆表與結案規則.md](1_拆表與結案規則.md) | 理解為何三張表足夠，以及 `(status='已結案')=(closed_on IS NOT NULL)` |
| **步驟 2** | 親手撰寫三張 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 建立 `tickets` 資料庫與三張表、實測 5 筆壞資料與 3 題 DDL 演練 |
| **步驟 3** | AI 建立保留原字交易檔 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 保留 WiFi 各種寫法、對齊 `setval` 並核對 30 件／19 已結案 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_搜尋與統計回答故事.md](4_搜尋與統計回答故事.md) | 完成 S1～S5 核心需求與 E1～E5 進階統計／日期保護沙盒 |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `tickets` 產出 PRD |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 拆解成可逐項驗收打勾的開發清單 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 完成模糊搜尋、分類統計、高負荷人員提醒、月趨勢與安全結案工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE tickets, categories, agents RESTART IDENTITY;` 清空三張表並重置編號，再重新執行你在**步驟 3 請 AI 產生的資料交易檔**，即可恢復為初始 **4 人員、4 分類、30 件案件（19 件已結案）**！

| 檔案 | 用途說明 |
|---|---|
| [客服案件紀錄.xlsx](客服案件紀錄.xlsx) | 原始客服工單表（含 30 筆案件、`需求`、`有問題的資料`） |
| [1_拆表與結案規則.md](1_拆表與結案規則.md) | 步驟 1：人員／分類拆表與兩條核心 `CHECK` 規則設計 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫 3 表 DDL、5 筆壞資料測試與 MCP 結構驗收 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 產出含 `setval()` 交易檔、`ROLLBACK` 測試與三方對帳 |
| [4_搜尋與統計回答故事.md](4_搜尋與統計回答故事.md) | 步驟 4：10 題模糊搜尋與工作量統計（S1～S5 ＋ E1～E5）＋ MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：授權 `ai_readonly` 唯讀帳號存取 `tickets` |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：用 `@microsoft/postgres-mcp` 讀取三張表結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 拆解為 todolist |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 套件清單（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準

- [ ] 親手建立 `agents`、`categories`、`tickets`（含雙 `CHECK` 結案防呆），並通過 MCP 結構驗證。
- [ ] `有問題的資料` 5 筆壞資料全數被資料庫擋下（含「已結案卻無日期」與「結案早於建案」）。
- [ ] AI 交易檔成功寫入 **4 位人員、4 個分類、30 件案件、19 件已結案**，且搜尋 `wifi` 可命中所有大小寫與 `Wi-Fi`。
- [ ] 完成步驟 4 全部 **10 題客服統計 DML 實戰**，並用 Microsoft Postgres MCP 查詢比對通過。
