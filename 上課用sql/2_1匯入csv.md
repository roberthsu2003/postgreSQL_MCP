# PostgreSQL 匯入 CSV 檔案教學

## 1. 匯入城市資料 - 使用 SQLite 建立的 city.sql

### 步驟說明
1. 將 `city.csv` 透過 DB Browser for SQLite 匯入
2. 透過 DB Browser for SQLite 匯出 `city.sql`
3. [下載 city.sql 檔案](../範例資料庫/其它範例csv/city.sql)
4. 使用 DBeaver 開啟 city.sql（**File → Open File**），選擇資料庫後按 `Alt + X` 執行

## 2. 匯入目前天氣資料

### 資料來源
- [下載目前天氣.csv](../範例資料庫/其它範例csv/目前天氣.csv)

### 建立資料表
```sql
/* 建立目前天氣資料表 */
CREATE TABLE IF NOT EXISTS 目前天氣(
    城市 VARCHAR(10),
    啟始時間 TIMESTAMPTZ,  /* 資料含時間與時區,例如 2023-07-22T12:00:00+08:00 */
    結束時間 TIMESTAMPTZ,
    最高溫度 REAL,
    最低溫度 REAL,
    感覺 VARCHAR,
    PRIMARY KEY(城市)
);
```

### 匯入步驟

使用 DBeaver 匯入 `目前天氣.csv` 至資料表 `目前天氣`：

1. 左側選取資料庫按 `F5` 重新整理，找到 `目前天氣` 資料表
2. 在 `目前天氣` 上按右鍵 → **Import Data**
3. 選擇 **CSV** → **Next**，選擇 `目前天氣.csv`
4. **Importer settings**：確認 **Header** 是 `top`（第一列是欄位名稱）、**Column delimiter** 是 `,`
5. **Tables mapping**：CSV 的欄位名稱和資料表相同，會自動對應（mapping 顯示 `existing`）
6. 按 **Proceed** 開始匯入，完成後在資料表按兩下 → **Data** 分頁確認有 22 筆

## 3. 匯入台鐵車站資訊和車站進出資料

### 資料來源
- [台鐵車站資訊.csv](../範例資料庫/其它範例csv/台鐵車站資訊.csv)
- [2019-2023進出資訊](../範例資料庫/其它範例csv/每日各站進出站人數20190423-20231231.zip)

### 建立關聯式資料表

> 💡 欄位名稱沒有加雙引號時，PostgreSQL 會自動轉成小寫，例如 `stationCode` 實際上是 `stationcode`。

#### 先刪除舊的資料表（如果需要重新建立）

```sql
-- 有 foreign key 時,要先刪除 child table,再刪除 parent table
DROP TABLE IF EXISTS station_in_out;
DROP TABLE IF EXISTS stations;
```

#### 車站資料表
```sql
CREATE TABLE IF NOT EXISTS stations(
    id SERIAL PRIMARY KEY,
    stationCode VARCHAR(5) UNIQUE NOT NULL,  /* 必須設定，因為是 foreign key 的 parent */
    stationName VARCHAR(20) NOT NULL,
    name VARCHAR(20),
    stationAddrTw VARCHAR(50),
    stationTel VARCHAR(20),
    gps VARCHAR(30),
    haveBike BOOLEAN   /* CSV 中的 Y/N 會自動轉成 true/false */
);

-- 查詢資料
SELECT * FROM stations;
```

> 匯入 `台鐵車站資訊.csv` 時，CSV 沒有 `id` 欄位，DBeaver 會依照欄位名稱對應，`id` 由 SERIAL 自動產生，不需要另外設定。

#### 車站進出資料表
```sql
CREATE TABLE IF NOT EXISTS station_in_out(
    date TIMESTAMP,
    staCode VARCHAR(5) NOT NULL,
    gateInComingCnt INTEGER,
    gateOutGoingCnt INTEGER,
    PRIMARY KEY (date, staCode),
    FOREIGN KEY (staCode)  /* 可設可不設，有設可以保持資料的完整性 */
        REFERENCES stations(stationCode)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

> 進出站 CSV 的欄位名稱（`trnOpDate`、`staCode`、`gateInComingCnt`、`gateOutGoingCnt`）和資料表的欄位名稱不同。DBeaver 匯入時，在 **Tables mapping** 頁面按 **Columns...**，把每個 CSV 欄位對應到資料表的欄位（`trnOpDate` → `date`，其餘依序對應）。一定要**先匯入 stations**，否則會違反 foreign key。

### 查詢範例

#### JOIN 查詢
```sql
SELECT * 
FROM station_in_out in_out 
JOIN stations s ON in_out.staCode = s.stationCode;
```

#### 時間查詢語法
```sql
-- 查詢特定日期
SELECT * FROM table_name WHERE date_column = 'YYYY-MM-DD';

