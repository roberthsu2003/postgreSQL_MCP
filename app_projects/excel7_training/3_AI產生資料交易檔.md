# 步驟 3｜AI 產生資料交易檔：三張工作表，五張資料表

> 💻 AI 對話框 + DBeaver（資料庫：`training`）｜ 🎯 學完你會：請 AI 處理多張工作表和三種出席狀態，並完成對帳

> 📚 先修：[專案 4 步驟 3](../excel4_expense/3_AI產生資料交易檔.md)的編號與 `setval`。

## 1. 請 AI 產生交易檔

附加 `教育訓練報名表.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請讀取「課程清單」「內部員工報名」「外部來賓報名」三張工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱：
（貼上你的五句 CREATE TABLE）

資料規則：
- 員工用工號辨識，來賓用信箱辨識。兩位陳小華是不同的人，一位是員工，一位是來賓。
- 來賓沒有編號，請依出現順序從 1 開始編號，寫完後用 setval 設定自動編號。
- 出席欄：是=true、否=false、空白=NULL，不可以把空白當成 false。

請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT、SELECT setval(...) 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. 寫入順序：courses、employees、guests、employee_enrollments、guest_enrollments。
3. 所有資料都要轉換，不可省略。

請直接輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 2. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 寫入順序 | 報名紀錄排在最後 |
| 去除重複 | 員工 6 筆、來賓 5 筆 |
| 出席 | C06 的三筆是 `NULL`，不是 `false` |
| C05 | 課程有寫入，但沒有報名紀錄 |

可以和標準答案 [`training_data.sql`](./training_data.sql) 對照。

## 3. 匯入並對帳

按 `Alt + X`（Mac：`Opt + X`）執行整份。失敗時**先執行 `ROLLBACK;`**。

在對應的工作表輸入公式：

| 項目 | 工作表 | Excel 公式 | 答案 |
|---|---|---|---:|
| 課程數 | 課程清單 | `=COUNTA(A2:A7)` | 6 |
| 內部報名 | 內部員工報名 | `=COUNTA(A2:A15)` | 14 |
| 內部出席 | 內部員工報名 | `=COUNTIF(E2:E15,"是")` | 8 |
| 員工數 | 內部員工報名 | `=SUMPRODUCT(1/COUNTIF(B2:B15,B2:B15))` | 6 |
| 外部報名 | 外部來賓報名 | `=COUNTA(A2:A8)` | 7 |
| 外部出席 | 外部來賓報名 | `=COUNTIF(E2:E8,"是")` | 5 |
| 來賓數 | 外部來賓報名 | `=SUMPRODUCT(1/COUNTIF(D2:D8,D2:D8))` | 5 |

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM courses) AS 課程,
       (SELECT COUNT(*) FROM employees) AS 員工,
       (SELECT COUNT(*) FROM guests) AS 來賓,
       (SELECT COUNT(*) FROM employee_enrollments) AS 內部報名,
       (SELECT COUNT(*) FROM guest_enrollments) AS 外部報名;

SELECT (SELECT COUNT(*) FROM employee_enrollments WHERE attended) AS 內部出席,
       (SELECT COUNT(*) FROM guest_enrollments WHERE attended) AS 外部出席;
```

**執行結果**：課程 6、員工 6、來賓 5、內部報名 14、外部報名 7；內部出席 8、外部出席 5。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| 來賓變成 4 位 | AI 把兩位陳小華當成同一人，或漏了來賓 | 提醒 AI 用信箱辨識 |
| 出席數對不上 | AI 把空白當成 `false` | 請 AI 改成 `NULL` |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`training_full.sql`](./training_full.sql)，它會**取代你手寫的表** |

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 專案說明](./README.md) | [步驟 4：合併與連結回答故事 ➡️](./4_合併與連結回答故事.md) |
