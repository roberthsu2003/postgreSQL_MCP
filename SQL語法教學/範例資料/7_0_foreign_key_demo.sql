-- DML-4 外來鍵｜完整實測（PostgreSQL）
-- 先在 cafe_db 執行 7_0_foreign_key_setup.sql，再整份執行本檔。
-- 若自行修改過練習資料，請先重新匯入 setup 恢復起始資料。
-- 預期錯誤由 EXCEPTION 捕捉，顯示於 DBeaver 的 Output / Server Output。
-- 本檔不需要三個職場範例庫，也不建立實作題資料表。
-- 最後 ROLLBACK 還原資料；SERIAL 序號不隨 ROLLBACK 回復，跳號是正常現象。

BEGIN;
SET LOCAL search_path TO public;

-- 1. 基本資料：2 家門市、3 位員工。
SELECT * FROM fk_stores ORDER BY store_id;
SELECT * FROM fk_staff ORDER BY staff_id;

-- 2. 新增、修改、刪除都會檢查外來鍵。
-- 若意外沒有報錯，就拋出例外，提醒資料或限制設定有問題。
DO $$
BEGIN
    BEGIN
        INSERT INTO fk_staff (name, store_id) VALUES ('幽靈員工', 99);
        RAISE EXCEPTION '驗證失敗：不存在的門市竟然可以新增員工';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE '符合預期：新增被外來鍵擋下（%）', SQLERRM;
    END;
    BEGIN
        UPDATE fk_staff SET store_id = 99 WHERE staff_id = 1;
        RAISE EXCEPTION '驗證失敗：員工竟然可以轉到不存在的門市';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE '符合預期：修改被外來鍵擋下（%）', SQLERRM;
    END;
    BEGIN
        DELETE FROM fk_stores WHERE store_id = 1;
        RAISE EXCEPTION '驗證失敗：NO ACTION 沒有擋下刪除';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE '符合預期：NO ACTION 保護仍有員工的門市（%）', SQLERRM;
    END;
END;
$$;

-- 3. 未設 NOT NULL 的外來鍵可填空值；觀察後退回儲存點。
SAVEPOINT nullable_demo;
UPDATE fk_staff SET store_id = NULL WHERE staff_id = 1;
SELECT staff_id, name, store_id FROM fk_staff WHERE staff_id = 1; -- NULL
ROLLBACK TO SAVEPOINT nullable_demo;

-- 4. 先刪子資料，再刪父資料可以成功。
SAVEPOINT child_first_demo;
DELETE FROM fk_staff WHERE store_id = 1;
DELETE FROM fk_stores WHERE store_id = 1;
SELECT COUNT(*) AS 門市剩餘筆數 FROM fk_stores WHERE store_id = 1; -- 0
ROLLBACK TO SAVEPOINT child_first_demo;

-- 5. SET NULL：子資料保留，外來鍵變空值。
SELECT * FROM fk_member_orders; -- member_id = 1
DELETE FROM fk_members WHERE member_id = 1;
SELECT * FROM fk_member_orders; -- (888, NULL, 350)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM fk_member_orders
                   WHERE order_id = 888 AND member_id IS NULL AND amount = 350) THEN
        RAISE EXCEPTION '驗證失敗：SET NULL 結果不符';
    END IF;
END;
$$;

-- 6. CASCADE：明細由 2 筆變成 0 筆。
SELECT COUNT(*) AS 刪除前明細筆數 FROM fk_order_items; -- 2
DELETE FROM fk_orders WHERE order_id = 101;
SELECT COUNT(*) AS 剩餘明細筆數 FROM fk_order_items; -- 0
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM fk_order_items WHERE order_id = 101) THEN
        RAISE EXCEPTION '驗證失敗：CASCADE 未刪除明細';
    END IF;
END;
$$;

-- 7. RESTRICT：仍有員工的部門不可刪。
DO $$
BEGIN
    BEGIN
        DELETE FROM fk_restrict_departments WHERE dept_id = 1;
        RAISE EXCEPTION '驗證失敗：RESTRICT 沒有擋下刪除';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE '符合預期：RESTRICT 保護仍有員工的部門（%）', SQLERRM;
    END;
END;
$$;

-- 8. SET DEFAULT：員工的 dept_id 由 1 改為 0。
SAVEPOINT default_demo;
SELECT * FROM fk_default_staff;
DELETE FROM fk_default_departments WHERE dept_id = 1;
SELECT * FROM fk_default_staff; -- (1, 李小華, 0)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM fk_default_staff WHERE staff_id = 1 AND dept_id = 0) THEN
        RAISE EXCEPTION '驗證失敗：SET DEFAULT 結果不符';
    END IF;
END;
$$;
ROLLBACK TO SAVEPOINT default_demo;

-- 9. 若父表沒有預設編號 0，SET DEFAULT 仍會被外來鍵擋下。
DELETE FROM fk_default_departments WHERE dept_id = 0;
DO $$
BEGIN
    BEGIN
        DELETE FROM fk_default_departments WHERE dept_id = 1;
        RAISE EXCEPTION '驗證失敗：預設部門不存在卻能完成刪除';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE '符合預期：預設部門 0 不存在，SET DEFAULT 失敗（%）', SQLERRM;
    END;
END;
$$;

ROLLBACK;

-- 確認還原：會員 1、訂單 101、部門 0 與 1 應仍在。
SELECT * FROM fk_members;
SELECT * FROM fk_orders;
SELECT * FROM fk_default_departments ORDER BY dept_id;
