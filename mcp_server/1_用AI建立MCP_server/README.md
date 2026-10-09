# 單元 1：用 AI 建立自己的 MCP Server

> **本單元目標**：不用自己寫程式，**請 AI 寫出**一個查詢台鐵進出站資料的 MCP Server，並接上 Claude Desktop。
> 你的角色是**需求設計者**和**驗收者**。

## 目錄

- [為什麼要自己建立 MCP Server？](#為什麼要自己建立-mcp-server)
- [事前準備](#事前準備)
- [步驟 1：規劃工具](#步驟-1規劃工具)
- [步驟 2：請 AI 寫程式](#步驟-2請-ai-寫程式)
- [步驟 3：看懂 AI 寫的程式](#步驟-3看懂-ai-寫的程式)
- [步驟 4：用 MCP Inspector 測試](#步驟-4用-mcp-inspector-測試)
- [步驟 5：接上 Claude Desktop](#步驟-5接上-claude-desktop)
- [步驟 6：請 AI 修改和除錯](#步驟-6請-ai-修改和除錯)
- [實作練習](#實作練習)

### 整體流程

```mermaid
flowchart LR
    S1["<b>1 規劃工具</b><br/>使用者會問什麼？"]
    S2["<b>2 請 AI 寫程式</b><br/>提示詞範本"]
    S3["<b>3 看懂程式</b><br/>5 項檢查清單"]
    S4["<b>4 測試</b><br/>MCP Inspector"]
    S5["<b>5 接上</b><br/>Claude Desktop"]
    S6["<b>6 請 AI<br/>修改、除錯</b>"]
    S1 --> S2 --> S3 --> S4 --> S5
    S3 -. 不符合規定 .-> S6
    S4 -. 出現錯誤 .-> S6
    S5 -. AI 選錯工具 .-> S6
    S6 -.-> S3

    classDef you fill:#f0fdfa,stroke:#0f766e,color:#134e4a
    classDef ai fill:#f5f3ff,stroke:#7c3aed,color:#4c1d95
    class S1,S3,S4,S5 you
    class S2,S6 ai
```

<sub>綠色：你負責　紫色：交給 AI</sub>

---

## 為什麼要自己建立 MCP Server？

[第 5 章的 Postgres MCP Pro](../../MCP操作資料庫/1_postgres_mcp_pro/) 把**整個資料庫**交給 AI，AI 可以自己寫任何 SQL。
自己建立的 MCP Server 則只提供**你設計好的幾個工具**，AI 只能呼叫這些工具。

| | Postgres MCP Pro（別人寫的） | 自建 MCP Server |
|---|---|---|
| AI 能做的事 | 任何 SQL | 只有你設計好的工具 |
| 安全性 | 靠 access mode 控制 | 只能執行寫好的 SQL，範圍最小 |
| 準確度 | AI 要先了解資料表才能寫 SQL，可能寫錯 | 查詢邏輯已經寫好，結果穩定 |
| 適合 | 工程師探索資料、開發、調校效能 | **給一般員工使用、特定業務查詢** |

```mermaid
flowchart LR
    subgraph B["自建 MCP Server"]
        direction LR
        AI2["AI"] --> T1["search_stations"] --> DB2[("資料庫")]
        AI2 --> T2["get_station_traffic"] --> DB2
        AI2 --> T3["top_stations"] --> DB2
    end
    subgraph A["Postgres MCP Pro"]
        direction LR
        AI1["AI"] -->|"自己寫的任何 SQL"| DB1[("整個資料庫")]
    end

    classDef tool fill:#eff6ff,stroke:#2563eb,color:#1e3a8a
    class T1,T2,T3 tool
```

企業導入時通常選擇**自建 MCP Server**：公司決定員工能查什麼，而不是把整個資料庫交給 AI。

---

## 事前準備

| 項目 | 說明 |
|---|---|
| 台鐵資料庫 | 匯入 `台鐵車站資訊`、`每日各站進出站人數` 兩張資料表 👉 [資料與 DDL](../../範例資料庫/其它範例csv/台鐵車站進出資訊_全部整合/) |
| uv | Python 套件管理工具 👉 [安裝說明](https://docs.astral.sh/uv/getting-started/installation/) |
| AI 程式助手 | 推薦 **Claude Code**（可以直接建立檔案、執行和測試）；也可以在 Claude Desktop 或 claude.ai 對話後複製程式 |
| Claude Desktop | 👉 [下載](https://claude.ai/download) |

---

## 步驟 1：規劃工具

**這是最重要的一步，也是 AI 無法替你做的事。** 先想清楚「使用者會問什麼」，再決定要提供哪些工具。

### 工具規劃表

| 工具名稱 | 用途 | 使用者可能會這樣問 | 參數 | 回傳 |
|---|---|---|---|---|
| `search_stations` | 搜尋車站 | 「花蓮有哪些車站？」「哪些站有 YouBike？」 | 關鍵字 | 車站代碼、名稱、地址、電話、有無 YouBike |
| `get_station_traffic` | 查某站每日人數 | 「臺北車站 1/1 到 1/7 每天進站多少人？」 | 站名、開始日期、結束日期 | 每日的進站、出站人數 |
| `top_stations` | 年度排行 | 「2022 年進站人數最多的 5 個車站」 | 年份、筆數、依進站或出站排序 | 車站名稱、進站、出站總人數 |

> 💡 **設計原則**
> - 一個工具只做一件事，名稱用英文、看得出用途
> - 從「使用者的問題」出發，不是從「資料表有什麼」出發
> - 想一想：哪些資料**不應該**開放？（例如會員的電話、地址）

### 取得資料表結構

AI 要知道資料表有哪些欄位才能寫出正確的 SQL。取得方式（擇一）：

- 直接使用 [建立進出站的ddl.sql](../../範例資料庫/其它範例csv/台鐵車站進出資訊_全部整合/建立進出站的ddl.sql)
- 在 pgAdmin 對資料表按右鍵 → **Scripts → CREATE Script**
- 用[第 5 章](../../MCP操作資料庫/1_postgres_mcp_pro/) 的 Postgres MCP Pro 問 Claude：「列出台鐵車站資訊、每日各站進出站人數兩張資料表的欄位與型別」

---

## 步驟 2：請 AI 寫程式

### 提示詞範本

把下面的範本複製給 AI，替換【】裡的內容：

````markdown
請幫我用 Python 建立一個 MCP Server。

## 目的
【讓一般員工用自然語言查詢台鐵各車站的資訊與每日進出站人數】

## 技術規定
- 使用 MCP 官方 Python SDK(mcp 套件 2.x 版),用 `from mcp.server import MCPServer` 建立 server,以 stdio 執行
- 使用 psycopg2 連線 PostgreSQL,連線字串從環境變數 DATABASE_URI 讀取,不可以把密碼寫在程式裡
- 連線設定為唯讀:conn.set_session(readonly=True)
- 所有使用者傳入的值都要用 %s 參數化查詢,不可以用字串組合 SQL
- 欄位名稱、排序方式這類不能用 %s 的參數,要用 Literal 限定可以傳入的值
- 查詢結果用 RealDictCursor 回傳 list[dict],日期轉成字串
- 每個工具都要寫清楚的繁體中文 docstring,說明用途和參數格式
- 程式加上繁體中文註解,讓不會寫程式的人也看得懂
- 同時產生 requirements.txt

## 資料表結構
【貼上 CREATE TABLE 語法】

## 工具
【貼上步驟 1 的工具規劃表】
````

> 💡 **給 AI 的資訊越清楚，寫出來的程式越正確。** 「技術規定」那一段就是公司的安全規定，每次都要附上。

### 使用 Claude Code（推薦）

```bash
mkdir my_mcp_server
cd my_mcp_server
claude
```

貼上提示詞後，可以再補一句：「**寫完之後幫我用 MCP Inspector 測試每個工具**」，Claude Code 會自己執行並修正錯誤。

### 參考答案

本單元依照上面的規劃表請 AI 產生的程式：[server.py](./server.py)、[requirements.txt](./requirements.txt)

---

## 步驟 3：看懂 AI 寫的程式

你不用會寫，但要**看得懂這 5 個地方**，才能判斷 AI 寫的程式能不能交給公司使用。

### 驗收檢查清單

| # | 檢查項目 | 在程式裡找這個 | 為什麼重要 |
|:---:|---|---|---|
| 1 | 工具有沒有註冊 | `@mcp.tool()` | 沒有這行，AI 看不到這個工具 |
| 2 | 工具說明寫清楚了嗎 | 函式下方的 `"""說明"""` | **這是給 AI 看的**，AI 依照它決定什麼時候呼叫哪個工具 |
| 3 | 密碼沒有寫死 | `os.environ.get("DATABASE_URI")` | 程式會被分享、放上 git，密碼寫在裡面就外洩了 |
| 4 | 唯讀連線 | `set_session(readonly=True)` | 就算 SQL 寫錯，也不會改到或刪掉資料 |
| 5 | 參數化查詢 | SQL 裡用 `%s`，值另外傳入 | 防止 SQL Injection（見下方說明） |

### 1–2. MCP Server 的基本結構

```python
from mcp.server import MCPServer

mcp = MCPServer("台鐵進出站查詢")          # 名稱會顯示在 Claude Desktop


@mcp.tool()                                # ① 註冊成 AI 可以呼叫的工具
def search_stations(keyword: str) -> list[dict]:
    """用關鍵字搜尋台鐵車站(車站名稱或地址),回傳車站代碼、名稱、地址、電話、是否有 YouBike"""   # ② 給 AI 看的說明
    ...


if __name__ == "__main__":
    mcp.run()                              # 用 stdio 和 Claude Desktop 溝通
```

`keyword: str` 是**型別提示**，SDK 會依照它告訴 AI 要傳入什麼格式的參數。

### 3–4. 連線設定

```python
DATABASE_URI = os.environ.get("DATABASE_URI", "postgresql://postgres:raspberry@localhost:5432/postgres")  # ③

def query(sql, params=None):
    with psycopg2.connect(DATABASE_URI) as conn:
        conn.set_session(readonly=True)                                                  # ④
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            ...
```

### 5. 防止 SQL Injection

AI 傳進來的參數也是「使用者輸入」，可能被惡意操控，一定要用 **`%s` 參數化查詢**：

![SQL Injection 對照圖](../images/sql_injection.svg)

```python
# ✅ 正確:值用 %s,另外傳入
cur.execute("SELECT * FROM 台鐵車站資訊 WHERE \"stationName\" LIKE %s", (pattern,))

# ❌ 危險:把字串直接接進 SQL
cur.execute(f"SELECT * FROM 台鐵車站資訊 WHERE \"stationName\" LIKE '{keyword}'")
```

**欄位名稱**（例如 `ORDER BY 進站人數`）不能用 `%s` 傳遞，這時候要用 `Literal` 限定只能傳入特定的值：

```python
@mcp.tool()
def top_stations(
    year: int, limit: int = 10, order_by: Literal["進站人數", "出站人數"] = "進站人數"
) -> list[dict]:
```

```mermaid
flowchart LR
    IN["AI 傳入 order_by"] --> C{"是「進站人數」<br/>或「出站人數」？"}
    C -->|是| RUN["執行 SQL"]
    C -->|不是| STOP["SDK 直接回傳錯誤<br/>函式完全不會執行"]

    classDef ok fill:#f0fdf4,stroke:#16a34a,color:#14532d
    classDef bad fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class RUN ok
    class STOP bad
```

如果有人傳入 `order_by="x; DROP TABLE a"`，SDK 會在執行函式**之前**就擋下來：

```
Input should be '進站人數' or '出站人數'
```

> 💡 **不確定 AI 有沒有做到？直接問 AI：**「請逐一檢查這份程式是否符合以下 5 項安全規定，並指出對應的程式碼行數：……」

---

## 步驟 4：用 MCP Inspector 測試

接上 Claude Desktop 之前，先用 MCP Inspector（網頁介面）確認每個工具都正常。

```bash
uv venv
uv pip install -r requirements.txt
uv run mcp dev server.py
```

> 如果資料庫的帳號、密碼和預設值不同，先設定環境變數：
> - macOS / Linux：`export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/postgres"`
> - Windows PowerShell：`$env:DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/postgres"`

瀏覽器會開啟 Inspector：

1. 按 **Connect**
2. 切換到 **Tools** 分頁 → **List Tools**，會看到 3 個工具
3. 選擇 `top_stations`，輸入 `year = 2022`、`limit = 3`，按 **Run Tool**

預期結果：

```json
[
  {"車站名稱": "臺北", "進站人數": 16565031, "出站人數": 16354305},
  {"車站名稱": "桃園", "進站人數": 7548521, "出站人數": 7748746},
  {"車站名稱": "臺南", "進站人數": 7172009, "出站人數": 7319528}
]
```

**驗收方式**：工具規劃表裡的每一個工具都要測過，並故意輸入錯誤的值（例如不存在的站名、錯誤的日期格式），看看會發生什麼事。

---

## 步驟 5：接上 Claude Desktop

編輯 `claude_desktop_config.json`（位置請參考[第 5 章](../../MCP操作資料庫/1_postgres_mcp_pro/#4-設定-claude-desktop)），在 `mcpServers` 中加入：

```json
{
  "mcpServers": {
    "taiwan_railway": {
      "command": "uv",
      "args": [
        "run",
        "--with",
        "mcp[cli]",
        "--with",
        "psycopg2-binary",
        "/完整路徑/mcp_server/1_用AI建立MCP_server/server.py"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/postgres"
      }
    }
  }
}
```

- `server.py` 必須使用**完整路徑**（Windows 範例：`C:\\Users\\你的帳號\\...\\server.py`，反斜線要寫兩個）
- `uv run --with` 會自動準備好需要的套件，不需要先啟動虛擬環境
- 找不到 `uv` 時，`"command"` 改成完整路徑（macOS 用 `which uv` 查詢）
- 可以和 Postgres MCP Pro 同時存在，各自用不同的名稱即可

存檔後**完全結束** Claude Desktop 再重新開啟。

---

## 步驟 6：請 AI 修改和除錯

程式很少一次就完美。遇到問題時，把**狀況描述清楚**交給 AI：

| 狀況 | 給 AI 的提示詞範例 |
|---|---|
| 出現錯誤訊息 | 「執行 `uv run mcp dev server.py` 時出現以下錯誤，請找出原因並修正：（貼上完整錯誤訊息）」 |
| Claude 選錯工具 | 「我問『臺北站上週每天多少人』，Claude 呼叫了 top_stations 而不是 get_station_traffic，請改善兩個工具的 docstring，讓 AI 更容易分辨」 |
| 要新增工具 | 「請新增工具 monthly_traffic(station_name, year)，用 GROUP BY 回傳某車站某一年每個月的進出站總人數，遵守原本的技術規定」 |
| 回傳資料太多 | 「請幫 top_stations 的 limit 加上最多 50 筆的限制，避免一次取回太多資料」 |
| 檢查安全性 | 「請用步驟 3 的 5 項檢查清單審查這份程式，列出不符合的地方」 |

> 💡 **錯誤訊息要完整貼上**，不要只說「不能跑」。Claude Desktop 的錯誤紀錄在 `~/Library/Logs/Claude/mcp*.log`（macOS）或 `%APPDATA%\Claude\logs`（Windows）。

---

## 實作練習

### 練習一：使用參考答案

在 Claude Desktop 提問，觀察 Claude 呼叫了哪個工具、傳入什麼參數：

- 「花蓮有哪些火車站？哪些有 YouBike？」
- 「臺北車站 2023 年 1 月 1 日到 1 月 7 日每天的進站人數」
- 「2021 年出站人數最多的前 5 個車站」
- 「比較 2020 和 2022 年進站人數前 3 名的車站，有什麼變化？」

### 練習二：用 AI 擴充功能

用[步驟 6](#步驟-6請-ai-修改和除錯) 的方式請 AI 完成，每完成一項都要用 Inspector 驗收：

1. 新增工具 `monthly_traffic(station_name, year)`：某車站某一年每個月的進出站總人數
2. 新增工具 `compare_stations(station_a, station_b, year)`：比較兩個車站一整年的進出站人數
3. 為 `top_stations` 的 `limit` 加上上限（最多 50 筆）

### 練習三：從零開始

用[中文範例資料庫](../../範例資料庫/中文範例資料庫/)的**圖書館借閱** `library.sql`，從步驟 1 的工具規劃表開始，請 AI 建立一個「圖書館館員助理」MCP Server。

> 🤔 **思考**：如果要讓 AI **新增**資料（例如登記借書），工具要怎麼設計才安全？👉 答案在[單元 4：會寫入資料的 MCP Server](../4_寫入型MCP_server/)

---

## 下一步

目前的 MCP Server 只在**自己的電腦**上執行，只有自己能用。
企業要讓全公司的員工都能使用，就要把它架在伺服器上，並且用 token 管控誰可以連線 👉 [單元 2：企業導入：遠端 MCP 與 token](../2_企業導入_遠端MCP與token/)
