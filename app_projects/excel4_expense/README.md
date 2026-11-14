# 實戰 4｜差旅報銷單：一張工作表拆成四張表（多表 JOIN × `SERIAL` × 審核流）

> **對應 Excel**：[差旅報銷單.xlsx](差旅報銷單.xlsx)（會計／出納每月彙整的報銷總表）
>
> **核心理念**：一張 Excel 裡混雜了部門主管、費用類別、員工名單和報銷金額，發票號碼全靠人眼比對，誰核准、誰待撥款更是一團亂。這一次我們親手把 1 張表正規化拆成 **4 張表（`departments`、`categories`、`employees`、`claims`）**，搞懂 `SERIAL` 跳號與 `setval()`、用 `UNIQUE` 防同一發票重複報帳，再用 4 表 `JOIN` 串出完整審核流程！

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：沒有備份 `.sql` 可以執行，看著 4 表 ER 關聯圖與欄位規格，自己在 DBeaver Query Tool 依「先父後子」順序手寫四句 `CREATE TABLE`。
2. **用 AI 建立 Transaction（交易）**：貼上你寫好的四句 `CREATE TABLE` 和 `差旅報銷單.xlsx`，讓 AI 產出包含 **`setval(pg_get_serial_sequence(...))`** 對齊自動編號的 `BEGIN; ... COMMIT;` 交易檔並完成三方對帳。
3. **10 題多表 JOIN / 審核流 DML ＋ Microsoft Postgres MCP 雙軌驗證**：親手寫出 4 表 `JOIN`、防重複審核 `UPDATE ... AND status='待審核'`、`FILTER` 部門交叉表與批次撥款沙盒，每題皆附 `@microsoft/postgres-mcp` 查詢驗證 Prompt。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且 DBeaver 可正常連線。
- [ ] 已依照 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），設定好全域 `@microsoft/postgres-mcp`。
- [ ] 已確認可透過 `postgres_mcp_connect` 切換到 `expense` 資料庫（或 Supabase 獨立 Schema）。
- [ ] 已打開 [差旅報銷單.xlsx](差旅報銷單.xlsx)，看過 `2024年3月費用報銷清單`（13 筆）、`需求`（S1～S5）與 `有問題的資料`（6 筆）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 剖析多表正規化拆法 | [1_一張拆四張.md](1_一張拆四張.md) | 決定哪幾張要用 `SERIAL`、哪些重複可以留、算出基準對帳數字 |
| **步驟 2** | 親手撰寫四張 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 建立 `expense` 資料庫與 4 張表、實測 6 筆壞資料與部門保護、學用 `RESTART IDENTITY` |
| **步驟 3** | AI 建立含 `setval` 的交易檔 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 貼上 4 句建表 DDL 與 Excel，產出 `BEGIN...COMMIT` 交易檔並確認編號接在 9 後面 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_多表JOIN回答故事.md](4_多表JOIN回答故事.md) | 完成 S1～S5 核心審核流與 E1～E5 進階多表分析／交易沙盒 |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `expense` 產出 PRD |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 拆解成可逐項驗收打勾的開發清單 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 完成具待撥款／待審核清單、核准駁回、防重複發票新增報銷的 Tkinter 工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE claims, employees, categories, departments RESTART IDENTITY;` 清空四張表並重置自動編號，再重新執行你在**步驟 3 請 AI 產生的資料交易檔**，即可恢復初始狀態！

| 檔案 | 用途說明 |
|---|---|
| [差旅報銷單.xlsx](差旅報銷單.xlsx) | 原始報銷工作表（含 13 筆單據、`需求`、`有問題的資料`） |
| [1_一張拆四張.md](1_一張拆四張.md) | 步驟 1：一張表拆四張表的關聯分析與 `SERIAL` 主鍵設計 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫 4 表 DDL、壞資料測試與 MCP 結構驗收 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 產出含 `setval()` 的交易檔、ROLLBACK 測試與對帳 |
| [4_多表JOIN回答故事.md](4_多表JOIN回答故事.md) | 步驟 4：10 題多表 JOIN 實戰（S1～S5 ＋ E1～E5）＋ MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：授權 `ai_readonly` 唯讀帳號存取 `expense` |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：用 `@microsoft/postgres-mcp` 讀取四表結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 拆解為 todolist |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 套件清單（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準

- [ ] 親手依正確相依順序建立 `departments`、`categories`、`employees`、`claims`，並通過 MCP 結構驗證。
- [ ] `有問題的資料` 6 筆壞資料（重複發票、重複單號、金額 0、非法狀態、不存在員工／類別）與部門保護全數觸發攔截。
- [ ] AI 交易檔含正確 `setval()` 並寫入 **4 部門、9 類別、5 員工、13 單、總金額 33,360.00**；後續新增第 10 類別能順接為編號 `10`。
- [ ] 完成步驟 4 全部 **10 題多表 JOIN DML 實戰**，並透過 Microsoft Postgres MCP 查詢比對通過。
