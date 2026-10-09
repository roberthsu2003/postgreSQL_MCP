# 單元 2：企業導入：遠端 MCP Server 與 token

> **本單元目標**：把 MCP Server 架在伺服器上，讓多位員工用 Claude Desktop **帶著自己的 token** 連線，並記錄每個人查了什麼。

## 目錄

- [1. 從「自己用」到「全公司用」](#1-從自己用到全公司用)
- [2. 為什麼連線一定要 token？](#2-為什麼連線一定要-token)
- [3. 範例：網路商店營運助理](#3-範例網路商店營運助理)
- [4. 動手做](#4-動手做)
- [5. 員工端：連線到公司的 MCP Server](#5-員工端連線到公司的-mcp-server)
- [6. 正式導入企業時](#6-正式導入企業時)
- [7. 請 AI 把你的 MCP Server 改成遠端版](#7-請-ai-把你的-mcp-server-改成遠端版)
- [8. 常見問題](#8-常見問題)

---

## 1. 從「自己用」到「全公司用」

| | 第 5 章、單元 1：本機（stdio） | 單元 2：遠端（Streamable HTTP） |
|---|---|---|
| MCP Server 在哪裡執行 | 自己的電腦，由 Claude Desktop 啟動 | 公司的伺服器，一直開著 |
| 誰可以用 | 只有自己 | 所有拿到 token 的員工 |
| 怎麼連線 | 設定 `command` 執行程式 | 設定**網址** + **token** |
| 資料庫密碼在哪裡 | 每個人的電腦上 | **只在伺服器上**，員工拿不到 |
| 程式更新 | 每個人都要更新 | 伺服器更新一次，全公司生效 |

![本機與遠端比較](../images/stdio_vs_http.svg)

---

## 2. 為什麼連線一定要 token？

MCP Server 放到網路上之後，**任何知道網址的人都能連線**。沒有 token，就等於把公司資料庫的大門打開。

token 就像**員工的門禁卡**：

![token 門禁示意圖](../images/token_gate.svg)

| 門禁卡 | token |
|---|---|
| 刷卡才能進公司 | 帶正確的 token 才能連線，否則回傳 `401 未授權` |
| 每個人一張，知道是誰進出 | 每個人一組 token，伺服器知道是誰在查詢 |
| 留下進出紀錄 | 留下**稽核紀錄**：誰、什麼時間、呼叫了哪個工具 |
| 卡片遺失或離職就停用 | token 外洩或員工離職，從清單刪除就無法再連線 |

### token 的使用規定

1. **一人一組**：不要全公司共用一組，否則出事時查不到是誰
2. **夠長的亂數**：不要用 `123456`、`company2025` 這種猜得到的字串
3. **不可以寫在程式裡、不可以放進 git**：本範例的 `tokens.json` 已經列在 [.gitignore](./.gitignore)
4. **正式環境一定要用 HTTPS**：用 `http://` 傳送時，token 在網路上是明文，可能被攔截
5. **定期更換**：懷疑外洩就立刻換掉

---

## 3. 範例：網路商店營運助理

程式：[server_http.py](./server_http.py)　資料庫：[shop.sql](../../範例資料庫/中文範例資料庫/)（網路商店）

| 工具 | 用途 | 員工可能會這樣問 |
|---|---|---|
| `search_products` | 搜尋商品、價格、庫存 | 「我們有賣哪些茶類商品？」 |
| `sales_summary` | 一段期間的銷售統計（依分類／商品／月份） | 「11、12 月哪個分類賣最好？」「2025 年每個月的營業額」 |
| `low_stock_products` | 需要補貨的商品 | 「哪些商品缺貨了？」 |
| `top_customers` | 年度消費金額最高的會員（最多 50 筆） | 「2025 年前 10 名的 VIP 會員」 |

和單元 1 比較，多了兩個部分：

```python
class TokenCheck:
    """每個連線都要帶 Authorization: Bearer <token>,token 不在清單內就拒絕"""
    ...
        if token not in TOKENS:
            return 401 未授權


def audit(tool, **params):
    """記錄誰在什麼時間呼叫了哪個工具(企業稽核用)"""
```

---

## 4. 動手做

### 4.1 準備資料庫

建立 `practice` 資料庫並匯入 `shop.sql` 👉 [匯入方式](../../範例資料庫/中文範例資料庫/#匯入方式)

### 4.2 安裝套件

```bash
cd mcp_server/2_企業導入_遠端MCP與token
uv venv
uv pip install -r requirements.txt
```

### 4.3 產生 token

每位員工產生一組：

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

會得到類似 `kV3x9QmZ...` 的 43 個字元亂數。

複製 [tokens.example.json](./tokens.example.json) 成 `tokens.json`，填入 token 和使用者名稱：

```json
{
  "kV3x9QmZ...(第一組 token)": "林美玲(業務部)",
  "Rq81bTnW...(第二組 token)": "李佳穎(行銷部)"
}
```

### 4.4 啟動 MCP Server

```bash
# macOS / Linux
export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/practice"
uv run server_http.py

# Windows PowerShell
$env:DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/practice"
uv run server_http.py
```

看到這行就代表啟動成功：

```
MCP Server 已啟動:http://127.0.0.1:8000/mcp(共 2 組 token)
```

> 這個視窗要一直開著，它就是「公司的伺服器」。

### 4.5 測試門禁：沒有 token 會被擋下

開**另一個**終端機視窗：

```bash
curl -i -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'
```

```
HTTP/1.1 401 Unauthorized
{"error":"未授權:請提供正確的 token"}
```

加上 token 再試一次（`-H` 那行換成你的 token）：

```bash
curl -i -X POST http://localhost:8000/mcp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer 你的token" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"curl","version":"1.0"}}}'
```

```
HTTP/1.1 200 OK
...
data: {"jsonrpc":"2.0","id":1,"result":{..."serverInfo":{"name":"網路商店營運助理"...
```

> Windows 的 PowerShell 請改用 `curl.exe`，並把每行結尾的 `\` 改成 `` ` ``。

---

## 5. 員工端：連線到公司的 MCP Server

### 5.1 Claude Desktop

Claude Desktop 的設定檔裡不能直接寫網址和 token，所以透過 [mcp-remote](https://github.com/geelen/mcp-remote) 這個小程式轉接，它會在每次連線時幫你帶上 token。

**需要先安裝 [Node.js](https://nodejs.org/)**（`mcp-remote` 用 `npx` 執行）。

```mermaid
sequenceDiagram
    participant CD as Claude Desktop
    participant MR as mcp-remote<br/>（員工電腦上的轉接程式）
    participant S as MCP Server<br/>（公司伺服器）
    participant DB as PostgreSQL

    CD->>MR: 呼叫工具（本機 stdio）
    MR->>S: HTTP 請求<br/>Authorization: Bearer token
    alt token 正確
        S->>S: 記錄稽核紀錄
        S->>DB: 執行 SQL（唯讀）
        DB-->>S: 查詢結果
        S-->>MR: 200 查詢結果
        MR-->>CD: 查詢結果
    else token 錯誤或沒有提供
        S-->>MR: 401 未授權
        MR-->>CD: 連線失敗
    end
```

編輯 `claude_desktop_config.json`（位置請參考[第 5 章](../../MCP操作資料庫/1_postgres_mcp_pro/#4-設定-claude-desktop)）：

```json
{
  "mcpServers": {
    "shop": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "http://localhost:8000/mcp",
        "--header",
        "Authorization:${AUTH_HEADER}"
      ],
      "env": {
        "AUTH_HEADER": "Bearer 你的token"
      }
    }
  }
}
```

- `Authorization:${AUTH_HEADER}` 冒號後面**不要加空格**（Windows 版 Claude Desktop 處理空格有問題），空格放在 `env` 裡的 `Bearer 你的token`
- 存檔後**完全結束** Claude Desktop 再重新開啟

接著問 Claude：「11、12 月哪個分類賣最好？」，回到 MCP Server 的視窗，會看到稽核紀錄：

```
[2026-10-09 15:01:43] 林美玲(業務部) 呼叫 sales_summary {'start_date': '2025-11-01', 'end_date': '2025-12-31', 'group_by': '分類'}
```

### 5.2 Claude Code

Claude Code 可以直接設定網址和 token：

```bash
claude mcp add --transport http shop http://localhost:8000/mcp \
  --header "Authorization: Bearer 你的token"
```

### 5.3 VS Code

`.vscode/mcp.json`：

```json
{
  "servers": {
    "shop": {
      "type": "http",
      "url": "http://localhost:8000/mcp",
      "headers": {
        "Authorization": "Bearer ${input:shop-token}"
      }
    }
  },
  "inputs": [
    {
      "id": "shop-token",
      "type": "promptString",
      "description": "網路商店 MCP 的 token",
      "password": true
    }
  ]
}
```

VS Code 會在第一次連線時詢問 token，不會寫在檔案裡。

### 5.4 課堂演練：老師當伺服器、學生當員工

```mermaid
flowchart LR
    subgraph 學生的電腦
        S1["學生 A<br/>Claude Desktop"]
        S2["學生 B<br/>Claude Desktop"]
        S3["學生 C<br/>Claude Desktop"]
    end
    subgraph 老師的電腦
        M["MCP Server<br/>MCP_HOST=0.0.0.0"]
        L["📋 稽核紀錄<br/>即時顯示誰查了什麼"]
        DB[("practice<br/>shop.sql")]
    end
    S1 -->|"token A"| M
    S2 -->|"token B"| M
    S3 -.->|"token C 已刪除<br/>401"| M
    M --> DB
    M --> L

    classDef student fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef removed fill:#fef2f2,stroke:#dc2626,color:#7f1d1d,stroke-dasharray:5 3
    class S1,S2 student
    class S3 removed
```

1. 老師為每位學生產生一組 token，寫進 `tokens.json`，用自己的名字當使用者名稱
2. 老師啟動時讓其它電腦可以連線：

	```bash
	export MCP_HOST=0.0.0.0
	uv run server_http.py
	```

3. 學生在 Claude Desktop 設定中，把網址改成老師電腦的 IP，並加上 `--allow-http`（教室區網內使用 http 才需要）：

	```json
	"args": ["-y", "mcp-remote", "http://老師的IP:8000/mcp", "--allow-http", "--header", "Authorization:${AUTH_HEADER}"]
	```

4. 全班一起提問，老師的視窗會即時出現每位學生的查詢紀錄
5. 老師從 `tokens.json` 刪掉某位學生的 token 並重新啟動 → 那位學生立刻無法連線（模擬員工離職）

> 查詢老師電腦 IP：macOS `ipconfig getifaddr en0`；Windows `ipconfig`。電腦的防火牆要允許 8000 埠。

---

## 6. 正式導入企業時

課堂上用 `http://` 和 `mcp-remote` 練習。正式上線前，IT 部門還要處理以下事項：

```mermaid
flowchart LR
    subgraph 員工
        CD["Claude Desktop<br/>（組織連接器）"]
        CC["Claude Code<br/>VS Code"]
    end
    subgraph 公司["公司伺服器 / 雲端"]
        P["反向代理<br/>HTTPS 憑證"]
        M["MCP Server<br/>token 驗證・稽核紀錄"]
        LOG[("稽核紀錄")]
    end
    DB[("PostgreSQL<br/>唯讀帳號")]

    CD -->|"https + token"| P
    CC -->|"https + token"| P
    P --> M
    M --> LOG
    M -->|"只有 SELECT 權限"| DB

    classDef secure fill:#f0fdf4,stroke:#16a34a,color:#14532d
    class P,M secure
```

| 項目 | 做法 |
|---|---|
| **HTTPS** | 在 MCP Server 前面加上反向代理（例如 Nginx、Caddy）或部署到雲端平台，取得 SSL 憑證，網址變成 `https://mcp.公司網域/mcp` |
| **Claude 組織版連接器** | 使用 Claude Team / Enterprise 方案時，管理員（Owner）可以在**組織設定 → Connectors** 加入自訂連接器（custom connector），員工在 **Customize → Connectors** 按 **Connect** 就能使用，不用自己改設定檔。連接器必須使用 HTTPS 網址；用 token 驗證要在 **Request headers** 填入 `Bearer <token>`，此功能目前為 beta，只開放給部分組織 |
| **伺服器在公司內網** | 自訂連接器需要能從外部連到 MCP Server；伺服器只在內網時，參考 Claude 的 [MCP tunnels](https://claude.com/docs/connectors/mcp-tunnels/overview) |
| **單一登入（SSO）** | 員工很多時，改用 OAuth 讓員工用公司帳號登入，不必手動發 token |
| **權限分級** | 不同部門的 token 只能使用特定工具，例如只有業務部可以查會員資料 |
| **稽核紀錄保存** | 把稽核紀錄寫進檔案或資料庫，而不只是印在畫面上 |
| **資料庫帳號** | MCP Server 使用**只有 SELECT 權限**的資料庫帳號，而不是 `postgres` 管理員帳號 |

> 詳細設定請參考 Claude 官方文件：[新增自訂連接器](https://claude.com/docs/connectors/custom/remote-mcp)

---

## 7. 請 AI 把你的 MCP Server 改成遠端版

把單元 1 做好的 MCP Server 交給 AI，加上遠端連線和 token：

````markdown
請把這份 MCP Server(server.py)改成可以讓多人遠端連線的版本:

## 規定
- 使用 Streamable HTTP 傳輸:用 mcp.streamable_http_app() 產生 app,再用 uvicorn 執行
- 網址為 http://主機:埠號/mcp;主機和埠號從環境變數 MCP_HOST(預設 127.0.0.1)、MCP_PORT(預設 8000)讀取
- 每個請求都要檢查 HTTP 標頭 Authorization: Bearer <token>
  - token 清單放在 tokens.json,格式為 {"token": "使用者名稱"},不可以寫在程式裡
  - token 錯誤或沒有提供時,回傳 401 和繁體中文錯誤訊息
- 每個工具被呼叫時,印出稽核紀錄:時間、使用者名稱、工具名稱、參數
- 保留原本的安全規定:唯讀連線、%s 參數化查詢、Literal 限定欄位名稱
- 產生 tokens.example.json、.gitignore(排除 tokens.json)、requirements.txt
- 程式加上繁體中文註解

## 原本的程式
【貼上 server.py】
````

完成後用 [4.5](#45-測試門禁沒有-token-會被擋下) 的 curl 指令驗收：**沒有 token 一定要回傳 401**。

### 延伸挑戰（請 AI 完成）

1. **權限分級**：`tokens.json` 改成 `{"token": {"name": "林美玲", "department": "業務部"}}`，只有業務部可以使用 `top_customers`
2. **稽核紀錄存檔**：除了印在畫面上，同時寫進 `audit.log`
3. **token 到期**：每組 token 加上到期日，過期就拒絕連線

---

## 8. 常見問題

| 問題 | 解決方式 |
|---|---|
| curl 回傳 `401` | token 不在 `tokens.json` 裡，或 `Bearer` 和 token 中間少了空格；修改 `tokens.json` 後要**重新啟動** MCP Server |
| 啟動時找不到 `tokens.json` | 從 `tokens.example.json` 複製一份並改名 |
| Claude Desktop 沒有出現 shop 工具 | 確認 MCP Server 視窗還開著；確認已安裝 Node.js（終端機輸入 `npx -v`） |
| 其它電腦連不上 | 啟動前設定 `MCP_HOST=0.0.0.0`；網址用 IP 而不是 `localhost`；`mcp-remote` 加上 `--allow-http`；檢查防火牆 |
| 查詢時出現資料庫錯誤 | 確認 `DATABASE_URI` 指向已匯入 `shop.sql` 的資料庫 |
| 想看 Claude Desktop 的錯誤訊息 | macOS：`~/Library/Logs/Claude/mcp*.log`；Windows：`%APPDATA%\Claude\logs` |

---

## 下一步

👉 [單元 3：範例集](../3_範例集/)：5 個部門的 AI 助理，每個都可以用本機或遠端 + token 執行

👉 [期末專題](../#期末專題)：用 AI 為一間「公司」打造需要 token 的 MCP Server
