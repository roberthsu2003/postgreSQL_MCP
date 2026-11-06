-- =====================================================================
-- 專案 1：股票資料庫建置腳本 (init_stock_db.sql)
-- 配合 SDD (Spec-Driven Development) 開發模式
--
-- 執行方式:
--   Supabase: 開啟 SQL Editor → 貼上全部內容 → 點選 Run 執行
--   DBeaver : 開啟檔案 (Alt+X) 執行全部
-- =====================================================================

SET client_encoding = 'UTF8';
SET search_path TO public;
BEGIN;

-- 1. 清理舊資料表
DROP TABLE IF EXISTS stock_prices CASCADE;
DROP TABLE IF EXISTS stocks CASCADE;
DROP TABLE IF EXISTS markets CASCADE;

-- 2. 市場類別表
CREATE TABLE markets (
    market_id   VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(30) NOT NULL,
    currency    VARCHAR(5) NOT NULL
);

-- 3. 個股資訊表
CREATE TABLE stocks (
    symbol      VARCHAR(20) PRIMARY KEY,
    market_id   VARCHAR(10) NOT NULL REFERENCES markets(market_id),
    name        VARCHAR(50) NOT NULL,
    sector      VARCHAR(30)
);

-- 4. 每日股價歷史表 (主鍵為 symbol + date，方便使用 ON CONFLICT 進行增量更新)
CREATE TABLE stock_prices (
    symbol      VARCHAR(20) NOT NULL REFERENCES stocks(symbol) ON DELETE CASCADE,
    date        DATE NOT NULL,
    open        NUMERIC(12, 2),
    high        NUMERIC(12, 2),
    low         NUMERIC(12, 2),
    close       NUMERIC(12, 2),
    adj_close   NUMERIC(12, 2),
    volume      BIGINT,
    PRIMARY KEY (symbol, date)
);

-- 建立索引加速依日期與個股範圍查詢
CREATE INDEX idx_stock_prices_date ON stock_prices(date);
CREATE INDEX idx_stock_prices_symbol_date ON stock_prices(symbol, date DESC);

COMMENT ON TABLE markets      IS '交易市場 (台股、美股等)';
COMMENT ON TABLE stocks       IS '追蹤股票清單';
COMMENT ON TABLE stock_prices IS '每日價格歷史紀錄 (開高低收與成交量)';

-- 5. 插入基礎種子資料 (預設追蹤標的)
INSERT INTO markets (market_id, name, currency) VALUES
('TW', '台灣證券交易所', 'TWD'),
('US', '美國美股市場', 'USD');

INSERT INTO stocks (symbol, market_id, name, sector) VALUES
('^TWII',    'TW', '台灣加權指數', '市場大盤'),
('2330.TW',  'TW', '台積電',       '半導體業'),
('2454.TW',  'TW', '聯發科',       '半導體業'),
('2317.TW',  'TW', '鴻海',         '電子代工'),
('AAPL',     'US', '蘋果 (Apple)', '科技軟硬體'),
('NVDA',     'US', '輝達 (NVIDIA)','半導體AI晶片');

COMMIT;

-- 驗證建立結果
SELECT s.symbol AS 代號, s.name AS 名稱, m.name AS 市場, m.currency AS 幣別
FROM stocks s
JOIN markets m ON s.market_id = m.market_id;

