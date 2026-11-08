# 步驟 2｜手寫 DDL：建立會員、商品、訂單和明細

> 💻 DBeaver（資料庫：`online_shop`）｜ 🎯 學完你會：建立多對多的明細表，並設定刪除訂單時的連動規則

> 📚 先修：[進階-1 建立七張表](../../SQL語法教學/7創建關聯資料庫.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 1. 建立資料庫

```sql
CREATE DATABASE online_shop;
```

建好後，在 DBeaver 工具列把資料庫切換成 `online_shop`。

## 2. 建立四張表

順序是會員、商品、訂單，最後才是同時參照訂單和商品的明細。

```sql
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    city        VARCHAR(10),
    email       VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE,
    category   VARCHAR(20) NOT NULL,
    price      INT NOT NULL CHECK (price >= 0)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    order_date     DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('信用卡', 'LINE Pay', '貨到付款')),
    status         VARCHAR(10) NOT NULL DEFAULT '處理中' CHECK (status IN ('處理中', '已完成', '已取消'))
);

CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);
```

| 寫法 | 白話 |
|---|---|
| `ON DELETE CASCADE` | 訂單被刪除時，明細跟著刪除 |
| `PRIMARY KEY (order_id, product_id)` | 同一張訂單的同一項商品只能有一筆 |

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

確認四張表都建好了：

```sql
SELECT table_name AS 資料表, COUNT(*) AS 欄位數
FROM information_schema.columns
WHERE table_name IN ('customers', 'products', 'orders', 'order_items')
GROUP BY table_name
ORDER BY table_name;
```

**執行結果**

| 資料表 | 欄位數 |
|---|---:|
| customers | 4 |
| order_items | 4 |
| orders | 5 |
| products | 4 |

## 3. 測試保護機制

先放進一組正確的資料：

```sql
INSERT INTO customers (name, city, email) VALUES ('陳小華', '台北市', 'hua@example.com') RETURNING customer_id, name;
INSERT INTO products (name, category, price) VALUES ('保溫鋼杯', '生活用品', 450) RETURNING product_id, name;
INSERT INTO products (name, category, price) VALUES ('快充行動電源', '3C配件', 890) RETURNING product_id, name;
INSERT INTO orders VALUES (1001, 1, '2024-03-01', '信用卡', '已完成');
INSERT INTO order_items VALUES (1001, 1, 2, 450);
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：同一張訂單的同一項商品出現兩列
INSERT INTO order_items VALUES (1001, 1, 1, 450);

-- 第 2 列：數量是 0
INSERT INTO order_items VALUES (1001, 2, 0, 890);

-- 第 3 列：單價是負數
INSERT INTO order_items VALUES (1001, 2, 1, -100);

-- 第 4 列：沒有這張訂單
INSERT INTO order_items VALUES (9999, 1, 1, 450);

-- 第 5 列：商品表沒有「隱形商品」，這裡用不存在的編號 99 代表
INSERT INTO order_items VALUES (1001, 99, 1, 100);

-- 第 6 列：信箱已經被別的會員使用
INSERT INTO customers (name, city, email) VALUES ('冒名者', '台北市', 'hua@example.com');

-- 第 7 列：付款方式不在三種之內
INSERT INTO orders VALUES (1011, 1, '2024-04-01', '現金', '處理中');

-- 第 8 列：訂單狀態不在三種之內
INSERT INTO orders VALUES (1012, 1, '2024-04-01', '信用卡', '退貨中');
```

**執行結果：八句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "order_items_pkey"` | 兩欄主鍵 |
| 2 | `violates check constraint "order_items_quantity_check"` | `CHECK` |
| 3 | `violates check constraint "order_items_unit_price_check"` | `CHECK` |
| 4 | `violates foreign key constraint "order_items_order_id_fkey"` | 外來鍵 |
| 5 | `violates foreign key constraint "order_items_product_id_fkey"` | 外來鍵 |
| 6 | `duplicate key ... "customers_email_key"` | `UNIQUE` |
| 7 | `violates check constraint "orders_payment_method_check"` | `CHECK` |
| 8 | `violates check constraint "orders_status_check"` | `CHECK` |

再試試刪除還在使用的會員和商品：

```sql
DELETE FROM customers WHERE customer_id = 1;
DELETE FROM products WHERE product_id = 1;
```

**執行結果**：分別被 `orders_customer_id_fkey` 和 `order_items_product_id_fkey` 擋下。會員和商品不會因為被誤刪，讓訂單失去對象。

## 4. 清空測試資料

```sql
TRUNCATE order_items, orders, products, customers RESTART IDENTITY;
```

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "orders" does not exist` | 建表順序錯了，或連錯資料庫 | 依照講義順序建立，並檢查工具列 |
| `multiple primary keys ... not allowed` | 兩個欄位各寫了 `PRIMARY KEY` | 改成最後一行 `PRIMARY KEY (order_id, product_id)` |
| `cannot truncate a table referenced in a foreign key constraint` | 沒有把相關的表一起清空 | 四張表寫在同一句 `TRUNCATE` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：為什麼 `orders.order_id` 不用 `SERIAL`，`products.product_id` 卻要用？

<details>
<summary>看答案</summary>

Excel 已經有訂單編號，直接沿用；商品沒有編號，所以要由資料庫自動產生。

</details>

**第 2 題**：`order_items` 的兩個外來鍵，為什麼只有訂單設了 `ON DELETE CASCADE`？

<details>
<summary>看答案</summary>

明細離開訂單就沒有意義，所以訂單刪除時明細跟著刪除。商品還被訂單使用時不應該被刪掉，否則歷史訂單會失去商品資訊，所以維持預設的禁止刪除。

</details>

## 🤖 問 AI 助教

> 這是我手寫的四張 PostgreSQL 資料表：（貼上你的 SQL）。請檢查多對多的設計、外來鍵的刪除規則，以及商品調價時舊訂單金額會不會變。有問題的話給我提示，不要直接重寫。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：多對多與歷史價格](./1_多對多與歷史價格.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
