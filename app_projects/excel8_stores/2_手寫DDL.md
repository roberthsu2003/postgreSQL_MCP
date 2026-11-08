# 步驟 2｜手寫 DDL：六張正式表和一張暫存表

> 💻 DBeaver（資料庫：`store_sales`）｜ 🎯 學完你會：自己蓋出完整的銷售資料庫，並建立匯入用的暫存表

> 📚 先修：[進階-1 建立七張表](../../SQL語法教學/7創建關聯資料庫.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 1. 建立資料庫

```sql
CREATE DATABASE store_sales;
```

建好後，在 DBeaver 工具列把資料庫切換成 `store_sales`。

## 2. 建立六張正式表

```sql
CREATE TABLE stores (
    store_id SERIAL PRIMARY KEY,
    name     VARCHAR(30) NOT NULL UNIQUE,
    region   VARCHAR(10) NOT NULL CHECK (region IN ('北部', '中部', '南部', '東部'))
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    name     VARCHAR(20) NOT NULL,
    store_id INT NOT NULL REFERENCES stores(store_id),
    UNIQUE (name, store_id)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE,
    category   VARCHAR(20) NOT NULL,
    price      INT NOT NULL CHECK (price >= 0)
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    phone       VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE orders (
    order_id       VARCHAR(20) PRIMARY KEY,
    order_date     DATE NOT NULL,
    order_time     TIME NOT NULL,
    store_id       INT NOT NULL REFERENCES stores(store_id),
    staff_id       INT NOT NULL REFERENCES staff(staff_id),
    customer_id    INT REFERENCES customers(customer_id),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('現金', '信用卡', 'LINE Pay', '街口支付')),
    status         VARCHAR(10) NOT NULL CHECK (status IN ('已完成', '已退款', '已取消'))
);

CREATE TABLE order_items (
    order_id   VARCHAR(20) NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);
```

`orders.customer_id` 沒有 `NOT NULL`，因為散客沒有會員資料。

## 3. 建立暫存表

欄位名稱和 CSV 的標題完全相同，DBeaver 匯入時才會自動對應。

```sql
CREATE TABLE raw_sales (
    銷售單號 TEXT,
    銷售日期 TEXT,
    時間 TEXT,
    門市名稱 TEXT,
    區域 TEXT,
    經手店員 TEXT,
    會員姓名 TEXT,
    會員電話 TEXT,
    商品分類 TEXT,
    商品名稱 TEXT,
    單價 TEXT,
    數量 TEXT,
    小計 TEXT,
    付款方式 TEXT,
    狀態 TEXT
);
```

確認七張表都建好了：

```sql
SELECT table_name AS 資料表, COUNT(*) AS 欄位數
FROM information_schema.columns
WHERE table_name IN ('stores', 'staff', 'products', 'customers', 'orders', 'order_items', 'raw_sales')
GROUP BY table_name
ORDER BY table_name;
```

**執行結果**

| 資料表 | 欄位數 |
|---|---:|
| customers | 3 |
| order_items | 4 |
| orders | 8 |
| products | 4 |
| raw_sales | 15 |
| staff | 3 |
| stores | 3 |

## 4. 測試保護機制

先放進一組正確的資料：

```sql
INSERT INTO stores (name, region) VALUES ('台北信義店', '北部');
INSERT INTO staff (name, store_id) VALUES ('張志明', 1);
INSERT INTO products (name, category, price) VALUES ('經典拿鐵', '義式咖啡', 95), ('靜岡抹茶歐蕾', '特調茶飲', 110);
INSERT INTO customers (name, phone) VALUES ('劉欣宜', '0936-805-870');
INSERT INTO orders VALUES ('ORD00001', '2024-01-24', '19:04', 1, 1, 1, '信用卡', '已完成');
INSERT INTO order_items VALUES ('ORD00001', 1, 1, 95);
```

先確認兩種**應該成功**的情況：

```sql
-- 同名但不同電話：是另一位會員
INSERT INTO customers (name, phone) VALUES ('劉欣宜', '0915-692-794') RETURNING customer_id, name, phone;

-- 散客訂單：沒有會員
INSERT INTO orders VALUES ('ORD00142', '2024-02-15', '18:34', 1, 1, NULL, '街口支付', '已退款') RETURNING order_id, customer_id;
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：同一張單的同一項商品已經有了
INSERT INTO order_items VALUES ('ORD00001', 1, 1, 95);

-- 第 2 列：數量是 0
INSERT INTO order_items VALUES ('ORD00001', 2, 0, 110);

-- 第 3 列：狀態不在三種之內
INSERT INTO orders VALUES ('ORD00002', '2024-01-24', '19:04', 1, 1, NULL, '現金', '已作廢');

-- 第 4 列：付款方式不在四種之內
INSERT INTO orders VALUES ('ORD00003', '2024-01-24', '19:04', 1, 1, NULL, '支票', '已完成');

-- 第 5 列：區域不在四種之內
INSERT INTO stores (name, region) VALUES ('澎湖馬公店', '離島');

-- 第 6 列：沒有這家門市
INSERT INTO orders VALUES ('ORD00004', '2024-01-24', '19:04', 99, 1, NULL, '現金', '已完成');

-- 第 7 列：這支電話已經是別的會員
INSERT INTO customers (name, phone) VALUES ('王小美', '0936-805-870');

-- 第 8 列：同一家店已經有這位店員
INSERT INTO staff (name, store_id) VALUES ('張志明', 1);
```

**執行結果：八句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "order_items_pkey"` | 兩欄主鍵 |
| 2 | `violates check constraint "order_items_quantity_check"` | `CHECK` |
| 3 | `violates check constraint "orders_status_check"` | `CHECK` |
| 4 | `violates check constraint "orders_payment_method_check"` | `CHECK` |
| 5 | `violates check constraint "stores_region_check"` | `CHECK` |
| 6 | `violates foreign key constraint "orders_store_id_fkey"` | 外來鍵 |
| 7 | `duplicate key ... "customers_phone_key"` | `UNIQUE` |
| 8 | `duplicate key ... "staff_name_store_id_key"` | 兩欄 `UNIQUE` |

## 5. 清空測試資料

```sql
TRUNCATE order_items, orders, customers, products, staff, stores RESTART IDENTITY;
```

`raw_sales` 沒有外來鍵，也還沒有資料，不用清空。

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "stores" does not exist` | 建表順序錯了，或連錯資料庫 | 依照講義順序建立，並檢查工具列 |
| `null value in column "customer_id"` | `customer_id` 多寫了 `NOT NULL` | 用 `ALTER TABLE orders ALTER COLUMN customer_id DROP NOT NULL;` |
| `cannot truncate a table referenced in a foreign key constraint` | 沒有把相關的表一起清空 | 六張表寫在同一句 `TRUNCATE` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：`raw_sales` 為什麼沒有主鍵？

<details>
<summary>看答案</summary>

一張訂單有多項商品，銷售單號會重複。暫存表的任務是原封不動收下 CSV，檢查留給正式表。

</details>

**第 2 題**：`orders` 為什麼同時記門市和店員？店員不是已經知道門市了嗎？

<details>
<summary>看答案</summary>

現在確實可以從店員推得門市。但店員日後可能調店，舊訂單仍然要算在當時的門市，所以訂單保留自己的 `store_id`。這和專案 5 的成交單價是同樣的想法。

</details>

## 🤖 問 AI 助教

> 這是我手寫的 PostgreSQL 資料表：（貼上你的 SQL）。請檢查同名會員、散客訂單和店員調店時的情況能不能正確記錄。有問題的話給我提示，不要直接重寫。

## ✅ 過關檢查

- [ ] 七張表的欄位數和講義相同
- [ ] 同名會員和散客訂單都能成功新增
- [ ] 八列有問題的資料都被擋下，我能說出原因
- [ ] 已執行含 `RESTART IDENTITY` 的 `TRUNCATE`，六張正式表都是 0 筆

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：跨月資料與暫存表](./1_跨月資料與暫存表.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 3：AI 產生匯入腳本 ➡️](./3_AI產生匯入腳本.md) |
