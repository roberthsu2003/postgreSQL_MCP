# 範例資料庫與職場實戰總覽 (會計・人資・總務・店長・業務)

在學習 SQL 與資料庫的過程中，**「範例資料庫」是決定學習成效的最關鍵核心**。  
很多上班族學員在課堂上聽得懂，但回家後面對自己工作上複雜的 Excel，卻不知道如何下手。

本專案的核心教學理念是：  
**「最接地氣的職場實戰：針對一般會計、出納、總務、業務、人資日常工作痛點，透過 AI 產生關聯式 SQL 交易檔，並親手在自己電腦上打造獨立運作的個人桌面小 App（PyQt5 / Tkinter）！」**

---

## ⚠️ 核心教學規範：MCP 可以讀取、不可寫入，扎實學習手寫 SQL

1. **不可以叫 MCP 寫入資料庫，但可以讀取**：
   - MCP 可以讀取資料庫的結構和資料；建表、新增、修改、刪除都不可以透過 MCP 執行。
   - 學生學習 SQL 的關鍵在於：親眼看懂每一條 DDL（`CREATE TABLE`、主鍵、外來鍵約束）與 DML（`INSERT INTO ... VALUES`、`SELECT ... JOIN`）。
   - Prompt 僅用於引導 AI 產出純 SQL 交易檔文字，由學生**親自在 DBeaver 執行**。
2. **拒絕線上架站繁瑣，聚焦個人本機桌面小 App**：
   - 不使用需要雲端部署、架伺服器的線上版（如 Web / Streamlit）。
   - 全面採用 **PyQt5**（高質感商業管理系統）與 **Tkinter**（Python 內建，免安裝繁雜環境，雙擊 `.py` 立即跑出視窗），做出在自己電腦上即開即用的個人管理小工具。
3. **Python 程式中全數手寫 SQL**：
   - 在桌面 App 的按鈕與表格背後，使用 `psycopg2` 撰寫原生 SQL（`cursor.execute("SELECT ...")`），讓學生深刻體會「手寫 SQL 如何驅動視窗畫面」。

---

## 🏢 五大職場核心職能完美對照

| 適用職務 | 範例資料庫檔案 | 解決之職場 Excel 痛點 | 最終打造的個人桌面 App | 桌面框架 |
|---|---|---|---|:---:|
| 💼 **會計 / 出納** | [`expense_tracker.sql`](./中文範例資料庫/expense_tracker.sql)<br>([報銷單 Excel](./excel範例/自備Excel轉SQL實戰示範/)) | 員工差旅請款 Excel 滿天飛、重複報帳、部門預算超支無預警 | **[企業費用報銷審核與預算系統](../app_projects/project1_expense_manager/)** | 🔵 **PyQt5** |
| 👥 **人資 (HR)** | [`hr_attendance.sql`](./中文範例資料庫/hr_attendance.sql) | 手動排班撞期與違反勞基法、打卡工時加總繁瑣、請假加班算薪算到眼花 | **[員工排班出勤與薪資試算小工具](../app_projects/project2_hr_attendance/)** | 🟢 **Tkinter** |
| 📦 **總務 / 倉管** | [`assets_inventory.sql`](./中文範例資料庫/assets_inventory.sql) | 筆電投影機借出沒還找不到人、耗材臨時斷貨缺安全庫存預警、資產編號重複 | **[固定資產借還與耗材庫存系統](../app_projects/project3_assets_inventory/)** | 🔵 **PyQt5** |
| ☕ **店長 / 營運** | [`cafe_shop.sql`](./中文範例資料庫/cafe_shop.sql)<br>([門市月報 Excel](./excel範例/連鎖門市月報表/)) | 解決「每個月複製一份 Excel」痛點、跨月營收與明星熱銷排行、VIP 常客名單 | **[門市營運分析與業績抽成看板](../app_projects/project4_cafe_dashboard/)** | 🔵 **PyQt5** |
| 🛒 **業務 / 電商** | [`shop.sql`](./中文範例資料庫/shop.sql)<br>([網路商店 Excel](./從Excel到關聯資料庫_正規化.md)) | 客戶電話地址在 Excel 容易矛盾、訂單狀態履約追蹤、客戶 RFM 價值分群 | **[客戶關係 CRM 與訂單履約系統](../app_projects/project5_shop_crm/)** | 🟢 **Tkinter** |

---

## 🌟 核心特色：從 Excel 痛點到個人桌面小 App

```mermaid
flowchart LR
    A["1. 上班族日常 Excel<br>(費用/排班/資產/門市/客戶)"] --> B["2. 詢問 AI (Prompt)<br>產生標準 SQL 交易腳本文字"]
    B --> C["3. 學生在 DBeaver 執行<br>手動匯入與驗證結構"]
    C --> D["4. 實戰 SQL 語法<br>SELECT / JOIN / GROUP BY"]
    D --> E["5. 打造個人桌面小 App<br>PyQt5 / Tkinter 桌面軟體"]
```

👉 **詳細實作指南與 Prompt 提示詞範本**：  
請參閱專屬文件：📖 **[從 Excel 用 AI 生成 SQL 交易檔與 App 產品規劃指南](./從Excel用AI生成SQL交易檔與App產品規劃指南.md)**

---

## 📁 範例資料庫匯入方式（DBeaver 一鍵建庫）

所有範例 `.sql` 檔均收錄於：👉 **[`中文範例資料庫/`](./中文範例資料庫/)**

1. 在 DBeaver 連線底下的 **Databases** 按右鍵 → **Create New Database**，**名稱和檔名相同**（例如 `cafe_shop`）。
2. **File → Open File** 開啟對應的 `.sql` 檔。
3. 確認工具列已切換到該資料庫，按下 `Alt + X`（Mac：`Opt + X`）執行整個檔案。

> [!IMPORTANT]
> `cafe_shop` 和 `shop` 有同名的資料表，匯入同一個資料庫時，後者會**直接覆蓋**前者。第 4、5、7 章請一個範例放一個資料庫。

---

## 🚀 巨量資料產生器（免下載大檔，10 萬筆）

📄 **檔案**：[`generate_100k_orders.sql`](./中文範例資料庫/generate_100k_orders.sql)

利用 PostgreSQL 內建的 `generate_series()` 引擎：
* **零網路傳輸**：完全不需要下載或上傳大檔案。
* **極速生成**：在 DBeaver 執行此腳本，**僅需 1~2 秒**，即可動態產生 5 萬筆訂單與 10 萬筆商品明細，專門用來練習索引（INDEX）優化與 EXPLAIN 效能分析！

## ✅ 過關檢查

- [ ] `cafe_shop` 已匯入，`SELECT COUNT(*) FROM orders;` 回傳 490
- [ ] 我知道為什麼 `cafe_shop` 和 `shop` 不能放在同一個資料庫
- [ ] 資料改壞了，我知道重新執行 `.sql` 檔就能恢復

👉 **下一步：[第 3 章：用中文查詢資料庫](../MCP操作資料庫/)**
