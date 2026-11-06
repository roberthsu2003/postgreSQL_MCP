# 專案 3：電商訂單履約與客戶 CRM 系統 (Shop OMS & CRM)

本專案對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql)**

---

## 🚀 專案目標

將電商網路商店的關聯資料庫（包含分類、商品、會員、訂單、明細），開發成具備**「訂單流水線履約」**與**「客戶 RFM 價值分群 CRM」**的現代化 Web 應用程式。

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `shop.sql`**：
   在 Supabase SQL Editor 或 DBeaver 中執行 [`shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql)。
2. **複製環境設定**：
   ```bash
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL / Supabase 連線資訊
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

