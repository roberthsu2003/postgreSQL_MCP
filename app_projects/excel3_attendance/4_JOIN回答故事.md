# 步驟 4｜10 題 JOIN DML 實戰 ＋ Microsoft Postgres MCP 雙軌驗證

> **學習節奏（三步練功循環）**：  
> **① 自己動手寫**：在 DBeaver（`我的查詢.sql`）看著題目與驗收條件自己寫 SQL 執行。  
> **② 核對標準答案**：展開 `<details>` 檢查參考 SQL、要領與真實執行結果表。  
> **③ 用 Microsoft Postgres MCP 驗證**：複製該題附帶的 **MCP Prompt** 請 AI 唯讀查詢 `attendance` 資料庫，比較 AI 查到的答案是否與你的 SQL 完全一致！
>
> **關於資料狀態的說明**：
> - **Part A（S1～S5）** 照故事順序執行（包含 **S4** 把 `黃雅婷` 改成 `'業務發展部'`，以及 **S5** 新增 `E07` `吳小安` 成 **7 位員工**）。
> - **Part B（E1～E5）** 的預期結果皆以**「做完 S1～S5 後（7 位員工、28 筆打卡、黃雅婷屬於業務發展部、E07 吳小安零打卡）」**為基準；**E5 交易沙盒**使用 `BEGIN; ... ROLLBACK;` 復原！
> - 若測試不小心改亂資料，在 DBeaver 執行 `TRUNCATE TABLE attendance, employees;` 後重新執行你在步驟 3 產生的交易檔即可恢復初始 **6 位員工、28 筆打卡**。

---

## Part A｜核心業務故事（S1～S5 任務挑戰）

### 題目 1（S1）：用 `JOIN` 查詢「林志明」一週打卡明細與部門

- **業務問題**：人資想在輸入員工姓名（如 `'林志明'`）後，把員工表 `employees` 的部門與打卡表 `attendance` 的出勤日期、上下班時間接在一起顯示，並依日期由早到晚排序。
- **驗收條件**：應回傳 **5 筆**（`2024-03-04` 到 `2024-03-08`），部門全部是 `資訊技術部`。
- **✍️ 在 DBeaver 動手作提示**：`attendance a JOIN employees e ON a.emp_id = e.emp_id`，條件 `WHERE e.name = '林志明'`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（5 筆）</summary>

```sql
SELECT e.name, e.dept, a.work_date, a.clock_in, a.clock_out
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.name = '林志明'
ORDER BY a.work_date;
```

| name | dept | work_date | clock_in | clock_out |
|---|---|---|---|---|
| 林志明 | 資訊技術部 | 2024-03-04 | 09:15:00 | 20:30:00 |
| 林志明 | 資訊技術部 | 2024-03-05 | 08:59:00 | 18:30:00 |
| 林志明 | 資訊技術部 | 2024-03-06 | 09:03:00 | 19:10:00 |
| 林志明 | 資訊技術部 | 2024-03-07 | 08:56:00 | 18:45:00 |
| 林志明 | 資訊技術部 | 2024-03-08 | 08:59:00 | 18:20:00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢（JOIN employees 與 attendance）找出「林志明」本週的打卡明細（姓名、部門、日期、上班打卡、下班打卡），依日期由早到晚排序，回傳表格與 SQL。
  ```

---

### 題目 2（S2）：找出遲到名單（`09:00` 整不算遲到）

- **業務問題**：人資想列出所有上班打卡**嚴格晚於 `09:00`** 的打卡紀錄，連同員工工號、姓名與部門一起顯示，依日期與上班時間排序。
- **驗收條件**：應回傳 **5 筆**（`林志明` 2 次，`黃雅婷`、`張大同`、`周美玲` 各 1 次），而 `張大同` 3/4 的 `09:00:00` **不能**出現。
- **✍️ 在 DBeaver 動手作提示**：注意不要寫 `>= '09:00'`，要寫 `a.clock_in > '09:00'`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（5 筆）</summary>

```sql
SELECT e.emp_id, e.name, e.dept, a.work_date, a.clock_in
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.clock_in > '09:00'
ORDER BY a.work_date, a.clock_in;
```

| emp_id | name | dept | work_date | clock_in |
|---|---|---|---|---|
| `E02` | 林志明 | 資訊技術部 | 2024-03-04 | 09:15:00 |
| `E03` | 黃雅婷 | 行銷企劃部 | 2024-03-05 | 09:07:00 |
| `E02` | 林志明 | 資訊技術部 | 2024-03-06 | 09:03:00 |
| `E04` | 張大同 | 管理行政部 | 2024-03-07 | 09:12:00 |
| `E05` | 周美玲 | 業務發展部 | 2024-03-08 | 09:01:00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢列出所有 clock_in 嚴格大於 '09:00'（09:00 整不算遲到）的員工打卡紀錄（含 emp_id, name, dept, work_date, clock_in），依日期與打卡時間排序，並附上執行的 SQL。
  ```

