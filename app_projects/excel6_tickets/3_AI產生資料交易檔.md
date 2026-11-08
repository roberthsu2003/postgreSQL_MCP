# 步驟 3｜AI 產生資料交易檔：原文要一字不改

> 💻 AI 對話框 + DBeaver（資料庫：`tickets`）｜ 🎯 學完你會：要求 AI 保留原始文字，並完成對帳

> 📚 先修：[專案 4 步驟 3](../excel4_expense/3_AI產生資料交易檔.md)的編號與 `setval`。

## 🎬 情境

問題描述裡的 WiFi、wifi、Wi-Fi 寫法不一致，這正是下一步要練習搜尋的內容。AI 很可能「好心」幫你統一，所以要明確告訴它**不可以修改**。

## 1. 請 AI 產生交易檔

附加 `客服案件紀錄.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取「案件紀錄」工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱：
（貼上你的三句 CREATE TABLE）

請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT、SELECT setval(...) 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. Excel 沒有人員和分類的編號，請依出現順序從 1 開始編號，寫完後用 setval 設定自動編號。
3. 寫入順序：agents、categories、tickets。
4. 30 件案件全部轉換。問題描述必須一字不改，不可以統一大小寫或修正寫法。
5. 空白的結案日期請寫 NULL。

請直接輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 2. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 寫入順序 | 人員、分類、案件 |
| 自動編號 | 兩句 `setval` |
| 原文 | T005 是小寫 `wifi`，T009 是大寫 `WIFI`，T013 是 `Wi-Fi` |

可以和標準答案 [`tickets_data.sql`](./tickets_data.sql) 對照。

## 3. 匯入並對帳

按 `Alt + X`（Mac：`Opt + X`）執行整份。失敗時**先執行 `ROLLBACK;`**。

先在「案件紀錄」工作表輸入公式：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 案件數 | `=COUNTA(A2:A31)` | 30 |
| 已結案 | `=COUNTIF(H2:H31,"已結案")` | 19 |
| 處理人員數 | `=SUMPRODUCT(1/COUNTIF(F2:F31,F2:F31))` | 4 |
| 分類數 | `=SUMPRODUCT(1/COUNTIF(D2:D31,D2:D31))` | 4 |

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM agents) AS 人員,
       (SELECT COUNT(*) FROM categories) AS 分類,
       (SELECT COUNT(*) FROM tickets) AS 案件,
       (SELECT COUNT(*) FROM tickets WHERE status = '已結案') AS 已結案;
```

**執行結果**

| 人員 | 分類 | 案件 | 已結案 |
|---:|---:|---:|---:|
| 4 | 4 | 30 | 19 |

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| `tickets_check` | AI 把空白日期寫成空字串，或狀態和日期對不上 | 先 `ROLLBACK;`，提醒 AI 空白要寫 `NULL` |
| 搜尋結果比講義多 | AI 統一了文字寫法 | 請 AI 重新產生，並保留原文 |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`tickets_full.sql`](./tickets_full.sql)，它會**取代你手寫的表** |

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 4：搜尋與統計回答故事 ➡️](./4_搜尋與統計回答故事.md) |
