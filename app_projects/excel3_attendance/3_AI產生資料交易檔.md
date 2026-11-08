# 步驟 3｜AI 產生資料交易檔：一張總表變成兩份資料

> 💻 AI 對話框 + DBeaver（資料庫：`attendance`）｜ 🎯 學完你會：請 AI 把總表拆進兩張表、處理矛盾資料，並完成對帳

> 📚 先修：[專案 1 步驟 3](../excel1_supplies/3_AI產生資料交易檔.md)。這裡多了兩個挑戰：員工資料要去除重複，矛盾資料要由你決定。

## 🎬 情境

Excel 有 28 列，但裡面只有 6 位員工。AI 要把員工去除重複後放進 `employees`，打卡紀錄放進 `attendance`，而且不能自己決定周美玲到底是哪個部門。

## 1. 請 AI 產生交易檔

附加 `打卡表.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取「打卡紀錄」工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱，不要新增或更改：
（貼上你的兩句 CREATE TABLE）

轉換之前，請先檢查：同一個工號的姓名、部門、職稱前後是否一致。
如果不一致，請列出來問我要以哪個為準，得到我的回答之前不要產生 SQL。

確認之後，請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT INTO ... VALUES; 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. INSERT 要明確寫出欄位名稱。
3. 先寫入 employees（每位員工只有一筆），再寫入 attendance。
4. 28 筆打卡全部轉換，不可省略，也不可修改時間。空白的打卡時間請寫 NULL。
5. 日期用 'YYYY-MM-DD'，時間用 'HH:MM'。

請直接在對話中輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 2. 回答 AI 的問題

AI 應該會指出：`E05` 周美玲的部門有「業務發展部」和「業務部」兩種。請回答：

```text
以「業務發展部」為準。
```

> [!TIP]
> **如果 AI 沒有問就直接產生 SQL**，請提醒它漏了檢查。AI 不一定每次都照做，所以下面的檢查要由你來把關。

## 3. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 有沒有多餘的動作 | 沒有 `CREATE`、`DROP`、`ALTER`、`TRUNCATE` |
| 寫入順序 | 先 `employees`，再 `attendance` |
| 員工筆數 | 6 筆，`E05` 只有一筆，部門是業務發展部 |
| 忘記打卡 | 3 個空白時間都是 `NULL`，不是 `'00:00'` 或空字串 |

可以和標準答案 [`attendance_data.sql`](./attendance_data.sql) 對照。

## 4. 匯入資料

確認工具列是 `attendance`，按 `Alt + X`（Mac：`Opt + X`）執行整份。如果失敗，**先執行 `ROLLBACK;`**，修好問題後再執行一次。

## 5. 和 Excel 對帳

先在「打卡紀錄」工作表的空白處輸入公式：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 員工數（不重複的工號） | `=SUMPRODUCT(1/COUNTIF(A2:A29,A2:A29))` | 6 |
| 打卡筆數 | `=COUNTA(A2:A29)` | 28 |
| 遲到次數 | `=COUNTIF(F2:F29,">"&TIME(9,0,0))` | 5 |

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM employees) AS 員工數,
       (SELECT COUNT(*) FROM attendance) AS 打卡筆數,
       (SELECT COUNT(*) FROM attendance WHERE clock_in > '09:00') AS 遲到次數;
```

**執行結果**

| 員工數 | 打卡筆數 | 遲到次數 |
|---:|---:|---:|
| 6 | 28 | 5 |

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `violates foreign key constraint` | AI 先寫 `attendance`，或漏了某位員工 | 先 `ROLLBACK;`，再請 AI 修正順序或補上員工 |
| `duplicate key ... "employees_pkey"` | 員工沒有去除重複，或測試資料沒清 | 先 `ROLLBACK;`，再檢查員工 INSERT |
| `column "..." does not exist` | 欄位名稱和 INSERT 不同 | 先 `ROLLBACK;`，再修正欄位名稱 |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`attendance_full.sql`](./attendance_full.sql)，它會**取代你手寫的表** |

## ✍️ 動手練

**如果 AI 把員工放在第二段才寫入，會發生什麼事？** 先想一想，再看答案。

<details>
<summary>看答案</summary>

第一筆打卡就會違反外來鍵，因為那時 `employees` 還沒有這位員工。整份交易都不會寫入，兩張表仍然是 0 筆。

</details>

## 🤖 問 AI 助教

> 我執行交易檔時出現這個錯誤：（貼上完整錯誤訊息）。這是我的兩句 CREATE TABLE：（貼上）。請告訴我錯在哪裡、為什麼，由我自己修改。

## ✅ 過關檢查

- [ ] 我自己決定了周美玲的部門，不是讓 AI 猜
- [ ] 我執行前檢查過寫入順序和 `NULL`
- [ ] 對帳結果是 6、28、5

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 4：JOIN 回答故事 ➡️](./4_JOIN回答故事.md) |
