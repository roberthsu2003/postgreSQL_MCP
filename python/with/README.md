# 單元 3：with 語法，成功就存檔，失敗就復原

> 🎯 學完你會：用 `with` 管理交易，寫入一半失敗也不會留下爛資料

## 🎬 情境

你寫程式新增會員，顯示成功了，DBeaver 卻看不到。原因：**Python 預設不會自動存檔，少了 `commit()` 就等於沒存。**

而開單同時要寫訂單和明細，如果寫到一半出錯，只存了訂單怎麼辦？

## with 幫你做兩件事

```text
with conn:                       ← 正常結束就 commit，出錯就 rollback
    with conn.cursor() as cur:   ← 結束時自動關閉游標
        cur.execute(...)
```

| 寫法 | 正常結束時 | 出錯時 |
|---|---|---|
| `with conn:` | 自動 `commit()` | 自動 `rollback()` |
| `with conn.cursor() as cur:` | 自動關閉游標 | 自動關閉游標 |

## 範例 1：新增會員

```python
import os
from datetime import date
import psycopg2
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)

with conn:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO customers (name, phone, gender, joined_on)
            VALUES (%s, %s, %s, %s)
            RETURNING customer_id;
            """,
            ("王小明", "0912-345-678", "男", date(2024, 4, 1)),
        )
        new_id = cur.fetchone()[0]
        print(f"🎉 新增成功！會員編號：{new_id}")

conn.close()  # with conn 不會關閉連線，要自己關
```

**執行結果**

```text
🎉 新增成功！會員編號：51
```


> [!WARNING]
> `with conn:` 只管交易，**不會關閉連線**，程式最後還是要 `conn.close()`。這一點和一般的檔案 `with` 不同。

## 範例 2：開單，全有或全無

訂單和明細要一起成功。下面故意讓明細失敗，商品 999 不存在：

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)


def count_orders():
    with conn:
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM orders;")
            return cur.fetchone()[0]


print("開單前訂單數：", count_orders())

try:
    with conn:
        with conn.cursor() as cur:
            # 第一步：新增訂單，用 RETURNING 取得編號
            cur.execute(
                """
                INSERT INTO orders (order_date, order_time, store_id, staff_id, payment_method, status)
                VALUES ('2024-04-01', '10:00', 1, 1, '現金', '已完成')
                RETURNING order_id;
                """
            )
            order_id = cur.fetchone()[0]
            print("訂單寫入了，編號：", order_id)

            # 第二步：新增明細，商品 999 不存在，會出錯
            cur.execute(
                "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (%s, %s, %s, %s);",
                (order_id, 999, 1, 95),
            )
except psycopg2.Error:
    print("❌ 明細寫入失敗，整筆交易自動取消")

print("開單後訂單數：", count_orders())
conn.close()
```

**執行結果**

```text
開單前訂單數： 490
訂單寫入了，編號： 491
❌ 明細寫入失敗，整筆交易自動取消
開單後訂單數： 490
```


訂單數沒有變！第一步雖然成功，也一起被復原了。

## ⚠️ 常見卡關

| 問題 | 原因 | 怎麼解 |
|---|---|---|
| 執行成功，DBeaver 看不到 | 沒有 commit | 用 `with conn:` |
| DBeaver 看不到，但重新查詢就有 | 畫面還沒更新 | 按 `F5` 或重新查詢 |
| `connection already closed` | 太早 `conn.close()` | 確定全部做完才關閉 |
| `current transaction is aborted` | 同一交易出錯後又繼續執行 | 用 `with conn:` 或呼叫 `rollback()` |

## ✍️ 動手練

**第 1 題**：用 `with`，把「蜜香紅茶」的價格改成 55 元，並印出受影響筆數（`cur.rowcount`）。

<details>
<summary>看答案</summary>

```python
import os, psycopg2
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))
with conn:
    with conn.cursor() as cur:
        cur.execute("UPDATE products SET price = %s WHERE name = %s;", (55, "蜜香紅茶"))
        print("受影響筆數：", cur.rowcount)
conn.close()
```

**執行結果**

```text
受影響筆數： 1
```


</details>

**第 2 題**：把範例 2 的商品 999 改成 1，再執行一次。訂單數有什麼變化？

<details>
<summary>看答案</summary>

訂單數會多 1 筆，到 DBeaver 查也看得到，因為 `with conn:` 在成功時自動 commit 了。

</details>

## 🤖 問 AI 助教

> 請檢查我這段程式有沒有正確使用交易：如果第二句 SQL 失敗，第一句會不會被取消？請解釋原因：（貼上你的程式）

## ✅ 過關檢查

- [ ] 我知道 `with conn:` 會自動 commit 和 rollback，但不會關閉連線
- [ ] 我跑過範例 2，親眼看到訂單數沒有增加

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 單元 2 基本步驟](../basic_module_usage/) | [🏠 第 5 章目錄](../) | [單元 4 參數傳遞 ➡️](../parameter/) |
