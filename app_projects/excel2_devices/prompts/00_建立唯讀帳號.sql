-- ==============================================================
-- 讓 AI 專用的唯讀帳號可以讀取設備資料
-- 執行位置：DBeaver，工具列先切換到 devices 資料庫
-- 帳號 ai_readonly 在專案 1 已經建立，這裡只補上這個資料庫的權限
-- 如果你沒有做專案 1，請先到 excel1_supplies/prompts/00_建立唯讀帳號.sql 建立帳號
-- ==============================================================

GRANT CONNECT ON DATABASE devices TO ai_readonly;
GRANT USAGE ON SCHEMA public TO ai_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ai_readonly;
