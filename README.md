# PostgreSQL 學習指南

結合自然語言 AI、手寫 SQL 基礎、Python 應用開發，到最後自行打造自訂 MCP Server 的完整 PostgreSQL 實戰指南。

## 學習四階段路線

![學習四階段路線](./mcp_server/images/learning_roadmap.svg)

| 階段 | 章節 | 你會學到 | 使用工具與環境 |
|:---:|---|---|---|
| **一** | [1. 環境安裝](#1-環境安裝) | 安裝 PostgreSQL（樹莓派 Docker / Supabase）與 DBeaver 圖形工具 | Docker / Supabase / DBeaver |
| **一** | [2. 範例資料庫](#2-範例資料庫) | 繁中範例庫（咖啡門市、電商、選課、圖書館）與自備 Excel 轉 SQL 交易檔 | DBeaver 匯入 |
| **一** | [3. 自然語言查庫初體驗](#3-自然語言查庫初體驗免寫-sql) | 不用會寫 SQL！直接用中文向 AI 提問網路商店資料，體驗 AI 自動查庫的便利 | Antigravity + 專案級 MCP |
| **二** | [4. SQL 語法與實戰練功](#4-sql-語法與實戰練功) | **講義與實戰題合一**：DDL/DML，每課搭配 prompt 讓 AI 做一次，章節尾端直接附實戰練習題 | DBeaver + Antigravity 對話 |
| **三** | [5. Python 串接](#5-python-串接psycopg2) | **在 Antigravity 中寫程式**：用 psycopg2 從 Python 進行資料庫 CRUD 與交易管理 | Antigravity (Python) |
| **三** | [6. 實戰專案開發](#6-實戰專案規格驅動開發-sdd) | 規格驅動開發 (SDD)，結合 Python 內建 Tkinter / PyQt 打造 5 款個人桌面小 App | Antigravity + Tkinter / PyQt |
| **四** | [7. 自訂 MCP Server](#7-自訂-mcp-server個人本機開發到企業容器化導入) | **壓軸單元**：打造自訂 MCP Server，封裝專屬商業邏輯與 Token 安全防護 | Antigravity + FastMCP |

---

## 1. 環境安裝

本課程環境採用**容器化標準（Docker）**運行 PostgreSQL 資料庫，免除繁瑣的原生環境設定；管理與查詢則由本機電腦的 **DBeaver** 與 **Antigravity 專案級 MCP** 負責：

| 環境 / 安裝方式 | 包含內容 | 教學連結 |
|---|---|:---:|
| ⭐ **Raspberry Pi（Docker 容器推薦）** | 樹莓派 Docker 安裝、PostgreSQL 容器化運行、DBeaver SSH 隧道、專案 MCP 與 Docker Compose 雙容器整合 | [查看教學](./raspberry_docker安裝/) |
| ⭐ **Supabase（雲端託管容器）** | 免硬體！申請免費雲端託管 PostgreSQL、DBeaver 直連與 Antigravity 專案級 MCP 設定 | [查看教學](./supabase安裝/) |

> 💡 連線字串格式：`postgresql://使用者名稱:密碼@主機:埠號/資料庫名稱`

---

## 2. 範例資料庫

提供學習各階段所需的資料庫範例檔與**「自備上班 Excel 轉 SQL 交易檔」**實作指南：  
👉 **[範例資料庫與 App 產品規劃專區](./範例資料庫/)**

| 類別 | 範例內容 | 學習用途與產品落地 |
|---|---|---|
| 🌟 **[自備 Excel 轉 SQL 實戰示範](./範例資料庫/excel範例/自備Excel轉SQL實戰示範/)** | 上傳「員工差旅報銷單.xlsx」➡️ AI Prompt ➡️ 產出「`expense_tracker.sql`」 | **回家自主實作核心**：完整實體 Excel 檔與產出 SQL 交易檔對照，學生在 DBeaver 親手執行，嚴禁 MCP 自動代勞 |
| ☕ **連鎖門市月報表** | 跨月銷售 Excel / CSV ➡️ `cafe_shop.sql` | 解決「每月複製一份 Excel」痛點，最終打造 **[門市店長營運分析桌面小視窗](./app_projects/project2_cafe_dashboard/)** |
| 🛒 **Excel 正規化對照範例** | 未正規化單表 Excel / CSV ➡️ 多表正規化 Excel | 體驗單表痛點與 3NF 正規化，對照 `shop.sql` 打造 **電商訂單履約與客戶 CRM 視窗工具** |
| ⭐ **繁體中文範例資料庫** | 咖啡門市、網路商店、學校選課、圖書館借閱、股市快取 | 執行單一 `.sql` 檔即完成建表與匯入，對照打造 5 大個人桌面視窗小 App |
| 🚀 **巨量資料產生器** | 1 秒自體生成 10 萬筆訂單明細腳本 | 零網路傳輸，用於索引優化 (INDEX) 與查詢計畫 (EXPLAIN ANALYZE) 效能壓測 |

---

## 3. 自然語言查庫初體驗（免寫 SQL）

在第 1 章完成環境安裝後，我們的 Antigravity 已經具備了專案級 MCP 連線能力。
現在只要在對話框中**用中文問問題，AI 就會自動查詢資料庫並整理成表格回答你**！完全不需要事先學會寫 SQL。

* 👉 **[前往實戰：自然語言查詢資料庫（網路商店範例）](./MCP操作資料庫/2_用中文查詢資料庫/)**：附有標準提問範例與驗證答案，親身體驗 AI 自動判斷資料表與撈取資料的便利。

---

## 4. SQL 語法與實戰練功

在第 3 章體驗了 AI 查庫後，**第 4 章我們要自己動手學會寫 SQL**！  
本章採用**「講義觀念與實戰練習合一」**設計：每一課先學標準 SQL 語法，搭配「🤖 **不寫 SQL，用 Prompt 完成**」單元驗證 AI，章節底部更附有**「🛠️ 實戰演練區」**，直接拿 `cafe_shop` 或 `shop` 範例庫進行題目挑戰！


### DDL：資料定義語言

建立、修改資料庫與資料表的**結構**（Schema）。

| # | 單元 | 內容 |
|:---:|---|---|
| 導讀 | [DDL 概念簡介](./SQL語法教學/DDL%28定義資料語言%29.md) | 什麼是資料定義語言？CREATE、ALTER、DROP 概念總覽 |
| 1 | [建立資料庫](./SQL語法教學/1建立資料庫.md) | `CREATE DATABASE`、`DROP DATABASE` |
| 2 | [資料表與基本型別](./SQL語法教學/2_0基本型別.md) | 數值、文字、日期時間等資料型別速查 |
| 3 | [建立資料表](./SQL語法教學/2建立資料表.md) | `CREATE TABLE`、`ALTER TABLE`、欄位結構操作 |
| 4 | [匯入 CSV](./SQL語法教學/2_1匯入csv.md) | 將 CSV 匯入資料表（含 22 縣市天氣與門市銷售大表） |
| 5 | [限制條件](./SQL語法教學/4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE`、`DEFAULT` |

### DML：資料操作語言

新增、查詢、修改、刪除資料表裡的**資料**（Data）。

| # | 單元 | 內容 |
|:---:|---|---|
| 導讀 | [DML 概念簡介](./SQL語法教學/DML%28資料操作語言%29.md) | 什麼是資料操作語言？INSERT、SELECT、UPDATE、DELETE 概念總覽 |
| 1 | [新增資料](./SQL語法教學/3新增資料.md) | `INSERT INTO` |
| 2 | [取得資料](./SQL語法教學/6取得資料.md) | `SELECT`、`WHERE`、`ORDER BY` |
| 3 | [修改和刪除](./SQL語法教學/5修改和刪除.md) | `UPDATE`、`DELETE` |
| 4 | [FOREIGN KEY](./SQL語法教學/7_0FOREIGN_KEY.md) | 外來鍵與資料表關聯 |
| 5 | [JOIN](./SQL語法教學/JOIN.md) | 合併多張資料表 |
| 6 | [JSON 應用](./SQL語法教學/16json.md) | `JSON` / `JSONB` 欄位 |

---

### 💡 觀念分水嶺：從單一資料表基礎 ➡️ 邁向關聯式資料庫

> ⚠️ **在進入關聯資料庫前，請先理解這個核心思維**：
> 
> * **上面的 DDL / DML 基礎**：教的是**「單一資料表」的基本操作**（建立、新增、修改、查詢）。這就像在 Excel 裡只使用**「單一個工作表（Sheet）」**來記帳。
> * **下方的關聯式資料庫**：教的是**「多張資料表之間的關聯（Relation）」**。這就像在 Excel 裡使用**「多個工作表」**並透過 `VLOOKUP` / `XLOOKUP` 互相串連（在 SQL 中就是 `JOIN`）！
>
> ❓ **思考一下（痛點）**：如果把公司的訂單、客戶個資、商品資料全部塞在「同一個 Excel 工作表」，會發生什麼災難？（同一位客戶改電話要改幾百列？取消訂單時連客戶資料一起被刪除？新進商品沒人買無法登記？）
> 
> 👉 **[必讀觀念教學：從 Excel 到關聯式資料庫（正規化思維）](./範例資料庫/從Excel到關聯資料庫_正規化.md)**  
> 內附實體範例檔與 Prompt 演練：
> 1. 📄 [未正規化_網路商店單一工作表.xlsx](./範例資料庫/excel範例/未正規化_網路商店單一工作表.xlsx)（親身體驗單一表的 4 大災難）
> 2. 🤖 用 Antigravity AI 丟 Prompt 學習**正規化法則（1NF ➡️ 2NF ➡️ 3NF）**
> 3. 📊 [正規化_網路商店多工作表.xlsx](./範例資料庫/excel範例/正規化_網路商店多工作表.xlsx)（拆解為 4 個工作表，完全對照我們的 [`shop.sql`](./範例資料庫/中文範例資料庫/shop.sql)）

---

### 關聯資料庫實作案例

從零建立一個關聯資料庫，並練習各種查詢。建議先看[適合初學者的版本](./SQL語法教學/7.0適合初學者關聯資料庫.md)。第 2～9 課的 prompt 請看 👉 [🤖 關聯資料庫實作：用 Prompt 操作](./SQL語法教學/關聯資料庫實作_用Prompt操作.md)

| # | 單元 | # | 單元 |
|:---:|---|:---:|---|
| 1 | [創建關聯資料庫](./SQL語法教學/7創建關聯資料庫.md) | 6 | [聯集 UNION](./SQL語法教學/12聯集.sql) |
| 2 | [新增資料](./SQL語法教學/8新增關聯資料庫資料.sql) | 7 | [連結 JOIN](./SQL語法教學/13連結.sql) |
| 3 | [搜尋資料](./SQL語法教學/9搜尋關聯資料庫.sql) | 8 | [子查詢 SubQuery](./SQL語法教學/14子查詢.sql) |
| 4 | [聚合函式](./SQL語法教學/10聚合函式.sql) | 9 | [ON DELETE 動作](./SQL語法教學/15on_delete_action.sql) |
| 5 | [萬用字元](./SQL語法教學/11萬用字元.sql) | | |

---

## 5. Python 串接（用自然語言 Prompt 驅動連線）

本章不是要讓你硬背 Python 語法，而是學會使用自然語言 Prompt 指引 AI，快速生成安全、能讀取 `.env` 並連線到範例資料庫（如 `cafe_shop`）的 Python 專案。 👉 [章節總覽與常用 Prompt](./python/)

| # | 單元 | 核心概念與 Prompt 重點 |
|:---:|---|---|
| 1 | [安裝和環境](./python/安裝和介紹) | 安裝套件、使用 `.env` 保管密碼，請 AI 產生連線測試檔 |
| 2 | [基本查詢](./python/basic_module_usage) | 查詢 `cafe_shop` 商品與門市，請 AI 抓取資料並印出表格 |
| 3 | [使用 with 語法](./python/with) | 請 AI 使用 `with` 語法自動 commit / rollback，確保交易安全 |
| 4 | [安全傳遞參數](./python/parameter) | 嚴禁字串拼接！請 AI 撰寫 `%s` 參數化查詢防止 SQL Injection |
| 5 | [型別對應](./python/type) | PostgreSQL 型別與 Python 對應關係，請 AI 轉換 JSON 格式 |
| 6 | [例外處理](./python/exception) | 請 AI 加上 `try...except psycopg2.Error` 與自動 rollback 容錯防呆 |

---

## 6. 實戰專案（規格驅動開發 SDD）

本階段採用現代 AI 軟體工程的 **規格驅動開發 (SDD, Spec-Driven Development)**：透過 `PRD.md` 規範需求，由 AI 透過 MCP 讀取真實資料庫結構並產生 `plan.md`，循序實作具備快取與視覺化的完整商業 App。  
**本目錄 5 大實戰專案，100% 對應繁體中文範例資料庫！** 👉 [專案總覽](./app_projects/)

| 專案 | 對應資料庫 | 介面 | 核心技術與手寫 SQL 說明 |
|---|---|---|---|
| ⭐ [股市即時監控與增量同步](./app_projects/project1_stock_market/) | `init_stock_db.sql` | Tkinter + Matplotlib | **Cache-Aside 快取與增量同步**：無資料抓 yfinance、有資料走 DB、手寫 SQL `ON CONFLICT DO UPDATE` |
| ☕ [連鎖門市營運分析桌面 App](./app_projects/project2_cafe_dashboard/) | `cafe_shop.sql` | Tkinter (Treeview) | **門市店長營運分析桌面小視窗**：多表手寫 JOIN、跨月營業額統計、HAVING VIP 常客篩選 |
| 🛒 [電商訂單履約與客戶 CRM](./app_projects/project3_shop_crm/) | `shop.sql` | Tkinter (雙分頁) | **訂單流水線履約與 RFM 分群**：手寫 SQL 訂單狀態過濾、點擊訂單展開明細、RFM 模型自動分群 |
| 🎓 [校園智慧選課與學分審查](./app_projects/project4_school_enrollment/) | `school.sql` | Tkinter (課表網格) | **選課防衝堂檢核與學分審查**：手寫 SQL 衝堂檢查、防呆彈出警告視窗、畢業學分達成率進度 |
| 📚 [圖書館借閱與罰金系統](./app_projects/project5_library_system/) | `library.sql` | Tkinter (模糊搜尋) | **館藏流通狀態與逾期罰款計算**：LIKE 模糊搜尋、動態日期相減計算逾期罰金、年度排行 (RANK) |

---

## 7. 自訂 MCP Server（個人本機開發到企業容器化導入）

學會了 SQL 與 Python 後，我們不再受限於現成工具，而是**使用 Python（FastMCP）在 Antigravity 中親手打造專屬的 MCP Server**！
採用**「先個人（本機執行 MCP 連樹莓派 DB） $\rightarrow$ 後企業共用（打包進樹莓派 Docker 雙容器 + Token 門禁）」**的循序漸進路線。 👉 [章節總覽](./mcp_server/)

| 階段 | 單元 | 你的角色 | 內容 |
|:---:|---|---|---|
| **個人篇** | [1. 用 AI 建立自己的 MCP Server（唯讀）](./mcp_server/1_用AI建立MCP_server/) ⭐ | 需求設計者、開發者 | 在本機規劃工具 → 撰寫 FastMCP 程式碼 → 本地 Inspector 除錯與專案掛載 |
| **個人篇** | [2. 會寫入資料的 MCP Server（安全寫入）](./mcp_server/2_寫入型MCP_server/) ⭐ | 需求設計者、驗收者 | 圖書館借還書：只開放特定寫入、商業檢查寫在程式裡、資料庫交易（Transaction） |
| **企業篇** | [3. 企業導入：遠端 MCP 與 Token 門禁](./mcp_server/3_企業導入_遠端MCP與token/) ⭐ | 系統導入者 | 升級為 Streamable HTTP 遠端服務，員工帶 Token 連線，留下即時稽核紀錄 |
| **企業篇** | [4. 正式上線：部署至樹莓派 Docker 雙容器](./mcp_server/4_樹莓派Docker容器部署/) ⭐ | 系統架構師 | 撰寫 `Dockerfile` 與 `docker-compose.yml`，將 MCP 放進樹莓派與 PostgreSQL 內網直連 |
| **綜合篇** | [5. 企業各部門範例集](./mcp_server/5_範例集/) | 參考、示範 | 網路商店客服、教務處、圖書館、YouBike、股市，5 個部門的 AI 助理（本機/遠端雙模） |
| **綜合篇** | [期末專題](./mcp_server/#期末專題) | 全部 | 用 AI 為一間「公司」打造專屬的 MCP Server 並完成容器化部署 |

---

## 參考文件

- [PostgreSQL 官方文件](https://www.postgresql.org/docs/current/)
- [PostgreSQL Tutorial](https://neon.com/postgresql/tutorial)
- [psycopg2 官方文件](https://www.psycopg.org/docs/)
