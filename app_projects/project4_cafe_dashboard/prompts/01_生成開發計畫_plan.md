# SDD 實戰步驟 1：請 AI 依據需求產生門市營運 PyQt5 App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **PyQt5 現代桌面視窗整合**。  
**請勿讓 AI 透過 MCP 在背後自動生成或代勞資料庫操作**，所有 SQL 必須由 AI 產生在程式碼或對話中，由學生親自看懂並在 DBeaver 執行。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過連鎖門市營運分析 PyQt5 商業桌面 App 的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `cafe_shop.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python PyQt5 桌面視窗版」的開發計畫：

【架構規範要求】：
1. 嚴禁使用 MCP 直接代勞資料庫操作。所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：多表 JOIN、GROUP BY 跨月份統計、HAVING VIP 篩選）。
2. 前端介面使用現代化的 `PyQt5`（包含 `QMainWindow`、`QTabWidget` 多分頁、`QTableWidget` 數據表、以及 `QSS` 樣式美化），打造具備商業質感、在本機電腦即開即用的視窗管理系統。
3. 程式碼分層清晰：資料庫手寫 SQL 模組 (`queries.py`) 與 PyQt5 視窗介面 (`app.py`)。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的門市清單、月營收統計、熱銷排行與 VIP 查詢函式。
- **Task 2: PyQt5 視窗介面 (app.py)**：建立主視窗、頂部動態篩選工具列、KPI 指標卡與 QTabWidget 三大分頁表格。
- **Task 3: 本機測試與驗證**：驗證切換分店與月份時數據即時刷新與準確度。

請為我生成 `plan.md`！
```