---

### 題目 3（S3）：找出忘記刷卡的紀錄（`IS NULL`）

- **業務問題**：找出上班打卡**或**下班打卡為空白（`NULL`）的異常紀錄，方便人資通知補卡。
- **驗收條件**：應回傳 **3 筆**：`周美玲` 3/5 缺上班、`張大同` 3/6 缺下班、`陳小華` 3/7 缺下班。
- **✍️ 在 DBeaver 動手作提示**：`WHERE a.clock_in IS NULL OR a.clock_out IS NULL`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（3 筆）</summary>

```sql
SELECT e.emp_id, e.name, e.dept, a.work_date, a.clock_in, a.clock_out
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.clock_in IS NULL OR a.clock_out IS NULL
ORDER BY a.work_date, e.emp_id;
```

| emp_id | name | dept | work_date | clock_in | clock_out |
|---|---|---|---|---|---|
| `E05` | 周美玲 | 業務發展部 | 2024-03-05 | *(NULL)* | 18:03:00 |
| `E04` | 張大同 | 管理行政部 | 2024-03-06 | 08:58:00 | *(NULL)* |
| `E01` | 陳小華 | 業務發展部 | 2024-03-07 | 08:49:00 | *(NULL)* |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢找出 clock_in 或 clock_out 為 NULL 的忘記打卡紀錄（含 emp_id, name, dept, work_date, clock_in, clock_out），依日期排序並回傳 SQL。
  ```

---

### 題目 4（S4）：員工調部門只需改一次 `employees`（`BEGIN ... COMMIT`）

- **業務問題**：`黃雅婷` 從 `行銷企劃部` 調動到 **`業務發展部`**。請用交易語法**只修改 `employees` 表一列**，再用 `JOIN` 查詢黃雅婷的所有打卡紀錄，驗證 4 筆打卡是不是一口氣全部變成新部門！
- **驗收條件**：只影響 `employees` 的 `1` 列（`UPDATE 1`）；再查 `JOIN` 結果，黃雅婷的 **4 筆**打卡（3/4～3/7）部門全部顯示 **`業務發展部`**。
- **✍️ 在 DBeaver 動手作提示**：拆表之後，部門只存在 `employees`，所以調部門永遠不必去改 `attendance`。

<details>
<summary>👀 寫完再打開：參考 SQL 與調部門後查詢結果</summary>

```sql
BEGIN;

UPDATE employees
SET dept = '業務發展部'
WHERE name = '黃雅婷';

-- 立刻 JOIN 確認她的 4 筆打卡全部顯示新部門
SELECT e.name, e.dept, a.work_date, a.clock_in
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.name = '黃雅婷'
ORDER BY a.work_date;

COMMIT;
```

| name | dept | work_date | clock_in |
|---|---|---|---|
| 黃雅婷 | 業務發展部 | 2024-03-04 | 08:50:00 |
| 黃雅婷 | 業務發展部 | 2024-03-05 | 09:07:00 |
| 黃雅婷 | 業務發展部 | 2024-03-06 | 08:53:00 |
| 黃雅婷 | 業務發展部 | 2024-03-07 | 08:51:00 |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢（嚴禁呼叫修改或寫入工具）：
  我剛才在 DBeaver 把「黃雅婷」調去「業務發展部」，請幫我驗證：
  1. employees 裡黃雅婷的 dept 是否已經變成「業務發展部」？
  2. 用 JOIN 查黃雅婷的全部打卡明細（4 筆），是否每一筆都已經同步顯示為「業務發展部」？
  ```

---

### 題目 5（S5）：登記新進員工 ＋ 用 `LEFT JOIN ... IS NULL` 找出完全未打卡的人

