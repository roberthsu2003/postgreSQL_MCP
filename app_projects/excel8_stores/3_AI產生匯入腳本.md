# 步驟 3｜AI 產生資料交易檔：用 `raw_sales` 與 `BEGIN ... COMMIT` 歸位第一季樣本

## 📥 本步驟資料與交易下載

- 原始 Excel：[下載 門市月報_需求與樣本.xlsx](./門市月報_需求與樣本.xlsx)，請使用本文指定的資料工作表。
- 純資料參考交易：[下載 store_data.sql](../_teacher_reference/store_data.sql)，包含 `BEGIN … COMMIT`，**不會幫你建表**。

先用自己的 DDL 與 Excel 請 AI 產生交易，再與參考檔核對。要執行參考檔時，先確認目標資料庫正確、已建好表並清空測試資料；下載與執行方法見 [共用操作指南](../學習與操作指南.md)。請保留自己核對通過的 `建立資料.sql`，之後還原資料會用到。

> 有意觸發錯誤的測試請逐句執行，出錯後先 `ROLLBACK;` 再開始下一個實驗。正式載入資料的交易要 `COMMIT`；後面的業務模擬交易最後一律還原，保持初始資料給步驟 4。

> 💻 AI 工具 ＋ DBeaver（資料庫：`store_sales`）｜ 🎯 學完你會：不依賴檔案匯入精靈，請 AI 產生「先寫入暫存表 `raw_sales`，再透過 `INSERT ... SELECT ... ON CONFLICT DO NOTHING` 分流進六張表」的純 SQL 交易檔，並做三方對帳與 `ROLLBACK` 演練

## 1. 請 AI 把第一季樣本轉成純資料交易 SQL

請打開 [`門市月報_需求與樣本.xlsx`](./門市月報_需求與樣本.xlsx) 的 **`給AI的樣本`** 工作表（共 31 筆跨 1、2、3 月的精選交易），連同你在步驟 2 手寫的 7 張 `CREATE TABLE` 結構，複製以下提示詞貼給 AI：

```markdown
這是我已在 store_sales 資料庫親手建好的 7 張表結構：
（貼上你在步驟 2 寫的 7 張 CREATE TABLE 語法）

以下是門市第一季銷售明細 Excel【給AI的樣本】工作表（共 31 筆、22 張訂單）：
（貼上 給AI的樣本 的 31 筆內容）

請幫我產生一份「純資料寫入的 SQL Transaction 交易檔」，嚴格遵守以下規則：
1. 用 BEGIN; 開頭、COMMIT; 結尾，絕對不可包含 DROP TABLE 或 CREATE TABLE。只允許清空本批次暫存區 raw_sales，不能清空六張正式表。
2. 第一步：在交易內先 TRUNCATE raw_sales;，再把這 31 筆資料以純文字寫進 raw_sales；注意「會員電話」空白者（散客）必須寫成不加引號的 NULL。
3. 第二步：在同一個交易內，依序從 raw_sales 用 INSERT INTO ... SELECT DISTINCT ... ON CONFLICT DO NOTHING 寫入六張表：
   - stores (衝突目標 name)
   - staff (JOIN stores 查 store_id，衝突目標 (name, store_id))
   - products (SELECT DISTINCT 商品名稱, 商品分類, 單價::INT，衝突目標 name)
   - customers (WHERE 會員電話 IS NOT NULL，衝突目標 phone)
   - orders (JOIN stores、staff，LEFT JOIN customers ON 會員電話 = phone，並將 銷售日期::DATE、時間::TIME 轉型，衝突目標 order_id)
   - order_items (JOIN products，將 數量::INT、單價::INT 轉型，衝突目標 (order_id, product_id))
4. 不可寫死 store_id、staff_id、product_id、customer_id 數字，全部靠 JOIN 動態對應並搭配 ON CONFLICT DO NOTHING，確保這段 SQL 重複執行也不會出錯或產生重複資料。
```

## 2. 執行前先幫 AI 檢查這 5 件事

收到 AI 產生的 SQL 後，先做一次安全掃描：

