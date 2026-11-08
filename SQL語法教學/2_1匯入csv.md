# DDL-4｜匯入 CSV：不用一筆一筆打字

> 💻 DBeaver（資料庫：`cafe_db`）｜ 🎯 學完你會：把 CSV 匯入資料表，並確認筆數正確

## 🎬 情境

王經理：「全台灣今天的天氣資料和第一季銷售明細，我都匯出成 CSV 了，放進資料庫吧。」

幾百筆資料不可能手打。流程只有三步：**先建表 → 再匯入 → 一定要驗筆數**。

```mermaid
flowchart LR
    A["1. 看 CSV 的欄位"] --> B["2. CREATE TABLE<br>欄位要對得上"] --> C["3. DBeaver<br>Import Data"] --> D["4. COUNT(*)<br>驗筆數"]
```

## 第一關：22 筆天氣資料

📁 下載練習檔：[`目前天氣.csv`](../範例資料庫/其它範例csv/目前天氣.csv)

### 步驟 1：看檔案內容

```text
城市,啟始時間,結束時間,最高溫度,最低溫度,感覺
臺北市,2023-07-22T12:00:00+08:00,2023-07-22T18:00:00+08:00,35.0,32.0,悶熱
```

### 步驟 2：建立對應的資料表

```sql
CREATE TABLE 目前天氣 (
    城市     VARCHAR(10) PRIMARY KEY,
    啟始時間 TIMESTAMPTZ,
    結束時間 TIMESTAMPTZ,
    最高溫度 REAL,
    最低溫度 REAL,
    感覺     VARCHAR(20)
);
```

> [!NOTE]
> PostgreSQL 允許中文欄位名稱，匯入 CSV 時很方便。但正式系統建議用英文（打字不用切輸入法），本課程其他資料表都用英文。

### 步驟 3：用 DBeaver 匯入

1. 左側選資料庫按 `F5`，在 `Tables` 下找到 `目前天氣`
2. 在 `目前天氣` 上按右鍵 → **Import Data**
3. 選 **CSV** → **Next** → 選取 `目前天氣.csv`
4. 匯入設定：**Encoding** 選 `UTF-8`、**Column delimiter** 是 `,`、**Header** 選 `top`（第一列是標題）
5. 確認欄位對應，每一欄的狀態是 `existing`
6. 按 **Proceed** 開始匯入

### 步驟 4：驗證

```sql
SELECT COUNT(*) AS 筆數 FROM 目前天氣;
```

**執行結果**

| 筆數 |
|---:|
| 22 |

看到 22 就對了。再查查哪裡最熱：

```sql
SELECT 城市, 最高溫度, 感覺
FROM 目前天氣
ORDER BY 最高溫度 DESC
LIMIT 3;
```

**執行結果**

| 城市 | 最高溫度 | 感覺 |
|---|---:|---|
| 臺北市 | 35.0 | 悶熱 |
| 桃園市 | 35.0 | 悶熱至易中暑 |
| 臺中市 | 35.0 | 悶熱 |

## 第二關：782 筆門市銷售明細

📁 練習檔：[`門市銷售明細_2024Q1_全部.csv`](../範例資料庫/excel範例/連鎖門市月報表/門市銷售明細_2024Q1_全部.csv)

```sql
CREATE TABLE 門市銷售明細_2024Q1 (
    銷售單號 VARCHAR(20),
    銷售日期 DATE,
    時間     TIME,
    門市名稱 VARCHAR(30),
    區域     VARCHAR(10),
    經手店員 VARCHAR(20),
    會員姓名 VARCHAR(20),
    會員電話 VARCHAR(20),
    商品分類 VARCHAR(20),
    商品名稱 VARCHAR(50),
    單價     INT,
    數量     INT,
    小計     INT,
    付款方式 VARCHAR(20),
    狀態     VARCHAR(20)
);
```

> [!NOTE]
> 還記得 DDL-1 的潛規則嗎？沒加雙引號的名字會轉小寫，所以這張表在 DBeaver 裡會顯示成 `門市銷售明細_2024q1`。查詢時大小寫都能用，不必擔心。

匯入方式和第一關相同，然後驗證：

```sql
SELECT COUNT(*) AS 筆數, SUM(小計) AS 總金額
FROM 門市銷售明細_2024Q1;
```

**執行結果**

| 筆數 | 總金額 |
|---:|---:|
| 782 | 97655 |

> [!TIP]
> **驗證的好習慣**：除了筆數，也加總一個金額欄，和 Excel 底部的合計比一比。兩邊一樣，才算真的匯入成功。

## ⚠️ 常見卡關

| 問題 | 原因 | 怎麼解 |
|---|---|---|
| 中文變亂碼 | 編碼不對。Excel 另存的 CSV 常是 Big5 | Encoding 改選 `Big5`，或在 Excel 另存為「CSV UTF-8」 |
| 第一個欄位對不上 | 檔案開頭有隱形的 BOM 字元 | 在 Tables mapping 手動對應第一欄，或 Encoding 選 `UTF-8 BOM` |
| `invalid input syntax for type integer` | 數字欄混入文字、逗號或空白 | 回 Excel 清掉，或先用 `VARCHAR` 匯入再整理 |
| `duplicate key value violates unique constraint` | 重複匯入了 | `TRUNCATE TABLE 表名;` 清空後重匯一次 |
| 筆數少了 | 檔案最後有空白列或有錯誤列被略過 | 看 DBeaver 匯入紀錄，和 Excel 列數比對 |

## ✍️ 動手練

**第 1 題**：查出最低溫度低於 25 度的城市。

<details>
<summary>看答案</summary>

```sql
SELECT 城市, 最低溫度
FROM 目前天氣
WHERE 最低溫度 < 25
ORDER BY 最低溫度;
```

**執行結果**

（查無資料，0 筆）

</details>

**第 2 題**：`門市銷售明細_2024Q1` 裡有哪些不重複的門市名稱？

<details>
<summary>看答案</summary>

```sql
SELECT DISTINCT 門市名稱 FROM 門市銷售明細_2024Q1;
```

應該有 5 家門市。

</details>

## 🤖 問 AI 助教

> 我附上一份 CSV（已去除真實姓名和電話）。請依內容建議 CREATE TABLE，告訴我每一欄為什麼用這個型別，並提醒匯入時可能遇到的問題。請給我 SQL，由我自己在 DBeaver 匯入。

> [!CAUTION]
> 公司資料丟給 AI 前，一定先**去識別化**：真實姓名、電話、身分證都要換掉，而且只留 10～20 筆當樣本。

## ✅ 過關檢查

- [ ] `目前天氣` 有 22 筆、`門市銷售明細_2024Q1` 有 782 筆
- [ ] 我記得匯入後要驗筆數和金額
- [ ] 遇到中文亂碼時，我知道要看編碼

> 🎯 **想要一次匯入完整的範例資料庫？** 請看 [第 2 章：繁體中文範例資料庫](../範例資料庫/中文範例資料庫/README.md)。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ DDL-3 建立資料表](./2建立資料表.md) | [🏠 第 4 章目錄](./README.md) | [DDL-5 限制條件 ➡️](./4限制.md) |
