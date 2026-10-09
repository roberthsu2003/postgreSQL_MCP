## 如何將python資料傳遞至SQL內
- 使用%s
- 使用tuple或list

```sql
-- sql
INSERT INTO some_table (an_int, a_date, a_string)
VALUES (10, '2005-11-18', 'O''Reilly');
```

```python
# python
import datetime

cur.execute("""
    INSERT INTO some_table (an_int, a_date, a_string)
    VALUES (%s, %s, %s);
    """,
    (10, datetime.date(2005, 11, 18), "O'Reilly"))
```

- 字串裡的單引號(O'Reilly)會由 psycopg2 自動處理,不需要自己寫成 `O''Reilly`
- 只有一個參數時,tuple 要寫成 `(value,)`,逗號不能省略
- ⚠️ 不可以用 f-string 或 `+` 把值直接組進 SQL,會有 SQL Injection 的風險


- 使用%(key)s
- 使用dictionary
- 同一個值要用很多次時,用名稱比較方便


```sql
-- sql
INSERT INTO some_table (an_int, a_date, another_date, a_string)
VALUES (10, '2005-11-18', '2005-11-18', 'O''Reilly');
```

```python
# python
cur.execute("""
    INSERT INTO some_table (an_int, a_date, another_date, a_string)
    VALUES (%(int)s, %(date)s, %(date)s, %(str)s);
    """,
    {'int': 10, 'str': "O'Reilly", 'date': datetime.date(2005, 11, 18)})
```
