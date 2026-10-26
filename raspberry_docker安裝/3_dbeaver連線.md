# 3. 使用 DBeaver 透過 SSH 連線至 Raspberry Pi

在個人電腦（Mac / Windows）上管理樹莓派的 PostgreSQL，最推薦且最安全的方式是**使用 DBeaver 內建的 SSH 隧道（SSH Tunnel）**。

---

## 為什麼推薦 SSH 隧道？
- **極致安全**：所有傳輸經過 SSH 加密通道，不需要將 PostgreSQL 的 5432 埠暴露到外部網路。
- **免除網路防火牆困擾**：只要電腦能透過 SSH（埠號 22）連進樹莓派，就能連線到資料庫。

---

## 步驟 3.1：確認樹莓派的連線資訊
請確認您知道以下資訊：
1. **樹莓派的 IP 位址**：在樹莓派終端機執行 `hostname -I` 查詢（例如 `192.168.1.150`），或主機名稱（例如 `raspberrypi.local`）。
2. **樹莓派的 SSH 帳號與密碼**：例如帳號 `pi` 及其密碼。
3. **PostgreSQL 的密碼**：步驟 2.2 設定的密碼。

---

## 步驟 3.2：在 DBeaver 設定 SSH 隧道連線

### 3.2.1 【主（Main）分頁】設定資料庫連線
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
* **Password**：步驟 2.2 建立容器時設定的密碼
* 勾選 **Save password**

---

### 3.2.2 【SSH 分頁】設定 SSH 隧道（核心步驟）
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

### 3.2.3 【PostgreSQL 分頁】與測試連線
1. 切換至 **PostgreSQL** 分頁，勾選 **Show all databases**（這樣建立的新資料庫才會顯示在左側清單中）。
2. 點選左下角 **測試連線 (Test Connection)**：
   - 首次連線若跳出提示下載驅動程式，點選 **Download** 即可。
   - 若出現 `Connected` 代表透過 SSH 隧道成功連上樹莓派上的 PostgreSQL 容器！
3. 點選右下角 **OK** 或 **Finish** 完成連線。

---

## 步驟 3.3：DBeaver 常用操作速查表

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

---

👉 **下一步：[4. 在本機 Antigravity 設定專案級 MCP 連線至樹莓派資料庫](./4_單獨安裝mcp_server.md)**
