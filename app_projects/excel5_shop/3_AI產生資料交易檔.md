# 步驟 3｜AI 產生資料交易檔：拆出四表與歷史／目前雙價位 Transaction

> **本步驟核心：不用匯入現成 `.sql` 救援檔！**  
> 這張 Excel 有兩項設計細節要交給 AI 在產出交易檔時特別注意：**誰該是目前售價 `products.price`**、**誰又是當時成交價 `order_items.unit_price`**，以及**沒有訂單的新會員「張大同」和沒賣出的新商品「輕量登山背包」絕對不能遺漏**！

---

## 給 AI 的「多對多 ＋ 雙價位交易檔 Prompt」

附上 [網路商店訂單表.xlsx](網路商店訂單表.xlsx)（`全部訂單` 工作表），貼上你在步驟 2 手寫的四句 `CREATE TABLE`，發送這段 Prompt：

```text
請幫我把附件「網路商店訂單表.xlsx」的「全部訂單」工作表，轉換成 PostgreSQL 的多對多資料寫入交易檔（純 SQL）。

我的四張資料表結構如下：
（把你在步驟 2 寫的四句 CREATE TABLE 貼在這裡）

嚴格轉換與判斷規則：
1. 只能輸出交易控制（BEGIN; ... COMMIT;）、INSERT 語法與對齊 SERIAL 的 SELECT setval(...)，禁止 CREATE、DROP、ALTER、TRUNCATE，也禁止透過 MCP 修改資料庫。
2. 同一個商品在表裡出現過不同單價（例如保溫鋼杯 450 與 490、無線藍牙耳機 1290 與 1190）：
   - products.price 請填入該商品「依訂單日期來看最後出現的目前最新售價」（保溫鋼杯 490、無線藍牙耳機 1190）。
   - order_items.unit_price 請忠實保留每一張訂單「當時的成交單價」（如 1001 保溫鋼杯仍是 450、1007 才是 490）。
3. 不可漏掉最後兩列沒有配對的獨立資料：
   - 商品「輕量登山背包」（戶外休閒，售價 1580）必須放進 products。
   - 會員「張大同」（高雄市，datong@example.com）必須放進 customers。
4. 寫入順序：customers（5 筆）→ products（7 筆）→ SELECT setval(...) 到 5 與 7 → orders（1001～1010 共 10 筆）→ order_items（16 筆）。
```

---

## 執行前自我檢查（花 30 秒檢查這 4 點）

1. **獨立的兩人一包都在嗎**：`customers` 有第 5 位 `張大同`；`products` 有第 7 項 `輕量登山背包`。
2. **雙價位保留了嗎**：`products` 裡的保溫鋼杯是 `490`、耳機是 `1190`；但 `order_items` 裡訂單 `1001` 保溫鋼杯依然是 `450`、訂單 `1004` 耳機是 `1290`。
3. **`setval` 存在嗎**：`customers` 調成 `5`，`products` 調成 `7`。
4. **整批包進交易**：開頭 `BEGIN;`，結尾 `COMMIT;`。

檢查完成後貼進 DBeaver 新編輯器（存成 `建立資料.sql`）按執行！

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

### ① Excel 公式（在 `網路商店訂單表.xlsx` 的 `全部訂單` 驗算）
- 有效明細列數（2～17 列）：**16 筆**
- 全部明細總金額：`=SUM(L2:L17)` → **12,080**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT
    (SELECT COUNT(*) FROM customers)   AS 會員數,
    (SELECT COUNT(*) FROM products)    AS 商品數,
    (SELECT COUNT(*) FROM orders)      AS 訂單數,
    (SELECT COUNT(*) FROM order_items) AS 明細數,
    (SELECT SUM(quantity * unit_price) FROM order_items) AS 全部明細總金額;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 online_shop 資料庫，只用唯讀查詢（SELECT）幫我核對：
