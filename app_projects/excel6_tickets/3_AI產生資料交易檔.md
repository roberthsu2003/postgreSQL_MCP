# 步驟 3｜AI 產生資料交易檔：保留原文與 `setval` 的三表交易檔

> **本步驟核心：不用匯入現成 `.sql` 救援檔！**  
> 這份 Excel 裡的 `問題描述` 刻意同時存在 `WiFi`、`wifi`、`WIFI`、`Wi-Fi` 四種寫法——務必要求 AI **原封不動保留原始字樣（不要幫你自作聰明統一格式！）**，這樣步驟 4 才能練到真實職場的模糊搜尋技巧！

---

## 給 AI 的「三表去重 ＋ 保留原文交易檔 Prompt」

附上 [客服案件紀錄.xlsx](客服案件紀錄.xlsx)（`案件紀錄` 工作表），貼上你在步驟 2 手寫好的三句 `CREATE TABLE`，發送這段 Prompt：

```text
請幫我把附件「客服案件紀錄.xlsx」的「案件紀錄」工作表（共 30 件），轉換成 PostgreSQL 的多表資料寫入交易檔（純 SQL）。

我的三張資料表結構如下：
（把你在步驟 2 寫的三句 CREATE TABLE 貼在這裡）

嚴格轉換規則：
1. 只能輸出交易控制（BEGIN; ... COMMIT;）、INSERT 語法與對齊 SERIAL 的 SELECT setval(...)，禁止 CREATE、DROP、ALTER、TRUNCATE，也禁止透過 MCP 直接修改資料庫。
2. 寫入順序必須先寫 agents（4 位人員，agent_id 1～4）與 categories（4 個分類，category_id 1～4），接著立即加上 SELECT setval(pg_get_serial_sequence('agents', 'agent_id'), 4); 與 SELECT setval(pg_get_serial_sequence('categories', 'category_id'), 4);，最後再寫 30 件 tickets。
3. tickets.description 必須完全保留 Excel 裡的原始寫法（包括 WiFi / wifi / WIFI / Wi-Fi 的大小寫與連字號差異），絕對不要自動統一改寫！
4. 「結案日期（closed_on）」空白的格子必須轉成 NULL（不加引號）。
```

---

## 執行前自我檢查（檢查這 4 點最關鍵）

1. **原文有沒有被 AI「偷美化」？**：檢查 `T005` 還是不是 `'wifi ...'`、`T009` 還是不是 `'WIFI ...'`、`T013` 還是不是 `'Wi-Fi ...'`！如果都被改成了 `'WiFi'`，請要求 AI 保留原始文字重產。
2. **空白變 `NULL`**：未結案那 11 件的 `closed_on` 必須是 `NULL`。
3. **`setval` 存在**：`agents` 與 `categories` 都對齊到 `4`。
4. **整批交易包住**：`BEGIN;` 開頭、`COMMIT;` 結尾，共 `30` 件。

確認沒問題後貼進 DBeaver 新編輯器（存成 `建立資料.sql`）按執行！

---

## 三方對帳：Excel 公式 vs DBeaver SQL vs MCP 查詢

### ① Excel 公式（在 `客服案件紀錄.xlsx` 驗算）
- 總案件數：`=COUNTA(A2:A31)` → **30**
- 已結案件數：`=COUNTIF(H2:H31, "已結案")` → **19**

### ② DBeaver 手寫對帳 SQL
```sql
SELECT
    (SELECT COUNT(*) FROM agents)     AS 人員數,
    (SELECT COUNT(*) FROM categories) AS 分類數,
    (SELECT COUNT(*) FROM tickets)    AS 案件總數,
    (SELECT COUNT(*) FROM tickets WHERE status = '已結案') AS 已結案數;

SELECT status AS 狀態, COUNT(*) AS 件數 FROM tickets GROUP BY status ORDER BY 件數 DESC;
```