- **業務問題**：
  1. 登記一位尚未開始打卡的新進人員：工號 `E07`、姓名 `'吳小安'`、部門 `'管理行政部'`、職稱 `'行政助理'`（另可再測一次相同工號，驗證會被主鍵攔下）。
  2. 用 **`LEFT JOIN`** 把「完全沒有任何打卡紀錄的員工」找出來！
- **驗收條件**：寫入後共有 **7 位員工**；`LEFT JOIN` 查詢應列出 **`E07` `吳小安`** 這 1 位。
- **✍️ 在 DBeaver 動手作提示**：`FROM employees e LEFT JOIN attendance a ON e.emp_id = a.emp_id WHERE a.emp_id IS NULL`。思考：為什麼改用 `INNER JOIN` 就永遠找不到 `吳小安`？

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果</summary>

```sql
-- 1. 新增尚未打卡的新進人員 E07
INSERT INTO employees (emp_id, name, dept, title)
VALUES ('E07', '吳小安', '管理行政部', '行政助理');

-- 2. 用 LEFT JOIN 找完全沒有打卡紀錄的員工
SELECT e.emp_id, e.name, e.dept, e.title
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id
WHERE a.emp_id IS NULL
ORDER BY e.emp_id;
```

| emp_id | name | dept | title |
|---|---|---|---|
| `E07` | 吳小安 | 管理行政部 | 行政助理 |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢（嚴禁新增或修改資料）：
  我剛才在 DBeaver 新增了新進員工 E07 吳小安，請用 LEFT JOIN 幫我查詢目前完全沒有打卡紀錄的員工有哪些，並順便確認目前 employees 總員工數是否已經變成 7 位。
  ```

---

## Part B｜進階 JOIN 與打卡分析題（E1～E5）

> 以下 E1～E5 皆以**做完 S1～S5 後**（共有 **7 位員工**、`黃雅婷` 已是 `業務發展部`、`吳小安` 尚無打卡）為基準！

### 題目 6（E1）：多條件 `JOIN` — 找出資訊技術部「晚上 20:00 後才下班」的加班紀錄

- **業務問題**：人資想了解 `資訊技術部` 同仁在本週晚上 **`20:00`（含）以後才打卡下班** 的詳細紀錄。
- **驗收條件**：應回傳 **2 筆**：`林志明` 3/4（`20:30:00`）與 `劉國強` 3/8（`21:05:00`）。
- **✍️ 在 DBeaver 動手作提示**：`WHERE e.dept = '資訊技術部' AND a.clock_out >= '20:00'`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT e.name, e.dept, a.work_date, a.clock_in, a.clock_out
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE e.dept = '資訊技術部'
  AND a.clock_out >= '20:00'
ORDER BY a.work_date, e.emp_id;
```

| name | dept | work_date | clock_in | clock_out |
|---|---|---|---|---|
| 林志明 | 資訊技術部 | 2024-03-04 | 09:15:00 | 20:30:00 |
| 劉國強 | 資訊技術部 | 2024-03-08 | 08:50:00 | 21:05:00 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢找出「資訊技術部」中下班打卡時間 clock_out >= '20:00' 的出勤紀錄，依日期排序回傳表格與 SQL。
  ```

---

### 題目 7（E2）：`LEFT JOIN` 條件放 `ON` 的經典陷阱 — 找出「3 月 6 日當天沒打卡」的員工

- **業務問題**：人資想列出 **`2024-03-06` 這一天完全沒有打卡紀錄** 的員工（提示：寫 `WHERE a.work_date = '2024-03-06'` 會把 `LEFT JOIN` 毀掉，必須把日期條件放進 `ON` 子句！）。
- **驗收條件**：應回傳 **2 位**：`E06` `劉國強`（當天請假/未打卡）與 `E07` `吳小安`（新進尚未打卡）。
- **✍️ 在 DBeaver 動手作提示**：`LEFT JOIN attendance a ON e.emp_id = a.emp_id AND a.work_date = '2024-03-06'`，最後再用 `WHERE a.work_date IS NULL`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT e.emp_id, e.name, e.dept
FROM employees e
LEFT JOIN attendance a
    ON e.emp_id = a.emp_id
   AND a.work_date = '2024-03-06'
WHERE a.work_date IS NULL
ORDER BY e.emp_id;
```

| emp_id | name | dept |
|---|---|---|
| `E06` | 劉國強 | 資訊技術部 |
| `E07` | 吳小安 | 管理行政部 |

