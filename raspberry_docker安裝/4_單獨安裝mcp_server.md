# 4. 在本機 Antigravity 設定全域 MCP 連線至樹莓派資料庫

在前面單元 2 與單元 3 中，我們已經在**樹莓派（Raspberry Pi）的 Docker 內**順利啟動了 PostgreSQL 資料庫伺服器（埠號 `5432`）。

現在，我們回到**本機電腦（Windows / Mac）**，使用極速免安裝的 Python 工具 **`uvx`** 設定**全域 MCP Server**，讓 **Antigravity** 在任何工作區都能隨時連線至樹莓派資料庫，純中文自然語言查庫與操作！

> [!NOTE]
> **為什麼採用全域設定？完全不需要建立虛擬環境！**
> * **免建虛擬環境（免 `.venv`）**：`uvx` 本身就是免安裝、暫存隔離執行工具，執行時會自動下載並運行 `postgres-mcp`，**完全不需要在專案或電腦內建立任何 Python 虛擬環境**！
> * **一次設定，處處可用**：設定在全域設定檔（`~/.gemini/config/mcp_config.json`），日後不論您開啟哪一個資料夾或專案，Antigravity 都能直接連線資料庫，無需在每個專案重複設定。
> * **學生電腦免裝 Docker**：只有遠端樹莓派需要 Docker，個人電腦只需要 `uvx` 即可。

---

## 🏗️ 連線運作架構

```mermaid
graph LR
    subgraph Local ["💻 您的個人電腦 (Windows / Mac)"]
        AG["Antigravity"]
        Config["全域設定檔<br/>~/.gemini/config/mcp_config.json"]
        MCPRunner["全域 MCP 執行緒<br/>(uvx postgres-mcp)"]
        AG --> Config --> MCPRunner
    end

    subgraph Pi ["🍓 Raspberry Pi 樹莓派（伺服器端）"]
        subgraph Docker ["Docker 容器環境"]
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

---

## 步驟 4.1：確認電腦安裝 `uv`（附帶 `uvx`）

`uv` 是極速的 Python 工具管理器，安裝時會自帶 **`uvx`** 指令，能在不污染全域環境的前提下即時執行各類 MCP 工具。

您可以直接在 Antigravity 聊天框發送以下指令：

> 「請幫我檢查這台電腦有沒有安裝 `uv`，如果沒有，請幫我安裝好 `uv`（包含 `uvx`）並確認安裝成功。」

* **AI 自動化成果**：Antigravity 會自動辨識您的作業系統（Windows 或 Mac），執行官方安裝腳本，並驗證 `uvx` 可正常執行。

---

## 步驟 4.2：設定全域 `~/.gemini/config/mcp_config.json`

全域 MCP 設定檔位於使用者的個人家目錄下：
* **Mac / Linux**：`~/.gemini/config/mcp_config.json`（即 `/Users/使用者名稱/.gemini/config/mcp_config.json`）
* **Windows**：`%USERPROFILE%\.gemini\config\mcp_config.json`（即 `C:\Users\使用者名稱\.gemini\config\mcp_config.json`）

### 1. 設定內容

請將以下設定寫入全域設定檔中（請將 `username`、`password`、`localhost`、`dbname` 替換為您的樹莓派連線資訊）：

```json
{
  "mcpServers": {
    "raspberry-postgres": {
      "command": "uvx",
      "args": [
        "postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://username:password@localhost:5432/dbname"
      }
    }
  }
}
```

> [!TIP]
> 您也可以直接對 Antigravity 說：
> 「請幫我更新全域 `~/.gemini/config/mcp_config.json` 中的 `postgres` MCP 設定：
> command 使用 `uvx`，args 傳入 `postgres-mcp` 與 `--access-mode=unrestricted`，連線 URI 為 `postgresql://postgres:您的密碼@樹莓派IP:5432/postgres`」

---

### 2. 關鍵參數詳細說明

1. **`"command": "uvx"`**：
   使用 `uvx` 免安裝工具，自動管理執行環境，完全不需要手動建立虛擬環境。
2. **`"args": ["postgres-mcp", ...]`**：
   指定啟動官方開源的 PostgreSQL MCP Server。
3. **`"--access-mode=unrestricted"`（存取模式）**：
   * **`unrestricted`（完整不受限模式）**：允許執行查詢、建立資料表（CREATE TABLE）、修改（UPDATE）、寫入（INSERT）及刪除等所有操作。
   * **`restricted`（唯讀保護模式）**：若您目前處於學習階段，希望 AI 僅做查詢與教學助教、防止誤改資料庫，可改設為 `--access-mode=restricted`。
4. **`DATABASE_URI`**：
   連線字串格式如下：
   ```text
   postgresql://【使用者帳號】:【密碼】@【樹莓派主機位址】:【埠號】/【資料庫名稱】
   ```

| 欄位片段 | 代表意義 | 範例與白話說明 |
|---|---|---|
| `postgresql://` | **連線協定** | 指定連線至 PostgreSQL 資料庫 |
| `username` | **帳號** | 預設最高管理員為 `postgres` |
| `:password` | **密碼** | 單元 2 啟動容器時設定的密碼（例如 `:raspberry`） |
| `@localhost` / `@樹莓派IP` | **主機位址** | 樹莓派在區網的 IP（例如 `192.168.1.150`）或主機名（例如 `pi3robert0301.local`） |
| `:5432` | **連接埠** | PostgreSQL 預設服務埠號 `5432` |
| `/dbname` | **資料庫名稱** | 目標資料庫名稱（預設為 `postgres`） |

---

## 步驟 4.3：重新載入與連線驗證

儲存設定後，**重新載入視窗**（或重開 Antigravity），即可在聊天框直接對 AI 提問測試：

1. **查看資料庫狀態**：
   > 「請透過 postgres MCP 連線到我的樹莓派資料庫，幫我列出目前所有的資料表。」
2. **查詢連線版本**：
   > 「請告訴我目前連線的 PostgreSQL 版本是什麼？」

當看到 Antigravity 自動調用 `postgres` MCP 工具並回傳資料庫內容時，就代表全域設定大功告成！

---

## 步驟 4.4：實戰應用情境

因為設定了全域 MCP，無論您在哪個專案工作區，都能隨時與資料庫互動：

### 🔍 情境 1：檢視資料表結構（Schema 探索）
> 「請連線樹莓派資料庫，幫我列出目前資料庫內所有資料表的結構與欄位型態。」

### 💡 情境 2：AI 協助撰寫與除錯 SQL
> 「我想查詢各部門中薪水前 3 高的員工名單，請幫我寫出標準 SQL 語法並解釋背後原理。」

### 🚀 情境 3：全自動維護或建立資料表
因為使用了 `--access-mode=unrestricted`，AI 擁有完整權限，可直接為您建立測試資料表或批次寫入資料：
> 「請在樹莓派資料庫中建立一張名為 `students` 的學生資料表，包含 id、姓名、成績，並幫我插入 5 筆測試資料。」

---

👉 **下一步：[5. 樹莓派端 Docker Compose 伺服器維護指南](./5_docker_compose雙容器.md)**
