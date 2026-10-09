# DDL(定義資料語言)
**建立、修改、刪除資料庫和資料表的SQL指令類別**

在SQL中，針對資料庫與資料表的「建立（Create）」、「修改（Alter）」、「刪除（Drop）」等操作，這些指令都屬於**資料定義語言（DDL, Data Definition Language）**的範疇。

### DDL（資料定義語言）簡介

DDL主要用於**定義與管理資料庫結構**，包括：

- **CREATE**：建立新的資料庫或資料表
- **ALTER**：修改現有的資料表結構
- **DROP**：刪除資料庫或資料表
- **TRUNCATE**：清空資料表內容但保留結構

### 常見DDL指令範例

| 操作   | 指令範例                  | 說明                   |
|--------|---------------------------|------------------------|
| 建立   | CREATE DATABASE / TABLE   | 建立資料庫或資料表     |
| 修改   | ALTER TABLE               | 修改資料表結構         |
| 刪除   | DROP DATABASE / TABLE     | 刪除資料庫或資料表     |

### 補充說明

- DDL指令會直接影響資料庫的結構，與資料內容的增刪改查（如INSERT、UPDATE、DELETE）不同，後者屬於DML（資料操作語言）。
- 在 MySQL、Oracle 等資料庫中，DDL 會自動提交（auto-commit），無法回復。
- **PostgreSQL 不一樣**：DDL 也可以放在交易（`BEGIN` … `ROLLBACK`）中，執行錯了還能回復（`CREATE DATABASE`、`DROP DATABASE` 除外）。


---

## 🤖 不寫 SQL，用 Prompt 完成

> 在 Claude Desktop 使用[第 3 章](../MCP操作資料庫/2_用中文查詢資料庫/#6-準備第-4-章設定可寫入的連線)設定的 **`postgres-sql`**（可寫入，連到 `sql_tutorial` 資料庫）。
> 每個 prompt 執行後，點開工具呼叫（`execute_sql`），**對照 AI 執行的 SQL 和上面學的是否一樣**。

**Prompt 1**

> 用 postgres-sql，列出 sql_tutorial 資料庫有哪些資料表，以及每張資料表的欄位和型別。

✅ 這是在「查看結構」。AI 會用 `list_objects`、`get_object_details` 工具，不需要執行 DDL。

**Prompt 2**

> 用一張 student 資料表當例子，分別寫出 CREATE、ALTER、DROP、TRUNCATE 的 SQL，說明每一個會對資料表做什麼。**先不要執行。**

✅ 對照上面的「常見DDL指令範例」表格。注意 AI 有沒有說明 `DROP` 和 `TRUNCATE` 的差別（刪除整張表 vs. 只清空資料）。

> 💡 要 AI「先不要執行」時，一定要明確說出來，否則 AI 可能直接執行。
