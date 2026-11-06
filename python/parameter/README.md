# 4. 安全傳遞參數（防範 SQL Injection）

當使用者透過輸入框查詢資料時，**絕對不能使用 Python 的 f-string 或字串相加組裝 SQL**！

```python
# 🚨 極度危險！黑客輸入 " ' OR 1=1; -- " 就能竊取或刪除整個資料庫
bad_sql = f"SELECT * FROM customers WHERE phone = '{user_input}'"
```

正確作法是使用 **參數化查詢（Parameterized Query）**：在 SQL 中使用 `%s` 作為佔位符號，並將實際數值打包成 Tuple 傳給 `cur.execute(sql, (param,))`。

---

## 🤖 自然語言 Prompt：請 AI 寫參數化查詢函式

在請 AI 寫程式時，只要加上這句**「務必使用參數化查詢防止 SQL Injection」**：

```markdown
請幫我寫一個 Python 查詢函式 `search_store_sales.py`：
1. 連線至 `practice` 資料庫的 `cafe_shop`。
2. 撰寫函式 `get_orders_by_store(store_name)`：依門市名稱查詢該店所有的已完成訂單總數與總營業額。
3. 務必使用 `%s` 參數化查詢傳遞門市名稱，嚴禁使用 f-string 拼接 SQL，以確保資安防護。
4. 示範查詢「台北信義店」的營業額結果。
```

---

## 💡 AI 產出的安全程式碼

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

def get_orders_by_store(store_name: str):
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        dbname=os.getenv("DB_NAME", "practice"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD")
    )
    
    with conn:
        with conn.cursor() as cur:
            # 使用 %s 作為佔位符
            sql = """
            SELECT 
                s.name AS 門市,
                COUNT(DISTINCT o.order_id) AS 總訂單數,
                COALESCE(SUM(i.quantity * i.unit_price), 0) AS 總營業額
            FROM stores s
            LEFT JOIN orders o ON s.store_id = o.store_id AND o.status = '已完成'
            LEFT JOIN order_items i ON o.order_id = i.order_id
            WHERE s.name = %s
            GROUP BY s.name;
            """
            # 第二個參數必須是 tuple (注意只有一個參數時要加逗號 (store_name,))
            cur.execute(sql, (store_name,))
            result = cur.fetchone()
            
    conn.close()
    return result

if __name__ == "__main__":
    target = "台北信義店"
    data = get_orders_by_store(target)
    if data:
        print(f"🏬 門市: {data[0]}")
        print(f"📋 總訂單數: {data[1]} 筆")
        print(f"💰 總營業額: NT$ {data[2]:,}")
    else:
        print(f"找不到門市：{target}")
```

> 💡 **關鍵原則**：在 psycopg2 中，無論傳進去的是字串、整數還是日期，SQL 裡**一律寫 `%s`**，psycopg2 會自動幫你做轉義與型別轉換！