1. customers(5)、products(7)、orders(10)、order_items(16) 與 SUM(quantity * unit_price) 總金額（是否為 12080？）。
2. 抽查保溫鋼杯在 products.price 是 490，且在訂單 1001 明細中的 unit_price 依然是 450。
嚴禁呼叫任何修改或寫入工具。
```

---

## ✍️ 動手練（原子性 `ROLLBACK` 保護 ＋ 請 AI 產生多品項建單交易）

1. **故意「建訂單寫到一半明細數量填 `0`」測原子性**：  
   在 DBeaver 開新分頁試著跑以下這筆包含「訂單主檔 ＋ 一筆正確明細 ＋ 一筆錯誤明細」的交易：
   ```sql
   BEGIN;
   INSERT INTO orders VALUES (1098, 5, '2024-04-05', '信用卡', '處理中');
   INSERT INTO order_items VALUES (1098, 7, 1, 1580);
   -- 第二項故意數量填 0（違反 CHECK quantity > 0）
   INSERT INTO order_items VALUES (1098, 2, 0, 890);
   ```
   遇到 `violates check constraint "order_items_quantity_check"` 後執行 `ROLLBACK;`，再查 `SELECT * FROM orders WHERE order_id = 1098;` —— **整張 `1098` 訂單與第一筆明細都不會留下，完美避免「有頭無尾」的半殘訂單！**

2. **請 AI 幫你寫「用 `SELECT` 自動帶入目前售價建單」交易 Prompt**：  
   不要自己手動抄商品金額！讓 AI 用 `INSERT INTO order_items ... SELECT ... FROM products` 直接把目前的售價複製當成交單價，測試完用 `ROLLBACK;` 復原：
   ```text
   請根據我建立的 online_shop 四張表，撰寫一個 PostgreSQL 交易（不要用 MCP 寫入，只給我 SQL）：
   1. 用 BEGIN; 開頭，最後幫我加上兩張表的 JOIN 查詢結果，並附上 ROLLBACK; 方便我在 DBeaver 試跑而不影響步驟 4。
   2. 交易內幫會員張大同（customer_id = 5）建立一張新訂單 1088（日期 2024-04-02、LINE Pay、處理中），購買：
      - 陶瓷咖啡杯（qty 2）
      - 筆記本組合（qty 3）
   3. 明細的 unit_price 不可寫死數字，必須用 INSERT INTO order_items ... SELECT ... FROM products 自動帶入商品目前的 price！
   ```
   <details>
   <summary>👀 參考答案（試跑完自動回滾）</summary>

   ```sql
   BEGIN;

   INSERT INTO orders (order_id, customer_id, order_date, payment_method, status)
   VALUES (1088, 5, '2024-04-02', 'LINE Pay', '處理中');

   INSERT INTO order_items (order_id, product_id, quantity, unit_price)
   SELECT 1088, product_id, qty, price
   FROM (VALUES ('陶瓷咖啡杯', 2), ('筆記本組合', 3)) AS cart(prod_name, qty)
   JOIN products p ON p.name = cart.prod_name;

   SELECT o.order_id, p.name, oi.quantity, oi.unit_price, (oi.quantity * oi.unit_price) AS 小計
   FROM orders o
   JOIN order_items oi ON o.order_id = oi.order_id
   JOIN products p     ON oi.product_id = p.product_id
   WHERE o.order_id = 1088;

   ROLLBACK;

   SELECT COUNT(*) AS 復原後訂單數 FROM orders; -- 應仍為 10
   ```
   </details>

---

## 🤖 問 AI 助教（雙價位或 `setval` 卡關診斷）

```text
我在 DBeaver 執行你產生的 online_shop 資料交易檔時遇到以下錯誤：
（貼上錯誤訊息與附近行數）
請不要用 MCP 修改資料庫，先告訴我是哪張表的關聯順序錯了、還是商品／訂單數量不符規定，再給我修正後的完整 SQL。
```

---

👉 **四表對帳完美通過！前往 [步驟 4｜10 題訂單 DML 實戰練功與 MCP 雙軌驗證](4_訂單查詢回答故事.md)**
