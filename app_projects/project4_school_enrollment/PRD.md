# 產品需求文件 (PRD)：校園智慧選課與學分審查個人桌面小 App

* **專案代號**：`School-Desktop-Enrollment`
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase ([`school.sql`](../../範例資料庫/中文範例資料庫/school.sql) 結構)
* **前端框架**：Python 內建 **Tkinter** (個人桌面視窗 GUI) 或 **PyQt5**
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 專案背景與痛點

學生在選課時最常遇到的困擾：
1. **衝堂問題無法即時檢查**：手動對照 Excel 時間表容易看漏重疊時段。
2. **畢業學分算不清楚**：不知道自己已修畢的學分中，必修、選修與通識各達成了多少百分比。

本專案旨在將已正規化儲存於 PostgreSQL 中的 `school.sql`，開發為一個**在個人電腦上獨立運作的桌面小 App（Desktop GUI）**，提供即時課表呈現、選課衝堂防呆與學分進度統計！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 school.sql 建立)

包含 5 張標準關聯表：
1. **`departments`**：學系資料 (dept_id, name, office)
2. **`teachers`**：授課教師 (teacher_id, name, title, dept_id)
3. **`students`**：學生資料 (student_id, name, dept_id, year, phone)
4. **`courses`**：課程清單 (course_id, name, credits, teacher_id, dept_id, weekday, start_time, end_time, capacity)
5. **`enrollments`**：選課紀錄 (enrollment_id, student_id, course_id, semester, score, status)

---

## 3. 前端介面與功能需求 (Tkinter 桌面視窗)

使用 Python 內建 **Tkinter** 設計：

### 3.1 學生身份切換與個人課表
- **學生切換下拉選單 (`ttk.Combobox`)**：切換不同學號，手寫 SQL 即時載入該學生的修課資料。
- **個人每週課表網格視圖**：以表格或日曆方塊直觀呈現週一至週五已選課程。

### 3.2 課程清單與防衝堂檢查
- **全校課程清單 (`ttk.Treeview`)**：顯示課程代碼、名稱、學分、上課時間、名額剩餘。
- **點擊加選與衝堂檢核**：
  - 手寫 SQL 檢查該課程的上課時段是否與該學生「已選課程」衝突。
  - 若衝突，Tkinter 彈出 `messagebox.showerror` 提示衝突課程名稱並阻止加選。

### 3.3 畢業學分達成率進度
- 手寫 SQL 統計該學生已及格（score >= 60）之總學分。
- 顯示必修達成率、選修達成率標籤。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 資料表由學生在 DBeaver 親自執行 `school.sql` 建立完畢。
- [ ] 執行 `python app.py` 立即於個人電腦彈出桌面視窗。
- [ ] 衝堂防呆與學分計算全數以手寫 SQL 在 `psycopg2` 中完成。
