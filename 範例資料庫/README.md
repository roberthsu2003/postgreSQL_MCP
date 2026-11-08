<div align="center">

# 🗄️ 範例資料庫

**從下載一份 CSV 開始，學會把資料放進資料庫，再用 AI 處理工作上的 Excel**

[← 回課程首頁](../README.md)

</div>

![範例資料庫四個步驟](./images/sample_db_steps.svg)

<div align="center">

**快速前往**　[① 匯入 CSV](#第-1-步下載-csv練習匯入)　·　[② AI 交易檔](#第-2-步用-ai-把-excel-轉成-sql-交易檔)　·　[③ 範例資料庫](#第-3-步匯入範例資料庫)　·　[④ 8 個 Excel 範例](#第-4-步認識-8-個-excel-範例)　·　[✅ 過關檢查](#-過關檢查)

</div>

> [!IMPORTANT]
> **MCP 可以讀取資料庫，但不可以寫入。** 建表、新增、修改、刪除都由你在 DBeaver 親手執行。

---

## 第 1 步：下載 CSV，練習匯入

> 🎯 **完成後你會：** 把 CSV 匯入資料表，並確認資料一筆都沒少。

**① 下載練習檔**：點檔名，再按 GitHub 右上角的 **Download raw file**。

| 順序 | 練習檔 | 內容 | 筆數 |
|:---:|---|---|---:|
| 🟢 先做 | ⬇️ [`目前天氣.csv`](./其它範例csv/目前天氣.csv) | 各縣市天氣，欄位少，適合第一次 | 22 |
| 🟡 再做 | ⬇️ [`門市銷售明細_2024Q1_全部.csv`](./excel範例/連鎖門市月報表/門市銷售明細_2024Q1_全部.csv) | 連鎖門市第一季銷售明細 | 782 |
| 🔵 觀察 | ⬇️ [`未正規化_網路商店單一工作表.csv`](./excel範例/未正規化_網路商店單一工作表.csv) | 全部記在一張表的訂單，找找看哪裡有問題 | 7 |

**② 依照教學匯入**：流程都是這四步，建表語法教學裡都準備好了，照著貼上即可。

| 1️⃣ 看欄位 | 2️⃣ 建資料表 | 3️⃣ 匯入資料 | 4️⃣ 確認筆數 |
|:---:|:---:|:---:|:---:|
| 打開 CSV 看標題列 | `CREATE TABLE` | DBeaver 的 **Import Data** | `SELECT COUNT(*)` |

### 👉 [開始練習：匯入 CSV](../SQL語法教學/2_1匯入csv.md)

---

## 第 2 步：用 AI 把 Excel 轉成 SQL 交易檔

> 🎯 **完成後你會：** 請 AI 把一張表拆成多張關聯的表，檢查 SQL 之後親手執行。

| 1️⃣ 準備 Excel | 2️⃣ 請 AI 產生 | 3️⃣ 檢查 SQL | 4️⃣ 親手執行 |
|:---:|:---:|:---:|:---:|
| 個資先**脫敏** | 貼上專用提示詞 | 看懂再執行 | 在 DBeaver 執行 |

### 👉 [開始練習：從 Excel 用 AI 生成 SQL 交易檔](./從Excel用AI生成SQL交易檔與App產品規劃指南.md)

---

## 第 3 步：匯入範例資料庫

> 🎯 **完成後你會：** 一次建好整個資料庫，資料改壞了也能馬上恢復。

**先匯入這兩個就夠了**，其他範例等課程用到再匯入：

| 檔案 | 資料庫名稱 | 用在 |
|---|---|---|
| ⬇️ [`cafe_shop.sql`](./中文範例資料庫/cafe_shop.sql) | `cafe_shop` | 第 3、4 章的主要練習 |
| ⬇️ [`shop.sql`](./中文範例資料庫/shop.sql) | `practice` | 第 3 章用中文查詢 |

**匯入方式：**

1. 在 DBeaver 連線底下的 **Databases** 按右鍵 → **Create New Database**，輸入上表的資料庫名稱。
2. **File → Open File**，開啟對應的 `.sql` 檔。
3. 確認工具列已切換到該資料庫，按 `Alt + X`（Mac：`Opt + X`）執行整個檔案。

> [!WARNING]
> `cafe_shop` 和 `shop` 有同名的資料表，匯入同一個資料庫時，後者會**直接覆蓋**前者。請一個範例放一個資料庫。

📚 所有範例的結構和說明：[`中文範例資料庫/`](./中文範例資料庫/README.md)

---

## 第 4 步：認識 8 個 Excel 範例

> 🎯 **完成後你會：** 知道哪個範例最接近你的工作。這些範例會在第 5 章的實戰專案用到，現在先認識就好。

<table>
<tr>
<td width="50%" valign="top">

**1. 🏢 耗材庫存表**（總務）

手動改庫存、斷貨才發現

📊 [下載 Excel](../app_projects/excel1_supplies/耗材庫存表.xlsx)<br>
🚀 [進入專案](../app_projects/excel1_supplies/README.md)<br>
📍 教完 DDL-5、DML-3 可以開始

</td>
<td width="50%" valign="top">

**2. 💻 IT 設備規格表**（資訊）

每種設備欄位不同，表越加越寬

📊 [下載 Excel](../app_projects/excel2_devices/設備規格表.xlsx)<br>
🚀 [進入專案](../app_projects/excel2_devices/README.md)<br>
📍 教完 DML-6 可以開始

</td>
</tr>
<tr>
<td valign="top">

**3. 👥 打卡表**（人資）

部門重複填寫、新人放不進表

📊 [下載 Excel](../app_projects/excel3_attendance/打卡表.xlsx)<br>
🚀 [進入專案](../app_projects/excel3_attendance/README.md)<br>
📍 教完 一對多入門 可以開始

</td>
<td valign="top">

**4. 💼 差旅報銷單**（會計 / 出納）

重複報帳、不知道該催誰審核

📊 [下載 Excel](../app_projects/excel4_expense/差旅報銷單.xlsx)<br>
🚀 [進入專案](../app_projects/excel4_expense/README.md)<br>
📍 教完 進階-2 可以開始

</td>
</tr>
<tr>
<td valign="top">

**5. 🛒 網路商店訂單**（業務）

商品調價後，舊訂單金額算不準

📊 [下載 Excel](../app_projects/excel5_shop/網路商店訂單表.xlsx)<br>
🚀 [進入專案](../app_projects/excel5_shop/README.md)<br>
📍 教完 進階-3 可以開始

</td>
<td valign="top">

**6. 🎧 客服案件紀錄**（客服）

關鍵字寫法不一，舊案件找不到

📊 [下載 Excel](../app_projects/excel6_tickets/客服案件紀錄.xlsx)<br>
🚀 [進入專案](../app_projects/excel6_tickets/README.md)<br>
📍 教完 進階-5 可以開始

</td>
</tr>
<tr>
<td valign="top">

**7. 🎓 教育訓練報名表**（訓練承辦）

兩份名單要手動合併

📊 [下載 Excel](../app_projects/excel7_training/教育訓練報名表.xlsx)<br>
🚀 [進入專案](../app_projects/excel7_training/README.md)<br>
📍 教完 進階-7 可以開始

</td>
<td valign="top">

**8. ☕ 連鎖門市月報**（店長 / 營運）

每月複製 Excel，跨月統計困難

📊 [下載 Excel](./excel範例/連鎖門市月報表/)<br>
🚀 [進入專案](../app_projects/excel8_stores/README.md)<br>
📍 教完 進階-9 可以開始

</td>
</tr>
</table>

🎓 **你的工作不在這裡？** 學完之後可以換成自己的 Excel，走一次完整流程：[畢業專題：換你的 Excel](../app_projects/畢業專題_換你的Excel.md)

---

## ✅ 過關檢查

都打勾了再往下一章：

- [ ] **① 匯入 CSV**：`目前天氣` 有 22 筆，門市銷售明細有 782 筆
- [ ] **② AI 交易檔**：我執行 AI 產生的交易檔之前，會先檢查內容
- [ ] **③ 範例資料庫**：`cafe_shop` 的 `SELECT COUNT(*) FROM orders;` 回傳 490
- [ ] **③ 範例資料庫**：我知道資料改壞了，重新執行 `.sql` 檔就能恢復

---

| 上一章 | 目錄 | 下一章 |
|:---|:---:|---:|
| [⬅️ 第 1 章 環境安裝](../環境安裝/README.md) | [🏠 課程首頁](../README.md) | [第 3 章 用中文查詢資料庫 ➡️](../MCP操作資料庫/README.md) |

<details>
<summary>📎 進階資源：10 萬筆資料產生器（進階-10 才會用到）</summary>

<br>

[`generate_100k_orders.sql`](./中文範例資料庫/generate_100k_orders.sql) 會用 PostgreSQL 內建的 `generate_series()` 產生 5 萬筆訂單與約 10 萬筆明細，用來練習索引與查詢效能。

請在獨立的 `cafe_perf` 資料庫執行，不要灌進 `cafe_shop`。對應課程：[進階-10 索引與效能](../SQL語法教學/17索引與效能.md)。

</details>
