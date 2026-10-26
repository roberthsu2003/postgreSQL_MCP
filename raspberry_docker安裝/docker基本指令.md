# Docker 與 Docker Compose 常用基本指令

本指南整理了在 Raspberry Pi 上管理 **PostgreSQL** 與未來的 **PostgreSQL MCP Server** 所需的核心指令。

---

## 目錄
1. [容器建立與執行 (Run)](#1-容器建立與執行-run)
2. [容器狀態檢查 (Check & Logs)](#2-容器狀態檢查-check--logs)
3. [容器啟動、停止與重啟 (Start, Stop, Restart)](#3-容器啟動停止與重啟-start-stop-restart)
4. [進入容器內部互動 (Exec)](#4-進入容器內部互動-exec)
5. [容器刪除與清理 (Remove)](#5-容器刪除與清理-remove)
6. [映像檔與資料卷管理 (Images & Volumes)](#6-映像檔與資料卷管理-images--volumes)
7. [Docker Compose 多容器管理 (重點核心)](#7-docker-compose-多容器管理-重點核心)

---

## 1. 容器建立與執行 (Run)

### 常用建立指令
```bash
docker run -d \
  --name <容器名稱> \
  -p <主機埠號>:<容器埠號> \
  -e <環境變數名稱>=<值> \
  -v <資料卷名稱>:<容器內掛載路徑> \
  --restart unless-stopped \
  <映像檔名稱>
```

#### 範例（以 PostgreSQL 為例）：
```bash
docker run -d \
  --name my-postgres \
  -e POSTGRES_PASSWORD=yourpassword \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres
```

| 常用參數 | 作用 |
|---|---|
| `-d` | 背景執行（Detached mode），終端機不會被佔用 |
| `--name` | 指定容器自訂名稱（例如 `my-postgres`），後續操作用此名稱很方便 |
| `-p` | 連接埠映射（主機 Port:容器 Port），例如 `-p 5432:5432` |
| `-e` | 設定環境變數（例如資料庫密碼 `POSTGRES_PASSWORD`） |
| `-v` | 掛載資料卷（Volume）或目錄，做資料持久化，避免容器刪除後資料遺失 |
| `--restart unless-stopped` | 只要樹莓派開機，容器自動重新啟動（除非手動停止） |

---

## 2. 容器狀態檢查 (Check & Logs)

### 2.1 查看運行中的容器
```bash
docker ps
```
> 顯示欄位包含：`CONTAINER ID`、`IMAGE`、`STATUS`（運行時間）、`PORTS`（連接埠映射）、`NAMES`（容器名稱）。

### 2.2 查看所有容器（包含已停止的容器）
```bash
docker ps -a
```
> 如果執行指令後容器立刻跳出退出（Exited），可透過此指令找出問題容器。

### 2.3 查看容器日誌 (Logs)
當容器啟動失敗、資料庫連不上或 MCP 報錯時，第一時間看日誌：
```bash
# 查看近期日誌
docker logs <容器名稱>

# 即時追蹤最新日誌（類似 tail -f，按 Ctrl+C 離開）
docker logs -f <容器名稱>

# 只看最後 50 行日誌
docker logs --tail 50 <容器名稱>
```

### 2.4 查看容器詳細資訊 (Inspect)
查看容器的內部 IP、掛載路徑、環境變數等：
```bash
docker inspect <容器名稱>
```

---

## 3. 容器啟動、停止與重啟 (Start, Stop, Restart)

| 操作 | 指令 | 說明 |
|---|---|---|
| **停止容器** | `docker stop my-postgres` | 優雅停止運行中的容器 |
| **啟動容器** | `docker start my-postgres` | 重新啟動已停止的既有容器（資料不會遺失） |
| **重啟容器** | `docker restart my-postgres` | 重新啟動容器（修改設定檔或服務異常時常用） |

---

## 4. 進入容器內部互動 (Exec)

在容器已經執行的狀態下，可以在容器內部執行命令或進入終端機：

### 4.1 進入容器的 Bash/Sh 終端環境
```bash
docker exec -it <容器名稱> /bin/bash
# 若映像檔沒有 bash，可改用 sh：
docker exec -it <容器名稱> /bin/sh
```
> 輸入 `exit` 即可退出容器，不會影響容器運行。

### 4.2 直接在容器內執行單一指令（以 psql 為例）
```bash
docker exec -it my-postgres psql -U postgres
```

---

## 5. 容器刪除與清理 (Remove)

若需要重新設定容器、換參數或重建：

```bash
# 1. 先停止容器
docker stop my-postgres

# 2. 刪除容器
docker rm my-postgres

# 強制刪除正在執行的容器（停止 + 刪除一步完成）
docker rm -f my-postgres
```
> [!NOTE]
> 刪除容器不會刪除掛載的具名資料卷（Volume），所以只要重新 `run` 掛載同一個 volume，資料庫資料依然存在。

---

## 6. 映像檔與資料卷管理 (Images & Volumes)

### 6.1 映像檔指令
- **查看本地所有映像檔**：`docker images`
- **下載最新映像檔**：`docker pull postgres`
- **刪除不要的映像檔**：`docker rmi <映像檔名稱或ID>`

### 6.2 資料卷指令 (Volume)
- **查看所有資料卷**：`docker volume ls`
- **檢查特定資料卷的本機實體存放路徑**：`docker volume inspect postgres_data`
- **刪除未使用的資料卷**：`docker volume prune`

---

## 7. Docker Compose 多容器管理 (重點核心)

未來我們會同時運行 **2 個容器**：
1. **PostgreSQL** 資料庫
2. **PostgreSQL MCP Server**（提供 AI 查詢資料庫的 MCP 工具服務）

使用 **Docker Compose** 只需一個 `docker-compose.yml` 檔案，即可一次管理這兩個服務的相依性、網路通訊與自動重啟。

### 7.1 常見 Compose 指令對照表

| 操作 | 指令 | 說明 |
|---|---|---|
| **一次啟動全部容器** | `docker compose up -d` | 讀取目前的 `docker-compose.yml`，在背景建立並啟動所有容器與虛擬網路 |
| **查看多容器狀態** | `docker compose ps` | 查看目前專案底下的所有容器運行狀態與 Port |
| **查看多容器日誌** | `docker compose logs -f` | 同時看 2 個容器的即時日誌（不同服務會有不同顏色） |
| **只看單一服務日誌** | `docker compose logs -f postgres` | 只看 postgres 服務的日誌 |
| **重啟服務** | `docker compose restart` | 一次重新啟動所有容器 |
| **停止所有服務** | `docker compose stop` | 停止所有容器（不刪除容器與網路） |
| **啟動已停止的服務** | `docker compose start` | 重新啟動所有已建立的容器 |
| **完整關閉並移除** | `docker compose down` | 停止並移除所有容器與專屬網路（資料卷不受影響） |
| **關閉並同時刪除資料卷** | `docker compose down -v` | ⚠️ 會同時清空資料庫 volume，請謹慎使用 |
| **進入指定服務容器** | `docker compose exec postgres bash` | 進入 compose 內指定的服務容器執行命令 |

### 7.2 一次啟動 2 個容器的範例預覽 (`docker-compose.yml`)
```yaml
services:
  # 1. PostgreSQL 資料庫服務
  postgres:
    image: postgres:latest
    container_name: my-postgres
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: yourpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mcp-network

  # 2. PostgreSQL MCP Server 服務
  postgres-mcp:
    image: <mcp-server-image>  # 等一下要安裝的 MCP 映像檔
    container_name: my-postgres-mcp
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://postgres:yourpassword@postgres:5432/postgres
    ports:
      - "8000:8000"
    depends_on:
      - postgres
    networks:
      - mcp-network

volumes:
  postgres_data:

networks:
  mcp-network:
    driver: bridge
```

> [!TIP]
> 在同一個 `docker-compose.yml` 內的容器，彼此可以直接使用**服務名稱**（例如 `postgres`）當作主機名稱（Host）進行溝通，不需要輸入複雜的 IP 位址！