> 💡 **為什麼日期條件一定要寫在 `ON`？** 如果把 `a.work_date = '2024-03-06'` 寫進 `WHERE`，所有在 3/6 沒有匹配的員工那一列（`a.work_date` 是 `NULL`）都會在 `WHERE` 階段被過濾光，結果會變成 0 筆！

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢使用 LEFT JOIN（日期條件放在 ON 上）找出在 2024-03-06 這一天完全沒有打卡紀錄的員工（包含 0 打卡的新人），依工號排序並回傳表格與 SQL。
  ```

---

### 題目 8（E3）：`LEFT JOIN` ＋ `GROUP BY` 統計每位員工本週出勤天數與遲到次數

- **業務問題**：月底出勤統計表！請對**全部 7 位員工**（就算 `E07` 吳小安是 0 天也要列出來！）統計「出勤天數」與「遲到次數（`clock_in > '09:00'`）」，依遲到次數由高到低、出勤天數由高到低、工號排序。
- **驗收條件**：必須出現 **7 列**，`林志明` 出勤 5 天遲到 2 次；`吳小安` 出勤 **0** 天遲到 **0** 次（提醒：要用 `COUNT(a.work_date)`，不可用 `COUNT(*)` 否則 `吳小安` 會被算成 1 天！）。
- **✍️ 在 DBeaver 動手作提示**：用 `COUNT(a.work_date)` 計出勤天數，用 `COUNT(*) FILTER (WHERE a.clock_in > '09:00')` 計遲到次數。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（7 筆）</summary>

```sql
SELECT
    e.emp_id,
    e.name,
    e.dept,
    COUNT(a.work_date)                           AS 出勤天數,
    COUNT(*) FILTER (WHERE a.clock_in > '09:00') AS 遲到次數
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, e.name, e.dept
ORDER BY 遲到次數 DESC, 出勤天數 DESC, e.emp_id;
```

| emp_id | name | dept | 出勤天數 | 遲到次數 |
|---|---|---|---|---|
| `E02` | 林志明 | 資訊技術部 | 5 | 2 |
| `E04` | 張大同 | 管理行政部 | 5 | 1 |
| `E05` | 周美玲 | 業務發展部 | 5 | 1 |
| `E03` | 黃雅婷 | 業務發展部 | 4 | 1 |
| `E01` | 陳小華 | 業務發展部 | 5 | 0 |
| `E06` | 劉國強 | 資訊技術部 | 4 | 0 |
| `E07` | 吳小安 | 管理行政部 | 0 | 0 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢用 LEFT JOIN 與 GROUP BY 統計全部 7 位員工各自的「出勤天數（注意 0 打卡的人要顯示 0）」與「遲到次數（clock_in > '09:00'）」，依遲到次數、出勤天數由高到低排序，回傳表格與 SQL。
  ```

---

### 題目 9（E4）：計算每日工時（`clock_out - clock_in`）並找出最長前 3 筆

- **業務問題**：PostgreSQL 的兩個 `TIME` 相減會直接算出 **`INTERVAL` 工時**！請計算出上班與下班都有紀錄的打卡工時，並列出工時最長的前 3 筆。
- **驗收條件**：第一名是 `E06` 劉國強 3/8（`12:15:00`），第二、三名是 `E02` 林志明 3/4（`11:15:00`）與 3/6（`10:07:00`）。
- **✍️ 在 DBeaver 動手作提示**：記得先用 `WHERE a.clock_in IS NOT NULL AND a.clock_out IS NOT NULL` 過濾掉缺卡紀錄（否則 `NULL` 相減為 `NULL` 會排在 `DESC` 最前面或變成無意義值）。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（3 筆）</summary>

```sql
SELECT
    e.emp_id,
    e.name,
    a.work_date,
    a.clock_in,
    a.clock_out,
    (a.clock_out - a.clock_in) AS 工時
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE a.clock_in IS NOT NULL
  AND a.clock_out IS NOT NULL
ORDER BY 工時 DESC, a.work_date
LIMIT 3;
```

