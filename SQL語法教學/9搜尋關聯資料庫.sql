/* ==============================================================================
   單元 11：關聯資料庫單表與多表搜尋練功 (以 cafe_shop 為例)
   
   【學習指引】：
   請在 DBeaver 開啟 SQL 編輯器，先確認已執行過 cafe_shop.sql，接著依序執行下方查詢：
   ============================================================================== */

-- 1. 取得全台灣所有門市清單
SELECT store_id AS 門市代碼, name AS 門市名稱, city AS 縣市, phone AS 聯絡電話
FROM stores;

-- 2. 取得所有在售商品，按售價由低到高排序
SELECT product_id, name, price, cost
FROM products
ORDER BY price ASC;

-- 3. 取得售價前 3 高的旗艦單品 (TOP 3)
SELECT name AS 頂級品項, price AS 售價
FROM products
ORDER BY price DESC
LIMIT 3;

-- 4. 取得顧客在訂單中使用的所有「不重複付款方式」 (DISTINCT)
SELECT DISTINCT payment_method AS 付款方式
FROM orders;

-- 5. 跨表查詢：查詢每位員工所屬的門市名稱 (二表 JOIN)
SELECT 
    s.name AS 門市名稱,
    e.name AS 員工姓名,
    e.position AS 職稱,
    e.salary AS 月薪
FROM staff e
JOIN stores s ON e.store_id = s.store_id
ORDER BY s.store_id, e.salary DESC;

-- 6. 跨表查詢：查詢每項商品所屬的分類名稱 (二表 JOIN)
SELECT 
    c.name AS 分類名稱,
    p.name AS 商品名稱,
    p.price AS 售價
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY c.category_id, p.price ASC;
