# 自己建立一個 MCP Server(Python + psycopg2)

## 為什麼要自己建立 MCP Server?

[Postgres MCP Pro](../1_postgres_mcp_pro/) 把**整個資料庫**交給 AI,AI 可以自己寫任何 SQL。
自己建立的 MCP Server 則是只提供**你設計好的幾個工具**,AI 只能呼叫這些工具。

| | Postgres MCP Pro | 自建 MCP Server |
|---|---|---|
| AI 能做的事 | 任何 SQL | 只有你寫好的工具 |
| 安全性 | 靠 access mode 控制 | 只能執行你寫好的 SQL,範圍最小 |
| 準確度 | AI 要先了解資料表結構才能寫 SQL | 查詢邏輯已經寫好,結果穩定 |
| 適合 | 開發、資料探索、效能調校 | 給一般使用者、特定業務查詢 |

本單元會把台鐵進出站資料庫包裝成 3 個工具,讓 Claude Desktop 可以用自然語言查詢。

## 1. 事前準備

- 已完成台鐵車站資料的匯入(資料表 `台鐵車站資訊`、`每日各站進出站人數`)
	- 資料與建立資料表的 SQL:[台鐵車站進出資訊_全部整合](../../範例資料庫/其它範例csv/台鐵車站進出資訊_全部整合/)
