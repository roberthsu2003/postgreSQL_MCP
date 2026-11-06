/* 進階-4｜聚合與分組：SQL 版的樞紐分析表
   講義（含說明、執行結果、練習題）：10聚合函式.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 五個基本函式
SELECT
    COUNT(*)            AS 員工數,
    SUM(salary)         AS 月薪總額,
    ROUND(AVG(salary))  AS 平均月薪,
    MAX(salary)         AS 最高月薪,
    MIN(salary)         AS 最低月薪
FROM staff;

-- ▼ COUNT(*) 和 COUNT(欄位) 不一樣
SELECT
    COUNT(*)                    AS 全部訂單,
    COUNT(customer_id)          AS 有會員的訂單,
    COUNT(DISTINCT customer_id) AS 來消費過的會員人數
FROM orders;

-- ▼ 2. GROUP BY：分組計算
SELECT title AS 職稱, COUNT(*) AS 人數, ROUND(AVG(salary)) AS 平均月薪
FROM staff
GROUP BY title
ORDER BY 平均月薪 DESC;

-- ▼ 2. GROUP BY：分組計算（故意示範錯誤，要體驗時請拿掉註解）
-- SELECT title, name, COUNT(*)
-- FROM staff
-- GROUP BY title;

-- ▼ 3. 回答王經理：各門市業績排名
SELECT
    s.name AS 門市,
    COUNT(DISTINCT o.order_id) AS 訂單數,
    SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name
ORDER BY 營業額 DESC;

-- ▼ 4. 跨月分析：再也不用開三個 Excel
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS 月份,
    SUM(i.quantity * i.unit_price)   AS 營業額
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY 月份;

-- ▼ 5. HAVING：篩選分組後的結果
SELECT p.name AS 商品, SUM(i.quantity) AS 銷量
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN orders o ON i.order_id = o.order_id
WHERE o.status = '已完成'
GROUP BY p.name
HAVING SUM(i.quantity) > 60
ORDER BY 銷量 DESC;

-- ▼ 6. 找忠實顧客：三個月都來消費
SELECT
    c.name AS 會員,
    COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) AS 消費月份數,
    SUM(i.quantity * i.unit_price) AS 累計消費
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) = 3
ORDER BY 累計消費 DESC
LIMIT 5;

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：expense_tracker
-- ======================================================

-- ▼ 7. 換個部門也一樣
SELECT
    d.name AS 部門,
    COUNT(*) AS 報銷筆數,
    SUM(x.amount) AS 已撥款總額
FROM expense_claims x
JOIN expense_employees e   ON x.emp_id = e.emp_id
JOIN expense_departments d ON e.dept_id = d.dept_id
WHERE x.status = '已撥款'
GROUP BY d.name
ORDER BY 已撥款總額 DESC;

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：hr_attendance
-- ======================================================

-- ▼ 7. 換個部門也一樣
SELECT
    e.name AS 員工,
    COUNT(*) AS 出勤天數,
    SUM(a.overtime_hours) AS 總加班時數,
    COUNT(*) FILTER (WHERE a.is_late) AS 遲到次數
FROM hr_attendance_records a
JOIN hr_employees e ON a.emp_id = e.emp_id
GROUP BY e.emp_id, e.name
ORDER BY 總加班時數 DESC;
