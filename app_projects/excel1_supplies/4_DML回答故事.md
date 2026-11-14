# 步驟 4｜10 題 DML 實戰練功 ＋ Microsoft Postgres MCP 雙軌驗證

> **學習節奏（三步練功循環）**：  
> **① 自己動手寫**：在 DBeaver 打開一個新查詢分頁（可存成 `我的查詢.sql`），只看「題目與驗收條件」先寫 SQL 執行。  
> **② 核對標準答案**：寫出來（或卡住想不通）再點開 `<details>` 核對參考 SQL 與預期結果表。  
> **③ 用 Microsoft Postgres MCP 驗證**：複製該題附帶的 **MCP 查詢／驗證 Prompt** 給 AI，讓 AI 用 `@microsoft/postgres-mcp` 唯讀連線你的 `supplies` 資料庫，比較 AI 查到的結果是否和你的手寫 SQL 100% 吻合！
>
> **關於資料狀態的特別說明**：
> - **Part A（S1～S5）** 會照故事順序執行（包含 S3 領用黑色原子筆 `45 → 43`，使總庫存金額從 `66,474` 變成 `66,450`；以及 S4 新增後再刪除）。
> - **Part B（E1～E5）** 的所有預期數字，皆以**「做完 S1～S5 後的狀態（總件數 544、總金額 66,450）」**為基準；最後的 **E5 交易沙盒**會使用 `BEGIN; ... ROLLBACK;` 復原，讓資料庫依然乾淨！
> - 若不小心把資料改亂，隨時在 DBeaver 執行 `TRUNCATE TABLE supplies;` 後重跑你在步驟 3 產生的交易檔，即可從頭來過。

---

## Part A｜核心業務故事（S1～S5 任務挑戰）

### 題目 1（S1）：找出要補貨的耗材並排順序

- **業務問題**：總務想一眼看到所有**庫存已經降到安全水位（含剛好等於）**的耗材，並算出**缺幾件（`安全庫存 - 現有庫存`）**，缺最多的排最前面，若缺口相同則依品號排序。
- **驗收條件**：應查出 **9 筆**，`便利貼` 與 `黑色原子筆` 缺口 `5` 排在最前面，`濕紙巾` 與 `A4 相片紙` 缺口 `0` 排在最後。
- **✍️ 在 DBeaver 動手作提示**：`WHERE current_stock <= safety_stock`，在 `SELECT` 中計算 `(safety_stock - current_stock) AS 缺口`，用 `ORDER BY 缺口 DESC, item_code`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（9 筆）</summary>

```sql
SELECT
    item_code,
    name,
    current_stock,
    safety_stock,
    (safety_stock - current_stock) AS 缺口,
    location
FROM supplies
WHERE current_stock <= safety_stock
ORDER BY 缺口 DESC, item_code;
```

| item_code | name | current_stock | safety_stock | 缺口 | location |
|---|---|---|---|---|---|
| `STA-NOTE-76` | 便利貼 | 15 | 20 | 5 | 3F 總務庫房 D-02 |
| `STA-PEN-K05` | 黑色原子筆 | 45 | 50 | 5 | 3F 總務庫房 D-02 |
| `CLN-BAG-L` | 垃圾袋 大 | 3 | 6 | 3 | 2F 清潔櫃 E-01 |
| `MAT-P-A470` | A4 70g 影印紙 | 3 | 5 | 2 | 3F 總務庫房 B-01 |
| `STA-MRK-RD` | 白板筆 紅色 | 8 | 10 | 2 | 3F 總務庫房 D-02 |
| `MAT-T-HP05` | HP 黑色碳粉匣 | 1 | 2 | 1 | 3F 總務庫房 C-03 |
| `MAT-T-HP11Y` | HP 黃色碳粉匣 | 0 | 1 | 1 | 3F 總務庫房 C-03 |
| `CLN-WIPE-80` | 濕紙巾 | 6 | 6 | 0 | 2F 清潔櫃 E-01 |
| `MAT-P-PHOTO` | A4 相片紙 | 2 | 2 | 0 | 3F 總務庫房 B-01 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（不修改任何資料）回答：
  目前有哪些耗材的現有庫存（current_stock）小於或等於安全庫存（safety_stock）？請幫我算出缺口（safety_stock - current_stock），依缺口由大到小、同缺口依 item_code 排序，並回傳結果表格與你執行的 SQL。
  ```

---

### 題目 2（S2）：關鍵字查存放位置

- **業務問題**：同事跑來問「碳粉匣放在哪裡、還有幾支？」請用關鍵字搜尋品名包含「碳粉」的所有耗材，列出品號、品名、規格、現有庫存、單位與存放位置。
- **驗收條件**：應查出 **4 筆**碳粉匣，全部都在 `3F 總務庫房 C-03`。另外也試著把關鍵字改成 `'不存在的東西'`，確認回傳 `0 筆` 不會報錯。
- **✍️ 在 DBeaver 動手作提示**：`WHERE name LIKE '%碳粉%'`（搭配 `ORDER BY item_code`）。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT item_code, name, spec, current_stock, unit, location
FROM supplies
WHERE name LIKE '%碳粉%'
ORDER BY item_code;
```

