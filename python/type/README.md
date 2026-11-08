# 單元 5：型別對照，資料庫的值到 Python 變成什麼

> 🎯 學完你會：處理日期和金額，把查詢結果輸出成 JSON

## 🎬 情境

王經理要一份 JSON 給系統商。你把查詢結果丟給 `json.dumps()`，卻報錯：

`Object of type date is not JSON serializable`

因為資料庫的日期到了 Python，是 `date` 物件，不是文字。

## 對照表

| PostgreSQL | Python | 本課程的例子 |
|:---|:---|:---|
| `NULL` | `None` | 散客的 `customer_id` |
| `boolean` | `bool` | `is_late` |
| `integer` | `int` | `quantity`、`price` |
| `real` | `float` | 天氣的最高溫度 |
| `numeric` | `decimal.Decimal` | 報銷金額 `amount` |
| `varchar`、`text` | `str` | `name`、`phone` |
| `date` | `datetime.date` | `order_date` |
| `time` | `datetime.time` | `order_time` |
| `timestamptz` | `datetime.datetime` | 打卡時間 `clock_in` |
| `jsonb` | `dict` 或 `list` | 飲料客製化 |

## 1. 親眼看一下

```python
import os, psycopg2
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))
cur = conn.cursor()
cur.execute("""
    SELECT order_id, order_date, order_time, customer_id, payment_method
    FROM orders
    WHERE customer_id IS NULL
    ORDER BY order_id
    LIMIT 1;
""")
for column, value in zip([d[0] for d in cur.description], cur.fetchone()):
    print(f"{column:15} {type(value).__name__:10} {value}")
cur.close()
conn.close()
```

**執行結果**

```text
order_id        int        5
order_date      date       2024-01-29
order_time      time       09:19:00
customer_id     NoneType   None
payment_method  str        現金
```


## 2. 金額的 Decimal

平均值和 `numeric` 欄位會是 `Decimal`。它很精準，計算時不要和 `float` 混用：

```python
import os, psycopg2
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))
cur = conn.cursor()
cur.execute("SELECT ROUND(AVG(price), 2) FROM products;")
avg = cur.fetchone()[0]
print(type(avg).__name__, avg)
print(f"顯示千分位：{avg:,.2f}")
print(f"要給只收數字的系統：{float(avg)}")
cur.close()
conn.close()
```

**執行結果**

```text
Decimal 93.06
顯示千分位：93.06
要給只收數字的系統：93.06
```


## 3. 輸出成 JSON

`default=str` 會把 JSON 不認識的型別（日期、Decimal）轉成文字；`ensure_ascii=False` 讓中文正常顯示：

```python
import json
import os
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)

# RealDictCursor：每一列變成字典，可以用欄位名稱取值
with conn:
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("""
            SELECT o.order_id, o.order_date, s.name AS store
            FROM orders o
            JOIN stores s ON o.store_id = s.store_id
            ORDER BY o.order_date, o.order_id
            LIMIT 2;
        """)
        rows = cur.fetchall()
conn.close()

print(json.dumps(rows, ensure_ascii=False, indent=2, default=str))
```

**執行結果**

```text
[
  {
    "order_id": 29,
    "order_date": "2024-01-01",
    "store": "台中逢甲店"
  },
  {
    "order_id": 38,
    "order_date": "2024-01-01",
    "store": "台北車站店"
  }
]
```


> [!TIP]
> `RealDictCursor` 很實用：`row["store"]` 比 `row[2]` 好讀，欄位順序改了也不會出錯。

## ⚠️ 常見卡關

| 錯誤 | 原因 | 怎麼解 |
|---|---|---|
| `Object of type date is not JSON serializable` | JSON 不認識日期 | `json.dumps(x, default=str)` |
| `Object of type Decimal is not JSON serializable` | JSON 不認識 Decimal | `default=str` 或 `float(x)` |
| `unsupported operand type(s) for +: 'decimal.Decimal' and 'float'` | Decimal 和 float 混用 | 全部轉成同一型別 |
| `'NoneType' ...` | 值是 `NULL` | 先判斷 `if value is not None` |

## ✍️ 動手練

**第 1 題**：查詢最近一筆訂單的日期，用 `.strftime("%Y/%m/%d")` 印成 `2024/03/31` 的格式。

<details>
<summary>看答案</summary>

```python
import os, psycopg2
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))
cur = conn.cursor()
cur.execute("SELECT MAX(order_date) FROM orders;")
print(cur.fetchone()[0].strftime("%Y/%m/%d"))
cur.close()
conn.close()
```

**執行結果**

```text
2024/03/31
```


</details>

## 🤖 問 AI 助教

> 我要把 cafe_shop 2024 年 1 月前 5 筆訂單和金額輸出成 recent_orders.json。日期要是 YYYY-MM-DD，金額要是數字，中文不能變亂碼。SQL 我自己寫：（貼上 SQL），請幫我寫 Python 的部分，並說明你怎麼處理型別。

## ✅ 過關檢查

- [ ] 我知道日期到 Python 是 `date`，`NULL` 是 `None`
- [ ] 我會用 `default=str` 和 `ensure_ascii=False` 輸出 JSON

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 單元 4 參數傳遞](../parameter/) | [🏠 第 5 章目錄](../) | [單元 6 例外處理 ➡️](../exception/) |
