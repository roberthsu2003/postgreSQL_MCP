# SDD 實戰步驟 1：請 AI 依據需求產生個人桌面版 Tkinter App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **Python 桌面視窗整合**。  
**請勿讓 AI 透過 MCP 在背後自動生成或代勞資料庫操作**，所有 SQL 必須由 AI 產生在程式碼或對話中，由學生親自看懂並在 DBeaver 執行。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過連鎖門市營運分析個人桌面 App 的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `cafe_shop.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python 桌面視窗版 (Tkinter)」的開發計畫：

【架構規範要求】：
1. 嚴禁使用 MCP 直接代勞資料庫操作。所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：多表 JOIN、GROUP BY 跨月份統計、HAVING VIP 篩選）。
2. 前端介面使用 Python 內建的 `Tkinter` (搭配 `ttk.Notebook` 分頁與 `ttk.Treeview` 表格)，打造無須架設網頁伺服器、點擊即可在本機執行的個人桌面小工具。
3. 程式碼架構清楚分離：資料庫手寫 SQL 查詢層與 Tkinter 介面層。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 查詢模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的門市清單、月營收統計、熱銷排行與 VIP 查詢函式。
- **Task 2: Tkinter 桌面介面 (app.py)**：建立視窗、側邊/頂部篩選器、KPI 面板與多分頁表格。
- **Task 3: 本機測試與效能驗證**：驗證門市與月份切換時查詢流暢度（0.1 秒極速反應），並確保手寫 SQL 採用參數化防範注入。

請為我生成 `plan.md`！
```
