# 單元 4：正式上線：部署至 Raspberry Pi Docker 雙容器

> **本單元目標**：把[單元 3](../3_企業導入_遠端MCP與token/) 做好的遠端 Token 版 MCP Server 打包成 Docker 容器，放進 **Raspberry Pi（樹莓派）** 與 PostgreSQL 組成**雙容器架構**，實現 24 小時常駐、資料庫密碼不外洩的企業共用環境。　[← 回第 8 章](../)

參考設定檔：[Dockerfile](./Dockerfile)、[docker-compose.yml](./docker-compose.yml)

---

## 1. 為什麼要放進樹莓派 Docker？

在[單元 1](../1_用AI建立MCP_server/) 與[單元 2](../2_寫入型MCP_server/) 中，我們在**自己的電腦**上執行 MCP Server（個人開發階段）；在[單元 3](../3_企業導入_遠端MCP與token/) 中，我們加上了 HTTP 與 Token 門禁，但如果伺服器還是開在自己的筆電終端機裡，**筆電一闔上，全公司就斷線了**。

將自訂 MCP Server 放進 **Raspberry Pi 的 Docker** 與 PostgreSQL 一起運行，就完成了真正的企業級部署：

```mermaid
graph LR
    subgraph Clients ["💻 員工的個人電腦（Mac / Windows）"]
        E1["員工 A（林美玲）<br/>Antigravity<br/>Token A"]
        E2["員工 B（李佳穎）<br/>Antigravity<br/>Token B"]
    end

    subgraph Pi ["🍓 Raspberry Pi 樹莓派（公司伺服器）"]
        subgraph Docker ["Docker 內部網路 (mcp-net)"]
            MCP["my-mcp-server 容器<br/>(自訂 MCP Server + Token 門禁)<br/>對外埠號: 8000"]
            PG[("my-postgres 容器<br/>(PostgreSQL 資料庫)<br/>內部埠號: 5432")]
            MCP ==>|"② Docker 內網高速直連<br/>@postgres:5432"| PG
        end
        TF["📄 tokens.json<br/>（掛載入容器）"]
        TF -.-> MCP
    end

    E1 & E2 ==>|"① 區網 HTTP + Bearer Token<br/>http://樹莓派IP:8000/mcp"| MCP

    classDef client fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#0369a1
    classDef server fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e
    classDef docker fill:#f0fdf4,stroke:#16a34a,stroke-width:2px,color:#15803d
    class Clients client
    class Pi server
    class Docker docker
```

| 比較項目 | 個人開發階段（單元 1–2） | 企業樹莓派容器階段（本單元） |
| :--- | :--- | :--- |
| **MCP Server 在哪裡跑** | 自己的電腦（隨 Antigravity 啟動與關閉） | **樹莓派 Docker 容器**（`restart: unless-stopped` 24 小時常駐） |
| **MCP 怎麼連資料庫** | 跨區域網路連 `樹莓派IP:5432` | **Docker 內部網路直連 `@postgres:5432`**（不經過外部網路，極快又安全） |
| **員工電腦需要什麼** | 需要 Python、`uv`、程式碼與**資料庫密碼** | **只需要樹莓派網址 + 自己的 Token**（免裝 Python、拿不到資料庫密碼） |
| **資料庫 `5432` 埠** | 必須對區網開放 | 正式上線時**可對外關閉**，只讓同在 `mcp-net` 的 MCP 容器存取 |

---

## 2. 事前準備

