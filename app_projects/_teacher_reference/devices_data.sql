-- ==============================================================
-- IT 設備規格表：資料交易檔（只有 INSERT，沒有建表）
-- 使用前：先在 devices 資料庫親手建好 devices 資料表
-- 任何一筆失敗，整份都不會寫入，修好結構後可以再執行一次
-- ==============================================================
BEGIN;

INSERT INTO devices (device_id, name, device_type, purchase_date, price, department, specs) VALUES
('NB-001', 'ThinkPad X1 Carbon', '筆電', '2023-03-15', 48500, '資訊技術部', '{"cpu": "i7-1365U", "ram_gb": 16, "screen_inch": 14}'),
('NB-002', 'MacBook Pro 14', '筆電', '2024-01-10', 59900, '資訊技術部', '{"cpu": "M3", "ram_gb": 18, "screen_inch": 14}'),
('NB-003', 'ThinkPad E14', '筆電', '2022-08-20', 28900, '業務發展部', '{"cpu": "i5-1235U", "ram_gb": 8, "screen_inch": 14}'),
('NB-004', 'ASUS ExpertBook B5', '筆電', '2023-06-01', 35900, '業務發展部', '{"cpu": "i5-1340P", "ram_gb": 16, "screen_inch": 14}'),
('NB-005', 'Dell Latitude 5440', '筆電', '2023-09-12', 33900, '行銷企劃部', '{"cpu": "i5-1335U", "ram_gb": 16, "screen_inch": 14}'),
('NB-006', 'HP ProBook 440', '筆電', '2022-05-18', 26900, '管理行政部', '{"cpu": "i5-1235U", "ram_gb": 8, "screen_inch": 14}'),
('NB-007', 'MacBook Air 13', '筆電', '2024-02-20', 36900, '行銷企劃部', '{"cpu": "M2", "ram_gb": 8, "screen_inch": 13}'),
('NB-008', 'Dell XPS 15', '筆電', '2024-03-05', 62900, '資訊技術部', '{"cpu": "i7-13700H", "ram_gb": 32, "screen_inch": 15}'),
('PJ-001', 'Epson CO-FH02', '投影機', '2023-02-01', 21900, '業務發展部', '{"lumens": 3000, "resolution": "1920x1080"}'),
('PJ-002', 'BenQ MH560', '投影機', '2022-11-11', 18900, '管理行政部', '{"lumens": 3800, "resolution": "1920x1080"}'),
('PJ-003', 'ViewSonic PA503X', '投影機', '2021-07-07', 12900, '行銷企劃部', '{"lumens": 3600, "resolution": "1024x768"}'),
('PJ-004', 'Epson EB-L200F', '投影機', '2024-01-22', 45900, '資訊技術部', '{"lumens": 4500, "resolution": "1920x1080"}'),
('PR-001', 'HP LaserJet M404dn', '印表機', '2022-04-15', 12900, '管理行政部', '{"ppm": 38, "duplex": true, "paper": "A4"}'),
('PR-002', 'Brother HL-L2375DW', '印表機', '2023-01-30', 6900, '業務發展部', '{"ppm": 34, "duplex": true, "paper": "A4"}'),
('PR-003', 'Canon LBP6030', '印表機', '2021-09-09', 3900, '行銷企劃部', '{"ppm": 18, "duplex": false, "paper": "A4"}'),
('PR-004', 'Epson WF-7310', '印表機', '2023-08-08', 8900, '資訊技術部', '{"ppm": 18, "duplex": true, "paper": "A3"}');

COMMIT;
