/* 進階-3｜關聯搜尋：從單表一路查到跨表
   講義（含說明、執行結果、練習題）：9搜尋關聯資料庫.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 問題 1：「全部門市的電話給我。」
SELECT store_id AS 編號, name AS 門市, region AS 區域, phone AS 電話
FROM stores;

-- ▼ 問題 2：「最貴的三項商品是什麼？」
SELECT name AS 商品, price AS 售價
FROM products
ORDER BY price DESC
LIMIT 3;

-- ▼ 問題 3：「客人都用什麼付款？」
SELECT DISTINCT payment_method AS 付款方式
FROM orders
ORDER BY payment_method;

-- ▼ 問題 4：「各門市有哪些員工？薪水多少？」
SELECT s.name AS 門市, e.name AS 員工, e.title AS 職稱, e.salary AS 月薪
FROM staff e
JOIN stores s ON e.store_id = s.store_id
ORDER BY s.store_id, e.salary DESC;

-- ▼ 問題 5：「茶飲類有哪些商品？」
SELECT p.name AS 商品, p.price AS 售價
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.name = '特調茶飲'
ORDER BY p.price;
