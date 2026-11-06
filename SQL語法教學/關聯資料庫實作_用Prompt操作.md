# 關聯資料庫實作：運用 MCP 產生建議 SQL (學生手動執行)

> 💡 **核心教學規範**：  
> 本篇貫穿使用繁體中文範例庫 **[`cafe_shop.sql`](../範例資料庫/中文範例資料庫/cafe_shop.sql)**。  
> 學生在學習每一課的 SQL 後，可複製下方的 Prompt 向 AI 提問。AI 會透過 MCP 檢查資料庫真實結構，為你**提供標準建議 SQL 與邏輯解說**；學生需**親自將 SQL 複製到 DBeaver 手動執行並驗證結果**，達到真正扎實的 SQL 練功目的！

---

## 目錄

- [8. 新增關聯資料](#8-新增關聯資料)
- [9. 搜尋關聯資料](#9-搜尋關聯資料)
- [10. 聚合函式與分組 (GROUP BY & HAVING)](#10-聚合函式與分組-group-by--having)
- [11. 萬用字元模糊比對 (LIKE)](#11-萬用字元模糊比對-like)
- [12. 聯集 (UNION)](#12-聯集-union)
- [13. 多表連接 (JOIN)](#13-多表連接-join)
- [14. 子查詢 (Subquery)](#14-子查詢-subquery)
- [15. 外來鍵連鎖動作 (ON DELETE)](#15-外來鍵連鎖動作-on-delete)

---

## 8. 新增關聯資料

📖 對照單元：[`8新增關聯資料庫資料.sql`](./8新增關聯資料庫資料.sql)

### Prompt 1：觀察外來鍵順序錯誤
> **提問 Prompt**：  
> 「在目前的 `cafe_shop` 資料庫中，如果我直接新增一筆訂單明細 `order_items`，但該訂單編號或商品編號根本不存在，PostgreSQL 會回傳什麼錯誤？請透過 MCP 檢查外來鍵後，給我一段測試的錯誤 INSERT SQL，由我在 DBeaver 中手動執行體會防呆保護。」

### Prompt 2：依正確關聯順序新增一整組訂單
> **提問 Prompt**：  
> 「顧客『陳小華』今天在『台北忠孝店』向『張店長』點了 2 杯『拿鐵咖啡』與 1 個『肉桂可頌』，以信用卡結帳。請給我一份完整的 SQL 交易區塊（包含 BEGIN; 新增 orders、新增 order_items、最後 COMMIT;），我會在 DBeaver 中親自執行驗證。」

---

## 9. 搜尋關聯資料

📖 對照單元：[`9搜尋關聯資料庫.sql`](./9搜尋關聯資料庫.sql)

| # | 學生提問 Prompt 範例 | AI 建議 SQL 核心重點 | 驗證目標 |
|:---:|---|---|---|
| 1 | 「請給我查詢全台灣所有門市名稱、所在縣市與聯絡電話的 SQL。」 | `SELECT name, city, phone FROM stores;` | 掌握特定欄位選取 |
| 2 | 「請給我查詢所有商品並按售價由高到低排行的 SQL 前 5 名。」 | `ORDER BY price DESC LIMIT 5;` | 掌握降冪排序與筆數限制 |
| 3 | 「顧客在我們門市使用過哪些不重複的付款方式？」 | `SELECT DISTINCT payment_method FROM orders;` | 掌握 `DISTINCT` 去重 |

---

## 10. 聚合函式與分組 (GROUP BY & HAVING)

📖 對照單元：[`10聚合函式.sql`](./10聚合函式.sql)

### Prompt 1：各門市營收排行
> **提問 Prompt**：  
> 「請給我一條 SQL，計算出 2024 年 Q1 各門市的『總銷售金額』與『總訂單數』，並依營收由高到低排序，我會在 DBeaver 中手動執行。」

### Prompt 2：使用 HAVING 抓出熱門商品
> **提問 Prompt**：  
> 「如何使用 `GROUP BY` 與 `HAVING`，篩選出全季累計售出超過 50 份的熱門商品清單？請給我建議語法。」

---

## 11. 萬用字元模糊比對 (LIKE)

📖 對照單元：[`11萬用字元.sql`](./11萬用字元.sql)

### Prompt 1：模糊搜尋拿鐵商品
> **提問 Prompt**：  
> 「我想搜尋商品名稱中所有『拿鐵』系列的飲品，不論字位在前面或中間。請給我使用 `LIKE` 萬用字元的 SQL 查詢語法。」

### Prompt 2：搜尋特定縣市門市
> **提問 Prompt**：  
> 「門市地址欄位中，如何篩選出位於『台北市』且路名包含『忠孝』的分店？請給我標準 SQL 語法。」

---

## 12. 聯集 (UNION)

📖 對照單元：[`12聯集.sql`](./12聯集.sql)

### Prompt：合併通訊錄
> **提問 Prompt**：  
> 「我想將 `staff` 表中的員工電話與 `customers` 表中的會員電話，合併為一張包含『名稱、電話、身分』的大通訊錄，並使用 `UNION ALL`。請給我建議的 SQL 語法。」

---

## 13. 多表連接 (JOIN)

📖 對照單元：[`JOIN.md`](./JOIN.md) 與 [`13連結.sql`](./13連結.sql)

### Prompt 1：跨 3 表查詢訂單明細
> **提問 Prompt**：  
> 「請給我一條將 `order_items`、`orders`、`stores`、`products` 串連在一起的四表 JOIN 查詢，列出每筆明細的訂單編號、門市名稱、商品名稱、數量與小計，我會在 DBeaver 中手動執行。」

### Prompt 2：找出從未消費過的會員 (LEFT JOIN)
> **提問 Prompt**：  
> 「如何用 `LEFT JOIN ... WHERE ... IS NULL` 抓出資料庫中註冊至今從未下單過的幽靈會員名單？請給我建議語法。」

---

## 14. 子查詢 (Subquery)

📖 對照單元：[`14子查詢.sql`](./14子查詢.sql)

### Prompt 1：高於全體平均的優質訂單
> **提問 Prompt**：  
> 「請給我一條使用子查詢的 SQL，找出訂單金額大於全店『平均訂單金額』的高價值訂單清單。」

### Prompt 2：找出從未被購買過的冷門商品
> **提問 Prompt**：  
> 「如何使用 `WHERE product_id NOT IN (SELECT product_id FROM order_items)` 找出完全沒賣出過的品項？請給我建議 SQL。」

---

## 15. 外來鍵連鎖動作 (ON DELETE)

📖 對照單元：[`15on_delete_action.sql`](./15on_delete_action.sql)

### Prompt：連鎖刪除驗證
> **提問 Prompt**：  
> 「請為我設計一組迷你測試資料表，示範在 `orders` 與 `order_items` 之間設定 `ON DELETE CASCADE`。當我手動在 DBeaver 執行 `DELETE FROM orders WHERE order_id = 101` 時，該訂單的商品明細會如何自動被連鎖清除？請給我完整 DDL 與測試 SQL。」

---

## 🏢 五大職場核心範例庫提問錦囊

學員若要針對自己的工作領域進行 SQL 練功，可直接複製以下職場專屬 Prompt 向 AI 請教：

| 職場職務 | 對應資料庫檔案 | 學生可複製提問的 Prompt 範例 |
|---|---|---|
| 💼 **會計 / 出納** | [`expense_tracker.sql`](../範例資料庫/中文範例資料庫/expense_tracker.sql) | 「我在 DBeaver 匯入了 `expense_tracker` 資料庫，請給我一條 SQL，計算出 2024 年各部門核准報銷總金額，並與部門年度預算比對，篩選出預算使用率超過 80% 的部門清單。」 |
| 👥 **人資 (HR)** | [`hr_attendance.sql`](../範例資料庫/中文範例資料庫/hr_attendance.sql) | 「請以 `hr_attendance` 資料庫為例，寫出一條使用 `CASE WHEN` 統計每位員工當月『遲到次數』與『總加班時數』的 SQL，我會在 DBeaver 中執行。」 |
| 🏢 **總務 / 倉管** | [`assets_inventory.sql`](../範例資料庫/中文範例資料庫/assets_inventory.sql) | 「請以 `assets_inventory` 資料庫為例，寫出找出『目前借出中且已超過應歸還日期的設備與借用人清單』，以及計算目前逾期天數的 SQL 語法。」 |
| ☕ **店長 / 營運** | [`cafe_shop.sql`](../範例資料庫/中文範例資料庫/cafe_shop.sql) | 「請給我一條將 2024 年各門市營業額按月份展開（跨月樞紐或分組），並統計各商品銷售佔比的 SQL。」 |
| 🛒 **業務 / 電商** | [`shop.sql`](../範例資料庫/中文範例資料庫/shop.sql) | 「請以 `shop` 資料庫為例，寫出一條 SQL，計算出各客戶的最後下單日期、下單總次數與總消費金額（RFM 模型），我會在 DBeaver 中手動驗證。」 |
