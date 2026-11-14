# 實戰 5｜網路商店訂單：多對多與歷史價格（`orders` × `order_items` × `ON DELETE CASCADE`）

> **對應 Excel**：[網路商店訂單表.xlsx](網路商店訂單表.xlsx)（業務／客服團隊的日常訂單總表）
>
> **核心理念**：一張訂單可以買很多商品，一項商品也會出現在不同訂單——這就是資料庫最經典的**多對多關聯**！同時你會在 Excel 裡親眼看到「保溫鋼杯前後出現過 `450` 和 `490` 兩個價格」：這不是打錯字，而是**歷史成交單價 vs 目前商品售價**必須分開儲存的真實業務需求！

---

## 本專案實作三大鐵則

1. **全程不匯入現成檔案**：看著多對多 ER 圖與欄位規格，自己打開 DBeaver Query Tool 親手敲出四張表的 `CREATE TABLE`（含 `ON DELETE CASCADE` 連動刪除規則）。
2. **用 AI 建立 Transaction（交易）**：貼上四句建表 DDL 與 `網路商店訂單表.xlsx`，請 AI 區分 `products.price`（目前售價）與 `order_items.unit_price`（當時成交價），加上 **`setval()`** 產出純 SQL `BEGIN; ... COMMIT;` 交易檔。
3. **10 題訂單與定價 DML ＋ Microsoft Postgres MCP 雙軌驗證**：練習 S1～S5 核心訂單交易與 E1～E5 進階營收/價差/RFM/下單沙盒，每題皆附 `@microsoft/postgres-mcp` 查詢驗證 Prompt。

---

## 開始之前：環境檢查清單

- [ ] 本機或雲端 PostgreSQL 伺服器已啟動，且 DBeaver 可順利連線。
- [ ] 已依照 [第 1 章 MCP 設定](../../raspberry_docker安裝/4_單獨安裝mcp_server.md)（或 [Supabase 設定](../../supabase安裝/README.md)），設定好全域 `@microsoft/postgres-mcp`。
- [ ] 已確認可透過 `postgres_mcp_connect` 切換到 `online_shop` 資料庫（或 Supabase 獨立 Schema）。
- [ ] 已打開 [網路商店訂單表.xlsx](網路商店訂單表.xlsx)，看過 `全部訂單`（18 列資料）、`需求`（S1～S5）與 `有問題的資料`（8 筆）。

---

## 學習與開發流程（步驟 1 → 步驟 8）

| 階段 | 對應動作 | 檔案／工具 | 目標與產出 |
|---|---|---|---|
| **步驟 1** | 分析多對多與雙重價格 | [1_多對多與歷史價格.md](1_多對多與歷史價格.md) | 找出「保溫鋼杯 450/490」與「空洞列」原因，算出對帳數字 |
| **步驟 2** | 親手撰寫四張 DDL 建表 | [2_手寫DDL.md](2_手寫DDL.md) | 建立 `online_shop` 資料庫、4 張表、`ON DELETE CASCADE`，實測 8 筆壞資料 |
| **步驟 3** | AI 建立雙價位交易檔 | [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 讓 AI 產出含 `setval()` 的四表交易檔並核對 `12,080` 元總金額 |
| **步驟 4** | 手寫 10 題 DML ＋ MCP 驗證 | [4_訂單查詢回答故事.md](4_訂單查詢回答故事.md) | 完成 S1～S5 建單刪單/調價與 E1～E5 營收/價差/RFM/下單沙盒 |
| **步驟 5** | MCP 讀結構寫出 `PRD.md` | [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 用 `@microsoft/postgres-mcp` 唯讀連線 `online_shop` 產出 PRD |
| **步驟 6** | 從 PRD 拆解 `todolist.md` | [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 拆解成逐項可驗收的開發清單 |
| **步驟 7** | 實作 Python 桌面小工具 | 參考 [PRD.md](PRD.md) 與 [todolist.md](todolist.md) | 完成可查訂單、會員紀錄、調整售價與安全建單／刪單的 Tkinter 工具 |
| **步驟 8** | 一條一條親自驗收 | [todolist.md](todolist.md) | 對照真實資料庫數字逐項勾選驗收 |

---

## 資料夾檔案說明

> **若練習過程把資料改亂了怎麼辦？**  
> 在 DBeaver 執行 `TRUNCATE TABLE order_items, orders, products, customers RESTART IDENTITY;` 清空四張表並重置自動編號，再重新執行你在**步驟 3 請 AI 產生的資料交易檔**，即可恢復初始狀態！

| 檔案 | 用途說明 |
|---|---|
| [網路商店訂單表.xlsx](網路商店訂單表.xlsx) | 原始訂單工作表（含 16 筆有效訂單列＋2 筆孤立樣本、`需求`、`有問題的資料`） |
| [1_多對多與歷史價格.md](1_多對多與歷史價格.md) | 步驟 1：多對多中間表設計與歷史價格保存思考 |
| [2_手寫DDL.md](2_手寫DDL.md) | 步驟 2：任務挑戰制手寫 4 表 DDL、`CASCADE` 與 8 筆壞資料實測 |
| [3_AI產生資料交易檔.md](3_AI產生資料交易檔.md) | 步驟 3：AI 產出含目前售價/成交價區隔與 `setval()` 交易檔＋對帳 |
| [4_訂單查詢回答故事.md](4_訂單查詢回答故事.md) | 步驟 4：10 題訂單 DML 實戰（S1～S5 ＋ E1～E5）＋ MCP Prompt |
| [prompts/00_建立唯讀帳號.sql](prompts/00_建立唯讀帳號.sql) | 選用：授權 `ai_readonly` 唯讀帳號存取 `online_shop` |
| [prompts/01_MCP讀結構產生PRD.md](prompts/01_MCP讀結構產生PRD.md) | 步驟 5：用 `@microsoft/postgres-mcp` 讀取四表結構產生 PRD |
| [prompts/02_PRD產生todolist.md](prompts/02_PRD產生todolist.md) | 步驟 6：把 PRD 拆解為 todolist |
| [PRD.md](PRD.md) | 範例成品規格文件（僅供對照） |
| [todolist.md](todolist.md) | 範例成品驗收清單（僅供對照） |
| [requirements.txt](requirements.txt) | 步驟 7 Python 套件清單（`psycopg2-binary`、`python-dotenv`） |

---

## 專案驗收標準

- [ ] 親手建立 `customers`、`products`、`orders`、`order_items` 四張表（含 `ON DELETE CASCADE`），並通過 MCP 結構檢查。
- [ ] `有問題的資料` 8 筆壞資料與「刪除被使用中的會員／商品」全數被資料庫攔截。
- [ ] AI 交易檔成功寫入 **5 位會員、7 項商品、10 張訂單、16 筆明細、總金額 12,080**，且 `setval` 正確。
- [ ] 完成步驟 4 全部 **10 題多對多 DML 實戰**，理解「調價不改舊訂單」並用 Microsoft Postgres MCP 驗證通過。
