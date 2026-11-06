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

## 🤖 運用 AI 助教：建議 DDL 語法 (學生手動執行)

> 💡 **核心教學原則**：  
> 本專案的 MCP Server 採用**安全唯讀保護模式 (`--access-mode=restricted`)**，嚴禁 AI 在背後直接代勞建立或修改資料庫！  
> 正確的學習方式：向 AI 請教建議語法與結構解析，**親自將 SQL 複製到 DBeaver 中手動執行**，看懂每張資料表的定義。

**Prompt 1：請 AI 查看目前資料庫結構**

> 「請透過唯讀 MCP 檢查目前資料庫有哪些資料表，並列出每張資料表的欄位名稱、資料型別與主鍵設定。」

✅ AI 會呼叫唯讀工具列出結構，完全不破壞資料庫。

**Prompt 2：請 AI 解析職場資料表 DDL（以總務資產管理為例）**

> 「請以公司總務的『固定資產 (assets)』資料表為例，寫出標準的 CREATE TABLE、ALTER TABLE 新增欄位、TRUNCATE 清空資料與 DROP TABLE 語法，並詳細說明 DROP 與 TRUNCATE 的核心差異（刪除結構 vs. 只清空內容）。請給我純 SQL 程式碼區塊，我會在 DBeaver 中手動執行。」

✅ 對照「常見DDL指令範例」表格，體會 DDL 對資料表結構的影響。

---

## 🧭 課程導覽

| 🏠 返回目錄 | ➡️ 下一單元 |
|:---:|---:|
| [第 4 章：SQL 語法與實戰練功](../README.md#ddl資料定義語言建立與修改結構) | [單元 1：建立資料庫](./1建立資料庫.md) |

