-- DML-4 外來鍵｜範例資料交易檔（PostgreSQL）
-- 連到 cafe_db，以「執行 SQL 腳本」執行整份檔案。
-- 會重建下列 10 張 fk_ 練習表並清除其舊資料；不使用 CASCADE。
-- 不包含實作題 fk_categories / fk_products，也不包含三個職場範例庫。
-- 建表與寫入全部成功才 COMMIT；失敗請執行 ROLLBACK，再排除原因。

BEGIN;
SET LOCAL search_path TO public;

-- 先刪子表，再刪父表。
DROP TABLE IF EXISTS fk_staff, fk_member_orders, fk_order_items,
    fk_restrict_staff, fk_default_staff;
DROP TABLE IF EXISTS fk_stores, fk_members, fk_orders,
    fk_restrict_departments, fk_default_departments;

CREATE TABLE fk_stores (
    store_id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);
CREATE TABLE fk_staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    store_id INT REFERENCES fk_stores(store_id)
);
INSERT INTO fk_stores (name) VALUES ('台北信義店'), ('台中逢甲店');
INSERT INTO fk_staff (name, store_id) VALUES ('張志明', 1), ('陳美玲', 1), ('許淑芬', 2);

CREATE TABLE fk_members (
    member_id INT PRIMARY KEY,
    name VARCHAR(20)
);
CREATE TABLE fk_member_orders (
    order_id INT PRIMARY KEY,
    member_id INT REFERENCES fk_members(member_id) ON DELETE SET NULL,
    amount INT
);
INSERT INTO fk_members VALUES (1, '林家豪');
INSERT INTO fk_member_orders VALUES (888, 1, 350);

CREATE TABLE fk_orders (
    order_id INT PRIMARY KEY
);
CREATE TABLE fk_order_items (
    item_id INT PRIMARY KEY,
    order_id INT REFERENCES fk_orders(order_id) ON DELETE CASCADE,
    item_name VARCHAR(50)
);
INSERT INTO fk_orders VALUES (101);
INSERT INTO fk_order_items VALUES (1, 101, '美式咖啡'), (2, 101, '可頌');

CREATE TABLE fk_restrict_departments (
    dept_id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);
CREATE TABLE fk_restrict_staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    dept_id INT REFERENCES fk_restrict_departments(dept_id) ON DELETE RESTRICT
);
INSERT INTO fk_restrict_departments VALUES (1, '業務部');
INSERT INTO fk_restrict_staff VALUES (1, '王小明', 1);

CREATE TABLE fk_default_departments (
    dept_id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL
);
CREATE TABLE fk_default_staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    dept_id INT DEFAULT 0 REFERENCES fk_default_departments(dept_id) ON DELETE SET DEFAULT
);
INSERT INTO fk_default_departments VALUES (0, '待分派'), (1, '行銷部');
INSERT INTO fk_default_staff VALUES (1, '李小華', 1);

COMMIT;

-- 匯入完成後，筆數應依序為 2、3、1、1、1、2、1、1、2、1。
SELECT 'fk_stores' AS table_name, COUNT(*) AS rows FROM fk_stores
UNION ALL SELECT 'fk_staff', COUNT(*) FROM fk_staff
UNION ALL SELECT 'fk_members', COUNT(*) FROM fk_members
UNION ALL SELECT 'fk_member_orders', COUNT(*) FROM fk_member_orders
UNION ALL SELECT 'fk_orders', COUNT(*) FROM fk_orders
UNION ALL SELECT 'fk_order_items', COUNT(*) FROM fk_order_items
UNION ALL SELECT 'fk_restrict_departments', COUNT(*) FROM fk_restrict_departments
UNION ALL SELECT 'fk_restrict_staff', COUNT(*) FROM fk_restrict_staff
UNION ALL SELECT 'fk_default_departments', COUNT(*) FROM fk_default_departments
UNION ALL SELECT 'fk_default_staff', COUNT(*) FROM fk_default_staff;
