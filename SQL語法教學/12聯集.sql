/* 進階-6｜聯集：把兩份名單上下疊起來
   講義（含說明、執行結果、練習題）：12聯集.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 基本用法
SELECT name AS 名稱, phone AS 電話, '門市' AS 類別
FROM stores
UNION ALL
SELECT name, phone, '會員'
FROM customers
ORDER BY 類別 DESC, 名稱
LIMIT 7;

-- ▼ 2. UNION 和 UNION ALL
SELECT 'UNION' AS 寫法, COUNT(*) AS 筆數
FROM (
    SELECT region FROM stores
    UNION
    SELECT region FROM stores
) AS a
UNION ALL
SELECT 'UNION ALL', COUNT(*)
FROM (
    SELECT region FROM stores
    UNION ALL
    SELECT region FROM stores
) AS b;

-- ▼ 3. 兩條規則（故意示範錯誤，要體驗時請拿掉註解）
-- SELECT name, phone FROM stores
-- UNION
-- SELECT name FROM customers;

-- ▼ 3. 兩條規則（故意示範錯誤，要體驗時請拿掉註解）
-- SELECT name FROM stores
-- UNION
-- SELECT customer_id FROM customers;

-- ▼ 4. 實用例子：業績總表加合計列
SELECT s.name AS 門市, SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name
UNION ALL
SELECT '★ 合計', SUM(i.quantity * i.unit_price)
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
ORDER BY 營業額;
