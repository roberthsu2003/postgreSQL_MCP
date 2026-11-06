# 專案 5：業務客戶 CRM 與訂單履約 Tkinter 系統

本專案適用職務：**業務專員 (Sales)、業務助理 (Sales Assistant)、電商營運人員**  
對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql)**  
對應職場 Excel：👉 **[`未正規化_網路商店單一工作表.xlsx`](../../範例資料庫/excel範例/未正規化_網路商店單一工作表.xlsx)**

---

## 🚀 專案目標

使用 Python 內建的 **Tkinter**，打造一套雙擊即開的業務客戶 CRM 與訂單管理小工具，實現訂單履約狀態追蹤、點擊展開明細與客戶 RFM 價值分群！

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `shop.sql`**：
   在 DBeaver 中開啟並執行 [`shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql)。
2. **安裝環境依賴**：
   ```bash
   pip install -r requirements.txt
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL 本機連線設定
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