| item_code | name | spec | current_stock | unit | location |
|---|---|---|---|---|---|
| `MAT-T-HP05` | HP 黑色碳粉匣 | CF205A | 1 | 支 | 3F 總務庫房 C-03 |
| `MAT-T-HP11C` | HP 青色碳粉匣 | CF411A | 4 | 支 | 3F 總務庫房 C-03 |
| `MAT-T-HP11M` | HP 洋紅色碳粉匣 | CF413A | 2 | 支 | 3F 總務庫房 C-03 |
| `MAT-T-HP11Y` | HP 黃色碳粉匣 | CF412A | 0 | 支 | 3F 總務庫房 C-03 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（SELECT）幫我找出品名包含「碳粉」的所有耗材，顯示品號、品名、規格、現有庫存、單位和存放位置，依品號排序並附上實際執行的 SQL。
  ```

---

### 題目 3（S5）：計算庫存總金額（領用前基準）

- **業務問題**：總務主管月底想知道現在倉庫裡所有耗材總共值多少錢，請寫一條 SQL 直接算出「每項單價 × 現有庫存」的總和、總品項數與總件數。
- **驗收條件**：初始狀態下應得到 **25 項**、**546 件**、**66,474 元**。
- **✍️ 在 DBeaver 動手作提示**：使用彙總函數 `COUNT(*)`、`SUM(current_stock)`、`SUM(unit_price * current_stock)`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果</summary>

```sql
SELECT
    COUNT(*)                         AS 品項數,
    SUM(current_stock)               AS 總件數,
    SUM(unit_price * current_stock)  AS 庫存總金額
FROM supplies;
```

| 品項數 | 總件數 | 庫存總金額 |
|---|---|---|
| 25 | 546 | 66474 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（SELECT）算出目前 supplies 的品項總數、現有庫存總件數，以及 SUM(unit_price * current_stock) 的庫存總金額，回傳結果表格與 SQL。
  ```

---

### 題目 4（S3）：用 Transaction 登記領用（＋超領被 `CHECK` 擋下測試）

- **業務問題**：
  1. 同事來領走 **`2 支` 黑色原子筆（`STA-PEN-K05`）**，請用 `BEGIN; ... COMMIT;` 交易寫法完成扣庫存。
  2. 接著同事想領 **`5 支` HP 黑色碳粉匣（`MAT-T-HP05`，目前僅剩 1 支）**，請執行扣庫存測試是否會被 `CHECK (current_stock >= 0)` 擋下，並執行 `ROLLBACK;`。
  3. 最後再查一次庫存總金額（驗證只扣掉 `2 × 12 = 24` 元）。
