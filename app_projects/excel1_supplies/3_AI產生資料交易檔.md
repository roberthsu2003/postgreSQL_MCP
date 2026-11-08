# 步驟 3｜AI 產生資料交易檔：表是你蓋的，資料讓 AI 轉

> 💻 AI 對話框 + DBeaver（資料庫：`supplies`）｜ 🎯 學完你會：請 AI 依照你的結構產生 INSERT，匯入後和 Excel 對帳

> 📚 先修：[DML-3 修改與刪除的交易](../../SQL語法教學/5修改和刪除.md)。語法細節請回章節複習，這裡把它用在真實的 Excel 上。

## 🎬 情境

資料表蓋好了，但裡面是空的。25 筆資料一筆一筆打太慢，這種機械式的轉換正好交給 AI。

重點是：**把你手寫的 `CREATE TABLE` 一起給 AI**。這樣它才會照你的欄位名稱產生資料，而不是自己另外設計一套。

## 1. 什麼是交易檔

交易（transaction）就是「要嘛全部成功，要嘛全部不算」：

```sql
BEGIN;     -- 開始
INSERT ...;
COMMIT;    -- 全部沒問題，正式寫入
```

中間只要有一筆失敗，整份都不會寫入，不會留下只匯入一半的資料。

## 2. 請 AI 產生交易檔

開啟 AI 對話框，附加 `耗材庫存表.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取「耗材庫存」工作表。

這是我親手建立的資料表，請嚴格依照它的欄位名稱，不要新增或更改欄位：
（貼上你的 CREATE TABLE）

請產生一份資料交易檔：
1. 只能有 BEGIN; 一句 INSERT INTO ... VALUES; 和 COMMIT;，不要 CREATE、DROP 或 ALTER。
2. INSERT 要明確寫出欄位名稱。
3. 25 筆資料全部轉換，不可省略，也不可修改內容。空白的儲存格請寫 NULL。
4. 日期請用 'YYYY-MM-DD' 格式。
5. 如果有主鍵是 SERIAL 且你指定了編號，請在 COMMIT 前加上 setval，讓下一筆的編號正確。

請直接在對話中輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 3. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 有沒有多餘的動作 | 沒有 `CREATE`、`DROP`、`ALTER` |
| 欄位名稱 | 和你的資料表完全相同 |
| 資料筆數 | 第一筆是 `MAT-P-A470`，最後一筆是 `CLN-WIPE-80`，沒有「以下省略」 |

> [!WARNING]
> **AI 給的 SQL，一定要看過才執行。** 特別是 `DROP`，它會把你親手建的表刪掉。

如果 AI 的結果怪怪的，可以和標準答案 [`supplies_data.sql`](./supplies_data.sql) 對照。

## 4. 匯入資料

把 SQL 貼到 DBeaver，確認工具列是 `supplies`，按 `Alt + X`（Mac：`Opt + X`）執行整份。

如果執行失敗，**先執行 `ROLLBACK;`**，讀懂錯誤訊息、修好問題後再執行一次。

## 5. 和 Excel 對帳

資料進來不代表資料正確。先在 Excel 空白處輸入公式，算出正確答案：

| 項目 | Excel 公式（在「耗材庫存」工作表） | 答案 |
|---|---|---:|
| 品項數 | `=COUNTA(A2:A26)` | 25 |
| 總庫存量 | `=SUM(G2:G26)` | 546 |
| 庫存總金額 | `=SUMPRODUCT(F2:F26,G2:G26)` | 66474 |

> [!NOTE]
> `SUM` 就是 Excel 的 SUM，`COUNT` 是算筆數。這裡只算一個總數，要依門市、月份分組統計時，[進階-4](../../SQL語法教學/10聚合函式.md)會完整教。

再用 SQL 算一次：

```sql
SELECT COUNT(*) AS 品項數,
       SUM(current_stock) AS 總庫存量,
       SUM(unit_price * current_stock) AS 庫存總金額
FROM supplies;
```

**執行結果**

| 品項數 | 總庫存量 | 庫存總金額 |
|---:|---:|---:|
| 25 | 546 | 66474 |

三個數字都相同，才算匯入成功。

## 6. AI 轉資料的界線

| 狀況 | 建議做法 |
|---|---|
| 幾十筆、內容不敏感 | 可以請 AI 直接轉成 INSERT |
| 資料有客戶姓名、電話、薪資 | 先脫敏，例如改成假名，再給 AI |
| 上千筆，或每月都有新檔案 | AI 只看 10～20 筆樣本寫語法，真實資料用 CSV 匯入（專案 8 會教） |

資料量越大，AI 越容易漏列或輸出到一半就截斷，所以對帳這一步不能省。

## ⚠️ 常見卡關

| 錯誤訊息 | 原因 | 怎麼解 |
|---|---|---|
| `column "..." of relation "supplies" does not exist` | 你的欄位名稱和 INSERT 不同 | 先 `ROLLBACK;`，再用 `ALTER TABLE ... RENAME COLUMN` 修正 |
| `duplicate key value violates unique constraint` | 測試資料沒清，或這份已經匯入過 | 先 `ROLLBACK;`，查 `SELECT COUNT(*) FROM supplies;`，已經是 25 筆就不用再匯入 |
| `current transaction is aborted` | 前一步失敗，交易還沒結束 | 先執行 `ROLLBACK;` |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`supplies_full.sql`](./supplies_full.sql)，它會**取代你手寫的表** |

## ✍️ 動手練

**體驗一次「結構寫錯時的保護」**：這一題會暫時改壞結構。先清空資料，把欄位 `location` 改名，再執行交易檔，看看會發生什麼事。

```sql
TRUNCATE supplies;
ALTER TABLE supplies RENAME COLUMN location TO place;
```

接著用 `Alt + X` 執行 [`supplies_data.sql`](./supplies_data.sql)，然後：

```sql
ROLLBACK;
SELECT COUNT(*) FROM supplies;
```

<details>
<summary>看答案</summary>

執行時會出現 `column "location" of relation "supplies" does not exist`，`COUNT(*)` 回傳 **0**。整份都沒有寫入，沒有留下半套資料。

記得把結構改回來，再匯入一次：

```sql
ALTER TABLE supplies RENAME COLUMN place TO location;
```

重新執行交易檔後，再跑一次對帳查詢，應該回到 25、546、66474。

</details>

## 🤖 問 AI 助教

> 我執行交易檔時出現這個錯誤：（貼上完整錯誤訊息）。這是我的 CREATE TABLE：（貼上）。請告訴我錯在哪裡、為什麼，由我自己修改。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 專案說明](./README.md) | [步驟 4：DML 回答故事 ➡️](./4_DML回答故事.md) |
