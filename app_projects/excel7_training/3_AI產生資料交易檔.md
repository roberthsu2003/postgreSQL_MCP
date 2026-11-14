# 步驟 3｜AI 產生資料交易檔：用 `BEGIN ... COMMIT` 轉入真實資料

> 💻 AI 工具 ＋ DBeaver（資料庫：`training`）｜ 🎯 學完你會：把雙名單 Excel 交給 AI 轉成受 Transaction（交易）保護的純 `INSERT` SQL，並做三方對帳與 `ROLLBACK` 保護演練

## 1. 請 AI 把 Excel 轉成純資料交易 SQL

請開啟 [`教育訓練報名表.xlsx`](./教育訓練報名表.xlsx)，同時準備好你在步驟 2 手寫完成的五張 `CREATE TABLE` 語法，將下面提示詞貼給 AI 並附上前三張工作表（`課程清單`、`內部員工報名`、`外部來賓報名`）的內容：

```markdown
這是我手寫建立好的 PostgreSQL 資料表結構：
（貼上你在步驟 2 寫的 5 張 CREATE TABLE 語法）

以下是教育訓練 Excel 的三張工作表資料：
1. 【課程清單】：
（貼上 6 筆課程資料）
2. 【內部員工報名】：
（貼上 14 筆內部員工報名資料）
3. 【外部來賓報名】：
（貼上 7 筆外部來賓報名資料）

請幫我產生一份「純資料寫入的 SQL Transaction 交易檔」，嚴格遵守以下規則：
1. 用 BEGIN; 開頭、COMMIT; 結尾，讓所有寫入要嘛全部成功、要嘛失敗後全部回滾。
2. 絕對不可以包含 DROP TABLE 或 CREATE TABLE（資料表我已經親手建好了）。
3. 內部員工請先去重整理為不重複的 employees（依 emp_id），外部來賓依 email 去重整理為不重複的 guests。
4. 寫入順序必須先寫主表：courses -> employees -> guests，再寫明細表：employee_enrollments -> guest_enrollments。
5. 若 guests 指定了明確的 guest_id，寫入 guests 後請記得執行 SELECT setval(pg_get_serial_sequence('guests', 'guest_id'), MAX(guest_id)) FROM guests; 更新序列。
6. 出席欄位轉換規則：「是」轉為 true、「否」轉為 false、空白轉為不加引號的 NULL。
7. 輸出成乾淨可直接複製到 DBeaver 執行的單一 SQL 區塊。
```

## 2. 執行前先幫 AI 檢查這 5 件事

收到 AI 產生的 SQL 後，**先別急著全選執行**，用肉眼核對這五點：

- [ ] **有交易邊界嗎？** 開頭是 `BEGIN;`，結尾是 `COMMIT;`
- [ ] **沒有破壞結構嗎？** 沒有任何 `DROP TABLE`、`TRUNCATE` 或 `CREATE TABLE`
- [ ] **順序正確嗎？** 先寫 `courses` / `employees` / `guests`，最後才寫 `employee_enrollments` / `guest_enrollments`
- [ ] **空白出席對了嗎？** `C06` 那三筆尚未登記出席的資料寫成 `NULL`（**沒有單引號**，不能寫成 `'NULL'` 或 `false`）
- [ ] **有維護 `SERIAL` 嗎？** 如果明確塞入 `guest_id`（`1`～`5`），後面緊接 `setval(...)` 校正序列

確認無誤後，貼進 DBeaver 並**全選後按 Execute SQL Script（Alt+X）**一次送出整筆交易！

## 3. 三方對帳：Excel、DBeaver、Microsoft Postgres MCP

寫入成功後，在三個地方互相核對總數，確定沒有漏轉或重複：

| 對帳項目 | Excel 公式做法 | 預期總數 |
|---|---|---:|
| 課程數 | `課程清單` 頁：`=COUNTA(A2:A7)` | **6** |
| 不重複員工數 | 依工號去重筆數（`E01`～`E06`） | **6** |
| 不重複來賓數 | 依信箱去重筆數（5 個信箱） | **5** |
| 內部報名明細 | `內部員工報名` 頁：`=COUNTA(A2:A15)` | **14** |
| 外部報名明細 | `外部來賓報名` 頁：`=COUNTA(A2:A8)` | **7** |
| 尚未登記 (`NULL`) | 內部 2 筆（`C06`）＋ 外部 1 筆（`C06`） | **3** |

### 在 DBeaver 執行 SQL 對帳：
```sql
SELECT
    (SELECT COUNT(*) FROM courses) AS 課程數,
    (SELECT COUNT(*) FROM employees) AS 員工數,
    (SELECT COUNT(*) FROM guests) AS 來賓數,
    (SELECT COUNT(*) FROM employee_enrollments) AS 內部報名筆數,
    (SELECT COUNT(*) FROM guest_enrollments) AS 外部報名筆數,
    (SELECT COUNT(*) FROM employee_enrollments WHERE attended IS NULL) AS 內部未登記,
    (SELECT COUNT(*) FROM guest_enrollments WHERE attended IS NULL) AS 外部未登記;
```

