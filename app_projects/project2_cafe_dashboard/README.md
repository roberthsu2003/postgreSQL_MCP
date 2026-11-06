# 實戰專案 2：連鎖咖啡門市營運分析看板

* **模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **核心技術**：PostgreSQL / Supabase (`cafe_shop.sql`)、MCP Server、Streamlit、Pandas、Plotly
* **難易度**：⭐⭐ (入門商業數據實戰)

---

## 📖 專案背景

本專案銜接前面的「Excel 跨月份檔案管理痛點」教學，將已正規化儲存於 PostgreSQL 中的門市銷售資料，打造為現代化的商業智慧看板 (BI Dashboard)。

---

## 🚀 SDD 開發步驟

1. **建立資料庫**：在 Supabase 或 DBeaver 中執行 [`cafe_shop.sql`](../../範例資料庫/中文範例資料庫/cafe_shop.sql)。
2. **研讀 PRD**：打開 [`PRD.md`](./PRD.md)，確認功能需求與 KPI 指標。
3. **產生計畫**：依照 [`prompts/01_生成開發計畫_plan.md`](./prompts/01_生成開發計畫_plan.md) 請 AI 呼叫 MCP 生成 `plan.md`。
4. **逐步實作**：循序完成資料庫查詢函式與 Streamlit 介面！

