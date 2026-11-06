# 專案 2：員工排班考勤與薪資試算 Tkinter 系統

本專案適用職務：**人資 (HR)、考勤管理員、計薪出納、門市督導**  
對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/hr_attendance.sql`](../../範例資料庫/中文範例資料庫/hr_attendance.sql)**

---

## 🚀 專案目標

使用 Python 內建的 **Tkinter**，打造一套不用安裝任何網頁伺服器、雙擊即開的人資桌面管理工具，實現出勤記錄查詢、遲到加班標記與月底薪資一鍵結算！

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `hr_attendance.sql`**：
   在 DBeaver 中開啟並執行 [`hr_attendance.sql`](../../範例資料庫/中文範例資料庫/hr_attendance.sql)。
2. **安裝環境依賴**：
   ```bash
   pip install -r requirements.txt
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL 本機連線設定
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

