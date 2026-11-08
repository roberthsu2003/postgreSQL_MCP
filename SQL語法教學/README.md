# 第 4 章：SQL 語法與實戰練功

> 本章是課程的核心。全章跟著「暖光咖啡」總部的王經理，把每天的 Excel 問題變成一句 SQL。每一課都有：**職場情境 → 語法 → 真實執行結果 → 常見卡關 → 附答案的練習 → 問 AI 助教 → 過關檢查**。講義中的 SQL 都實際執行過，結果就是你應該看到的結果。

[← 回課程首頁](../README.md)

## 開始之前

- [ ] 已完成 [第 1 章](../環境安裝/)，DBeaver 連得上資料庫
- [ ] 知道按 `Ctrl/Cmd + Enter` 執行一句，`Alt/Opt + X` 執行全部

## 課程目錄

### 📐 DDL：蓋結構

| # | 單元主題 | 核心內容 | 學完可接實戰專案 |
|:---:|---|---|---|
| 導讀 | [DDL 是什麼](./DDL%28定義資料語言%29.md) | CREATE、ALTER、DROP、TRUNCATE | — |
| 1 | [建立資料庫](./1建立資料庫.md) | `CREATE DATABASE`、切換資料庫、命名規則 | — |
| 2 | [基本型別](./2_0基本型別.md) | 金額為什麼不能用 FLOAT、電話為什麼是文字 | — |
| 3 | [建立資料表](./2建立資料表.md) | `CREATE TABLE`、`ALTER TABLE` | — |
| 4 | [匯入 CSV](./2_1匯入csv.md) | DBeaver 匯入、驗筆數、亂碼處理 | — |
| 5 | [限制條件](./4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE`、`CHECK`、`DEFAULT` | [專案 1](../app_projects/excel1_supplies/) 步驟 1、2 |

### 🔍 DML：操作資料

| # | 單元主題 | 核心內容 | 學完可接實戰專案 |
|:---:|---|---|---|
| 導讀 | [DML 是什麼](./DML%28資料操作語言%29.md) | **匯入 `cafe_shop`**，開工準備 | — |
| 1 | [新增資料](./3新增資料.md) | `INSERT`、`RETURNING`、單引號的坑 | — |
| 2 | [查詢資料](./6取得資料.md) | `SELECT`、`WHERE`、`ORDER BY`、`LIMIT` | — |
| 3 | [修改與刪除](./5修改和刪除.md) | `UPDATE`、`DELETE`、保命三步驟與交易 | [專案 1](../app_projects/excel1_supplies/) 步驟 3、4 |
| 4 | [外來鍵](./7_0FOREIGN_KEY.md) | 父子表、`ON DELETE` 怎麼選 | — |
| 5 | [JOIN](./JOIN.md) | SQL 版的 VLOOKUP：五種 JOIN | [專案 3](../app_projects/excel3_attendance/)（再學完下方的一對多入門） |
| 6 | [JSONB](./16json.md) | 飲料客製化、`->` 和 `->>` | [專案 2](../app_projects/excel2_devices/) |

### 💡 思維躍升：從單一工作表到多張表

> [!NOTE]
> 單一工作表裡，客戶電話一改就要改幾百列，刪掉訂單連客戶資料都不見。拆成多張表，再用主鍵和外來鍵串起來，這些問題就消失了。

- 👉 **[必讀觀念：從 Excel 到關聯式資料庫](../範例資料庫/從Excel到關聯資料庫_正規化.md)**
- 👉 **[快速上手：一對多關聯](./7.0適合初學者關聯資料庫.md)**：學完可接[專案 3](../app_projects/excel3_attendance/)

### 🧩 關聯資料庫進階實戰

| # | 單元主題 | 核心內容 | 練習腳本 | 學完可接實戰專案 |
|:---:|---|---|:---:|---|
| 1 | [建立七張表](./7創建關聯資料庫.md) | 親手蓋出 `cafe_shop`、多對多設計 | — | — |
| 2 | [關聯新增](./8新增關聯資料庫資料.md) | 寫入順序、交易、SERIAL 撞號 | [.sql](./8新增關聯資料庫資料.sql) | [專案 4](../app_projects/excel4_expense/) |
| 3 | [關聯搜尋](./9搜尋關聯資料庫.md) | 拆解問題的三個步驟 | [.sql](./9搜尋關聯資料庫.sql) | [專案 5](../app_projects/excel5_shop/) |
| 4 | [聚合與分組](./10聚合函式.md) | SQL 版樞紐分析表：`GROUP BY`、`HAVING` | [.sql](./10聚合函式.sql) | — |
| 5 | [模糊搜尋](./11萬用字元.md) | `LIKE`、`ILIKE`、`%`、`_` | [.sql](./11萬用字元.sql) | [專案 6](../app_projects/excel6_tickets/) |
| 6 | [聯集](./12聯集.md) | `UNION`、`UNION ALL` | [.sql](./12聯集.sql) | — |
| 7 | [綜合連結](./13連結.md) | 條件放 `ON` 還是 `WHERE` | [.sql](./13連結.sql) | [專案 7](../app_projects/excel7_training/) |
| 8 | [子查詢](./14子查詢.md) | `WITH`、`EXISTS`、`NOT IN` 遇到 NULL 的大坑 | [.sql](./14子查詢.sql) | — |
| 9 | [ON DELETE](./15on_delete_action.md) | 查規則、預測後果、軟刪除 | [.sql](./15on_delete_action.sql) | [專案 8](../app_projects/excel8_stores/) |
| 10 | [索引與效能](./17索引與效能.md) | 用 5 萬筆資料實測 `INDEX`、`EXPLAIN` | [腳本](../範例資料庫/中文範例資料庫/generate_100k_orders.sql) | — |
| 11 | [AI 助教與結業挑戰](./關聯資料庫實作_用Prompt操作.md) | 抓出 AI 的錯、五大職務實戰、結業五題 | — | — |

---

## 怎麼用這份講義

每一課都是同樣的結構，自學時照順序做就好：

| 區塊 | 做什麼 |
|---|---|
| 🎬 **情境** | 先知道這個語法解決什麼工作問題 |
| 📘 **內容** | 把 SQL **親手打進 DBeaver**，對照「執行結果」 |
| ⚠️ **常見卡關** | 報錯時先查這裡 |
| ✍️ **動手練** | 先自己寫，再點開「看答案」 |
| 🤖 **問 AI 助教** | 卡住就問，但由你自己執行 |
| ✅ **過關檢查** | 都打勾了再往下走 |

> [!TIP]
> **講義中的 SQL 和結果都實際執行過。** 你的結果若不同，通常是資料被改過：重新執行範例 `.sql` 檔就會恢復。

## 用到哪些資料庫？

**一個範例放一個資料庫，資料庫名稱和檔名相同。**

| 資料庫 | 怎麼來的 | 用途 |
|---|---|---|
| `cafe_db` | 自己從零建立 | DDL 和 DML 的手寫練習 |
| `cafe_lab` | 自己從零建立 | 進階-1、2 親手蓋七張表 |
| `cafe_perf` | 匯入 `cafe_shop.sql` 後再產生 5 萬筆訂單 | 進階-10 索引練習，不要和 `cafe_shop` 混用 |
| `cafe_shop` | 匯入 [`cafe_shop.sql`](../範例資料庫/中文範例資料庫/cafe_shop.sql) | 主要查詢練習，改壞了重匯即可 |
| `expense_tracker` | 匯入 [`expense_tracker.sql`](../範例資料庫/中文範例資料庫/expense_tracker.sql) | 會計案例 |
| `hr_attendance` | 匯入 [`hr_attendance.sql`](../範例資料庫/中文範例資料庫/hr_attendance.sql) | 人資案例 |
| `assets_inventory` | 匯入 [`assets_inventory.sql`](../範例資料庫/中文範例資料庫/assets_inventory.sql) | 總務案例 |
| `shop` | 匯入 [`shop.sql`](../範例資料庫/中文範例資料庫/shop.sql) | 業務案例 |

## SQL 速查表

**查詢的書寫順序**

```sql
SELECT   欄位, 聚合函式(欄位)
FROM     表 a
JOIN     表 b ON a.鍵 = b.鍵
WHERE    分組前的條件
GROUP BY 欄位
HAVING   分組後的條件
ORDER BY 欄位 DESC
LIMIT    筆數;
```

**常用語法**

| 想做什麼 | 語法 |
|---|---|
| 新增 | `INSERT INTO t (a, b) VALUES (1, 'x') RETURNING id;` |
| 修改 | `UPDATE t SET a = 1 WHERE id = 1;` |
| 刪除 | `DELETE FROM t WHERE id = 1;` |
| 安全修改 | `BEGIN;` → 改 → 檢查 → `COMMIT;` 或 `ROLLBACK;` |
| 找空值 | `WHERE a IS NULL` |
| 模糊搜尋 | `WHERE a LIKE '%拿鐵%'` |
| 空值換預設 | `COALESCE(a, '散客')` |
| 條件判斷 | `CASE WHEN a > 1 THEN 'x' ELSE 'y' END` |
| 條件計數 | `COUNT(*) FILTER (WHERE a > 1)` |
| 不在清單中 | `WHERE NOT EXISTS (SELECT 1 FROM t WHERE ...)` |
| 暫時的表 | `WITH x AS (SELECT ...) SELECT * FROM x;` |

**看到錯誤訊息怎麼辦**

| 訊息關鍵字 | 通常是 |
|---|---|
| `column ... does not exist` | 欄位打錯、文字用了雙引號 |
| `relation ... does not exist` | 表名打錯、連到錯的資料庫 |
| `syntax error at or near` | 那個字的**前面**寫錯了 |
| `violates foreign key` | 父資料不存在，或還有子資料 |
| `violates unique` / `duplicate key` | 資料重複 |
| `must appear in the GROUP BY` | 欄位沒分組也沒聚合 |
| `current transaction is aborted` | 先執行 `ROLLBACK;` |

**還是解不開？** 把 SQL 和完整的錯誤訊息貼給 AI，問它「錯在哪裡，為什麼」。
