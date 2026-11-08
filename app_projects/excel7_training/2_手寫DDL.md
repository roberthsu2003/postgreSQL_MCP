# 步驟 2｜手寫 DDL：建立五張表

> 💻 DBeaver（資料庫：`training`）｜ 🎯 學完你會：建立兩組報名紀錄，並用布林值記錄出席

## 1. 建立資料庫和資料表

```sql
CREATE DATABASE training;
```

切換到 `training`，先建課程、員工和來賓，最後建報名紀錄：

```sql
CREATE TABLE courses (
    course_id   VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    course_date DATE        NOT NULL,
    instructor  VARCHAR(20) NOT NULL,
    capacity    INT         NOT NULL CHECK (capacity > 0)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    dept   VARCHAR(20) NOT NULL
);

CREATE TABLE guests (
    guest_id SERIAL PRIMARY KEY,
    name     VARCHAR(20) NOT NULL,
    company  VARCHAR(30) NOT NULL,
    email    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee_enrollments (
    course_id VARCHAR(10) NOT NULL REFERENCES courses(course_id),
    emp_id    VARCHAR(10) NOT NULL REFERENCES employees(emp_id),
    attended  BOOLEAN,
    PRIMARY KEY (course_id, emp_id)
);

CREATE TABLE guest_enrollments (
    course_id VARCHAR(10) NOT NULL REFERENCES courses(course_id),
    guest_id  INT         NOT NULL REFERENCES guests(guest_id),
    attended  BOOLEAN,
    PRIMARY KEY (course_id, guest_id)
);
```

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

## 2. 測試保護機制

先放進一組正確的資料：

```sql
INSERT INTO courses VALUES ('C01', 'Excel 樞紐分析', '2024-04-10', '李老師', 30);
INSERT INTO employees VALUES ('E01', '陳小華', '業務發展部');
INSERT INTO guests (name, company, email) VALUES ('趙文華', '順發貿易', 'wenhua@example.com');
INSERT INTO employee_enrollments VALUES ('C01', 'E01', true);
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：同一門課已經報過名
INSERT INTO employee_enrollments VALUES ('C01', 'E01', NULL);

-- 第 2 列：沒有這門課
INSERT INTO employee_enrollments VALUES ('C99', 'E01', NULL);

-- 第 3 列：沒有這位員工
INSERT INTO employee_enrollments VALUES ('C01', 'E99', NULL);

-- 第 4 列：這個信箱已經被使用
INSERT INTO guests (name, company, email) VALUES ('王小美', '順發貿易', 'wenhua@example.com');

-- 第 5 列：人數上限是 0
INSERT INTO courses VALUES ('C07', '人數錯誤的課', '2024-07-01', '李老師', 0);
```

**執行結果：五句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "employee_enrollments_pkey"` | 兩欄主鍵 |
| 2 | `violates foreign key constraint "employee_enrollments_course_id_fkey"` | 外來鍵 |
| 3 | `violates foreign key constraint "employee_enrollments_emp_id_fkey"` | 外來鍵 |
| 4 | `duplicate key ... "guests_email_key"` | `UNIQUE` |
| 5 | `violates check constraint "courses_capacity_check"` | `CHECK` |

## 3. 清空測試資料

```sql
TRUNCATE guest_enrollments, employee_enrollments, guests, employees, courses RESTART IDENTITY;
```

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "courses" does not exist` | 建表順序錯了 | 報名紀錄要最後建 |
| `cannot truncate a table referenced in a foreign key constraint` | 沒有一起清空 | 五張表寫在同一句 `TRUNCATE` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：兩份名單怎麼設計](./1_兩份名單怎麼設計.md) | [🏠 專案說明](./README.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
