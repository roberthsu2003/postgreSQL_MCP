-- ==============================================================================
-- 實戰範例：由「員工差旅與費用報銷單.xlsx」經 AI 轉換產出之標準 PostgreSQL 交易檔
-- 
-- 【教學特性】：
-- 1. 嚴格符合關聯式資料庫第三正規化 (3NF)，消除部門名稱、主管與類別的重複紀錄。
-- 2. 採用交易區塊包裹 (BEGIN ... COMMIT)，確保整批結構與資料寫入的原子性 (Atomicity)。
-- 3. 包含完整外來鍵 (FOREIGN KEY)、主鍵 (PRIMARY KEY) 與金額檢核限制 (CHECK)。
-- ==============================================================================

BEGIN; -- 開啟交易

-- 1. 建立基礎主表：部門表 (departments)
CREATE TABLE IF NOT EXISTS expense_departments (
    dept_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    manager_name VARCHAR(20) NOT NULL
);
COMMENT ON TABLE expense_departments IS '企業組織部門與主管資料表';

-- 2. 建立基礎主表：員工表 (employees)
CREATE TABLE IF NOT EXISTS expense_employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    dept_id VARCHAR(10) NOT NULL REFERENCES expense_departments(dept_id) ON UPDATE CASCADE
);
COMMENT ON TABLE expense_employees IS '員工基本資料表 (外來鍵關聯部門)';

-- 3. 建立基礎主表：費用類別表 (categories)
CREATE TABLE IF NOT EXISTS expense_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);
COMMENT ON TABLE expense_categories IS '財務費用報銷類別表';

-- 4. 建立核心業務從表：費用報銷單 (expense_claims)
CREATE TABLE IF NOT EXISTS expense_claims (
    claim_id VARCHAR(20) PRIMARY KEY,
    claim_date DATE NOT NULL,
    emp_id VARCHAR(10) NOT NULL REFERENCES expense_employees(emp_id),
    category_id INT NOT NULL REFERENCES expense_categories(category_id),
    invoice_no VARCHAR(30) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT '待審核' CHECK (status IN ('待審核', '已批准', '待撥款', '已撥款', '已駁回')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE expense_claims IS '費用報銷與單據主檔 (含金額防呆與審核狀態限制)';

-- ==============================================================================
-- 資料匯入 (嚴格依據主從關聯順序：先父表後子表)
-- ==============================================================================

-- (1) 寫入部門資料
INSERT INTO expense_departments (dept_id, name, manager_name) VALUES
('D01', '業務部', '張協理'),
('D02', '技術部', '李副總'),
('D03', '行銷部', '王經理'),
('D04', '人事部', '李副總')
ON CONFLICT (dept_id) DO NOTHING;

-- (2) 寫入員工資料
INSERT INTO expense_employees (emp_id, name, dept_id) VALUES
('E01', '陳小華', 'D01'),
('E02', '林志明', 'D02'),
('E03', '黃雅婷', 'D03'),
('E04', '張大同', 'D04'),
('E05', '周美玲', 'D01')
ON CONFLICT (emp_id) DO NOTHING;

-- (3) 寫入費用類別資料
INSERT INTO expense_categories (category_id, name) VALUES
(1, '市區交通'),
(2, '長途交通'),
(3, '雲端服務'),
(4, '廣告推廣'),
(5, '商務餐敘'),
(6, '辦公耗材'),
(7, '軟體授權'),
(8, '差旅住宿'),
(9, '外部進修')
ON CONFLICT (category_id) DO NOTHING;

-- 修正 SERIAL 序列目前最大值
SELECT setval(pg_get_serial_sequence('expense_categories', 'category_id'), 9);

-- (4) 寫入報銷單據明細資料
INSERT INTO expense_claims (claim_id, claim_date, emp_id, category_id, invoice_no, amount, description, status) VALUES
('EXP20240301', '2024-03-01', 'E01', 1, 'AB-98765431', 350.00, '拜訪台北市內湖客戶計程車費', '已撥款'),
('EXP20240302', '2024-03-02', 'E01', 2, 'AB-98765432', 1400.00, '台中客戶提案高鐵來回票', '已撥款'),
('EXP20240303', '2024-03-03', 'E02', 3, 'CD-11223344', 3850.00, 'AWS雲端伺服器月租扣款', '已撥款'),
('EXP20240304', '2024-03-05', 'E03', 4, 'EF-55667788', 8500.00, 'Meta臉書春季促銷廣告費', '已撥款'),
('EXP20240305', '2024-03-08', 'E01', 5, 'AB-98765433', 1680.00, '與VIP簽約客戶工作便餐', '已撥款'),
('EXP20240306', '2024-03-10', 'E04', 6, 'GH-99887766', 1200.00, '採購員工報到文具與影印紙', '已撥款'),
('EXP20240307', '2024-03-12', 'E02', 7, 'CD-11223345', 4500.00, 'JetBrains IDE 開發工具年費', '已撥款'),
('EXP20240308', '2024-03-15', 'E03', 1, 'EF-55667789', 280.00, '台北國際烘焙展參展交通費', '已撥款'),
('EXP20240309', '2024-03-18', 'E05', 2, 'JK-33445566', 2980.00, '高雄分部業務巡訪高鐵票', '待撥款'),
('EXP20240310', '2024-03-20', 'E05', 8, 'JK-33445567', 2200.00, '高雄出差商務飯店一晚', '待撥款'),
('EXP20240311', '2024-03-22', 'E02', 9, 'CD-11223346', 3600.00, 'PostgreSQL效能優化研討會報名費', '已批准'),
('EXP20240312', '2024-03-25', 'E03', 5, 'EF-55667790', 2500.00, '行銷外包攝影團隊結案餐敘', '待審核'),
('EXP20240313', '2024-03-28', 'E01', 1, 'AB-98765434', 320.00, '拜訪新竹科學園區廠商客運費', '待審核')
ON CONFLICT (claim_id) DO NOTHING;

COMMIT; -- 提交交易，寫入資料庫！

