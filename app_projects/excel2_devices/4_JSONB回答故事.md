# 步驟 4｜10 題 JSONB DML 實戰 ＋ Microsoft Postgres MCP 雙軌驗證

> **學習節奏（三步練功循環）**：  
> **① 自己動手寫**：在 DBeaver（`我的查詢.sql`）自己寫 SQL 執行。  
> **② 核對標準答案**：展開 `<details>` 對照參考 SQL、注意事項與真實結果表。  
> **③ 用 Microsoft Postgres MCP 驗證**：複製該題的 **MCP Prompt** 請 AI 唯讀查詢 `devices` 資料庫，比較手寫結果與 AI 結果是否吻合！
>
> **關於資料狀態的說明**：
> - **Part A（S1～S5）** 照故事順序執行（包含 S4 把 `NB-003` 升級到 `16GB` 並 `COMMIT`；S5 新增 `TB-001` 平板成 `17` 台設備）。
> - **Part B（E1～E5）** 的預期結果皆以**「做完 S1～S5 後（共 17 台、總採購額 485,900）」**為基準；**E5 交易沙盒**使用 `BEGIN; ... ROLLBACK;` 復原，不破壞資料！
> - 若不小心把資料改亂，在 DBeaver 執行 `TRUNCATE TABLE devices;` 後重新執行你在步驟 3 產生的交易檔即可恢復初始 16 台。

---

## Part A｜核心業務故事（S1～S5 任務挑戰）

### 題目 1（S1）：找出記憶體 `16GB` 以上的筆電（JSONB 轉整數篩選）

- **業務問題**：資訊人員想列出所有類型為 `'筆電'`、且 `specs` 裡的 `ram_gb` 大於等於 `16` 的設備，依記憶體由大到小排序（相同則依設備編號排序）。
- **驗收條件**：在升級 `NB-003` 之前應查出 **5 台**，第一台是 `Dell XPS 15`（32GB）。
- **✍️ 在 DBeaver 動手作提示**：`specs->>'ram_gb'` 取出來是文字，必須加上 `::INT` 才能做 `>= 16` 比較與排序！

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（5 筆）</summary>

```sql
SELECT
    device_id,
    name,
    department,
    (specs->>'ram_gb')::INT AS ram_gb,
    specs->>'cpu'           AS cpu
FROM devices
WHERE device_type = '筆電'
  AND (specs->>'ram_gb')::INT >= 16
ORDER BY (specs->>'ram_gb')::INT DESC, device_id;
```

| device_id | name | department | ram_gb | cpu |
|---|---|---|---|---|
| `NB-008` | Dell XPS 15 | 資訊技術部 | 32 | i7-13700H |
| `NB-002` | MacBook Pro 14 | 資訊技術部 | 18 | M3 |
| `NB-001` | ThinkPad X1 Carbon | 資訊技術部 | 16 | i7-1365U |
| `NB-004` | ASUS ExpertBook B5 | 業務發展部 | 16 | i5-1340P |
| `NB-005` | Dell Latitude 5440 | 行銷企劃部 | 16 | i5-1335U |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢（SELECT）找出類型為「筆電」且 JSONB specs 欄位中 ram_gb >= 16 的設備（顯示 device_id, name, department, ram_gb, cpu），依記憶體由大到小排序，回傳結果表格與 SQL。
  ```

---

### 題目 2（S2）：查看所有投影機的亮度和解析度

- **業務問題**：總務借用投影機時想一次比較亮度，請列出所有 `'投影機'` 的編號、品名、使用部門、亮度（`lumens` 轉整數）與解析度（`resolution`），亮度由高到低排序。
- **驗收條件**：應列出 **4 台**，`Epson EB-L200F`（4500 流明）排第一。
- **✍️ 在 DBeaver 動手作提示**：記得一樣要將 `(specs->>'lumens')::INT` 轉成數字排序，避免文字排序出錯。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT
    device_id,
    name,
    department,
    (specs->>'lumens')::INT AS lumens,
    specs->>'resolution'    AS resolution
FROM devices
WHERE device_type = '投影機'
ORDER BY (specs->>'lumens')::INT DESC;
```

