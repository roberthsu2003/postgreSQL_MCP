/* ==============================================================================
   單元 10：關聯資料庫資料寫入實戰 (以 cafe_shop 為例)
   
   【核心學習目標】：
   1. 體會外來鍵相依性：必須遵守「先父表後子表」的順序。
   2. 示範常見錯誤：直接插入不存在的外來鍵 ID 會被資料庫擋下。
   3. 運用交易區塊 (BEGIN ... COMMIT) 確保整批業務資料完整寫入。
   ============================================================================== */

BEGIN; -- 開啟交易

-- 【錯誤示範】：若尚未建立門市 1，直接新增員工會出錯：
-- INSERT INTO staff (name, store_id, position, salary) VALUES ('陳小華', 1, '店長', 45000);
-- 🛑 錯誤訊息：violates foreign key constraint "staff_store_id_fkey"

-- ------------------------------------------------------------------------------
-- 1. 正確第一步：建立基礎父表資料 (門市、分類、會員)
-- ------------------------------------------------------------------------------
INSERT INTO stores (store_id, name, city, address, phone) VALUES
(1, '台北忠孝店', '台北市', '大安區忠孝東路四段 100 號', '02-2771-0001'),
(2, '台中勤美店', '台中市', '西區公益路 68 號', '04-2328-0003'),
(3, '高雄巨蛋店', '高雄市', '左營區博愛二路 777 號', '07-5551-0004')
ON CONFLICT (store_id) DO NOTHING;

INSERT INTO categories (category_id, name) VALUES
(1, '義式咖啡'),
(2, '手沖單品'),
(3, '現烤輕食')
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO customers (customer_id, name, phone, gender) VALUES
(1, '陳小華', '0912-000-001', '女'),
(2, '林志明', '0912-000-002', '男'),
(3, '黃雅婷', '0912-000-003', '女')
ON CONFLICT (customer_id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 2. 正確第二步：建立依賴父表的二級資料 (員工、商品)
-- ------------------------------------------------------------------------------
INSERT INTO staff (staff_id, store_id, name, position, salary) VALUES
(1, 1, '張店長', '店長', 48000),
(2, 1, '王咖啡師', '正職', 36000),
(3, 2, '李店長', '店長', 46000)
ON CONFLICT (staff_id) DO NOTHING;

INSERT INTO products (product_id, category_id, name, price, cost) VALUES
(101, 1, '經典美式咖啡', 85.00, 25.00),
(102, 1, '原味拿鐵咖啡', 120.00, 40.00),
(103, 2, '耶加雪菲手沖', 150.00, 50.00),
(104, 3, '肉桂黑糖可頌', 75.00, 25.00)
ON CONFLICT (product_id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 3. 正確第三步：建立業務交易紀錄 (訂單主檔與明細)
-- ------------------------------------------------------------------------------
-- 門市 1 的張店長經手、會員 1 購買的訂單
INSERT INTO orders (order_id, store_id, staff_id, customer_id, order_date, payment_method, status) VALUES
(1001, 1, 1, 1, '2024-03-01', '信用卡', '已完成'),
(1002, 1, 2, 2, '2024-03-02', '現金', '已完成')
ON CONFLICT (order_id) DO NOTHING;

-- 訂單 1001 包含兩項商品明細
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 102, 2, 120.00), -- 拿鐵 2 杯
(2, 1001, 104, 1, 75.00),  -- 可頌 1 份
(3, 1002, 101, 1, 85.00)   -- 訂單 1002 買美式 1 杯
ON CONFLICT (item_id) DO NOTHING;

COMMIT; -- 確認無誤，交易正式寫入！

-- 查詢確認所有資料表筆數
SELECT 'stores' AS 表名, COUNT(*) AS 筆數 FROM stores
UNION ALL SELECT 'staff', COUNT(*) FROM staff
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
