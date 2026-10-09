# 3-1：安裝與設定 Postgres MCP Pro

> **本單元目標**：安裝**別人寫好的** MCP Server，體驗「AI 直接查詢資料庫」是什麼感覺，並學會在 Claude Desktop 設定 MCP Server。
> 你的角色是**使用者**。　[← 回第 3 章](../)

[Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp) 是一個開源的 PostgreSQL MCP Server,除了讓 AI 執行 SQL 之外,還提供查詢計畫分析、索引建議、資料庫健康檢查等功能。

## 1. 事前準備

1. **PostgreSQL 已經在執行**(沿用講義首頁的 Docker 安裝方式)

	```bash
	docker run --name my-postgres -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres
	```

2. **已經匯入範例資料庫**:依照第 2 章,把[網路商店 shop.sql](../../範例資料庫/中文範例資料庫/) 匯入 `practice` 資料庫
3. **安裝 [Claude Desktop](https://claude.ai/download)**
4. **安裝 Docker**(推薦)**或 Python 3.12 以上 + [uv](https://docs.astral.sh/uv/getting-started/installation/)**

> 先用 pgAdmin 或 DBeaver 確認帳號、密碼可以正常連線,再進行下一步。

## 2. 安裝 Postgres MCP Pro

### 方法一:使用 Docker(推薦)

```bash
docker pull crystaldba/postgres-mcp
```

### 方法二:使用 uv(Python)

不需要事先安裝,`uvx` 會在 Claude Desktop 啟動 MCP Server 時自動下載執行。
可以先在終端機測試是否能執行:

```bash
uvx --with "mcp<2" postgres-mcp --help
```

> ⚠️ **一定要加上 `--with "mcp<2"`**:Postgres MCP Pro 使用 MCP Python SDK 1.x 版的寫法,uvx 預設會安裝最新的 2.x 版,啟動時會出現 `No module named 'mcp.server.fastmcp'` 的錯誤。

## 3. 連線字串(DATABASE_URI)

格式:

```
postgresql://使用者名稱:密碼@主機:埠號/資料庫名稱
```

範例(連線到 practice 資料庫):

```
postgresql://postgres:yourpassword@localhost:5432/practice
```

> 使用 Docker 版的 Postgres MCP Pro 時,`localhost` 會自動轉換成 `host.docker.internal`(macOS/Windows),所以直接寫 `localhost` 即可。

## 4. 設定 Claude Desktop

### 設定檔位置

- macOS:`~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows:`%APPDATA%\Claude\claude_desktop_config.json`

也可以從 Claude Desktop 的 **設定(Settings) → 開發者(Developer) → 編輯設定(Edit Config)** 開啟。

### 使用 Docker 的設定

```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    }
  }
}
```

### 使用 uvx 的設定

```json
{
  "mcpServers": {
    "postgres": {
      "command": "uvx",
      "args": [
        "--with",
        "mcp<2",
        "postgres-mcp",
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    }
  }
}
```

> macOS 若出現找不到 `uvx` 的錯誤,請將 `"command"` 改成完整路徑,可用 `which uvx` 查詢(例如 `/Users/你的帳號/.local/bin/uvx`)。

### 重新啟動 Claude Desktop

存檔後**完全結束** Claude Desktop 再重新開啟(macOS 請用 `Cmd + Q`),在對話框的工具圖示中看到 `postgres` 即代表設定成功。

## 5. 存取模式(access mode)

| 模式 | 參數 | 說明 | 適用情境 |
|------|------|------|----------|
| 受限模式 | `--access-mode=restricted` | 只能執行唯讀交易,並限制執行時間 | 上課練習、正式環境 |
| 不受限模式 | `--access-mode=unrestricted` | 可以新增、修改、刪除資料與資料表 | 開發環境 |

```mermaid
flowchart LR
    Q["AI 產生的 SQL"] --> M{"access mode"}
    M -->|restricted| R["只允許 SELECT 等唯讀指令<br/>並限制執行時間"]
    M -->|unrestricted| U["INSERT、UPDATE、DELETE、<br/>DROP TABLE 都可以執行"]
    R --> OK["✔ 適合上課、正式環境"]
    U --> WARN["⚠ 只在開發環境使用"]

    classDef safe fill:#f0fdf4,stroke:#16a34a,color:#14532d
    classDef danger fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class R,OK safe
    class U,WARN danger
```

> **建議**:上課時先使用 `restricted`,避免 AI 誤刪資料。需要讓 AI 幫忙建立資料表或新增資料時,再改成 `unrestricted`。

## 6. Postgres MCP Pro 提供的工具

| 工具名稱 | 說明 |
|----------|------|
| `list_schemas` | 列出資料庫中所有的 schema |
| `list_objects` | 列出 schema 中的資料表、檢視表、序列、擴充套件 |
| `get_object_details` | 查看物件細節,例如資料表的欄位、限制、索引 |
| `execute_sql` | 執行 SQL(restricted 模式下只能唯讀) |
| `explain_query` | 取得查詢的執行計畫(EXPLAIN),可模擬加上假設索引後的效果 |
| `get_top_queries` | 依 `pg_stat_statements` 列出最慢的查詢 |
| `analyze_workload_indexes` | 分析整體工作負載,建議應該建立的索引 |
| `analyze_query_indexes` | 針對指定的 SQL(最多 10 個)建議索引 |
| `analyze_db_health` | 資料庫健康檢查(快取命中率、連線、索引、vacuum 等) |

> 你不需要記住這些工具名稱,只要用自然語言提問,Claude 會自己決定要呼叫哪一個工具。

例如問「列出 2025 年銷售數量最多的前 10 項商品」，Claude 通常會這樣使用工具：

```mermaid
sequenceDiagram
    actor 你
    participant AI as Claude Desktop
    participant MCP as Postgres MCP Pro
    participant DB as PostgreSQL

    你->>AI: 列出 2025 年銷售數量最多的前 10 項商品
    AI->>MCP: list_objects（有哪些資料表？）
    MCP-->>AI: categories, products, orders, order_items…
    AI->>MCP: get_object_details（products、order_items 有哪些欄位？）
    MCP-->>AI: 欄位名稱、型別、外來鍵
    Note over AI: 依照欄位<b>自己寫出 SQL</b>
    AI->>MCP: execute_sql（SELECT … JOIN … GROUP BY …）
    MCP->>DB: 執行 SQL
    DB-->>MCP: 查詢結果
    MCP-->>AI: 查詢結果
    AI-->>你: 整理成表格回答
```

> 💡 注意：這裡的 SQL 是 **AI 自己寫的**，可能寫錯。下一個單元會改成「公司寫好 SQL，AI 只挑選工具」。

## 7. 開始使用

設定完成後，👉 [3-2:第一次用中文查詢資料庫](../2_用中文查詢資料庫/),不用寫 SQL,直接用中文查詢網路商店的資料。

## 8. 連線到 Supabase(雲端 PostgreSQL)

[Supabase](https://supabase.com) 提供雲端的 PostgreSQL,免費方案就可以練習。Postgres MCP Pro 只需要換掉 `DATABASE_URI`,其餘使用方式完全相同。

### 8.1 建立專案並取得連線字串

1. 登入 Supabase,建立新專案,**記下資料庫密碼**
2. 進入專案,點選上方的 **Connect**
3. 選擇 **Session pooler**,複製連線字串:

	```
	postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres
	```

> **注意事項**
> - 請使用 **Session pooler**:Direct connection 只支援 IPv6,很多教室網路和 Docker 容器連不上;Session pooler 支援 IPv4
> - 使用者名稱是 `postgres.[PROJECT-REF]`,**不是** `postgres`,這是最常見的錯誤
> - `[POOLER-HOST]` 請直接從 Connect 畫面複製,不要自己猜
> - 密碼若含有 `@`、`#`、`?`、`&`、空白等特殊字元,要先做 URL 編碼(例如 `#` 寫成 `%23`)
> - 連線字串最後加上 `?sslmode=require`,強制使用加密連線

### 8.2 匯入範例資料

- **繁體中文範例資料庫**:在 Supabase 的 **SQL Editor** 貼上 [shop.sql](../../範例資料庫/中文範例資料庫/shop.sql) 等檔案的內容後執行;或使用 `psql`:

	```bash
	psql "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require" -f shop.sql
	```

- **台鐵 CSV**:先在 Supabase 的 **SQL Editor** 執行[建立進出站的ddl.sql](../../範例資料庫/其它範例csv/台鐵車站進出資訊_全部整合/建立進出站的ddl.sql),再用 DBeaver 或 `psql` 的 `\copy` 匯入 CSV(進出站資料約 40 萬筆,Table Editor 網頁上傳可能會逾時)

### 8.3 Claude Desktop 同時連接本機和 Supabase

`mcpServers` 可以設定多個 MCP Server,用不同名稱區分:

```json
{
  "mcpServers": {
    "postgres-local": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    },
    "postgres-supabase": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require"
      }
    }
  }
}
```

- 本機用 `unrestricted`,可以練習讓 AI 建立資料表、新增資料
- **雲端一律用 `restricted`**:雲端資料被 AI 誤刪很難救回
- 提問時指定要用哪一個,例如「用 postgres-supabase 查詢 2022 年進站人數前 5 名」

> **安全提醒**:`claude_desktop_config.json` 內有資料庫密碼,不要放進 git repo 或分享給別人。講義與作業中的密碼一律寫成 `[YOUR-PASSWORD]`。

### 8.4 延伸:Supabase 官方 MCP Server

Supabase 也有自己的 [官方 MCP Server](https://supabase.com/docs/guides/getting-started/mcp),可以管理專案、查看 log、產生型別等。本課程統一使用 Postgres MCP Pro,本機和雲端的操作方式才會一致,有興趣可以自行研究。

## 9. 常見問題

| 問題 | 解決方式 |
|------|----------|
| Claude Desktop 沒有出現 postgres 工具 | 確認 JSON 格式正確(不可有多餘的逗號),並完全結束後重新開啟 Claude Desktop |
| 連線失敗 | 確認 postgres 容器正在執行(`docker ps`),帳號、密碼、資料庫名稱正確 |
| 找不到 `uvx` 或 `docker` 指令 | 在 `"command"` 使用完整路徑(`which uvx`、`which docker`) |
| 想看錯誤訊息 | macOS 的 log 位於 `~/Library/Logs/Claude/mcp*.log`;Windows 位於 `%APPDATA%\Claude\logs` |
| AI 說無法修改資料 | 目前是 `restricted` 模式,這是正常的;需要寫入時改成 `unrestricted` |
| 出現 `No module named 'mcp.server.fastmcp'` | 使用 uvx 時要加上 `--with mcp<2`(見[方法二](#方法二使用-uvpython)) |
| Supabase 連線逾時 | 改用 Session pooler(IPv4);免費專案一段時間沒使用會被暫停,請先到 Supabase 後台恢復專案 |
| Supabase 帳號密碼錯誤 | 使用者名稱要用 `postgres.[PROJECT-REF]`;密碼中的特殊字元要 URL 編碼 |

## 下一步

👉 [3-2:第一次用中文查詢資料庫](../2_用中文查詢資料庫/)
