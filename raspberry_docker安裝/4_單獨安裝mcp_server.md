# 4. 在本機 Antigravity 設定專案級 MCP 連線至樹莓派資料庫

在前面單元 2 中，我們已經在**樹莓派（Raspberry Pi）的 Docker 內**順利啟動了 PostgreSQL 資料庫伺服器（埠號 `5432`）。

現在，我們回到**本機電腦（Mac / Windows）**，在 **Antigravity** 中透過**專案級 MCP（Project-level MCP）**連線至樹莓派資料庫，讓 AI 能直接透過自然語言幫我們查詢資料表！

---

## 🏗️ 連線運作架構

```mermaid
graph LR
    subgraph Local ["💻 您的個人電腦 (Local PC / Mac)"]
        AG["Antigravity / Antigravity IDE"]
        Config[".agents/mcp_config.json"]
        MCPRunner["本地 MCP 執行緒<br/>(Docker / uvx)"]
        AG --> Config --> MCPRunner
    end

    subgraph Pi ["🍓 Raspberry Pi 樹莓派（伺服器端）"]
        subgraph Docker ["Docker 容器"]
            PG["my-postgres 容器<br/>(PostgreSQL 伺服器)<br/>埠號: 5432"]
        end
    end

    MCPRunner ==>|"透過網路連線 (樹莓派 IP: 5432)"| PG

    classDef client fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1
    classDef server fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e
    classDef docker fill:#f0fdf4,stroke:#16a34a,stroke-width:2px,color:#15803d
    class Local client
    class Pi server
    class Docker docker
```

> [!NOTE]
> * **樹莓派責任**：專門執行資料庫容器，提供穩定的 5432 埠服務與資料持久化。
> * **本機電腦責任**：執行 Antigravity 與專案 MCP，透過區域網路 IP 連線至樹莓派。
> * **免全域安裝**：設定檔位於本專案目錄內，只有打開本專案時才會啟動，完全不污染您的個人電腦環境。

---

## 步驟 4.1：在本機電腦編輯 `.agents/mcp_config.json`

請在本機電腦開啟本專案根目錄下的 [`.agents/mcp_config.json`](file:///Users/roberthsu2003/Documents/GitHub/postgreSQL_MCP/.agents/mcp_config.json)，加入樹莓派資料庫連線設定：

```json
{
  "mcpServers": {
    "raspberry-postgres": {
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
        "DATABASE_URI": "postgresql://postgres:yourpassword@<樹莓派IP或主機名稱>:5432/postgres"
      }
    }
  }
}
```

> 💡 請將 `<樹莓派IP或主機名稱>` 替換為您的樹莓派 IP（例如 `192.168.1.150` 或 `raspberrypi.local`），並將 `yourpassword` 替換為單元 2 設定的資料庫密碼。

---

### 🔍 白話詳細拆解：什麼是 `DATABASE_URI`？

連線字串的通用公式非常固定：
```text
postgresql://【帳號】:【密碼】@【主機位址】:【埠號】/【資料庫名稱】
```

將這一段文字拆開來看：

| 欄位片段 | 代表意義 | 白話說明 |
|---|---|---|
| `postgresql://` | **連線協定** | 告訴程式這是要連線到 PostgreSQL 資料庫 |
| `postgres` | **帳號 (Username)** | PostgreSQL 預設最高管理者的帳號名稱就叫做 `postgres` |
| `:yourpassword` | **密碼 (Password)** | 單元 2 啟動資料庫時自己設定的密碼 |
| `@<樹莓派IP>` | **主機位址 (Host)** | 樹莓派在區域網路中的 IP（例如 `192.168.1.150`）或主機名 |
| `:5432` | **連接埠 (Port)** | 樹莓派 PostgreSQL 對外暴露的服務埠號 |
| `/postgres` | **資料庫名稱 (Database)** | 連線進入的目標資料庫名稱（預設為 `postgres`） |

> [!TIP]
> **關於 `--access-mode` 存取模式：**
> * **教學實戰推薦**：`--access-mode=unrestricted`（不受限模式），AI 不僅能做查詢，還能協助建立資料表（CREATE TABLE）、新增與更新資料。
> * **正式唯讀模式**：`--access-mode=restricted`，AI 只能做 `SELECT` 查詢，不能改動資料。

---

## 步驟 4.2：免安裝 Docker 的替代方案（使用 uvx）

若您的個人電腦尚未安裝 Docker Desktop，也可以直接使用 Python 工具 `uvx` 喚起 MCP，效果完全相同：

```json
{
  "mcpServers": {
    "raspberry-postgres": {
      "command": "uvx",
      "args": [
        "--with",
        "mcp<2",
        "postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@<樹莓派IP或主機名稱>:5432/postgres"
      }
    }
  }
}
```

---

## 步驟 4.3：在本機 Antigravity 中提問測試

儲存設定後，直接在您本機的 **Antigravity** 聊天框中輸入中文指令：

1. **查看資料庫狀態**：
   > 「請連線到我的樹莓派資料庫，幫我列出目前所有的資料表。」
2. **查詢結構**：
   > 「請告訴我目前資料庫有哪些 schema 和權限？」

當看到 Antigravity 自動調用 `raspberry-postgres` MCP 工具並回傳資料庫內容時，就代表本機 AI 與樹莓派資料庫已成功連線！

---

👉 **下一步：[5. 樹莓派端 Docker Compose 伺服器維護指南](./5_docker_compose雙容器.md)**