- **驗收條件**：`STA-PEN-K05` 庫存從 `45` 變成 **`43`**；`MAT-T-HP05` 報錯 `violates check constraint "supplies_current_stock_check"`，回滾後維持 **`1`**；倉庫總金額變為 **`66,450`**。
- **✍️ 在 DBeaver 動手作提示**：注意不要漏寫 `WHERE item_code = '...'`，否則整間倉庫每一項都會被扣庫存！

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
-- 1. 正常領用黑色原子筆 2 支
BEGIN;
UPDATE supplies
SET current_stock = current_stock - 2
WHERE item_code = 'STA-PEN-K05';
SELECT item_code, name, current_stock FROM supplies WHERE item_code = 'STA-PEN-K05';
COMMIT;

-- 2. 測試超領黑色碳粉匣 5 支（應失敗）
BEGIN;
UPDATE supplies
SET current_stock = current_stock - 5
WHERE item_code = 'MAT-T-HP05';
-- 發生 CHECK 錯誤後執行：
ROLLBACK;

-- 3. 驗證結果：黑色碳粉匣仍是 1，總金額變成 66450
SELECT item_code, name, current_stock FROM supplies WHERE item_code = 'MAT-T-HP05';
SELECT SUM(unit_price * current_stock) AS 庫存總金額 FROM supplies;
```

- `STA-PEN-K05`：`current_stock = 43`
- `MAT-T-HP05`：發生 `ERROR: new row for relation "supplies" violates check constraint "supplies_current_stock_check"`，執行 `ROLLBACK` 後維持 `1`
- 最新 `庫存總金額`：**`66450`**

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代改）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（嚴禁使用 modify 或任何寫入工具）：
  我剛才自己在 DBeaver 執行了一筆領用交易，想確認結果是否正確。請幫我查詢：
  1. STA-PEN-K05（黑色原子筆）目前現有庫存是否已經更新為 43？
  2. MAT-T-HP05（HP 黑色碳粉匣）目前現有庫存是否依然維持 1？
  3. 目前整間倉庫的庫存總金額是否等於 66450？
  ```

---

### 題目 5（S4）：新增耗材 ＋ 防重複測試 ＋ 交易安全刪除

- **業務問題**：
  1. 新購入品號 `STA-GLUE-01`（品名 `口紅膠`、規格 `40g`、類別 `文具`、單位 `支`、單價 `30`、庫存 `10`、安全庫存 `5`、位置 `3F 總務庫房 D-02`、盤點日 `CURRENT_DATE`），寫入資料庫。
  2. 再試一次相同的 `INSERT`，確認被主鍵擋下。
  3. 發現其實登錯品項了，請包成 `BEGIN; ... COMMIT;` 刪除這筆 `STA-GLUE-01`（提醒自己先查再刪，只刪到 1 筆）。
- **驗收條件**：新增後為 26 筆，重複新增報 `duplicate key`，刪除並 `COMMIT` 後回到 **25 筆**，其他品項毫髮無傷。
- **✍️ 在 DBeaver 動手作提示**：在 `BEGIN;` 裡面執行 `DELETE` 後，可先 `SELECT COUNT(*) FROM supplies;` 看是不是正好少 1 筆，確定無誤才 `COMMIT;`！

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
-- 1. 新增口紅膠
INSERT INTO supplies (item_code, name, spec, category, unit, unit_price, current_stock, safety_stock, location, last_checked)
VALUES ('STA-GLUE-01', '口紅膠', '40g', '文具', '支', 30, 10, 5, '3F 總務庫房 D-02', CURRENT_DATE);

-- 2. 再插一次相同的（會被 PRIMARY KEY 擋下：duplicate key value violates unique constraint "supplies_pkey"）
INSERT INTO supplies (item_code, name, spec, category, unit, unit_price, current_stock, safety_stock, location, last_checked)
VALUES ('STA-GLUE-01', '口紅膠', '40g', '文具', '支', 30, 10, 5, '3F 總務庫房 D-02', CURRENT_DATE);

