## 例外(exception)

```python
import psycopg2

try:
    cur.execute("SELECT * FROM barf")
except psycopg2.Error as e:
    print(e.pgcode)   # 42P01
    print(e.pgerror)  # ERROR:  relation "barf" does not exist
                      # LINE 1: SELECT * FROM barf
    conn.rollback()   # 發生錯誤後要 rollback,這個連線才能繼續執行其它 SQL
```

- `e.pgcode`：PostgreSQL 的錯誤代碼，例如 `42P01` 代表資料表不存在
- `e.pgerror`：PostgreSQL 回傳的錯誤訊息
- 發生錯誤後，同一個交易中後面的 SQL 都會失敗（`current transaction is aborted`），要先 `conn.rollback()`

> 參考：[PostgreSQL 錯誤代碼一覽](https://www.postgresql.org/docs/current/errcodes-appendix.html)
