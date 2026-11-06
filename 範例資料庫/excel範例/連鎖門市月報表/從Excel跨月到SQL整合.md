# 職場實戰：從「Excel 每月複製檔案」到「SQL 資料庫整合」

在一般企業、連鎖門市或業務部門，最常見的資料管理方式就是**「用 Excel 檔案記帳」**：
每到月底，行政或店長就把上個月的檔案複製一份，改個檔名（如 `門市銷售明細_202401.xlsx` 複製成 `門市銷售明細_202402.xlsx`），然後繼續手動打字填寫。

本單元透過 **3 個月份的連鎖咖啡門市 Excel 實體檔案**，帶你親身體驗 Excel 檔案管理的崩潰極限，並示範如何用 **PostgreSQL / Supabase 輕鬆解決！**

---

## 📁 範例檔案

本資料夾內提供 3 個月份的真實模擬 Excel 與合併 CSV：
1. 📄 **[門市銷售明細_202401.xlsx](./門市銷售明細_202401.xlsx)**（1 月份，225 筆明細）
2. 📄 **[門市銷售明細_202402.xlsx](./門市銷售明細_202402.xlsx)**（2 月份過年檔期，313 筆明細）
3. 📄 **[門市銷售明細_202403.xlsx](./門市銷售明細_202403.xlsx)**（3 月份，244 筆明細）
4. 📊 **[門市銷售明細_2024Q1_全部.csv](./門市銷售明細_2024Q1_全部.csv)**（整季合併檔，共 782 筆，適合練習 CSV 匯入）

對應的一鍵建庫 SQL 腳本位於：
👉 **[`cafe_shop.sql`](../../中文範例資料庫/cafe_shop.sql)**（包含門市、員工、商品、會員、訂單與明細的完整正規化結構與資料，約 55 KB，可直接貼上 Supabase 執行）。

---

## 1. 職場 Excel 的 4 大痛點

請試著打開這 3 個 Excel 檔案，如果老闆今天提出以下需求，你會怎麼做？

### 痛點一：跨月份統計超級麻煩（跨檔案公式容易損毀）
> **老闆問**：「請給我第一季（1~3月）各門市的總營收與月成長率？」

* **在 Excel 中**：
  你必須同時開啟 3 個檔案，在每個檔案裡做加總，再開第 4 個「季報表.xlsx」，用跨工作簿公式引用（如 `='[門市銷售明細_202401.xlsx]2024-01門市明細'!$M$226`）。只要檔案改名、路徑移動或有人不小心動到列數，整個季報表直接全變 `#REF!`！
* **在 SQL 中**：
  在資料庫裡，**時間只是一個欄位（`order_date`）**，根本不用分檔案！
  ```sql
  -- 一條 SQL 產出各門市 1~3 月營業額
  SELECT 
      s.name AS 門市,
      TO_CHAR(o.order_date, 'YYYY-MM') AS 月份,
      SUM(i.quantity * i.unit_price) AS 月營業額
  FROM orders o
  JOIN stores s ON o.store_id = s.store_id
  JOIN order_items i ON o.order_id = i.order_id
  WHERE o.status = '已完成'
  GROUP BY s.name, TO_CHAR(o.order_date, 'YYYY-MM')
  ORDER BY s.name, 月份;
  ```

---

### 痛點二：手動輸入導致「文字不一致」，報表直接失真
* **在 Excel 中**：
  員工人工輸入品名，容易出現打錯字、全形半形不一（例如「美式咖啡」被手誤打成「美式 咖啡」或「美式」）。Excel 樞紐分析會把它們當成兩項完全不同的商品，銷量統計直接失真。
* **在 SQL 中**：
  透過「商品表（`products`）」規範 `product_id`，訂單明細只能關聯既有商品編號（外來鍵 Foreign Key），**徹底杜絕打錯字**。

---

### 痛點三：找出「每個月都來消費的忠實 VIP」極度困難
> **行銷主管問**：「1月、2月、3月都有來門市消費的常客有誰？我們想發送專屬優惠券。」

* **在 Excel 中**：
  你得在 3 個檔案之間反覆使用 `VLOOKUP` 或 `COUNTIF` 對比電話號碼，如果資料有幾萬列，電腦直接卡死。
* **在 SQL 中**：
  使用 `GROUP BY` 與 `HAVING`，兩秒鐘找出忠誠顧客：
  ```sql
  -- 找出 1~3 月每個月都至少消費一次的忠誠會員
  SELECT 
      c.name AS 會員姓名,
      c.phone AS 電話,
      COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) AS 消費月份數,
      SUM(i.quantity * i.unit_price) AS 第一季累計消費
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  JOIN order_items i ON o.order_id = i.order_id
  WHERE o.status = '已完成'
  GROUP BY c.customer_id, c.name, c.phone
  HAVING COUNT(DISTINCT TO_CHAR(o.order_date, 'YYYY-MM')) = 3
  ORDER BY 第一季累計消費 DESC;
  ```

---

### 痛點四：檔案變多、資料變大，Excel 崩潰當機
當門市從 5 家擴張到 50 家，每個月訂單有十幾萬筆時：
* Excel 超過 10 萬列時，滾輪卡頓、存檔要等 1 分鐘、隨時可能當機崩潰。
* 雲端資料庫（PostgreSQL）儲存數百萬筆資料依然游刃有餘，搭配索引（Index）查詢依然毫秒級回應。

---

## 2. 資料結構對照表：從 Excel 欄位到關聯資料庫

| Excel 原始欄位 | 關聯資料庫正規化拆分 | 資料表與欄位 |
| :--- | :--- | :--- |
| `門市名稱`, `區域` | 獨立出「門市表」 | `stores` (`name`, `region`, `address`, `phone`) |
| `經手店員` | 獨立出「員工表」 | `staff` (`name`, `title`, `store_id`, `salary`) |
| `商品分類`, `商品名稱`, `單價` | 獨立出「商品表」與「分類表」 | `products` (`name`, `price`, `cost`), `categories` |
| `會員姓名`, `會員電話` | 獨立出「會員表」 | `customers` (`name`, `phone`, `gender`) |
| `銷售單號`, `銷售日期`, `時間`, `付款方式` | 記錄為「訂單主檔」 | `orders` (`order_date`, `order_time`, `store_id`, `staff_id`, `customer_id`) |
| `商品名稱`, `單價`, `數量`, `小計` | 記錄為「訂單明細」 | `order_items` (`order_id`, `product_id`, `quantity`, `unit_price`) |

---

## 3. 在 Supabase 或 DBeaver 中的快速起步

### 步驟 A：一秒建置資料庫
1. 開啟你的 Supabase 專案，點擊左側選單的 **SQL Editor**。
2. 開啟 [`cafe_shop.sql`](../../中文範例資料庫/cafe_shop.sql)，將內容全部複製貼上。
3. 點擊右下角的 **Run** 按鈕。
4. **不到 1 秒鐘**，7 張資料表與整季的完整真實資料即建置完成！

### 步驟 B：體驗 10 萬筆巨量資料查詢（選用）
若你想在課堂上體驗大數據查詢的效能與索引（Index）的威力，**完全不需要下載幾十 MB 的大檔案**：
1. 在 Supabase SQL Editor 中開啟並執行 [`generate_100k_orders.sql`](../../中文範例資料庫/generate_100k_orders.sql)。
2. 利用 PostgreSQL 內建的 `generate_series()` 引擎，**只需 1~2 秒**，資料庫就會自體生成 50,000 筆訂單與 100,000 筆明細！