### 用 Microsoft Postgres MCP 做唯讀核對：
在 Antigravity 貼上以下提示詞，讓 AI 幫你核對資料庫實況：

```markdown
請用 Microsoft Postgres MCP（僅限查詢，嚴禁使用 postgres_mcp_modify）連線至 training 資料庫，並執行 SELECT COUNT(*) 核對：
- courses 應為 6 筆、employees 應為 6 筆、guests 應為 5 筆
- employee_enrollments 應為 14 筆（其中 attended IS NULL 有 2 筆）
- guest_enrollments 應為 7 筆（其中 attended IS NULL 有 1 筆）
順便確認兩位「陳小華」在 employees 與 guests 中是否各自獨立存在。
```

## 4. 演練 Transaction 的錯誤回滾保護（`ROLLBACK`）

體會為什麼資料寫入要包在 `BEGIN ... COMMIT;` 裡：在 DBeaver **逐行或整段試跑**下面這個故意出錯的交易：

```sql
BEGIN;

-- 第 1 步看似合法：新增一位臨時來賓
INSERT INTO guests (name, company, email)
VALUES ('測試來賓', '臨時企業', 'temp@example.com');

-- 第 2 步故意出錯：報名不存在的課程 C99（外來鍵錯誤）
INSERT INTO guest_enrollments (course_id, guest_id, attended)
VALUES ('C99', currval(pg_get_serial_sequence('guests', 'guest_id')), true);

COMMIT;
```

第 2 步會立刻被外來鍵擋下。此時請執行 `ROLLBACK;`，再查詢 `SELECT * FROM guests WHERE email = 'temp@example.com';`——你會發現**連同第 1 步看似成功的「測試來賓」也被一併撤銷，完全不留半套髒資料！**

## 5. 🤖 請 AI 寫一個複合業務交易（實務練習）

日常工作常常需要把「建新課 + 幫整批業務部門員工報名」綁成一筆交易，現在試著請 AI 幫你產生這段交易 SQL（看完邏輯再決定要不要在測試後 `ROLLBACK`）：

```markdown
請根據我在 training 資料庫的五張表結構，幫我撰寫一個只做練習用的 PostgreSQL Transaction 範例（最後先用 ROLLBACK; 結尾方便我測試不留髒資料）：
1. 新增一門課程 'C07'、'商務簡報進階'、'2024-06-20'、'王講師'、上限 15 人。
2. 同時把所有 dept = '業務發展部' 的員工整批寫入 employee_enrollments 報名這門課（attended 設為 NULL）。
3. 查詢確認這門課的新增報名名單後，執行 ROLLBACK; 保持原本 6 門課的初始資料不變。
```

## ⚠️ 常見卡關

| 現象 | 原因 | 怎麼解 |
|---|---|---|
| 執行時顯示 `duplicate key value violates unique constraint "employees_pkey"` | AI 沒有把 14 筆員工報名裡重複的員工去重（例如 `E01` 出現三次） | 先執行 `ROLLBACK;`，請 AI 用 `INSERT ... ON CONFLICT DO NOTHING` 或先挑出不重複的 6 位員工 |
| `attended` 出現 `invalid input syntax for type boolean: "NULL"` | AI 把空白加上了單引號 `'NULL'` | 改成不加引號的 `NULL`（大小寫皆可） |
| 想要全部重來再測一次交易檔 | 表裡已經寫入部分資料 | 在 DBeaver 執行 `TRUNCATE guest_enrollments, employee_enrollments, guests, employees, courses RESTART IDENTITY;` 清空後重跑交易 SQL |

## ✍️ 動手練

**1. 如果 AI 產生的 SQL 忘了加 `SELECT setval(...)`，又寫死了 `guest_id = 1..5`，之後公司多來了一位第 6 位來賓、不指定 `guest_id` 新增時會發生什麼事？**

<details>
<summary>看答案</summary>

`SERIAL` 的序列還會停在 `1`，下一次新增時會嘗試配發 `guest_id = 1` 而撞上主鍵重複錯誤 (`duplicate key value violates unique constraint "guests_pkey"`)，直到序列追上 `6` 才會成功。因此指定 ID 寫入後務必用 `setval` 同步序列！

</details>

**2. 為什麼在 `BEGIN ... COMMIT` 交易裡，只要有一筆 `INSERT` 失敗，後面就算寫了 `COMMIT;` PostgreSQL 也不會讓你部分寫入成功？**

<details>
<summary>看答案</summary>

PostgreSQL 只要在同一個 Transaction 內發生錯誤，就會進入 aborted 狀態並忽略後續指令；最後送出 `COMMIT;` 時會自動等同 `ROLLBACK` 全部還原，確保資料表不會留下一半主檔、缺一半明細的殘破狀態。

</details>

## 🤖 問 AI 助教

> 請比較「用 `BEGIN; ... COMMIT;` 一次寫入 5 張表」和「沒包交易、一張表一張表分開執行 `INSERT`」，萬一寫到第 4 張表 `employee_enrollments` 才發現外來鍵或欄位型別錯誤時，資料庫狀態會有什麼差別？

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 專案導覽](./README.md) | [步驟 4：合併與連結回答故事 ➡️](./4_合併與連結回答故事.md) |
