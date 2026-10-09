## Foreign Key實際案例-火車站點進出人數

建立資料表的 SQL：[train_stations.sql](./train_stations.sql)

```sql
/*請參考火車站點.csv和火車進出人數資料*/
/*先刪除 child table(gate_count),再刪除 parent table(stations)*/
DROP TABLE IF EXISTS gate_count;
DROP TABLE IF EXISTS stations;

CREATE TABLE IF NOT EXISTS stations(
	編號 INT PRIMARY KEY, /*0900*/
	名稱 VARCHAR(20) NOT NULL,
	英文名稱 VARCHAR(50),
	地名 VARCHAR(20),
	英文地名 VARCHAR(50),
	地址 VARCHAR(255),
	英文地址 VARCHAR(255),
	電話 VARCHAR(20),
	gps VARCHAR(50),
	youbike BOOL
);

CREATE TABLE IF NOT EXISTS gate_count(
	id INT GENERATED ALWAYS AS IDENTITY,
	日期 DATE NOT NULL,
	站點編號 INT,
	進站人數 INT DEFAULT 0,
	出站人數 INT DEFAULT 0,
	PRIMARY KEY(id),
	FOREIGN KEY(站點編號) REFERENCES stations(編號)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

SELECT COUNT(*) AS 筆數
FROM gate_count;
```

### 資料

| 檔案 | 匯入到 | 說明 |
|---|---|---|
| [火車站點.csv](./火車站點.csv) | `stations` | 10 個欄位依序對應 |
| [火車站進出人口數_2020_2021_2022](./火車站進出人口數_2020_2021_2022/) 內的 4 個 CSV | `gate_count` | 匯入時 **Columns** 取消勾選 `id`（id 由資料庫自動產生） |

> 一定要**先匯入 stations**，再匯入 gate_count，否則會違反 foreign key。



