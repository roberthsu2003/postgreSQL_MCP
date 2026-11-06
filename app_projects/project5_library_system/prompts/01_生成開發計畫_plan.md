# SDD 實戰步驟 1：請 AI 透過 MCP 檢查 library.sql 並產生 plan.md

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在 Antigravity 對話框中發送：

```markdown
我已經準備好了圖書館借閱與罰金系統的規格文件 `PRD.md`，資料庫也已經執行過 `library.sql`。

請按照「規格驅動開發 (SDD)」流程為我規劃開發計畫：

1. 請先使用 PostgreSQL MCP 工具（例如 list_tables、describe_table），實體檢查目前資料庫中 `publishers`、`authors`、`books`、`members`、`borrow_records` 的真實欄位結構與關聯鍵。
2. 仔細研讀 `PRD.md` 中關於「館藏查詢、逾期天數與罰金計算、熱門借閱榜單 (RANK)」的功能要求。
3. 根據真實資料表結構，在當前目錄下生成一份清晰的 `plan.md` 開發計畫。

請拆解為 3~4 個階段任務（Task）：
- **Task 1: 資料庫查詢層 (queries.py)**：編寫取得書籍流通狀態、讀者未還清單、逾期天數與罰金動態結算 (CURRENT_DATE - due_date)、年度熱門借閱排行 (RANK) 的 SQL 函式。
- **Task 2: 前端視覺化看板 (app.py)**：使用 Streamlit 整合書目搜尋、讀者罰款計算機與排行榜圖表。
- **Task 3: 效能優化與測試**：加入 `@st.cache_data` 快取、驗證日期計算邏輯。

請立即開始透過 MCP 檢查資料表，並為我建立 `plan.md`！
```

