# 步驟 4｜DML 回答故事：一則需求，一句 SQL

> 💻 DBeaver（資料庫：`supplies`）｜ 🎯 學完你會：用 `SELECT`、`UPDATE`、`INSERT`、`DELETE` 完成小林的五個需求

> 📚 先修：[DML 章節](../../SQL語法教學/DML%28資料操作語言%29.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

資料已經進來了。回到 Excel 的「需求」工作表，一則一則完成。**DML** 就是用來操作資料的語法。

在 DBeaver 開一個新的 SQL 分頁，存成 `我的查詢.sql`。每完成一則故事，就把 SQL 留在裡面，之後做 App 會直接用到。

> [!TIP]
> 請照順序做。S3、S4 會改變資料，後面的練習答案是以做完這些步驟的資料為準。

## S1｜哪些耗材該補貨

```sql
SELECT item_code AS 品號,
       name AS 品名,
       current_stock AS 現有庫存,
       safety_stock AS 安全庫存,
       safety_stock - current_stock AS 缺口
FROM supplies
WHERE current_stock <= safety_stock
ORDER BY 缺口 DESC, item_code;
```

| SQL | 對應 Excel 的動作 |
|---|---|
| `SELECT` 欄位 | 只顯示某幾欄 |
| `AS 品號` | 改標題 |
| `safety_stock - current_stock` | 公式欄 |
| `WHERE` | 篩選 |
| `ORDER BY ... DESC` | 由大到小排序 |

**執行結果**

| 品號 | 品名 | 現有庫存 | 安全庫存 | 缺口 |
|---|---|---:|---:|---:|
| STA-NOTE-76 | 便利貼 | 15 | 20 | 5 |
| STA-PEN-K05 | 黑色原子筆 | 45 | 50 | 5 |
| CLN-BAG-L | 垃圾袋 大 | 3 | 6 | 3 |
| MAT-P-A470 | A4 70g 影印紙 | 3 | 5 | 2 |
| STA-MRK-RD | 白板筆 紅色 | 8 | 10 | 2 |
| MAT-T-HP05 | HP 黑色碳粉匣 | 1 | 2 | 1 |
| MAT-T-HP11Y | HP 黃色碳粉匣 | 0 | 1 | 1 |
| CLN-WIPE-80 | 濕紙巾 | 6 | 6 | 0 |
| MAT-P-PHOTO | A4 相片紙 | 2 | 2 | 0 |

## S2｜東西放在哪裡

```sql
SELECT name AS 品名, current_stock AS 現有庫存, location AS 存放位置
FROM supplies
WHERE name LIKE '%碳粉%'
ORDER BY item_code;
```

`%` 代表「前後可以有任何文字」，類似 Excel 篩選的「包含」。

**執行結果**

| 品名 | 現有庫存 | 存放位置 |
|---|---:|---|
| HP 黑色碳粉匣 | 1 | 3F 總務庫房 C-03 |
| HP 青色碳粉匣 | 4 | 3F 總務庫房 C-03 |
| HP 洋紅色碳粉匣 | 2 | 3F 總務庫房 C-03 |
| HP 黃色碳粉匣 | 0 | 3F 總務庫房 C-03 |

## S5｜庫存總金額

```sql
SELECT SUM(unit_price * current_stock) AS 庫存總金額
FROM supplies;
```

**執行結果**：`66474`，和 Excel 對帳的數字相同。

## S3｜登記領用，自動扣庫存

修改資料前，先記住**保命三步驟：開始交易、修改並檢查、確認沒問題才送出**。

同事領了 2 支黑色原子筆：

```sql
BEGIN;

UPDATE supplies
SET current_stock = current_stock - 2
WHERE item_code = 'STA-PEN-K05'
RETURNING item_code, name, current_stock;
```

**執行結果**

| item_code | name | current_stock |
|---|---|---:|
| STA-PEN-K05 | 黑色原子筆 | 43 |

`RETURNING` 會讓你看到改完的結果。45 減 2 是 43，數字正確，就送出：

```sql
COMMIT;
```

如果發現改錯了，改執行 `ROLLBACK;`，資料就會回到修改之前。

> [!WARNING]
> `UPDATE` 忘了寫 `WHERE`，**整張表**的庫存都會被扣。Excel 有 `Ctrl + Z`，資料庫沒有，所以才要用交易保護。

現在試試超領。黑色碳粉匣只剩 1 支，有人要領 5 支：

```sql
UPDATE supplies
SET current_stock = current_stock - 5
WHERE item_code = 'MAT-T-HP05';
```

**執行結果**：`new row for relation "supplies" violates check constraint "supplies_current_stock_check"`

你在步驟 2 寫的 `CHECK` 擋下了這次超領，庫存仍然是 1。這就是 S3 的驗收條件。

## S4｜新增耗材，登錯可以刪除

新進一批口紅膠，規格和盤點日先留空：

```sql
INSERT INTO supplies (item_code, name, category, unit, unit_price, current_stock, safety_stock, location)
VALUES ('STA-GLUE-01', '口紅膠', '文具', '支', 30, 10, 5, '3F 總務庫房 D-02')
RETURNING item_code, name, spec, last_checked;
```

**執行結果**

| item_code | name | spec | last_checked |
|---|---|---|---|
| STA-GLUE-01 | 口紅膠 | NULL | NULL |

沒列出的欄位會是預設值，沒有預設值就是 `NULL`（DBeaver 可能顯示 `[NULL]`）。再執行一次同一句，會得到 `duplicate key value violates unique constraint`，表示品號重複時不能新增。

後來發現這筆登錯了，要刪掉。**刪除前先用同樣的條件查一次**：

```sql
BEGIN;

SELECT item_code, name FROM supplies WHERE item_code = 'STA-GLUE-01';  -- 確認只有這一筆

DELETE FROM supplies WHERE item_code = 'STA-GLUE-01' RETURNING item_code, name;

SELECT COUNT(*) AS 品項數 FROM supplies;  -- 應該回到 25

COMMIT;
```

**執行結果**：`SELECT` 和 `DELETE` 都只有 `STA-GLUE-01 | 口紅膠` 一筆，品項數為 25。

## 你的 `我的查詢.sql`

完成後，檔案應該包含這幾句。之後 App 的每個功能，都會對應到其中一句：

| 故事 | SQL | 未來 App 的功能 |
|:---:|---|---|
| S1 | `SELECT ... WHERE current_stock <= safety_stock` | 補貨清單 |
| S2 | `SELECT ... WHERE name LIKE` | 搜尋耗材 |
| S3 | `UPDATE ... SET current_stock = current_stock - 數量` | 登記領用 |
| S4 | `INSERT`、`DELETE` | 新增與刪除 |
| S5 | `SELECT SUM(unit_price * current_stock)` | 庫存總金額 |

> [!TIP]
> 資料被改亂了？執行 [`supplies_full.sql`](./supplies_full.sql) 就會回到初始狀態。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| 文字條件出現 `column "碳粉" does not exist` | 文字用了雙引號 | SQL 的文字要用單引號 |
| `WHERE last_checked = NULL` 查不到資料 | `NULL` 不能用等號比較 | 改成 `IS NULL` |
| `current transaction is aborted` | 交易中有一句失敗 | 先執行 `ROLLBACK;` |
| 改完後別的視窗看不到 | 還沒 `COMMIT;` | 確認沒問題後執行 `COMMIT;` |

## ✍️ 動手練

**第 1 題**：列出最貴的 3 項清潔用品，顯示品名和單價。

<details>
<summary>看答案</summary>

```sql
SELECT name AS 品名, unit_price AS 單價
FROM supplies
WHERE category = '清潔用品'
ORDER BY unit_price DESC
LIMIT 3;
```

| 品名 | 單價 |
|---|---:|
| 抽取式衛生紙 | 890 |
| 洗手乳補充包 | 120 |
| 垃圾袋 大 | 65 |

</details>

**第 2 題**：列出還沒盤點過的耗材。

<details>
<summary>看答案</summary>

```sql
SELECT item_code AS 品號, name AS 品名
FROM supplies
WHERE last_checked IS NULL
ORDER BY item_code;
```

| 品號 | 品名 |
|---|---|
| CLN-ALC-500 | 75% 酒精 |
| STA-TAPE-18 | 透明膠帶 |

</details>

**第 3 題**：算出文具類的庫存總金額。

<details>
<summary>看答案</summary>

```sql
SELECT SUM(unit_price * current_stock) AS 文具庫存金額
FROM supplies
WHERE category = '文具';
```

做完 S3 領用後，結果是 **8596**。

</details>

## 🤖 問 AI 助教

> 我要完成這個需求：（貼上故事與驗收條件）。這是我寫的 SQL：（貼上）。請判斷它有沒有符合驗收條件；不符合的話，給我提示就好，先不要給答案。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 3：AI 產生資料交易檔](./3_AI產生資料交易檔.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 5：產生 PRD ➡️](./prompts/01_MCP讀結構產生PRD.md) |