-- 查詢時間範圍
SELECT * FROM table_name 
WHERE timestamp_column BETWEEN 'start_timestamp' AND 'end_timestamp';

-- 查詢最近7天
SELECT * FROM table_name 
WHERE timestamp_column >= NOW() - INTERVAL '7 days';

-- 查詢未來7天
SELECT * FROM tasks 
WHERE task_due_date BETWEEN NOW() AND NOW() + INTERVAL '7 days';
```

#### 布林值查詢
```sql
SELECT * FROM table_name WHERE boolean_column = TRUE;
```

## 4. 匯入繁體中文範例資料庫

網路商店、學校選課、圖書館借閱三個練習用資料庫，各只有一個 `.sql` 檔，在 DBeaver 開啟後按 `Alt + X` 執行即可匯入。

👉 [繁體中文範例資料庫](../範例資料庫/中文範例資料庫/)


---

## 🤖 不寫 SQL，用 Prompt 完成

> 在 Claude Desktop 使用[第 3 章](../MCP操作資料庫/2_用中文查詢資料庫/#6-準備第-4-章設定可寫入的連線)設定的 **`postgres-sql`**（可寫入，連到 `sql_tutorial` 資料庫）。
> 每個 prompt 執行後，點開工具呼叫（`execute_sql`），**對照 AI 執行的 SQL 和上面學的是否一樣**。

### 1. 執行 city.sql

在 Claude Desktop 的對話框**附加 [city.sql](../範例資料庫/其它範例csv/city.sql) 檔案**，然後說：

> 請用 postgres-sql 執行這個 SQL 檔的內容，然後告訴我 city 資料表有幾筆資料。

✅ 答案：274 筆。

> ⚠️ **再執行一次會變成 548 筆**。city.sql 用的是 `CREATE TABLE IF NOT EXISTS`，資料表已經存在時不會重建，但 INSERT 會再新增一次。問 AI「為什麼變成 548 筆？要怎麼避免？」

### 2. 匯入目前天氣.csv

> 用 postgres-sql 建立「目前天氣」資料表：城市 VARCHAR(10) 是主鍵，啟始時間、結束時間是 TIMESTAMPTZ，最高溫度、最低溫度是 REAL，感覺是 VARCHAR。

接著**附加 [目前天氣.csv](../範例資料庫/其它範例csv/目前天氣.csv)**：

> 把這個 CSV 的資料全部新增到「目前天氣」資料表，完成後告訴我新增了幾筆。

✅ 答案：22 筆。檢查 AI 產生的 INSERT 筆數和 CSV 是否相同。

> 💡 Postgres MCP Pro 不能讀取你電腦上的檔案，所以要把檔案**附加到對話中**，由 AI 讀取後產生 INSERT。

### 3. 台鐵資料：大量資料還是要用 DBeaver 匯入

台鐵進出站資料有數十萬筆，不適合貼給 AI。**資料表可以請 AI 建立，資料用 DBeaver 的 Import Data 匯入**：

> 用 postgres-sql 建立兩張資料表：
> - stations：id 是 SERIAL 主鍵，stationCode VARCHAR(5) 不可重複且必填，stationName VARCHAR(20) 必填，name VARCHAR(20)，stationAddrTw VARCHAR(50)，stationTel VARCHAR(20)，gps VARCHAR(30)，haveBike BOOLEAN
> - station_in_out：date TIMESTAMP，staCode VARCHAR(5) 必填，gateInComingCnt INTEGER，gateOutGoingCnt INTEGER，(date, staCode) 是主鍵，staCode 參考 stations 的 stationCode，刪除和更新時都 CASCADE

✅ 對照上面的 `CREATE TABLE stations`、`CREATE TABLE station_in_out`。注意 AI 有沒有先建立 stations（parent），再建立 station_in_out（child）。

用 DBeaver 匯入資料後，再用 prompt 查詢：

> 查詢 2022 年 1 月 1 日每個車站的進站人數，顯示車站名稱，由多到少排序。

> 有提供 YouBike 的車站有幾個？
