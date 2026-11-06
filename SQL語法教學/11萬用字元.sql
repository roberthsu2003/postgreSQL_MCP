/* 進階-5｜模糊搜尋：只記得一部分也找得到
   講義（含說明、執行結果、練習題）：11萬用字元.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 三種最常用的寫法
SELECT name, price
FROM products
WHERE name LIKE '%拿鐵%';

-- ▼ 1. 三種最常用的寫法
SELECT name, address
FROM stores
WHERE address LIKE '台北市%';

-- ▼ 1. 三種最常用的寫法
SELECT name FROM products WHERE name LIKE '%咖啡';

-- ▼ 2. % 的位置有差
SELECT COUNT(*) AS 開頭是拿鐵 FROM products WHERE name LIKE '拿鐵%';

-- ▼ 3. 底線：指定字數
SELECT DISTINCT name
FROM customers
WHERE name LIKE '陳__';

-- ▼ 4. ILIKE：不分大小寫
SELECT DISTINCT payment_method, 'LIKE' AS 方法 FROM orders WHERE payment_method LIKE 'line%'
UNION ALL
SELECT DISTINCT payment_method, 'ILIKE' FROM orders WHERE payment_method ILIKE 'line%';
