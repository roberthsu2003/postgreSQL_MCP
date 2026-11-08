# 步驟 2｜手寫 DDL：建立三張表

> 💻 DBeaver（資料庫：`tickets`）｜ 🎯 學完你會：用 `CHECK` 把業務規則寫進資料表

## 1. 建立資料庫和資料表

```sql
CREATE DATABASE tickets;
```

切換到 `tickets`，先建人員和分類，再建案件：

```sql
CREATE TABLE agents (
    agent_id  SERIAL PRIMARY KEY,
    name      VARCHAR(20) NOT NULL UNIQUE,
    extension VARCHAR(10) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE tickets (
    ticket_id     VARCHAR(10) PRIMARY KEY,
    created_on    DATE        NOT NULL,
    customer_name VARCHAR(30) NOT NULL,
    category_id   INT         NOT NULL REFERENCES categories(category_id),
    description   TEXT        NOT NULL,
    agent_id      INT         NOT NULL REFERENCES agents(agent_id),
    status        VARCHAR(10) NOT NULL DEFAULT '處理中' CHECK (status IN ('處理中', '待回覆', '已結案')),
    closed_on     DATE,
    CHECK ((status = '已結案') = (closed_on IS NOT NULL)),
    CHECK (closed_on >= created_on)
);
```

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

## 2. 測試保護機制

先放進一組正確的資料：

```sql
INSERT INTO agents (name, extension) VALUES ('陳怡君', '101');
INSERT INTO categories (name) VALUES ('網路連線');
INSERT INTO tickets VALUES ('T001', '2024-01-03', '順發貿易', 1, 'WiFi 連不上，重開機也沒用', 1, '已結案', '2024-01-04');
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：案件編號重複
INSERT INTO tickets VALUES ('T001', '2024-04-01', '順發貿易', 1, '編號重複', 1, '處理中', NULL);

-- 第 2 列：狀態不在三種之內
INSERT INTO tickets VALUES ('T101', '2024-04-01', '順發貿易', 1, '狀態自己亂寫', 1, '暫緩', NULL);

-- 第 3 列：沒有這位處理人員，這裡用不存在的編號 99 代表
INSERT INTO tickets VALUES ('T102', '2024-04-01', '順發貿易', 1, '處理人員不存在', 99, '處理中', NULL);

-- 第 4 列：已結案卻沒有日期
INSERT INTO tickets VALUES ('T103', '2024-04-01', '順發貿易', 1, '已結案卻沒有日期', 1, '已結案', NULL);

-- 第 5 列：結案比建立還早
INSERT INTO tickets VALUES ('T104', '2024-04-05', '順發貿易', 1, '結案比建立還早', 1, '已結案', '2024-04-01');
```

**執行結果：五句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "tickets_pkey"` | 主鍵 |
| 2 | `violates check constraint "tickets_status_check"` | `CHECK` |
| 3 | `violates foreign key constraint "tickets_agent_id_fkey"` | 外來鍵 |
| 4 | `violates check constraint "tickets_check"` | 結案規則 |
| 5 | `violates check constraint "tickets_check1"` | 日期規則 |

## 3. 清空測試資料

```sql
TRUNCATE tickets, categories, agents RESTART IDENTITY;
```

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "categories" does not exist` | 建表順序錯了 | 先建 `agents`、`categories` |
| `tickets_check` | 狀態和結案日期對不上 | 已結案要有日期，其他狀態不能有日期 |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✅ 過關檢查

- [ ] 五列有問題的資料都被擋下，我能說出原因
- [ ] 已執行含 `RESTART IDENTITY` 的 `TRUNCATE`，三張表都是 0 筆

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：拆表與結案規則](./1_拆表與結案規則.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
