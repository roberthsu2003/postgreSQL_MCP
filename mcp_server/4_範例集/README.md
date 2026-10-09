# 單元 4：MCP Server 範例集

> 把課程中**所有的範例資料庫**都做成 MCP Server。每個範例都是一個「部門」的 AI 助理，可以直接使用，也可以當作請 AI 寫程式時的參考。

## 範例一覽

```mermaid
flowchart LR
    subgraph 資料庫
        SHOP[("shop.sql<br/>網路商店")]
        SCHOOL[("school.sql<br/>學校選課")]
        LIB[("library.sql<br/>圖書館借閱")]
        TRA[("台鐵<br/>進出站人數")]
        YB[("YouBike<br/>實戰專案")]
        STK[("大盤股市<br/>實戰專案")]
    end
    subgraph MCP Server
        E0["營運助理<br/>（單元 3）"]
        E1["客服助理"]
        E2["教務處助理"]
        E3["館員助理"]
        E4["台鐵查詢<br/>（單元 2）"]
        E5["YouBike 查詢"]
        E6["股市查詢"]
    end
    SHOP --> E0
    SHOP --> E1
    SCHOOL --> E2
    LIB --> E3
    TRA --> E4
    YB --> E5
    STK --> E6

    classDef here fill:#eff6ff,stroke:#2563eb,color:#1e3a8a
    classDef other fill:#f8fafc,stroke:#94a3b8,color:#334155
    class E1,E2,E3,E5,E6 here
    class E0,E4 other
```

| # | 範例 | 誰會用 | 資料庫 | 工具數 | 學到的技巧 |
|:---:|---|---|---|:---:|---|
| 1 | [🛒 網路商店客服助理](./shop_service.md) | 客服人員 | shop.sql | 4 | **個資最小化**（email 遮罩）、多步驟查詢 |
| 2 | [🎓 教務處助理](./school_office.md) | 教務處職員、導師 | school.sql | 4 | `HAVING` 找出需要輔導的學生、`CASE WHEN` 判斷及格 |
| 3 | [📚 圖書館館員助理](./library_desk.md) | 圖書館館員 | library.sql | 4 | 日期計算（逾期天數）、`RANK()` 排名、可選的篩選條件 |
| 4 | [🚲 YouBike 查詢](./youbike.md) | 一般民眾 | YouBike 實戰專案 | 4 | 時間序列取「最新一筆」、**台／臺**的搜尋問題 |
| 5 | [📈 股市大盤查詢](./stock.md) | 理財專員 | 大盤股市實戰專案 | 4 | 依日／週／月彙總、計算漲跌幅、限制回傳筆數 |
| — | [🛍️ 網路商店營運助理](../3_企業導入_遠端MCP與token/) | 主管 | shop.sql | 4 | 單元 3 的遠端 + token 範例 |
| — | [🚆 台鐵進出站查詢](../2_用AI建立MCP_server/) | 一般民眾 | 台鐵資料 | 3 | 單元 2 的基礎範例 |

> 💡 **同一個資料庫，可以有不同的 MCP Server。** 網路商店就有「客服助理」和「營運助理」兩個：客服只能查會員訂單，主管才能看營業額。這就是企業依照**部門**開放不同工具的做法。

---

## 範例的程式架構

所有範例共用一份 [common.py](./common.py)，裡面是**資料庫查詢、token 門禁、稽核紀錄、啟動方式**。每個範例的程式只需要寫自己的工具。

```mermaid
flowchart LR
    D["<b>各部門只寫工具</b><br/><br/>shop_service.py<br/>school_office.py<br/>library_desk.py<br/>youbike.py<br/>stock.py"]
    subgraph IT["IT 部門寫一次：common.py"]
        Q["query()　唯讀查詢"]
        A["audit()　稽核紀錄"]
        T["TokenCheck　token 門禁"]
        R["run()　本機或遠端啟動"]
    end
    D -->|"from common import<br/>audit, query, run"| IT

    classDef dept fill:#f0fdfa,stroke:#0f766e,color:#134e4a
    classDef it fill:#eff6ff,stroke:#2563eb,color:#1e3a8a
    class D dept
    class Q,A,T,R it
```

每個範例的程式長得都一樣，只有工具不同：

```python
from mcp.server import MCPServer
from common import audit, query, run

mcp = MCPServer("教務處助理", instructions="你是大學教務處的助理……")   # instructions:給 AI 的角色說明


@mcp.tool()
def student_transcript(student_id: str) -> list[dict]:
    """查詢某位學生的成績單……"""
    audit("student_transcript", student_id=student_id)   # 記錄誰查了什麼
    sql = "SELECT … WHERE e.student_id = %s"
    return query(sql, (student_id,))                     # 唯讀 + 參數化查詢


if __name__ == "__main__":
    run(mcp)                                             # 本機或遠端,由環境變數決定
```

---

## 準備

### 1. 安裝套件

