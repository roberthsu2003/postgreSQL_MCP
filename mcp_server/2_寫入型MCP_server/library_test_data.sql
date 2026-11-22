-- 單元 2：可重複準備的借還書驗收資料（PostgreSQL）
-- 先在獨立練習資料庫 mcp_library 匯入 library.sql，再執行本檔。
-- 保留 9901～9907 的書籍與 9901～9905 的會員編號供教學使用。
-- 重跑會刪除這些測試會員／書籍的借閱紀錄並重建測試情境；不重建原始資料表。
-- 到期日依執行當天計算，避免教材過幾個月就無法得到預期結果。
BEGIN;
SET LOCAL search_path TO public;

DELETE FROM loans WHERE member_id BETWEEN 9901 AND 9905 OR book_id BETWEEN 9901 AND 9907;
DELETE FROM members WHERE member_id BETWEEN 9901 AND 9905;
DELETE FROM books WHERE book_id BETWEEN 9901 AND 9907;

INSERT INTO members (member_id, name, member_type, joined_on) VALUES
(9901, '練習_可借會員', '學生', CURRENT_DATE),
(9902, '練習_逾期會員', '一般', CURRENT_DATE),
(9903, '練習_滿額會員', '一般', CURRENT_DATE),
(9904, '練習_額度競爭會員', '學生', CURRENT_DATE),
(9905, '練習_另一位可借會員', '一般', CURRENT_DATE);

INSERT INTO books (book_id, title, category, copies) VALUES
(9901, '練習_可借測試書', '教學測試', 2),
(9902, '練習_已借完測試書', '教學測試', 1),
(9903, '練習_額度測試書', '教學測試', 5),
(9904, '練習_併發額度用書', '教學測試', 4),
(9905, '練習_最後一本測試書', '教學測試', 1),
(9906, '練習_不同書A', '教學測試', 2),
(9907, '練習_不同書B', '教學測試', 2);

INSERT INTO loans (loan_id, book_id, member_id, loan_date, due_date) VALUES
(9901, 9902, 9902, CURRENT_DATE - 15, CURRENT_DATE - 1),
(9902, 9903, 9903, CURRENT_DATE, CURRENT_DATE + 14),
(9903, 9903, 9903, CURRENT_DATE, CURRENT_DATE + 14),
(9904, 9903, 9903, CURRENT_DATE, CURRENT_DATE + 14),
(9905, 9903, 9903, CURRENT_DATE, CURRENT_DATE + 14),
(9906, 9903, 9903, CURRENT_DATE, CURRENT_DATE + 14),
(9907, 9904, 9904, CURRENT_DATE, CURRENT_DATE + 21),
(9908, 9904, 9904, CURRENT_DATE, CURRENT_DATE + 21),
(9909, 9904, 9904, CURRENT_DATE, CURRENT_DATE + 21),
(9910, 9904, 9904, CURRENT_DATE, CURRENT_DATE + 21);

SELECT setval(pg_get_serial_sequence('members', 'member_id'), (SELECT MAX(member_id) FROM members));
SELECT setval(pg_get_serial_sequence('books', 'book_id'), (SELECT MAX(book_id) FROM books));
SELECT setval(pg_get_serial_sequence('loans', 'loan_id'), (SELECT MAX(loan_id) FROM loans));
COMMIT;

-- 應依序看到：9901=0/0、9902=1/1、9903=5/0、9904=4/0、9905=0/0。
SELECT m.member_id, m.name,
       COUNT(l.loan_id) AS 借閱中,
       COUNT(l.loan_id) FILTER (WHERE l.due_date < CURRENT_DATE) AS 逾期未還
FROM members m
LEFT JOIN loans l ON l.member_id = m.member_id AND l.return_date IS NULL
WHERE m.member_id BETWEEN 9901 AND 9905
GROUP BY m.member_id, m.name
ORDER BY m.member_id;