-- 3. 用交易刪除（只刪指定那筆）
BEGIN;
DELETE FROM supplies WHERE item_code = 'STA-GLUE-01';
SELECT COUNT(*) AS 刪除後總筆數 FROM supplies; -- 應為 25
COMMIT;
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代改）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（嚴禁修改或刪除資料）：
  我剛才在 DBeaver 完成「新增 STA-GLUE-01 → 測重複 → 刪除 STA-GLUE-01」的演練，請幫我驗證：
  1. supplies 目前總筆數是否已經回到 25 筆？
  2. 品號 'STA-GLUE-01' 是否已經不存在？
  3. 庫存總金額是否依然為 66450？
  ```

---

## Part B｜進階 DML 練功題（E1～E5，涵蓋進階查詢與交易沙盒）

> 以下 E1～E5 皆以**做完 S1～S5 後的狀態**（`STA-PEN-K05` 為 `43`、共 `25` 項、`544` 件、`66,450` 元）為基準！

### 題目 6（E1）：找出單價最高的前 3 項清潔用品（`WHERE` ＋ `ORDER BY` ＋ `LIMIT`）

- **業務問題**：總務想節省高單價清潔用品支出，請篩選類別為 `'清潔用品'` 的耗材，依單價由高到低排序，只顯示前 3 筆。
- **驗收條件**：應回傳 `抽取式衛生紙`（890）、`洗手乳補充包`（120）、`垃圾袋 大`（65）。
- **✍️ 在 DBeaver 動手作提示**：結合 `WHERE category = '清潔用品'`、`ORDER BY unit_price DESC` 與 `LIMIT 3`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（3 筆）</summary>

```sql
SELECT item_code, name, unit_price, current_stock, location
FROM supplies
WHERE category = '清潔用品'
ORDER BY unit_price DESC
LIMIT 3;
```

| item_code | name | unit_price | current_stock | location |
|---|---|---|---|---|
| `CLN-TP-ROLL` | 抽取式衛生紙 | 890 | 5 | 2F 清潔櫃 E-01 |
| `CLN-HAND-1L` | 洗手乳補充包 | 120 | 7 | 2F 清潔櫃 E-01 |
| `CLN-BAG-L` | 垃圾袋 大 | 65 | 3 | 2F 清潔櫃 E-01 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢找出 category 為 '清潔用品' 中單價最高的前 3 項耗材（含品號、品名、單價、庫存、位置），並回傳結果表格與 SQL。
  ```

---

### 題目 7（E2）：找出從未盤點過的耗材（`IS NULL`）

- **業務問題**：月底總務安排抽盤，想先找出所有 `last_checked`（最後盤點日）目前還是空白的耗材優先去盤點。
- **驗收條件**：應查出 **2 筆**（`75% 酒精`、`透明膠帶`）。提醒：`= NULL` 查不到任何東西，一定要用 `IS NULL`。
- **✍️ 在 DBeaver 動手作提示**：`WHERE last_checked IS NULL ORDER BY item_code`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT item_code, name, category, current_stock, location, last_checked
FROM supplies
WHERE last_checked IS NULL
ORDER BY item_code;
```

| item_code | name | category | current_stock | location | last_checked |
|---|---|---|---|---|---|
| `CLN-ALC-500` | 75% 酒精 | 清潔用品 | 18 | 2F 清潔櫃 E-01 | *(NULL)* |
| `STA-TAPE-18` | 透明膠帶 | 文具 | 36 | 3F 總務庫房 D-02 | *(NULL)* |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢列出所有最後盤點日（last_checked）為 NULL 的耗材，依 item_code 排序並顯示結果表格與 SQL。
  ```

---

### 題目 8（E3）：統計各類別品項數、總件數與類別庫存金額（`GROUP BY`）

- **業務問題**：主管需要一份各耗材類別的金額占比報表：每個類別各有多少品項、多少總件數、多少庫存總金額？並把金額最高的大類排在最前面。
- **驗收條件**：共 4 類，`碳粉墨水` 金額最高（`28,280`），`文具`（在 S3 扣減 2 支黑筆後）金額為 **`8,596`**（件數 `458`）。
- **✍️ 在 DBeaver 動手作提示**：`GROUP BY category`，欄位使用 `COUNT(*)`、`SUM(current_stock)`、`SUM(unit_price * current_stock)`，依類別庫存金額 `DESC` 排序。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT
    category                         AS 類別,
    COUNT(*)                         AS 品項數,
    SUM(current_stock)               AS 總件數,
    SUM(unit_price * current_stock)  AS 類別庫存金額
