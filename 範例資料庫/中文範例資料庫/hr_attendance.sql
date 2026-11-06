-- ==============================================================================
-- 繁體中文範例資料庫：人資考勤、排班與薪資計算系統 (hr_attendance.sql)
-- 
-- 【適用職務】：人資 (HR)、考勤計薪、行政店長
-- 【解決痛點】：
--   1. 告別 Excel 排班撞期與連上超過 6 天的勞基法防呆問題。
--   2. 打卡出勤時間自動比對遲到、早退與加班時數。
--   3. 月底一鍵結算應發薪資、請假扣款與加班費。
-- ==============================================================================

BEGIN;

DROP TABLE IF EXISTS hr_leave_requests CASCADE;
DROP TABLE IF EXISTS hr_attendance_records CASCADE;
DROP TABLE IF EXISTS hr_shifts CASCADE;
DROP TABLE IF EXISTS hr_employees CASCADE;
DROP TABLE IF EXISTS hr_departments CASCADE;

-- 1. 部門表
CREATE TABLE hr_departments (
    dept_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    manager_name VARCHAR(20) NOT NULL
);

-- 2. 員工基本資料檔 (含基本月薪與換算時薪)
CREATE TABLE hr_employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    dept_id VARCHAR(10) NOT NULL REFERENCES hr_departments(dept_id),
    name VARCHAR(20) NOT NULL,
    title VARCHAR(30) NOT NULL,
    base_salary INT NOT NULL CHECK (base_salary >= 0),
    hourly_rate INT GENERATED ALWAYS AS (base_salary / 240) STORED, -- 換算法定時薪
    hire_date DATE NOT NULL,
    phone VARCHAR(20) NOT NULL
);

-- 3. 月度排班表 (包含早班、中班、晚班與排休)
CREATE TABLE hr_shifts (
    shift_id SERIAL PRIMARY KEY,
    emp_id VARCHAR(10) NOT NULL REFERENCES hr_employees(emp_id),
    shift_date DATE NOT NULL,
    shift_type VARCHAR(20) NOT NULL CHECK (shift_type IN ('早班', '中班', '晚班', '常態班', '排休')),
    planned_hours INT NOT NULL DEFAULT 8,
    UNIQUE (emp_id, shift_date) -- 防呆：同員工同日不可重複排班
);

-- 4. 每日打卡出勤明細檔
CREATE TABLE hr_attendance_records (
    record_id SERIAL PRIMARY KEY,
    emp_id VARCHAR(10) NOT NULL REFERENCES hr_employees(emp_id),
    work_date DATE NOT NULL,
    clock_in TIMESTAMPTZ,
    clock_out TIMESTAMPTZ,
    actual_hours NUMERIC(4, 1) DEFAULT 0,
    overtime_hours NUMERIC(4, 1) DEFAULT 0,
    is_late BOOLEAN DEFAULT false,
    status VARCHAR(20) DEFAULT '正常'
);

-- 5. 請假審批單檔
CREATE TABLE hr_leave_requests (
    leave_id SERIAL PRIMARY KEY,
    emp_id VARCHAR(10) NOT NULL REFERENCES hr_employees(emp_id),
    leave_type VARCHAR(20) NOT NULL CHECK (leave_type IN ('事假', '病假', '特休', '公假', '婚喪假')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    hours INT NOT NULL CHECK (hours > 0),
    reason TEXT,
    approval_status VARCHAR(20) DEFAULT '待審核' CHECK (approval_status IN ('待審核', '已核准', '已駁回'))
);

-- ==============================================================================
-- 假資料寫入 (2024 年 3 月份實戰數據)
-- ==============================================================================

-- 部門資料
INSERT INTO hr_departments VALUES
('D01', '業務發展部', '張協理'),
('D02', '資訊技術部', '李副總'),
('D03', '行銷企劃部', '王經理'),
('D04', '管理行政部', '陳主任');

-- 員工資料
INSERT INTO hr_employees (emp_id, dept_id, name, title, base_salary, hire_date, phone) VALUES
('E01', 'D01', '陳小華', '資深業務代表', 48000, '2021-03-01', '0912-000-001'),
('E02', 'D02', '林志明', '後端工程師', 65000, '2020-07-15', '0912-000-002'),
('E03', 'D03', '黃雅婷', '行銷專員', 42000, '2022-02-10', '0912-000-003'),
('E04', 'D04', '張大同', '總務行政助理', 35000, '2023-05-01', '0912-000-004'),
('E05', 'D01', '周美玲', '業務專員', 38000, '2022-11-20', '0912-000-005'),
('E06', 'D02', '劉國強', '資深架構師', 82000, '2019-04-12', '0912-000-006');

-- 排班資料 (以 3 月初為例)
INSERT INTO hr_shifts (emp_id, shift_date, shift_type, planned_hours) VALUES
('E01', '2024-03-01', '常態班', 8),
('E01', '2024-03-02', '排休', 0),
('E01', '2024-03-03', '排休', 0),
('E01', '2024-03-04', '常態班', 8),
('E02', '2024-03-01', '常態班', 8),
('E02', '2024-03-04', '常態班', 8),
('E03', '2024-03-01', '常態班', 8),
('E04', '2024-03-01', '常態班', 8);

-- 打卡出勤紀錄
INSERT INTO hr_attendance_records (emp_id, work_date, clock_in, clock_out, actual_hours, overtime_hours, is_late, status) VALUES
('E01', '2024-03-01', '2024-03-01 08:55:00+08', '2024-03-01 18:05:00+08', 8.0, 0.0, false, '正常'),
('E02', '2024-03-01', '2024-03-01 09:15:00+08', '2024-03-01 20:30:00+08', 10.0, 2.0, true, '遲到且加班'),
('E03', '2024-03-01', '2024-03-01 08:50:00+08', '2024-03-01 18:00:00+08', 8.0, 0.0, false, '正常'),
('E04', '2024-03-01', '2024-03-01 09:00:00+08', '2024-03-01 18:00:00+08', 8.0, 0.0, false, '正常'),
('E01', '2024-03-04', '2024-03-04 08:58:00+08', '2024-03-04 19:30:00+08', 9.5, 1.5, false, '正常加班');

-- 請假審批單
INSERT INTO hr_leave_requests (emp_id, leave_type, start_date, end_date, hours, reason, approval_status) VALUES
('E03', '特休', '2024-03-08', '2024-03-08', 8, '個人事假安排', '已核准'),
('E05', '事假', '2024-03-12', '2024-03-12', 4, '家中有事外出辦理', '已核准'),
('E02', '病假', '2024-03-15', '2024-03-15', 8, '感冒發燒就醫', '待審核');

COMMIT;

