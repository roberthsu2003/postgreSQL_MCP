## 安裝和介紹

### 安裝

```bash
pip install -U pip
pip install psycopg2-binary
```


### 使用

```python
import psycopg2

# 連線postgres DB
conn = psycopg2.connect("dbname=test user=postgres")

# 建立cursor實體以便於執行SQL語言
cur = conn.cursor()

# 執行SQL
cur.execute("SELECT * FROM my_data")

# 取出結果
records = cur.fetchall()

# 用完要關閉
cur.close()
conn.close()
```