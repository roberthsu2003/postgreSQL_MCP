-- ==============================================================
-- 差旅報銷單：完整版（救援用）
-- 注意：這份會刪掉現有的四張資料表，你手寫的表和資料都會被取代
-- 只有卡關、或想把資料恢復成初始狀態時才執行
-- ==============================================================
BEGIN;

DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id      SERIAL PRIMARY KEY,
    name         VARCHAR(30) NOT NULL UNIQUE,
    manager_name VARCHAR(20) NOT NULL
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE employees (
    emp_id  VARCHAR(10) PRIMARY KEY,
    name    VARCHAR(20) NOT NULL,
    dept_id INT NOT NULL REFERENCES departments(dept_id)
);

CREATE TABLE claims (
    claim_id    VARCHAR(20) PRIMARY KEY,
    claim_date  DATE NOT NULL,
    emp_id      VARCHAR(10) NOT NULL REFERENCES employees(emp_id),
    category_id INT NOT NULL REFERENCES categories(category_id),
    description TEXT,
    invoice_no  VARCHAR(30) NOT NULL UNIQUE,
    amount      NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    status      VARCHAR(20) NOT NULL DEFAULT '待審核'
                CHECK (status IN ('待審核', '已批准', '待撥款', '已撥款', '已駁回'))
);

-- 1. 部門（Excel 沒有部門編號，這裡依出現順序編號）
INSERT INTO departments (dept_id, name, manager_name) VALUES
(1, '業務部', '張協理'),
(2, '技術部', '李副總'),
(3, '行銷部', '王經理'),
(4, '人事部', '李副總');

-- 2. 費用類別（Excel 沒有類別編號，這裡依出現順序編號）
INSERT INTO categories (category_id, name) VALUES
(1, '市區交通'),
(2, '長途交通'),
(3, '雲端服務'),
(4, '廣告推廣'),
(5, '商務餐敘'),
(6, '辦公耗材'),
(7, '軟體授權'),
(8, '差旅住宿'),
(9, '外部進修');

-- 3. 手動指定過編號，要告訴自動編號從哪裡接著編
SELECT setval(pg_get_serial_sequence('departments', 'dept_id'), 4);
SELECT setval(pg_get_serial_sequence('categories', 'category_id'), 9);

-- 4. 員工
INSERT INTO employees (emp_id, name, dept_id) VALUES
('E01', '陳小華', 1),
('E02', '林志明', 2),
('E03', '黃雅婷', 3),
('E04', '張大同', 4),
('E05', '周美玲', 1);

-- 5. 報銷單
INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount, status) VALUES
('EXP20240301', '2024-03-01', 'E01', 1, '拜訪台北市內湖客戶計程車費', 'AB-98765431', 350, '已撥款'),
('EXP20240302', '2024-03-02', 'E01', 2, '台中客戶提案高鐵來回票', 'AB-98765432', 1400, '已撥款'),
('EXP20240303', '2024-03-03', 'E02', 3, 'AWS雲端伺服器月租扣款', 'CD-11223344', 3850, '已撥款'),
('EXP20240304', '2024-03-05', 'E03', 4, 'Meta臉書春季促銷廣告費', 'EF-55667788', 8500, '已撥款'),
('EXP20240305', '2024-03-08', 'E01', 5, '與VIP簽約客戶工作便餐', 'AB-98765433', 1680, '已撥款'),
('EXP20240306', '2024-03-10', 'E04', 6, '採購員工報到文具與影印紙', 'GH-99887766', 1200, '已撥款'),
('EXP20240307', '2024-03-12', 'E02', 7, 'JetBrains IDE 開發工具年費', 'CD-11223345', 4500, '已撥款'),
('EXP20240308', '2024-03-15', 'E03', 1, '台北國際烘焙展參展交通費', 'EF-55667789', 280, '已撥款'),
('EXP20240309', '2024-03-18', 'E05', 2, '高雄分部業務巡訪高鐵票', 'JK-33445566', 2980, '待撥款'),
('EXP20240310', '2024-03-20', 'E05', 8, '高雄出差商務飯店一晚', 'JK-33445567', 2200, '待撥款'),
('EXP20240311', '2024-03-22', 'E02', 9, 'PostgreSQL效能優化研討會報名費', 'CD-11223346', 3600, '已批准'),
('EXP20240312', '2024-03-25', 'E03', 5, '行銷外包攝影團隊結案餐敘', 'EF-55667790', 2500, '待審核'),
('EXP20240313', '2024-03-28', 'E01', 1, '拜訪新竹科學園區廠商客運費', 'AB-98765434', 320, '待審核');

COMMIT;
