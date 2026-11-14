# 步驟 3｜AI 產生資料交易檔：把 Excel 寫進 `BEGIN ... COMMIT` 交易

> **本步驟核心：不用匯入現成 `.sql`、也不用 CSV 匯入精靈！**  
> 資料表是你自己在步驟 2 手寫的，現在要**由你親自把自己的 `CREATE TABLE` ＋ `耗材庫存表.xlsx` 交給 AI**，請 AI 產出標準的 **SQL Transaction 交易檔**，經你檢查無誤後在 DBeaver 執行。

---

## 為什麼要包成「交易（Transaction）」？

把 25 筆資料塞進 `BEGIN; ... COMMIT;` 裡面有三層意義：
1. **全有或全無（原子性）**：只要第 18 筆有錯（例如型別錯、違反 `CHECK`），整批寫入會停止並全部 `ROLLBACK`，不會留下一半半殘的資料。
2. **與日常業務一致**：往後領用耗材、調整單價、批次補貨全部都要靠交易保護，現在先看懂交易的長相。
3. **純手寫驗證**：SQL 在你的畫面上看得到每一行，確認無誤才送給資料庫。

---

## 給 AI 的「建立交易檔 Prompt」

打開聊天視窗，附上 [耗材庫存表.xlsx](耗材庫存表.xlsx) 的 `耗材庫存` 工作表，**貼上你在步驟 2 親手寫好的 `CREATE TABLE supplies (...)` 語法**，並發送這段 Prompt：

```text
請幫我把附件「耗材庫存表.xlsx」裡的「耗材庫存」工作表（25 筆），轉成 PostgreSQL 的資料寫入交易檔（純 SQL）。

我的資料表定義如下：
（把你在步驟 2 寫的 CREATE TABLE supplies (...) 貼在這裡）

嚴格規則：
1. 只能產生交易控制（BEGIN; ... COMMIT;）和 INSERT INTO supplies (...) VALUES (...)，禁止任何 CREATE、DROP、ALTER、TRUNCATE 指令。
2. 不可自行透過 MCP 修改或寫入資料庫，請直接輸出 SQL 文字讓我審查後自行在 DBeaver 執行。
3. Excel 裡「規格（spec）」或「最後盤點日（last_checked）」空白的儲存格，SQL 必須寫成 NULL（不加引號），不可寫成空字串 '' 或 'NULL'。
4. 單價、現有庫存、安全庫存必須是不帶千分位逗號的純整數。
5. 日期格式請轉成 'YYYY-MM-DD'，字串內的單引號若有需要請正確跳脫。
```

---

## 執行前自我檢查（花 30 秒看這 5 點，能抓出 9 成 AI 小毛病）

1. **開頭與結尾**：有 `BEGIN;` 開頭、`COMMIT;` 結尾嗎？中間有偷渡 `DROP TABLE` 或 `CREATE TABLE` 嗎？
2. **共 25 筆**：數一下 `VALUES` 括號是不是從 `MAT-P-A470` 到 `CLN-WIPE-80` 共 25 筆？
3. **空白變 `NULL`**：檢查 `STA-MRK-BK`（白板筆 黑色）的 `spec` 是 `NULL` 而不是 `''`；檢查 `STA-TAPE-18`（透明膠帶）和 `CLN-ALC-500`（75% 酒精）的 `last_checked` 是 `NULL`。
4. **數字沒引號**：`unit_price`、`current_stock`、`safety_stock` 不加單引號（例如 `650, 3, 5`）。
5. **類別字完全一致**：只有 `'紙張'`、`'碳粉墨水'`、`'文具'`、`'清潔用品'` 四種，沒有被 AI 擅自翻譯或改字。

檢查沒問題後，請在 DBeaver 打開新 SQL 編輯器，另存為 `建立資料.sql`，貼進去按「執行 SQL 腳本」（`Alt+X` / `Cmd+Enter` 選取全部）。

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

寫入完成後，用下面三個管道核對三個核心數字是否完全一致：

### ① Excel 公式（在 `耗材庫存表.xlsx` 的 `耗材庫存` 工作表驗算）
- 品項數：`=COUNTA(A2:A26)` → **25**
- 總庫存數量：`=SUM(G2:G26)` → **546**
- 庫存總金額：`=SUMPRODUCT(F2:F26, G2:G26)` → **66,474**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT
    COUNT(*)                         AS 品項數,
    SUM(current_stock)               AS 總庫存數量,
    SUM(unit_price * current_stock)  AS 庫存總金額
