# 用自然語言讓 AI 寫 Python 連線資料庫

> 💡 **這章不是要教你死背 Python 語法！**
> 在 AI 時代，你不需要手寫幾十行 `psycopg2` 程式碼，你只需要：
> 1. **看懂關鍵概念**：知道用 `.env` 保管帳密、用 `%s` 防資料庫被駭、用 `with` 自動確認交易。
> 2. **學會用 Prompt（自然語言）引導 AI**：把你的需求與先前的範例資料庫告訴 AI，讓 AI 幫你寫出正確、安全且能執行的 Python 專案！

---

## 🎯 必學核心：開箱即用的連線 Prompt

當你想用 Python 連線先前的 **`cafe_shop`（連鎖咖啡門市）** 或其他資料庫時，直接把這段 Prompt 複製給 AI：

```markdown
我使用的是 PostgreSQL（本機/Supabase），資料庫名稱為 `practice`，
裡面已經匯入過連鎖咖啡門市資料庫 `cafe_shop.sql`。

請幫我建立一個連線並查詢資料的 Python 程式 `query_stores.py`：
1. 使用 `python-dotenv` 從 `.env` 檔案中讀取連線資訊（DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD）。
2. 連線到資料庫，查詢 `stores` 資料表的所有門市資訊。
3. 採用 `with conn:` 和 `with conn.cursor():` 確保連線資源正確釋放。
4. 將查詢結果整理成清晰的表格印在終端機上。
5. 附帶說明需要的依賴套件（requirements.txt）。
```

---

## 🧭 單元導覽

| 單元 | 核心概念（一眼看懂） | 🤖 AI Prompt 重點 |
|---|---|---|
| 1. [安裝和環境](./安裝和介紹/) | 安裝 `psycopg2-binary`，建立 `.env` 保管密碼 | 叫 AI 產生環境變數範本與測試連線腳本 |
| 2. [基本語法與查詢](./basic_module_usage/) | Connect ➔ Cursor ➔ Execute ➔ Fetch ➔ Close | 叫 AI 查詢 `cafe_shop` 門市與商品清單 |
| 3. [使用 with 語法](./with/) | 自動 `commit()`、出錯自動 `rollback()`、自動關閉游標 | 叫 AI 使用 `with` 語法確保交易完整性 |
| 4. [安全參數傳遞](./parameter/) | 嚴禁字串拼接！務必使用 `%s` 參數化查詢防駭 | 叫 AI 寫防 SQL Injection 的查詢函式 |
| 5. [型別對照表](./type/) | PostgreSQL 的日期、數字進到 Python 變什麼？ | 讓 AI 正確處理日期與 Decimal 格式化 |
| 6. [例外處理](./exception/) | 遇到查無資料、外來鍵衝突時如何優雅抓錯 | 叫 AI 加上 `try...except psycopg2.Error` 防呆 |

