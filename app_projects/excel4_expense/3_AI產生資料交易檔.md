# 步驟 3｜AI 產生資料交易檔：拆出四表、處理 `SERIAL` 與對齊 `setval`

> **本步驟核心：不用匯入現成 `.sql` 救援檔！**  
> 當一張總表要拆成 4 張有關聯的表（其中 `departments`、`categories` 的主鍵在 Excel 裡根本沒有編號），我們要讓 AI 產生一份包含 **`setval(pg_get_serial_sequence(...))`** 的標準 **`BEGIN; ... COMMIT;` 交易檔**，讓後續新增類別時編號能完美接續下去！

---

## 為什麼這題需要 `setval`？

在交易檔裡，為了讓 AI 一次產出清楚的寫入關係，通常會直接幫部門填 `1..4`、類別填 `1..9`。  
但如果**沒有最後那兩句 `SELECT setval(...)`**，PostgreSQL 的自動編號計數器會停留在 `1`！下次你在步驟 4 新增第 10 個類別「員工訓練」時，資料庫就會試圖發 `category_id = 1` 並撞到主鍵重複報錯。

---

## 給 AI 的「多表去重 ＋ `setval` 交易檔 Prompt」

附上 [差旅報銷單.xlsx](差旅報銷單.xlsx) 的 `2024年3月費用報銷清單` 工作表，**貼上你在步驟 2 親手寫好的 4 句 `CREATE TABLE`**，發送這段 Prompt：

```text
請幫我把附件「差旅報銷單.xlsx」的「2024年3月費用報銷清單」工作表，轉換成 PostgreSQL 的多表資料寫入交易檔（純 SQL）。

我的四張資料表結構如下：
（把你在步驟 2 寫的四句 CREATE TABLE 貼在這裡）

嚴格規則：
1. 只能輸出交易控制（BEGIN; ... COMMIT;）、INSERT 語法與對齊 SERIAL 序列的 SELECT setval(...)，禁止任何 CREATE、DROP、ALTER、TRUNCATE，也禁止透過 MCP 直接修改資料庫。
2. 必須按相依順序寫入：
   (1) departments（去重後 4 個部門，依序編號 dept_id 1～4）
   (2) categories（去重後 9 個費用類別，依序編號 category_id 1～9）
   (3) 立即用 SELECT setval(pg_get_serial_sequence('departments', 'dept_id'), 4); 與 SELECT setval(pg_get_serial_sequence('categories', 'category_id'), 9); 對齊自動編號
   (4) employees（去重後 5 位員工，對應正確 dept_id）
   (5) claims（全部 13 張報銷單，對應正確 emp_id 與 category_id）
3. 金額 amount 不要加千分位逗號或貨幣符號。
```

---

## 執行前自我檢查（檢查這 4 點最關鍵）

1. **寫入順序**：`departments`、`categories` → `setval(...)` → `employees` → `claims`。
2. **`setval` 沒有漏**：務必檢查有沒有 `setval` 到 `4` 和 `9`！
3. **兩位都是李副總沒關係**：`技術部 (2)` 和 `人事部 (4)` 的主管都是 `'李副總'`，部門要確實保留 **4 個**。
4. **整批包進交易**：`BEGIN;` 開頭、`COMMIT;` 結尾，共 `13` 張報銷單。

確認完成後貼進 DBeaver 新編輯器（存成 `建立資料.sql`）按執行！

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

### ① Excel 公式（在 `差旅報銷單.xlsx` 驗算）
- 報銷單數：`=COUNTA(A2:A14)` → **13**
- 報銷總金額：`=SUM(J2:J14)` → **33,360**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT
    (SELECT COUNT(*) FROM departments) AS 部門數,
    (SELECT COUNT(*) FROM categories)  AS 類別數,
    (SELECT COUNT(*) FROM employees)   AS 員工數,
    (SELECT COUNT(*) FROM claims)      AS 報銷單數,
    (SELECT SUM(amount) FROM claims)   AS 報銷總金額;