| emp_id | name | work_date | clock_in | clock_out | 工時 |
|---|---|---|---|---|---|
| `E06` | 劉國強 | 2024-03-08 | 08:50:00 | 21:05:00 | `12:15:00` |
| `E02` | 林志明 | 2024-03-04 | 09:15:00 | 20:30:00 | `11:15:00` |
| `E02` | 林志明 | 2024-03-06 | 09:03:00 | 19:10:00 | `10:07:00` |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢計算出上下班時間皆完整的紀錄每日工時（clock_out - clock_in），依工時由長到短列出前 3 筆，回傳結果表格與 SQL。
  ```

---

### 題目 10（E5）：進階交易沙盒 — 批次補登忘打卡紀錄（＋ `CHECK` 攔截錯誤補卡與 `ROLLBACK` 復原）

- **業務問題**：
  1. **第一段（故意打錯測試攔截）**：假設補登 `E04`（3/6 上班 `08:58`）的下班時間時不小心打成 `'08:00'`（早於上班時間），觀察是否觸發 `CHECK (clock_out > clock_in)` 並執行 `ROLLBACK;`。
  2. **第二段（沙盒批次補登再復原）**：開啟 `BEGIN;`，一次補登兩筆忘打卡：`E04 (3/6)` 補下班 `'18:00'`、`E05 (3/5)` 補上班 `'08:50'`，在交易內查詢剩餘忘打卡筆數（應從 `3` 降成 `1`），最後執行 **`ROLLBACK;`** 復原回原本的 `3` 筆忘打卡！
- **驗收條件**：錯誤時間立刻被 `attendance_check` 擋下；正確沙盒內忘打卡降為 **`1` 筆**，`ROLLBACK;` 後恢復 **`3` 筆**。
- **✍️ 在 DBeaver 動手作提示**：注意第一段錯完一定要先執行 `ROLLBACK;` 清掉 aborted transaction，再開啟第二段 `BEGIN;`。

<details>
<summary>👀 寫完再打開：參考 SQL 與沙盒前後結果</summary>

```sql
-- 第一段：測試誤填比上班還早的下班時間（會失敗）
BEGIN;
UPDATE attendance SET clock_out = '08:00' WHERE emp_id = 'E04' AND work_date = '2024-03-06';
-- ERROR: new row for relation "attendance" violates check constraint "attendance_check"
ROLLBACK;

-- 第二段：沙盒批次補登兩筆並觀察前後變化，再 ROLLBACK
BEGIN;

UPDATE attendance SET clock_out = '18:00' WHERE emp_id = 'E04' AND work_date = '2024-03-06';
UPDATE attendance SET clock_in  = '08:50' WHERE emp_id = 'E05' AND work_date = '2024-03-05';

SELECT e.emp_id, e.name, a.work_date, a.clock_in, a.clock_out
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
WHERE (a.emp_id = 'E04' AND a.work_date = '2024-03-06')
   OR (a.emp_id = 'E05' AND a.work_date = '2024-03-05')
ORDER BY a.work_date;

SELECT COUNT(*) AS 沙盒尚有忘打卡數 FROM attendance WHERE clock_in IS NULL OR clock_out IS NULL; -- 1

ROLLBACK;

SELECT COUNT(*) AS 復原後忘打卡數 FROM attendance WHERE clock_in IS NULL OR clock_out IS NULL; -- 3
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代改）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢（嚴禁使用 modify 或任何修改工具）：
  我剛才在 DBeaver 用 BEGIN ... ROLLBACK 測試補登 E04 (3/6) 與 E05 (3/5) 打卡並且已 ROLLBACK 復原。請幫我查證：
  1. 目前忘記打卡（clock_in IS NULL OR clock_out IS NULL）是否仍然剛好是 3 筆？
  2. E04 在 2024-03-06 的 clock_out、以及 E05 在 2024-03-05 的 clock_in 是否都確定維持 NULL？
  ```

---

## 🤖 問 AI 助教（複習 `JOIN` 與 `LEFT JOIN` 核心）

```text
我剛做完 attendance 資料庫的 10 題 JOIN / 彙總 DML，並用 Microsoft Postgres MCP 完成比對。
請幫我整理三個我容易寫錯的地方：(1) JOIN vs LEFT JOIN 何時該用哪個 (2) 為什麼 LEFT JOIN 的篩選條件放 ON 和放 WHERE 差那麼多 (3) 為什麼 COUNT(欄位) 和 COUNT(*) 在 LEFT JOIN 後會得出不同數字。
```

---

👉 **所有故事與進階練習都親手跑完並驗證過了！接著前往 [步驟 5｜MCP 讀結構產生 PRD](prompts/01_MCP讀結構產生PRD.md)！**
