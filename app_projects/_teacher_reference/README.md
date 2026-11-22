# 講師參考與資料交易核對檔

> [!CAUTION]
> **先完成手寫 DDL 與 AI 轉檔練習，再核對解答。**
> `*_full.sql` 是含建表的講師／自動化測試檔，不作為學生的建表流程。`*_data.sql` 是純資料交易核對檔，已連結到各專案步驟 3；學生可在自己建表與產生交易後下載比對，執行前必須清空本專案練習資料。

## 檔案對照表

| 專案 | 交易資料對照檔 | 完整建表＋資料測試檔 | 對應資料庫 |
|:---:|---|---|---|
| 1 | [`supplies_data.sql`](./supplies_data.sql) | [`supplies_full.sql`](./supplies_full.sql) | `supplies` |
| 2 | [`devices_data.sql`](./devices_data.sql) | [`devices_full.sql`](./devices_full.sql) | `devices` |
| 3 | [`attendance_data.sql`](./attendance_data.sql) | [`attendance_full.sql`](./attendance_full.sql) | `attendance` |
| 4 | [`expense_data.sql`](./expense_data.sql) | [`expense_full.sql`](./expense_full.sql) | `expense` |
| 5 | [`shop_data.sql`](./shop_data.sql) | [`shop_full.sql`](./shop_full.sql) | `online_shop` |
| 6 | [`tickets_data.sql`](./tickets_data.sql) | [`tickets_full.sql`](./tickets_full.sql) | `tickets` |
| 7 | [`training_data.sql`](./training_data.sql) | [`training_full.sql`](./training_full.sql) | `training` |
| 8 | [`store_data.sql`](./store_data.sql) | [`store_full.sql`](./store_full.sql) | `store_sales` |

另保留原 CSV 檔 [`門市銷售明細_202404.csv`](./門市銷售明細_202404.csv) 供備查；學員在專案 8 一律改用 `excel8_stores/門市月報_需求與樣本.xlsx` 內的跨月精選樣本與「4月新銷售明細」工作表，請 AI 產生 SQL Transaction 執行。
