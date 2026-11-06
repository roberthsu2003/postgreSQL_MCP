# 專案 3：企業資產借還與耗材庫存 PyQt5 系統

本專案適用職務：**總務 (General Affairs)、行政庶務、IT 資產管理、倉管**  
對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/assets_inventory.sql`](../../範例資料庫/中文範例資料庫/assets_inventory.sql)**

---

## 🚀 專案目標

將總務痛點滿滿的 Excel 資產清冊，升級為高質感的 **PyQt5 專業管理視窗軟體**，實現設備借還追蹤、逾期紅字警示與辦公耗材低庫存自動補貨提示！

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `assets_inventory.sql`**：
   在 DBeaver 中開啟並執行 [`assets_inventory.sql`](../../範例資料庫/中文範例資料庫/assets_inventory.sql)。
2. **安裝環境依賴**：
   ```bash
   pip install -r requirements.txt
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL 本機連線設定
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

