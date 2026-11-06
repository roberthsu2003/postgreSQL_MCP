# 產品需求文件 (PRD)：圖書借閱與逾期罰金個人桌面小 App

* **專案代號**：`Library-Desktop-Circulation`
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase ([`library.sql`](../../範例資料庫/中文範例資料庫/library.sql) 結構)
* **前端框架**：Python 內建 **Tkinter** (個人桌面視窗 GUI) 或 **PyQt5**
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 專案背景與痛點

小型圖書館館員、社區管理員或企業書庫負責人，過去用 Excel 登記借還書時最常頭痛：
1. **逾期天數與罰款手動算錯**：每次還書都要手動算今天離應還日差幾天。
2. **缺乏即時在庫搜尋視窗**：無法一鍵輸入關鍵字看出哪些書在庫、哪些書借出中。

本專案旨在將已正規化儲存於 PostgreSQL 中的 `library.sql`，開發為一個**在個人電腦上獨立運作的桌面小 App（Desktop GUI）**，支援館藏模糊查詢、逾期罰金自動計算與熱門借閱排行！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 library.sql 建立)

包含 5 張標準關聯表：
1. **`publishers`**：出版社 (publisher_id, name, phone, address)
2. **`authors`**：作者名錄 (author_id, name, country)
3. **`books`**：圖書主檔 (book_id, title, author_id, publisher_id, publish_year, category, total_copies)
4. **`members`**：借閱會員 (member_id, name, member_type, phone)
5. **`borrow_records`**：借還記錄 (record_id, member_id, book_id, borrow_date, due_date, return_date, status)

---

## 3. 前端介面與功能需求 (Tkinter 桌面視窗)

使用 Python 內建 **Tkinter** 設計：

### 3.1 館藏圖書即時搜尋 (`ttk.Treeview`)
- **關鍵字搜尋框 (`Entry`)**：輸入書名或作者，手寫 SQL `LIKE %s` 即時過濾。
- **在庫/借出狀態標籤**：
  - 🟢 在館可借（館藏數 > 借出中數量）
  - 🔴 全部借出中

### 3.2 讀者借閱紀錄與逾期罰款計算機
- 輸入會員證號，手寫 SQL 列出目前尚未歸還的書籍名單。
- **動態罰金結算**：
  - 手寫 SQL：`CASE WHEN CURRENT_DATE > due_date THEN (CURRENT_DATE - due_date) * 5 ELSE 0 END`
  - 介面動態即時顯示逾期天數與應繳罰款金額。
- **「還書登記」按鈕**：點擊更新 `return_date = CURRENT_DATE` 與狀態為「已歸還」。

### 3.3 年度閱讀排行榜 (RANK)
- 手寫 SQL 使用 PostgreSQL 視窗函式 `RANK() OVER (ORDER BY COUNT(*) DESC)` 列出借閱次數 TOP 10 書籍。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 資料表由學生在 DBeaver 親自執行 `library.sql` 建立完畢。
- [ ] 執行 `python app.py` 立即於個人電腦彈出桌面視窗。
- [ ] 逾期天數、罰金與排行全數以手寫 SQL 在 `psycopg2` 中完成。
