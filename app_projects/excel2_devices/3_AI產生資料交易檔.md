# 步驟 3｜AI 產生資料交易檔：把 14 欄寬表打包進 JSONB Transaction

> **本步驟核心：不用匯入現成 `.sql` 救援檔！**  
> 你自己貼上步驟 2 親手建好的 `CREATE TABLE devices (...)` 與 [設備規格表.xlsx](設備規格表.xlsx)，請 AI 幫你轉換成只保留非空屬性、塞進 `JSONB` 的 **`BEGIN; ... COMMIT;` 交易檔**。

---

## 給 AI 的「建立 JSONB 交易檔 Prompt」

附上 [設備規格表.xlsx](設備規格表.xlsx) 的 `設備清單` 工作表，**貼上你在步驟 2 寫的 `CREATE TABLE devices (...)`**，發送這段 Prompt：

```text
請幫我把附件「設備規格表.xlsx」的「設備清單」工作表（共 16 筆），轉成 PostgreSQL 的資料寫入交易檔（純 SQL）。

我的資料表結構如下：
（把你在步驟 2 手寫的 CREATE TABLE devices (...) 貼在這裡）

嚴格轉換規則：
1. 只能輸出交易控制（BEGIN; ... COMMIT;）與 INSERT INTO devices (...) VALUES (...)，禁止任何 CREATE、DROP、ALTER、TRUNCATE，也禁止透過 MCP 直接修改資料庫。
2. 共 7 個欄位：device_id, name, device_type, purchase_date, price, department, specs（JSONB）。
3. 規格（specs）欄位請依設備類型只收錄非空白的欄位，空白的格子絕對不要放進 JSON，也不要填 null：
   - 筆電：cpu（字串）, ram_gb（整數）, screen_inch（整數）
   - 投影機：lumens（整數）, resolution（字串）
   - 印表機：ppm（整數）, duplex（Excel 寫「是」轉 JSON 布林 true，「否」轉 false，不加雙引號）, paper（字串）
4. JSON 裡的鍵與字串值必須用雙引號 " 包住，整個 JSON 字串外層用單引號 ' 包住。
5. 單價 price 請輸出純整數。
```

---

## 執行前自我檢查（特別小心這 4 個 JSONB 地雷）

1. **看頭尾**：有 `BEGIN;` 和 `COMMIT;` 包住整批 `16` 筆 `INSERT` 嗎？
2. **沒有把空白寫進去**：筆電的 JSON 裡面**不該**出現 `"lumens": null` 或 `"duplex": null`，只有 `cpu`、`ram_gb`、`screen_inch` 三個鍵。
3. **數字與布林沒多包雙引號**：確認是 `"ram_gb": 16`、`"duplex": true`（如果變成 `"ram_gb": "16"` 或 `"duplex": "是"` 就叫 AI 重產）。
4. **雙引號格式**：JSON 裡全部都用雙引號 `"`，例如 `'{"cpu": "M3", "ram_gb": 18, "screen_inch": 14}'`。

檢查完成後貼進 DBeaver 新編輯器（存成 `建立資料.sql`）按執行！

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

### ① Excel 公式（在 `設備規格表.xlsx` 的 `設備清單` 工作表）
- 總台數：`=COUNTA(A2:A17)` → **16**
- 採購總金額：`=SUM(E2:E17)` → **466,000**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT COUNT(*) AS 設備總數, SUM(price) AS 採購總金額 FROM devices;
SELECT device_type AS 類型, COUNT(*) AS 台數 FROM devices GROUP BY device_type ORDER BY 台數 DESC;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢（SELECT）幫我核對：
1. devices 總共有幾筆、price 總金額是多少？
2. 依 device_type 分組各有多少台？
3. 幫我抽查 NB-001（筆電）、PJ-001（投影機）、PR-001（印表機）的 specs 欄位，確認有沒有混入多餘的 null 鍵值或文字型別數字。
嚴禁呼叫修改資料庫工具。
```

對上 **16 台**、總金額 **466,000**（筆電 8、投影機 4、印表機 4）才算對帳完成！

---

## ✍️ 動手練（原子性 `ROLLBACK` 測試 ＋ 請 AI 建立資產交易）

1. **交易原子性與 `ROLLBACK` 保護測試**：  
   在 DBeaver 開一個新查詢分頁執行以下「半對半錯」的交易：
   ```sql
   BEGIN;
   -- 第一步正確：將 NB-003 部門改為 資訊技術部
   UPDATE devices SET department = '資訊技術部' WHERE device_id = 'NB-003';
   -- 第二步故意違法：把 PJ-001 單價設成 -500（違反 CHECK）
   UPDATE devices SET price = -500 WHERE device_id = 'PJ-001';
   ```
   看到 `violates check constraint "devices_price_check"` 後立刻執行：
   ```sql
   ROLLBACK;
   SELECT device_id, department FROM devices WHERE device_id = 'NB-003';
   ```
   <details>
   <summary>👀 應該看到什麼？</summary>

   `NB-003` 的 `department` 依然是原本的 **`業務發展部`**，證明同一個交易裡的任何錯誤都會連帶保護第一步不會意外生效！
   </details>

2. **請 AI 幫你寫「批次設備調撥 ＋ 升級」業務交易 Prompt**：  
   假設業務發展部要把 `NB-004` 調撥給「行銷企劃部」，同時幫 `PJ-001` 在 JSONB 規格裡加上保養日期 `"calibrated_at": "2024-04-01"`，請貼上這段 Prompt 讓 AI 寫出安全交易（測試完先 `ROLLBACK;`）：
   ```text
   請根據 devices 資料表（含 JSONB specs），寫一個 PostgreSQL 交易（不要用 MCP 寫入，只給我 SQL）：
   1. 用 BEGIN; 開頭，最後幫我加上 SELECT 查詢受影響設備並附上 -- ROLLBACK; 讓我先測試不破壞資料。
   2. 交易動作：
      - 將 NB-004 的 department 改為 '行銷企劃部'
      - 用 jsonb_set 替 PJ-001 的 specs 加上 '"calibrated_at": "2024-04-01"'
   ```
   <details>
   <summary>👀 參考答案（測試完請執行 ROLLBACK;）</summary>

   ```sql
   BEGIN;

   UPDATE devices
   SET department = '行銷企劃部'
   WHERE device_id = 'NB-004';

   UPDATE devices
   SET specs = jsonb_set(specs, '{calibrated_at}', '"2024-04-01"')
   WHERE device_id = 'PJ-001';

   SELECT device_id, department, specs
   FROM devices
   WHERE device_id IN ('NB-004', 'PJ-001')
   ORDER BY device_id;

   ROLLBACK;
   ```
   </details>

---

## 🤖 問 AI 助教（JSONB 常見轉換錯誤）

```text
我在執行你生成的 devices 交易檔時遇到 JSON 格式錯誤（或型別錯誤），錯誤訊息如下：
（貼上完整 ERROR 訊息與該筆 INSERT）
請幫我檢查雙引號、數字、布林值以及 SQL 單引號有沒有哪裡錯了，並輸出修正後的完整 BEGIN ... COMMIT 交易檔（不要用 MCP 寫入）。
```

---

👉 **對帳成功！前往 [步驟 4｜10 題 JSONB 實戰練功與 MCP 雙軌驗證](4_JSONB回答故事.md)**
