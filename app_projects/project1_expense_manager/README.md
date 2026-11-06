# 專案 1：企業費用報銷審核與預算預警 PyQt5 系統

本專案適用職務：**會計 (Accounting)、出納 (Cashier)、財務主管**  
對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/expense_tracker.sql`](../../範例資料庫/中文範例資料庫/expense_tracker.sql)**  
對應職場 Excel：👉 **[`員工差旅與費用報銷單.xlsx`](../../範例資料庫/excel範例/自備Excel轉SQL實戰示範/員工差旅與費用報銷單.xlsx)**

---

## 🚀 專案目標

將公司最常見的混亂 Excel 請款單，轉化為自己個人電腦上隨點隨開的 **PyQt5 現代化會計出納管理系統**，具備部門切換、待審單據即時統計與一鍵審批功能！

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `expense_tracker.sql`**：
   在 DBeaver 中開啟並執行 [`expense_tracker.sql`](../../範例資料庫/中文範例資料庫/expense_tracker.sql)。
2. **安裝環境依賴**：
   ```bash
   pip install -r requirements.txt
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL 本機連線設定
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

