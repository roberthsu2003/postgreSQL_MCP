# 步驟 3｜AI 產生資料交易檔：編號與寫入順序

> 💻 AI 對話框 + DBeaver（資料庫：`expense`）｜ 🎯 學完你會：讓 AI 替沒有編號的資料編號、依序寫入四張表，並檢查自動編號

> 📚 先修：[進階-2 關聯新增](../../SQL語法教學/8新增關聯資料庫資料.md)的「手動指定編號後，自動編號會撞號」。

## 🎬 情境

Excel 寫的是部門和類別的**名稱**，資料表要的是**編號**。AI 要先替它們編號，再把報銷單換成對應的編號。

因為手動指定了編號，還要告訴資料庫接下來從哪裡接著編，這就是 `setval` 的工作。

## 1. 請 AI 產生交易檔

附加 `差旅報銷單.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取第一張報銷清單工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱，不要新增或更改：
（貼上你的四句 CREATE TABLE）

轉換之前，請先檢查：同一個員工編號的姓名和部門、同一個部門的主管是否前後一致。
如果不一致，請列出來問我要以哪個為準，得到我的回答之前不要產生 SQL。

請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT、SELECT setval(...) 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. Excel 沒有部門和類別的編號，請依出現順序從 1 開始編號，並在 INSERT 中明確寫出編號。
3. departments、categories 寫完後，用 setval 和 pg_get_serial_sequence 把兩個自動編號設定成目前的最大值。
4. 寫入順序：departments、categories、employees、claims。
5. 13 張報銷單全部轉換，不可省略，也不可修改內容。

請直接在對話中輸出 SQL 程式碼。不要使用 MCP 或任何工具連線到我的資料庫，我會自己在 DBeaver 檢查後執行。
```

## 2. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 有沒有多餘的動作 | 沒有 `CREATE`、`DROP`、`ALTER`、`TRUNCATE` |
| 寫入順序 | 部門、類別、員工、報銷單 |
| 去除重複 | 部門 4 筆、類別 9 筆、員工 5 筆 |
| 自動編號 | 有兩句 `setval`，分別對應 `departments`、`categories` |

可以和標準答案 [`expense_data.sql`](./expense_data.sql) 對照。編號順序可能不同，只要每個名稱都對應正確即可。

## 3. 匯入資料

確認工具列是 `expense`，按 `Alt + X`（Mac：`Opt + X`）執行整份。`setval` 那兩句會顯示數字 4 和 9，這是正常的。

如果失敗，**先執行 `ROLLBACK;`**，修好問題後再執行一次。

## 4. 和 Excel 對帳

先在報銷清單工作表的空白處輸入公式：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 部門數 | `=SUMPRODUCT(1/COUNTIF(E2:E14,E2:E14))` | 4 |
| 類別數 | `=SUMPRODUCT(1/COUNTIF(G2:G14,G2:G14))` | 9 |
| 員工數 | `=SUMPRODUCT(1/COUNTIF(C2:C14,C2:C14))` | 5 |
| 報銷單數 | `=COUNTA(A2:A14)` | 13 |
| 總金額 | `=SUM(J2:J14)` | 33360 |

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM departments) AS 部門,
       (SELECT COUNT(*) FROM categories) AS 類別,
       (SELECT COUNT(*) FROM employees) AS 員工,
       (SELECT COUNT(*) FROM claims) AS 報銷單,
       (SELECT SUM(amount) FROM claims) AS 總金額;
```

**執行結果**

| 部門 | 類別 | 員工 | 報銷單 | 總金額 |
|---:|---:|---:|---:|---:|
| 4 | 9 | 5 | 13 | 33360.00 |

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `violates foreign key constraint` | 寫入順序錯了，或編號對應錯誤 | 先 `ROLLBACK;`，再請 AI 修正 |
| 匯入成功，之後新增類別出現 `duplicate key ... "categories_pkey"` | AI 漏了 `setval` | 執行下面動手練的修復語法 |
| `column "..." does not exist` | 欄位名稱和 INSERT 不同 | 先 `ROLLBACK;`，再修正欄位名稱 |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`expense_full.sql`](./expense_full.sql)，它會**取代你手寫的表** |

## ✍️ 動手練

**親眼看一次撞號，再修好它。** 先把部門的自動編號改回起點，模擬 AI 忘了寫 `setval`：

```sql
SELECT setval(pg_get_serial_sequence('departments', 'dept_id'), 1, false);

INSERT INTO departments (name, manager_name) VALUES ('測試部', '測試主管');
```

<details>
<summary>看結果和修復方法</summary>

**執行結果**：`duplicate key value violates unique constraint "departments_pkey"`，`Key (dept_id)=(1) already exists`。

資料庫以為下一號是 1，但 1 已經被用掉了。修復方法是把自動編號設定成目前的最大值：

```sql
SELECT setval(pg_get_serial_sequence('departments', 'dept_id'), (SELECT MAX(dept_id) FROM departments));
```

**執行結果**：`4`。之後新增的部門會從 5 開始。這一題只要修好就好，不用真的新增測試部。

</details>

## 🤖 問 AI 助教

> 我執行交易檔時出現這個錯誤：（貼上完整錯誤訊息）。這是我的 CREATE TABLE：（貼上）。請告訴我錯在哪裡、為什麼，由我自己修改。

## ✅ 過關檢查

- [ ] 我執行前檢查過寫入順序和 `setval`
- [ ] 對帳結果是 4、9、5、13、33360
- [ ] 我親眼看過撞號，也把自動編號修回來了

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 4：多表 JOIN 回答故事 ➡️](./4_多表JOIN回答故事.md) |
