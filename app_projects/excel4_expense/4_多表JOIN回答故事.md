# 步驟 4｜10 題多表 JOIN DML 實戰 ＋ Microsoft Postgres MCP 雙軌驗證

> **學習節奏（三步練功循環）**：  
> **① 自己動手寫**：在 DBeaver（`我的查詢.sql`）先看題目與驗收條件自己寫 SQL 執行。  
> **② 核對標準答案**：展開 `<details>` 核對參考 SQL、觀念要點與真實執行結果表。  
> **③ 用 Microsoft Postgres MCP 驗證**：複製該題的 **MCP Prompt** 請 AI 唯讀連線 `expense` 資料庫查核比對！
>
> **關於資料狀態的特別說明**：
> - **Part A（S1～S5）** 依序執行（包含 **S3** 核准 `EXP20240313` 成 `'已批准'`，以及 **S4** 新增第 10 個類別 `'員工訓練'` 與第 14 張單 `EXP20240314` `1,500` 元）。
> - **Part B（E1～E5）** 的預期結果皆以**「做完 S1～S5 後（共 10 類別、14 張單、總金額 34,860.00）」**為基準；其中的 **E2、E5 交易沙盒**皆會使用 `BEGIN; ... ROLLBACK;` 復原！
> - 若不小心把資料改亂，在 DBeaver 執行 `TRUNCATE TABLE claims, employees, categories, departments RESTART IDENTITY;` 後重新執行步驟 3 產生的交易檔即可恢復初始 **4 部門、9 類別、5 員工、13 單（33,360.00）**。

---

## Part A｜核心業務故事（S1～S5 任務挑戰）

### 題目 1（S1）：四表 `JOIN` 查詢待撥款明細與合計

- **業務問題**：出納想列出所有狀態為 `'待撥款'` 的單據，每一列都要看到單號、日期、員工姓名、所屬部門名稱、費用類別名稱與金額；另外再寫一句查出這批待撥款總合計金額。
- **驗收條件**：明細共 **2 筆**（都是 `周美玲`：`2980.00` 與 `2200.00`），待撥款合計為 **`5180.00`**。
- **✍️ 在 DBeaver 動手作提示**：從 `claims cl` 出發，接連 `JOIN employees e`、`JOIN departments d`、`JOIN categories ca`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆 ＋ 合計）</summary>

```sql
-- 1. 待撥款明細（四表 JOIN）
SELECT
    cl.claim_id,
    cl.claim_date,
    e.name  AS 員工,
    d.name  AS 部門,
    ca.name AS 類別,
    cl.amount
FROM claims cl
JOIN employees e   ON cl.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
JOIN categories ca ON cl.category_id = ca.category_id
WHERE cl.status = '待撥款'
ORDER BY cl.claim_date;

-- 2. 待撥款合計
SELECT SUM(amount) AS 待撥款合計
FROM claims
WHERE status = '待撥款';
```

| claim_id | claim_date | 員工 | 部門 | 類別 | amount |
|---|---|---|---|---|---|
| `EXP20240309` | 2024-03-18 | 周美玲 | 業務部 | 長途交通 | 2980.00 |
| `EXP20240310` | 2024-03-20 | 周美玲 | 業務部 | 差旅住宿 | 2200.00 |

- `待撥款合計`：**`5180.00`**

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（JOIN 四張表）列出所有狀態為「待撥款」的報銷單明細（單號、日期、員工、部門、類別、金額），並另外算出待撥款總合計，回傳表格與 SQL。
  ```

---

### 題目 2（S2）：三表 `JOIN` 查詢待審核單據與負責主管

- **業務問題**：會計想看狀態為 `'待審核'` 的單據，並抓出該員工所屬部門的 **`manager_name`（負責主管）** 以利催簽。
- **驗收條件**：應查出 **2 筆**：`黃雅婷`（行銷部，負責主管 `王經理`，`2500.00`）與 `陳小華`（業務部，負責主管 `張協理`，`320.00`）。
- **✍️ 在 DBeaver 動手作提示**：部門表 `departments` 的 `manager_name` 就是審核主管。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT
    cl.claim_id,
    cl.claim_date,
    e.name         AS 申請人,
    d.name         AS 部門,
    d.manager_name AS 負責主管,
    cl.amount
FROM claims cl
JOIN employees e   ON cl.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE cl.status = '待審核'
ORDER BY cl.claim_date;
```

