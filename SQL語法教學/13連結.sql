/* ==============================================================================
   單元 14：多表連接查詢實戰 (JOIN / INNER JOIN / LEFT JOIN)
   (以繁體中文範例庫 cafe_shop 為例)
   ============================================================================== */

-- 1. INNER JOIN (內連接)：取得每位員工姓名與所屬門市名稱
-- 只會列出雙方都有對應到的資料
SELECT 
    e.staff_id AS 員工代碼,
    e.name AS 員工姓名,
    e.position AS 職位,
    s.name AS 門市名稱,
    s.city AS 門市縣市
FROM staff e
INNER JOIN stores s ON e.store_id = s.store_id
ORDER BY s.store_id, e.staff_id;

-- 2. 指定表格別名 (AS)，讓欄位來源一目了然
SELECT 
    p.product_id AS 商品編號,
    p.name AS 商品名稱,
    c.name AS 分類名稱,
    p.price AS 售價
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY c.category_id, p.price DESC;

-- 3. LEFT JOIN (左外連接)：列出所有門市及其 2024 年 3 月的訂單
-- 即使某些新門市在 3 月尚未產生任何訂單，門市名稱依然會被完整保留 (訂單欄位呈現 NULL)
SELECT 
    s.name AS 門市名稱,
    s.city AS 城市,
    o.order_id AS 訂單編號,
    o.order_date AS 銷售日期,
    o.status AS 狀態
FROM stores s
LEFT JOIN orders o ON s.store_id = o.store_id AND o.order_date BETWEEN '2024-03-01' AND '2024-03-31'
ORDER BY s.store_id, o.order_date ASC;

-- 4. 跨 3 表連接：查詢訂單明細包含的商品名稱與單價
SELECT 
    o.order_id AS 訂單編號,
    o.order_date AS 日期,
    s.name AS 門市,
    p.name AS 商品,
    i.quantity AS 數量,
    i.unit_price AS 單價,
    (i.quantity * i.unit_price) AS 小計
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
JOIN stores s ON o.store_id = s.store_id
JOIN products p ON i.product_id = p.product_id
LIMIT 20;