| device_id | name | department | lumens | resolution |
|---|---|---|---|---|
| `PJ-004` | Epson EB-L200F | 資訊技術部 | 4500 | 1920x1080 |
| `PJ-002` | BenQ MH560 | 管理行政部 | 3800 | 1920x1080 |
| `PJ-003` | ViewSonic PA503X | 行銷企劃部 | 3600 | 1024x768 |
| `PJ-001` | Epson CO-FH02 | 業務發展部 | 3000 | 1920x1080 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢列出所有投影機的編號、品名、部門、lumens 與 resolution，依亮度（數字）由高到低排序，並附上實際執行的 SQL。
  ```

---

### 題目 3（S3）：找出支援雙面列印的印表機（JSONB 布林篩選）

- **業務問題**：行政想找支援雙面列印（`specs` 裡的 `duplex` 為 `true`）的印表機，列出編號、品名、部門、列印速度 `ppm` 與紙張大小 `paper`。
- **驗收條件**：應回傳 **3 台**（不含只支援單面的 `Canon LBP6030`）。
- **✍️ 在 DBeaver 動手作提示**：`(specs->>'duplex')::BOOLEAN = true`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（3 筆）</summary>

```sql
SELECT
    device_id,
    name,
    department,
    (specs->>'ppm')::INT AS ppm,
    specs->>'paper'      AS paper
FROM devices
WHERE device_type = '印表機'
  AND (specs->>'duplex')::BOOLEAN = true
ORDER BY device_id;
```

| device_id | name | department | ppm | paper |
|---|---|---|---|---|
| `PR-001` | HP LaserJet M404dn | 管理行政部 | 38 | A4 |
| `PR-002` | Brother HL-L2375DW | 業務發展部 | 34 | A4 |
| `PR-004` | Epson WF-7310 | 資訊技術部 | 18 | A3 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢列出所有支援雙面列印（specs->>'duplex' 為 true）的印表機（含編號、品名、部門、ppm、paper），依 device_id 排序並顯示 SQL。
  ```

---

### 題目 4（S4）：用 `jsonb_set` ＋ Transaction 升級記憶體（不動到其他規格）

- **業務問題**：`NB-003`（ThinkPad E14）要從 8GB 記憶體升級到 **`16GB`**。請用 `BEGIN; ... COMMIT;` 交易寫法搭配 `jsonb_set` 只修改 `{ram_gb}` 成數字 `16`，不能蓋掉原本的 `cpu` 和 `screen_inch`。完成後重查 S1 確認高規格筆電數量變成 **6 台**。
- **驗收條件**：`NB-003` 的 `specs` 變成 `{"cpu": "i5-1235U", "ram_gb": 16, "screen_inch": 14}`（注意 `16` 不能變成字串 `"16"`）；S1 變成 **6 台**。
- **✍️ 在 DBeaver 動手作提示**：`jsonb_set(specs, '{ram_gb}', '16')`（若寫 `'"16"'` 會變成文字，之後 `::INT` 雖仍可轉，但規格型別會不乾淨，所以數字應傳 `'16'`）。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
BEGIN;

UPDATE devices
SET specs = jsonb_set(specs, '{ram_gb}', '16')
WHERE device_id = 'NB-003'
RETURNING device_id, specs;
-- 應看到：NB-003 | {"cpu": "i5-1235U", "ram_gb": 16, "screen_inch": 14}

COMMIT;

-- 再重測 16GB 以上筆電數量（應為 6）
SELECT COUNT(*) AS 高規格筆電數
FROM devices
WHERE device_type = '筆電' AND (specs->>'ram_gb')::INT >= 16;
```

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢（嚴禁使用 modify 或任何修改工具）：
  我剛才在 DBeaver 把 NB-003 升級到 16GB，請幫我驗證：
  1. NB-003 目前的 specs JSON 內容是什麼？cpu 和 screen_inch 是否完整保留，且 ram_gb 確實是數字 16？
  2. 目前類型為「筆電」且 ram_gb >= 16 的設備是否已經從 5 台變成 6 台？
  ```

