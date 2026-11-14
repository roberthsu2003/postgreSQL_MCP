# 實戰 2｜IT 設備規格表（用 JSONB 收納每種設備截然不同的規格）

> **對應 Excel**：[設備規格表.xlsx](設備規格表.xlsx)（資訊部門常見的資產規格清冊）
>
> **核心理念**：筆電要記 CPU／記憶體、投影機要記流明／解析度、印表機要記雙面列印／紙張大小。傳統做法會把 Excel 越拉越寬、滿是空白。這一次我們要用 PostgreSQL 的 **`JSONB`** 欄位，讓每筆設備只存屬於自己的規格！

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：看著需求與規格，自己打開 DBeaver 親手敲出 `CREATE DATABASE devices;` 與 `CREATE TABLE devices (...)`。
2. **用 AI 建立 Transaction（交易）**：貼上自己的建表語法與 `設備規格表.xlsx`，請 AI 幫你把 14 欄寬表轉成只取非空規格、自動塞進 `JSONB` 的 `BEGIN; ... COMMIT;` 交易檔。
3. **10 題 JSONB 實戰 ＋ Microsoft Postgres MCP 雙軌驗證**：親手寫 `specs->>'...'` 轉型、布林篩選、`jsonb_set` 升級與交易沙盒，每題皆附 `@microsoft/postgres-mcp` 查詢驗證 Prompt。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且 DBeaver 可正常連線。
- [ ] 已依照 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），設定好全域 `@microsoft/postgres-mcp`。
- [ ] 已確認可透過 `postgres_mcp_connect` 切換到 `devices` 資料庫（或 Supabase 獨立 Schema）。
- [ ] 已打開 [設備規格表.xlsx](設備規格表.xlsx)，看過 `設備清單`（16 台）、`需求`（S1～S5）與 `有問題的資料`（5 筆）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 分析哪裡該放進 JSONB | [1_哪些欄位放JSONB.md](1_哪些欄位放JSONB.md) | 區分「共通欄位（固定欄）」與「動態規格（JSONB）」，並完成拆解思考題 |
| **步驟 2** | 親手撰寫 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 建立 `devices` 資料庫與資料表、實測 5 筆壞資料（含錯誤 JSON 格式） |
| **步驟 3** | AI 建立 JSONB 交易檔 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 讓 AI 忽略空白儲存格並轉成標準 JSONB `BEGIN...COMMIT` 交易檔＋對帳 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_JSONB回答故事.md](4_JSONB回答故事.md) | 練習 S1～S5 核心故事與 E1～E5 進階 JSONB 查詢／交易沙盒 |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `devices` 產出需求文件 |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 拆解成可逐項測試打勾的開發清單 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 完成可查 JSONB 規格、升級記憶體與新增設備類型的 Tkinter 工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE devices;` 清空資料表，再重新執行你在**步驟 3 請 AI 產生的資料交易檔**，即可恢復為初始 16 台設備！

| 檔案 | 用途說明 |
|---|---|
| [設備規格表.xlsx](設備規格表.xlsx) | 原始資產表（含 14 欄寬表樣本、`需求`、`有問題的資料`） |
| [1_哪些欄位放JSONB.md](1_哪些欄位放JSONB.md) | 步驟 1：分辨固定欄位與 JSONB 欄位的實務原則 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫 DDL、JSONB 壞資料測試與 MCP 驗收 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 產生 JSONB 交易檔、ROLLBACK 保護測試與對帳 |
| [4_JSONB回答故事.md](4_JSONB回答故事.md) | 步驟 4：10 題 JSONB DML 任務挑戰 ＋ Microsoft Postgres MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：建立 `ai_readonly` 唯讀帳號 |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：用 `@microsoft/postgres-mcp` 讀取結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 拆解為 todolist |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 套件清單（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準

- [ ] 親手寫出含 `specs JSONB NOT NULL` 的 `CREATE TABLE devices (...)` 並透過 MCP 確認結構。
- [ ] `有問題的資料` 5 筆測試案例（重複 PK、規格空白、負單價、非法日期、單引號 JSON）全數被資料庫攔截。
- [ ] AI 交易檔寫入 16 台設備，三方對帳確認總金額 **466,000**、筆電 8 台、投影機 4 台、印表機 4 台。
- [ ] 完成步驟 4 全部 **10 題 JSONB DML 實戰**，並用 Microsoft Postgres MCP 查詢驗證過結果。
