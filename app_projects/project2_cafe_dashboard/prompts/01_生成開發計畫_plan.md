# SDD 實戰步驟 1：請 AI 透過 MCP 檢查 cafe_shop 並產生 plan.md

---

## 🎯 複製以下 Prompt 給 Antigravity AI

請直接複製以下文字，在 Antigravity 對話框中發送：

```markdown
我已經準備好了門市銷售看板的規格文件 `PRD.md`，資料庫也已經執行過 `cafe_shop.sql`。

請按照「規格驅動開發 (SDD)」流程為我規劃開發計畫：

1. 請先使用 PostgreSQL MCP 工具（例如 list_tables、describe_table），實體檢查目前資料庫中 `stores`、`staff`、`categories`、`products`、`customers`、`orders`、`order_items` 的真實欄位結構與關聯鍵。
2. 仔細研讀 `PRD.md` 中關於「門市篩選、跨月份聚合統計、熱銷排行與 VIP 會員」的功能要求。
3. 根據真實資料表結構，在當前目錄下生成一份清晰的 `plan.md` 開發計畫。

請拆解為 3~4 個階段任務（Task）：
- **Task 1: 資料庫查詢層 (queries.py)**：編寫取得門市清單、計算月營收 KPI、熱銷品排行 TOP 5、VIP 名單等 SQL 函式。
- **Task 2: 前端視覺化看板 (app.py)**：使用 Streamlit 整合側邊欄選單、指標卡與圖表。
- **Task 3: 效能優化與測試**：加入 `@st.cache_data` 快取、驗證不同門市與月份切換下的統計準確度。

請立即開始透過 MCP 檢查資料表，並為我建立 `plan.md`！
```

