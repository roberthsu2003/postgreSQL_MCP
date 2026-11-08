-- ==============================================================
-- 連鎖門市月報：匯入腳本（把暫存表 raw_sales 的資料放進正式資料表）
-- 使用前：先親手建好六張正式表和 raw_sales，再把 CSV 匯入 raw_sales
-- 每個月都用同一份；重複執行也不會產生重複資料
-- 任何一筆失敗，整份都不會寫入
-- ==============================================================
BEGIN;

-- 1. 門市
INSERT INTO stores (name, region)
SELECT DISTINCT 門市名稱, 區域
FROM raw_sales
ON CONFLICT (name) DO NOTHING;

-- 2. 店員（同一家店不會重複）
INSERT INTO staff (name, store_id)
SELECT DISTINCT r.經手店員, s.store_id
FROM raw_sales r
JOIN stores s ON r.門市名稱 = s.name
ON CONFLICT (name, store_id) DO NOTHING;

-- 3. 商品
INSERT INTO products (name, category, price)
SELECT DISTINCT 商品名稱, 商品分類, 單價::INT
FROM raw_sales
ON CONFLICT (name) DO NOTHING;

-- 4. 會員（用電話辨識，散客沒有電話，不寫入）
INSERT INTO customers (name, phone)
SELECT DISTINCT 會員姓名, 會員電話
FROM raw_sales
WHERE NULLIF(會員電話, '') IS NOT NULL
ON CONFLICT (phone) DO NOTHING;

-- 5. 訂單（散客的 customer_id 是 NULL，所以用 LEFT JOIN）
INSERT INTO orders (order_id, order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
SELECT DISTINCT r.銷售單號, r.銷售日期::DATE, r.時間::TIME, s.store_id, st.staff_id, c.customer_id, r.付款方式, r.狀態
FROM raw_sales r
JOIN stores s ON r.門市名稱 = s.name
JOIN staff st ON r.經手店員 = st.name AND st.store_id = s.store_id
LEFT JOIN customers c ON NULLIF(r.會員電話, '') = c.phone
ON CONFLICT (order_id) DO NOTHING;

-- 6. 訂單明細
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT r.銷售單號, p.product_id, r.數量::INT, r.單價::INT
FROM raw_sales r
JOIN products p ON r.商品名稱 = p.name
ON CONFLICT (order_id, product_id) DO NOTHING;

COMMIT;
