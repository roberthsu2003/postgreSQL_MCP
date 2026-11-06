# 實戰專案：規格驅動開發 (SDD) 專區

本目錄包含結合 **PostgreSQL / Supabase + MCP + Python (Streamlit / GUI)** 的綜合實戰專案。

不同於傳統「照抄現成專案」的學習方式，本專區採用現代 AI 軟體工程的 **規格驅動開發 (SDD, Spec-Driven Development)** 流程：

```mermaid
flowchart LR
    A["1. 規格需求 (PRD.md)<br>定義功能、畫面與邏輯"] --> B["2. AI 探索真實環境<br>透過 MCP 檢查資料庫 Schema"]
    B --> C["3. 產生計畫 (plan.md)<br>AI 自動拆解 Task 清單"]
    C --> D["4. 任務驅動實作<br>一步一驗證，高效率完成"]
```

> 💡 **環境提示**：使用 Devcontainer 時，資料夾路徑必須包含英文字母與數字（如 `app_projects`），避免純中文路徑可能造成的 Docker 掛載異常。

---

## 📁 實戰專案列表

| 專案 | 應用場景 | 核心技術亮點 | 適合技術 |
|---|---|---|---|
| ⭐ **[專案 1：股市即時監控與增量同步](./project1_stock_market/)** | 金融股市、資料快取 | **Cache-Aside 快取與增量同步**<br>• 無資料上網抓、有資料走 DB<br>• 自動偵測落後天數並補齊 (Upsert)<br>• 0.1 秒極速載入 | Streamlit / Tkinter<br>yfinance<br>PostgreSQL MCP |
| ☕ **[專案 2：連鎖門市營運分析看板](./project2_cafe_dashboard/)** | 商業分析、連鎖經營 | **跨月商業報表與 BI 看板**<br>• 銜接前面 Excel 跨月痛點教學<br>• 門市/月份切換與營收成長分析<br>• 明星商品 TOP 5 與 VIP 常客名冊 | Streamlit<br>Plotly<br>`cafe_shop.sql` |

---

## 🛠️ 開發流程三步驟

1. **先在資料庫建好資料表**：執行各專案內的 `.sql` 腳本（如 `init_stock_db.sql` 或 `cafe_shop.sql`）。
2. **確認 Antigravity 的 PostgreSQL MCP 連線正常**：讓 AI 具備隨時查看資料表結構的能力。
3. **複製 Prompt 引導 AI 啟動 SDD**：打開專案目錄下的 `prompts/01_生成開發計畫_plan.md`，貼給 AI 即可展開開發！