| claim_id | claim_date | 申請人 | 部門 | 負責主管 | amount |
|---|---|---|---|---|---|
| `EXP20240312` | 2024-03-25 | 黃雅婷 | 行銷部 | 王經理 | 2500.00 |
| `EXP20240313` | 2024-03-28 | 陳小華 | 業務部 | 張協理 | 320.00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢列出所有 status = '待審核' 的單據，連同申請人姓名、部門名稱和負責主管（manager_name），依申請日期排序並回傳表格與 SQL。
  ```

---

### 題目 3（S5）：統計「業務部」已撥款總金額

- **業務問題**：財務主管想看特定部門（如 `'業務部'`）所有狀態為 `'已撥款'` 的單據金額總和。
- **驗收條件**：業務部已撥款總額為 **`3430.00`**（不含那兩張「待撥款」也不含「待審核」）。
- **✍️ 在 DBeaver 動手作提示**：注意同時條件 `WHERE d.name = '業務部' AND cl.status = '已撥款'`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果</summary>

```sql
SELECT d.name AS 部門, SUM(cl.amount) AS 已撥款總額
FROM claims cl
JOIN employees e   ON cl.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.name = '業務部'
  AND cl.status = '已撥款'
GROUP BY d.name;
```

| 部門 | 已撥款總額 |
|---|---|
| 業務部 | 3430.00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢算出「業務部」所有 status = '已撥款' 單據的金額加總（SUM(amount)），並附上實際執行的 SQL。
  ```

---

### 題目 4（S3）：防重複審核交易 — 核准 `EXP20240313` 並攔截二度駁回

- **業務問題**：
  1. 在 `BEGIN; ... COMMIT;` 交易裡，將 `EXP20240313` 改為 `'已批准'`——**關鍵防呆**：`WHERE` 必須加上 **`AND status = '待審核'`**，不能只寫 `WHERE claim_id = 'EXP20240313'`！
  2. 接著模擬另一位主管手快又對 `EXP20240313` 執行「駁回（`status = '已駁回' WHERE claim_id = 'EXP20240313' AND status = '待審核'`）」，觀察異動列數是否變成 `0`（不覆蓋已審核單據）。
- **驗收條件**：第一次 `UPDATE` 回傳 `1` 列（狀態變 `'已批准'`）；第二次誤按駁回回傳 `UPDATE 0`，狀態依然維持 `'已批准'`。
- **✍️ 在 DBeaver 動手作提示**：`WHERE claim_id = 'EXP20240313' AND status = '待審核'` 就是狀態機防誤觸的標準寫法。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
-- 1. 核准 EXP20240313（加上狀態檢查，只允許待審核的單被改）
BEGIN;
UPDATE claims
SET status = '已批准'
WHERE claim_id = 'EXP20240313'
  AND status = '待審核'
RETURNING claim_id, status;
-- 結果：EXP20240313 | 已批准（UPDATE 1）
COMMIT;

-- 2. 再對同一張已批准的單試圖駁回（會改不到任何一筆）
UPDATE claims
SET status = '已駁回'
WHERE claim_id = 'EXP20240313'
  AND status = '待審核';
