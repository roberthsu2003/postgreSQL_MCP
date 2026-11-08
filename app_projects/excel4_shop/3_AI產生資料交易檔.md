# 步驟 3｜AI 產生資料交易檔：價格差異由你判斷

> 💻 AI 對話框 + DBeaver（資料庫：`online_shop`）｜ 🎯 學完你會：告訴 AI 怎麼處理業務規則，並檢查價格有沒有放對位置

> 📚 先修：[專案 3 步驟 3](../excel3_expense/3_AI產生資料交易檔.md)的編號與 `setval`。

## 🎬 情境

這份 Excel 有三個地方，AI 不該自己猜：同一商品有兩種價格、最後兩列沒有訂單、會員沒有編號。這些都是業務判斷，要由你說清楚。

## 1. 請 AI 產生交易檔

附加 `網路商店訂單表.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取「全部訂單」工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱，不要新增或更改：
（貼上你的四句 CREATE TABLE）

轉換之前，請先檢查：同一個商品的單價、同一個信箱的姓名和城市是否前後一致。
如果不一致，請列出來問我如何處理，得到我的回答之前不要產生 SQL。

資料規則：
- 最後兩列沒有訂單編號：一列是尚未賣出的商品，一列是尚未下單的會員。請只寫入 products 或 customers，不要建立訂單。
- 會員用信箱辨識。Excel 沒有會員和商品的編號，請依出現順序從 1 開始編號。

請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT、SELECT setval(...) 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. 寫入順序：customers、products、orders、order_items。
3. customers、products 寫完後，用 setval 和 pg_get_serial_sequence 把兩個自動編號設定成目前的最大值。
4. 10 張訂單和 16 筆明細全部轉換，不可省略。

請直接在對話中輸出 SQL 程式碼。不要使用 MCP 或任何工具連線到我的資料庫，我會自己在 DBeaver 檢查後執行。
```

## 2. 回答 AI 的問題

AI 應該會指出：「保溫鋼杯」有 450 和 490，「無線藍牙耳機」有 1290 和 1190。這是調價，不是錯誤，請回答：

```text
這是商品調價，不是錯誤。
products.price 請用 Excel 中最後一次出現的單價（目前售價）。
order_items.unit_price 請保留每一列當時的單價。
```

> [!WARNING]
> **如果 AI 沒有問，就把所有明細改成同一個價格**，總金額會對不上。這正是下面要對帳的原因。

## 3. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 有沒有多餘的動作 | 沒有 `CREATE`、`DROP`、`ALTER`、`TRUNCATE` |
| 寫入順序 | 會員、商品、訂單、明細 |
| 目前售價 | 保溫鋼杯 490、無線藍牙耳機 1190 |
| 成交單價 | 訂單 1001 的保溫鋼杯仍是 450 |
| 空白列 | 輕量登山背包和張大同有寫入，但沒有產生訂單 |
| 自動編號 | 有兩句 `setval`，分別對應 `customers`、`products` |

可以和標準答案 [`shop_data.sql`](./shop_data.sql) 對照。

## 4. 匯入資料

確認工具列是 `online_shop`，按 `Alt + X`（Mac：`Opt + X`）執行整份。`setval` 那兩句會顯示數字 5 和 7，這是正常的。

如果失敗，**先執行 `ROLLBACK;`**，修好問題後再執行一次。

## 5. 和 Excel 對帳

因為有空白列，不重複計數的公式要多一層判斷。在「全部訂單」工作表的空白處輸入：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 會員數 | `=SUMPRODUCT((G2:G19<>"")/COUNTIF(G2:G19,G2:G19&""))` | 5 |
| 商品數 | `=SUMPRODUCT((I2:I19<>"")/COUNTIF(I2:I19,I2:I19&""))` | 7 |
| 訂單數 | `=SUMPRODUCT((A2:A19<>"")/COUNTIF(A2:A19,A2:A19&""))` | 10 |
| 明細筆數 | `=COUNTA(A2:A19)` | 16 |
| 總金額 | `=SUM(L2:L19)` | 12080 |

再用 SQL 算一次：

```sql
SELECT (SELECT COUNT(*) FROM customers) AS 會員,
       (SELECT COUNT(*) FROM products) AS 商品,
       (SELECT COUNT(*) FROM orders) AS 訂單,
       (SELECT COUNT(*) FROM order_items) AS 明細,
       (SELECT SUM(quantity * unit_price) FROM order_items) AS 總金額;
```

**執行結果**

| 會員 | 商品 | 訂單 | 明細 | 總金額 |
|---:|---:|---:|---:|---:|
| 5 | 7 | 10 | 16 | 12080 |

確認目前售價：

```sql
SELECT name AS 商品, price AS 目前售價
FROM products
ORDER BY product_id;
```

**執行結果**

| 商品 | 目前售價 |
|---|---:|
| 保溫鋼杯 | 490 |
| 快充行動電源 | 890 |
| 人體工學滑鼠墊 | 320 |
| 陶瓷咖啡杯 | 280 |
| 無線藍牙耳機 | 1190 |
| 筆記本組合 | 180 |
| 輕量登山背包 | 1580 |

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| 總金額不是 12080 | AI 把成交單價改成目前售價，或漏了明細 | 檢查訂單 1001、1005 的保溫鋼杯是不是 450 |
| `violates foreign key constraint` | 寫入順序或編號對應錯誤 | 先 `ROLLBACK;`，再請 AI 修正 |
| `null value in column "order_id"` | AI 把空白列當成訂單 | 提醒 AI 最後兩列不要建立訂單 |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`shop_full.sql`](./shop_full.sql)，它會**取代你手寫的表** |

## ✍️ 動手練

**如果把 Excel 的「商品單價」全部放進 `products.price`，只留一個值，少了 `order_items.unit_price`，對帳時會發生什麼事？** 先想一想，再看答案。

<details>
<summary>看答案</summary>

只能用目前售價去算所有訂單。保溫鋼杯在調價前賣出 3 個，每個多算 40 元；藍牙耳機在調價前賣出 2 個，每個少算 100 元。總金額會變成 12080 + 120 - 200 = **12000**，和 Excel 對不上。

</details>

## 🤖 問 AI 助教

> 我執行交易檔時出現這個錯誤：（貼上完整錯誤訊息）。這是我的 CREATE TABLE：（貼上）。請告訴我錯在哪裡、為什麼，由我自己修改。

## ✅ 過關檢查

- [ ] 我自己決定了商品單價差異的處理方式
- [ ] 我確認過目前售價和成交單價都放對位置
- [ ] 對帳結果是 5、7、10、16、12080

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 4：訂單查詢回答故事 ➡️](./4_訂單查詢回答故事.md) |
