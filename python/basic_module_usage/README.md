# 2. Python 操作資料庫基本步驟

Python 操作 PostgreSQL 永遠遵循這五個固定動作：
1. **Connect**：建立連線物件（`conn`）。
2. **Cursor**：建立游標物件（`cur`），用來下達 SQL 指令。
3. **Execute**：執行 SQL 語法（`cur.execute(...)`）。
4. **Fetch**：取出查詢結果（`cur.fetchone()` 取一筆、`cur.fetchall()` 取全部）。
5. **Close**：關閉游標與連線釋放記憶體。

---

## 🤖 自然語言 Prompt：查詢門市銷售範例

我們以先前的 **`cafe_shop`（連鎖咖啡門市）** 為例，直接請 AI 產生查詢程式：

```markdown
我的 PostgreSQL 資料庫 `practice` 內已匯入 `cafe_shop.sql`。

請寫一個 Python 腳本 `get_products.py`：
1. 讀取 `.env` 取得連線。
2. 執行 SQL 查詢 `products` 資料表：找出所有售價大於 100 元的飲品與餐點（商品名稱、售價、成本）。
3. 依售價由高到低排序。
4. 取出所有結果並印在終端機上。
```

---

## 💡 AI 產出的對照程式碼

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

# 1. 建立連線
conn = psycopg2.connect(
    host=os.getenv("DB_HOST", "localhost"),
    dbname=os.getenv("DB_NAME", "practice"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD")
)

# 2. 建立游標
cur = conn.cursor()

# 3. 執行 SQL (查詢售價 > 100 的商品)
sql = """
SELECT name, price, cost 
FROM products 
WHERE price > 100 
ORDER BY price DESC;
"""
cur.execute(sql)

# 4. 取出全部結果 (List of Tuples)
products = cur.fetchall()

print(f"📦 共找到 {len(products)} 筆高單價商品：")
for name, price, cost in products:
    profit = price - cost
    print(f"- {name:<12} 售價: NT${price:>3} (毛利: NT${profit})")

# 5. 關閉釋放資源
cur.close()
conn.close()
```

> 💡 **小結**：你不需要背 `fetchall()` 是什麼，你只要在 Prompt 裡告訴 AI「找出售價大於 100 元並印出來」，AI 就會幫你處理好所有的資料抓取與走訪！
