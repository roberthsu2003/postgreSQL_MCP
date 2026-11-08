-- ==============================================================
-- 建立 AI 專用的唯讀帳號
-- 執行位置：DBeaver，工具列先切換到 supplies 資料庫
-- 執行前：把下面的密碼改成你自己的
-- 這個帳號只能看資料，不能新增、修改或刪除
-- ==============================================================

CREATE ROLE ai_readonly LOGIN PASSWORD '請改成你自己的密碼';

GRANT CONNECT ON DATABASE supplies TO ai_readonly;
GRANT USAGE ON SCHEMA public TO ai_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ai_readonly;
