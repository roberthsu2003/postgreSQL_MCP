# 步驟 2｜手寫 DDL：親手建立兩張有關聯的表

> 💻 DBeaver（資料庫：`attendance`）｜ 🎯 學完你會：建立外來鍵與兩欄主鍵，並看懂資料庫怎麼保護關聯

> 📚 先修：[DML-4 外來鍵](../../SQL語法教學/7_0FOREIGN_KEY.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

拆法已經決定，現在親手把兩張表蓋出來。

## 1. 建立資料庫

```sql
CREATE DATABASE attendance;
```

建好後，在 DBeaver 工具列把資料庫切換成 `attendance`。

## 2. 建立資料表：先父後子

`attendance` 要參照 `employees`，所以 `employees` 一定要先存在。

```sql
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    dept   VARCHAR(20) NOT NULL,
    title  VARCHAR(30) NOT NULL
);

CREATE TABLE attendance (
    emp_id    VARCHAR(10) NOT NULL REFERENCES employees(emp_id),
    work_date DATE        NOT NULL,
    clock_in  TIME,
    clock_out TIME,
    PRIMARY KEY (emp_id, work_date),
    CHECK (clock_out > clock_in)
);
```

| 寫法 | 白話 | Excel 裡類似的功能 |
|---|---|---|
| `REFERENCES employees(emp_id)` | 外來鍵：工號必須存在於員工表 | 下拉清單來自另一張工作表 |
| `PRIMARY KEY (emp_id, work_date)` | 兩欄合起來不能重複 | 無 |
| `CHECK (clock_out > clock_in)` | 下班要晚於上班 | 資料驗證的自訂公式 |

> [!NOTE]
> 如果有一邊打卡是空白，`CHECK` 不會擋下來。忘記打卡是允許的情況，所以這正是我們要的結果。

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

## 3. 查看結構

```sql
SELECT table_name AS 資料表, column_name AS 欄位, data_type AS 型別, is_nullable AS 可留空
FROM information_schema.columns
WHERE table_name IN ('employees', 'attendance')
ORDER BY table_name DESC, ordinal_position;
```

**執行結果**

| 資料表 | 欄位 | 型別 | 可留空 |
|---|---|---|---|
| employees | emp_id | character varying | NO |
| employees | name | character varying | NO |
| employees | dept | character varying | NO |
| employees | title | character varying | NO |
| attendance | emp_id | character varying | NO |
| attendance | work_date | date | NO |
| attendance | clock_in | time without time zone | YES |
| attendance | clock_out | time without time zone | YES |

## 4. 測試保護機制

先放進一位員工和一筆打卡。寫入也是**先父後子**：

```sql
INSERT INTO employees VALUES ('E01', '陳小華', '業務發展部', '資深業務代表');
INSERT INTO attendance VALUES ('E01', '2024-03-11', '08:55', '18:00');
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：沒有這位員工
INSERT INTO attendance VALUES ('E99', '2024-03-11', '08:55', '18:00');

-- 第 2 列：同一人同一天打卡兩次
INSERT INTO attendance VALUES ('E01', '2024-03-11', '08:55', '18:00');

-- 第 3 列：下班比上班早
INSERT INTO attendance VALUES ('E01', '2024-03-12', '18:00', '09:00');

-- 第 4 列：沒有這一天
INSERT INTO attendance VALUES ('E01', '2024-02-30', '08:55', '18:00');

-- 第 5 列：沒有這個時間
INSERT INTO attendance VALUES ('E01', '2024-03-13', '25:10', '18:00');
```

**執行結果：五句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `violates foreign key constraint "attendance_emp_id_fkey"` | 外來鍵 |
| 2 | `duplicate key value violates unique constraint "attendance_pkey"` | 兩欄主鍵 |
| 3 | `violates check constraint "attendance_check"` | `CHECK` |
| 4 | `date/time field value out of range: "2024-02-30"` | 型別 `DATE` |
| 5 | `date/time field value out of range: "25:10"` | 型別 `TIME` |

再試試刪掉還有打卡紀錄的員工：

```sql
DELETE FROM employees WHERE emp_id = 'E01';
```

**執行結果**：`update or delete on table "employees" violates foreign key constraint "attendance_emp_id_fkey" on table "attendance"`

資料庫不會讓打卡紀錄變成沒有主人的孤兒。

## 5. 清空測試資料

只清空父表會被擋下，因為子表還參照著它：

```sql
TRUNCATE employees;
```

**執行結果**：`cannot truncate a table referenced in a foreign key constraint`

要兩張表一起清空：

```sql
TRUNCATE attendance, employees;
```

> [!WARNING]
> `TRUNCATE` 沒有資源回收桶，也沒有 `Ctrl + Z`。

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "employees" does not exist` | 先建了 `attendance`，或連錯資料庫 | 先建 `employees`，並檢查工具列 |
| `cannot drop table employees because other objects depend on it` | 子表還在 | 先 `DROP TABLE attendance;`，再刪 `employees` |
| `multiple primary keys ... not allowed` | 在兩個欄位各寫了 `PRIMARY KEY` | 改成最後一行 `PRIMARY KEY (emp_id, work_date)` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：為什麼第 2 列被擋，但同一個人在另一天打卡就可以？

<details>
<summary>看答案</summary>

主鍵是 `emp_id` 和 `work_date` 的組合。同一人不同天，組合不同，所以不算重複。

</details>

**第 2 題**：不看講義，說出建表、寫入、刪除時，父表和子表的先後順序。

<details>
<summary>看答案</summary>

建表和寫入都是先父後子；刪除資料和刪除資料表則是先子後父。

</details>

## 🤖 問 AI 助教

> 這是我手寫的兩張 PostgreSQL 資料表：（貼上你的 SQL）。請檢查外來鍵和主鍵能不能做到「打卡的工號必須存在」和「同一人同一天只有一筆」，有問題的話給我提示，不要直接重寫。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：為什麼要拆表](./1_為什麼要拆表.md) | [🏠 專案說明](./README.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