- 已安裝 [uv](https://docs.astral.sh/uv/getting-started/installation/)
- 已學過 [psycopg2 基本語法](../../python/basic_module_usage/) 和 [傳遞資料至 SQL Query 參數](../../python/parameter/)

## 2. 安裝套件

```bash
uv venv
uv pip install -r requirements.txt
```

[requirements.txt](./requirements.txt) 內容:

```
mcp[cli]>=2.3.0
psycopg2-binary>=2.9.3
```

- `mcp`:MCP 官方 Python SDK,`[cli]` 會多安裝 `mcp` 指令(用來測試)
- `psycopg2-binary`:連線 PostgreSQL

## 3. 認識 MCP Server 的程式結構

最小的 MCP Server 只需要幾行:

```python
from mcp.server import MCPServer

mcp = MCPServer("Demo")


@mcp.tool()
def add(a: int, b: int) -> int:
    """兩個數字相加"""
    return a + b


if __name__ == "__main__":
    mcp.run()
```

| 程式 | 說明 |
|------|------|
| `MCPServer("Demo")` | 建立 MCP Server,名稱會顯示在 Claude Desktop |
| `@mcp.tool()` | 把函式註冊成 AI 可以呼叫的工具 |
| 型別提示 `a: int` | 自動產生參數格式,AI 會依照型別傳入參數 |
| docstring `"""..."""` | **這是給 AI 看的說明**,AI 依照它決定何時呼叫這個工具,要寫清楚 |
| `mcp.run()` | 使用 stdio(標準輸入輸出)和 Claude Desktop 溝通 |

## 4. 台鐵進出站查詢 MCP Server

完整程式:[server.py](./server.py)

### 4.1 連線設定與共用查詢函式

```python
DATABASE_URI = os.environ.get(
    "DATABASE_URI",
    "postgresql://postgres:raspberry@localhost:5432/postgres",
)

mcp = MCPServer("台鐵進出站查詢")


def query(sql, params=None):
    """執行唯讀查詢,回傳 list[dict]"""
    with psycopg2.connect(DATABASE_URI) as conn:
        # 設定為唯讀,即使 SQL 寫錯也不會修改資料
        conn.set_session(readonly=True)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
    conn.close()
    ...
```

- 連線字串從環境變數 `DATABASE_URI` 讀取,密碼不要寫死在程式中
- `conn.set_session(readonly=True)`:連線設為唯讀,多一層保護
- `RealDictCursor`:查詢結果變成 `dict`(欄位名稱: 值),AI 比較容易看懂

### 4.2 三個工具

| 工具 | 參數 | 說明 |
|------|------|------|
| `search_stations` | `keyword` | 用關鍵字搜尋車站名稱或地址 |
| `get_station_traffic` | `station_name`、`start_date`、`end_date` | 查詢車站某段期間每日的進出站人數 |
| `top_stations` | `year`、`limit`、`order_by` | 某一年進站或出站人數最多的車站排行 |

```python
@mcp.tool()
def search_stations(keyword: str) -> list[dict]:
    """用關鍵字搜尋台鐵車站(車站名稱或地址),回傳車站代碼、名稱、地址、電話、是否有 YouBike"""
    sql = """
        SELECT "stationCode" AS 車站代碼,
               "stationName" AS 車站名稱,
               ...
        FROM 台鐵車站資訊
        WHERE "stationName" LIKE %s OR "stationAddrTw" LIKE %s
        ORDER BY "stationCode"
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))
```

### 4.3 重點:防止 SQL Injection

AI 傳進來的參數也是「使用者輸入」,一定要用 **`%s` 參數化查詢**,不可以直接把字串接進 SQL。

但是**欄位名稱**(例如 `ORDER BY 進站人數`)不能用 `%s` 傳遞。這時候用 `Literal` 限定只能傳入特定的值:

```python
@mcp.tool()
def top_stations(
    year: int, limit: int = 10, order_by: Literal["進站人數", "出站人數"] = "進站人數"
) -> list[dict]:
    """查詢某一年總人數最多的車站排行,可以依進站人數或出站人數排序"""
    # 欄位名稱不能用 %s 傳遞,所以用 Literal 限定只能是這兩個值,避免 SQL injection
    sql = f"""
        ...
        ORDER BY {order_by} DESC
        LIMIT %s
    """
    return query(sql, (year, limit))
```

如果 AI 傳入 `order_by="x; DROP TABLE a"`,MCP SDK 會在執行函式**之前**就擋下來,並回傳錯誤訊息:

```
Input should be '進站人數' or '出站人數'
```

同理,`get_station_traffic` 的日期參數使用 `date` 型別,格式錯誤的日期也會先被擋下。

## 5. 使用 MCP Inspector 測試

接上 Claude Desktop 之前,先用 MCP Inspector(網頁介面)測試工具是否正常:

```bash
uv run mcp dev server.py
```

瀏覽器會開啟 Inspector:

1. 按 **Connect**
2. 切換到 **Tools** 分頁 → **List Tools**,會看到 3 個工具
3. 選擇 `top_stations`,輸入 `year = 2022`、`limit = 3`,按 **Run Tool**

預期結果:

```json
[
  {"車站名稱": "臺北", "進站人數": 16565031, "出站人數": 16354305},
  {"車站名稱": "桃園", "進站人數": 7548521, "出站人數": 7748746},
  {"車站名稱": "臺南", "進站人數": 7172009, "出站人數": 7319528}
]
```

> 如果資料庫的帳號、密碼和預設值不同,先設定環境變數:
> macOS/Linux:`export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/postgres"`
> Windows(PowerShell):`$env:DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/postgres"`

## 6. 註冊到 Claude Desktop

編輯 `claude_desktop_config.json`(位置請參考[上一單元](../1_postgres_mcp_pro/#4-設定-claude-desktop)),在 `mcpServers` 中加入:

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
        "/完整路徑/mcp_server/2_自建MCP_server/server.py"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/postgres"
      }
    }
  }
}
```

- `server.py` 必須使用**完整路徑**(Windows 範例:`C:\\Users\\你的帳號\\...\\server.py`,反斜線要寫兩個)
- `uv run --with` 會自動準備好需要的套件,不需要先啟動虛擬環境
- 找不到 `uv` 時,`"command"` 改成完整路徑(`which uv`)
- 可以和 Postgres MCP Pro 同時存在,各自用不同的名稱即可

存檔後完全結束 Claude Desktop 再重新開啟。

## 7. 實作練習

在 Claude Desktop 提問,觀察 Claude 呼叫了哪個工具、傳入什麼參數:

- 「花蓮有哪些火車站?哪些有 YouBike?」
- 「臺北車站 2023 年 1 月 1 日到 1 月 7 日每天的進站人數」
- 「2021 年出站人數最多的前 5 個車站」
- 「比較 2020 和 2022 年進站人數前 3 名的車站,有什麼變化?」

## 8. 延伸挑戰

1. 新增工具 `monthly_traffic(station_name, year)`:用 `GROUP BY` 回傳某車站某一年每個月的進出站總人數(參考 [GROUP BY](../../上課用sql/GROUP_BY.md))
2. 新增工具 `compare_stations(station_a, station_b, year)`:比較兩個車站一整年的進出站人數
3. 為 `top_stations` 的 `limit` 加上上限(例如最多 50),避免 AI 一次取回太多資料
4. 思考:如果要讓 AI **新增**資料,工具要怎麼設計才安全?

## 9. 自建 MCP Server 和 Postgres MCP Pro 怎麼選?

- **探索資料、開發、調校效能** → Postgres MCP Pro
- **給非工程師使用、只開放特定查詢、要求結果穩定** → 自建 MCP Server
- 兩者可以同時註冊在 Claude Desktop,依需求使用
