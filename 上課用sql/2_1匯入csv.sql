/* 2_1 匯入 CSV 範例 SQL */

-- 1. 建立「目前天氣」資料表（對應 目前天氣.csv）
CREATE TABLE IF NOT EXISTS 目前天氣(
    城市 VARCHAR(10),
    啟始時間 TIMESTAMPTZ,
    結束時間 TIMESTAMPTZ,
    最高溫度 REAL,
    最低溫度 REAL,
    感覺 VARCHAR,
    PRIMARY KEY(城市)
);

-- 查詢目前天氣資料
-- SELECT * FROM 目前天氣;


-- 2. 建立「台鐵車站」關聯資料表（對應 台鐵車站資訊.csv 與 進出站人數 CSV）
-- 注意：有 Foreign Key 關聯時，刪除要先刪除 Child（進出站），再刪除 Parent（車站）
DROP TABLE IF EXISTS station_in_out;
DROP TABLE IF EXISTS stations;

-- 車站資訊表 (Parent Table)
CREATE TABLE IF NOT EXISTS stations(
    stationCode VARCHAR(5) PRIMARY KEY,
    stationName VARCHAR(20) NOT NULL,
    stationAddrTw VARCHAR(50),
    stationTel VARCHAR(20),
    gps VARCHAR(30),
    haveBike BOOLEAN
);

-- 車站每日進出站人數表 (Child Table)
CREATE TABLE IF NOT EXISTS station_in_out(
    date DATE,
    staCode VARCHAR(5),
    gateInComingCnt INTEGER,
    gateOutGoingCnt INTEGER,
    PRIMARY KEY(date, staCode),
    FOREIGN KEY(staCode) REFERENCES stations(stationCode) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- 查詢測試
-- SELECT * FROM stations LIMIT 10;
-- SELECT * FROM station_in_out LIMIT 10;
