## 練習建立資料表與匯入 CSV

本練習引導你建立資料表結構，並將 CSV 資料匯入 PostgreSQL。

> 💡 用 DBeaver 匯入：在資料表上按右鍵 → **Import Data** → **CSV**（詳細步驟見[匯入 CSV](../../SQL語法教學/2_1匯入csv.md)）。

---

### 練習 1：建立「目前天氣」資料表並匯入

- **使用檔案**：[目前天氣.csv](../../範例資料庫/其它範例csv/目前天氣.csv)
- **筆數**：22 筆（台灣 22 縣市）
- **欄位需求**：
  - `城市`：主鍵，VARCHAR(10)
  - `啟始時間`：TIMESTAMPTZ（含時區）
  - `結束時間`：TIMESTAMPTZ（含時區）
  - `最高溫度`：REAL
  - `最低溫度`：REAL
  - `感覺`：VARCHAR(20)

```sql
CREATE TABLE IF NOT EXISTS 目前天氣(
    城市 VARCHAR(10) PRIMARY KEY,
    啟始時間 TIMESTAMPTZ,
    結束時間 TIMESTAMPTZ,
    最高溫度 REAL,
    最低溫度 REAL,
    感覺 VARCHAR(20)
);
```

#### 匯入後查詢確認：

```sql
SELECT * FROM 目前天氣; -- 22 筆
```

---

### 練習 2：建立「門市銷售」大表並匯入

- **使用檔案**：[門市銷售明細_2024Q1_全部.csv](../../範例資料庫/excel範例/連鎖門市月報表/門市銷售明細_2024Q1_全部.csv)
- **筆數**：782 筆
- **說明**：練習包含日期、時間、金額、中文欄位的平坦化大表匯入

```sql
CREATE TABLE IF NOT EXISTS 門市銷售明細_2024Q1(
    銷售單號 VARCHAR(20),
    銷售日期 DATE,
    時間 TIME,
    門市名稱 VARCHAR(30),
    區域 VARCHAR(10),
    經手店員 VARCHAR(20),
    會員姓名 VARCHAR(20),
    會員電話 VARCHAR(20),
    商品分類 VARCHAR(20),
    商品名稱 VARCHAR(50),
    單價 INT,
    數量 INT,
    小計 INT,
    付款方式 VARCHAR(20),
    狀態 VARCHAR(10)
);
```

#### 匯入後查詢確認：

```sql
SELECT * FROM 門市銷售明細_2024Q1; -- 782 筆
```
