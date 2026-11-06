/* 進階-2｜關聯新增：順序錯一步就報錯
   講義（含說明、執行結果、練習題）：8新增關聯資料庫資料.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_lab
-- ======================================================

-- ▼ 1. 順序錯了會怎樣（故意示範錯誤，要體驗時請拿掉註解）
-- INSERT INTO staff (name, store_id, title, hired_on, salary)
-- VALUES ('張志明', 1, '店長', '2021-03-01', 52000);

-- ▼ 2. 正確順序：用交易包起來
BEGIN;

-- 第一步：獨立的主檔
INSERT INTO stores (store_id, name, address, region, phone) VALUES
    (1, '台北信義店', '台北市信義區忠孝東路五段', '北部', '02-2720-1111'),
    (2, '台中逢甲店', '台中市西屯區逢甲路',       '中部', '04-2451-4444');

INSERT INTO categories (category_id, name) VALUES
    (1, '義式咖啡'),
    (2, '現烤點心');

INSERT INTO customers (customer_id, name, phone, gender, joined_on) VALUES
    (1, '曾怡君', '0973-000-001', '女', '2023-03-27');

-- 第二步：依賴主檔的資料
INSERT INTO staff (staff_id, name, store_id, title, hired_on, salary) VALUES
    (1, '張志明', 1, '店長', '2021-03-01', 52000),
    (2, '陳美玲', 1, '正職咖啡師', '2022-07-15', 38000);

INSERT INTO products (product_id, category_id, name, price, cost, launched_on) VALUES
    (101, 1, '經典拿鐵',     95, 35, '2023-01-01'),
    (102, 2, '法式經典可頌', 65, 25, '2023-01-01');

-- 第三步：訂單主檔
INSERT INTO orders (order_id, order_date, order_time, store_id, staff_id, customer_id, payment_method, status) VALUES
    (1001, '2024-03-01', '09:30', 1, 2, 1,    '信用卡', '已完成'),
    (1002, '2024-03-01', '10:15', 1, 2, NULL, '現金',   '已完成');  -- 散客

-- 第四步：訂單明細
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1001, 101, 2, 95),  -- 拿鐵 2 杯
    (1001, 102, 1, 65),  -- 可頌 1 個
    (1002, 101, 1, 95);

COMMIT;

-- ▼ 2. 正確順序：用交易包起來
SELECT
    o.order_id AS 訂單,
    COALESCE(c.name, '散客') AS 顧客,
    p.name AS 商品,
    i.quantity AS 數量,
    i.quantity * i.unit_price AS 小計
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
JOIN products p ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id, p.product_id;

-- ▼ 3. 陷阱：手動指定編號後，自動編號會撞號（故意示範錯誤，要體驗時請拿掉註解）
-- INSERT INTO stores (name, address, region)
-- VALUES ('高雄巨蛋店', '高雄市左營區博愛二路', '南部');

-- ▼ 3. 陷阱：手動指定編號後，自動編號會撞號
SELECT setval('stores_store_id_seq', (SELECT MAX(store_id) FROM stores));

INSERT INTO stores (name, address, region)
VALUES ('高雄巨蛋店', '高雄市左營區博愛二路', '南部')
RETURNING store_id, name;

-- ▼ 4. 更好的寫法：讓資料庫編號，再拿回來用
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));

INSERT INTO orders (order_date, order_time, store_id, staff_id, payment_method, status)
VALUES ('2024-03-02', '11:00', 1, 2, 'LINE Pay', '已完成')
RETURNING order_id;

-- ▼ 4. 更好的寫法：讓資料庫編號，再拿回來用
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1003, 102, 2, 65);

-- ▼ 5. 交易的威力：全有或全無
BEGIN;

INSERT INTO orders (order_date, order_time, store_id, staff_id, payment_method, status)
VALUES ('2024-03-03', '12:00', 1, 2, '現金', '已完成');

-- ▼ 5. 交易的威力：全有或全無（故意示範錯誤，要體驗時請拿掉註解）
-- INSERT INTO order_items (order_id, product_id, quantity, unit_price)
-- VALUES (1004, 999, 1, 95);

-- ▼ 5. 交易的威力：全有或全無
ROLLBACK;

SELECT COUNT(*) AS 訂單筆數 FROM orders;
