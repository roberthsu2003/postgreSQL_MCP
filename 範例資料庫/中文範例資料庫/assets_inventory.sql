-- ==============================================================================
-- 繁體中文範例資料庫：企業固定資產借還與辦公耗材管理系統 (assets_inventory.sql)
-- 
-- 【適用職務】：總務 (General Affairs)、行政庶務、IT 資產管理、倉管
-- 【解決痛點】：
--   1. 辦公設備（筆電、投影機、測試機、會議設備）借用沒還找不到人。
--   2. 辦公耗材（影印紙、碳粉匣、文具）經常超領或臨時斷貨，缺乏安全庫存預警。
--   3. 每季固定資產盤點在幾千列 Excel 中搜尋對照，容易遺失與編號重複。
-- ==============================================================================

BEGIN;

DROP TABLE IF EXISTS asset_borrow_logs CASCADE;
DROP TABLE IF EXISTS asset_purchase_requests CASCADE;
DROP TABLE IF EXISTS assets CASCADE;
DROP TABLE IF EXISTS asset_categories CASCADE;

-- 1. 資產與耗材分類表
CREATE TABLE asset_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('固定資產設備', '辦公事務耗材'))
);

-- 2. 資產與耗材清單主檔
CREATE TABLE assets (
    asset_id VARCHAR(20) PRIMARY KEY, -- 如：IT-2024-001 或 MAT-PAPER-A4
    category_id INT NOT NULL REFERENCES asset_categories(category_id),
    name VARCHAR(50) NOT NULL,
    brand_model VARCHAR(50),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    current_stock INT NOT NULL DEFAULT 1 CHECK (current_stock >= 0),
    safety_stock INT NOT NULL DEFAULT 0, -- 安全庫存警戒水位
    location VARCHAR(50) NOT NULL,       -- 存放位置 (如：4F 總務庫房 A-02、IT 機房)
    status VARCHAR(20) DEFAULT '在庫可用' CHECK (status IN ('在庫可用', '借出中', '維修中', '報廢', '需補貨'))
);

-- 3. 設備借用與歸還流通紀錄檔 (以員工借用為核心)
CREATE TABLE asset_borrow_logs (
    log_id SERIAL PRIMARY KEY,
    asset_id VARCHAR(20) NOT NULL REFERENCES assets(asset_id),
    borrower_name VARCHAR(20) NOT NULL,
    borrower_dept VARCHAR(20) NOT NULL,
    borrower_phone VARCHAR(20) NOT NULL,
    borrow_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE,
    purpose TEXT,
    status VARCHAR(20) DEFAULT '借出中' CHECK (status IN ('借出中', '已歸還', '逾期未還'))
);

-- 4. 耗材請購與採購單主檔
CREATE TABLE asset_purchase_requests (
    request_id VARCHAR(20) PRIMARY KEY,
    asset_id VARCHAR(20) NOT NULL REFERENCES assets(asset_id),
    requester_name VARCHAR(20) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    estimated_total INT NOT NULL CHECK (estimated_total >= 0),
    request_date DATE NOT NULL,
    approval_status VARCHAR(20) DEFAULT '待審核' CHECK (approval_status IN ('待審核', '已採購', '已入庫', '已駁回'))
);

-- ==============================================================================
-- 假資料寫入 (真實總務與 IT 資產情境)
-- ==============================================================================

INSERT INTO asset_categories (category_id, name, type) VALUES
(1, '筆記型電腦與主機', '固定資產設備'),
(2, '會議投影與影音設備', '固定資產設備'),
(3, '公務測試智慧手機', '固定資產設備'),
(4, '影印紙與事務用紙', '辦公事務耗材'),
(5, '原廠碳粉匣與墨水', '辦公事務耗材');

INSERT INTO assets (asset_id, category_id, name, brand_model, unit_price, current_stock, safety_stock, location, status) VALUES
('IT-NB-202401', 1, 'MacBook Pro 14吋 M3', 'Apple A2992', 59900, 0, 1, '4F IT庫房', '借出中'),
('IT-NB-202402', 1, 'ThinkPad X1 Carbon', 'Lenovo Gen11', 48500, 1, 1, '4F IT庫房', '在庫可用'),
('AV-PJ-202301', 2, '無線便攜雷射投影機', 'Epson CO-FH02', 21900, 0, 1, '5F 貴賓會議室', '借出中'),
('MO-PH-202401', 3, 'Pixel 8 測試機 (128GB)', 'Google Pixel 8', 24900, 2, 1, '4F QA測試櫃', '在庫可用'),
('MAT-P-A470', 4, 'Double A A4 70g 影印紙(箱)', 'Double A 5包/箱', 650, 3, 5, '3F 總務庫房 B-01', '需補貨'),
('MAT-P-A380', 4, 'Double A A3 80g 繪圖紙(箱)', 'Double A 5包/箱', 1350, 8, 3, '3F 總務庫房 B-01', '在庫可用'),
('MAT-T-HP05', 5, 'HP LaserJet 原廠黑色碳粉匣', 'HP CF205A', 3200, 1, 2, '3F 總務庫房 C-03', '需補貨');

INSERT INTO asset_borrow_logs (asset_id, borrower_name, borrower_dept, borrower_phone, borrow_date, expected_return_date, actual_return_date, purpose, status) VALUES
('IT-NB-202401', '林志明', '資訊技術部', '0912-000-002', '2024-03-01', '2024-03-15', NULL, '新專案客戶現場部署與除錯', '借出中'),
('AV-PJ-202301', '陳小華', '業務發展部', '0912-000-001', '2024-03-05', '2024-03-06', '2024-03-06', '信義區客戶年度合約提案簡報', '已歸還'),
('AV-PJ-202301', '黃雅婷', '行銷企劃部', '0912-000-003', '2024-03-10', '2024-03-12', NULL, '台北烘焙加盟展場外投影宣傳', '逾期未還');

INSERT INTO asset_purchase_requests (request_id, asset_id, requester_name, quantity, estimated_total, request_date, approval_status) VALUES
('REQ-202403-01', 'MAT-P-A470', '張大同', 10, 6500, '2024-03-12', '已採購'),
('REQ-202403-02', 'MAT-T-HP05', '張大同', 3, 9600, '2024-03-15', '待審核');

COMMIT;

