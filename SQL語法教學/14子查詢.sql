/* ==========================================
   子查詢 (Subquery) 教學與實戰
   ========================================== */

/* 1. 基本子查詢觀念 (以公司員工表為例) */

-- 找出研發部門的經理名字 (單值子查詢)
SELECT name
FROM employee
WHERE emp_id = (
    SELECT manager_id
    FROM branch
    WHERE branch_name = '研發'
);

-- 找出對單一位客戶銷售金額達到 50000 以上的員工名字
-- 子查詢回傳多筆資料時，必須使用 IN (...)
SELECT name
FROM employee
WHERE emp_id IN (
    SELECT emp_id
    FROM works_with
    WHERE total_sales >= 50000
);

/* ==========================================
   2. 實務練功：連鎖門市與電商子查詢實戰
   (以繁體中文範例庫 cafe_shop / shop 為例)
   ========================================== */

-- 【實戰 1：找出單價最高與最低的商品 (單值子查詢)】
SELECT product_id, name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products)
   OR price = (SELECT MIN(price) FROM products);

-- 【實戰 2：找出「消費總金額高於全體平均」的優質訂單】
SELECT 
    order_id,
    SUM(quantity * unit_price) AS 訂單金額
FROM order_items
GROUP BY order_id
HAVING SUM(quantity * unit_price) > (
    -- 子查詢：計算所有訂單的平均金額
    SELECT AVG(order_total)
    FROM (
        SELECT SUM(quantity * unit_price) AS order_total
        FROM order_items
        GROUP BY order_id
    ) AS sub
)
ORDER BY 訂單金額 DESC;

-- 【實戰 3：各商品分類中「單價最高」的代表商品 (多欄位複合子查詢)】
SELECT c.name AS 分類名稱, p.name AS 商品名稱, p.price AS 單價
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE (p.category_id, p.price) IN (
    SELECT category_id, MAX(price)
    FROM products
    GROUP BY category_id
)
ORDER BY p.price DESC;

-- 【實戰 4：使用 NOT IN / NOT EXISTS 找出從未被購買過的商品】
SELECT product_id, name, price
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id 
    FROM order_items
);

/* ==========================================
   3. 職場跨部門實戰：會計與總務範例庫子查詢
   ========================================== */

-- 【實戰 5：會計報銷 (expense_tracker) - 找出單筆報銷金額大於平均值的費用明細】
-- 需先在 DBeaver 執行 expense_tracker.sql
SELECT 
    i.item_id,
    c.name AS 費用類別,
    i.expense_date AS 支出日期,
    i.amount AS 金額,
    i.description AS 說明
FROM expense_items i
JOIN expense_categories c ON i.category_id = c.category_id
WHERE i.amount > (
    SELECT AVG(amount) FROM expense_items
)
ORDER BY i.amount DESC;

-- 【實戰 6：總務資產 (assets_inventory) - 找出「借用天數大於預計歸還期」的逾期未還資產】
-- 需先在 DBeaver 執行 assets_inventory.sql
SELECT 
    l.lending_id,
    a.asset_code AS 資產編號,
    a.name AS 設備名稱,
    l.borrower_name AS 借用人,
    l.lend_date AS 借用日期,
    l.due_date AS 應歸還日,
    (CURRENT_DATE - l.due_date) AS 逾期天數
FROM asset_lendings l
JOIN assets a ON l.asset_id = a.asset_id
WHERE l.return_date IS NULL 
  AND l.due_date < CURRENT_DATE
ORDER BY 逾期天數 DESC;
