<div align="center">

# 🐘 第 4 章：SQL 語法與實戰練功

**跟著「暖光咖啡」總部的王經理，把每天的 Excel 問題變成一句 SQL**

[← 回課程首頁](../README.md)

</div>

![第 4 章學習路線](./images/chapter4_path.svg)

<div align="center">

**快速前往**　[📐 DDL](#-ddl蓋結構)　·　[🔍 DML](#-dml操作資料)　·　[💡 思維躍升](#-思維躍升從單一工作表到多張表)　·　[🧩 進階實戰](#-關聯資料庫進階實戰)

</div>

> [!TIP]
> **開始之前：** 確認已完成[第 1 章](../環境安裝/README.md)，DBeaver 連得上資料庫。按 `Ctrl/Cmd + Enter` 執行一句，`Alt/Opt + X` 執行全部。
>
> 看到 🚀 的單元，學完就可以接著做第 5 章對應的實戰專案。

### 👉 [從 DDL 導讀開始](./DDL%28定義資料語言%29.md)

---

## 📐 DDL：蓋結構

> 🎯 **學完你會：** 建立資料庫和資料表，並用規則擋下錯誤資料。

| 單元 | 課程 | 學到什麼 | 實戰專案 |
|:---:|---|---|---|
| 導讀 | [DDL 是什麼](./DDL%28定義資料語言%29.md) | CREATE、ALTER、DROP、TRUNCATE | |
| 1 | [建立資料庫](./1建立資料庫.md) | `CREATE DATABASE`、切換資料庫、命名規則 | |
| 2 | [基本型別](./2_0基本型別.md) | 金額為什麼不能用 FLOAT、電話為什麼是文字 | |
| 3 | [建立資料表](./2建立資料表.md) | `CREATE TABLE`、`ALTER TABLE` | |
| 4 | [匯入 CSV](./2_1匯入csv.md) | DBeaver 匯入、驗筆數、亂碼處理 | |
| 5 | [限制條件](./4限制.md) | `PRIMARY KEY`、`NOT NULL`、`UNIQUE`、`CHECK`、`DEFAULT` | 🚀 [專案 1 耗材庫存表](../app_projects/excel1_supplies/README.md)（步驟 1、2） |

---

## 🔍 DML：操作資料

> 🎯 **學完你會：** 新增、查詢、修改和刪除資料，並用 JOIN 把資料接起來。

| 單元 | 課程 | 學到什麼 | 實戰專案 |
|:---:|---|---|---|
| 導讀 | [DML 是什麼](./DML%28資料操作語言%29.md) | **匯入 `cafe_shop`**，開工準備 | |
| 1 | [新增資料](./3新增資料.md) | `INSERT`、`RETURNING`、單引號的坑 | |
| 2 | [查詢資料](./6取得資料.md) | `SELECT`、`WHERE`、`ORDER BY`、`LIMIT` | |
| 3 | [修改與刪除](./5修改和刪除.md) | `UPDATE`、`DELETE`、保命三步驟與交易 | 🚀 [專案 1 耗材庫存表](../app_projects/excel1_supplies/README.md)（步驟 3、4） |
| 4 | [外來鍵](./7_0FOREIGN_KEY.md) | 父子表、`ON DELETE` 怎麼選 | |
| 5 | [JOIN](./JOIN.md) | SQL 版的 VLOOKUP：五種 JOIN | 🚀 [專案 3 打卡表](../app_projects/excel3_attendance/README.md)（再學完下方的一對多入門） |
| 6 | [JSONB](./16json.md) | 飲料客製化、`->` 和 `->>` | 🚀 [專案 2 IT 設備規格表](../app_projects/excel2_devices/README.md) |

---

## 💡 思維躍升：從單一工作表到多張表

> 🎯 **學完你會：** 判斷一張 Excel 為什麼要拆表，以及要怎麼拆。
>
> 單一工作表裡，客戶電話一改就要改幾百列，刪掉訂單連客戶資料都不見。拆成多張表，再用主鍵和外來鍵串起來，這些問題就消失了。

| 單元 | 課程 | 學到什麼 | 實戰專案 |
|:---:|---|---|---|
| 必讀 | [從 Excel 到關聯式資料庫](../範例資料庫/從Excel到關聯資料庫_正規化.md) | 用四個問題檢查 Excel | |
| 入門 | [一對多關聯](./7.0適合初學者關聯資料庫.md) | 最常見的兩表關係 | 🚀 [專案 3 打卡表](../app_projects/excel3_attendance/README.md) |

---

## 🧩 關聯資料庫進階實戰

> 🎯 **學完你會：** 從多張表做出報表、統計和複雜查詢，並能檢查 AI 寫的 SQL。

**🏗 多表建立與查詢**

| 單元 | 課程 | 學到什麼 | 腳本 | 實戰專案 |
|:---:|---|---|:---:|---|
| 1 | [建立七張表](./7創建關聯資料庫.md) | 親手蓋出 `cafe_shop`、多對多設計 | | |
| 2 | [關聯新增](./8新增關聯資料庫資料.md) | 寫入順序、交易、SERIAL 撞號 | [.sql](./8新增關聯資料庫資料.sql) | 🚀 [專案 4 差旅報銷單](../app_projects/excel4_expense/README.md) |
| 3 | [關聯搜尋](./9搜尋關聯資料庫.md) | 拆解問題的三個步驟 | [.sql](./9搜尋關聯資料庫.sql) | 🚀 [專案 5 網路商店訂單](../app_projects/excel5_shop/README.md) |

**📊 統計、搜尋與合併**

| 單元 | 課程 | 學到什麼 | 腳本 | 實戰專案 |
|:---:|---|---|:---:|---|
| 4 | [聚合與分組](./10聚合函式.md) | SQL 版樞紐分析表：`GROUP BY`、`HAVING` | [.sql](./10聚合函式.sql) | |
| 5 | [模糊搜尋](./11萬用字元.md) | `LIKE`、`ILIKE`、`%`、`_` | [.sql](./11萬用字元.sql) | 🚀 [專案 6 客服案件紀錄](../app_projects/excel6_tickets/README.md) |
| 6 | [聯集](./12聯集.md) | `UNION`、`UNION ALL` | [.sql](./12聯集.sql) | |
| 7 | [綜合連結](./13連結.md) | 條件放 `ON` 還是 `WHERE` | [.sql](./13連結.sql) | 🚀 [專案 7 教育訓練報名表](../app_projects/excel7_training/README.md) |

**🎓 進階查詢與結業**

| 單元 | 課程 | 學到什麼 | 腳本 | 實戰專案 |
|:---:|---|---|:---:|---|
| 8 | [子查詢](./14子查詢.md) | `WITH`、`EXISTS`、`NOT IN` 遇到 NULL 的大坑 | [.sql](./14子查詢.sql) | |
| 9 | [ON DELETE](./15on_delete_action.md) | 查規則、預測後果、軟刪除 | [.sql](./15on_delete_action.sql) | 🚀 [專案 8 連鎖門市月報](../app_projects/excel8_stores/README.md) |
| 10 | [索引與效能](./17索引與效能.md) | 用 5 萬筆資料實測 `INDEX`、`EXPLAIN` | [腳本](../範例資料庫/中文範例資料庫/generate_100k_orders.sql) | |
| 11 | [AI 助教與結業挑戰](./關聯資料庫實作_用Prompt操作.md) | 抓出 AI 的錯、五大職務實戰、結業五題 | | |

---

| 上一章 | 目錄 | 下一章 |
|:---|:---:|---:|
| [⬅️ 第 3 章 用中文查詢資料庫](../MCP操作資料庫/README.md) | [🏠 課程首頁](../README.md) | [第 5 章 實戰專案 ➡️](../app_projects/README.md) |
