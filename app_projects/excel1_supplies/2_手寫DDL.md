# 步驟 2｜手寫 DDL：親手蓋出資料表

> 💻 DBeaver（資料庫：`supplies`）｜ 🎯 學完你會：建立資料庫和資料表，並用限制條件擋下錯誤資料

> 📚 先修：[DDL 章節](../../SQL語法教學/DDL%28定義資料語言%29.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

上一步的欄位規格已經訂好，現在要把它變成真正的資料表。**DDL** 就是用來蓋結構的語法，這一步請全部親手打，不要請 AI 代勞。

## 1. 建立資料庫

```sql
CREATE DATABASE supplies;
```

建好後，在 DBeaver 工具列把資料庫切換成 `supplies`。如果左側沒看到，按 `F5` 重新整理。

## 2. 建立資料表

```sql
CREATE TABLE supplies (
    item_code     VARCHAR(20) PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    spec          VARCHAR(50),
    category      VARCHAR(10) NOT NULL CHECK (category IN ('紙張', '碳粉墨水', '文具', '清潔用品')),
    unit          VARCHAR(5)  NOT NULL,
    unit_price    INT         NOT NULL CHECK (unit_price >= 0),
    current_stock INT         NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    safety_stock  INT         NOT NULL DEFAULT 0 CHECK (safety_stock >= 0),
    location      VARCHAR(30) NOT NULL,
    last_checked  DATE
);
```

| 寫法 | 白話 | Excel 裡類似的功能 |
|---|---|---|
| `PRIMARY KEY` | 主鍵：必填，而且不能重複 | 資料驗證的「不允許重複」 |
| `NOT NULL` | 必填 | 資料驗證的「不可空白」 |
| `CHECK (...)` | 自訂規則 | 資料驗證的「自訂公式」 |
| `CHECK (... IN (...))` | 只能從清單中選 | 下拉清單 |
| `DEFAULT 0` | 沒填時自動填 0 | 無 |

> [!IMPORTANT]
> 欄位名稱請和上面**完全相同**。下一步匯入資料時，名稱不同就會失敗。

## 3. 查看結構

```sql
SELECT column_name AS 欄位, data_type AS 型別, is_nullable AS 可留空
FROM information_schema.columns
WHERE table_name = 'supplies'
ORDER BY ordinal_position;
```

**執行結果**

| 欄位 | 型別 | 可留空 |
|---|---|---|
| item_code | character varying | NO |
| name | character varying | NO |
| spec | character varying | YES |
| category | character varying | NO |
| unit | character varying | NO |
| unit_price | integer | NO |
| current_stock | integer | NO |
| safety_stock | integer | NO |
| location | character varying | NO |
| last_checked | date | YES |

## 4. 測試你請的警衛

先放進一筆正確的資料（`INSERT` 的細節步驟 4 會教，這裡直接貼上）：

```sql
INSERT INTO supplies VALUES ('MAT-P-A470', 'A4 70g 影印紙', 'Double A 5包/箱', '紙張', '箱', 650, 3, 5, '3F 總務庫房 B-01', '2024-03-29');
```

接著打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：品號重複
INSERT INTO supplies VALUES ('MAT-P-A470', 'A4 70g 影印紙（重複）', 'Double A 5包/箱', '紙張', '箱', 650, 1, 5, '3F 總務庫房 B-01', '2024-04-01');

-- 第 2 列：品名空白
INSERT INTO supplies VALUES ('STA-GLUE-01', NULL, '40g', '文具', '支', 30, 10, 5, '3F 總務庫房 D-02', '2024-04-01');

-- 第 3 列：庫存是負數
INSERT INTO supplies VALUES ('STA-RULE-30', '30cm 直尺', NULL, '文具', '支', 20, -3, 5, '3F 總務庫房 D-02', '2024-04-01');

-- 第 4 列：單價是負數
INSERT INTO supplies VALUES ('STA-ERAS-01', '橡皮擦', NULL, '文具', '個', -8, 10, 5, '3F 總務庫房 D-02', '2024-04-01');

-- 第 5 列：類別不在清單中
INSERT INTO supplies VALUES ('OTH-FAN-01', '桌上型電扇', NULL, '雜項', '台', 590, 2, 1, '3F 總務庫房 D-02', '2024-04-01');

-- 第 6 列：單價不是數字
INSERT INTO supplies VALUES ('STA-CUT-01', '美工刀', NULL, '文具', '支', '約30', 12, 5, '3F 總務庫房 D-02', '2024-04-01');

-- 第 7 列：沒有這一天
INSERT INTO supplies VALUES ('STA-INK-01', '印泥', NULL, '文具', '個', 45, 6, 2, '3F 總務庫房 D-02', '2024/13/45');
```

**執行結果：七句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key value violates unique constraint "supplies_pkey"` | `PRIMARY KEY` |
| 2 | `null value in column "name" ... violates not-null constraint` | `NOT NULL` |
| 3 | `violates check constraint "supplies_current_stock_check"` | `CHECK` |
| 4 | `violates check constraint "supplies_unit_price_check"` | `CHECK` |
| 5 | `violates check constraint "supplies_category_check"` | `CHECK` |
| 6 | `invalid input syntax for type integer: "約30"` | 型別 `INT` |
| 7 | `date/time field value out of range: "2024/13/45"` | 型別 `DATE` |

現在表裡應該只有最初那一筆：

```sql
SELECT COUNT(*) FROM supplies;
```

**執行結果**：`1`

## 5. 清空測試資料

正式匯入前，要把測試資料清掉，否則下一步會因為品號重複而失敗。

```sql
TRUNCATE supplies;
```

`TRUNCATE` 會清空所有資料，但保留資料表結構。

> [!WARNING]
> `TRUNCATE` 沒有資源回收桶，也沒有 `Ctrl + Z`。只在確定要清空時使用。

## 6. 事後修改：ALTER TABLE

建好之後想多記一欄，不用重建：

```sql
ALTER TABLE supplies ADD COLUMN supplier VARCHAR(30);
```

後來決定不記了：

```sql
ALTER TABLE supplies DROP COLUMN supplier;
```

下一步需要原本的結構，所以請確定 `supplier` 已經刪掉。

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `relation "supplies" already exists` | 這張表已經建過 | 要重來就先 `DROP TABLE supplies;` |
| `relation "supplies" does not exist` | 連到錯的資料庫 | 檢查工具列是不是 `supplies` |
| `syntax error at or near ")"` | 最後一個欄位後面多了逗號 | 刪掉 `)` 前面的逗號 |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**第 1 題**：`spec` 想放更長的文字，要怎麼把長度放寬到 100？

<details>
<summary>看答案</summary>

```sql
ALTER TABLE supplies ALTER COLUMN spec TYPE VARCHAR(100);
ALTER TABLE supplies ALTER COLUMN spec TYPE VARCHAR(50);  -- 改回來，下一步要用
```

</details>

**第 2 題**：不看講義，說出「有問題的資料」七列分別被什麼擋下。

<details>
<summary>看答案</summary>

重複品號是主鍵，品名空白是 `NOT NULL`，負庫存、負單價和類別錯誤是 `CHECK`，單價文字和錯誤日期是欄位型別。

</details>

## 🤖 問 AI 助教

> 這是我手寫的 PostgreSQL CREATE TABLE：（貼上你的 SQL）。請告訴我它和下列需求有沒有不符合的地方，但不要直接重寫：單價和庫存不能是負數、品號不能重複、類別只能有四種。我會自己在 DBeaver 修改。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：讀懂 Excel 與故事](./1_讀懂Excel與故事.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