- [ ] **交易完整嗎？** 最上面是 `BEGIN;`，最下面是 `COMMIT;`，中間沒有多餘 `DROP/CREATE`
- [ ] **散客電話沒寫死字串嗎？** `會員電話` 空值寫成 `NULL`（不能是 `'NULL'` 或 `''`）
- [ ] **會員表過濾了嗎？** 寫入 `customers` 時有加上 `WHERE 會員電話 IS NOT NULL`，沒有把「散客」當成會員建檔
- [ ] **`orders` 有用 `LEFT JOIN customers` 嗎？** 如果誤用 `INNER JOIN customers`，所有散客訂單會直接蒸發不見！
- [ ] **`staff` JOIN 時有綁定 `store_id` 嗎？** 必須寫 `r.經手店員 = st.name AND st.store_id = s.store_id`，防止不同店剛好出現同名店員時對應錯門市

檢查過關後，貼入 DBeaver 全選並執行 SQL Script（Alt+X）！

> 本課使用 `ON CONFLICT DO NOTHING` 來略過同鍵資料，不會自動更正舊資料。若同一訂單號的金額、會員或狀態與既有資料不同，必須先查明差異，不能把「沒有報錯」當成已更新成功。核對 `raw_sales` 的小計與 `數量::INT * 單價::INT` 是否一致，也能及早發現轉檔錯誤。

## 3. 三方對帳：Excel、DBeaver、Microsoft Postgres MCP

寫入完成後，用 Excel、SQL 與 MCP 三邊核對，確定這 31 筆一塊錢都不差：

| 對帳項目 | Excel `給AI的樣本` 公式（資料列 `2:32`） | 預期結果 |
|---|---|---:|
| 明細總筆數 | `=COUNTA(A2:A32)` | **31** |
| 全部明細小計總和 | `=SUM(M2:M32)` | **3,740** |
| 已完成訂單總金額 | `=SUMIF(O2:O32, "已完成", M2:M32)` | **3,125** |

### 在 DBeaver 執行 SQL 對帳：
```sql
-- 1. 核對各表筆數
SELECT
    (SELECT COUNT(*) FROM raw_sales) AS raw_sales筆數,
    (SELECT COUNT(*) FROM stores) AS 門市數,
    (SELECT COUNT(*) FROM staff) AS 店員數,
    (SELECT COUNT(*) FROM products) AS 商品數,
    (SELECT COUNT(*) FROM customers) AS 會員數,
    (SELECT COUNT(*) FROM orders) AS 訂單張數,
    (SELECT COUNT(*) FROM order_items) AS 明細筆數;

-- 2. 核對金額總數（須完全吻合 Excel 3,740 與 3,125）
SELECT
    COUNT(*) AS 明細筆數,
    COUNT(DISTINCT o.order_id) AS 訂單張數,
    SUM(oi.quantity * oi.unit_price) AS 全部明細小計總和,
    SUM(oi.quantity * oi.unit_price) FILTER (WHERE o.status = '已完成') AS 已完成總金額
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id;
```

預期數字：**5 家門市、10 位店員、12 項商品、10 位會員、22 張訂單、31 筆明細、全部小計 `3,740`、已完成總金額 `3,125`**。

### 用 Microsoft Postgres MCP 做唯讀核對：
```markdown
請使用 Microsoft Postgres MCP（僅限查詢，嚴禁 postgres_mcp_modify）連線至 store_sales 資料庫，查詢 stores、staff、products、customers、orders、order_items、raw_sales 七張表的筆數，並統計所有訂單明細總金額與 status = '已完成' 的金額，幫我確認是否與 Excel 樣本的 22 張單 / 31 筆 / 總計 3,740 / 已完成 3,125 完全一致。
```

## 4. 演練 Transaction 的錯誤回滾保護（`ROLLBACK`）

試想某次轉寫某張新訂單時，訂單主表寫進去了，明細裡卻有一筆數量誤填為 `0`。在 DBeaver 跑以下示範交易看看發生什麼事：

```sql
BEGIN;

-- 1. 先合法寫入一張新訂單主檔 ORD99999
INSERT INTO orders (order_id, order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
SELECT 'ORD99999', DATE '2024-03-31', TIME '12:00', s.store_id, st.staff_id, NULL, '現金', '已完成'
FROM stores s JOIN staff st ON st.store_id = s.store_id
WHERE s.name = '台北信義店' AND st.name = '張志明';

-- 2. 緊接著明細故意寫入數量 0（違反 CHECK (quantity > 0)）
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT 'ORD99999', product_id, 0, price FROM products WHERE name = '經典拿鐵';

-- 此處預期已報錯，接著單獨執行下方的 ROLLBACK。
```

