/* 進階-9｜ON DELETE：刪資料前先看連帶後果
   講義（含說明、執行結果、練習題）：15on_delete_action.md
   請在 DBeaver 用 Ctrl/Cmd + Enter 一句一句執行，邊看結果邊對照講義。
   本檔由講義內容產生，所有查詢都已實際執行驗證。 */

-- ======================================================
-- 以下請在 DBeaver 工具列切換到資料庫：cafe_shop
-- ======================================================

-- ▼ 1. 查出這個資料庫的所有規則
SELECT
    conrelid::regclass  AS 子表,
    confrelid::regclass AS 父表,
    CASE confdeltype
        WHEN 'a' THEN 'NO ACTION（不准刪）'
        WHEN 'r' THEN 'RESTRICT（不准刪）'
        WHEN 'c' THEN 'CASCADE（一起刪）'
        WHEN 'n' THEN 'SET NULL（變空值）'
        WHEN 'd' THEN 'SET DEFAULT（變預設值）'
    END AS 父資料被刪時
FROM pg_constraint
WHERE contype = 'f'
ORDER BY conrelid::regclass::TEXT, confrelid::regclass::TEXT;

-- ▼ 2. 實測 CASCADE：刪訂單，明細跟著走
BEGIN;

-- ▼ 2. 實測 CASCADE：刪訂單，明細跟著走
SELECT COUNT(*) AS 刪除前的明細 FROM order_items WHERE order_id = 1;

-- ▼ 2. 實測 CASCADE：刪訂單，明細跟著走
DELETE FROM orders WHERE order_id = 1;

SELECT COUNT(*) AS 刪除後的明細 FROM order_items WHERE order_id = 1;

-- ▼ 2. 實測 CASCADE：刪訂單，明細跟著走
ROLLBACK;

-- ▼ 3. 實測 NO ACTION：刪商品被擋（故意示範錯誤，要體驗時請拿掉註解）
-- DELETE FROM products WHERE product_id = 1;

-- ▼ 3. 實測 NO ACTION：刪商品被擋
ALTER TABLE products ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT true;

UPDATE products SET is_active = false WHERE product_id = 1;

SELECT COUNT(*) AS 販售中商品 FROM products WHERE is_active;

-- ▼ 4. 實測 SET NULL：會員註銷，訂單留著
BEGIN;

ALTER TABLE orders DROP CONSTRAINT orders_customer_id_fkey;

ALTER TABLE orders
    ADD CONSTRAINT orders_customer_id_fkey
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE SET NULL;

SELECT COUNT(*) AS 刪除前散客單 FROM orders WHERE customer_id IS NULL;

-- ▼ 4. 實測 SET NULL：會員註銷，訂單留著
DELETE FROM customers WHERE customer_id = 1;

SELECT COUNT(*) AS 刪除後散客單 FROM orders WHERE customer_id IS NULL;

-- ▼ 4. 實測 SET NULL：會員註銷，訂單留著
ROLLBACK;
