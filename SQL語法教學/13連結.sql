/* 進階-7｜綜合連結：一張報表跨四張表
   講義（含說明、執行結果、練習題）：13連結.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 把明細接回完整報表
SELECT
    o.order_date AS 日期,
    s.name       AS 門市,
    e.name       AS 經手,
    p.name       AS 商品,
    i.quantity   AS 數量,
    i.quantity * i.unit_price AS 小計
FROM order_items i
JOIN orders o   ON i.order_id = o.order_id
JOIN stores s   ON o.store_id = s.store_id
JOIN staff e    ON o.staff_id = e.staff_id
JOIN products p ON i.product_id = p.product_id
WHERE o.status = '已完成'
  AND o.order_date BETWEEN '2024-03-01' AND '2024-03-31'
ORDER BY o.order_date, o.order_id, p.product_id
LIMIT 5;

-- ▼ 2. 會員是散客怎麼辦？
SELECT '用 JOIN' AS 寫法, COUNT(*) AS 訂單數
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
UNION ALL
SELECT '用 LEFT JOIN', COUNT(*)
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- ▼ 3. 陷阱：條件放 ON 還是 WHERE？
INSERT INTO stores (name, address, region)
VALUES ('台南西門店', '台南市中西區西門路一段', '南部');

-- ▼ 3. 陷阱：條件放 ON 還是 WHERE？
SELECT s.name AS 門市, COUNT(o.order_id) AS 三月訂單數
FROM stores s
LEFT JOIN orders o ON s.store_id = o.store_id
WHERE o.order_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY s.store_id, s.name
ORDER BY s.store_id;

-- ▼ 3. 陷阱：條件放 ON 還是 WHERE？
SELECT s.name AS 門市, COUNT(o.order_id) AS 三月訂單數
FROM stores s
LEFT JOIN orders o
       ON s.store_id = o.store_id
      AND o.order_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY s.store_id, s.name
ORDER BY s.store_id;

-- ▼ 4. 從業績看員工
SELECT
    s.name AS 門市,
    e.name AS 員工,
    e.title AS 職稱,
    COUNT(DISTINCT o.order_id) AS 訂單數,
    SUM(i.quantity * i.unit_price) AS 業績
FROM staff e
JOIN stores s ON e.store_id = s.store_id
JOIN orders o ON e.staff_id = o.staff_id AND o.status = '已完成'
JOIN order_items i ON o.order_id = i.order_id
GROUP BY s.store_id, s.name, e.staff_id, e.name, e.title
ORDER BY 業績 DESC
LIMIT 5;
