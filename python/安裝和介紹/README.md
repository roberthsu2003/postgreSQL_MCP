# 單元 1：安裝和環境，密碼不能寫在程式裡

> 🎯 學完你會：安裝套件、用 `.env` 保管密碼、測試連線

## 🎬 情境

同事把程式傳到公司群組，裡面寫著 `password="Admin1234"`。現在全公司都知道資料庫密碼了。

**規則：程式碼可以給別人看，密碼不行。** 密碼要放在另一個不外流的檔案 `.env` 裡。

## 步驟 1：建立專案資料夾和虛擬環境

```bash
mkdir my_cafe && cd my_cafe
uv venv
source .venv/bin/activate      # Windows：.venv\Scripts\activate
uv pip install psycopg2-binary python-dotenv
```

| 套件 | 用途 |
|---|---|
| `psycopg2-binary` | 讓 Python 能連上 PostgreSQL |
| `python-dotenv` | 讀取 `.env` 檔案 |

> [!NOTE]
> 沒有 `uv` 的話，用 `python -m venv .venv` 和 `pip install` 也可以。

## 步驟 2：建立 `.env`

在專案資料夾新增一個名為 `.env` 的檔案：

```ini
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cafe_shop
DB_USER=postgres
DB_PASSWORD=你的密碼
```

樹莓派就把 `DB_HOST` 改成它的 IP；Supabase 就填後台的連線資訊。

## 步驟 3：不讓 `.env` 上傳到 GitHub

建立 `.gitignore`，裡面寫上：

```text
.env
.venv/
```

> [!CAUTION]
> 這一步不能省。密碼一旦上傳到公開的 GitHub，就算事後刪除，也要當作已經外洩，必須更換密碼。

## 步驟 4：測試連線

建立 `test_connect.py`：

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()  # 讀取 .env

try:
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM stores;")
    print(f"✅ 連線成功！共有 {cur.fetchone()[0]} 家門市")
    cur.close()
    conn.close()
except psycopg2.Error as e:
    print(f"❌ 連線失敗，請檢查 .env：{e}")
```

**執行結果**

```text
✅ 連線成功！共有 5 家門市
```


## ⚠️ 常見卡關

| 訊息 | 原因 | 怎麼解 |
|---|---|---|
| `ModuleNotFoundError: No module named 'psycopg2'` | 沒進虛擬環境，或沒裝套件 | 啟動 `.venv`，再裝一次 |
| `password authentication failed` | 密碼錯 | 檢查 `.env`，不用加引號 |
| `connection refused` / `timeout` | 主機或連接埠不對 | 檢查 `DB_HOST`，資料庫有在執行嗎？ |
| `database "cafe_shop" does not exist` | 還沒建立資料庫 | 回 DBeaver 建立並匯入 |
| `relation "stores" does not exist` | 連到別的資料庫 | 檢查 `DB_NAME` |

## 🤖 問 AI 助教

> 我執行 test_connect.py 出現這個錯誤，請告訴我原因和檢查步驟（我已遮掉密碼）：（貼上錯誤訊息）

> [!WARNING]
> 把錯誤訊息或設定貼給 AI 之前，先把密碼遮掉。

## ✅ 過關檢查

- [ ] `test_connect.py` 印出「共有 5 家門市」
- [ ] 程式裡看不到密碼
- [ ] `.gitignore` 裡有 `.env`

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 第 5 章導讀](../) | [🏠 第 5 章目錄](../) | [單元 2 基本步驟 ➡️](../basic_module_usage/) |
