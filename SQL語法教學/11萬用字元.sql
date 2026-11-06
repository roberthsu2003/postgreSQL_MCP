/* ==============================================================================
   單元 12：萬用字元與字串模糊比對 (LIKE / ILIKE)
   
   【規則速查】：
   • % 代表 0 個或多個任意字元
   • _ 代表剛好 1 個任意字元
   • LIKE 區分英文字母大小寫；ILIKE 不區分大小寫 (PostgreSQL 專有特異功能)
   ============================================================================== */

-- 1. 取得品名開頭是「拿鐵」的所有商品 (例如：拿鐵咖啡、拿鐵風味燕麥奶)
SELECT name, price 
FROM products 
WHERE name LIKE '拿鐵%';

-- 2. 取得品名包含「手沖」關鍵字的所有品項
SELECT name, price 
FROM products 
WHERE name LIKE '%手沖%';

-- 3. 取得地址位於「台北市」的門市
SELECT name, city, address, phone 
FROM stores 
WHERE address LIKE '台北市%';

-- 4. 取得門市名稱包含「忠孝」字眼的分店
SELECT name, address 
FROM stores 
WHERE name LIKE '%忠孝%';

-- 5. 取得會員電話開頭是 0912 的會員資料
SELECT name, phone 
FROM customers 
WHERE phone LIKE '0912%';

-- 6. 取得會員姓名為「陳」開頭，且剛好是 3 個字的名字 (一個底線 _ 代表剛好一字)
SELECT name, phone, gender 
FROM customers 
WHERE name LIKE '陳__';

-- 7. 使用 ILIKE 不區分大小寫搜尋 (例如搜尋英文品牌或規格)
SELECT name, address 
FROM stores 
WHERE address ILIKE '%sec%';
