# 5. Python 與 PostgreSQL 型別對照表

當你執行 `cur.fetchone()` 或 `cur.fetchall()` 取出資料時，`psycopg2` 會自動將 PostgreSQL 的資料型別轉換為 Python 對應的原生型別：

| PostgreSQL 資料型別 | Python 資料型別 | 範例資料庫對應欄位 |
|:---|:---|:---|
| `NULL` | `None` | 散客訂單的 `customer_id`、未填電話 |
| `bool` | `bool` (`True` / `False`) | 是否有 YouBike、開關狀態 |
| `smallint`, `integer`, `bigint` | `int` | `order_id`, `quantity`, `price` |
| `real`, `double precision` | `float` | `目前天氣` 的最高溫、最低溫 |
| `numeric`, `decimal` | `decimal.Decimal` | 精確金額、股票價格 |
| `varchar`, `text`, `char` | `str` | `stores.name`, `customers.phone` |
| `date` | `datetime.date` | `order_date`, `hired_on` |
| `time` | `datetime.time` | `order_time` |
| `timestamp`, `timestamptz` | `datetime.datetime` | `目前天氣.啟始時間` |
| `ARRAY` | `list` | 標籤陣列 |
| `json`, `jsonb` | `dict` / `list` | 客製化備註字典 |

---

## 🤖 自然語言 Prompt：請 AI 處理型別轉換與 JSON 匯出

在實務上，從資料庫取出的 `datetime.date` 或 `Decimal` 無法直接 `json.dumps()` 轉成 JSON 字串，只要對 AI 說：

```markdown
請寫一個 Python 腳本 `export_orders_json.py`：
1. 查詢 `cafe_shop` 2024 年 1 月份的最新 5 筆訂單與金額。
2. 取出資料後，將日期轉換為 "YYYY-MM-DD" 字串，金額轉換為浮點數或整數。
3. 輸出為格式美觀的 JSON 檔案 `recent_orders.json`。
```