-- 結果：UPDATE 0（App 可依 rowcount = 0 提示「這張單已經審核過」）
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（嚴禁執行 UPDATE 或 modify 工具）：
  我剛才在 DBeaver 核准了 EXP20240313 並測試了防重複駁回，請幫我查詢：
  1. EXP20240313 目前的 status 是否為「已批准」（而不是「已駁回」）？
  2. 目前 status = '待審核' 的單據是否只剩 1 張（EXP20240312）？
  ```

---

### 題目 5（S4）：新增費用類別（`setval` 驗證）＋ 新增報銷單 ＋ 防重複發票

- **業務問題**：
  1. 新增費用類別 `'員工訓練'`，用 `RETURNING category_id, name` 觀察編號是不是正好接續成 **`10`**！
  2. 幫員工 `E04`（張大同）新增報銷單 `EXP20240314`（日期 `'2024-03-29'`、類別剛拿到的 `10`、說明 `'新進同仁資安課程'`、發票 `'GH-99887767'`、金額 `1500`、不填 `status` 測 `DEFAULT '待審核'`）。
  3. 再用同一張發票 `'GH-99887767'` 新增 `EXP20240315`，驗證被 `UNIQUE` 擋下！
- **驗收條件**：`員工訓練` 編號是 **`10`**；`EXP20240314` 成功寫入且狀態自動是 **`待審核`**（總報銷單變 **14 張**、總金額 **34,860.00**）；`EXP20240315` 報錯 `duplicate key ... "claims_invoice_no_key"`。
- **✍️ 在 DBeaver 動手作提示**：如果沒在步驟 3 做過 `setval`，這裡 `INSERT INTO categories` 就會立刻撞牆——這正是驗證你步驟 3 做對與否的試金石！

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
-- 1. 新增類別，應取得 category_id = 10
INSERT INTO categories (name)
VALUES ('員工訓練')
RETURNING category_id, name;

-- 2. 新增報銷單 EXP20240314（不填 status 會自動套用 DEFAULT '待審核'）
INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount)
VALUES ('EXP20240314', '2024-03-29', 'E04', 10, '新進同仁資安課程', 'GH-99887767', 1500)
RETURNING claim_id, status;

-- 3. 重複發票測試（會被 claims_invoice_no_key 擋下）
INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount)
VALUES ('EXP20240315', '2024-03-29', 'E04', 10, '重複發票測試', 'GH-99887767', 1500);
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（嚴禁新增或修改資料）：
  我剛才在 DBeaver 新增了「員工訓練」類別與 EXP20240314，請幫我驗證：
  1. categories 是否共 10 筆，且「員工訓練」的 category_id 是否正是 10？
  2. EXP20240314 的 status 是否自動設為「待審核」、發票為 'GH-99887767'？
  3. 目前 claims 總筆數是否為 14 筆、總金額是否為 34,860.00？
  ```

---

## Part B｜進階多表 DML 練功題（E1～E5）

> 以下 E1～E5 皆以**做完 S1～S5 後**（10 類別、14 張單、總金額 `34,860.00`）為基準！

### 題目 6（E1）：依部門主管篩選其轄下所有部門的報銷單

- **業務問題**：`'李副總'` 同時管理 `技術部` 與 `人事部`。請用 4 表 `JOIN` 一次查出所有歸 `'李副總'` 管轄部門員工提出過的全部報銷單，依申請日期排序。
- **驗收條件**：應查出 **5 筆**：技術部林志明 3 筆 ＋ 人事部張大同 2 筆（包含 S4 剛新增的 `EXP20240314`）。
- **✍️ 在 DBeaver 動手作提示**：條件篩在 `WHERE d.manager_name = '李副總'`，這展現了只要資料拆對，不用在報銷單存部門或主管一樣能輕鬆反查！

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（5 筆）</summary>

```sql
SELECT
    cl.claim_id,
    cl.claim_date,
    d.name  AS 部門,
    e.name  AS 員工,
    ca.name AS 類別,
    cl.amount,
    cl.status
FROM claims cl
JOIN employees e   ON cl.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
JOIN categories ca ON cl.category_id = ca.category_id
WHERE d.manager_name = '李副總'
ORDER BY cl.claim_date;
```

| claim_id | claim_date | 部門 | 員工 | 類別 | amount | status |
|---|---|---|---|---|---|---|
| `EXP20240303` | 2024-03-03 | 技術部 | 林志明 | 雲端服務 | 3850.00 | 已撥款 |
| `EXP20240306` | 2024-03-10 | 人事部 | 張大同 | 辦公耗材 | 1200.00 | 已撥款 |
| `EXP20240307` | 2024-03-12 | 技術部 | 林志明 | 軟體授權 | 4500.00 | 已撥款 |
| `EXP20240311` | 2024-03-22 | 技術部 | 林志明 | 外部進修 | 3600.00 | 已批准 |
| `EXP20240314` | 2024-03-29 | 人事部 | 張大同 | 員工訓練 | 1500.00 | 待審核 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢找出部門主管（manager_name）為「李副總」的所有報銷單明細（含單號、日期、部門、員工、類別、金額、狀態），依日期排序並回傳表格與 SQL。
  ```

---

### 題目 7（E2）：交易沙盒 ＋ `LEFT JOIN ... IS NULL` 找出從未有人報銷過的費用類別

- **業務問題**：目前這 10 個類別全都有單據（1～9 都有、10 剛被 `EXP20240314` 用過）。請你開啟一個 **`BEGIN; ... ROLLBACK;` 安全沙盒**：在沙盒裡新增第 11 個類別 `'公關交際'`，然後用 `LEFT JOIN claims ... WHERE cl.claim_id IS NULL` 查出沒人報銷過的類別，最後執行 **`ROLLBACK;`** 復原類別數量回 `10`！
- **驗收條件**：沙盒內 `LEFT JOIN` 應精準抓出 **`公關交際`**；`ROLLBACK;` 後 `categories` 總筆數回到 **`10`**。
- **✍️ 在 DBeaver 動手作提示**：複習一下，為什麼這個測試裡即使 `ROLLBACK` 了，下一次新增類別編號還會從 `12` 開始而不是 `11`？（因為 PostgreSQL 的 `SERIAL` 序號配發後不回滾，以確保多人併發不撞號！）

<details>
<summary>👀 寫完再打開：參考 SQL 與沙盒驗證結果</summary>

```sql
BEGIN;

