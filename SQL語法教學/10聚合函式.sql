/* ==========================================
   聚合函式 (Aggregate Functions) 與 GROUP BY / HAVING
   ========================================== */

/* 1. 基本聚合函式 (以 employee 表為例) */

-- 取得員工人數
SELECT COUNT(*) FROM employee;

-- 取得所有出生於 1970-01-01 之後的女性員工人數
SELECT COUNT(*)
FROM employee
WHERE birth_date > '1970-01-01' AND sex = 'F';

-- 取得所有員工的平均薪水
SELECT AVG(salary) FROM employee;

-- 取得所有員工薪水的總和
SELECT SUM(salary) FROM employee;

-- 取得最高的薪水
SELECT MAX(salary) FROM employee;

-- 想知道是「哪一位」員工領最高薪，要用子查詢 (請參考 14子查詢.sql)
SELECT name, salary
FROM employee
WHERE salary = (SELECT MAX(salary) FROM employee);

-- 取得最低的薪水
SELECT MIN(salary) FROM employee;

/* ==========================================
   2. 實務練功：GROUP BY 分組與 HAVING 過濾
   (以繁體中文範例庫 cafe_shop 為例)
   ========================================== */

-- 【實戰 1：各門市 2024 年第一季銷售總金額】
SELECT 
    s.name AS 門市名稱,
    COUNT(DISTINCT o.order_id) AS 總訂單數,
    SUM(i.quantity * i.unit_price) AS 總營業額
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name
ORDER BY 總營業額 DESC;

-- 【實戰 2：跨月份營業額統計 (按門市與月份分組)】
SELECT 
    s.name AS 門市名稱,
    TO_CHAR(o.order_date, 'YYYY-MM') AS 月份,
    SUM(i.quantity * i.unit_price) AS 月營業額
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name, TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY s.name, 月份 ASC;

-- 【實戰 3：使用 HAVING 篩選熱銷商品 (總銷量大於 50 份)】
SELECT 
    p.name AS 商品名稱,
    c.name AS 所屬分類,
    SUM(i.quantity) AS 累計售出數量,
    SUM(i.quantity * i.unit_price) AS 貢獻營業額
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.name, c.name
HAVING SUM(i.quantity) >= 50
ORDER BY 累計售出數量 DESC;

-- 【實戰 4：使用 HAVING 抓出忠誠 VIP (在 1~3 月中至少在 2 個不同月份消費過)】
SELECT 
    c.customer_id AS 會員ID,
    c.name AS 會員姓名,
    c.phone AS 電話,
    COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) AS 消費月份數,
    SUM(i.quantity * i.unit_price) AS 累計消費金額
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY c.customer_id, c.name, c.phone
HAVING COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) >= 2
ORDER BY 累計消費金額 DESC;

/* ==========================================
   3. 職場跨部門實戰：會計與人資範例庫
   ========================================== */

-- 【實戰 5：會計報銷 (expense_tracker) - 各部門累計支出與預算使用率】
-- 需先在 DBeaver 執行 expense_tracker.sql
SELECT 
    d.name AS 部門名稱,
    b.budget_amount AS 年度預算,
    COALESCE(SUM(c.total_amount), 0) AS 累計核准支出,
    ROUND((COALESCE(SUM(c.total_amount), 0) / b.budget_amount) * 100, 2) AS 預算使用百分比
FROM departments d
JOIN budgets b ON d.department_id = b.department_id AND b.year = 2024
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN expense_claims c ON e.employee_id = c.employee_id AND c.status = '已撥款'
GROUP BY d.department_id, d.name, b.budget_amount
ORDER BY 預算使用百分比 DESC;

-- 【實戰 6：人資差勤 (hr_attendance) - 員工總加班時數與異常打卡次數】
-- 需先在 DBeaver 執行 hr_attendance.sql
SELECT 
    e.name AS 員工姓名,
    COUNT(a.log_id) AS 出勤天數,
    SUM(a.overtime_hours) AS 總加班時數,
    COUNT(CASE WHEN a.status = '遲到' THEN 1 END) AS 遲到次數,
    COUNT(CASE WHEN a.status = '早退' THEN 1 END) AS 早退次數
FROM employees e
JOIN attendance_logs a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.name
ORDER BY 總加班時數 DESC;
