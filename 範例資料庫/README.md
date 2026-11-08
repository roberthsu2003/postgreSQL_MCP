# 範例資料庫

> 🎯 從下載 CSV 開始，學會把資料放進資料庫，再用 AI 處理工作上的 Excel

[← 回課程首頁](../README.md)

## 🧭 學習順序

| 步驟 | 做什麼 | 學完你會 |
|:---:|---|---|
| 1 | [下載 CSV，練習匯入](#第-1-步下載-csv練習匯入) | 把 CSV 匯入資料表，並確認筆數 |
| 2 | [用 AI 把 Excel 轉成 SQL 交易檔](#第-2-步用-ai-把-excel-轉成-sql-交易檔) | 檢查 AI 的 SQL，並親手執行 |
| 3 | [匯入範例資料庫](#第-3-步匯入範例資料庫) | 一次建好整個資料庫 |
| 4 | [認識五大職場範例](#第-4-步認識五大職場範例) | 知道哪個範例對應哪種工作 |

> [!IMPORTANT]
> **MCP 可以讀取資料庫，但不可以寫入。** 建表、新增、修改、刪除都由學生在 DBeaver 親手執行。

---

## 第 1 步：下載 CSV，練習匯入

先下載以下檔案。在 GitHub 打開檔案後，按右上角的 **Download raw file** 就能存到電腦。

| 建議順序 | 檔案 | 內容 | 筆數 |
|:---:|---|---|---:|
| 1 | [`目前天氣.csv`](./其它範例csv/目前天氣.csv) | 各縣市天氣，適合第一次練習 | 22 |
| 2 | [`門市銷售明細_2024Q1_全部.csv`](./excel範例/連鎖門市月報表/門市銷售明細_2024Q1_全部.csv) | 連鎖門市第一季銷售明細 | 782 |
| 3 | [`未正規化_網路商店單一工作表.csv`](./excel範例/未正規化_網路商店單一工作表.csv) | 全部記在一張表的訂單，用來觀察 Excel 的問題 | 7 |

匯入都是同樣的流程：

```mermaid
flowchart LR
    A["看 CSV 的欄位"] --> B["CREATE TABLE<br>建立資料表"]
    B --> C["DBeaver<br>Import Data"]
    C --> D["COUNT(*)<br>確認筆數"]
```

👉 **詳細步驟：[匯入 CSV](../SQL語法教學/2_1匯入csv.md)**

---

## 第 2 步：用 AI 把 Excel 轉成 SQL 交易檔

會匯入 CSV 之後，就可以處理更複雜的 Excel：請 AI 把一張表拆成多張關聯的表，並產生可以一次執行的交易檔。

```mermaid
flowchart LR
    A["準備 Excel<br>先脫敏"] --> B["請 AI 產生<br>SQL 交易檔"]
    B --> C["檢查 SQL"]
    C --> D["在 DBeaver<br>親手執行"]
```

👉 **實作指南與提示詞：[從 Excel 用 AI 生成 SQL 交易檔與 App 產品規劃指南](./從Excel用AI生成SQL交易檔與App產品規劃指南.md)**

---

## 第 3 步：匯入範例資料庫

所有範例 `.sql` 檔都在 👉 **[`中文範例資料庫/`](./中文範例資料庫/)**

1. 在 DBeaver 連線底下的 **Databases** 按右鍵 → **Create New Database**，**名稱和檔名相同**（例如 `cafe_shop`）。
2. **File → Open File** 開啟對應的 `.sql` 檔。
3. 確認工具列已切換到該資料庫，按下 `Alt + X`（Mac：`Opt + X`）執行整個檔案。

> [!WARNING]
> `cafe_shop` 和 `shop` 有同名的資料表，匯入同一個資料庫時，後者會**直接覆蓋**前者。請一個範例放一個資料庫。

---

## 第 4 步：認識五大職場範例

這些範例會在後面的課程陸續用到，可以先看看哪一個最接近你的工作。

| 職務 | 工作上的痛點 | 範例資料庫 | 對應 Excel | 延伸 App |
|---|---|---|---|---|
| 💼 **會計 / 出納** | 請款單滿天飛、重複報帳、預算超支 | [`expense_tracker`](./中文範例資料庫/expense_tracker.sql) | [報銷單](./excel範例/自備Excel轉SQL實戰示範/) | [費用報銷與預算](../app_projects/project1_expense_manager/) |
| 👥 **人資** | 排班撞期、工時加總繁瑣、算薪費時 | [`hr_attendance`](./中文範例資料庫/hr_attendance.sql) | [打卡表（簡化版）](../app_projects/excel2_attendance/打卡表.xlsx) | [排班出勤與薪資](../app_projects/project2_hr_attendance/) |
| 📦 **總務 / 倉管** | 設備找不到人、耗材斷貨、編號重複 | [`assets_inventory`](./中文範例資料庫/assets_inventory.sql) | [耗材庫存（簡化版）](../app_projects/excel1_supplies/耗材庫存表.xlsx) | [資產借還與耗材](../app_projects/project3_assets_inventory/) |
| ☕ **店長 / 營運** | 每月複製 Excel、跨月營收難統計 | [`cafe_shop`](./中文範例資料庫/cafe_shop.sql) | [門市月報](./excel範例/連鎖門市月報表/) | [門市營運看板](../app_projects/project4_cafe_dashboard/) |
| 🛒 **業務 / 電商** | 客戶資料矛盾、訂單難追蹤 | [`shop`](./中文範例資料庫/shop.sql) | [網路商店](./從Excel到關聯資料庫_正規化.md) | [客戶與訂單管理](../app_projects/project5_shop_crm/) |

---

## ✅ 過關檢查

- [ ] `目前天氣` 匯入後有 22 筆，門市銷售明細有 782 筆
- [ ] 我執行 AI 產生的交易檔之前，會先檢查內容
- [ ] `cafe_shop` 已匯入，`SELECT COUNT(*) FROM orders;` 回傳 490
- [ ] 我知道為什麼 `cafe_shop` 和 `shop` 不能放在同一個資料庫
- [ ] 資料改壞了，我知道重新執行 `.sql` 檔就能恢復

👉 **下一步：[第 3 章：用中文查詢資料庫](../MCP操作資料庫/)**

---

<details>
<summary>📎 進階資源：10 萬筆資料產生器（進階-10 才會用到）</summary>

[`generate_100k_orders.sql`](./中文範例資料庫/generate_100k_orders.sql) 會用 PostgreSQL 內建的 `generate_series()` 產生 5 萬筆訂單與約 10 萬筆明細，用來練習索引與查詢效能。

請在獨立的 `cafe_perf` 資料庫執行，不要灌進 `cafe_shop`。對應課程：[進階-10 索引與效能](../SQL語法教學/17索引與效能.md)。

</details>