---

### 題目 5（S5）：免改資料表直接新增「平板」類型設備

- **業務問題**：公司新購入一台平板：`TB-001`、`iPad Air`、類型 `'平板'`、購入日 `'2024-04-02'`、單價 `19900`、部門 `'業務發展部'`，規格只有 `{"os": "iPadOS", "storage_gb": 256}`。請直接寫入並觀察**完全不需要修改資料表欄位**，總設備變成 **17 台**。
- **驗收條件**：寫入成功，`SELECT COUNT(*) FROM devices;` 為 **`17`**。
- **✍️ 在 DBeaver 動手作提示**：在 `INSERT INTO devices` 裡直接給入 JSON 字串 `'{"os": "iPadOS", "storage_gb": 256}'`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期結果</summary>

```sql
INSERT INTO devices
    (device_id, name, device_type, purchase_date, price, department, specs)
VALUES
    ('TB-001', 'iPad Air', '平板', '2024-04-02', 19900, '業務發展部',
     '{"os": "iPadOS", "storage_gb": 256}')
RETURNING device_id, device_type, specs;

SELECT COUNT(*) AS 設備總數 FROM devices; -- 應為 17
```

| device_id | device_type | specs |
|---|---|---|
| `TB-001` | 平板 | `{"os": "iPadOS", "storage_gb": 256}` |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢（嚴禁寫入或修改資料）：
  我剛才在 DBeaver 新增了一筆 TB-001（iPad Air），請幫我驗證：
  1. devices 總設備數是否已經變成 17 台？
  2. TB-001 的 device_type 與 specs 內容為何？是否和既有筆電/投影機和平共處而不互相干擾？
  ```

---

## Part B｜進階 JSONB DML 練功題（E1～E5）

> 以下 E1～E5 皆以**做完 S1～S5 後（17 台設備、總價 485,900 元）**為基準！

### 題目 6（E1）：找出 CPU 是 Apple M 系列的設備（JSONB 字串 `LIKE`）

- **業務問題**：找出 `specs` 中 `cpu` 以 `'M'` 開頭（Apple M 系列晶片）的所有設備，顯示編號、品名、CPU 與記憶體大小。
- **驗收條件**：應查出 **2 筆**：`NB-002`（M3, 18GB）與 `NB-007`（M2, 8GB）。
- **✍️ 在 DBeaver 動手作提示**：`WHERE specs->>'cpu' LIKE 'M%'`（即使投影機、平板沒有 `cpu` 鍵，`->>` 只會回傳 `NULL`，不會出錯！）。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT
    device_id,
    name,
    specs->>'cpu'            AS cpu,
    (specs->>'ram_gb')::INT  AS ram_gb
FROM devices
WHERE specs->>'cpu' LIKE 'M%'
ORDER BY device_id;
```

| device_id | name | cpu | ram_gb |
|---|---|---|---|
| `NB-002` | MacBook Pro 14 | M3 | 18 |
| `NB-007` | MacBook Air 13 | M2 | 8 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢找出 specs->>'cpu' 以 'M' 開頭的所有設備，顯示 device_id、品名、CPU、ram_gb，依編號排序並附上 SQL。
  ```

---

### 題目 7（E2）：用 `jsonb_exists` 檢查哪幾筆設備含有 `lumens` 鍵值

- **業務問題**：假設忘記誰是投影機，或想找出所有在 JSONB `specs` 裡有紀錄 `'lumens'` 這個鍵的設備，請使用相容於 DBeaver 的 `jsonb_exists(specs, 'lumens')` 寫法查出來（註：不用 `?` 運算子，避免被 DBeaver 當作參數佔位符）。
- **驗收條件**：應回傳 **4 筆**投影機。
- **✍️ 在 DBeaver 動手作提示**：`WHERE jsonb_exists(specs, 'lumens') ORDER BY device_id`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT device_id, device_type, name, specs
FROM devices
WHERE jsonb_exists(specs, 'lumens')
ORDER BY device_id;
```

