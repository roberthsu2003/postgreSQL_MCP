# SDD 實戰步驟 1：請 AI 依據需求產生個人桌面版 Tkinter App 開發計畫

---

## ⚠️ 教學規範說明
本專案旨在讓學生扎實學習 **手寫 SQL 語法** 與 **Python 桌面視窗整合**。  
**請勿讓 AI 透過 MCP 在背後自動生成或代勞資料庫操作**，所有 SQL 必須由 AI 產生在程式碼或對話中，由學生親自看懂並在 DBeaver 執行。

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在對話框中發送：

```markdown
我已經研讀過電商訂單與客戶 CRM 個人桌面 App 的規格文件 `PRD.md`，並在 DBeaver 中手動執行過 `shop.sql`。

請按照「規格驅動開發 (SDD)」為我規劃一個「Python 桌面視窗版 (Tkinter)」的開發計畫：

【架構規範要求】：
1. 嚴禁使用 MCP 直接代勞資料庫操作。所有與 PostgreSQL 的互動，必須使用 `psycopg2` 並在 Python 中明確撰寫原生 SQL（例如：訂單狀態過濾、訂單明細 JOIN 展開、RFM 統計計算）。
2. 前端介面使用 Python 內建的 `Tkinter` (搭配 `ttk.Notebook` 雙分頁與 `ttk.Treeview` 表格)，打造無須架設網頁伺服器、點擊即可在本機執行的個人桌面小工具。
3. 程式碼分層清晰：資料庫手寫 SQL 查詢層與 Tkinter 視窗介面層。

請在當前目錄下生成一份清晰的 `plan.md` 開發計畫，拆解為以下任務：
- **Task 1: 資料庫手寫 SQL 查詢模組 (queries.py)**：編寫使用 psycopg2 手寫 SQL 的訂單主檔清單、明細 JOIN 查詢、客戶 RFM 指標計算函式。
- **Task 2: Tkinter 桌面介面 (app.py)**：建立視窗、雙分頁（訂單履約 / 客戶 CRM）、主從表格連動顯示。
- **Task 3: 本機測試與驗證**：驗證點選訂單時明細表格是否即時反應，以及 RFM 標籤判斷的正確性。

請為我生成 `plan.md`！
```
