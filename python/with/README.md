# 3. 使用 with 語法管理交易與資源

在實務開發中，手動寫 `conn.commit()` 或 `cur.close()` 容易遺忘，一旦程式出錯，連線可能卡在未完成的交易中（Transaction Aborted）。

使用 Python 的 **`with` 語法**，能自動幫你做好兩大關鍵保障：
1. **`with conn.cursor() as cur:`**：區塊結束時，**自動關閉游標**。
2. **`with conn:`**：區塊正常跑完，**自動執行 `conn.commit()`**；如果中途發生任何錯誤，**自動執行 `conn.rollback()`** 取消變更！

---

## 🤖 自然語言 Prompt：請 AI 用 with 語法寫程式

告訴 AI 這一句關鍵字即可：

```markdown
請幫我寫一個 Python 腳本 `add_member.py`：
1. 連線至 `practice` 資料庫。
2. 在 `cafe_shop` 的 `customers` 資料表新增一位新會員（姓名: "張小明", 電話: "0912-345-678", 性別: "男", 加入日期: 今天）。
3. 務必使用 `with conn:` 與 `with conn.cursor() as cur:` 語法，確保交易自動提交（commit）並安全釋放游標。
4. 結尾記得呼叫 `conn.close()` 關閉連線。
```

---

## 💡 AI 產出的標準寫法

```python
import os
import psycopg2
from datetime import date
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv("DB_HOST", "localhost"),
    dbname=os.getenv("DB_NAME", "practice"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD")
)

# 使用雙層 with：安全交易 + 自動關閉游標
with conn:
    with conn.cursor() as cur:
        sql = """
        INSERT INTO customers (name, phone, gender, joined_on)
        VALUES (%s, %s, %s, %s)
        RETURNING customer_id;
        """
        cur.execute(sql, ("張小明", "0912-345-678", "男", date.today()))
        new_id = cur.fetchone()[0]
        print(f"🎉 新增成功！新會員編號為：{new_id}")

# 離開 with conn 區塊時，psycopg2 會自動幫你 commit！
# 最後只需關閉連線本體
conn.close()
```

> ⚠️ **重要觀念**：`with conn:` 會自動提交交易，但**不會關閉連線本體**，程式結束前請記得補上 `conn.close()`。
