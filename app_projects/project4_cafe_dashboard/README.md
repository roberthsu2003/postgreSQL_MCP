# 專案 4：門市營運分析與業績抽成 PyQt5 商業桌面 App

本專案適用職務：**門市店長、營運經理、連鎖零售主管、區域業務督導**  
對應範例資料庫：👉 **[`範例資料庫/中文範例資料庫/cafe_shop.sql`](../../範例資料庫/中文範例資料庫/cafe_shop.sql)**  
對應職場 Excel：👉 **[`連鎖門市月報表`](../../範例資料庫/excel範例/連鎖門市月報表/)**

---

## 🚀 專案目標

將「每個月複製一份 Excel」的痛苦職場記帳，轉變為現代化的 **PyQt5 門市營運分析系統**，實現跨月跨店動態切換、明星熱賣排行與 VIP 常客名單秒出！

---

## 🛠️ 開發三步驟 (SDD 流程)

1. **先在資料庫匯入 `cafe_shop.sql`**：
   在 DBeaver 中開啟並執行 [`cafe_shop.sql`](../../範例資料庫/中文範例資料庫/cafe_shop.sql)。
2. **安裝環境依賴**：
   ```bash
   pip install -r requirements.txt
   cp .env.example .env
   # 編輯 .env 填入你的 PostgreSQL 本機連線設定
   ```
3. **複製 Prompt 引導 AI 啟動開發**：
   打開 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md)，貼給 AI 即刻展開規格驅動開發！

