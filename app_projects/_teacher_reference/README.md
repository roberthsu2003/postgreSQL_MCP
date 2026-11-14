# 講師參考與自動化測試檔（學員實作請勿直接匯入）

> [!CAUTION]
> **教學原則：學員必須全程親手寫 SQL，不得直接匯入現成檔案。**
> 本資料夾存放八個專案的標準 DDL 與交易對照檔，僅供**講師備課、自動化驗證與課後解答核對**使用。

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
