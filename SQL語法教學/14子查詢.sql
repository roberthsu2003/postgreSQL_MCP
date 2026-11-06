/* 進階-8｜子查詢：查詢裡面再查詢
   講義（含說明、執行結果、練習題）：14子查詢.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 回傳單一值：當成條件比較
SELECT name, salary
FROM staff
WHERE salary = (SELECT MAX(salary) FROM staff);

-- ▼ 1. 回傳單一值：當成條件比較
SELECT name, title, salary
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff)
ORDER BY salary DESC;

-- ▼ 2. 回傳多筆：配 IN
SELECT name, title
FROM staff
WHERE store_id IN (SELECT store_id FROM stores WHERE region = '北部')
ORDER BY store_id, staff_id
LIMIT 4;

-- ▼ 3. 放在 FROM：先算一張暫時的表
SELECT COUNT(*) AS 高於平均的訂單數, ROUND(AVG(總額)) AS 這些訂單的平均
FROM (
    SELECT order_id, SUM(quantity * unit_price) AS 總額
    FROM order_items
    GROUP BY order_id
) AS 訂單金額
WHERE 總額 > (
    SELECT AVG(總額)
    FROM (
        SELECT SUM(quantity * unit_price) AS 總額
        FROM order_items
        GROUP BY order_id
    ) AS 平均用
);

-- ▼ 3. 放在 FROM：先算一張暫時的表
WITH 訂單金額 AS (
    SELECT order_id, SUM(quantity * unit_price) AS 總額
    FROM order_items
    GROUP BY order_id
)
SELECT COUNT(*) AS 高於平均的訂單數, ROUND(AVG(總額)) AS 這些訂單的平均
FROM 訂單金額
WHERE 總額 > (SELECT AVG(總額) FROM 訂單金額);

-- ▼ 4. 每個分類最貴的商品：多欄位比對
SELECT c.name AS 分類, p.name AS 商品, p.price AS 售價
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE (p.category_id, p.price) IN (
    SELECT category_id, MAX(price)
    FROM products
    GROUP BY category_id
)
ORDER BY p.price DESC;

-- ▼ 5. EXISTS：只問「有沒有」
SELECT e.name
FROM staff e
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.staff_id = e.staff_id
      AND o.order_date = '2024-02-14'
)
ORDER BY e.staff_id;

-- ▼ 6. 大坑：NOT IN 遇到 NULL
INSERT INTO customers (name, phone, gender, joined_on)
VALUES ('新來的', '0900-000-001', '女', '2024-04-01');

-- ▼ 6. 大坑：NOT IN 遇到 NULL
SELECT name
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM orders);

-- ▼ 6. 大坑：NOT IN 遇到 NULL
SELECT c.name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：expense_tracker
-- ======================================================

-- ▼ 7. 其他部門也用得上
SELECT c.name AS 類別, x.claim_date AS 日期, x.amount AS 金額, x.description AS 說明
FROM expense_claims x
JOIN expense_categories c ON x.category_id = c.category_id
WHERE x.amount > (SELECT AVG(amount) FROM expense_claims)
ORDER BY x.amount DESC
LIMIT 3;

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：assets_inventory
-- ======================================================

-- ▼ 7. 其他部門也用得上
SELECT name AS 品項, current_stock AS 庫存, safety_stock AS 安全存量
FROM assets
WHERE asset_id IN (
    SELECT asset_id FROM assets WHERE current_stock < safety_stock
)
ORDER BY name;
