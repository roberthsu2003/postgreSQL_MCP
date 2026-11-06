# 專案 4：校園智慧選課與學分審查系統 (School Course Enrollment)

本專案對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/school.sql`](../../範例資料庫/中文範例資料庫/school.sql)**

---

## 🚀 專案目標

將學校選課資料庫（學系、教師、學生、課程、選課紀錄），開發為包含**「即時選課防衝堂檢核」**、**「個人週課表視圖」**與**「畢業學分進度審查條」**的現代化智慧校園 Web 應用。

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `school.sql`**：
   在 Supabase SQL Editor 或 DBeaver 中執行 [`school.sql`](../../範例資料庫/中文範例資料庫/school.sql)。
2. **複製環境設定**：
   ```bash
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL / Supabase 連線資訊
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

