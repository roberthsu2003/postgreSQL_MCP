# PostgreSQL 學習指南

從安裝、SQL 語法、Python 串接，到實戰專案與 AI（MCP）應用的 PostgreSQL 完整課程。

## 學習路線

| 步驟 | 單元 | 你會學到 |
|:---:|---|---|
| 1 | [環境安裝](#1-環境安裝) | 安裝 PostgreSQL Server 與管理工具 |
| 2 | [範例資料庫](#2-範例資料庫) | 匯入練習用的資料 |
| 3 | [SQL 語法](#3-sql-語法) | DDL 建立結構、DML 操作資料、關聯資料庫 |
| 4 | [SQL 練習](#4-sql-練習) | 用範例資料庫動手寫查詢 |
| 5 | [Python 串接](#5-python-串接psycopg2) | 用 psycopg2 從 Python 存取資料庫 |
| 6 | [實戰專案](#6-實戰專案) | CLI 與 Streamlit 資料應用 |
| 7 | [AI 查詢資料庫](#7-ai-查詢資料庫mcp) | 讓 Claude 透過 MCP 查詢、分析資料庫 |

📖 [參考文件](#參考文件)

---

## 1. 環境安裝

### PostgreSQL Server

| 安裝方式 | 說明 |
|---|---|
| **Docker**（推薦） | 一行指令完成，見下方 |
| Linux / Raspberry Pi | [安裝教學](./server安裝/) |
| 其它作業系統 | [PostgreSQL 官網下載](https://www.postgresql.org/download/) |

```bash
docker run --name my-postgres -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres
```

| 參數 | 說明 |
|---|---|
| `--name my-postgres` | 容器名稱 |
| `-e POSTGRES_PASSWORD=yourpassword` | 設定預設帳號 `postgres` 的密碼 |
| `-p 5432:5432` | 將容器的 5432 埠對應到本機 5432 埠 |
| `-d postgres` | 在背景執行，使用官方 postgres 映像檔 |

> [!NOTE]
> 目前只測試過本機連線，從其它電腦連線的設定尚未測試成功。

### 管理工具

| 工具 | 說明 |
|---|---|
| [pgAdmin](https://www.pgadmin.org) | PostgreSQL 官方管理工具 |
| [DBeaver](https://dbeaver.io/) | 通用資料庫管理工具，支援多種資料庫 |

<details>
<summary>DBeaver 連線設定（JDBC）</summary>

```
URL      : jdbc:postgresql://主機網址/資料庫名稱
Username : 使用者名稱
Password : 使用者密碼
```

</details>

---

## 2. 範例資料庫

📁 [範例資料庫總覽](./範例資料庫/)

| 範例 | 大小 | 說明 |
|---|---|---|
| ⭐ [繁體中文範例資料庫](./範例資料庫/中文範例資料庫/) | 50–90 KB | 網路商店、學校選課、圖書館借閱；各一個 `.sql` 檔，執行就能匯入，附 ER 圖與練習題。**初學者首選** |
| [台鐵車站進出站人數](./範例資料庫/#2-台鐵車站進出站人數) | 9.4 MB | 真實公開資料，約 40 萬筆 |
| [其它範例 CSV 檔](./範例資料庫/#3-其它範例-csv-檔) | 4 KB–35 MB | 練習建立資料表與匯入 CSV |

---

## 3. SQL 語法

### DDL：資料定義語言

建立、修改資料庫與資料表的**結構**。 👉 [DDL 概念](./上課用sql/DDL%28定義資料語言%29.md)

| # | 單元 | 內容 |
|:---:|---|---|
| 1 | [建立資料庫](./上課用sql/1建立資料庫.md) | `CREATE DATABASE` |
| 2 | [資料表與基本型別](./上課用sql/2_0基本型別.md) | 數值、文字、日期等資料型別 |
| 3 | [建立資料表](./上課用sql/2建立資料表.md) | `CREATE TABLE` |
| 4 | [匯入 CSV](./上課用sql/2_1匯入csv.md) | 將 CSV 匯入資料表，包含台鐵進出站關聯資料庫 |
| 5 | [限制](./上課用sql/4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE` |

### DML：資料操作語言

新增、查詢、修改、刪除資料表裡的**資料**。 👉 [DML 概念](./上課用sql/DML%28資料操作語言%29.md)

| # | 單元 | 內容 |
|:---:|---|---|
| 1 | [新增資料](./上課用sql/3新增資料.md) | `INSERT INTO` |
| 2 | [取得資料](./上課用sql/6取得資料.md) | `SELECT`、`WHERE`、`ORDER BY` |
| 3 | [修改和刪除](./上課用sql/5修改和刪除.md) | `UPDATE`、`DELETE` |
| 4 | [FOREIGN KEY](./上課用sql/7_0FOREIGN_KEY.md) | 外來鍵與資料表關聯 |
| 5 | [JOIN](./上課用sql/JOIN.md) | 合併多張資料表 |
| 6 | [JSON 應用](./上課用sql/16json.md) | `JSON` / `JSONB` 欄位 |

### 關聯資料庫實作案例

從零建立一個關聯資料庫，並練習各種查詢。建議先看[適合初學者的版本](./上課用sql/7.0適合初學者關聯資料庫.md)。

| # | 單元 | # | 單元 |
|:---:|---|:---:|---|
| 1 | [創建關聯資料庫](./上課用sql/7創建關聯資料庫.md) | 6 | [聯集 UNION](./上課用sql/12聯集.sql) |
| 2 | [新增資料](./上課用sql/8新增關聯資料庫資料.sql) | 7 | [連結 JOIN](./上課用sql/13連結.sql) |
| 3 | [搜尋資料](./上課用sql/9搜尋關聯資料庫.sql) | 8 | [子查詢 SubQuery](./上課用sql/14子查詢.sql) |
| 4 | [聚合函式](./上課用sql/10聚合函式.sql) | 9 | [ON DELETE 動作](./上課用sql/15on_delete_action.sql) |
| 5 | [萬用字元](./上課用sql/11萬用字元.sql) | | |

---

## 4. SQL 練習

| 練習 | 使用資料 | 主題 |
|---|---|---|
| ⭐ [中文範例資料庫練習題](./範例資料庫/中文範例資料庫/) | 網路商店、學校選課、圖書館借閱 | SELECT、JOIN、GROUP BY、HAVING、子查詢、日期計算（附參考答案） |
| [CREATE TABLE](./練習/1CREATE_TABLE) | 自行建立資料表 | 建立資料表、匯入 CSV |
| [INSERT INTO](./練習/5INSERT_INTO) | 自行建立資料表 | 新增資料、`ON CONFLICT` |
| [FOREIGN KEY](./練習/7Foreign_key) | 台鐵進出站 | 外來鍵 |
| [JOIN](./練習/8JOIN) | 台鐵進出站 | 合併查詢 |
| [GROUP BY、HAVING](./練習/9HAVING) | 台鐵進出站 | 分組統計 |
| [SubQuery](./練習/10subQuery) | 台鐵進出站 | 子查詢 |

---

## 5. Python 串接（psycopg2）

| # | 單元 | 內容 |
|:---:|---|---|
| 1 | [安裝和介紹](./python/安裝和介紹) | 安裝 psycopg2 |
| 2 | [基本語法](./python/basic_module_usage) | 連線、執行 SQL、取得結果 |
| 3 | [使用 with](./python/with) | 自動管理連線與交易 |
| 4 | [傳遞參數](./python/parameter) | 安全地把資料傳進 SQL，避免 SQL Injection |
| 5 | [型別對應](./python/type) | SQL 型別與 Python 型別的對應 |
| 6 | [例外處理](./python/exception) | psycopg2 的 Exceptions |

---

## 6. 實戰專案

| 專案 | 介面 | 說明 |
|---|---|---|
| [引導式 CLI 專案](./tutorial_container/範例/3引導式的CLI專案) | CLI | 函式框架先行的學習方式 |
| [台鐵車站進出站](./tutorial_container/範例/4台鐵車站進出站範例) | CLI | 查詢台鐵車站進出站人數 |
| [大盤股市](./tutorial_container/範例/1stock_market) | Streamlit | 下載股市資料、存入資料庫並視覺化 |
| [台北市 YouBike](./tutorial_container/範例/2taipei_youbike) | Streamlit | 下載 YouBike 站點資料、存入資料庫並視覺化 |

---

## 7. AI 查詢資料庫（MCP）

讓 AI 助理（Claude Desktop）透過 MCP 直接查詢、分析 PostgreSQL 資料庫。 👉 [MCP 概念介紹](./mcp_server/)

| # | 單元 | 內容 |
|:---:|---|---|
| 1 | [使用 Postgres MCP Pro](./mcp_server/1_postgres_mcp_pro/) | 安裝現成的 MCP Server，用自然語言查詢資料庫 |
| 2 | [自己建立 MCP Server](./mcp_server/2_自建MCP_server/) | 用 Python + psycopg2 寫一個自己的 MCP Server |

---

## 參考文件

- [PostgreSQL 官方文件](https://www.postgresql.org/docs/current/)
- [PostgreSQL Tutorial](https://neon.com/postgresql/tutorial)
- [psycopg2 官方文件](https://www.psycopg.org/docs/)
