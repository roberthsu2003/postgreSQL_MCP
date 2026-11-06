/* ==============================================================================
   單元 13：聯集操作 (UNION 與 UNION ALL)
   
   【核心規則】：
   1. 每個 SELECT 的「欄位數量」必須完全相同。
   2. 對應欄位的「資料型別」必須相容（如文字對文字、數字對數字）。
   3. UNION 會自動過濾重複值（較消耗效能）；UNION ALL 保留所有列（效能極高）。
   ============================================================================== */

-- 1. 取得全體品牌「聯絡人名冊」（將「門市員工」與「會員顧客」姓名合併）
SELECT name AS 聯絡人姓名, '員工' AS 身分別
FROM staff
UNION
SELECT name AS 聯絡人姓名, '會員' AS 身分別
FROM customers;

-- 2. 比較 UNION 與 UNION ALL 的差異
-- 假設某會員與某員工同名，UNION 會自動合併為單一列：
SELECT city FROM stores
UNION
SELECT '台北市' AS city;

-- UNION ALL 不過濾重複，全部列出 (速度最快)：
SELECT city FROM stores
UNION ALL
SELECT '台北市' AS city;

-- 3. 取得「門市聯絡電話」與「會員聯絡電話」的大名冊
SELECT store_id AS 編號, name AS 名稱, phone AS 電話, '門市總機' AS 類別
FROM stores
WHERE phone IS NOT NULL
UNION ALL
SELECT customer_id AS 編號, name AS 名稱, phone AS 電話, '個人會員' AS 類別
FROM customers;

-- 4. 錯誤示範（欄位數量不同會直接報錯）：
-- SELECT name, phone FROM stores
-- UNION
-- SELECT name FROM customers;
-- 🛑 錯誤訊息：ERROR: each UNION query must have the same number of columns
