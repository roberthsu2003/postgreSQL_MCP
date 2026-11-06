# 專案 5：圖書館數位借閱與逾期罰金管理系統 (Library Circulation System)

本專案對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/library.sql`](../../範例資料庫/中文範例資料庫/library.sql)**

---

## 🚀 專案目標

將圖書館借閱資料庫（出版社、作者、書籍、讀者、借閱紀錄），開發為包含**「館藏即時在庫/借出狀態」**、**「逾期罰金自動動態計算」**與**「年度熱門書籍排行榜 (RANK)」**的現代化 Web 應用。

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `library.sql`**：
   在 Supabase SQL Editor 或 DBeaver 中執行 [`library.sql`](../../範例資料庫/中文範例資料庫/library.sql)。
2. **複製環境設定**：
   ```bash
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL / Supabase 連線資訊
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

