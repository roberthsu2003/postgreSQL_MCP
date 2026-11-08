-- ==============================================================
-- 網路商店訂單表：完整版（救援用）
-- 注意：這份會刪掉現有的四張資料表，你手寫的表和資料都會被取代
-- 只有卡關、或想把資料恢復成初始狀態時才執行
-- ==============================================================
BEGIN;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    city        VARCHAR(10),
    email       VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE,
    category   VARCHAR(20) NOT NULL,
    price      INT NOT NULL CHECK (price >= 0)
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    order_date     DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('信用卡', 'LINE Pay', '貨到付款')),
    status         VARCHAR(10) NOT NULL DEFAULT '處理中' CHECK (status IN ('處理中', '已完成', '已取消'))
);

CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

-- 1. 會員（Excel 沒有會員編號，用信箱辨識，依出現順序編號）
INSERT INTO customers (customer_id, name, city, email) VALUES
(1, '陳小華', '台北市', 'hua@example.com'),
(2, '林志明', '新北市', 'ming@example.com'),
(3, '黃雅婷', '台中市', 'ting@example.com'),
(4, '周美玲', '高雄市', 'mei@example.com'),
(5, '張大同', '高雄市', 'datong@example.com');

-- 2. 商品（price 是目前售價，也就是 Excel 中最後一次出現的單價）
INSERT INTO products (product_id, name, category, price) VALUES
(1, '保溫鋼杯', '生活用品', 490),
(2, '快充行動電源', '3C配件', 890),
(3, '人體工學滑鼠墊', '文具', 320),
(4, '陶瓷咖啡杯', '生活用品', 280),
(5, '無線藍牙耳機', '3C配件', 1190),
(6, '筆記本組合', '文具', 180),
(7, '輕量登山背包', '戶外休閒', 1580);

-- 3. 手動指定過編號，要告訴自動編號從哪裡接著編
SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), 5);
SELECT setval(pg_get_serial_sequence('products', 'product_id'), 7);

-- 4. 訂單
INSERT INTO orders (order_id, customer_id, order_date, payment_method, status) VALUES
(1001, 1, '2024-03-01', '信用卡', '已完成'),
(1002, 2, '2024-03-02', 'LINE Pay', '已完成'),
(1003, 1, '2024-03-05', '貨到付款', '已完成'),
(1004, 3, '2024-03-08', '信用卡', '已取消'),
(1005, 4, '2024-03-10', '信用卡', '已完成'),
(1006, 2, '2024-03-12', 'LINE Pay', '已完成'),
(1007, 3, '2024-03-18', '信用卡', '已完成'),
(1008, 1, '2024-03-20', '貨到付款', '已完成'),
(1009, 4, '2024-03-25', '信用卡', '處理中'),
(1010, 2, '2024-03-28', 'LINE Pay', '處理中');

-- 5. 訂單明細（unit_price 是當時的成交單價）
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1001, 1, 2, 450),
(1001, 2, 1, 890),
(1002, 3, 1, 320),
(1003, 4, 2, 280),
(1004, 5, 1, 1290),
(1005, 1, 1, 450),
(1005, 6, 3, 180),
(1006, 5, 1, 1290),
(1006, 3, 2, 320),
(1007, 1, 1, 490),
(1007, 4, 1, 280),
(1008, 5, 1, 1190),
(1008, 2, 1, 890),
(1009, 1, 2, 490),
(1009, 6, 1, 180),
(1010, 5, 1, 1190);

COMMIT;
