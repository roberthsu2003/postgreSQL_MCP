# DML 導讀：倉庫蓋好了，開始進出貨

> ⏱️ **10 分鐘** ｜ 💻 DBeaver ｜ 🎯 先把環境準備好，後面的課才跑得動

## 一句話看懂

DDL 蓋好倉庫，**DML 負責每天的進出貨**。四個動作對應 Excel 的日常操作：

| SQL | 白話 | Excel 裡的你 | 例子 |
|---|---|---|---|
| `INSERT` | 新增 | 在最下面打一列新資料 | 開了新門市 |
| `SELECT` | 查詢 | 篩選、排序、看報表 | 找出高價商品 |
| `UPDATE` | 修改 | 改儲存格 | 商品調價 |
| `DELETE` | 刪除 | 刪掉整列 | 商品下架 |

> [!NOTE]
> 有些書把 `SELECT` 單獨歸類為 DQL（資料查詢語言）。名字不重要，會用才重要。

## ⚙️ 開工前準備：匯入 `cafe_shop`

後面要用**真實規模的資料**練習，請匯入連鎖咖啡範例：7 張表、490 筆訂單、782 筆明細。

1. 在 DBeaver 建立新資料庫 `cafe_shop`（方法同 [DDL-1](./1建立資料庫.md)）
2. **File → Open File** 開啟 [`cafe_shop.sql`](../範例資料庫/中文範例資料庫/cafe_shop.sql)
3. 工具列切換到 `cafe_shop` 資料庫，按 `Alt + X`（Mac：`Opt + X`）執行整個檔案
4. 跑下面這句確認：

```sql
SELECT
    (SELECT COUNT(*) FROM stores)      AS 門市,
    (SELECT COUNT(*) FROM products)    AS 商品,
    (SELECT COUNT(*) FROM customers)   AS 會員,
    (SELECT COUNT(*) FROM orders)      AS 訂單,
    (SELECT COUNT(*) FROM order_items) AS 明細;
```

**執行結果**

| 門市 | 商品 | 會員 | 訂單 | 明細 |
|---:|---:|---:|---:|---:|
| 5 | 18 | 50 | 490 | 782 |

數字一樣就成功了。

> [!IMPORTANT]
> **一個範例庫放一個資料庫**。`cafe_shop` 和 `shop` 有同名的表（`orders`、`products`…），匯入同一個資料庫時，後者會**直接蓋掉**前者。所以資料庫名稱請和檔名相同。

> [!TIP]
> **把資料改壞了也不怕**：重新執行一次 `cafe_shop.sql`，資料就恢復原狀了。放心練習！

## 本段用到哪個資料庫？

| 課程 | 資料庫 | 為什麼 |
|---|---|---|
| DML-1 新增 | `cafe_db` | 接續自己建的 `stores` 表 |
| DML-2 查詢 | `cafe_shop` | 資料夠多才查得出東西 |
| DML-3 修改與刪除 | `cafe_shop` | 改壞了可以重匯 |
| DML-4 外來鍵 | `cafe_db` 加其他範例庫 | 自己建小表，再看真實資料 |
| DML-5 JOIN | `cafe_db` 加 `cafe_shop` | 先看小例子，再做真題 |
| DML-6 JSON | `cafe_db` | 自己建小表 |

## 🤖 問 AI 助教

> 請用人資打卡紀錄當例子，說明 SELECT、INSERT、UPDATE、DELETE 分別會在什麼情境用到。請只給我 SQL 和說明，我會自己在 DBeaver 執行。另外提醒我 UPDATE 和 DELETE 最容易犯什麼錯。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ DDL-5 限制條件](./4限制.md) | [🏠 第 4 章目錄](./README.md) | [DML-1 新增資料 ➡️](./3新增資料.md) |
