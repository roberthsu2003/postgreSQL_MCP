# 在 Raspberry Pi 上使用 Docker 安裝 PostgreSQL 與 DBeaver 連線

本指南適用於在 **Raspberry Pi（樹莓派）** 環境下，透過 **Docker** 快速建立 PostgreSQL 資料庫服務，並從個人電腦（Mac / Windows）使用 **DBeaver** 進行遠端連線管理。

---

## 目錄
1. [在 Raspberry Pi 安裝 Docker](#1-在-raspberry-pi-安裝-docker)
2. [在 Docker 上安裝與運行 PostgreSQL](#2-在-docker-上安裝與運行-postgresql)
3. [使用 DBeaver 連線至 Raspberry Pi](#3-使用-dbeaver-連線至-raspberry-pi)
4. [常用維護指令與常見問題](#4-常用維護指令與常見問題)

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

## 2. 在 Docker 上安裝與運行 PostgreSQL

使用 Docker 運行 PostgreSQL 的最大好處是：**映像檔預設已允許遠端連線，且安裝、備份、刪除都極為乾淨**。

### 步驟 2.1：建立並啟動 PostgreSQL 容器

在樹莓派終端機執行以下指令（請將 `yourpassword` 替換為你的密碼）：

```bash
docker run -d \
  --name my-postgres \
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
| `-e POSTGRES_PASSWORD=yourpassword` | 設定預設管理者帳號 `postgres` 的密碼 |
| `-p 5432:5432` | 將樹莓派主機的 `5432` 埠對應到容器內的 `5432` 埠（允許連線） |
| `-v postgres_data:/var/lib/postgresql/data` | **資料持久化**：建立具名磁碟卷，確保容器重啟或重建時資料不會消失 |
| `--restart unless-stopped` | **開機自動重啟**：設定開機自動啟動容器（除非手動停止），樹莓派重開機後會自動啟動 |
| `postgres` | 使用 Docker Hub 官方最新版本的 PostgreSQL 映像檔（支援 ARM64 架構） |

> [!IMPORTANT]
> **未來開機會自動重新啟動：**
> 指令中的 `--restart unless-stopped` 參數非常重要！這代表**未來樹莓派每次開機或重新啟動後，Docker 都會自動把 PostgreSQL 容器啟動起來**。
> 您不需要每次開機都進終端機手動輸入指令，資料庫服務將會常駐運行。

> [!TIP]
> **可選：使用 Docker Compose 管理**
> 如果習慣使用 Docker Compose，可在樹莓派建立 `docker-compose.yml`：
> ```yaml
> services:
>   postgres:
>     image: postgres
>     container_name: my-postgres
>     restart: unless-stopped
>     environment:
>       POSTGRES_PASSWORD: yourpassword
>     ports:
>       - "5432:5432"
>     volumes:
>       - postgres_data:/var/lib/postgresql/data
> 
> volumes:
>   postgres_data:
> ```
> 啟動指令：`docker compose up -d`

### 步驟 2.2：檢查容器狀態
檢查容器是否正常運行：
```bash
docker ps
```
若狀態顯示為 `Up ... (healthy)` 或 `Up ...`，代表伺服器已正常啟動。

若想查看資料庫日誌：
```bash
docker logs my-postgres
```

### 步驟 2.3：測試進入容器內的 psql（可選）
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

## 4. 常用維護指令與常見問題

### 常用 Docker 維護指令

- **停止資料庫：**
  ```bash
  docker stop my-postgres
  ```
- **啟動資料庫：**
  ```bash
  docker start my-postgres
  ```
- **重啟資料庫：**
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
