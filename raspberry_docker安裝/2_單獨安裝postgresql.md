# 2. 單獨使用 Docker Run 安裝與運行 PostgreSQL

使用 Docker 運行 PostgreSQL 的最大好處是：**映像檔預設已允許遠端連線，且安裝、備份、刪除都極為乾淨**。

---

## 步驟 2.1：建立 Docker 自訂網路 `mcp-net`

因為我們預先知道後續需要將 PostgreSQL 與 **Postgres MCP Server** 互相連線，而 Docker 容器預設的 bridge 網路不支援直接用容器名稱（`my-postgres`）互相訪問。

因此，在啟動資料庫前，我們先建立一個專屬的虛擬網路：

```bash
docker network create mcp-net
```

---

## 步驟 2.2：建立並啟動 PostgreSQL 容器

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

### 參數詳細解說：
| 參數 | 說明 |
|---|---|
| `-d` | 在背景執行（Detached mode），不佔用終端機 |
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

---

## 步驟 2.3：檢查容器狀態
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

## 步驟 2.4：測試進入容器內的 psql（可選）
如果想在樹莓派終端機內直接測試連線：
```bash
docker exec -it my-postgres psql -U postgres
```
成功進入後會看到 `postgres=#` 提示字元，輸入 `\q` 即可離開。

---

👉 **下一步：[3. 使用 DBeaver 透過 SSH 連線至 Raspberry Pi](./3_dbeaver連線.md)**
