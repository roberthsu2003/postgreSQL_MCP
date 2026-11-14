# 實戰 1｜行政耗材庫存表（從一張表認識 DDL、交易與 DML）

> **對應 Excel**：[耗材庫存表.xlsx](耗材庫存表.xlsx)（總務／行政部門常見的辦公室耗材盤點表）
>
> **核心理念**：先不學多表 JOIN，先把「單一資料表」的四件大事做紮實：**親手寫 DDL 建表** → **請 AI 建立 Transaction 交易檔** → **手寫 DML 回答故事並用 Microsoft Postgres MCP 雙軌驗證** → **做出桌面庫存小工具**。

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：沒有備份 `.sql` 可以一鍵還原，也沒有匯入精靈可以點。你要看著需求與規格，自己打開 DBeaver Query Tool 親手寫 `CREATE TABLE`。
2. **用 AI 建立 Transaction（交易）**：自己建好空資料表後，把你的 `CREATE TABLE` 和 `耗材庫存表.xlsx` 交給 AI，請 AI 產出標準 `BEGIN; ... COMMIT;` 交易檔，經你檢查後親自執行並核對金額。
3. **10 題 DML ＋ Microsoft Postgres MCP 交叉驗證**：步驟 4 準備了 **5 則核心故事 ＋ 5 題進階練功（共 10 題）**，每題都能先在 DBeaver 手寫練習，再用 `@microsoft/postgres-mcp` 查詢 Prompt 請 AI 做唯讀交叉比對。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且在 DBeaver 中能順利連線。
- [ ] 已參考 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），在全域 `~/.gemini/config/mcp_config.json` 設定好 **`@microsoft/postgres-mcp`**。
- [ ] 確認可透過 Microsoft Postgres MCP 的 `postgres_mcp_connect` 切換目標資料庫（若使用 Supabase 免費方案，可在預設資料庫建立獨立 Schema 練習）。
- [ ] 已經開啟 [耗材庫存表.xlsx](耗材庫存表.xlsx)，看過三個工作表：`耗材庫存`（25 筆樣本）、`需求`（5 則故事 S1～S5）、`有問題的資料`（7 筆壞資料測試案例）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 讀懂 Excel 與需求故事 | [1_讀懂Excel與故事.md](1_讀懂Excel與故事.md) | 拆解欄位型別與限制規則，思考為什麼 Excel 會出錯 |
| **步驟 2** | 親手撰寫 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 建立 `supplies` 資料庫與資料表、實測 7 筆壞資料阻擋、用 MCP 驗收結構 |
| **步驟 3** | AI 建立交易檔寫入 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 貼上你的 DDL 與 Excel，請 AI 產出 `BEGIN...COMMIT` 交易檔並完成三方對帳 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_DML回答故事.md](4_DML回答故事.md) | 完成 S1～S5 核心故事與 E1～E5 進階練習，每題皆附 MCP 查詢驗證 Prompt |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `supplies` 產出需求文件 |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 將需求拆解成逐項可驗收的開發任務 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 依 `todolist` 完成具備領用交易與安全補貨提醒的 Tkinter 小工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE supplies;` 清空資料表，再重新執行你在**步驟 3 請 AI 產生的資料交易檔（`建立資料.sql`）**，即可恢復為初始 25 筆資料！

| 檔案 | 用途說明 |
|---|---|
| [耗材庫存表.xlsx](耗材庫存表.xlsx) | 原始職場試算表（含 `耗材庫存`、`需求`、`有問題的資料`） |
| [1_讀懂Excel與故事.md](1_讀懂Excel與故事.md) | 步驟 1：需求剖析與欄位規則推論練習 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫 DDL、壞資料測試與 MCP 結構驗收 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 建立 `BEGIN...COMMIT` 交易檔、ROLLBACK 測試與對帳 |
| [4_DML回答故事.md](4_DML回答故事.md) | 步驟 4：10 題 DML 任務挑戰（S1～S5 ＋ E1～E5）＋ Microsoft Postgres MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：在資料庫建立最小權限的 `ai_readonly` 唯讀帳號 |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：使用 `@microsoft/postgres-mcp` 讀取資料庫結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 轉為實作待辦清單 |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 桌面 App 所需套件（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準（完成本專案的定義）

- [ ] 親手寫出 `CREATE TABLE supplies (...)` 並透過 `@microsoft/postgres-mcp` 檢查結構完全正確。
- [ ] `有問題的資料` 中的 7 筆壞資料（重複品號、缺品名、負庫存、負單價、非法類別、非數字單價、非法日期）全部被資料庫擋下。
- [ ] 使用 AI 產生的 `BEGIN; ... COMMIT;` 交易檔成功寫入 25 筆資料，且對帳確認總庫存 **546 件**、總金額 **66,474 元**。
- [ ] 完成步驟 4 全部 **10 題 DML 實戰**，並體驗過用 Microsoft Postgres MCP 查詢 Prompt 與 DBeaver 結果雙軌比對。
- [ ] 完成步驟 5～8，不依賴任何現成救援腳本即打造出可操作的庫存管理小工具。
