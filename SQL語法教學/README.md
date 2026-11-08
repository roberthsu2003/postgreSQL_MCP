# 第 4 章參考資料：資料庫對照與 SQL 速查

> 課程目錄請看[課程首頁的第 4 章](../README.md#4-sql-語法與實戰練功)。這一頁是上課時查語法和資料庫用的。

[← 回課程首頁](../README.md)

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

## 開始之前

- [ ] 已完成 [第 1 章](../README.md#1-環境安裝)，DBeaver 連得上資料庫
- [ ] 知道按 `Ctrl/Cmd + Enter` 執行一句，`Alt/Opt + X` 執行全部

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

## 👉 開始

[前往第 4 章課程目錄 →](../README.md#4-sql-語法與實戰練功)
