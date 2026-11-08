# 步驟 2｜手寫 DDL：一張表，一個規格欄位

> 💻 DBeaver（資料庫：`devices`）｜ 🎯 學完你會：建立有 JSONB 欄位的資料表，並看懂 JSON 格式錯誤

> 📚 先修：[DML-6 JSONB](../../SQL語法教學/16json.md)。

## 1. 建立資料庫和資料表

```sql
CREATE DATABASE devices;
```

切換到 `devices`，建立資料表：

```sql
CREATE TABLE devices (
    device_id     VARCHAR(10) PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    device_type   VARCHAR(10) NOT NULL,
    purchase_date DATE        NOT NULL,
    price         INT         NOT NULL CHECK (price >= 0),
    department    VARCHAR(20) NOT NULL,
    specs         JSONB       NOT NULL
);
```

`device_type` 沒有限制只能填哪幾種，因為之後可能買新類型的設備。

> [!IMPORTANT]
> 表名和欄位名稱請和上面**完全相同**，否則下一步匯入會失敗。

## 2. 測試保護機制

先放進一筆正確的資料：

```sql
INSERT INTO devices VALUES ('NB-001', 'ThinkPad X1 Carbon', '筆電', '2023-03-15', 48500, '資訊技術部', '{"cpu": "i7-1365U", "ram_gb": 16, "screen_inch": 14}');
```

打開「有問題的資料」工作表，**先猜會被哪個規則擋下**，再一句一句執行：

```sql
-- 第 1 列：編號重複
INSERT INTO devices VALUES ('NB-001', '重複的筆電', '筆電', '2024-04-01', 30000, '資訊技術部', '{"ram_gb": 8}');

-- 第 2 列：規格完全空白
INSERT INTO devices VALUES ('NB-101', '規格沒填的筆電', '筆電', '2024-04-01', 30000, '資訊技術部', NULL);

-- 第 3 列：單價是負數
INSERT INTO devices VALUES ('NB-102', '單價錯誤的筆電', '筆電', '2024-04-01', -100, '資訊技術部', '{"ram_gb": 8}');

-- 第 4 列：沒有這一天
INSERT INTO devices VALUES ('NB-103', '日期錯誤的筆電', '筆電', '2024-02-30', 30000, '資訊技術部', '{"ram_gb": 8}');

-- 第 5 列：JSON 裡用了單引號
INSERT INTO devices VALUES ('NB-104', '規格格式錯誤', '筆電', '2024-04-01', 30000, '資訊技術部', '{''ram_gb'': 8}');
```

**執行結果：五句全部被擋下**

| 列 | 錯誤訊息 | 擋下它的是 |
|:---:|---|---|
| 1 | `duplicate key ... "devices_pkey"` | 主鍵 |
| 2 | `null value in column "specs"` | `NOT NULL` |
| 3 | `violates check constraint "devices_price_check"` | `CHECK` |
| 4 | `date/time field value out of range` | 型別 `DATE` |
| 5 | `invalid input syntax for type json` | 型別 `JSONB` |

`JSONB` 欄位會自動檢查格式，寫錯的 JSON 根本進不來。

## 3. 清空測試資料

```sql
TRUNCATE devices;
```

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `invalid input syntax for type json` | JSON 裡用了單引號，或多了逗號 | JSON 內部用雙引號，外層用單引號 |
| `relation "devices" does not exist` | 連錯資料庫 | 檢查工具列是不是 `devices` |
| `current transaction is aborted` | 交易中發生過錯誤 | 先執行 `ROLLBACK;` |

## ✍️ 動手練

**為什麼 `specs` 要設 `NOT NULL`，裡面的內容卻可以每台不同？**

<details>
<summary>看答案</summary>

`NOT NULL` 只確保每台設備都有填規格。至於裡面放哪些項目，資料庫不會限制，這正是 JSONB 的彈性。

</details>

## 🤖 問 AI 助教

> 這是我手寫的 PostgreSQL 資料表：（貼上）。請檢查哪些規則能擋下錯誤資料，還有什麼風險。有問題的話給我提示，不要直接重寫。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 1：哪些欄位放 JSONB](./1_哪些欄位放JSONB.md) | [🏠 專案說明](./README.md) | [步驟 3：AI 產生資料交易檔 ➡️](./3_AI產生資料交易檔.md) |