| device_id | device_type | name | specs |
|---|---|---|---|
| `PJ-001` | 投影機 | Epson CO-FH02 | `{"lumens": 3000, "resolution": "1920x1080"}` |
| `PJ-002` | 投影機 | BenQ MH560 | `{"lumens": 3800, "resolution": "1920x1080"}` |
| `PJ-003` | 投影機 | ViewSonic PA503X | `{"lumens": 3600, "resolution": "1024x768"}` |
| `PJ-004` | 投影機 | Epson EB-L200F | `{"lumens": 4500, "resolution": "1920x1080"}` |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢利用 jsonb_exists(specs, 'lumens') 找出所有 specs 包含 lumens 鍵的設備，回傳表格與執行的 SQL。
  ```

---

### 題目 8（E3）：找出每分鐘列印 `30 頁` 以上的印表機

- **業務問題**：總務要大量印會議資料，請從 `specs` 中找出列印速度 `(specs->>'ppm')::INT >= 30` 的印表機。
- **驗收條件**：應回傳 **2 筆**：`PR-001`（38 頁）與 `PR-002`（34 頁）。
- **✍️ 在 DBeaver 動手作提示**：對未包含 `ppm` 的設備（筆電／投影機／平板），`specs->>'ppm'` 是 `NULL`，`NULL::INT >= 30` 不會報錯而只會過濾掉。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（2 筆）</summary>

```sql
SELECT
    device_id,
    name,
    (specs->>'ppm')::INT AS ppm,
    specs->>'duplex'     AS duplex
FROM devices
WHERE (specs->>'ppm')::INT >= 30
ORDER BY device_id;
```

| device_id | name | ppm | duplex |
|---|---|---|---|
| `PR-001` | HP LaserJet M404dn | 38 | true |
| `PR-002` | Brother HL-L2375DW | 34 | true |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢找出列印速度 ppm >= 30 的設備，顯示 device_id、name、ppm 與 duplex，並附上 SQL。
  ```

---

### 題目 9（E4）：統計各類型設備台數與採購總金額（`GROUP BY device_type`）

- **業務問題**：主管想做年度設備資產盤點總表（包含 S5 剛買的平板！），想知道每種設備類型（`device_type`）目前各有幾台、總共花了多少採購金額，依總金額由高到低排列。
- **驗收條件**：共 **4 類**：`筆電` 8 台（`333,800`）、`投影機` 4 台（`99,600`）、`印表機` 4 台（`32,600`）、`平板` 1 台（`19,900`）。
- **✍️ 在 DBeaver 動手作提示**：`GROUP BY device_type` 搭配 `COUNT(*)`、`SUM(price)`。

<details>
<summary>👀 寫完再打開：參考 SQL 與預期執行結果（4 筆）</summary>

```sql
SELECT
    device_type AS 類型,
    COUNT(*)    AS 台數,
    SUM(price)  AS 採購總金額
FROM devices
GROUP BY device_type
ORDER BY 採購總金額 DESC;
```

| 類型 | 台數 | 採購總金額 |
|---|---|---|
| 筆電 | 8 | 333800 |
| 投影機 | 4 | 99600 |
| 印表機 | 4 | 32600 |
| 平板 | 1 | 19900 |

</details>