```bash
cd mcp_server/4_範例集
uv venv
uv pip install -r requirements.txt
```

### 2. 準備資料庫

| 範例 | 資料庫 | 準備方式 |
|---|---|---|
| 客服助理、教務處助理、館員助理 | `practice` | 匯入[中文範例資料庫](../../範例資料庫/中文範例資料庫/)的 `shop.sql`、`school.sql`、`library.sql` |
| YouBike 查詢 | 實戰專案使用的資料庫 | 執行 [台北市 YouBike](../../tutorial_container/範例/2taipei_youbike/) 的 notebook 下載資料 |
| 股市大盤查詢 | `stock_market` | 執行 [大盤股市](../../tutorial_container/範例/1stock_market/) 的 notebook 下載資料 |

### 3. 用 Inspector 測試

```bash
export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/practice"
uv run mcp dev shop_service.py
```

---

## 兩種執行方式

每個範例都可以用**本機**或**遠端**兩種方式執行，程式不用改，只要改環境變數 `MCP_TRANSPORT`。

| | 本機（預設） | 遠端 |
|---|---|---|
| 設定 | 不用設定 | `MCP_TRANSPORT=http` |
| 誰啟動 | Claude Desktop | 自己在終端機啟動，一直開著 |
| token | 不需要 | 需要（`tokens.json`） |
| 對應單元 | [單元 2](../2_用AI建立MCP_server/) | [單元 3](../3_企業導入_遠端MCP與token/) |

### 方式一：本機

在 `claude_desktop_config.json` 加入，**可以同時註冊好幾個範例**：

```json
{
  "mcpServers": {
    "shop-service": {
      "command": "uv",
      "args": ["run", "--with", "mcp[cli]", "--with", "psycopg2-binary",
               "/完整路徑/mcp_server/4_範例集/shop_service.py"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    },
    "school-office": {
      "command": "uv",
      "args": ["run", "--with", "mcp[cli]", "--with", "psycopg2-binary",
               "/完整路徑/mcp_server/4_範例集/school_office.py"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    },
    "library-desk": {
      "command": "uv",
      "args": ["run", "--with", "mcp[cli]", "--with", "psycopg2-binary",
               "/完整路徑/mcp_server/4_範例集/library_desk.py"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice",
        "MCP_USER": "王館員"
      }
    }
  }
}
```

- `MCP_USER`：本機模式沒有 token，稽核紀錄會顯示這個名字（沒有設定就顯示「本機使用者」）
- 稽核紀錄會寫在 Claude Desktop 的 log 裡（macOS：`~/Library/Logs/Claude/mcp-server-library-desk.log`）

### 方式二：遠端 + token

```bash
# 1. 從 tokens.example.json 複製一份 tokens.json,填入 token(產生方式見單元 3)
cp tokens.example.json tokens.json

# 2. 啟動(macOS / Linux)
export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/practice"
MCP_TRANSPORT=http MCP_PORT=8001 uv run school_office.py
```

Windows PowerShell：

```powershell
$env:DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/practice"
$env:MCP_TRANSPORT="http"; $env:MCP_PORT="8001"
uv run school_office.py
```

員工的 Claude Desktop 設定（和[單元 3](../3_企業導入_遠端MCP與token/#51-claude-desktop) 相同）：

```json
{
  "mcpServers": {
    "school-office": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://localhost:8001/mcp", "--header", "Authorization:${AUTH_HEADER}"],
      "env": { "AUTH_HEADER": "Bearer 你的token" }
    }
  }
}
```

> 同時開好幾個遠端範例時，每個要用**不同的埠號**（`MCP_PORT=8001`、`8002`……）。

| 環境變數 | 預設值 | 說明 |
|---|---|---|
| `DATABASE_URI` | `postgresql://postgres:yourpassword@localhost:5432/practice` | 資料庫連線字串 |
| `MCP_TRANSPORT` | `stdio` | `stdio` 本機、`http` 遠端 |
| `MCP_HOST` | `127.0.0.1` | 遠端模式；讓其它電腦連線時改成 `0.0.0.0` |
| `MCP_PORT` | `8000` | 遠端模式的埠號 |
| `MCP_USER` | `本機使用者` | 本機模式時，稽核紀錄顯示的名字 |

---

## 怎麼使用這些範例

| 用途 | 做法 |
|---|---|
| **上課示範** | 同時註冊 2～3 個範例，問 Claude 跨領域的問題，觀察它怎麼挑選工具 |
| **當作提示詞的參考** | 每個範例的說明頁都附上「產生這個範例的提示詞」，可以照著修改成自己的需求 |
| **請 AI 擴充** | 把範例程式和「延伸挑戰」交給 AI，練習[步驟 6：請 AI 修改和除錯](../2_用AI建立MCP_server/#步驟-6請-ai-修改和除錯) |
| **期末專題的起點** | 選一個範例，換一個使用者角色（例如把「教務處」換成「學生自己」），重新規劃工具 |
