-- =====================================================================
-- 進階-11｜檢視表 VIEW：把常用查詢存成一張「虛擬表」
-- 資料庫：cafe_shop（第 6 節改用 cafe_perf）
-- 建議：一段一段選取後按 Ctrl/Cmd + Enter 執行，對照講義的執行結果
-- =====================================================================


-- ---------------------------------------------------------------------
-- 2. CREATE VIEW：把四表 JOIN 存起來
-- ---------------------------------------------------------------------
CREATE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- 像查資料表一樣查 VIEW
SELECT *
FROM v_order_details
WHERE 日期 = '2024-02-14'
ORDER BY 訂單編號, 商品;

-- VIEW 後面一樣可以接 WHERE、GROUP BY
SELECT 門市, SUM(小計) AS 營業額
FROM v_order_details
WHERE 狀態 = '已完成'
GROUP BY 門市
ORDER BY 營業額 DESC;


-- ---------------------------------------------------------------------
-- 3. VIEW 不存資料：原表一改，VIEW 立刻跟著變
-- ---------------------------------------------------------------------
BEGIN;

UPDATE stores SET name = '台北信義旗艦店' WHERE store_id = 1;

SELECT DISTINCT 門市
FROM v_order_details
ORDER BY 門市;

ROLLBACK;


-- ---------------------------------------------------------------------
-- 4. 修改與刪除 VIEW
-- ---------------------------------------------------------------------

-- ✅ 在最後面加欄位：可以
CREATE OR REPLACE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態,
    o.payment_method              AS 付款方式
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- ❌ 把欄位插在中間：會報錯 cannot change name of view column
CREATE OR REPLACE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_time                  AS 時間,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態,
    o.payment_method              AS 付款方式
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- ❌ 原表的欄位被 VIEW 用到，就不能直接刪
ALTER TABLE customers DROP COLUMN name;

-- 查這個 VIEW 依賴哪些資料表
SELECT DISTINCT table_name AS 用到的資料表
FROM information_schema.view_table_usage
WHERE view_name = 'v_order_details'
ORDER BY table_name;


-- ---------------------------------------------------------------------
-- 5. 用 VIEW 把敏感欄位藏起來，再交給 AI（MCP）
-- ---------------------------------------------------------------------
CREATE VIEW v_customer_public AS
SELECT
    customer_id                                   AS 會員編號,
    name                                          AS 姓名,
    LEFT(phone, 4) || '-***-' || RIGHT(phone, 3)  AS 電話,
    gender                                        AS 性別,
    joined_on                                     AS 加入日期
FROM customers;

SELECT * FROM v_customer_public ORDER BY 會員編號 LIMIT 3;

CREATE VIEW v_staff_directory AS
SELECT s.name AS 姓名, st.name AS 門市, s.title AS 職稱
FROM staff s
JOIN stores st ON s.store_id = st.store_id;

-- 建立一個「只能看 VIEW」的帳號，給 MCP 連線使用
CREATE ROLE mcp_reader LOGIN PASSWORD 'change_me_123';
GRANT CONNECT ON DATABASE cafe_shop TO mcp_reader;
GRANT USAGE ON SCHEMA public TO mcp_reader;
GRANT SELECT ON v_order_details, v_customer_public, v_staff_directory TO mcp_reader;

-- 模擬用 mcp_reader 身分查詢
SET ROLE mcp_reader;

SELECT * FROM v_staff_directory LIMIT 3;   -- ✅ 可以
SELECT * FROM customers LIMIT 3;           -- ❌ permission denied
SELECT salary FROM staff LIMIT 3;          -- ❌ permission denied

RESET ROLE;


-- ---------------------------------------------------------------------
-- 6. 物化檢視表 MATERIALIZED VIEW（請切換到 cafe_perf）
-- ---------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT s.name AS 門市,
       DATE_TRUNC('month', o.order_date)::date AS 月份,
       SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s      ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name, 月份;

CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT s.name AS 門市,
       DATE_TRUNC('month', o.order_date)::date AS 月份,
       SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s      ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name, 月份;

EXPLAIN ANALYZE
SELECT * FROM mv_monthly_sales;

SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';

-- 新增一筆 12 月大訂單：美式咖啡 100 杯，每杯 70 元
WITH new_order AS (
    INSERT INTO orders (order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
    VALUES ('2024-12-31', '10:00', 1, 1, NULL, '現金', '已完成')
    RETURNING order_id
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT order_id, 1, 100, 70 FROM new_order;

-- 物化檢視表還是舊數字
SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';

-- 重新整理後才會更新
REFRESH MATERIALIZED VIEW mv_monthly_sales;

SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';


-- ---------------------------------------------------------------------
-- 8. 其他部門也用得上
-- ---------------------------------------------------------------------

-- 會計（expense_tracker）：待處理報銷總表
CREATE VIEW v_pending_claims AS
SELECT x.claim_id AS 單號, x.claim_date AS 日期, e.name AS 申請人,
       c.name AS 類別, x.amount AS 金額, x.status AS 狀態
FROM expense_claims x
JOIN expense_employees e  ON x.emp_id = e.emp_id
JOIN expense_categories c ON x.category_id = c.category_id
WHERE x.status IN ('待審核', '待撥款');

SELECT * FROM v_pending_claims ORDER BY 日期;

-- 總務（assets_inventory）：需要補貨的品項
CREATE VIEW v_low_stock AS
SELECT name AS 品項, current_stock AS 庫存, safety_stock AS 安全存量,
       safety_stock - current_stock AS 至少要補
FROM assets
WHERE current_stock < safety_stock;

SELECT * FROM v_low_stock ORDER BY 至少要補 DESC, 品項;


-- ---------------------------------------------------------------------
-- 收拾（回到 cafe_shop 執行）：把這一課建立的東西刪掉
-- ---------------------------------------------------------------------
-- DROP OWNED BY mcp_reader;
-- DROP ROLE mcp_reader;
-- DROP VIEW v_order_details, v_customer_public, v_staff_directory;
