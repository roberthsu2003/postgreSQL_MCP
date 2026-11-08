# 步驟 3｜AI 產生匯入腳本：真實資料留在自己手上

> 💻 DBeaver + AI 對話框（資料庫：`store_sales`）｜ 🎯 學完你會：匯入大量 CSV，請 AI 只看樣本寫語法，並驗收匯入結果

> 📚 先修：[DDL-4 匯入 CSV](../../SQL語法教學/2_1匯入csv.md)。

## 🎬 情境

前四個專案，AI 都是把資料一筆一筆轉成 INSERT。這次有 782 筆，而且真實工作中的銷售資料不該整份上傳。所以這次分工不同：

| | 誰做 | 資料有沒有交給 AI |
|---|---|---|
| CSV 匯入暫存表 | 你，用 DBeaver | 沒有 |
| 寫 `INSERT ... SELECT` 語法 | AI | 只有 21 列樣本 |
| 執行與對帳 | 你 | 沒有 |

## 1. 把 CSV 匯入暫存表

1. 在左側 `raw_sales` 上按右鍵 → **Import Data**
2. 選 **CSV** → **Next** → 選取 [`門市銷售明細_2024Q1_全部.csv`](../../範例資料庫/excel範例/連鎖門市月報表/門市銷售明細_2024Q1_全部.csv)
3. 設定 **Encoding** 為 `UTF-8`、**Column delimiter** 為 `,`、**Header** 為 `top`
4. 確認每一欄都對應到同名欄位，按 **Proceed**

檢查筆數和金額：

```sql
SELECT COUNT(*) AS 筆數, SUM(小計::INT) AS 總金額
FROM raw_sales;
```

**執行結果**

| 筆數 | 總金額 |
|---:|---:|
| 782 | 97655 |

`::INT` 是把文字轉成整數，因為暫存表的欄位都是 `TEXT`。

## 2. 請 AI 寫匯入腳本

把 [`門市月報_需求與樣本.xlsx`](./門市月報_需求與樣本.xlsx) 的「給AI的樣本」工作表另存成 CSV 或直接貼上，連同以下提示詞交給 AI：

```text
你是 PostgreSQL 教學助教。附件是銷售資料的樣本，真實資料已經在我的暫存表 raw_sales 裡，不需要你轉換資料內容。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱，不要新增或更改：
（貼上你的七句 CREATE TABLE）

請寫一份匯入腳本，把 raw_sales 的資料放進六張正式表：
1. 用 BEGIN; 開始、COMMIT; 結束，裡面只能有 INSERT INTO ... SELECT ...，不要 CREATE、DROP、ALTER、TRUNCATE、UPDATE 或 DELETE，也不要寫死任何資料內容。
2. 寫入順序：stores、staff、products、customers、orders、order_items。
3. raw_sales 全部是 TEXT，寫入時請轉成正式表的型別。
4. 會員用電話辨識，同名不同電話是不同的人。會員電話可能是 NULL 或空字串，這些是散客，不要寫入 customers，訂單的 customer_id 要是 NULL。
5. 店員用「姓名加門市」辨識。
6. 訂單表每張訂單只能有一筆，請去除重複。
7. 這份腳本每個月都要重複使用，每句 INSERT 都要用 ON CONFLICT DO NOTHING，同一份資料重複執行不能增加筆數。

請直接在對話中輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 3. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 有沒有多餘的動作 | 沒有 `CREATE`、`DROP`、`ALTER`、`TRUNCATE`、`UPDATE`、`DELETE` |
| 沒有寫死資料 | 沒有 `VALUES` 和樣本裡的人名、單號 |
| 去除重複 | `stores`、`staff`、`products`、`customers`、`orders` 都有 `DISTINCT` |
| 散客 | 訂單用 `LEFT JOIN customers`，不是 `JOIN` |
| 重複執行 | 六句 INSERT 都有 `ON CONFLICT` |

可以和標準答案 [`store_data.sql`](./store_data.sql) 對照。

> [!WARNING]
> 訂單如果用 `JOIN customers`，散客的 154 張訂單會全部消失，而且**不會有任何錯誤訊息**。這種錯誤只有對帳才抓得到。

## 4. 執行匯入腳本

確認工具列是 `store_sales`，按 `Alt + X`（Mac：`Opt + X`）執行整份。如果失敗，**先執行 `ROLLBACK;`**，修好問題後再執行一次。

因為這次的編號都由資料庫自動產生，不像專案 4、5 手動指定編號，所以**不需要 `setval`**。

## 5. 和 Excel 對帳

用 Excel 打開第一季 CSV，在空白處輸入公式：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 明細筆數 | `=COUNTA(A2:A783)` | 782 |
| 訂單數 | `=SUMPRODUCT(1/COUNTIF(A2:A783,A2:A783))` | 490 |
| 會員數 | `=SUMPRODUCT((H2:H783<>"")/COUNTIF(H2:H783,H2:H783&""))` | 50 |
| 總金額 | `=SUM(M2:M783)` | 97655 |
| 已完成金額 | `=SUMIF(O2:O783,"已完成",M2:M783)` | 80985 |

> [!TIP]
> 只在 Excel 檢查就好，關閉時選擇不要儲存，避免 Excel 改掉 CSV 的格式。

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM stores) AS 門市,
       (SELECT COUNT(*) FROM staff) AS 店員,
       (SELECT COUNT(*) FROM products) AS 商品,
       (SELECT COUNT(*) FROM customers) AS 會員,
       (SELECT COUNT(*) FROM orders) AS 訂單,
       (SELECT COUNT(*) FROM order_items) AS 明細,
       (SELECT SUM(quantity * unit_price) FROM order_items) AS 總金額;
```