INSERT INTO categories (name) VALUES ('公關交際') RETURNING category_id, name;

SELECT ca.category_id, ca.name AS 無人使用類別
FROM categories ca
LEFT JOIN claims cl ON ca.category_id = cl.category_id
WHERE cl.claim_id IS NULL
ORDER BY ca.category_id;
-- 結果：公關交際

ROLLBACK;

SELECT COUNT(*) AS 復原後類別數 FROM categories; -- 應回到 10
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代改）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（嚴禁使用 modify 工具）：
  我剛才用 BEGIN ... ROLLBACK 測試了新增「公關交際」並用 LEFT JOIN 找無人報銷類別。請幫我查證：
  1. 目前有沒有任何「完全沒人報銷過」的費用類別（LEFT JOIN claims WHERE claim_id IS NULL）？應該為 0 筆且「公關交際」已確實回滾不存在。
  2. categories 總數是否仍維持 10 筆？
  ```

---

### 題目 8（E3）：找出單筆金額最高的「已撥款」報銷單

- **業務問題**：財務稽核想快速抓出目前所有狀態為 `'已撥款'` 的單據中，金額最高的那 1 張詳細資訊。
- **驗收條件**：應回傳 `EXP20240304`（黃雅婷、行銷部、廣告推廣、**`8500.00`**）。
- **✍️ 在 DBeaver 動手作提示**：`WHERE cl.status = '已撥款' ORDER BY cl.amount DESC LIMIT 1`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（1 筆）</summary>

```sql
SELECT
    cl.claim_id,
    cl.claim_date,
    e.name  AS 員工,
    d.name  AS 部門,
    ca.name AS 類別,
    cl.amount
FROM claims cl
JOIN employees e   ON cl.emp_id = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
JOIN categories ca ON cl.category_id = ca.category_id
WHERE cl.status = '已撥款'
ORDER BY cl.amount DESC
LIMIT 1;
```

| claim_id | claim_date | 員工 | 部門 | 類別 | amount |
|---|---|---|---|---|---|
| `EXP20240304` | 2024-03-05 | 黃雅婷 | 行銷部 | 廣告推廣 | 8500.00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢找出所有已撥款單據中金額最高的那 1 張報銷單（含單號、日期、員工、部門、類別、金額），回傳表格與 SQL。
  ```

---

### 題目 9（E4）：用 `GROUP BY` ＋ `FILTER` 做出各部門不同狀態金額一覽表

