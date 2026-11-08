# 步驟 4｜多表 JOIN 回答故事：一路接到需要的資料

> 💻 DBeaver（資料庫：`expense`）｜ 🎯 學完你會：連續 JOIN 多張表，並用條件保護審核流程

> 📚 先修：[DML-5 JOIN](../../SQL語法教學/JOIN.md)。多表 JOIN 只是一次接一張。

## 🎬 情境

報銷單只記員工和類別的編號。要看到部門和主管，就得一路接過去：**報銷單 → 員工 → 部門**。

開一個新的 SQL 分頁，存成 `我的查詢.sql`。

> [!TIP]
> 請照順序做。S3、S4 會改變資料，後面的練習答案是以做完這些步驟的資料為準。

## S1｜待撥款清單

```sql
SELECT c.claim_id AS 單號,
       e.name AS 員工,
       d.name AS 部門,
       k.name AS 類別,
       c.amount AS 金額
FROM claims c
JOIN employees e ON c.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
JOIN categories k ON c.category_id = k.category_id
WHERE c.status = '待撥款'
ORDER BY c.claim_date;
```

**執行結果**

| 單號 | 員工 | 部門 | 類別 | 金額 |
|---|---|---|---|---:|
| EXP20240309 | 周美玲 | 業務部 | 長途交通 | 2980.00 |
| EXP20240310 | 周美玲 | 業務部 | 差旅住宿 | 2200.00 |

> [!NOTE]
> `SUM` 就是 Excel 的 SUM，`COUNT` 是算筆數。這裡只算一個總數，要依門市、月份分組統計時，[進階-4](../../SQL語法教學/10聚合函式.md)會完整教。

驗收條件還要合計金額：

```sql
SELECT SUM(amount) AS 待撥款合計
FROM claims
WHERE status = '待撥款';
```

**執行結果**：`5180.00`

## S2｜待審核與負責主管

```sql
SELECT c.claim_id AS 單號,
       e.name AS 申請人,
       d.name AS 部門,
       d.manager_name AS 審核主管,
       c.amount AS 金額
FROM claims c
JOIN employees e ON c.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE c.status = '待審核'
ORDER BY c.claim_date;
```

**執行結果**

| 單號 | 申請人 | 部門 | 審核主管 | 金額 |
|---|---|---|---|---:|
| EXP20240312 | 黃雅婷 | 行銷部 | 王經理 | 2500.00 |
| EXP20240313 | 陳小華 | 業務部 | 張協理 | 320.00 |

## S5｜部門已撥款總額

```sql
SELECT SUM(c.amount) AS 已撥款總額
FROM claims c
JOIN employees e ON c.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.name = '業務部' AND c.status = '已撥款';
```

**執行結果**：`3430.00`

周美玲的單據還沒撥款，陳小華有一張還在待審核，這些都不會算進去。

## S3｜審核單據

重點在 `WHERE` 除了指定單號，還要確認**目前是待審核**：

```sql
BEGIN;

UPDATE claims
SET status = '已批准'
WHERE claim_id = 'EXP20240313' AND status = '待審核'
RETURNING claim_id, status;
```

**執行結果**

| claim_id | status |
|---|---|
| EXP20240313 | 已批准 |

沒問題就送出：

```sql
COMMIT;
```

假設另一位主管沒注意到，又想駁回同一張單：

```sql
UPDATE claims
SET status = '已駁回'
WHERE claim_id = 'EXP20240313' AND status = '待審核'
RETURNING claim_id, status;
```

**執行結果**：**0 筆**，單據仍然是「已批准」。沒有錯誤訊息，也沒有改到資料，這就是 S3 要的保護。

## S4｜新增類別與報銷單

有一種新費用，先新增類別。因為 `setval` 設定正確，編號會接在 9 後面：

```sql
INSERT INTO categories (name) VALUES ('員工訓練') RETURNING category_id, name;
```

**執行結果**：`10 | 員工訓練`

再新增報銷單。沒有填狀態，會自動是待審核：

```sql
INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount)
VALUES ('EXP20240314', '2024-03-29', 'E04', 10, '新進同仁資安課程', 'GH-99887767', 1500)
RETURNING claim_id, status, amount;
```

