## 使用with語法

- `with conn:` 區塊結束時，成功就自動執行 `conn.commit()`，發生錯誤就自動執行 `conn.rollback()`
- `with conn.cursor() as curs:` 區塊結束時，自動執行 `curs.close()`
- ⚠️ **psycopg2 的 `with conn:` 不會關閉連線**，用完要自己執行 `conn.close()`（新版的 psycopg 3 才會自動關閉）

## 執行一個SQL敘述的語法

```python
conn = psycopg2.connect(DSN)

with conn:
    with conn.cursor() as curs:
        curs.execute(SQL)

conn.close()
```

- 內部with程式區塊執行完,自動執行curs.close()
- 外部with程式區塊執行完,如果成功,自動執行conn.commit(),失敗執行conn.rollback()
- with 區塊**不會**自動執行conn.close(),最後要自己關閉


## 執行多個新增,更新,刪除的語法

```python
conn = psycopg2.connect(DSN)

with conn:
    with conn.cursor() as curs:
        curs.execute(SQL1)

with conn:
    with conn.cursor() as curs:
        curs.execute(SQL2)

conn.close()
```

- 同一個連線可以重複使用 `with conn:`，每個區塊是一個獨立的交易(transaction)
- with conn:成功,自動執行conn.commit(),失敗執行conn.rollback(),不會執行conn.close()
- 最後一定要執行conn.close()

> 參考：[psycopg2 官方文件 - with statement](https://www.psycopg.org/docs/usage.html#with-statement)
