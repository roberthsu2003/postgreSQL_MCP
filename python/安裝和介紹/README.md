# 1. 安裝與環境準備

在 Python 中連接 PostgreSQL 最通用的套件是 **`psycopg2`**，搭配 **`python-dotenv`** 用來安全保管資料庫密碼。

---

## 1. 安裝必要套件

在終端機中執行：

```bash
pip install psycopg2-binary python-dotenv
```

> 💡 **初學者推薦**：使用 `psycopg2-binary`，它已經預編譯好 C 函式庫，免去本地端編譯安裝的繁瑣問題。

---

## 2. 安全原則：使用 `.env` 保管密碼

千萬不要把資料庫帳號密碼寫死在 Python 程式碼中！請在專案根目錄建立一個 `.env` 檔案：

```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=practice
DB_USER=postgres
DB_PASSWORD=你的密碼
```

---

## 3. 🤖 請 AI 產生連線測試程式 (Prompt)

把以下這段自然語言複製給 AI，AI 就會為你寫出專業且安全的連線測試檔：

```markdown
請幫我寫一個 Python 腳本 `test_connect.py`：
1. 使用 `dotenv` 讀取 `.env` 內的資料庫連線參數。
2. 使用 `psycopg2` 連線到 PostgreSQL 資料庫。
3. 執行 `SELECT version();` 查詢資料庫版本，成功連線則印出「✅ 連線成功！資料庫版本：...」。
4. 若連線失敗，請用 try...except 捕獲錯誤並提示使用者檢查密碼或主機位址。
5. 連線結束後記得關閉連線。
```

### 💡 AI 會為你產出如下的簡潔程式碼：

```python
import os
import psycopg2
from dotenv import load_dotenv

# 讀取 .env 檔案
load_dotenv()

try:
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "practice"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD")
    )
    cur = conn.cursor()
    cur.execute("SELECT version();")
    db_version = cur.fetchone()
    print("✅ 資料庫連線成功！")
    print(f"PostgreSQL 版本：{db_version[0]}")
    
    cur.close()
    conn.close()
except Exception as e:
    print(f"❌ 連線失敗，請檢查 .env 設定：{e}")
```
