# 步驟 2｜手寫 DDL：依順序建立四張表

> 💻 DBeaver（資料庫：`expense`）｜ 🎯 學完你會：依相依順序建立多張表，並驗證每一層保護

> 📚 先修：[進階-1 建立七張表](../../SQL語法教學/7創建關聯資料庫.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

規劃已經完成，現在親手建立。請注意順序：被參照的表要先存在。

## 1. 建立資料庫

```sql
CREATE DATABASE expense;
```

建好後，在 DBeaver 工具列把資料庫切換成 `expense`。

## 2. 建立四張表

```sql
CREATE TABLE departments (
    dept_id      SERIAL PRIMARY KEY,
    name         VARCHAR(30) NOT NULL UNIQUE,
    manager_name VARCHAR(20) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE employees (
    emp_id  VARCHAR(10) PRIMARY KEY,
    name    VARCHAR(20) NOT NULL,
    dept_id INT NOT NULL REFERENCES departments(dept_id)
);

CREATE TABLE claims (
    claim_id    VARCHAR(20) PRIMARY KEY,
    claim_date  DATE NOT NULL,
    emp_id      VARCHAR(10) NOT NULL REFERENCES employees(emp_id),
    category_id INT NOT NULL REFERENCES categories(category_id),
    description TEXT,
    invoice_no  VARCHAR(30) NOT NULL UNIQUE,
    amount      NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    status      VARCHAR(20) NOT NULL DEFAULT '待審核'
                CHECK (status IN ('待審核', '已批准', '待撥款', '已撥款', '已駁回'))
);
```

`SERIAL` 是整數，所以參照它的 `dept_id`、`category_id` 用 `INT`。

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

確認四張表都建好了：

```sql
SELECT table_name AS 資料表, COUNT(*) AS 欄位數
FROM information_schema.columns
WHERE table_name IN ('departments', 'categories', 'employees', 'claims')
GROUP BY table_name
ORDER BY table_name;
```

**執行結果**

| 資料表 | 欄位數 |
|---|---:|
| categories | 2 |
| claims | 8 |
| departments | 3 |
| employees | 3 |

## 3. 測試保護機制

先放進一組正確的資料，從最上層開始寫：

```sql
INSERT INTO departments (name, manager_name) VALUES ('業務部', '張協理') RETURNING dept_id, name;
INSERT INTO categories (name) VALUES ('市區交通') RETURNING category_id, name;
INSERT INTO employees VALUES ('E01', '陳小華', 1);
INSERT INTO claims VALUES ('EXP20240301', '2024-03-01', 'E01', 1, '拜訪台北市內湖客戶計程車費', 'AB-98765431', 350, '已撥款');
```

`RETURNING` 會顯示自動產生的編號，兩個都應該是 1。

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：同一張發票又報一次
INSERT INTO claims VALUES ('EXP20240401', '2024-04-01', 'E01', 1, '同一張發票又報一次', 'AB-98765431', 350, '待審核');

-- 第 2 列：報銷單號已經存在
INSERT INTO claims VALUES ('EXP20240301', '2024-04-01', 'E01', 1, '單號打錯', 'AB-00000001', 200, '待審核');

-- 第 3 列：金額是 0
INSERT INTO claims VALUES ('EXP20240402', '2024-04-02', 'E01', 1, '金額忘了填', 'AB-00000002', 0, '待審核');

-- 第 4 列：狀態不在五種之內
INSERT INTO claims VALUES ('EXP20240403', '2024-04-03', 'E01', 1, '狀態自己亂寫', 'AB-00000003', 300, '審核中');

-- 第 5 列：沒有這位員工
INSERT INTO claims VALUES ('EXP20240404', '2024-04-04', 'E99', 1, '沒有這位員工', 'AB-00000004', 300, '待審核');

-- 第 6 列：類別表沒有「交際費」，這裡用不存在的編號 99 代表
INSERT INTO claims VALUES ('EXP20240405', '2024-04-05', 'E01', 99, '類別表沒有這一項', 'AB-00000005', 300, '待審核');
```

**執行結果：六句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "claims_invoice_no_key"` | `UNIQUE` |
| 2 | `duplicate key ... "claims_pkey"` | 主鍵 |
| 3 | `violates check constraint "claims_amount_check"` | `CHECK` |
| 4 | `violates check constraint "claims_status_check"` | `CHECK` |
| 5 | `violates foreign key constraint "claims_emp_id_fkey"` | 外來鍵 |
| 6 | `violates foreign key constraint "claims_category_id_fkey"` | 外來鍵 |

再試試兩種情況：

```sql
-- 部門名稱重複
INSERT INTO departments (name, manager_name) VALUES ('業務部', '王經理');

-- 刪除還有員工的部門
DELETE FROM departments WHERE dept_id = 1;
```

**執行結果**：分別是 `duplicate key ... "departments_name_key"` 和 `violates foreign key constraint "employees_dept_id_fkey"`。

## 4. 清空測試資料，編號也要重來

```sql
TRUNCATE claims, employees, categories, departments RESTART IDENTITY;
```

`RESTART IDENTITY` 會把自動編號歸零。

> [!NOTE]
> 失敗的 INSERT 也會用掉編號，所以編號出現跳號是正常的。編號只用來識別資料，不需要連續。

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "departments" does not exist` | 建表順序錯了，或連錯資料庫 | 依照講義順序建立，並檢查工具列 |
| `foreign key constraint ... cannot be implemented` | 兩邊型別不同 | `SERIAL` 的外來鍵用 `INT` |
| `cannot truncate a table referenced in a foreign key constraint` | 沒有把相關的表一起清空 | 四張表寫在同一句 `TRUNCATE` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：如果要刪掉這四張表，順序是什麼？

<details>
<summary>看答案</summary>

和建立順序相反：先刪 `claims`，再刪 `employees`，最後刪 `categories` 和 `departments`。

</details>

**第 2 題**：`claims.status` 沒有填的時候會是什麼？為什麼這樣設計？

<details>
<summary>看答案</summary>

會是 `待審核`，因為有 `DEFAULT '待審核'`。新單據一定要先經過審核，所以用預設值確保流程從正確的狀態開始。

</details>

## 🤖 問 AI 助教

> 這是我手寫的四張 PostgreSQL 資料表：（貼上你的 SQL）。請檢查建表順序、外來鍵型別，以及能不能擋下重複發票和金額為 0，有問題的話給我提示，不要直接重寫。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：一張拆四張](./1_一張拆四張.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
