# SDD 實戰步驟 1：請 AI 透過 MCP 檢查 school.sql 並產生 plan.md

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在 Antigravity 對話框中發送：

```markdown
我已經準備好了校園智慧選課與學分審查系統的規格文件 `PRD.md`，資料庫也已經執行過 `school.sql`。

請按照「規格驅動開發 (SDD)」流程為我規劃開發計畫：

1. 請先使用 PostgreSQL MCP 工具（例如 list_tables、describe_table），實體檢查目前資料庫中 `departments`、`teachers`、`students`、`courses`、`enrollments` 的真實欄位結構與關聯鍵。
2. 仔細研讀 `PRD.md` 中關於「學生課表排程、名額狀態、衝堂防呆、畢業學分審查」的功能要求。
3. 根據真實資料表結構，在當前目錄下生成一份清晰的 `plan.md` 開發計畫。

請拆解為 3~4 個階段任務（Task）：
- **Task 1: 資料庫查詢層 (queries.py)**：編寫取得課程名單與剩餘名額、學生修課課表、已修學分計算 (CASE WHEN / SUM) 的 SQL 函式。
- **Task 2: 前端視覺化看板 (app.py)**：使用 Streamlit 整合學生身份切換、週課表視覺化呈現與學分進度條。
- **Task 3: 效能優化與測試**：加入 `@st.cache_data` 快取、驗證衝堂比對邏輯。

請立即開始透過 MCP 檢查資料表，並為我建立 `plan.md`！
```