**執行結果**：`EXP20240314 | 待審核 | 1500.00`

同一張發票再報一次：

```sql
INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount)
VALUES ('EXP20240315', '2024-03-29', 'E04', 10, '同一張發票又報一次', 'GH-99887767', 1500);
```

**執行結果**：`duplicate key value violates unique constraint "claims_invoice_no_key"`

## 你的 `我的查詢.sql`

| 故事 | SQL | 未來 App 的功能 |
|:---:|---|---|
| S1 | 三次 `JOIN ... WHERE status = '待撥款'`、`SUM` | 待撥款清單 |
| S2 | 兩次 `JOIN ... WHERE status = '待審核'` | 待審核清單 |
| S3 | `UPDATE ... WHERE claim_id = ... AND status = '待審核'` | 核准、駁回 |
| S4 | `INSERT INTO categories`、`INSERT INTO claims` | 新增類別、新增報銷單 |
| S5 | 兩次 `JOIN`、`SUM ... WHERE d.name = ...` | 部門已撥款總額 |

> [!TIP]
> 資料被改亂了？執行 [`expense_full.sql`](./expense_full.sql) 就會回到初始狀態。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| `column reference "name" is ambiguous` | 好幾張表都有 `name` | 寫清楚 `e.name`、`d.name`、`k.name` |
| `missing FROM-clause entry for table "d"` | 用了 `d`，卻沒有 `JOIN` 部門 | 補上 `JOIN departments d ...` |
| 查不到單據 | 狀態文字打錯 | 直接從講義或資料複製狀態文字 |
| `UPDATE` 回傳 0 筆 | 單據已經不是待審核 | 先查單據目前的狀態 |

## ✍️ 動手練

**第 1 題**：列出「李副總」負責的部門的所有報銷單，顯示單號、申請人、部門和金額。

<details>
<summary>看答案</summary>

```sql
SELECT c.claim_id AS 單號, e.name AS 申請人, d.name AS 部門, c.amount AS 金額
FROM claims c
JOIN employees e ON c.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.manager_name = '李副總'
ORDER BY c.claim_date;
```

| 單號 | 申請人 | 部門 | 金額 |
|---|---|---|---:|
| EXP20240303 | 林志明 | 技術部 | 3850.00 |
| EXP20240306 | 張大同 | 人事部 | 1200.00 |
| EXP20240307 | 林志明 | 技術部 | 4500.00 |
| EXP20240311 | 林志明 | 技術部 | 3600.00 |
| EXP20240314 | 張大同 | 人事部 | 1500.00 |

</details>

**第 2 題**：新增一個「團隊活動」類別，然後找出從來沒有人報銷過的類別。

<details>
<summary>看答案</summary>

```sql
INSERT INTO categories (name) VALUES ('團隊活動');

SELECT k.category_id AS 編號, k.name AS 類別
FROM categories k
LEFT JOIN claims c ON k.category_id = c.category_id
WHERE c.claim_id IS NULL;
```

| 編號 | 類別 |
|---:|---|
| 11 | 團隊活動 |

</details>

**第 3 題**：找出金額最高的已撥款單據，顯示單號、申請人和金額。

<details>
<summary>看答案</summary>

```sql
SELECT c.claim_id AS 單號, e.name AS 申請人, c.amount AS 金額
FROM claims c
JOIN employees e ON c.emp_id = e.emp_id
WHERE c.status = '已撥款'
ORDER BY c.amount DESC
LIMIT 1;
```

**執行結果**：`EXP20240304 | 黃雅婷 | 8500.00`

</details>

## 🤖 問 AI 助教

> 我要完成這個需求：（貼上故事與驗收條件）。這是我寫的 SQL：（貼上）。請判斷它有沒有符合驗收條件；不符合的話，給我提示就好，先不要給答案。

## ✅ 過關檢查

- [ ] 五則故事都完成，SQL 都存進 `我的查詢.sql`
- [ ] 我能說明報銷單是怎麼一路接到部門主管的
- [ ] 我能說明為什麼審核的 `WHERE` 要加上 `status = '待審核'`

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 3：AI 產生資料交易檔](./3_AI產生資料交易檔.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 5：產生 PRD ➡️](./prompts/01_MCP讀結構產生PRD.md) |