FROM supplies
GROUP BY category
ORDER BY 類別庫存金額 DESC;
```

| 類別 | 品項數 | 總件數 | 類別庫存金額 |
|---|---|---|---|
| 碳粉墨水 | 5 | 13 | 28280 |
| 紙張 | 4 | 25 | 22550 |
| 文具 | 10 | 458 | 8596 |
| 清潔用品 | 6 | 48 | 7024 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢依 category 分組統計「品項數」、「總件數」與「類別庫存金額（單價 * 現有庫存總和）」，依金額由高到低排序，回傳表格與 SQL。
  ```

---

### 題目 9（E4）：用 `CASE WHEN` 替全部耗材分級並統計各警戒等級（子查詢 ＋ `STRING_AGG`）

- **業務問題**：總務想將 25 項耗材分三種警戒等級：
  - `current_stock = 0` → `'1. 斷貨'`
  - `current_stock <= safety_stock` → `'2. 偏低需補貨'`
  - 其餘 → `'3. 庫存充足'`  
  請算出每個警戒等級各有幾項耗材，並把同等級品名串成一欄方便週會報告！
- **驗收條件**：`1. 斷貨` 有 **1 項**（HP 黃色碳粉匣），`2. 偏低需補貨` 有 **8 項**，`3. 庫存充足` 有 **16 項**（`1 + 8 + 16 = 25`）。
- **✍️ 在 DBeaver 動手作提示**：先在內層子查詢用 `CASE WHEN ... END AS 警戒等級` 標記每一列，外層再 `GROUP BY 警戒等級` 搭配 `COUNT(*)` 與 `STRING_AGG(name, '、' ORDER BY item_code)`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（3 筆）</summary>

```sql
SELECT
    警戒等級,
    COUNT(*) AS 品項數,
    STRING_AGG(name, '、' ORDER BY item_code) AS 品項清單
FROM (
    SELECT
        item_code,
        name,
        CASE
            WHEN current_stock = 0 THEN '1. 斷貨'
            WHEN current_stock <= safety_stock THEN '2. 偏低需補貨'
            ELSE '3. 庫存充足'
        END AS 警戒等級
    FROM supplies
) t
GROUP BY 警戒等級
ORDER BY 警戒等級;
```

| 警戒等級 | 品項數 | 品項清單 |
|---|---|---|
| 1. 斷貨 | 1 | HP 黃色碳粉匣 |
| 2. 偏低需補貨 | 8 | 垃圾袋 大、濕紙巾、A4 70g 影印紙、A4 相片紙、HP 黑色碳粉匣、白板筆 紅色、便利貼、黑色原子筆 |
| 3. 庫存充足 | 16 | 75% 酒精、垃圾袋 中、洗手乳補充包、抽取式衛生紙、A3 80g 影印紙、A4 80g 影印紙、Epson 黑色墨水、HP 青色碳粉匣、HP 洋紅色碳粉匣、迴紋針、A4 資料夾、白板筆 黑色、藍色原子筆、紅色原子筆、釘書針、透明膠帶 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢替每項耗材分類：庫存 0 為「1. 斷貨」、小於等於安全庫存為「2. 偏低需補貨」、其餘為「3. 庫存充足」，統計每個等級的品項數並用逗號串列品名，回傳結果表格與 SQL。
  ```

---

### 題目 10（E5）：進階交易沙盒 — 同時領用影印紙＋全面微調文具單價試算（`BEGIN ... ROLLBACK`）

- **業務問題**：開學季文具全面預計小幅漲價 **每項 `+2` 元**，同時有同事預領 **`MAT-P-A480`（A4 80g 影印紙）1 箱**。請你寫一個**安全沙盒交易**：在 `BEGIN` 裡執行這兩個 `UPDATE`（用 `RETURNING` 或 `SELECT` 觀察變動後這 11 項耗材與整間倉庫的新總金額），最後用 **`ROLLBACK;` 復原**以免真的改掉售價！
- **驗收條件**：沙盒內總金額會從 `66,450` 變成 **`66,586`**（`MAT-P-A480` 少 1 箱減 `780`；文具共 `458` 件各加 `2` 元增加 `916`；`66450 - 780 + 916 = 66586`）；執行 `ROLLBACK;` 後應立刻回到 **`66,450`**。
- **✍️ 在 DBeaver 動手作提示**：`BEGIN;` → 兩條 `UPDATE` → `SELECT SUM(unit_price * current_stock)` 試算新金額 → `ROLLBACK;` → 再查一次 `SUM` 確認已復原！

<details>
<summary>👀 寫完再打開：參考 SQL 與沙盒前後對照結果</summary>

```sql
BEGIN;

