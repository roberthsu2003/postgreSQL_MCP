# SDD 實戰步驟 1：請 AI 依據需求產生總務資產庫存 PyQt5 App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **PyQt5 現代桌面視窗整合**。  
所有 SQL 都要由學生親自看懂。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過總務資產借還與耗材庫存 PyQt5 系統的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `assets_inventory.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python PyQt5 桌面視窗版」的開發計畫：

【架構規範要求】：
1. 所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：設備借還狀態切換 UPDATE、逾期日期比對 `CURRENT_DATE > expected_return_date`、安全庫存水位判斷 `current_stock <= safety_stock`）。
2. 前端介面使用現代化的 `PyQt5`（包含 `QMainWindow`、`QTabWidget` 雙分頁、`QTableWidget` 數據表、以及醒目的逾期紅字標籤），打造適合總務與 IT 資產管理的本機桌面管理工具。
3. 程式碼分層清晰：資料庫手寫 SQL 模組 (`queries.py`) 與 PyQt5 視窗介面 (`app.py`)。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的資產分類清單、未還設備查詢、借出與還書登記、耗材低庫存預警函式。
- **Task 2: PyQt5 視窗介面 (app.py)**：建立主視窗、雙分頁（設備借還 / 耗材庫存）、快速登記面板、還書核銷按鈕與請購觸發。
- **Task 3: 本機測試與驗證**：驗證逾期天數判定邏輯與庫存狀態即時切換。

請為我生成 `plan.md`！
```

