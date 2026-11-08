-- ==============================================================
-- 教育訓練報名表：完整版（救援用）
-- 注意：這份會刪掉現有的資料表，你手寫的表和資料都會被取代
-- 只有卡關、或想把資料恢復成初始狀態時才執行
-- ==============================================================
BEGIN;

DROP TABLE IF EXISTS guest_enrollments;
DROP TABLE IF EXISTS employee_enrollments;
DROP TABLE IF EXISTS guests;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    course_id   VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    course_date DATE        NOT NULL,
    instructor  VARCHAR(20) NOT NULL,
    capacity    INT         NOT NULL CHECK (capacity > 0)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    name   VARCHAR(20) NOT NULL,
    dept   VARCHAR(20) NOT NULL
);

CREATE TABLE guests (
    guest_id SERIAL PRIMARY KEY,
    name     VARCHAR(20) NOT NULL,
    company  VARCHAR(30) NOT NULL,
    email    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee_enrollments (
    course_id VARCHAR(10) NOT NULL REFERENCES courses(course_id),
    emp_id    VARCHAR(10) NOT NULL REFERENCES employees(emp_id),
    attended  BOOLEAN,
    PRIMARY KEY (course_id, emp_id)
);

CREATE TABLE guest_enrollments (
    course_id VARCHAR(10) NOT NULL REFERENCES courses(course_id),
    guest_id  INT         NOT NULL REFERENCES guests(guest_id),
    attended  BOOLEAN,
    PRIMARY KEY (course_id, guest_id)
);

INSERT INTO courses (course_id, name, course_date, instructor, capacity) VALUES
('C01', 'Excel 樞紐分析', '2024-04-10', '李老師', 30),
('C02', '資料安全入門', '2024-04-17', '陳顧問', 40),
('C03', '簡報表達技巧', '2024-04-24', '王講師', 20),
('C04', 'Power BI 入門', '2024-05-08', '李老師', 25),
('C05', 'AI 工具實務', '2024-05-22', '林顧問', 50),
('C06', '跨部門溝通', '2024-06-05', '王講師', 20);

INSERT INTO employees (emp_id, name, dept) VALUES
('E01', '陳小華', '業務發展部'),
('E02', '林志明', '資訊技術部'),
('E03', '黃雅婷', '行銷企劃部'),
('E04', '張大同', '管理行政部'),
('E05', '周美玲', '業務發展部'),
('E06', '劉國強', '資訊技術部');

INSERT INTO guests (guest_id, name, company, email) VALUES
(1, '趙文華', '順發貿易', 'wenhua@example.com'),
(2, '孫佳蓉', '大成科技', 'jiarong@example.com'),
(3, '周建宏', '宏達物流', 'jianhong@example.com'),
(4, '陳小華', '金福食品', 'xiaohua@example.com'),
(5, '吳淑芬', '金福食品', 'shufen@example.com');

SELECT setval(pg_get_serial_sequence('guests', 'guest_id'), 5);

INSERT INTO employee_enrollments (course_id, emp_id, attended) VALUES
('C01', 'E01', true),
('C01', 'E02', true),
('C01', 'E03', false),
('C01', 'E05', true),
('C02', 'E01', true),
('C02', 'E02', true),
('C02', 'E04', true),
('C02', 'E06', false),
('C03', 'E03', true),
('C03', 'E05', true),
('C04', 'E02', false),
('C04', 'E06', false),
('C06', 'E01', NULL),
('C06', 'E04', NULL);

INSERT INTO guest_enrollments (course_id, guest_id, attended) VALUES
('C01', 1, true),
('C01', 2, false),
('C02', 1, true),
('C02', 3, true),
('C02', 4, true),
('C03', 5, true),
('C06', 2, NULL);

COMMIT;