SELECT status AS 審核狀態, COUNT(*) AS 張數, SUM(amount) AS 小計
FROM claims
GROUP BY status
ORDER BY 張數 DESC;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 expense 資料庫，只用唯讀查詢（SELECT）幫我核對目前四張表的對帳數字：
1. departments（4 筆）、categories（9 筆）、employees（5 筆）、claims（13 筆）與 claims 總金額（是否為 33360.00？）。
2. claims 依 status 分組各自的張數與金額合計。
嚴禁呼叫任何修改工具。
```

---

## ✍️ 動手練（原子性 `ROLLBACK` 保護 ＋ 請 AI 建立安全審核／記帳交易）

1. **故意撞重複發票測原子性與 `ROLLBACK`**：  
   在 DBeaver 開新分頁試著跑以下包含兩張單的交易，其中第二張單刻意沿用已經存在的發票 `'AB-98765431'`：
   ```sql
   BEGIN;
   -- 第一張是合法新單據
   INSERT INTO claims VALUES ('EXP-TEMP-01', '2024-03-30', 'E01', 1, '合法測試單', 'ZZ-00000001', 500, '待審核');
   -- 第二張誤填重複發票 'AB-98765431'
   INSERT INTO claims VALUES ('EXP-TEMP-02', '2024-03-30', 'E01', 1, '重複發票誤報', 'AB-98765431', 500, '待審核');
   ```
   收到 `duplicate key value violates unique constraint "claims_invoice_no_key"` 後執行 `ROLLBACK;`，再查 `SELECT COUNT(*) FROM claims;` —— **`EXP-TEMP-01` 也不會殘留，總筆數依舊是 `13` 張！**

2. **請 AI 建立「同時核准單據 ＋ 新增一筆後續撥款申請」業務交易 Prompt**：  
   用這段 Prompt 讓 AI 寫一組多步驟安全交易，自己在 DBeaver 試跑並 `ROLLBACK;`：
   ```text
   請根據我建立的 expense 四張表，幫我寫一個 PostgreSQL Transaction（不要用 MCP 寫入，只給我 SQL）：
   1. 用 BEGIN; 開頭，交易最後不要自動 COMMIT;，改成先查詢 EXP20240312 的最新狀態與部門待撥款清單，然後加上 ROLLBACK; 讓我安心測試不改變原本資料。
   2. 交易內做兩件事：
      - 安全批准 EXP20240312（必須加上 AND status = '待審核' 防呆）
      - 幫業務部林美（不對，幫 E05 周美玲）新增一張類別 1（市區交通）的測試單 EXP-TEST-99（日期 2024-03-29、發票 TT-12345678、金額 450、狀態 '待撥款'）
   ```
   <details>
   <summary>👀 參考答案（測試完確認筆數回到 13 張）</summary>

   ```sql
   BEGIN;

   UPDATE claims
   SET status = '已批准'
   WHERE claim_id = 'EXP20240312' AND status = '待審核';

   INSERT INTO claims (claim_id, claim_date, emp_id, category_id, description, invoice_no, amount, status)
   VALUES ('EXP-TEST-99', '2024-03-29', 'E05', 1, '市區拜訪計程車測試', 'TT-12345678', 450, '待撥款');

   SELECT claim_id, status, amount FROM claims WHERE claim_id IN ('EXP20240312', 'EXP-TEST-99');

   ROLLBACK;

   SELECT COUNT(*) AS 復原後報銷單數 FROM claims; -- 應仍為 13
   ```
   </details>

---

## 🤖 問 AI 助教（處理交易檔或 `setval` 錯誤）

```text
我在 DBeaver 執行你幫我產生的 expense 多表交易檔時遇到以下錯誤：
（貼上完整 ERROR 訊息與行數）
請不要用 MCP 修改資料庫，先告訴我是外來鍵編號對不上、發票重複、還是金額欄位格式錯誤，再提供修正後的完整 SQL。
```

---

👉 **四表對帳與編號皆完美！前往 [步驟 4｜10 題多表 JOIN 實戰練功與 MCP 雙軌驗證](4_多表JOIN回答故事.md)**
