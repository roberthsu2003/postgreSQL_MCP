# 使用 Postgres MCP Pro

[Postgres MCP Pro](https://github.com/crystaldba/postgres-mcp) 是一個開源的 PostgreSQL MCP Server,除了讓 AI 執行 SQL 之外,還提供查詢計畫分析、索引建議、資料庫健康檢查等功能。

## 1. 事前準備

1. **PostgreSQL 已經在執行**(沿用講義首頁的 Docker 安裝方式)

	```bash
	docker run --name my-postgres -e POSTGRES_PASSWORD=yourpassword -p 5432:5432 -d postgres
	```

2. **已經匯入範例資料庫**(dvdrental、台鐵進出站資料),請參考[範例資料庫](../../範例資料庫/)
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
uvx postgres-mcp --help
```

## 3. 連線字串(DATABASE_URI)

格式:

```
postgresql://使用者名稱:密碼@主機:埠號/資料庫名稱
```

範例(連線到 dvdrental 資料庫):

```
postgresql://postgres:yourpassword@localhost:5432/dvdrental
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
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/dvdrental"
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
        "postgres-mcp",
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/dvdrental"
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

## 7. 實作練習

### 練習一:認識 dvdrental 資料庫

在 Claude Desktop 輸入:

- 「dvdrental 資料庫有哪些資料表?」
- 「說明 film、inventory、rental 三個資料表之間的關聯」
- 「列出租借次數最多的前 10 部電影」
- 「把上一題使用的 SQL 給我看,並逐行解釋」

> 觀察重點:Claude 會先呼叫 `list_objects`、`get_object_details` 了解資料表結構,再呼叫 `execute_sql`。把 Claude 產生的 SQL 拿到 pgAdmin 執行,比對結果是否一致。

### 練習二:台鐵進出站資料

將 `DATABASE_URI` 改成台鐵資料所在的資料庫,重新啟動 Claude Desktop 後提問:

- 「2022 年進站人數最多的前 5 個車站是哪些?」
- 「台北車站每個月的平均進站人數,用表格呈現」
- 「哪些車站有提供 YouBike(haveBike)?」

### 練習三:效能分析

- 「幫我分析這個查詢的執行計畫:`SELECT * FROM 每日各站進出站人數 WHERE 車站代碼 = 1000`」
- 「這個查詢應該加什麼索引?加了之後預估成本差多少?」
- 「幫我做一次資料庫健康檢查」

> 對照課程中的 [JOIN](../../上課用sql/JOIN.md)、[GROUP BY](../../上課用sql/GROUP_BY.md)、[SubQuery](../../上課用sql/subQuery.md),試著先自己寫出 SQL,再和 AI 的答案比較。

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

- **dvdrental**:使用 `pg_restore`(解壓縮後的 `dvdrental` 資料夾)。備份還原建議使用 Direct connection;網路不支援 IPv6 時改用 Session pooler

	```bash
	pg_restore --no-owner --no-privileges -d "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require" dvdrental
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
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/dvdrental"
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
| Supabase 連線逾時 | 改用 Session pooler(IPv4);免費專案一段時間沒使用會被暫停,請先到 Supabase 後台恢復專案 |
| Supabase 帳號密碼錯誤 | 使用者名稱要用 `postgres.[PROJECT-REF]`;密碼中的特殊字元要 URL 編碼 |

## 下一步

[自己建立一個 MCP Server](../2_自建MCP_server/)