```sql
ROLLBACK;
SELECT * FROM orders WHERE order_id = 'ORD99999';
```

第 2 步的 CHECK 錯誤使整筆交易失敗，還原後查詢為 0 筆，第一步的訂單頭也被撤銷。這個保護以「實際寫入並觸發錯誤」為前提：若 SELECT 查不到商品，會寫入 0 筆而不是報錯，所以仍要核對每一步的受影響筆數。

## 5. 🤖 請 AI 幫你測一個多表商業交易（先在 `ROLLBACK` 保護下看效果）

試著請 AI 寫一段「客人臨櫃點單並開立訂單與兩筆明細」的交易練習檔，先以 `ROLLBACK;` 結尾：

```markdown
請根據我 store_sales 資料庫的結構，寫一個「現場新增一張內含 2 項商品的會員現金訂單」PostgreSQL Transaction 練習（全程用 BEGIN; ... ROLLBACK; 包起來避免污染樣本對帳）：
1. 找台北信義店的張志明結帳，會員為手機 '0936-805-870' 的劉欣宜，單號 'ORD88888'，日期 '2024-03-31' 15:00，狀態 '已完成'。
2. 透過 JOIN products 名稱寫入 '經典拿鐵' 1 杯與 '法式經典可頌' 2 個（unit_price 直接引用商品售價），寫完在交易內查詢該張訂單總金額後立刻 ROLLBACK;。
```

## ⚠️ 常見卡關

| 現象 | 原因 | 怎麼解 |
|---|---|---|
| 執行完散客的訂單不見了 | `orders` 從 `raw_sales` 寫入時用了 `INNER JOIN customers` | 改成 `LEFT JOIN customers c ON r.會員電話 = c.phone` |
| 報錯 `invalid input syntax for type integer: "單價"` | 把標題列也塞進了 `raw_sales` | 清空 `raw_sales` 後只寫入第 2～32 列資料，不要包含第 1 列中文標題 |
| 同樣電話但會員姓名出現重複或對錯人 | `customers` 未去重或沒檢查同電話 | 先 `ROLLBACK;` 並請 AI 使用 `ON CONFLICT (phone) DO NOTHING` |

## ✍️ 動手練

**1. 本次樣本裡會員數共有 10 位，其中有幾位叫「謝哲瑋」、幾位叫「劉欣宜」？資料庫怎麼區分他們？**

<details>
<summary>看答案</summary>

樣本中共有 3 位不同電話的「謝哲瑋」（`0963-728-214`、`0943-645-351`、`0945-239-678`）和 2 位不同電話的「劉欣宜」（`0936-805-870`、`0915-692-794`）。因為 `customers` 以 `phone UNIQUE` 辨識唯一性，每位不同手機的主人都會獲得獨立的 `customer_id`。

</details>

**2. 如果把步驟 1 產生的 31 筆第一季交易檔再重複按一次 Execute SQL Script，會發生什麼事？為什麼？**

<details>
<summary>看答案</summary>

如果在交易最前面先 `TRUNCATE raw_sales;` 再跑一次，核心的 6 張表（門市、店員、商品、會員、訂單、明細）筆數會**完全維持原樣不增加任何一筆**，因為每一張目標表都設了 `ON CONFLICT DO NOTHING`（注意：若沒先清 `raw_sales`，只有 `raw_sales` 暫存區自己會多收 31 筆，所以每月匯入批次開頭都習慣先 `TRUNCATE raw_sales;`）。

</details>

## 🤖 問 AI 助教

> 請解釋為什麼我們在步驟 3 先把 31 筆資料存成全 `TEXT` 的 `raw_sales`，再分成 6 句 `INSERT ... SELECT ... ON CONFLICT DO NOTHING` 寫進核心表；如果將來「4月新銷售明細」多了一位沒聽過的新店員「許淑芬」或新商品「桂花烏龍拿鐵」，這段 SQL 會自己處理好嗎？

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 專案導覽](./README.md) | [步驟 4：報表回答故事 ➡️](./4_報表回答故事.md) |