1. 已完成[第 1 章：在樹莓派使用 Docker Compose 管理伺服器容器](../../raspberry_docker安裝/5_docker_compose雙容器.md)，樹莓派上已有 `~/postgres-compose` 目錄與運作中的 PostgreSQL。
2. 樹莓派的 PostgreSQL 已建立 `practice` 資料庫並匯入 [shop.sql](../../範例資料庫/中文範例資料庫/#-網路商店-shop)。

---

## 3. 動手做：在樹莓派建立 MCP Server 容器

### 步驟 3.1：在樹莓派建立 `my-mcp-server` 資料夾

請透過 SSH 連線到你的樹莓派，進入原本第 1 章建立的 `~/postgres-compose` 目錄，並在裡面新增一個 `my-mcp-server` 子目錄：

```bash
cd ~/postgres-compose
mkdir -p my-mcp-server
```

把單元 3 的程式與本單元的 `Dockerfile` 放進 `~/postgres-compose/my-mcp-server/`，最終目錄結構如下：

```text
~/postgres-compose/
├── docker-compose.yml          # 雙容器設定檔（postgres + mcp-server）
└── my-mcp-server/
    ├── Dockerfile              # 打包 MCP Server 的藍圖
    ├── requirements.txt        # Python 套件清單
    ├── server_http.py          # 單元 3 的網路商店營運助理程式
    └── tokens.json             # 員工 Token 清單（掛載進容器）
```

> 💡 **如何把個人電腦的檔案傳到樹莓派？**
> 在**個人電腦**的終端機執行 `scp` 指令即可一鍵傳送：
> ```bash
> scp mcp_server/3_企業導入_遠端MCP與token/server_http.py \
>     mcp_server/3_企業導入_遠端MCP與token/requirements.txt \
>     mcp_server/4_樹莓派Docker容器部署/Dockerfile \
>     pi@<樹莓派IP>:~/postgres-compose/my-mcp-server/
> ```

---

### 步驟 3.2：看懂 [`Dockerfile`](./Dockerfile)

```dockerfile
FROM python:3.12-slim

# 讓 Python 的 print() 稽核紀錄即時輸出到 Docker logs，不會被緩衝區卡住
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 先複製並安裝套件（利用 Docker 快取機制，改程式碼時不用重裝套件）
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 複製 MCP Server 程式碼
COPY server_http.py .

# 開放 8000 埠供區域網路員工連線
EXPOSE 8000

# 啟動遠端 HTTP + Token 驗證的 MCP Server
CMD ["python", "server_http.py"]
```

> [!TIP]
> **為什麼要設定 `ENV PYTHONUNBUFFERED=1`？**
> Python 在背景容器執行時，預設會把 `print()` 暫存在記憶體緩衝區。加上這行設定後，每當員工查詢資料，`audit()` 印出的稽核紀錄才會**立刻**出現在樹莓派的 `docker compose logs` 畫面上！

---

### 步驟 3.3：在樹莓派準備 `tokens.json`

在樹莓派的 `~/postgres-compose/my-mcp-server/` 目錄下建立 `tokens.json`：

```bash
cd ~/postgres-compose/my-mcp-server
nano tokens.json
```

填入發給員工的 Token 清單（可先用 `python3 -c "import secrets; print(secrets.token_urlsafe(32))"` 產生）：

```json
{
  "kV3x9QmZ_replace_with_real_token_1": "林美玲(業務部)",
  "Rq81bTnW_replace_with_real_token_2": "李佳穎(行銷部)"
}
```

---

### 步驟 3.4：更新樹莓派的 [`docker-compose.yml`](./docker-compose.yml)

回到 `~/postgres-compose` 目錄，編輯 `docker-compose.yml`，在原本的 `postgres` 服務下方加入 `mcp-server` 服務：

```bash
cd ~/postgres-compose
nano docker-compose.yml
```

完整內容如下（請將兩處 `yourpassword` 改為你的資料庫密碼）：

```yaml
services:
  # 1. PostgreSQL 資料庫伺服器（沿用第 1 章的資料卷與設定）
  postgres:
    image: postgres:17
    container_name: my-postgres
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: yourpassword
    ports:
      - "5432:5432"   # 供教學時 DBeaver 遠端管理；正式企業環境可移除此埠映射，徹底隱藏資料庫
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mcp-net

  # 2. 自訂企業 MCP Server 容器（Streamable HTTP + Token 門禁）
  mcp-server:
    build: ./my-mcp-server
    container_name: my-mcp-server
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      # 注意：主機位址直接填容器服務名稱 postgres，走 Docker 內部高速網路直連！
      DATABASE_URI: postgresql://postgres:yourpassword@postgres:5432/practice
      MCP_HOST: 0.0.0.0
      MCP_PORT: 8000
    ports:
      - "8000:8000"   # 對區域網路開放 8000 埠，員工帶 Bearer Token 連線
    volumes:
      # 將樹莓派上的 tokens.json 掛載進容器（唯讀），新增或註銷員工 Token 免重新打包映像檔
      - ./my-mcp-server/tokens.json:/app/tokens.json:ro
    networks:
      - mcp-net

volumes:
  postgres_data:

networks:
  mcp-net:
    driver: bridge
```

> [!IMPORTANT]
> **兩大架構關鍵設計：**
> 1. **`@postgres:5432` 內網直連**：因為兩個容器都在 `mcp-net` 網路內，Docker 內建 DNS 會自動把主機名稱 `postgres` 解析為資料庫容器的內部 IP，不用填樹莓派的外部 IP！
> 2. **Volume 掛載 `tokens.json`**：將 `./my-mcp-server/tokens.json` 掛載到容器內的 `/app/tokens.json`。當有新進員工或員工離職時，只要在樹莓派修改 `tokens.json` 並執行 `docker compose restart mcp-server`，3 秒鐘即刻生效，完全不必重新 `build` 映像檔！

---

### 步驟 3.5：打包並啟動雙容器

在樹莓派 `~/postgres-compose` 目錄下執行：

```bash
docker compose up -d --build
```

檢查兩個容器是否都處於 `Up` 狀態：

```bash
docker compose ps
```

預期會看到 `my-postgres`（`5432` 埠）與 `my-mcp-server`（`8000` 埠）同時在背景穩定運行！

查看 MCP Server 的即時啟動狀態與稽核紀錄：

```bash
docker compose logs -f mcp-server
```

會看到：
```text
my-mcp-server  | MCP Server 已啟動:http://0.0.0.0:8000/mcp(共 2 組 token)
my-mcp-server  | INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

## 4. 員工端：在個人電腦用 Antigravity 連線

現在回到你的**個人電腦（Mac / Windows）**，員工電腦上**完全不需要有 `server_http.py` 程式碼，也不需要知道資料庫密碼**！

### 步驟 4.1：設定專案級 `.agents/mcp_config.json`

在個人電腦開啟本專案的 [`.agents/mcp_config.json`](file:///Users/roberthsu2003/Documents/GitHub/postgreSQL_MCP/.agents/mcp_config.json)，加入連線至樹莓派 `8000` 埠的設定：

```json
{
  "mcpServers": {
    "company-shop-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "http://<樹莓派IP>:8000/mcp",
        "--allow-http",
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

> 💡 請將 `<樹莓派IP>` 替換為樹莓派的區網 IP（例如 `192.168.1.150`），並將 `你的token` 替換為 `tokens.json` 中的 Token。

### 步驟 4.2：提問並觀察樹莓派上的即時稽核紀錄

1. 在個人電腦的 **Antigravity** 對話框提問：
   > 「請問 2025 年 11、12 月哪個商品分類賣最好？另外目前有哪些商品庫存低於 10 件需要補貨？」
2. 看向樹莓派的終端機（`docker compose logs -f mcp-server`），會即時跳出稽核紀錄：
   ```text
   my-mcp-server  | [2026-10-31 20:05:12] 林美玲(業務部) 呼叫 sales_summary {'start_date': '2025-11-01', 'end_date': '2025-12-31', 'group_by': '分類'}
   my-mcp-server  | [2026-10-31 20:05:14] 林美玲(業務部) 呼叫 low_stock_products {'threshold': 10}
   ```

---

## 5. 常用維護指令速查（樹莓派端）

| 情境 | 在樹莓派 `~/postgres-compose` 執行的指令 |
| :--- | :--- |
| **查看即時稽核紀錄** | `docker compose logs -f mcp-server` |
| **修改了 `tokens.json`（新增/註銷員工）** | `docker compose restart mcp-server`（免重編，秒生效） |
| **修改了 `server_http.py`（新增/修改工具）** | `docker compose up -d --build mcp-server`（重新打包並重啟） |
| **查看雙容器運行狀態** | `docker compose ps` |

---

## 下一步

學會了如何將單一 MCP Server 部署到樹莓派 Docker 後，如果公司有**客服部、教務處、圖書館、理財部**等多個部門，該如何共用同一套 Token 與安全底層？

👉 **[單元 5：企業各部門範例集](../5_範例集/)**：5 個部門的 AI 助理範本，支援本機開發（`stdio`）與樹莓派容器（`http + Token`）一鍵切換！

