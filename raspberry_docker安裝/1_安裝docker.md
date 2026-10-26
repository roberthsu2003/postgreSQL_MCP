# 1. 在 Raspberry Pi 安裝 Docker

在樹莓派上安裝 Docker 最推薦官方提供的自動安裝腳本。

---

## 步驟 1.1：更新系統套件
打開樹莓派終端機（SSH 或本機終端機）：
```bash
sudo apt update && sudo apt upgrade -y
```

---

## 步驟 1.2：使用官方腳本安裝 Docker
執行官方便利腳本進行自動化安裝：
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

---

## 步驟 1.3：將目前使用者加入 docker 群組
為了避免每次執行 docker 指令都要加 `sudo`，請將目前使用者（例如預設的 `pi`）加入群組：
```bash
sudo usermod -aG docker $USER
```
> [!IMPORTANT]
> 加入群組後，請執行 `newgrp docker` 立即生效，或登出後重新登入（或重開機 `sudo reboot`）。

---

## 步驟 1.4：驗證 Docker 是否安裝成功
```bash
docker --version
docker compose version
```
如果能正確顯示版本號碼（例如 `Docker version 27.x.x...`），代表安裝成功！

> [!TIP]
> 📖 **推薦參考：[Docker 與 Docker Compose 常用基本指令速查](./docker基本指令.md)**
> 包含日常必備的 `docker run`、檢查狀態（`ps` / `logs`）、啟動、停止、進入容器互動，以及未來一次啟動 2 個服務所需的 **Docker Compose** 完整指令攻略。

---

👉 **下一步：[2. 單獨使用 Docker Run 安裝與運行 PostgreSQL](./2_單獨安裝postgresql.md)**
