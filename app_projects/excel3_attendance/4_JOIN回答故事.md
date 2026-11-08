# 步驟 4｜JOIN 回答故事：拆開存，接起來看

> 💻 DBeaver（資料庫：`attendance`）｜ 🎯 學完你會：用 JOIN 還原報表，用 LEFT JOIN 找出沒有資料的人

> 📚 先修：[DML-5 JOIN](../../SQL語法教學/JOIN.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

資料拆成兩張表後，小芳要看的報表還是「姓名和打卡在同一列」。這正是 `JOIN` 的工作，它就像 VLOOKUP，用工號到員工表把姓名和部門帶過來。

開一個新的 SQL 分頁，存成 `我的查詢.sql`。

> [!TIP]
> 請照順序做。S4、S5 會改變資料，後面的練習答案是以做完這些步驟的資料為準。

## S1｜查某位員工的打卡

```sql
SELECT a.work_date AS 日期,
       e.name AS 姓名,
       e.dept AS 部門,
       a.clock_in AS 上班,
       a.clock_out AS 下班
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.name = '林志明'
ORDER BY a.work_date;
```

| SQL | 白話 |
|---|---|
| `attendance a` | 幫表取個短名字 `a` |
| `JOIN employees e` | 把員工表接過來 |
| `ON a.emp_id = e.emp_id` | 用工號對應，就像 VLOOKUP 的查找值 |

**執行結果**

| 日期 | 姓名 | 部門 | 上班 | 下班 |
|---|---|---|---|---|
| 2024-03-04 | 林志明 | 資訊技術部 | 09:15:00 | 20:30:00 |
| 2024-03-05 | 林志明 | 資訊技術部 | 08:59:00 | 18:30:00 |
| 2024-03-06 | 林志明 | 資訊技術部 | 09:03:00 | 19:10:00 |
| 2024-03-07 | 林志明 | 資訊技術部 | 08:56:00 | 18:45:00 |
| 2024-03-08 | 林志明 | 資訊技術部 | 08:59:00 | 18:20:00 |

## S2｜遲到名單

```sql
SELECT a.work_date AS 日期,
       e.name AS 姓名,
       e.dept AS 部門,
       a.clock_in AS 上班
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.clock_in > '09:00'
ORDER BY a.work_date, a.clock_in;
```

**執行結果**

| 日期 | 姓名 | 部門 | 上班 |
|---|---|---|---|
| 2024-03-04 | 林志明 | 資訊技術部 | 09:15:00 |
| 2024-03-05 | 黃雅婷 | 行銷企劃部 | 09:07:00 |
| 2024-03-06 | 林志明 | 資訊技術部 | 09:03:00 |
| 2024-03-07 | 張大同 | 管理行政部 | 09:12:00 |
| 2024-03-08 | 周美玲 | 業務發展部 | 09:01:00 |

張大同 3 月 4 日 09:00 整打卡，用 `>` 不會算遲到，符合驗收條件。

## S3｜忘記打卡

```sql
SELECT a.work_date AS 日期,
       e.name AS 姓名,
       a.clock_in AS 上班,
       a.clock_out AS 下班
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.clock_in IS NULL OR a.clock_out IS NULL
ORDER BY a.work_date, e.emp_id;
```

**執行結果**

| 日期 | 姓名 | 上班 | 下班 |
|---|---|---|---|
| 2024-03-05 | 周美玲 | NULL | 18:03:00 |
| 2024-03-06 | 張大同 | 08:58:00 | NULL |
| 2024-03-07 | 陳小華 | 08:49:00 | NULL |

## S4｜調部門只改一次

黃雅婷調到業務發展部。在 Excel 要改 4 列，現在只要改一列：

```sql
BEGIN;

UPDATE employees
SET dept = '業務發展部'
WHERE emp_id = 'E03'
RETURNING emp_id, name, dept;

SELECT a.work_date AS 日期, e.name AS 姓名, e.dept AS 部門
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.emp_id = 'E03'
ORDER BY a.work_date;
```

**執行結果**：`UPDATE` 改了 1 筆，查詢的 4 筆打卡全部顯示新部門。

| 日期 | 姓名 | 部門 |
|---|---|---|
| 2024-03-04 | 黃雅婷 | 業務發展部 |
| 2024-03-05 | 黃雅婷 | 業務發展部 |
| 2024-03-06 | 黃雅婷 | 業務發展部 |
| 2024-03-07 | 黃雅婷 | 業務發展部 |

確認無誤就送出：

```sql
COMMIT;
```

周美玲那種部門矛盾也不會再發生，因為部門只存一次。

## S5｜新人先登記，找出沒打卡的人

新人吳小安下週才開始打卡，現在就能先登記：

```sql
INSERT INTO employees (emp_id, name, dept, title)
VALUES ('E07', '吳小安', '管理行政部', '行政助理')
RETURNING emp_id, name, dept;
```

**執行結果**：`E07 | 吳小安 | 管理行政部`

用剛才的 `JOIN` 查吳小安，會得到 **0 筆**，因為 `JOIN` 只留下兩邊都有的資料。要找「沒有打卡的人」，要用 `LEFT JOIN`：

```sql
SELECT e.emp_id AS 工號, e.name AS 姓名, e.dept AS 部門
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id
WHERE a.emp_id IS NULL;
```

**執行結果**

| 工號 | 姓名 | 部門 |
|---|---|---|
| E07 | 吳小安 | 管理行政部 |

`LEFT JOIN` 會保留左邊所有員工，對不到打卡的部分是 `NULL`，再用 `IS NULL` 把這些人挑出來。這在單一工作表裡做不到，因為吳小安根本放不進去。

## 你的 `我的查詢.sql`

| 故事 | SQL | 未來 App 的功能 |
|:---:|---|---|
| S1 | `JOIN ... WHERE e.name = ...` | 查員工打卡 |
| S2 | `JOIN ... WHERE a.clock_in > '09:00'` | 遲到名單 |
| S3 | `JOIN ... WHERE ... IS NULL OR ... IS NULL` | 忘打卡名單 |
| S4 | `UPDATE employees SET dept = ...` | 調部門 |
| S5 | `INSERT INTO employees`、`LEFT JOIN ... IS NULL` | 新增員工、未打卡名單 |

> [!TIP]
> 資料被改亂了？執行 [`attendance_full.sql`](./attendance_full.sql) 就會回到初始狀態。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| `column reference "emp_id" is ambiguous` | 兩張表都有 `emp_id` | 寫清楚 `a.emp_id` 或 `e.emp_id` |
| 結果筆數多到不合理 | 忘了寫 `ON`，或對應欄位寫錯 | 檢查 `ON a.emp_id = e.emp_id` |
| 查不到沒打卡的人 | 用了 `JOIN` | 改成 `LEFT JOIN`，並從 `employees` 開始 |
| `current transaction is aborted` | 交易中有一句失敗 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：列出資訊技術部晚上 8 點以後才下班的紀錄，顯示姓名、日期和下班時間。

<details>
<summary>看答案</summary>

```sql
SELECT e.name AS 姓名, a.work_date AS 日期, a.clock_out AS 下班
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.dept = '資訊技術部' AND a.clock_out >= '20:00'
ORDER BY a.work_date;
```

| 姓名 | 日期 | 下班 |
|---|---|---|
| 林志明 | 2024-03-04 | 20:30:00 |
| 劉國強 | 2024-03-08 | 21:05:00 |

</details>

**第 2 題**：找出 3 月 6 日沒有打卡紀錄的員工。提示：日期條件要放在 `ON`。

<details>
<summary>看答案</summary>

```sql
SELECT e.emp_id AS 工號, e.name AS 姓名
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id AND a.work_date = '2024-03-06'
WHERE a.emp_id IS NULL
ORDER BY e.emp_id;
```

| 工號 | 姓名 |
|---|---|
| E06 | 劉國強 |
| E07 | 吳小安 |

如果把日期條件放到 `WHERE`，結果會是 0 筆。因為沒打卡的人日期是 `NULL`，會被 `WHERE` 濾掉。

</details>

## 🤖 問 AI 助教

> 我要完成這個需求：（貼上故事與驗收條件）。這是我寫的 SQL：（貼上）。請判斷它有沒有符合驗收條件；不符合的話，給我提示就好，先不要給答案。

## ✅ 過關檢查

- [ ] 五則故事都完成，SQL 都存進 `我的查詢.sql`
- [ ] 我能說明 `JOIN` 和 VLOOKUP 的相似之處
- [ ] 我知道什麼時候要用 `LEFT JOIN`
- [ ] 我親眼看到調部門只改一次，所有報表都更新

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 3：AI 產生資料交易檔](./3_AI產生資料交易檔.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 5：產生 PRD ➡️](./prompts/01_MCP讀結構產生PRD.md) |
