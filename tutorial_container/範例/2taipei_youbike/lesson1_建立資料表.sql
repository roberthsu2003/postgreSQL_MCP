/*有 foreign key 時,要先刪除 child table(youbike),再刪除 parent table(站點資訊)*/
DROP TABLE IF EXISTS youbike;
DROP TABLE IF EXISTS 站點資訊;

CREATE TABLE IF NOT EXISTS 站點資訊(
	站點編號 VARCHAR(10),
	站點名稱 VARCHAR(50) NOT NULL,  /*有些站名超過 30 個字*/
	行政區 VARCHAR(10) NOT NULL,
	站點地址 VARCHAR(100),
	lat NUMERIC(15,11),
	lng NUMERIC(15,11),
	PRIMARY KEY(站點編號)
);

CREATE TABLE IF NOT EXISTS youbike(
	日期 TIMESTAMP,
	編號 VARCHAR(10),
	總車輛 INTEGER,
	可借 INTEGER,
	可還 INTEGER,
	活動 BOOLEAN,
	PRIMARY KEY(日期,編號),
	FOREIGN KEY(編號) REFERENCES 站點資訊(站點編號) 
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
