# 在 Raspberry Pi 上使用 Docker 安裝 PostgreSQL、DBeaver 與 MCP Server

本指南適用於在 **Raspberry Pi（樹莓派）** 環境下，透過 **Docker** 建立 PostgreSQL 資料庫服務與 **Postgres MCP Server**，並從個人電腦（Mac / Windows）使用 **DBeaver** 與 **Claude Desktop** 進行管理與 AI 查詢。

---

## 📋 完整目錄導覽

本手冊涵蓋從基礎 Docker 安裝到進階 Docker Compose 雙容器整合的完整步驟，您可以點選以下目錄快速跳轉：

1. **[在 Raspberry Pi 安裝 Docker](#1-在-raspberry-pi-安裝-docker)**
   * [1.1 更新系統套件](#步驟-11更新系統套件)
   * [1.2 使用官方腳本安裝 Docker](#步驟-12使用官方腳本安裝-docker)
   * [1.3 將目前使用者加入 docker 群組](#步驟-13將目前使用者加入-docker-群組)
   * [1.4 驗證 Docker 是否安裝成功](#步驟-14驗證-docker-是否安裝成功)
   * 📖 *[Docker 常用基本指令速查手冊](./docker基本指令.md)*
2. **[單獨使用 Docker Run 安裝與運行 PostgreSQL](#2-單獨使用-docker-run-安裝與運行-postgresql)**
   * [2.1 建立 Docker 自訂網路 mcp-net](#步驟-21建立-docker-自訂網路-mcp-net)
   * [2.2 建立並啟動 PostgreSQL 容器（加入網路、開機自啟與資料持久化）](#步驟-22建立並啟動-postgresql-容器)
   * [2.3 檢查容器狀態](#步驟-23檢查容器狀態)
   * [2.4 測試進入容器內的 psql](#步驟-24測試進入容器內的-psql可選)
3. **[使用 DBeaver 透過 SSH 連線至 Raspberry Pi](#3-使用-dbeaver-透過-ssh-連線至-raspberry-pi)**
   * [3.1 確認樹莓派的連線資訊](#步驟-31確認樹莓派的連線資訊)
   * [3.2 在 DBeaver 設定 SSH 隧道連線（附圖解）](#步驟-32在-dbeaver-設定-ssh-隧道連線)
     * [3.2.1 【主（Main）分頁】設定資料庫連線](#321-主main分頁設定資料庫連線)
     * [3.2.2 【SSH 分頁】設定 SSH 隧道](#322-ssh-分頁設定-ssh-隧道核心步驟)
     * [3.2.3 【PostgreSQL 分頁】與測試連線](#323-postgresql-分頁與測試連線)
   * [3.3 DBeaver 常用操作速查表](#步驟-33dbeaver-常用操作)
4. **[單獨使用 Docker Run 安裝 Postgres MCP Server 與連線設定](#4-單獨使用-docker-run-安裝-postgres-mcp-server-與連線設定)**
   * [4.1 使用 docker run 啟動 MCP Server 容器（加入同一網路）](#步驟-41使用-docker-run-單獨啟動-mcp-server-容器)
   * [4.2 個人電腦端 Claude Desktop 連線設定](#步驟-42個人電腦端-claude-desktop-連線設定)
5. **[進階整合：使用 Docker Compose 一次安裝與啟動 2 套服務（推薦）](#5-進階整合使用-docker-compose-一次安裝與啟動-2-套服務)**
   * [5.1 建立專案資料夾與 docker-compose.yml](#步驟-51建立專案資料夾與-docker-composeyml)
   * [5.2 一行指令一次啟動 2 套容器](#步驟-52一行指令一次啟動-2-套容器)
   * [5.3 檢查狀態與多容器彩色即時日誌](#步驟-53檢查狀態與日誌)
6. **[常用維護指令與常見問題](#6-常用維護指令與常見問題)**
   * [常用 Docker 維護指令](#常用-docker-維護指令)
   * [常見問題排查](#常見問題排查)

---

## 1. 在 Raspberry Pi 安裝 Docker

在樹莓派上安裝 Docker 最推薦官方提供的自動安裝腳本。

### 步驟 1.1：更新系統套件
打開樹莓派終端機（SSH 或本機終端機）：
```bash
sudo apt update && sudo apt upgrade -y
```

### 步驟 1.2：使用官方腳本安裝 Docker
執行官方便利腳本進行自動化安裝：
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 步驟 1.3：將目前使用者加入 docker 群組
為了避免每次執行 docker 指令都要加 `sudo`，請將目前使用者（例如預設的 `pi`）加入群組：
```bash
sudo usermod -aG docker $USER
```
> [!IMPORTANT]
> 加入群組後，請執行 `newgrp docker` 立即生效，或登出後重新登入（或重開機 `sudo reboot`）。

### 步驟 1.4：驗證 Docker 是否安裝成功
```bash
docker --version
docker compose version
```
如果能正確顯示版本號碼（例如 `Docker version 27.x.x...`），代表安裝成功！

> [!TIP]
> 📖 **必讀教學：[Docker 與 Docker Compose 常用基本指令速查](./docker基本指令.md)**
> 包含日常必備的 `docker run`、檢查狀態（`ps` / `logs`）、啟動、停止、進入容器互動，以及未來一次啟動 2 個服務（PostgreSQL + MCP Server）所需的 **Docker Compose** 完整指令攻略。

---

## 2. 單獨使用 Docker Run 安裝與運行 PostgreSQL

使用 Docker 運行 PostgreSQL 的最大好處是：**映像檔預設已允許遠端連線，且安裝、備份、刪除都極為乾淨**。

### 步驟 2.1：建立 Docker 自訂網路 `mcp-net`

因為我們預先知道後續需要將 PostgreSQL 與 **Postgres MCP Server** 互相連線，而 Docker 容器預設的 bridge 網路不支援直接用容器名稱（`my-postgres`）互相訪問。

因此，在啟動資料庫前，我們先建立一個專屬的虛擬網路：

```bash
docker network create mcp-net
```

---

### 步驟 2.2：建立並啟動 PostgreSQL 容器

在樹莓派終端機執行以下指令（直接指定加入 `--network mcp-net`，並請將 `yourpassword` 替換為你的密碼）：

```bash
docker run -d \
  --name my-postgres \
  --network mcp-net \
  -e POSTGRES_PASSWORD=yourpassword \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres
```

#### 參數詳細解說：
| 參數 | 說明 |
|---|---|
| `-d` | 在背景執行（Detached mode） |
| `--name my-postgres` | 指定容器名稱為 `my-postgres` |
| `--network mcp-net` | **加入專屬虛擬網路**：讓後續啟動的 MCP Server 可以直接用 `my-postgres` 名稱連線 |
| `-e POSTGRES_PASSWORD=yourpassword` | 設定預設管理者帳號 `postgres` 的密碼 |
| `-p 5432:5432` | 將樹莓派主機的 `5432` 埠對應到容器內的 `5432` 埠（允許連線） |
| `-v postgres_data:/var/lib/postgresql/data` | **資料持久化**：建立具名磁碟卷，確保容器重啟或重建時資料不會消失 |
| `--restart unless-stopped` | **開機自動重啟**：設定開機自動啟動容器（除非手動停止），樹莓派重開機後會自動啟動 |
| `postgres` | 使用 Docker Hub 官方最新版本的 PostgreSQL 映像檔（支援 ARM64 架構） |

> [!IMPORTANT]
> **未來開機會自動重新啟動：**
> 指令中的 `--restart unless-stopped` 參數非常重要！這代表**未來樹莓派每次開機或重新啟動後，Docker 都會自動把 PostgreSQL 容器啟動起來**。
> 您不需要每次開機都進終端機手動輸入指令，資料庫服務將會常駐運行。

> 💡 **提示**：若想省去手動建立網路的步驟，直接一次安裝與啟動 PostgreSQL + MCP Server 雙容器，可直接參考 [第 5 節：Docker Compose 一鍵啟動教學](#5-進階整合使用-docker-compose-一次安裝與啟動-2-套服務)。

---

### 步驟 2.3：檢查容器狀態
檢查容器是否正常運行：
```bash
docker ps
```
若狀態顯示為 `Up ... (healthy)` 或 `Up ...`，代表伺服器已正常啟動。

若想查看資料庫日誌：
```bash
docker logs my-postgres
```

---

### 步驟 2.4：測試進入容器內的 psql（可選）
如果想在樹莓派終端機內直接測試連線：
```bash
docker exec -it my-postgres psql -U postgres
```
成功進入後會看到 `postgres=#` 提示字元，輸入 `\q` 即可離開。

---

## 3. 使用 DBeaver 透過 SSH 連線至 Raspberry Pi

在個人電腦（Mac / Windows）上管理樹莓派的 PostgreSQL，最推薦且最安全的方式是**使用 DBeaver 內建的 SSH 隧道（SSH Tunnel）**。

透過 SSH 隧道連線的優勢：
- **極致安全**：所有傳輸經過 SSH 加密通道，不需要將 PostgreSQL 的 5432 埠暴露到外部網路。
- **免除網路防火牆困擾**：只要電腦能透過 SSH（埠號 22）連進樹莓派，就能連線到資料庫。

### 步驟 3.1：確認樹莓派的連線資訊
請確認您知道以下資訊：
1. **樹莓派的 IP 位址**：在樹莓派終端機執行 `hostname -I` 查詢（例如 `192.168.1.150`），或主機名稱（例如 `raspberrypi.local`）。
2. **樹莓派的 SSH 帳號與密碼**：例如帳號 `pi` 及其密碼。
3. **PostgreSQL 的密碼**：步驟 2.1 設定的 `yourpassword`。

### 步驟 3.2：在 DBeaver 設定 SSH 隧道連線

#### 3.2.1 【主（Main）分頁】設定資料庫連線
1. 開啟個人電腦上的 **DBeaver**。
2. 點選左上角按鈕：**Database → New Database Connection**。
3. 選擇 **PostgreSQL**，點選 **Next**。
4. 依下圖填入資料庫連線資訊：

![DBeaver 主設定](./images/dbeaver_main.png)

* **Connect by**：選擇 `Host`
* **Host**：`localhost`（因為透過 SSH 隧道轉發，對樹莓派內部而言即是 `localhost`）
* **Port**：`5432`
* **Database（預設資料庫）**：`postgres`
* **Authentication**：`Username/password`
* **Username（預設使用者名稱）**：`postgres`
* **Password**：步驟 2.1 建立容器時設定的密碼（例如 `yourpassword`）
* 勾選 **Save password**

---

#### 3.2.2 【SSH 分頁】設定 SSH 隧道（核心步驟）
切換到 **SSH** 分頁，依下圖填入樹莓派的 SSH 登入資訊：

![DBeaver SSH 隧道設定](./images/dbeaver_ssh.png)

* 勾選 **Use SSH Tunnel**
* **主機 / IP**：填入樹莓派的 mDNS 主機名稱（例如圖中的 `pi4robert03012gb.local`）或樹莓派的區網 IP（例如 `192.168.1.150`）
* **連接埠**：`22`（SSH 預設連接埠）
* **使用者名稱**：樹莓派的系統帳號（例如預設的 `pi`）
* **驗證方式**：選擇 `密碼`（若使用金鑰請選 `Public Key`）
* **密碼**：輸入樹莓派該使用者（如 `pi`）的 SSH 登入密碼
* 勾選 **儲存認證（Save password）**

---

#### 3.2.3 【PostgreSQL 分頁】與測試連線
1. 切換至 **PostgreSQL** 分頁，勾選 **Show all databases**（這樣建立的新資料庫才會顯示在左側清單中）。
2. 點選左下角 **測試連線 (Test Connection)**：
   - 首次連線若跳出提示下載驅動程式，點選 **Download** 即可。
   - 若出現 `Connected` 代表透過 SSH 隧道成功連上樹莓派上的 PostgreSQL 容器！
3. 點選右下角 **OK** 或 **Finish** 完成連線。

---

### 步驟 3.3：DBeaver 常用操作

| 要做的事 | 操作方式 |
|---|---|
| **開啟 SQL 編輯器** | 在左側選取資料庫 → 按右鍵 **SQL Editor → New SQL script**（`Ctrl + ]` 或 Mac 的 `Cmd + ]`） |
| **執行游標所在的一句 SQL** | `Ctrl + Enter`（Mac：`Cmd + Enter`） |
| **執行整個檔案的所有 SQL** | `Alt + X`（Mac：`Opt + X`） |
| **開啟 `.sql` 檔** | **File → Open File** 選擇檔案，再從工具列的 **Active datasource** 選擇要執行的資料庫 |
| **建立資料庫** | 在連線底下的 **Databases** 按右鍵 → **Create New Database** |
| **匯入 CSV** | 在資料表上按右鍵 → **Import Data** → 選 **CSV** → 選擇檔案 → 確認欄位對應 → **Proceed** |
| **查看資料表結構、限制、外來鍵** | 在資料表上按兩下 → **Properties** 分頁（Columns、Constraints、Foreign Keys） |
| **查看關聯圖 (ERD)** | 在資料表或 Schema 上按兩下 → **ER Diagram** 分頁 |
| **產生資料表的 `CREATE TABLE` (DDL)** | 在資料表上按右鍵 → **Generate SQL → DDL** |
| **重新整理左側清單** | 選取後按 `F5`（用 SQL 建立資料庫或資料表後，左側需重新整理才會出現） |

> 💡 **連線字串格式參考**（MCP 和 Python 使用）：
> `postgresql://使用者名稱:密碼@主機:埠號/資料庫名稱`
> 例如本機 SSH 轉發：`postgresql://postgres:yourpassword@localhost:5432/postgres`

---

## 4. 單獨使用 Docker Run 安裝 Postgres MCP Server 與連線設定

在步驟 2.1 與 2.2 中，我們已經建立好了 `mcp-net` 專屬網路，並讓 `my-postgres` 運行於其中。

現在我們只需**單獨使用 `docker run` 啟動 Postgres MCP Server 並加入同一網路**，它就能透過主機名稱 `my-postgres` 與資料庫互通，讓 AI（如 Claude Desktop）進行中文查詢！

### 步驟 4.1：使用 `docker run` 啟動 MCP Server 容器

在樹莓派終端機執行以下指令啟動 MCP Server（請將 `yourpassword` 替換為資料庫密碼）：

```bash
docker run -d \
  --name my-postgres-mcp \
  --network mcp-net \
  -e DATABASE_URI=postgresql://postgres:yourpassword@my-postgres:5432/postgres \
  --restart unless-stopped \
  crystaldba/postgres-mcp
```

#### 參數解說：
| 參數 | 說明 |
|---|---|
| `-d` | 背景執行容器（終端機不會被佔用） |
| `--name my-postgres-mcp` | 容器自訂名稱 |
| `--network mcp-net` | **加入步驟 2.1 建立的專屬網路**：與 `my-postgres` 容器互通，直接使用容器名當主機名 |
| `-e DATABASE_URI=...` | 指定資料庫連線字串（重要！見下方詳細拆解） |
| `--restart unless-stopped` | 開機自動重啟 MCP Server |

> [!TIP]
> **關於 `--access-mode` 存取權限模式說明：**
> * **教學環境（讓 AI 協助做事）**：在指令末尾不加或加上 `--access-mode=unrestricted`，代表**不受限模式**。AI 除了查詢外，還能協助建立資料表（CREATE TABLE）、新增、修改資料，最適合上課與教學實戰！
> * **正式環境（唯讀保護）**：若在指令末尾加上 `--access-mode=restricted`，則為**唯讀模式**，AI 只能做 `SELECT` 查詢，不能改動任何資料庫結構與內容。

---

#### 🔍 白話詳細拆解：什麼是 `DATABASE_URI`？
這行指令看起來最複雜、最容易讓人混淆：
```text
DATABASE_URI=postgresql://postgres:yourpassword@my-postgres:5432/postgres
```

其實它的通用公式非常固定：
```text
postgresql://【帳號】:【密碼】@【主機位址】:【埠號】/【資料庫名稱】
```

將這一段文字拆開來看：

| 欄位片段 | 代表意義 | 白話說明 |
|---|---|---|
| `postgresql://` | **連線協定** | 告訴程式這是要連線到 PostgreSQL 資料庫 |
| `postgres` | **帳號 (Username)** | PostgreSQL 預設最高管理者的帳號名稱就叫做 `postgres` |
| `:yourpassword` | **密碼 (Password)** | 步驟 2.2 啟動資料庫時自己設定的密碼 |
| `@my-postgres` | **主機位址 (Host)** | ⭐ **關鍵重點**：在同一個 Docker 網路內，**容器名稱就是主機名稱**！填入步驟 2.2 的 `--name my-postgres`，Docker 就會自動找到資料庫，完全不需要填寫 IP |
| `:5432` | **連接埠 (Port)** | PostgreSQL 的預設通訊埠號 |
| `/postgres` | **資料庫名稱 (Database)** | 連線進入的目標資料庫名稱。預設內建資料庫叫 `postgres`；如果未來要切換到練習用的資料庫（例如 `practice`），只需改成 `/practice` |

> 💡 **常見疑問：為什麼字串裡有這麼多個 `postgres`？**
> * 第一個 `postgresql://`：是**資料庫類型**
> * 第二個 `postgres`：是**使用者帳號**
> * 第三個 `@my-postgres`：是**容器名稱**（代表那台伺服器）
> * 第四個 `/postgres`：是**要連進去的資料庫**
> 
> 它們各自扮演不同的角色，只是預設都叫這個名字！

---

檢查容器是否正常啟動：
```bash
docker ps
```
若能看到 `my-postgres` 與 `my-postgres-mcp` 兩個容器同時處於 `Up` 狀態，代表單獨安裝成功！

---

### 步驟 4.2：個人電腦端 Claude Desktop 連線設定

在個人電腦（Mac / Windows）安裝 [Claude Desktop](https://claude.ai/download) 後，打開設定檔：
* **macOS**：`~/Library/Application Support/Claude/claude_desktop_config.json`
* **Windows**：`%APPDATA%\Claude\claude_desktop_config.json`

在 `claude_desktop_config.json` 中填入連線設定（將 `<樹莓派IP或主機名稱>` 替換為您的樹莓派 IP，例如 `192.168.1.150` 或 `pi4robert03012gb.local`）：

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
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@<樹莓派IP或主機名稱>:5432/postgres"
      }
    }
  }
}
```

> **測試連線：**
> 存檔後**完全退出並重新開啟 Claude Desktop**。在輸入框下方點選工具圖示，若看到 `raspberry-postgres` 工具（例如 `list_objects`、`execute_sql`），即代表已成功連上樹莓派上的資料庫！

---

## 5. 進階整合：使用 Docker Compose 一次安裝與啟動 2 套服務

雖然在第 2 節與第 4 節我們可以用 `docker run` 分別啟動資料庫與 MCP Server，但必須執行多次指令，還要手動建立網路（`docker network create`、`connect`），較為瑣碎。

**Docker Compose** 解決了這個痛點：**只需撰寫一份 `docker-compose.yml`，一行指令就能同時建立網路、配置環境變數、並一次啟動 2 套服務！**

### 步驟 5.1：建立專案資料夾與 `docker-compose.yml`
若想改用 Docker Compose 管理，建議先停止原本單獨運行的容器：
```bash
docker stop my-postgres my-postgres-mcp
docker rm my-postgres my-postgres-mcp
```
> [!NOTE]
> 刪除容器不會刪除 `postgres_data` 資料卷，原本建立的資料表依然完整保存。

接著在樹莓派終端機建立 compose 專案：
```bash
mkdir -p ~/postgres-compose && cd ~/postgres-compose
nano docker-compose.yml
```

貼入以下內容（請將 `yourpassword` 替換為您的密碼）：

```yaml
services:
  # 服務 1：PostgreSQL 資料庫
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
      - mcp-net

  # 服務 2：Postgres MCP Server（AI 連線工具）
  postgres-mcp:
    image: crystaldba/postgres-mcp:latest
    container_name: my-postgres-mcp
    restart: unless-stopped
    environment:
      # 在同一個 compose 網路中，可以直接使用服務名稱 postgres 連線
      DATABASE_URI: postgresql://postgres:yourpassword@postgres:5432/postgres
    depends_on:
      - postgres
    networks:
      - mcp-net

volumes:
  postgres_data:

networks:
  mcp-net:
    driver: bridge
```
> 按 `Ctrl + O` 儲存，按 `Enter`，按 `Ctrl + X` 離開。

### 步驟 5.2：一行指令一次啟動 2 套容器
在含有 `docker-compose.yml` 的目錄下執行：

```bash
docker compose up -d
```

### 步驟 5.3：檢查狀態與日誌
- **查看 2 個容器的狀態：**
  ```bash
  docker compose ps
  ```
- **同時查看 2 個容器的彩色輸出日誌：**
  ```bash
  docker compose logs -f
  ```
- **重啟這 2 套服務：**
  ```bash
  docker compose restart
  ```

---

## 6. 常用維護指令與常見問題

### 常用 Docker 維護指令

- **停止容器：**
  ```bash
  docker stop my-postgres
  ```
- **啟動容器：**
  ```bash
  docker start my-postgres
  ```
- **重啟容器：**
  ```bash
  docker restart my-postgres
  ```
- **開機自動啟動狀態：**
  因為啟動時加上了 `--restart unless-stopped`，只要樹莓派開機，容器就會自動在背景啟動。

### 常見問題排查

1. **DBeaver 顯示 `Connection refused` 或連線超時（Timeout）：**
   - 檢查樹莓派上的容器是否有在執行：`docker ps`。
   - 檢查個人電腦能否 ping 到樹莓派：`ping <樹莓派IP>`。
   - 確認樹莓派是否有開啟防火牆（若有安裝 `ufw`，可執行 `sudo ufw allow 5432/tcp` 放行）。
   - 確認個人電腦與樹莓派是否連到同一個 Wi-Fi 路由器（避免訪客網路隔離）。

2. **資料庫資料會不會因容器重啟而消失？**
   - 不會。我們在啟動時指定了 `-v postgres_data:/var/lib/postgresql/data`，所有建立的資料庫、資料表與資料都會被持久保存在 Docker volume 中。
