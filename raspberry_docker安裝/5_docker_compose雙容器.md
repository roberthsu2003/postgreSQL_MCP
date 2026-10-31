# 5. 進階管理：在樹莓派使用 Docker Compose 管理伺服器容器

在單元 2 中，我們使用 `docker run` 指令啟動了 PostgreSQL。然而，當指令包含密碼、埠號對應（`-p`）、資料卷（`-v`）與開機自動重啟（`--restart`）等多項參數時，每次手動輸入較繁瑣。

**Docker Compose** 解決了這個問題：**只需撰寫一份 `docker-compose.yml` 設定檔，一行指令就能管理樹莓派上的伺服器容器服務！**

---

## 🏗️ 架構分工回顧

* 🍓 **樹莓派（伺服器端）**：使用 Docker Compose 啟動並常駐執行 PostgreSQL 容器（埠號 `5432`）。
* 💻 **本機電腦（操作端）**：
  * **DBeaver**：透過 SSH 隧道或區網 IP 管理資料表與寫 SQL。
  * **Antigravity**：透過專案級 MCP（`.agents/mcp_config.json`）連線查庫與寫程式。

---

## 步驟 5.1：建立專案資料夾與 `docker-compose.yml`

在樹莓派終端機建立 compose 專案目錄：

```bash
mkdir -p ~/postgres-compose && cd ~/postgres-compose
nano docker-compose.yml
```

貼入以下內容（請將 `yourpassword` 替換為您的自訂密碼）：

```yaml
services:
  # PostgreSQL 資料庫伺服器
  postgres:
    image: postgres:17
    container_name: my-postgres
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: yourpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mcp-net

volumes:
  # 資料持久化具名磁碟卷
  postgres_data:

networks:
  # 專屬網路（供未來第 8 章單元 4 擴充自訂企業 MCP Server 雙容器使用）
  mcp-net:
    driver: bridge
```

> 💡 **編輯器操作提示**：按 `Ctrl + O` 儲存，按 `Enter` 確認檔名，按 `Ctrl + X` 離開 nano。
> 🔗 **未來擴充預告**：這條 `mcp-net` 專屬網路將在 **[第 8 章 單元 4：部署至樹莓派 Docker 雙容器](../mcp_server/4_樹莓派Docker容器部署/)** 派上用場，讓自訂的企業 MCP Server 容器與 PostgreSQL 容器在樹莓派內部高速直連！

---

## 步驟 5.2：一行指令啟動伺服器服務

在含有 `docker-compose.yml` 的目錄下執行：

```bash
docker compose up -d
```

### 指令解說：
* `up`：依據 `docker-compose.yml` 的定義建立並啟動服務。
* `-d`：在背景執行（Detached mode），不會佔用終端機。

---

## 步驟 5.3：常用維護與狀態檢查指令

在樹莓派的 `~/postgres-compose` 目錄下：

- **查看運行狀態：**
  ```bash
  docker compose ps
  ```
- **查看資料庫日誌：**
  ```bash
  docker compose logs -f postgres
  ```
- **停止服務：**
  ```bash
  docker compose stop
  ```
- **重新啟動服務：**
  ```bash
  docker compose restart
  ```
- **更新或修改設定後重新載入：**
  ```bash
  docker compose up -d
  ```

---

## 步驟 5.4：從個人電腦驗證連線

容器啟動後，請回到您的個人電腦：
1. **打開 DBeaver**：點擊已設定好的樹莓派連線，確認能順利連線並展開資料表。
2. **打開 Antigravity**：提問「請檢查樹莓派資料庫連線是否正常」，確認 AI 能夠透過專案級 MCP 正常讀取資料庫。

---

## 🔍 常見問題排查

1. **若原本已用 `docker run` 啟動過 `my-postgres`：**
   若執行 `docker compose up -d` 時出現「The container name "/my-postgres" is already in use」錯誤，請先執行：
   ```bash
   docker rm -f my-postgres
   docker compose up -d
   ```
   > 放心，資料儲存在具名資料卷中，容器移除並以 Compose 重建後，既有資料依然完好如初。

2. **DBeaver 顯示連線超時（Timeout）：**
   - 檢查樹莓派上的容器狀態：`docker compose ps` 是否處於 `Up` 狀態。
   - 在個人電腦檢查網路是否通暢：`ping <樹莓派IP>`。
   - 若樹莓派有啟用防火牆，放行 5432 埠：`sudo ufw allow 5432/tcp`。
