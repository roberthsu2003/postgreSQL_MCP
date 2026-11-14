# 實戰 3｜打卡表：把一張總表拆成兩張表（`employees` × `attendance`）

> **對應 Excel**：[打卡表.xlsx](打卡表.xlsx)（人資部門每週彙整的員工出缺勤紀錄表）
>
> **核心理念**：單一 Excel 總表裡每天都在重複填姓名、部門、職稱，導致員工調部門改不完（甚至已經出現 `E05` 周美玲同時寫著「業務發展部」和「業務部」的矛盾）。這一次我們要親手拆成 **員工主表** 與 **打卡明細表**，用外來鍵（Foreign Key）鎖住關聯！

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：沒有 `.sql` 救援檔可以按，看著規格與 ER 圖自己在 DBeaver 敲出 `CREATE TABLE employees` 與 `CREATE TABLE attendance`。
2. **用 AI 建立 Transaction（交易）**：貼上你寫好的兩句 `CREATE TABLE` 和 `打卡表.xlsx`，讓 AI 讀取總表後**去重（先父表 `employees` 再子表 `attendance`）**產出純 SQL `BEGIN; ... COMMIT;` 交易檔並對帳。
3. **10 題 JOIN / 彙總 DML ＋ Microsoft Postgres MCP 雙軌驗證**：親手寫 `JOIN`、`LEFT JOIN ... IS NULL`、條件放 `ON`、`GROUP BY`、工時計算與補登打卡沙盒，每題皆附 `@microsoft/postgres-mcp` 查詢驗證 Prompt。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且 DBeaver 可順利連線。
- [ ] 已依照 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），設定好全域 `@microsoft/postgres-mcp`。
- [ ] 已確認可透過 `postgres_mcp_connect` 切換到 `attendance` 資料庫（或 Supabase 獨立 Schema）。
- [ ] 已打開 [打卡表.xlsx](打卡表.xlsx)，看過 `打卡紀錄`（28 筆）、`需求`（S1～S5）與 `有問題的資料`（5 筆）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 檢查總表問題與拆法 | [1_為什麼要拆表.md](1_為什麼要拆表.md) | 抓出 `E05` 部門矛盾原因，設計一對多兩表結構 |
| **步驟 2** | 親手撰寫兩張 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 先父後子建立 `employees` 與 `attendance`、測試 5 筆壞資料與孤兒防護 |
| **步驟 3** | AI 建立去重交易檔 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 讓 AI 先問清楚 `E05` 正確部門再產生 `BEGIN...COMMIT` 交易檔並對帳 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_JOIN回答故事.md](4_JOIN回答故事.md) | 完成 S1～S5 核心故事與 E1～E5 進階 `JOIN`/彙總/交易沙盒 |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `attendance` 產出 PRD |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 拆解成可逐項測試打勾的開發清單 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 完成可查打卡、遲到／忘打卡／未打卡名單與調部門的 Tkinter 工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE attendance, employees;` 清空兩張表，再重新執行你在**步驟 3 請 AI 產生的資料交易檔**，即可恢復為初始 **6 位員工、28 筆打卡**！

| 檔案 | 用途說明 |
|---|---|
| [打卡表.xlsx](打卡表.xlsx) | 原始職場打卡總表（含 28 筆紀錄、`需求`、`有問題的資料`） |
| [1_為什麼要拆表.md](1_為什麼要拆表.md) | 步驟 1：拆表邏輯、ER 圖與規格思考 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫兩表 DDL、複合主鍵與 FK 攔截測試 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 產出「先父後子」交易檔、ROLLBACK 測試與對帳 |
| [4_JOIN回答故事.md](4_JOIN回答故事.md) | 步驟 4：10 題 JOIN 與打卡實戰 ＋ Microsoft Postgres MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：授權 `ai_readonly` 唯讀帳號存取 `attendance` |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：用 `@microsoft/postgres-mcp` 讀取兩張表結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 拆解為 todolist |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 套件清單（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準

- [ ] 親手寫出 `employees` 與 `attendance`（含外來鍵與複合主鍵 `(emp_id, work_date)`），並通過 MCP 結構檢查。
- [ ] `有問題的資料` 5 筆壞資料與「刪除仍有打卡的員工」全數被外來鍵與限制條件攔下。
- [ ] 請 AI 解決 `E05` 部門矛盾後產出交易檔並寫入 **6 位員工、28 筆打卡（5 筆遲到、3 筆忘打卡）**，完成三方對帳。
- [ ] 完成步驟 4 全部 **10 題 JOIN DML 實戰**，並使用 Microsoft Postgres MCP 查詢 Prompt 驗證結果。
