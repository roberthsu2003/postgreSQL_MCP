# SDD 實戰步驟 1：請 AI 依據需求產生人資考勤與計薪 Tkinter App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **Python 桌面視窗整合**。  
**請勿讓 AI 透過 MCP 在背後自動生成或代勞資料庫操作**，所有 SQL 必須由 AI 產生在程式碼或對話中，由學生親自看懂並在 DBeaver 執行。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過人資排班考勤與薪資試算 Tkinter 系統的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `hr_attendance.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python Tkinter 桌面視窗版」的開發計畫：

【架構規範要求】：
1. 嚴禁使用 MCP 直接代勞資料庫操作。所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：出勤多表 JOIN 查詢、CASE WHEN 遲到與加班統計、時薪加乘試算）。
2. 前端介面使用 Python 內建的 `Tkinter` (搭配 `ttk.Treeview`, `ttk.Combobox`, `ttk.LabelFrame`)，打造不用架設伺服器、在本機電腦即開即用的人資考勤工具。
3. 程式碼分層清晰：資料庫手寫 SQL 模組 (`queries.py`) 與 Tkinter 視窗介面 (`app.py`)。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的部門員工名單、每日出勤明細查詢、累計加班費與實發薪資試算函式。
- **Task 2: Tkinter 視窗介面 (app.py)**：建立主視窗、月份切換工具列、出勤表格、薪資結算試算卡片與一鍵匯出按鈕。
- **Task 3: 本機測試與驗證**：驗證遲到判定與加班費計算是否符合邏輯規則。

請為我生成 `plan.md`！
```