- **業務問題**：老闆想要一張橫向總表：列出全部 4 個部門，分別算出各自的「總單數」、「已撥款金額」、「待撥款金額」、「審核/批准中金額（`待審核` 或 `已批准`）」，並依已撥款金額由高到低排序。
- **驗收條件**：4 個部門金額加總剛好等於 `34,860.00`（`8780 + 8350 + 3430 + 1200` + 待撥款 `5180` + 審核批准中 `7920`）。
- **✍️ 在 DBeaver 動手作提示**：用 `COALESCE(SUM(cl.amount) FILTER (WHERE ...), 0)` 避免沒有該狀態的部門顯示成 `NULL`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT
    d.name AS 部門,
    COUNT(cl.claim_id) AS 總單數,
    COALESCE(SUM(cl.amount) FILTER (WHERE cl.status = '已撥款'), 0) AS 已撥款金額,
    COALESCE(SUM(cl.amount) FILTER (WHERE cl.status = '待撥款'), 0) AS 待撥款金額,
    COALESCE(SUM(cl.amount) FILTER (WHERE cl.status IN ('待審核', '已批准')), 0) AS 審核批准中金額
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN claims cl   ON e.emp_id = cl.emp_id
GROUP BY d.dept_id, d.name
ORDER BY 已撥款金額 DESC;
```

| 部門 | 總單數 | 已撥款金額 | 待撥款金額 | 審核批准中金額 |
|---|---|---|---|---|
| 行銷部 | 3 | 8780.00 | 0 | 2500.00 |
| 技術部 | 3 | 8350.00 | 0 | 3600.00 |
| 業務部 | 6 | 3430.00 | 5180.00 | 320.00 |
| 人事部 | 2 | 1200.00 | 0 | 1500.00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢依部門分組，使用 FILTER (WHERE ...) 分別算出各部門的總單數、已撥款金額、待撥款金額與待審核/已批准中金額（空值以 0 呈現），依已撥款金額由高到低排序，回傳表格與 SQL。
  ```

---

### 題目 10（E5）：進階交易沙盒 — 批次將「已批准」單據推進為「待撥款」試算本次總撥款額

- **業務問題**：出納準備週五彙整撥款：凡是目前狀態為 `'已批准'` 的單據（經 S3 後有 `EXP20240311` 與 `EXP20240313` 共 2 張），都要推進變成 `'待撥款'`。請在 **`BEGIN; ... ROLLBACK;`** 沙盒中推進這兩張單的狀態、查詢推進後全部 `'待撥款'` 的新總額與張數，最後再 **`ROLLBACK;`** 復原！
- **驗收條件**：沙盒內 `UPDATE` 影響 **`2` 列**，`待撥款` 從 `2 張 / 5180.00` 增加到 **`4 張 / 9100.00`**（`5180 + 3600 + 320`）；`ROLLBACK;` 後恢復 **`2 張 / 5180.00`**。
- **✍️ 在 DBeaver 動手作提示**：`UPDATE claims SET status = '待撥款' WHERE status = '已批准' RETURNING claim_id, amount, status;`。

<details>
<summary>👀 寫完再打開：參考 SQL 與沙盒前後對照結果</summary>

```sql
BEGIN;

-- 1. 推進所有已批准單據進入待撥款
UPDATE claims
SET status = '待撥款'
WHERE status = '已批准'
RETURNING claim_id, amount, status;

-- 2. 計算沙盒內待撥款新總數與新總金額（應為 4 張 | 9100.00）
SELECT COUNT(*) AS 沙盒待撥款單數, SUM(amount) AS 沙盒待撥款總額
FROM claims
WHERE status = '待撥款';

-- 3. 結束演練，回滾復原
ROLLBACK;

-- 4. 確認復原成 2 張 | 5180.00
SELECT COUNT(*) AS 復原後待撥款單數, SUM(amount) AS 復原後待撥款總額
FROM claims
WHERE status = '待撥款';
```

| 狀態 | 待撥款張數 | 待撥款總金額 |
|---|---|---|
| 沙盒推進交易中 | 4 張 | 9100.00 |
| 執行 `ROLLBACK;` 後 | **2 張** | **5180.00** |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（嚴禁呼叫修改或寫入工具）：
  我剛才用 BEGIN ... ROLLBACK 模擬將「已批准」單據推進為「待撥款」並已回滾復原。請幫我查證：
  1. 目前 status = '待撥款' 是否依然是 2 張、總額 5180.00？
  2. EXP20240311 與 EXP20240313 的狀態是否都依然保留為「已批准」？
  ```

---

## 🤖 問 AI 助教（複習四表設計與審核狀態機）

```text
我剛親手寫完 expense 四表資料庫的 10 題多表 JOIN 與交易實戰，也用 Microsoft Postgres MCP 完成核對。
請幫我總結三個關鍵觀念：(1) 為什麼多表 JOIN 不用在 claims 存部門和主管 (2) 為什麼 UPDATE status 要同時檢查原本 status = '待審核' (3) SERIAL + setval 與 FILTER 條件加總在報表上的好處。
```

---

👉 **所有多表故事與進階練習都親手跑完並驗證過了！接著前往 [步驟 5｜MCP 讀結構產生 PRD](prompts/01_MCP讀結構產生PRD.md)！**
