# 6. 例外處理（Exception Handling）

當 SQL 語法錯誤、資料表不存在、或違反外來鍵限制（例如：新增員工時指定了不存在的門市 ID）時，`psycopg2` 會拋出例外。

在同一個連線中，一旦發生錯誤，PostgreSQL 會將交易標記為 **中斷狀態（current transaction is aborted）**。**此時必須執行 `conn.rollback()`**，否則該連線後續執行的所有 SQL 都會直接報錯失敗！

---

## 🤖 自然語言 Prompt：請 AI 加上完整錯誤處理

告訴 AI 這一句關鍵字：

```markdown
請幫我寫一個 Python 腳本 `safe_insert_staff.py`：
1. 嘗試在 `cafe_shop` 的 `staff` 資料表新增一位員工，所屬門市設定為不存在的門市編號 `store_id = 999`。
2. 使用 `try ... except psycopg2.Error as e:` 捕獲資料庫錯誤。
3. 發生錯誤時，印出具體的錯誤代碼 `e.pgcode` 與訊息 `e.pgerror`，並務必執行 `conn.rollback()` 回復交易。
4. 在 finally 區塊確保連線安全關閉。
```

---

## 💡 AI 產出的例外處理標準範本

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv("DB_HOST", "localhost"),
    dbname=os.getenv("DB_NAME", "practice"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD")
)

cur = conn.cursor()

try:
    # 刻意插入一個不存在的門市 store_id=999 (違反外來鍵 ForeignKey 約束)
    sql = """
    INSERT INTO staff (name, store_id, title, hired_on, salary)
    VALUES (%s, %s, %s, %s, %s);
    """
    cur.execute(sql, ("王大明", 999, "正職咖啡師", "2024-03-01", 38000))
    conn.commit()
    print("新增成功！")
    
except psycopg2.Error as e:
    print("🚨 資料庫操作失敗！")
    print(f"錯誤代碼 (pgcode) : {e.pgcode}")
    print(f"錯誤訊息 (pgerror): {e.pgerror.strip()}")
    
    # ⚠️ 關鍵動作：發生錯誤一定要 rollback，連線才能恢復正常
    conn.rollback()
    print("🔄 已自動 rollback 回復交易狀態。")
    
finally:
    cur.close()
    conn.close()
```

> 💡 **常見的 PostgreSQL 錯誤代碼**：
> - `23503` (foreign_key_violation)：違反外來鍵（參考的資料不存在）。
> - `23505` (unique_violation)：違反唯一性限制（例如新增了重複的會員電話）。
> - `42P01` (undefined_table)：資料表名稱打錯，不存在。
