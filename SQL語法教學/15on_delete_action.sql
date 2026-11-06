/* ==============================================================================
   單元 15：外來鍵刪除連鎖動作 (ON DELETE CASCADE / SET NULL / RESTRICT)
   (以繁體中文範例庫 cafe_shop / shop 為例)
   ============================================================================== */

-- ==============================================================================
-- 1. ON DELETE CASCADE (連鎖刪除) 實戰
-- 場景：當一張「訂單」被刪除時，其所屬的「訂單明細」必須連帶全部刪除，不能留下幽靈孤兒資料！
-- ==============================================================================

-- 建立測試用的迷你訂單與明細表
DROP TABLE IF EXISTS demo_order_items CASCADE;
DROP TABLE IF EXISTS demo_orders CASCADE;

CREATE TABLE demo_orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(20)
);

CREATE TABLE demo_order_items (
    item_id INT PRIMARY KEY,
    order_id INT REFERENCES demo_orders(order_id) ON DELETE CASCADE, -- 連鎖刪除
    item_name VARCHAR(50),
    amount INT
);

INSERT INTO demo_orders VALUES (101, '陳小華');
INSERT INTO demo_order_items VALUES 
    (1, 101, '經典美式咖啡', 85),
    (2, 101, '肉桂黑糖可頌', 75);

-- 刪除訂單 101
DELETE FROM demo_orders WHERE order_id = 101;

-- 驗證：demo_order_items 裡的那 2 筆明細已自動被連帶清空！
SELECT * FROM demo_order_items; -- 結果：0 筆

-- ==============================================================================
-- 2. ON DELETE SET NULL (設為空值) 實戰
-- 場景：當「會員」申請註銷帳號時，歷史訂單不能刪（公司要報稅），只需將會員欄位設為 NULL
-- ==============================================================================

DROP TABLE IF EXISTS demo_member_orders CASCADE;
DROP TABLE IF EXISTS demo_members CASCADE;

CREATE TABLE demo_members (
    member_id INT PRIMARY KEY,
    name VARCHAR(20)
);

CREATE TABLE demo_member_orders (
    order_id INT PRIMARY KEY,
    member_id INT REFERENCES demo_members(member_id) ON DELETE SET NULL, -- 設為 NULL
    total_amount INT
);

INSERT INTO demo_members VALUES (1, '林志明');
INSERT INTO demo_member_orders VALUES (888, 1, 350);

-- 會員註銷帳號
DELETE FROM demo_members WHERE member_id = 1;

-- 驗證：訂單 888 依然保留，但 member_id 變成 NULL！
SELECT * FROM demo_member_orders;
