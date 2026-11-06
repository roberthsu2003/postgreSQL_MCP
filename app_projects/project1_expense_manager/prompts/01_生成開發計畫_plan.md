# SDD 實戰步驟 1：請 AI 依據需求產生會計費用審核 PyQt5 App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **PyQt5 現代桌面視窗整合**。  
**請勿讓 AI 透過 MCP 在背後自動生成或代勞資料庫操作**，所有 SQL 必須由 AI 產生在程式碼或對話中，由學生親自看懂並在 DBeaver 執行。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過會計費用審核與預算預警 PyQt5 系統的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `expense_tracker.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python PyQt5 桌面視窗版」的開發計畫：

【架構規範要求】：
1. 嚴禁使用 MCP 直接代勞資料庫操作。所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：待審核金額聚合加總、依部門與狀態篩選單據、更新審核狀態 UPDATE）。
2. 前端介面使用現代化的 `PyQt5`（包含 `QMainWindow`、頂部 KPI 指標卡片、`QTableWidget` 單據清單、審批動作按鈕群與 QSS 樣式美化），打造適合會計與出納日常使用的本機桌面小 App。
3. 程式碼分層清晰：資料庫手寫 SQL 模組 (`queries.py`) 與 PyQt5 視窗介面 (`app.py`)。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的部門清單、待審金額統計、單據過濾查詢與審核狀態更新函式。
- **Task 2: PyQt5 視窗介面 (app.py)**：建立主視窗、KPI 面板、單據表格與批准/駁回/撥款按鈕互動槽。
- **Task 3: 本機測試與驗證**：驗證點選按鈕時狀態更新與金額即時刷新是否流暢準確。

請為我生成 `plan.md`！
```