-- 1. 領走 1 箱 A4 80g 影印紙
UPDATE supplies
SET current_stock = current_stock - 1
WHERE item_code = 'MAT-P-A480';

-- 2. 所有「文具」單價試算調漲 +2 元
UPDATE supplies
SET unit_price = unit_price + 2
WHERE category = '文具';

-- 3. 觀察被影響到的 11 筆資料與試算後倉庫總金額
SELECT item_code, name, unit_price, current_stock, (unit_price * current_stock) AS 小計
FROM supplies
WHERE category = '文具' OR item_code = 'MAT-P-A480'
ORDER BY item_code;

SELECT SUM(unit_price * current_stock) AS 沙盒模擬總金額 FROM supplies; -- 應為 66586

-- 4. 結束沙盒測試，全部回滾復原！
ROLLBACK;

-- 5. 確認回到 66450
SELECT SUM(unit_price * current_stock) AS 復原後總金額 FROM supplies; -- 應為 66450
```

| 狀態 | `MAT-P-A480` 庫存 | `文具` 類單價異動 | 倉庫總金額 |
|---|---|---|---|
| 沙盒交易中（COMMIT 前） | 7 箱（原 8） | 10 項文具單價皆 `+2` | **66586** |
| 執行 `ROLLBACK;` 後 | **8 箱** | **全部復原** | **66450** |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫或回滾）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 supplies 資料庫，只用唯讀查詢（嚴禁執行任何 UPDATE/DELETE/modify 工具）：
  我剛才在 DBeaver 用 BEGIN ... ROLLBACK 做了「A4 80g 影印紙扣 1 ＋ 文具單價漲 2 元」的沙盒模擬並且已經 ROLLBACK。請幫我查證：
  1. MAT-P-A480 目前庫存是否依然是 8（沒有被誤扣）？
  2. 文具類藍色原子筆（STA-PEN-B05）單價是否依然是 12（沒有被調漲）？
  3. 倉庫目前的總金額是否依然完整維持在 66450？
  另外請順便告訴我，如果這種雙 UPDATE 交易不小心忘了寫 WHERE category = '文具' 會發生什麼後果？
  ```

---

## 🤖 問 AI 助教（把這 10 題變成你自己的 SQL 筆記本）

```text
我剛親手寫完 supplies 資料庫的 10 題 DML（包含安全水位缺口、LIKE 關鍵字、SUM 總金額、Transaction 領用防呆、INSERT/DELETE、LIMIT、IS NULL、GROUP BY 類別統計、CASE WHEN 分級、BEGIN...ROLLBACK 試算沙盒），也透過 Microsoft Postgres MCP 交叉驗證完了。
請幫我把這些題目整理成一張「單表常見 SQL 語法速查小抄」，說明什麼情況要用 IS NULL、什麼情況不能漏 WHERE、以及為什麼扣庫存和調價前可以先用 BEGIN...ROLLBACK 試算。
```

---

👉 **所有故事與進階練習都親手跑完並驗證過了！接著使用 [步驟 5｜MCP 讀結構產生 PRD](prompts/01_MCP讀結構產生PRD.md)，準備打造桌面小工具！**
