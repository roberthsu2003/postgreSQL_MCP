# 步驟 3｜AI 產生資料交易檔：把總表拆成兩份並寫進 Transaction

> **本步驟核心：不用匯入現成 `.sql` 救援檔！**  
> 你自己貼上步驟 2 親手寫好的兩句 `CREATE TABLE` 與 [打卡表.xlsx](打卡表.xlsx)，請 AI 先發現並詢問 `E05` 周美玲的部門矛盾，再產生**「先寫父表 `employees`、再寫子表 `attendance`」**的標準 **`BEGIN; ... COMMIT;` 交易檔**。

---

## 給 AI 的「拆表建立交易檔 Prompt」

附上 [打卡表.xlsx](打卡表.xlsx)（`打卡紀錄` 工作表），貼上你在步驟 2 寫的兩句 `CREATE TABLE`，發送這段 Prompt：

```text
請幫我把附件「打卡表.xlsx」裡的「打卡紀錄」工作表，轉換成 PostgreSQL 的資料寫入交易檔（純 SQL）。

我已在資料庫建好以下兩張表：
（把你在步驟 2 寫的 CREATE TABLE employees (...) 與 CREATE TABLE attendance (...) 貼在這裡）

嚴格規則：
1. 只能輸出交易控制（BEGIN; ... COMMIT;）和 INSERT 語法，禁止任何 CREATE、DROP、ALTER、TRUNCATE，也禁止直接透過 MCP 寫入資料庫。
2. 寫入順序必須先寫父表 employees（去重後的 6 位員工），再寫子表 attendance（28 筆打卡）。
3. 如果你在資料中發現同一個工號對應到不同的部門名稱，請不要擅自猜測哪個對，先在回覆中告訴我矛盾在哪裡、停下來等我確認正確部門後再產出 SQL。
4. 打卡時間空白的格子必須轉成 NULL（不加引號），時間保留 'HH:MM' 或 'HH:MM:SS'，日期為 'YYYY-MM-DD'。
```

> 💡 **實測看看 AI 有沒有替你把關！**  
> 當你發現 AI 回覆你：「工號 `E05` 周美玲在 3/7 寫『業務部』，其他天寫『業務發展部』，請問要以哪個為準？」——恭喜！這就是 Prompt 裡第 3 點在發揮作用。請回答它：**「以『業務發展部』為準，現在請產出完整的 `BEGIN; ... COMMIT;` 交易檔。」**

---

## 執行前自我檢查（花 30 秒檢查這 4 點）

1. **順序對了嗎**：`employees` 的 6 位員工一定在 `attendance` 的 28 筆打卡前面。
2. **`E05` 正確嗎**：`E05` 周美玲在 `employees` 裡的部門要是 `'業務發展部'`，且全部員工剛好 6 位（沒有多出一筆叫「業務部」的幽靈重複）。
3. **空白變 `NULL`**：檢查 `E05 (3/5)` 的 `clock_in`、`E04 (3/6)` 的 `clock_out`、`E01 (3/7)` 的 `clock_out` 三格都是 `NULL`。
4. **整批交易包住**：開頭 `BEGIN;`，結尾 `COMMIT;`。

確認完畢後貼進 DBeaver 新分頁（存成 `建立資料.sql`）按執行！

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

### ① Excel 公式（`打卡表.xlsx` 的 `打卡紀錄` 工作表）
- 打卡總筆數：`=COUNTA(A2:A29)` → **28**
- 遲到（`> 09:00`）：**5**
- 忘記刷卡（空白 `clock_in` 或 `clock_out`）：**3**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT
    (SELECT COUNT(*) FROM employees)                                 AS 員工數,
    (SELECT COUNT(*) FROM attendance)                                AS 打卡數,
    (SELECT COUNT(*) FROM attendance WHERE clock_in > '09:00')       AS 遲到數,
    (SELECT COUNT(*) FROM attendance WHERE clock_in IS NULL OR clock_out IS NULL) AS 忘打卡數;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 attendance 資料庫，只用唯讀查詢（SELECT）幫我核對以下四個數字：