**執行結果**

| 門市 | 店員 | 商品 | 會員 | 訂單 | 明細 | 總金額 |
|---:|---:|---:|---:|---:|---:|---:|
| 5 | 12 | 18 | 50 | 490 | 782 | 97655 |

已完成金額，以及散客和會員的訂單數：

```sql
SELECT SUM(oi.quantity * oi.unit_price) AS 已完成金額
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = '已完成';

SELECT COUNT(*) FILTER (WHERE customer_id IS NULL) AS 散客訂單,
       COUNT(customer_id) AS 會員訂單
FROM orders;
```

**執行結果**：已完成金額 `80985`；散客訂單 `154`、會員訂單 `336`，合計 490。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| 匯入時中文變亂碼 | 編碼不對 | Encoding 改選 `UTF-8` 或 `Big5` |
| 第一欄沒有對應到 | 檔案開頭的 BOM 字元 | 在欄位對應畫面手動對應第一欄 |
| 訂單少於 490 | 用了 `JOIN customers`，散客被濾掉 | 改成 `LEFT JOIN`，清空六張表後重新執行 |
| 會員變成 51 | 把「散客」也寫入了 | 加上排除空白電話的條件 |
| `there is no unique or exclusion constraint matching the ON CONFLICT` | `ON CONFLICT` 的欄位沒有對應的 `UNIQUE` | 確認資料表有對應的限制 |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`store_full.sql`](./store_full.sql)，它會**取代你手寫的表** |

## ✍️ 動手練

**看看一筆壞資料會發生什麼事。** 先把正式表清空，再放一筆日期錯誤的資料到暫存表：

```sql
TRUNCATE order_items, orders, customers, products, staff, stores RESTART IDENTITY;

INSERT INTO raw_sales (銷售單號, 銷售日期, 時間, 門市名稱, 區域, 經手店員, 商品分類, 商品名稱, 單價, 數量, 小計, 付款方式, 狀態)
VALUES ('ORD09999', '2024-13-45', '10:00', '台北信義店', '北部', '張志明', '義式咖啡', '經典拿鐵', '95', '1', '95', '現金', '已完成');
```

接著執行匯入腳本，然後：

```sql
ROLLBACK;
SELECT (SELECT COUNT(*) FROM stores) AS 門市, (SELECT COUNT(*) FROM orders) AS 訂單;
```

<details>
<summary>看結果和修復方法</summary>

**執行結果**：`date/time field value out of range: "2024-13-45"`，門市和訂單都是 **0**。

暫存表什麼都收，但轉換成 `DATE` 時就被抓到了，而且交易讓整份匯入都不算數。把壞資料刪掉，再執行一次匯入腳本：

```sql
DELETE FROM raw_sales WHERE 銷售單號 = 'ORD09999';
```

再跑一次對帳查詢，應該回到 5、12、18、50、490、782、97655。

</details>

## 🤖 問 AI 助教

> 我執行匯入腳本時出現這個錯誤：（貼上完整錯誤訊息）。這是我的 CREATE TABLE 和腳本：（貼上）。請告訴我錯在哪裡、為什麼，由我自己修改。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 4：報表回答故事 ➡️](./4_報表回答故事.md) |
