-- =====================================================================
-- 🚀 巨量資料產生器 (PostgreSQL generate_series)
-- 目的: 體驗 10 萬筆訂單查詢效能與索引 (INDEX) 威力，免下載、免匯入幾十 MB 檔案！
--
-- 執行方式:
--   請先確保已執行過 cafe_shop.sql 建立好基本資料表。
--   在 Supabase SQL Editor 或 DBeaver 中直接執行本檔，約 1~2 秒即可瞬間產生 10 萬筆明細。
-- =====================================================================

DO $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    cur_orders INT;
BEGIN
    SELECT COUNT(*) INTO cur_orders FROM orders;
    IF cur_orders = 0 THEN
        RAISE EXCEPTION '請先執行 cafe_shop.sql 建立基礎門市與商品資料！';
    END IF;

    RAISE NOTICE '⚡ 開始動態生成 50,000 筆訂單與 100,000 筆商品明細...';
    start_time := clock_timestamp();

    -- 1. 產生 50,000 筆延伸訂單 (日期涵蓋 2024 全年)
    INSERT INTO orders (order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
    SELECT 
        DATE '2024-01-01' + (TRUNC(random() * 365))::INT AS order_date,
        (TIME '07:30:00' + (TRUNC(random() * 46800))::INT * INTERVAL '1 second')::TIME AS order_time,
        (TRUNC(random() * 5) + 1)::INT AS store_id,
        (TRUNC(random() * 12) + 1)::INT AS staff_id,
        CASE WHEN random() < 0.75 THEN (TRUNC(random() * 50) + 1)::INT ELSE NULL END AS customer_id,
        (ARRAY['LINE Pay', '信用卡', '現金', '街口支付'])[floor(random() * 4 + 1)] AS payment_method,
        (ARRAY['已完成', '已完成', '已完成', '已退款'])[floor(random() * 4 + 1)] AS status
    FROM generate_series(1, 50000);

    -- 2. 為最新產生的這批訂單，隨機配發 1~3 項商品明細 (合計約 10 萬列)
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    SELECT 
        o.order_id,
        p.product_id,
        (TRUNC(random() * 3) + 1)::INT AS quantity,
        p.price AS unit_price
    FROM (
        SELECT order_id FROM orders WHERE order_id > 490
    ) o
    CROSS JOIN LATERAL (
        SELECT product_id, price 
        FROM products 
        ORDER BY random() 
        LIMIT (TRUNC(random() * 2) + 1)::INT
    ) p
    ON CONFLICT (order_id, product_id) DO NOTHING;

    end_time := clock_timestamp();
    RAISE NOTICE '🎉 完成！總耗時: %', (end_time - start_time);
END $$;

-- 驗證成果
SELECT 
    (SELECT COUNT(*) FROM orders) AS 總訂單筆數,
    (SELECT COUNT(*) FROM order_items) AS 總明細筆數,
    (SELECT MIN(order_date) FROM orders) AS 起始日期,
    (SELECT MAX(order_date) FROM orders) AS 結束日期;
