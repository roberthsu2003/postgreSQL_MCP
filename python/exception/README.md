# 單元 6：例外處理，出錯了也不當機

> ⏱️ **30 分鐘** ｜ 🎯 學完你會：抓住資料庫錯誤、給使用者看得懂的訊息、讓程式繼續運作

## 🎬 情境

店員在你寫的 App 輸入重複的會員電話，畫面瞬間消失，只留下一大串英文。

使用者要看到的是：「**這支電話已經註冊過了**」。

## 1. 基本寫法

下面故意把員工加到不存在的門市 999：

```python
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)
cur = conn.cursor()

try:
    cur.execute(
        "INSERT INTO staff (name, store_id, title, hired_on, salary) VALUES (%s, %s, %s, %s, %s);",
        ("王大明", 999, "正職咖啡師", "2024-03-01", 38000),
    )
    conn.commit()
    print("新增成功！")
except psycopg2.Error as e:
    conn.rollback()  # 一定要復原，連線才能繼續用
    print("錯誤代碼：", e.pgcode)
    print("錯誤訊息：", e.pgerror.split("\n")[0])
finally:
    cur.close()
    conn.close()
```

**執行結果**

```text
錯誤代碼： 23503
錯誤訊息： ERROR:  insert or update on table "staff" violates foreign key constraint "staff_store_id_fkey"
```


| 區塊 | 什麼時候執行 |
|---|---|
| `try` | 放可能出錯的程式 |
| `except` | 出錯時才執行 |
| `finally` | 不管成功失敗，一定執行，適合放關閉連線 |

## 2. 為什麼一定要 rollback

在交易中一旦出錯，連線就進入「中斷」狀態，之後每一句都會失敗：

```python
import os, psycopg2
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))
cur = conn.cursor()

try:
    cur.execute("SELECT * FROM 不存在的表;")
except psycopg2.Error:
    print("第一句出錯了")

try:
    cur.execute("SELECT 1;")
except psycopg2.Error as e:
    print("第二句也失敗：", e.pgerror.split("\n")[0])

conn.rollback()
cur.execute("SELECT 1;")
print("rollback 後恢復正常：", cur.fetchone()[0])

cur.close()
conn.close()
```

**執行結果**

```text
第一句出錯了
第二句也失敗： ERROR:  current transaction is aborted, commands ignored until end of transaction block
rollback 後恢復正常： 1
```


## 3. 依錯誤類型給中文訊息

`psycopg2.errors` 為每種錯誤都準備了類別，寫起來比比對代碼清楚：

```python
import os
import psycopg2
from psycopg2 import errors
from dotenv import load_dotenv

load_dotenv()
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"),
)


def add_customer(name, phone):
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO customers (name, phone, joined_on) VALUES (%s, %s, CURRENT_DATE) RETURNING customer_id;",
                    (name, phone),
                )
                return f"✅ 新增成功，編號 {cur.fetchone()[0]}"
    except errors.UniqueViolation:
        return "⚠️ 這支電話已經註冊過了"
    except errors.NotNullViolation:
        return "⚠️ 姓名是必填欄位"
    except psycopg2.Error as e:
        return f"❌ 資料庫發生錯誤（代碼 {e.pgcode}）"


print(add_customer("新會員", "0900-111-222"))
print(add_customer("重複的人", "0900-111-222"))
print(add_customer(None, "0900-333-444"))
conn.close()
```

**執行結果**

```text
✅ 新增成功，編號 51
⚠️ 這支電話已經註冊過了
⚠️ 姓名是必填欄位
```


## 常見錯誤代碼

| 代碼 | `psycopg2.errors` 類別 | 意思 | 給使用者的訊息 |
|:---:|---|---|---|
| `23503` | `ForeignKeyViolation` | 外來鍵不符 | 「找不到這家門市」 |
| `23505` | `UniqueViolation` | 資料重複 | 「這筆資料已存在」 |
| `23502` | `NotNullViolation` | 必填欄位空白 | 「請填寫必填欄位」 |
| `23514` | `CheckViolation` | 違反規則 | 「金額不可為負數」 |
| `42P01` | `UndefinedTable` | 資料表不存在 | 程式或環境有問題 |
| `42703` | `UndefinedColumn` | 欄位不存在 | 程式有問題 |

> [!TIP]
> **給使用者看中文，給工程師看細節**：畫面上顯示友善訊息，完整錯誤則寫進記錄檔，方便除錯。

## ⚠️ 常見卡關

| 問題 | 原因 | 怎麼解 |
|---|---|---|
| `current transaction is aborted` | 出錯後沒有 rollback | 在 `except` 裡 `conn.rollback()`，或用 `with conn:` |
| `except Exception` 把什麼都吃掉 | 範圍太大，連程式錯誤都蓋掉 | 先抓 `psycopg2.Error` |
| `finally` 裡 `conn.close()` 報錯 | 連線一開始就失敗，`conn` 不存在 | 把 `connect` 放在 `try` 之前 |

## ✍️ 動手練

寫一個函式 `update_price(product_id, new_price)`：
- 成功時回傳「已更新」
- 價格是負數（違反 CHECK）時回傳「價格不可為負數」
- 找不到商品（`rowcount == 0`）時回傳「查無此商品」

<details>
<summary>看答案</summary>

```python
import os, psycopg2
from psycopg2 import errors
from dotenv import load_dotenv
load_dotenv()
conn = psycopg2.connect(host=os.getenv("DB_HOST"), port=os.getenv("DB_PORT"), dbname=os.getenv("DB_NAME"),
                        user=os.getenv("DB_USER"), password=os.getenv("DB_PASSWORD"))


def update_price(product_id, new_price):
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute("UPDATE products SET price = %s WHERE product_id = %s;", (new_price, product_id))
                return "已更新" if cur.rowcount else "查無此商品"
    except errors.CheckViolation:
        return "價格不可為負數"


print(update_price(1, 75))
print(update_price(1, -5))
print(update_price(9999, 75))
conn.close()
```

**執行結果**

```text
已更新
價格不可為負數
查無此商品
```


</details>

## 🤖 問 AI 助教

> 請把這段程式加上例外處理：違反外來鍵、資料重複、必填空白時，分別顯示繁體中文訊息，並確保連線會被關閉：（貼上你的程式）

## ✅ 過關檢查

- [ ] 我知道出錯後要 rollback，也看過不這麼做的後果
- [ ] 我會用 `errors.UniqueViolation` 給使用者中文訊息
- [ ] 回頭用[驗收五問](../#驗收五問)檢查自己寫的程式

> 🎉 **第 5 章完成！** 接著可以 [讓 AI 查詢自己的資料庫](../../mcp_server/)（第 6 章）或 [打造桌面 App](../../app_projects/)（第 7 章）。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 單元 5 型別對照](../type/) | [🏠 第 5 章目錄](../) | [第 6 章 自訂 MCP Server ➡️](../../mcp_server/) |