- **🤖 用 Microsoft Postgres MCP 查詢比較（Prompt）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢依 device_type 分組統計「台數」與「採購總金額（SUM(price)）」，依總金額由高到低排序，回傳結果表格與 SQL。
  ```

---

### 題目 10（E5）：進階交易沙盒 — 批次替投影機補上保固鍵值 ＋ 模擬退役舊筆電再 `ROLLBACK`

- **業務問題**：試寫一筆安全沙盒交易：
  1. 在 `BEGIN;` 裡面，使用 `jsonb_set(specs, '{warranty_years}', '3')` 替**所有投影機**在 JSONB 中補上 `"warranty_years": 3`（預設 `create_if_missing` 為 `true`，所以就算原本沒有這個鍵也能直接補上去！）。
  2. 同時模擬刪除準備報廢的 `NB-006`（HP ProBook 440，單價 26,900）。
  3. 觀察沙盒中的 4 台投影機新 JSONB 以及設備總台數／總金額變化，最後執行 **`ROLLBACK;`** 恢復原狀！
- **驗收條件**：沙盒內總台數變 **`16`**、總金額變 **`459,000`**（`485,900 - 26,900`），且投影機出現 `"warranty_years": 3`；執行 `ROLLBACK;` 後恢復 **`17` 台 / `485,900`**，且 `PJ-001` 的 `warranty_years` 消失。
- **✍️ 在 DBeaver 動手作提示**：`BEGIN;` → `UPDATE ... jsonb_set(...) WHERE device_type = '投影機';` → `DELETE ... WHERE device_id = 'NB-006';` → `SELECT` 觀察 → `ROLLBACK;` → 再驗證！

<details>
<summary>👀 寫完再打開：參考 SQL 與沙盒前後對照結果</summary>

```sql
BEGIN;

-- 1. 替所有投影機補上保固年限（不存在的 key 會自動新增）
UPDATE devices
SET specs = jsonb_set(specs, '{warranty_years}', '3')
WHERE device_type = '投影機';

-- 2. 模擬移除報廢筆電 NB-006
DELETE FROM devices WHERE device_id = 'NB-006';

-- 3. 查看沙盒內投影機規格與模擬總金額
SELECT device_id, specs FROM devices WHERE device_type = '投影機' ORDER BY device_id;
SELECT COUNT(*) AS 沙盒模擬總台數, SUM(price) AS 沙盒模擬總金額 FROM devices; -- 16 | 459000

-- 4. 回滾復原
ROLLBACK;

-- 5. 確認恢復原狀
SELECT COUNT(*) AS 復原後總台數, SUM(price) AS 復原後總金額 FROM devices; -- 17 | 485900
SELECT device_id, specs FROM devices WHERE device_id = 'PJ-001';
```

| 狀態 | `PJ-001` 規格內容 | 設備總台數 | 總金額 |
|---|---|---|---|
| 沙盒交易中 | `{"lumens": 3000, "resolution": "1920x1080", "warranty_years": 3}` | 16 | 459000 |
| `ROLLBACK;` 後 | `{"lumens": 3000, "resolution": "1920x1080"}` | **17** | **485900** |

</details>

- **🤖 用 Microsoft Postgres MCP 唯讀驗證（Prompt，嚴禁 MCP 代寫）**：
  ```text
  請透過 Microsoft Postgres MCP 連線到我的 devices 資料庫，只用唯讀查詢（嚴禁執行任何寫入或 modify 工具）：
  我剛才用 BEGIN ... ROLLBACK 模擬替投影機加上 JSONB 鍵 warranty_years 並刪除 NB-006，然後已經 ROLLBACK。請幫我查證：
  1. 目前設備總數是否仍是 17 台、總金額仍是 485,900？
  2. NB-006 是否還安好地存在資料庫中？
  3. PJ-001 的 specs 是否確定沒有殘留 warranty_years 鍵值？
  ```

---

## 🤖 問 AI 助教（複習 JSONB 語法重點）

```text
我剛完成 devices 資料庫的 10 題 JSONB DML 實戰並用 Microsoft Postgres MCP 交叉比對完成。
請幫我把 -> 與 ->>、::INT 與 ::BOOLEAN、jsonb_exists 與 jsonb_set 的用法差異，用一份給職場非工程師的極簡口訣表整理給我。
```

---

👉 **所有故事與進階練習都親手跑完並驗證過了！接著前往 [步驟 5｜MCP 讀結構產生 PRD](prompts/01_MCP讀結構產生PRD.md)！**