1. employees 總員工數（是否為 6 位？）
2. attendance 總打卡筆數（是否為 28 筆？）
3. clock_in > '09:00' 的遲到次數（是否為 5 次，09:00 整不算？）
4. clock_in IS NULL OR clock_out IS NULL 的忘打卡紀錄數（是否為 3 筆？）
請列出結果表格與 SQL，嚴禁呼叫修改工具。
```

對齊 **員工 `6`、打卡 `28`、遲到 `5`、忘打卡 `3`**，對帳即通過！

---

## ✍️ 動手練（原子性 `ROLLBACK` 保護 ＋ 請 AI 產生人事交易）

1. **故意「先子後父」測原子性與 `ROLLBACK`**：  
   在 DBeaver 開新分頁試著跑以下把順序弄反（或包含不存在員工）的交易：
   ```sql
   BEGIN;
   -- 第一步成功：把 E04 改名為張大為
   UPDATE employees SET name = '張大為' WHERE emp_id = 'E04';
   -- 第二步失敗：插入不存在的員工 E99 打卡紀錄
   INSERT INTO attendance VALUES ('E99', '2024-03-11', '08:55', '18:00');
   ```
   遇到外來鍵錯誤後執行 `ROLLBACK;`，再查 `SELECT emp_id, name FROM employees WHERE emp_id = 'E04';`，確認姓名仍是 **`張大同`**！

2. **請 AI 設計「新人報到 ＋ 首日打卡」交易 Prompt**：  
   假設新進人員 `E08` `趙文豪`（`行銷企劃部`、`數位行銷專員`）今天報到並立刻留下一筆 `2024-03-11` `08:52` 上班卡（尚未下班，`clock_out` 為 `NULL`）。請把下面這段 Prompt 貼給 AI 寫出交易並用 `ROLLBACK;` 測試：
   ```text
   請根據我建立的 employees 與 attendance 資料表，幫我撰寫一個 PostgreSQL 交易（不要使用 MCP 寫入，只輸出 SQL）：
   1. 用 BEGIN; 開頭，最後放兩張表的 JOIN 查詢結果，並加上一句 ROLLBACK; 方便我在 DBeaver 測試確認不影響後續練習。
   2. 在交易內完成：
      - 先新增員工 E08（趙文豪、行銷企劃部、數位行銷專員）
      - 再替 E08 新增一筆 2024-03-11 上班 08:52、下班 NULL 的打卡紀錄
   ```
   <details>
   <summary>👀 參考答案（測試完確認 E08 已回滾不存在）</summary>

   ```sql
   BEGIN;

   INSERT INTO employees (emp_id, name, dept, title)
   VALUES ('E08', '趙文豪', '行銷企劃部', '數位行銷專員');

   INSERT INTO attendance (emp_id, work_date, clock_in, clock_out)
   VALUES ('E08', '2024-03-11', '08:52', NULL);

   SELECT e.emp_id, e.name, e.dept, a.work_date, a.clock_in, a.clock_out
   FROM employees e
   JOIN attendance a ON e.emp_id = a.emp_id
   WHERE e.emp_id = 'E08';

   ROLLBACK;

   SELECT COUNT(*) AS 復原後員工數 FROM employees; -- 仍為 6
   ```
   </details>

---

## 🤖 問 AI 助教（遇到錯誤先診斷）

```text
我在 DBeaver 執行你產生的 employees / attendance 交易檔時收到這則錯誤：
（貼上錯誤訊息與出錯行）
請不要用 MCP 修改資料庫，先解釋是因為父子表寫入順序錯了、主鍵重複、還是 CHECK(clock_out > clock_in) 被違反，再給我修正後的完整 SQL。
```

---

👉 **對帳數字完美一致！前往 [步驟 4｜10 題 JOIN 實戰練功與 MCP 雙軌驗證](4_JOIN回答故事.md)**
