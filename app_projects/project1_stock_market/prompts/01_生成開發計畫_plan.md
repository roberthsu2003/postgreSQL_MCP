# SDD 實戰步驟 1：請 AI 透過 MCP 檢查資料庫並產生 plan.md

在過去，初學者常常直接對 AI 說「幫我寫一個股票 App」，結果 AI 憑空捏造資料庫欄位名稱，程式碼一跑就噴錯。

在 **規格驅動開發 (SDD)** 模式下，我們讓 AI **「先看 PRD、再透過 MCP 看真實資料庫」**，產出一份縝密的 `plan.md` 開發計畫！

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在 Antigravity 對話框中發送：

```markdown
我已經準備好了專案規格文件 `PRD.md`，資料庫也已經執行過 `init_stock_db.sql`。

請按照「規格驅動開發 (SDD)」流程為我規劃開發計畫：

1. 請先使用 PostgreSQL MCP 工具（例如 list_tables、describe_table），實體檢查目前資料庫中 `markets`、`stocks`、`stock_prices` 三張資料表的真實欄位名稱與型別。
2. 仔細研讀 `PRD.md` 中關於「Cache-Aside 快取與 yfinance 增量同步 (Incremental Sync)」的邏輯要求。
3. 根據真實的資料庫 Schema 與需求，在當前目錄下生成一份詳細的 `plan.md`。

開發計畫 `plan.md` 請拆解為 4 個循序漸進的 Task：
- **Task 1: 資料庫連線模組 (db.py)**：負責 PostgreSQL 連線池與基礎查詢。
- **Task 2: 快取與增量同步引擎 (sync.py)**：實作「無資料抓全部、落後抓增量、最新走 DB」的核心邏輯。
- **Task 3: 前端介面與視覺化 (app.py)**：使用 Streamlit 建立側邊欄、KPI 指標卡與 Plotly K線/走勢圖。
- **Task 4: 整合測試與防呆驗證**：驗證初次同步、二次讀取快取速度、以及休市日例外處理。

請立即開始透過 MCP 檢查資料表，並為我建立 `plan.md`！
```

---

## 💡 AI 產生 `plan.md` 後的下一步

當 AI 產生 `plan.md` 後，請查看檔案中的任務清單，接著參考 [02_SDD逐步實作引導.md](./02_SDD逐步實作引導.md) 讓 AI 逐一落實每個 Task！