FROM supplies;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（SELECT）幫我計算 supplies 資料表目前的：
1. 總筆數（品項數）
2. 所有現有庫存的加總
3. 每項「單價 * 現有庫存」的總金額
4. NULL 值筆數（spec 為 NULL 的筆數、last_checked 為 NULL 的筆數）
請列出結果表格與你執行的 SQL，嚴禁修改資料庫。
```

**三個數字完全對上 `25`、`546`、`66,474`（且 spec 與 last_checked 各有 2 筆 NULL）才算對帳過關！**

---

## ✍️ 動手練（體驗 Transaction 原子性 ＋ 請 AI 設計業務交易）

1. **原子性與 `ROLLBACK` 保護測試**：  
   在 DBeaver 開一個新查詢分頁（**不要影響原本已寫好的 `建立資料.sql`**），執行以下「一半正確、一半刻意觸發錯誤」的交易：
   ```sql
   BEGIN;
   -- 第一步正確：幫藍色原子筆補貨 10 支（180 -> 190）
   UPDATE supplies SET current_stock = current_stock + 10 WHERE item_code = 'STA-PEN-B05';
   -- 第二步故意違法：把類別改成不存在的 '雜項'
   UPDATE supplies SET category = '雜項' WHERE item_code = 'STA-PEN-B05';
   ```
   此時 PostgreSQL 會報錯 `violates check constraint "supplies_category_check"`，整個交易進入失敗狀態。請接著執行：
   ```sql
   ROLLBACK;
   SELECT item_code, current_stock, category FROM supplies WHERE item_code = 'STA-PEN-B05';
   ```
   <details>
   <summary>👀 應該看到什麼？</summary>

   `STA-PEN-B05` 的 `current_stock` 仍然是 **`180`**，而不是 `190`！這就是交易保護的威力：第一步雖然先執行成功，但只要整筆交易沒能全部完成並 `COMMIT`，就全部自動回到原本狀態。
   </details>

2. **請 AI 幫你寫多步驟「業務交易」Prompt 實作**：  
   假設今天總務要一次處理三件事：同事領走 `2 箱` A4 80g 影印紙（`MAT-P-A480`）、同時領走 `3 包` A4 資料夾（`STA-FOLD-A4`），而且要把透明膠帶（`STA-TAPE-18`）的 `last_checked` 更新成今天（`CURRENT_DATE`）。請試著用下面這段 Prompt 讓 AI 產出交易 SQL，在 DBeaver 執行後先查出更新後結果，再用 `ROLLBACK;` 復原以免影響步驟 4 的初始數字！
   ```text
   請根據 supplies 資料表結構，幫我撰寫一個 PostgreSQL Transaction（不要用 MCP 寫入，只給我 SQL）：
   1. 用 BEGIN 開頭，但最後先不要自動寫 COMMIT;，改在最後加上查詢三項品號的 SELECT 與一句註解掉的 -- ROLLBACK; 方便我在 DBeaver 測試確認沒問題後才自行決定 COMMIT 或 ROLLBACK。
   2. 交易內容：
      - MAT-P-A480 扣庫存 2，並加上防護條件確保扣完不會失敗或清楚呈現原本數量檢查
      - STA-FOLD-A4 扣庫存 3
      - STA-TAPE-18 將 last_checked 設為 CURRENT_DATE
   ```
   <details>
   <summary>👀 參考答案（測試完記得執行 ROLLBACK; 復原！）</summary>

   ```sql
   BEGIN;

   UPDATE supplies
   SET current_stock = current_stock - 2
   WHERE item_code = 'MAT-P-A480';

   UPDATE supplies
   SET current_stock = current_stock - 3
   WHERE item_code = 'STA-FOLD-A4';

   UPDATE supplies
   SET last_checked = CURRENT_DATE
   WHERE item_code = 'STA-TAPE-18';

   SELECT item_code, name, current_stock, last_checked
   FROM supplies
   WHERE item_code IN ('MAT-P-A480', 'STA-FOLD-A4', 'STA-TAPE-18')
   ORDER BY item_code;

   -- 練習測試完請執行下方指令復原，保持 25 筆初始狀態給步驟 4！
   ROLLBACK;
   ```
   </details>

---

## 🤖 問 AI 助教（常見資料卡關解法）

如果你的交易檔執行的時候出現 `syntax error` 或 `check constraint` 報錯，不要盲目重試，把**完整錯誤訊息**與出錯前後 5 行貼給 AI：

```text
我在 DBeaver 執行你幫我產生的 supplies 資料交易檔時，PostgreSQL 回傳以下錯誤：
（貼上完整 ERROR 訊息與行數）

這是出錯那一行附近的 SQL：
（貼上該筆 INSERT 語法）

請不要用 MCP 修改資料庫，先告訴我為什麼錯、是哪個欄位不符型別或 CHECK 規則，並給我修正後的完整 BEGIN ... COMMIT 交易檔。
```

---

👉 **對帳完成且資料乾淨無誤了嗎？前往 [步驟 4｜10 題 DML 實戰練功與 MCP 雙軌驗證](4_DML回答故事.md)**
