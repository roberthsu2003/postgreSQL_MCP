# 🐘 PostgreSQL 職場實戰學習指南

<div align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white)
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
> 1. **AI 是助教，手寫才是真功夫**：所有 Prompt **嚴禁**讓 MCP 在背景自動建立或修改資料庫！AI 的任務是提供結構建議與 SQL 程式碼區塊，學員必須親自在 **DBeaver** 中檢視並手動執行。
> 2. **拒絕線上架站繁瑣，聚焦個人本機桌面軟體**：捨棄需要伺服器與雲端維運的 Web / Streamlit 線上版，專注使用 **PyQt5**（高質感商業管理視窗）與 **Tkinter**（Python 內建、免繁複環境安裝），開發在自己電腦上即開即用的個人管理小工具。
> 3. **Python 程式中全數手寫 SQL**：在桌面 App 的按鈕與表格背後，使用 `psycopg2` 撰寫原生 SQL 語法（`cursor.execute("SELECT ...")`），體會 SQL 如何靈活驅動桌面視窗畫面。

---

## 🗺️ 學習四階段路線

![學習四階段路線](./mcp_server/images/learning_roadmap.svg)

| 階段 | 章節模組 | 你會學到與產出 | 使用工具與環境 |
|:---:|---|---|---|
| **一** | **[1. 環境安裝](#1-環境安裝)**<br>**[2. 範例資料庫](#2-範例資料庫)**<br>**[3. 自然語言查庫初體驗](#3-自然語言查庫初體驗免寫-sql)** | • 安裝 PostgreSQL（樹莓派 Docker / Supabase）與 DBeaver<br>• 匯入 5 大職場範例庫（報銷、差勤、資產、門市、CRM）<br>• 體驗自備 Excel 轉 SQL 交易檔流程與中文自然語言查庫 | Docker / Supabase / DBeaver / Antigravity |
| **二** | **[4. SQL 語法與實戰練功](#4-sql-語法與實戰練功)** | • **講義與實戰題合一**：完整 DDL、DML、JOIN、JSONB<br>• 告別圖片死圖：全數採用 Mermaid 視覺化流程圖與關聯架構<br>• 每課附 AI Prompt 建議語法，學生手動複製至 DBeaver 執行 | DBeaver + Antigravity 對話 |
| **三** | **[5. Python 串接](#5-python-串接psycopg2)**<br>**[6. 讓 AI 查詢自己的資料庫](#6-讓自己的-ai-可以查詢自己的資料庫自訂-mcp-server)** | • 使用 `psycopg2` 進行參數化查詢（`%s` 防注入）與交易管理<br>• **讓 AI 查詢自己的資料庫**：用 FastMCP 寫幾行 Python，AI 就能用中文查庫<br>• 從個人本機查庫，進階到企業 Token 門禁與樹莓派 Docker 容器部署 | Python (`psycopg2`) + FastMCP + Docker |
| **四** | **[7. 職場桌面 App 實戰開發](#7-實戰專案規格驅動開發-sdd打造-5-大職場個人桌面-app)** | • **全課程壓軸大專題**：規格驅動開發 (SDD)，手寫 SQL 貫穿<br>• 結合 **PyQt5** 與 **Tkinter** 打造 5 款職場個人獨立桌面視窗<br>• 會計報銷、人資排班、總務資產、門市營運、業務 CRM | PyQt5 / Tkinter |

---

## 1. 環境安裝

本課程採用**容器化標準（Docker）**或**雲端免安裝託管**，免除繁瑣的原生環境設定。資料庫管理一律使用開源直覺的 **DBeaver** 圖形客戶端：

| 環境 / 安裝方式 | 包含內容 | 推薦對象 | 教學連結 |
|---|---|:---:|:---:|
| 🍓 **Raspberry Pi（Docker 容器推薦）** | 樹莓派 Docker 安裝、PostgreSQL 容器化運行、DBeaver SSH 隧道、專案 MCP 雙容器整合 | 想在家中打造專屬常駐資料庫伺服器者 | [查看教學](./raspberry_docker安裝/) |
| ☁️ **Supabase（免費雲端託管）** | 免硬體！申請免費雲端託管 PostgreSQL、取得連線字串、DBeaver 直連設定 | 零硬體負擔、想隨開即用立即開始者 | [查看教學](./supabase安裝/) |

> 💡 **連線字串格式範例**：`postgresql://使用者名稱:密碼@主機IP:5432/資料庫名稱`

---

## 2. 範例資料庫

資料庫不能紙上談兵！我們針對上班族最常見的 5 大部門職能（會計、人資、總務、店長、業務），設計了最貼合工作實務的範例庫與轉換指南：  
👉 **[進入：範例資料庫與 App 產品規劃專區](./範例資料庫/)**

```mermaid
flowchart LR
    A["1. 混亂上班 Excel<br>(單一工作表/公式雜亂)"] --> B["2. 提問 AI (Prompt)<br>產生 3NF 關聯式 SQL 交易腳本"]
    B --> C["3. 學生手動在 DBeaver 執行<br>確認 BEGIN...COMMIT 交易安全"]
    C --> D["4. 練習手寫 SQL<br>SELECT / JOIN / GROUP BY"]
    D --> E["5. 打造個人本機桌面 App<br>PyQt5 / Tkinter 專屬視窗"]
```

### 🏢 五大職場核心職能範例庫對照

| 適用職務 | 範例資料庫腳本 | 解決之職場 Excel 痛點 | 最終打造的個人桌面 App | 視窗技術 |
|---|---|---|---|:---:|
| 💼 **會計 / 出納** | [`expense_tracker.sql`](./範例資料庫/中文範例資料庫/expense_tracker.sql) | 差旅請款單滿天飛、重複報帳、部門預算超支無即時預警 | **[費用報銷審核與預算預警系統](./app_projects/project1_expense_manager/)** | 🔵 **PyQt5** |
| 👥 **人資 (HR)** | [`hr_attendance.sql`](./範例資料庫/中文範例資料庫/hr_attendance.sql) | 手動排班撞期、打卡時數加總繁瑣、加班費與計薪算到眼花 | **[排班出勤與加班計薪小工具](./app_projects/project2_hr_attendance/)** | 🟢 **Tkinter** |
| 🏢 **總務 / 倉管** | [`assets_inventory.sql`](./範例資料庫/中文範例資料庫/assets_inventory.sql) | 筆電投影機借出找不到人、耗材臨時斷貨缺安全庫存提醒 | **[固定資產借還與耗材管理系統](./app_projects/project3_assets_inventory/)** | 🔵 **PyQt5** |
| ☕ **店長 / 營運** | [`cafe_shop.sql`](./範例資料庫/中文範例資料庫/cafe_shop.sql) | 每月複製一份 Excel 難以跨月對比、明星商品與常客排行 | **[門市營運分析與員工提成看板](./app_projects/project4_cafe_dashboard/)** | 🔵 **PyQt5** |
| 🛒 **業務 / 電商** | [`shop.sql`](./範例資料庫/中文範例資料庫/shop.sql) | 客戶資料與訂單塞在同張表、訂單履約追蹤、RFM 客戶分群 | **[客戶 CRM 與訂單履約系統](./app_projects/project5_shop_crm/)** | 🟢 **Tkinter** |

* 🌟 **[自備 Excel 轉 SQL 實戰示範](./範例資料庫/excel範例/自備Excel轉SQL實戰示範/)**：附完整「員工差旅與費用報銷單.xlsx」，示範如何請 AI 產出具備 `BEGIN...COMMIT` 的 SQL 交易腳本，並手動在 DBeaver 成功匯入。
* 🚀 **[巨量資料產生器](./範例資料庫/中文範例資料庫/generate_100k_orders.sql)**：免下載任何巨大檔案！PostgreSQL 內建指令 1 秒動態生成 10 萬筆訂單資料，專門用於索引（INDEX）與查詢效能壓測。

---

## 3. 自然語言查庫初體驗（免寫 SQL）

在深入學習 SQL 語法之前，先體驗 AI 賦能的震撼力！  
在 Antigravity 中掛載本專案提供的專案級 MCP（具備唯讀保護 `--access-mode=restricted`），只要在對話框中**用中文問問題，AI 就會自動查詢資料庫並整理成清楚表格回答你**：

* 👉 **[前往實戰：用中文查詢資料庫（以電商 shop 為例）](./MCP操作資料庫/2_用中文查詢資料庫/)**：體驗 AI 自動判斷表格關聯並撈取資料的便利。

---

## 4. SQL 語法與實戰練功

本目錄所有單元均為**「觀念講義、Mermaid 結構圖與實戰練習合一」**：全數移除傳統圖片死圖，改用清晰的 Mermaid 視覺圖表；每一單元均附有標準 SQL 語法、AI Prompt 提示範例，以及單元練習題，讓學員看著講義就能一步步在 DBeaver 中親自動手練功！

### 📐 DDL：資料定義語言（建立與修改結構）

| # | 單元主題 | 核心內容與語法重點 | 視覺圖表 |
|:---:|---|---|:---:|
| 導讀 | [DDL 概念簡介](./SQL語法教學/DDL%28定義資料語言%29.md) | 什麼是資料定義語言？CREATE、ALTER、DROP 概念總覽 | - |
| 1 | [建立資料庫](./SQL語法教學/1建立資料庫.md) | `CREATE DATABASE`、`DROP DATABASE`、字元編碼 UTF8 | 流程圖 |
| 2 | [基本型別速查](./SQL語法教學/2_0基本型別.md) | 整數、數值 NUMERIC、文字 VARCHAR/TEXT、日期時間 TIMESTAMP | 心智圖 |
| 3 | [建立資料表](./SQL語法教學/2建立資料表.md) | `CREATE TABLE`、欄位結構宣告、`ALTER TABLE` 新增修改欄位 | 類別圖 |
| 4 | [匯入 CSV 資料](./SQL語法教學/2_1匯入csv.md) | DBeaver 圖形化匯入 CSV 與 psql `\copy` 指令速查 | 步驟圖 |
| 5 | [資料表限制條件](./SQL語法教學/4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE`、`DEFAULT`、`CHECK` | 流程決策圖 |

### 🔍 DML：資料操作語言（資料的新增、查詢、異動）

| # | 單元主題 | 核心內容與語法重點 | 實戰練習庫 |
|:---:|---|---|:---:|
| 導讀 | [DML 概念簡介](./SQL語法教學/DML%28資料操作語言%29.md) | INSERT、SELECT、UPDATE、DELETE 四大核心操作 | 觀念架構 |
| 1 | [新增資料](./SQL語法教學/3新增資料.md) | `INSERT INTO ... VALUES` 單筆與批次新增、預設值寫入 | 門市與商品表 |
| 2 | [取得資料與篩選](./SQL語法教學/6取得資料.md) | `SELECT`、`WHERE` 條件、`ORDER BY` 排序、`LIMIT / OFFSET` | 訂單與客戶表 |
| 3 | [修改和刪除](./SQL語法教學/5修改和刪除.md) | `UPDATE ... SET`、`DELETE FROM`、**務必搭配 WHERE 防呆原則** | 庫存與狀態更動 |
| 4 | [外來鍵 FOREIGN KEY](./SQL語法教學/7_0FOREIGN_KEY.md) | 什麼是外來鍵？父子表約束與參照完整性概念解析 | 實體關聯圖 |
| 5 | [多表連結 JOIN](./SQL語法教學/JOIN.md) | INNER JOIN、LEFT JOIN、RIGHT JOIN、FULL JOIN、CROSS JOIN（Mermaid 圖解） | 跨表整合查詢 |
| 6 | [JSON 與 JSONB 應用](./SQL語法教學/16json.md) | 半結構化資料儲存、`->` 與 `->>` 運算子、飲品客製化配方實作 | 咖啡飲品客製庫存 |

---

### 💡 核心思維躍升：從「單一工作表」到「關聯式資料庫（正規化）」

> [!NOTE]
> * **單表操作（上述 DDL/DML）**：相當於在 Excel 裡將所有資料硬塞在**同一個工作表（Sheet）**，極易發生「改了客戶電話要修改幾百列、刪除訂單連客戶資料一起不見」的慘劇。
> * **關聯式多表（下方實戰）**：相當於 Excel 裡拆成多個乾淨工作表並透過 `VLOOKUP` / `XLOOKUP` 串連，在 SQL 裡即是以主鍵（Primary Key）與外來鍵（Foreign Key）構成的強大結構！

👉 **[必讀觀念：從 Excel 到關聯式資料庫（正規化思維）](./範例資料庫/從Excel到關聯資料庫_正規化.md)**  
👉 **[快速上手：適合初學者的關聯資料庫入門](./SQL語法教學/7.0適合初學者關聯資料庫.md)**

### 🧩 關聯資料庫進階實戰

| # | 單元主題 | 核心語法與技術重點 | 參考連結 |
|:---:|---|---|:---:|
| 1 | 創建關聯資料庫 | 7 張資料表完整 DDL、多對多關係設計與外來鍵關聯 | [7創建關聯資料庫.md](./SQL語法教學/7創建關聯資料庫.md) |
| 2 | 關聯新增資料 | 依父子表順序安全寫入資料，維護外來鍵約束 | [8新增關聯資料庫資料.sql](./SQL語法教學/8新增關聯資料庫資料.sql) |
| 3 | 關聯搜尋實戰 | 多表 INNER / LEFT JOIN 查詢出完整商業明細 | [9搜尋關聯資料庫.sql](./SQL語法教學/9搜尋關聯資料庫.sql) |
| 4 | 聚合函式與群組 | `COUNT`、`SUM`、`AVG`、`GROUP BY` 與 `HAVING` 過濾 | [10聚合函式.sql](./SQL語法教學/10聚合函式.sql) |
| 5 | 萬用字元與模糊搜尋 | `LIKE`、`ILIKE`（不分大小寫）、`%` 與 `_` 匹配 | [11萬用字元.sql](./SQL語法教學/11萬用字元.sql) |
| 6 | 聯集操作 | `UNION` 與 `UNION ALL` 合併多組查詢結果集 | [12聯集.sql](./SQL語法教學/12聯集.sql) |
| 7 | 綜合連結演練 | 複雜商業情境下的跨表多重 JOIN 練習題 | [13連結.sql](./SQL語法教學/13連結.sql) |
| 8 | 子查詢 SubQuery | WHERE 子查詢、FROM 衍生資料表與關聯子查詢 | [14子查詢.sql](./SQL語法教學/14子查詢.sql) |
| 9 | 串聯刪除約束 | `ON DELETE CASCADE`、`SET NULL`、`RESTRICT` | [15on_delete_action.sql](./SQL語法教學/15on_delete_action.sql) |
| 10 | AI 助教操作示範 | 示範如何向 AI 提問以獲得建議 SQL 並手動驗證 | [關聯資料庫實作_用Prompt操作.md](./SQL語法教學/關聯資料庫實作_用Prompt操作.md) |

---

## 5. Python 串接（psycopg2）

學會 SQL 語法後，我們使用 Python 官方標準驅動套件 `psycopg2` 進行連線。本章節著重於**程式架構安全與交易完整性**，引導學員建立穩健的資料庫應用習慣：  
👉 **[進入：Python 連線教學與實戰語法](./python/)**

```python
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# 使用 with 語法自動管理連線與交易（安全防呆、自動 commit / rollback）
with psycopg2.connect(os.getenv("DATABASE_URL")) as conn:
    with conn.cursor() as cur:
        # 嚴禁字串拼接！一律採用 %s 參數化查詢防止 SQL Injection
        sql = "SELECT order_id, order_date, total_amount FROM orders WHERE member_id = %s;"
        cur.execute(sql, (101,))
        rows = cur.fetchall()
        for row in rows:
            print(row)
```

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

本章採用大白話教學與循序漸進架構：**「從個人本機專屬助理 $\rightarrow$ 升級到具備 Token 門禁的企業級安全服務與樹莓派 Docker 雙容器常駐」**。 👉 **[章節總覽與完整指引](./mcp_server/)**

```mermaid
flowchart TD
    subgraph 個人本機篇
        M1["1. 唯讀 AI 查庫工具<br>(FastMCP 本機中文查詢)"] --> M2["2. 安全交易寫入<br>(封裝商業檢查與交易保護)"]
    end
    subgraph 企業與伺服器篇
        M2 --> M3["3. 遠端 HTTP 與 Token 門禁<br>(Bearer Token 安全驗證與稽核日誌)"]
        M3 --> M4["4. 樹莓派 Docker 雙容器<br>(PostgreSQL + MCP Server 內網直連常駐)"]
    end
    M4 --> M5["5. 企業多部門實戰範例集<br>(門市營運、電商客服、金融大盤等)"]
```

| 階段 | 單元模組 | 你的角色 | 學習重點與實作內容 |
|:---:|---|:---:|---|
| **個人篇** | **[1. 用 AI 建立自己的 MCP Server（唯讀）](./mcp_server/1_用AI建立MCP_server/)** | 需求設計與開發者 | • 在本機規劃資料查詢工具，使用 FastMCP 撰寫 Python 邏輯<br>• 透過 MCP Inspector 進行本機視覺化除錯，掛載到 Antigravity 中文查庫 |
| **個人篇** | **[2. 會寫入資料的 MCP Server（安全交易）](./mcp_server/2_寫入型MCP_server/)** | 架構設計與驗收者 | • 圖書館借還書情境：嚴格限制寫入介面，商業檢核寫在程式中<br>• 確保資料庫交易（Transaction `BEGIN...COMMIT`）具備原子性 |
| **企業篇** | **[3. 企業導入：遠端 MCP 與 Token 門禁](./mcp_server/3_企業導入_遠端MCP與token/)** | 系統導入工程師 | • 升級為 Streamable HTTP 遠端微服務架構<br>• 導入 Bearer Token 門禁驗證機制，即時記錄每次呼叫的審計日誌 |
| **企業篇** | **[4. 正式上線：部署至樹莓派 Docker 雙容器](./mcp_server/4_樹莓派Docker容器部署/)** | 系統架構師 | • 撰寫 `Dockerfile` 與 `docker-compose.yml`<br>• 將 MCP 與 PostgreSQL 一同打包至樹莓派內網，免開外部 Port 兼顧極速與安全 |
| **綜合篇** | **[5. 企業各部門範例集](./mcp_server/5_範例集/)** | 參考與最佳實踐 | • 提供電商客服、門市營運、金融大盤等完整範例程式碼（本機/遠端雙模） |

---

## 7. 實戰專案：規格驅動開發 SDD（打造 5 大職場個人桌面 App）

當我們掌握了手寫 SQL 語法、Python 驅動程式，並且擁有專屬的 AI 查庫助理後，我們邁向全課程的**壓軸實戰專案**！

我們採用現代軟體工程的 **規格驅動開發 (SDD, Spec-Driven Development)**：透過 `PRD.md` 規範商業功能，由 AI 閱讀資料庫結構並引導架構，學員在自己電腦上以純本機視窗（**PyQt5** 與 **Tkinter**）親手手寫 SQL，開發出完全屬於自己的 5 大職場桌面管理工具！

**本目錄 5 大實戰專案，100% 完整對應五大職場範例資料庫！** 👉 **[專案總覽專區](./app_projects/)**

| 專案目錄 | 對應範例庫 | 本機 GUI 框架 | 職場角色 | 核心手寫 SQL 技術與亮點功能 |
|---|---|:---:|:---:|---|
| **[project1_expense_manager](./app_projects/project1_expense_manager/)** | `expense_tracker.sql` | 🔵 **PyQt5** | 💼 會計 / 出納 | • **報銷案件審批流程**：待審/核准/駁回狀態流動<br>• **手寫 SQL 預算對比**：聚合查詢各部門年度核定預算 vs 累計支出<br>• **超支預警機制**：支出率達 80% 自動變色警示 |
| **[project2_hr_attendance](./app_projects/project2_hr_attendance/)** | `hr_attendance.sql` | 🟢 **Tkinter** | 👥 人資 (HR) | • **排班打卡核對網格**：手寫 SQL `CASE WHEN` 判定遲到/早退<br>• **加班工時試算**：平日與假日加班時數分類加總<br>• **月底計薪結算機**：勞基法費率試算應發薪資總額 |
| **[project3_assets_inventory](./app_projects/project3_assets_inventory/)** | `assets_inventory.sql` | 🔵 **PyQt5** | 🏢 總務 / 倉管 | • **固定資產借還登記**：手寫 SQL 篩選逾期未歸還名冊與天數<br>• **耗材安全庫存預警**：庫存低於預警線自動標記「建議採購」<br>• **部門領用追蹤**：領用即時扣庫存並留存完整歷史紀錄 |
| **[project4_cafe_dashboard](./app_projects/project4_cafe_dashboard/)** | `cafe_shop.sql` | 🔵 **PyQt5** | ☕ 門市店長 | • **跨月營收戰情室**：解決多份 Excel 拼湊痛點，即時跨月切換<br>• **明星熱銷排行**：手寫 SQL `GROUP BY` 與視窗函式計算商品佔比<br>• **員工提成計算**：銷售杯數階梯試算各店員當月提成獎金 |
| **[project5_shop_crm](./app_projects/project5_shop_crm/)** | `shop.sql` | 🟢 **Tkinter** | 🛒 業務 / 電商 | • **主從訂單履約**：點選訂單，下方手寫 SQL JOIN 即時帶出明細品項<br>• **訂單狀態流水線**：未處理 ➡️ 已出貨 ➡️ 已完成流動控管<br>• **RFM 客戶價值模型**：試算消費頻次與貢獻金額，標記 VIP 客戶 |

---

## 📚 推薦學習資源與官方文件

- [PostgreSQL 官方文件 (v16)](https://www.postgresql.org/docs/current/)
- [PostgreSQL Tutorial (Neon)](https://neon.com/postgresql/tutorial)
- [psycopg2 官方文件](https://www.psycopg.org/docs/)
- [PyQt5 官方參考手冊 (Riverbank)](https://www.riverbankcomputing.com/static/Docs/PyQt5/)
- [Python 官方 Tkinter 模組指引](https://docs.python.org/3/library/tkinter.html)
- [Model Context Protocol 官方規範](https://modelcontextprotocol.io/)

---

<div align="center">
<b>為自己的日常工作賦能，從手寫每一句 SQL 開始！</b>
</div>