### ③ 🤖 Microsoft Postgres MCP 對帳查詢 Prompt
```text
請透過 Microsoft Postgres MCP 連線到我的 tickets 資料庫，只用唯讀查詢（SELECT）幫我核對：
1. agents(4)、categories(4)、tickets(30)、已結案數(19) 是否完全一致？
2. 檢查 description 包含 WiFi/wifi/WIFI/Wi-Fi 的原始筆數，確認 AI 產交易檔時沒有竄改大小寫與連字號。
嚴禁呼叫修改工具。
```

---

## ✍️ 動手練（原子性 `ROLLBACK` 保護 ＋ 請 AI 設計批次分派／結案交易）

1. **故意放入一筆「違反結案規則」測整批 `ROLLBACK`**：  
   在 DBeaver 開新分頁試著跑以下交易，其中第一件合格、第二件偷塞「已結案卻 `closed_on` 為 `NULL`」：
   ```sql
   BEGIN;
   INSERT INTO tickets VALUES ('T-TMP-1', '2024-04-01', '順發貿易', 1, '合法測試單', 1, '處理中', NULL);
   INSERT INTO tickets VALUES ('T-TMP-2', '2024-04-01', '順發貿易', 1, '已結案漏填日', 1, '已結案', NULL);
   ```
   收到 `violates check constraint "tickets_check"` 後執行 `ROLLBACK;`，再查 `SELECT COUNT(*) FROM tickets;` —— **`T-TMP-1` 也不會殘留，案件總數依然是 `30` 件！**

2. **請 AI 幫你寫「批次改派人員 ＋ 結案」業務交易 Prompt**：  
   假設張育誠負荷太重，要把他手上還沒結案的 `T018` 改派給 `林佳穎（agent_id = 3）`，同時將已經處理完成的 `T020` 安全結案（日期 `'2024-03-29'`）。請貼這段 Prompt 讓 AI 產出交易並在 DBeaver 用 `ROLLBACK;` 試跑：
   ```text
   請根據我建立的 tickets 三張表，幫我寫一個 PostgreSQL Transaction（不要用 MCP 寫入，只給我 SQL）：
   1. 用 BEGIN; 開頭，交易最後附上 SELECT 驗證改動結果，並加上 ROLLBACK; 方便我在 DBeaver 測試而不影響步驟 4。
   2. 交易動作：
      - 將尚未結案的 T018 改派給 agent_id = 3（需加 AND status <> '已結案'）
      - 將尚未結案的 T020 安全結案，closed_on 設為 '2024-03-29'（需加 AND status <> '已結案'）
   ```
   <details>
   <summary>👀 參考答案（測試完自動復原）</summary>

   ```sql
   BEGIN;

   UPDATE tickets
   SET agent_id = 3
   WHERE ticket_id = 'T018' AND status <> '已結案';

   UPDATE tickets
   SET status = '已結案', closed_on = '2024-03-29'
   WHERE ticket_id = 'T020' AND status <> '已結案';

   SELECT ticket_id, agent_id, status, closed_on
   FROM tickets
   WHERE ticket_id IN ('T018', 'T020')
   ORDER BY ticket_id;

   ROLLBACK;

   SELECT COUNT(*) AS 復原後已結案數 FROM tickets WHERE status = '已結案'; -- 應仍為 19
   ```
   </details>

---

## 🤖 問 AI 助教（交易檔寫入疑難排查）

```text
我在 DBeaver 執行你幫我產生的 tickets 三表交易檔時遇到以下錯誤：
（貼上完整 ERROR 訊息與行數）
請不要用 MCP 修改資料庫，先告訴我是人員/分類外來鍵對不上、還是 status 與 closed_on 不符雙重 CHECK 規則，再給我修正後的完整 SQL。
```

---

👉 **對帳數字完美一致！前往 [步驟 4｜10 題客服統計 DML 實戰與 MCP 雙軌驗證](4_搜尋與統計回答故事.md)**
