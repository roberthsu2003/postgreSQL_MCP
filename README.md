# 🐘 PostgreSQL 職場實戰學習指南

<div align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PyQt5](https://img.shields.io/badge/GUI-PyQt5-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![Tkinter](https://img.shields.io/badge/GUI-Tkinter-FFD43B?style=for-the-badge&logo=python&logoColor=3776AB)
![DBeaver](https://img.shields.io/badge/Client-DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![FastMCP](https://img.shields.io/badge/Protocol-Model%20Context%20Protocol-8A2BE2?style=for-the-badge)

<br/>

**專為上班族（會計、出納、總務、業務、人資）量身打造！**  
**告別混亂 Excel 痛點 ➡️ 透過 AI 轉換為關聯式 SQL 交易檔 ➡️ 在 DBeaver 親自動手執行 ➡️ 打造專屬個人本機桌面小 App（PyQt5 / Tkinter）**

</div>

---

## 🎯 核心教學理念與安全規範

> [!IMPORTANT]
> **本專案的核心目標是「讓學員扎實學會 SQL 與資料庫架構」，嚴格遵循以下三大規範：**
> 
> 1. **AI 是助教，手寫才是真功夫**：學員**不可以叫 MCP 寫入資料庫**（建表、新增、修改、刪除），但**可以讓 MCP 讀取**資料庫的結構和資料。AI 提供建議與 SQL，學員必須親自在 **DBeaver** 中檢視並手動執行。第 7 章的實戰專案不受此限。
> 2. **拒絕線上架站繁瑣，聚焦個人本機桌面軟體**：捨棄需要伺服器與雲端維運的 Web / Streamlit 線上版，專注使用 **PyQt5**（高質感商業管理視窗）與 **Tkinter**（Python 內建、免繁複環境安裝），開發在自己電腦上即開即用的個人管理小工具。
> 3. **SQL 自己寫，App 由 AI 做**：每則需求的 SQL 都由學員親手寫好並在 DBeaver 跑過。桌面 App 的 Python 由 AI 產生，學員依 `todolist.md` 逐項驗收畫面，並確認每句 SQL 都看得懂。

---

## 🚀 第一次來？這樣開始

1. **選環境**：有樹莓派走 [Docker 方案](./raspberry_docker安裝/)，沒有就走 [Supabase 雲端方案](./supabase安裝/)（最快）。
2. **照順序走**：第 1 章走到第 7 章，每一章都接著前一章。第 4 章學完一個段落，就可以接著做第 7 章對應的實戰專案。
3. **每課都親手打**：看懂不等於會寫。每課結尾的 ✅ 過關檢查都打勾了，再往下走。
4. **卡住了**：先看該課的「⚠️ 常見卡關」，再把 SQL 和錯誤訊息貼給 AI，問它「錯在哪裡，為什麼」。

| 章 | 主題 | 完成後你能 |
|:---:|---|---|
| 1 | [環境安裝](#1-環境安裝) | 用 DBeaver 連上自己的資料庫 |
| 2 | [範例資料庫](#2-範例資料庫) | 匯入五大職場範例 |
| 3 | [用中文查詢資料庫](#3-自然語言查詢資料庫初體驗免寫-sql) | 不寫 SQL 也能問 AI 查資料 |
| 4 | [SQL 語法與練功](#4-sql-語法與實戰練功) | **親手寫出跨表報表，並抓出 AI 的錯** |
| 5 | [Python 串接](#5-python-串接psycopg2) | 用程式自動查詢，並防止資料庫被駭 |
| 6 | [自訂 MCP Server](#6-讓自己的-ai-可以查詢自己的資料庫自訂-mcp-server) | 讓 AI 只能呼叫你設計的工具 |
| 7 | [Excel 實戰專案](#7-實戰專案規格驅動開發-sdd打造-5-大職場個人桌面-app) | 把工作上的 Excel 變成資料庫和個人小工具 |

**只想學 SQL？** 做完第 1、2 章，直接跳到第 4 章。

---

## 🗺️ 學習四階段路線

![學習四階段路線](./mcp_server/images/learning_roadmap.svg)

| 階段 | 章節模組 | 你會學到與產出 | 使用工具與環境 |
|:---:|---|---|---|
| **一** | **[1. 環境安裝](#1-環境安裝)**<br>**[2. 範例資料庫](#2-範例資料庫)**<br>**[3. 自然語言查詢資料庫初體驗](#3-自然語言查詢資料庫初體驗免寫-sql)** | • 安裝 PostgreSQL（樹莓派 Docker / Supabase）與 DBeaver<br>• 匯入 5 大職場範例資料庫（報銷、差勤、資產、門市、CRM）<br>• 體驗用中文自然語言查詢資料庫 | Docker / Supabase / DBeaver / Antigravity |
| **二** | **[4. SQL 語法與實戰練功](#4-sql-語法與實戰練功)** | • **講義與實戰題合一**：完整 DDL、DML、JOIN、JSONB<br>• 每課都有職場情境、真實執行結果、常見卡關與附答案的練習<br>• 每課附 AI 提示詞，學生親手在 DBeaver 執行 | DBeaver + Antigravity 對話 |
| **三** | **[5. Python 串接](#5-python-串接psycopg2)**<br>**[6. 讓 AI 查詢自己的資料庫](#6-讓自己的-ai-可以查詢自己的資料庫自訂-mcp-server)** | • 使用 `psycopg2` 進行參數化查詢（`%s` 防注入）與交易管理<br>• **讓 AI 查詢自己的資料庫**：用 FastMCP 寫幾行 Python，AI 就能用中文查庫<br>• 從個人本機查庫，進階到企業 Token 門禁與樹莓派 Docker 容器部署 | Python (`psycopg2`) + FastMCP + Docker |
| **四** | **[7. 職場桌面 App 實戰開發](#7-實戰專案規格驅動開發-sdd打造-5-大職場個人桌面-app)** | • **五張職場 Excel，由淺入深**：耗材庫存、打卡、差旅報銷、網路商店、門市月報<br>• 從 user story 開始，手寫 DDL 與 DML，AI 產生交易檔後與 Excel 對帳<br>• AI 透過唯讀 MCP 產生 `PRD.md` 與 `todolist.md`，再做成個人桌面 App<br>• **畢業專題**：換成自己工作上的 Excel 走一次 | DBeaver + Antigravity + Tkinter / PyQt5 |

---

## 1. 環境安裝

本課程採用**容器化標準（Docker）**或**雲端免安裝託管**，免除繁瑣的原生環境設定。資料庫管理一律使用開源直覺的 **DBeaver** 圖形客戶端：

| 環境 / 安裝方式 | 包含內容 | 推薦對象 | 教學連結 |
|---|---|:---:|:---:|
| 🍓 **Raspberry Pi（Docker 容器推薦）** | 樹莓派 Docker 安裝、PostgreSQL 容器化運行、DBeaver SSH 隧道、專案 MCP 雙容器整合 | 想在家中打造專屬常駐資料庫伺服器者 | [查看教學](./raspberry_docker安裝/) |
| ☁️ **Supabase（免費雲端託管）** | 免硬體！申請免費雲端託管 PostgreSQL、取得連線字串、DBeaver 直連設定 | 零硬體負擔、想隨開即用立即開始者 | [查看教學](./supabase安裝/) |

> 💡 **連線字串格式範例**：`postgresql://使用者名稱:密碼@主機IP:5432/資料庫名稱`
>
> 📖 DBeaver 的常用操作，請見 [DBeaver 速查表](./raspberry_docker安裝/3_dbeaver連線.md#步驟-33dbeaver-常用操作速查表)。

---

## 2. 範例資料庫

資料庫不能紙上談兵！我們針對上班族最常見的 5 大部門職能（會計、人資、總務、店長、業務），設計了開箱即用的範例資料庫，內附關聯式架構圖、業務痛點解析與 DBeaver 一鍵匯入步驟。

👉 **[查看詳細結構與匯入教學](./範例資料庫/)**

---

## 3. 自然語言查詢資料庫初體驗（免寫 SQL）

在深入學習 SQL 語法之前，先體驗 AI 賦能的震撼力！  
我們使用微軟官方推出的 **`@microsoft/postgres-mcp`**，透過 Node.js 的 **`npx`** 免安裝指令直接在全域設定 MCP Server（免建 Python 虛擬環境）。只要在 Antigravity 對話框中**用中文問問題，AI 就會自動查詢資料庫並整理成清楚表格回答你**：

* 👉 **[前往實戰：用中文查詢資料庫（以電商 shop 為例）](./MCP操作資料庫/2_用中文查詢資料庫/)**：體驗 AI 自動判斷資料表關聯並查詢資料的便利。

---

## 4. SQL 語法與實戰練功

本章是課程的核心。全章跟著「暖光咖啡」總部的王經理，把每天的 Excel 問題變成一句 SQL。每一課都有：**職場情境 → 語法 → 真實執行結果 → 常見卡關 → 附答案的練習 → 問 AI 助教 → 過關檢查**。講義中的 SQL 都實際執行過，結果就是你應該看到的結果。

👉 **[進入第 4 章目錄](./SQL語法教學/README.md)**：含課程地圖、資料庫對照表和 SQL 速查表。

### 📐 DDL：蓋結構

| # | 單元主題 | 核心內容 | 學完可接實戰專案 |
|:---:|---|---|---|
| 導讀 | [DDL 是什麼](./SQL語法教學/DDL%28定義資料語言%29.md) | CREATE、ALTER、DROP、TRUNCATE | — |
| 1 | [建立資料庫](./SQL語法教學/1建立資料庫.md) | `CREATE DATABASE`、切換資料庫、命名規則 | — |
| 2 | [基本型別](./SQL語法教學/2_0基本型別.md) | 金額為什麼不能用 FLOAT、電話為什麼是文字 | — |
| 3 | [建立資料表](./SQL語法教學/2建立資料表.md) | `CREATE TABLE`、`ALTER TABLE` | — |
| 4 | [匯入 CSV](./SQL語法教學/2_1匯入csv.md) | DBeaver 匯入、驗筆數、亂碼處理 | — |
| 5 | [限制條件](./SQL語法教學/4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE`、`CHECK`、`DEFAULT` | [專案 1](./app_projects/excel1_supplies/) 步驟 1、2 |

### 🔍 DML：操作資料

| # | 單元主題 | 核心內容 | 學完可接實戰專案 |
|:---:|---|---|---|
| 導讀 | [DML 是什麼](./SQL語法教學/DML%28資料操作語言%29.md) | **匯入 `cafe_shop`**，開工準備 | — |
| 1 | [新增資料](./SQL語法教學/3新增資料.md) | `INSERT`、`RETURNING`、單引號的坑 | — |
| 2 | [查詢資料](./SQL語法教學/6取得資料.md) | `SELECT`、`WHERE`、`ORDER BY`、`LIMIT` | — |
| 3 | [修改與刪除](./SQL語法教學/5修改和刪除.md) | `UPDATE`、`DELETE`、保命三步驟與交易 | [專案 1](./app_projects/excel1_supplies/) 步驟 3、4 |
| 4 | [外來鍵](./SQL語法教學/7_0FOREIGN_KEY.md) | 父子表、`ON DELETE` 怎麼選 | — |
| 5 | [JOIN](./SQL語法教學/JOIN.md) | SQL 版的 VLOOKUP：五種 JOIN | [專案 2](./app_projects/excel2_attendance/)（再學完下方的一對多入門） |
| 6 | [JSONB](./SQL語法教學/16json.md) | 飲料客製化、`->` 和 `->>` | — |

### 💡 思維躍升：從單一工作表到多張表

> [!NOTE]
> 單一工作表裡，客戶電話一改就要改幾百列，刪掉訂單連客戶資料都不見。拆成多張表，再用主鍵和外來鍵串起來，這些問題就消失了。

- 👉 **[必讀觀念：從 Excel 到關聯式資料庫](./範例資料庫/從Excel到關聯資料庫_正規化.md)**
- 👉 **[快速上手：一對多關聯](./SQL語法教學/7.0適合初學者關聯資料庫.md)**：學完可接[專案 2](./app_projects/excel2_attendance/)

### 🧩 關聯資料庫進階實戰

| # | 單元主題 | 核心內容 | 練習腳本 | 學完可接實戰專案 |
|:---:|---|---|:---:|---|
| 1 | [建立七張表](./SQL語法教學/7創建關聯資料庫.md) | 親手蓋出 `cafe_shop`、多對多設計 | — | — |
| 2 | [關聯新增](./SQL語法教學/8新增關聯資料庫資料.md) | 寫入順序、交易、SERIAL 撞號 | [.sql](./SQL語法教學/8新增關聯資料庫資料.sql) | [專案 3](./app_projects/excel3_expense/) |
| 3 | [關聯搜尋](./SQL語法教學/9搜尋關聯資料庫.md) | 拆解問題的三個步驟 | [.sql](./SQL語法教學/9搜尋關聯資料庫.sql) | [專案 4](./app_projects/excel4_shop/) |
| 4 | [聚合與分組](./SQL語法教學/10聚合函式.md) | SQL 版樞紐分析表：`GROUP BY`、`HAVING` | [.sql](./SQL語法教學/10聚合函式.sql) | — |
| 5 | [模糊搜尋](./SQL語法教學/11萬用字元.md) | `LIKE`、`ILIKE`、`%`、`_` | [.sql](./SQL語法教學/11萬用字元.sql) | — |
| 6 | [聯集](./SQL語法教學/12聯集.md) | `UNION`、`UNION ALL` | [.sql](./SQL語法教學/12聯集.sql) | — |
| 7 | [綜合連結](./SQL語法教學/13連結.md) | 條件放 `ON` 還是 `WHERE` | [.sql](./SQL語法教學/13連結.sql) | — |
| 8 | [子查詢](./SQL語法教學/14子查詢.md) | `WITH`、`EXISTS`、`NOT IN` 遇到 NULL 的大坑 | [.sql](./SQL語法教學/14子查詢.sql) | — |
| 9 | [ON DELETE](./SQL語法教學/15on_delete_action.md) | 查規則、預測後果、軟刪除 | [.sql](./SQL語法教學/15on_delete_action.sql) | [專案 5](./app_projects/excel5_stores/) |
| 10 | [索引與效能](./SQL語法教學/17索引與效能.md) | 用 5 萬筆資料實測 `INDEX`、`EXPLAIN` | [腳本](./範例資料庫/中文範例資料庫/generate_100k_orders.sql) | — |
| 11 | [AI 助教與結業挑戰](./SQL語法教學/關聯資料庫實作_用Prompt操作.md) | 抓出 AI 的錯、五大職務實戰、結業五題 | — | — |

---

## 5. Python 串接（psycopg2）

學會 SQL 語法後，我們使用 Python 官方標準驅動套件 `psycopg2` 進行連線。本章節著重於**程式架構安全與交易完整性**，引導學員建立穩健的資料庫應用習慣：

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()  # 從 .env 讀取連線資訊，密碼不寫在程式裡

conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)

# with conn：成功自動 commit，出錯自動 rollback
with conn:
    with conn.cursor() as cur:
        # 嚴禁字串拼接！一律用 %s 參數化，防止 SQL Injection
        cur.execute("SELECT order_id, order_date, status FROM orders WHERE store_id = %s LIMIT 3;", (1,))
        for row in cur.fetchall():
            print(row)

conn.close()
```

👉 **[進入第 5 章目錄](./python/)**

1. [安裝與環境設定](./python/安裝和介紹)：使用 `.env` 保管帳密，建立虛擬環境與安裝 `psycopg2-binary`。
2. [基本查詢與操作](./python/basic_module_usage)：執行 `SELECT` 撈取資料與游標（Cursor）運用。
3. [使用 with 語法](./python/with)：掌握 Python 資源管理器，異常時自動 `rollback`，成功自動 `commit`。
4. [安全參數化傳遞](./python/parameter)：**徹底杜絕 SQL Injection 漏洞**，全面使用 `%s` 佔位符。
5. [資料型別對應](./python/type)：PostgreSQL 與 Python 型別轉換（日期時間、NUMERIC 轉 float、JSONB 轉 dict）。
6. [例外處理機制](./python/exception)：補捉 `psycopg2.Error`，保障視窗應用程式不當機崩潰。

---

## 6. 讓自己的 AI 可以查詢自己的資料庫（自訂 MCP Server）

在學會了 SQL 與 Python 串接後，最實用、最有成就感的一步，就是**讓平常對話的 AI，具備專屬於你的大腦——可以直接用中文查詢你自己電腦上的資料庫！**

你不再需要手動把資料匯出成 Excel 丟給 AI，也不需要架設複雜的 Web 後端網站。透過 **MCP（Model Context Protocol）**，只要用 Python (FastMCP) 寫幾行查詢小工具，你的 AI 就能化身為專屬查庫助理，直接在聊天對話框中幫你找出客戶訂單、庫存警報、出勤打卡或營業額！

本章採用大白話教學與循序漸進架構：**「從個人本機專屬助理 $\rightarrow$ 升級到具備 Token 門禁的企業級安全服務與樹莓派 Docker 雙容器常駐」**。

![AI 查庫與自訂 MCP 學習路線](./mcp_server/images/mcp_learning_path.svg)

| 階段 | 單元模組 | 你的角色 | 學習重點與實作內容 |
|:---:|---|:---:|---|
| **個人篇** | **[1. 用 AI 建立自己的 MCP Server（唯讀）](./mcp_server/1_用AI建立MCP_server/)** | 需求設計與開發者 | • 在本機規劃資料查詢工具，使用 FastMCP 撰寫 Python 邏輯<br>• 透過 MCP Inspector 進行本機視覺化除錯，掛載到 Antigravity 中文查庫 |
| **個人篇** | **[2. 會寫入資料的 MCP Server（安全交易）](./mcp_server/2_寫入型MCP_server/)** | 架構設計與驗收者 | • 圖書館借還書情境：嚴格限制寫入介面，商業檢核寫在程式中<br>• 確保資料庫交易（Transaction `BEGIN...COMMIT`）具備原子性 |
| **企業篇** | **[3. 企業導入：遠端 MCP 與 Token 門禁](./mcp_server/3_企業導入_遠端MCP與token/)** | 系統導入工程師 | • 升級為 Streamable HTTP 遠端微服務架構<br>• 導入 Bearer Token 門禁驗證機制，即時記錄每次呼叫的審計日誌 |
| **企業篇** | **[4. 正式上線：部署至樹莓派 Docker 雙容器](./mcp_server/4_樹莓派Docker容器部署/)** | 系統架構師 | • 撰寫 `Dockerfile` 與 `docker-compose.yml`<br>• 將 MCP 與 PostgreSQL 一同打包至樹莓派內網，免開外部 Port 兼顧極速與安全 |
| **綜合篇** | **[5. 企業各部門範例集](./mcp_server/5_範例集/)** | 參考與最佳實踐 | • 提供電商客服、門市營運、金融大盤等完整範例程式碼（本機/遠端雙模） |

---

## 7. 實戰專案：規格驅動開發 SDD（打造 5 大職場個人桌面 App）

每個專案都從一張職場 Excel 開始，由淺入深，最後做成自己電腦上的小工具。完整規劃請見[實戰專案大綱](./app_projects/實戰專案大綱.md)。

```mermaid
flowchart LR
    A["Excel<br>與 user story"] --> B["手寫 DDL<br>蓋結構"]
    B --> C["AI 依結構<br>產生交易檔"]
    C --> D["匯入<br>與 Excel 對帳"]
    D --> E["手寫 DML<br>回答故事"]
    E --> F["AI 用唯讀 MCP<br>寫 PRD.md"]
    F --> G["todolist.md"]
    G --> H["個人桌面 App"]
```

| 專案 | Excel | 職場角色 | 結構 | 這個專案的重點 | 先學完 |
|:---:|---|---|---|---|---|
| 1 | [耗材庫存表](./app_projects/excel1_supplies/) | 🏢 總務 | 單表 | 從 Excel 訂欄位規格、限制條件、基本 DML | DDL、DML-1～3 |
| 2 | [打卡表](./app_projects/excel2_attendance/) | 👥 人資 | 一對多 | 拆成兩張表、處理矛盾資料、`JOIN` 與 `LEFT JOIN` | DML-4、DML-5、一對多入門 |
| 3 | [差旅報銷單](./app_projects/excel3_expense/) | 💼 會計 / 出納 | 一張拆四張 | 自動編號與 `setval`、防重複報帳、審核流程 | 進階-1、進階-2 |
| 4 | [網路商店訂單](./app_projects/excel4_shop/) | 🛒 業務 / 客服 | 多對多 | 明細表、成交單價與目前售價、用交易建立訂單 | 進階-1、進階-3 |
| 5 | [連鎖門市月報](./app_projects/excel5_stores/) | ☕ 店長 / 營運 | 跨月多檔 | CSV 暫存表、每月重複匯入、SQL 版樞紐分析 | 進階-4～9 |

**怎麼進行：** 每個專案的步驟 1～4（看懂 Excel、建表、匯入對帳、用 SQL 完成需求）只需要第 4 章的內容。步驟 5 之後（PRD、todolist、App）建議學完第 5 章再做，並依照 [MCP 設定教學](./MCP操作資料庫/1_antigravity設定.md)連線。

| 工作 | 學員 | AI |
|---|:---:|:---:|
| 寫 user story、驗收條件 | ✅ | 協助檢查 |
| 手寫 DDL、DML | ✅ | 只當助教 |
| 把 Excel 轉成資料交易檔 | 檢查與對帳 | ✅ |
| `PRD.md`、`todolist.md` | 審核與修改 | ✅ 用唯讀 MCP 讀結構 |
| Python 與視窗程式 | 依 `todolist.md` 驗收 | ✅ |

### 🎓 畢業專題：換你的 Excel

做完專案後，拿自己工作上的 Excel 走一次同樣的流程：先脫敏、自己手寫建表，再請 AI 處理資料，最後做成自己的小工具。

👉 **[開始畢業專題](./app_projects/畢業專題_換你的Excel.md)**

### 延伸專題

做完五個專案後，想挑戰功能更完整的版本，可以參考以下專案：

<details>
<summary>展開五個延伸專題</summary>

| 專案目錄 | 對應範例庫 | 本機 GUI 框架 | 職場角色 | 核心手寫 SQL 技術與亮點功能 |
|---|---|:---:|:---:|---|
| **[project1_expense_manager](./app_projects/project1_expense_manager/)** | `expense_tracker.sql` | 🔵 **PyQt5** | 💼 會計 / 出納 | • **報銷案件審批流程**：待審/核准/駁回狀態流動<br>• **手寫 SQL 預算對比**：聚合查詢各部門年度核定預算 vs 累計支出<br>• **超支預警機制**：支出率達 80% 自動變色警示 |
| **[project2_hr_attendance](./app_projects/project2_hr_attendance/)** | `hr_attendance.sql` | 🟢 **Tkinter** | 👥 人資 (HR) | • **排班打卡核對網格**：手寫 SQL `CASE WHEN` 判定遲到/早退<br>• **加班工時試算**：平日與假日加班時數分類加總<br>• **月底計薪結算機**：勞基法費率試算應發薪資總額 |
| **[project3_assets_inventory](./app_projects/project3_assets_inventory/)** | `assets_inventory.sql` | 🔵 **PyQt5** | 🏢 總務 / 倉管 | • **固定資產借還登記**：手寫 SQL 篩選逾期未歸還名冊與天數<br>• **耗材安全庫存預警**：庫存低於預警線自動標記「建議採購」<br>• **部門領用追蹤**：領用即時扣庫存並留存完整歷史紀錄 |
| **[project4_cafe_dashboard](./app_projects/project4_cafe_dashboard/)** | `cafe_shop.sql` | 🔵 **PyQt5** | ☕ 門市店長 | • **跨月營收戰情室**：解決多份 Excel 拼湊痛點，即時跨月切換<br>• **明星熱銷排行**：手寫 SQL `GROUP BY` 與視窗函式計算商品佔比<br>• **員工提成計算**：銷售杯數階梯試算各店員當月提成獎金 |
| **[project5_shop_crm](./app_projects/project5_shop_crm/)** | `shop.sql` | 🟢 **Tkinter** | 🛒 業務 / 電商 | • **主從訂單履約**：點選訂單，下方手寫 SQL JOIN 即時帶出明細品項<br>• **訂單狀態流水線**：未處理 ➡️ 已出貨 ➡️ 已完成流動控管<br>• **RFM 客戶價值模型**：試算消費頻次與貢獻金額，標記 VIP 客戶 |

</details>

---

<div align="center">
<b>為自己的日常工作賦能，從手寫每一句 SQL 開始！</b>
</div>
