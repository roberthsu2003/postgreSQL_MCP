# Supabase 雲端 PostgreSQL 資料庫申請、DBeaver 連線與 MCP Server 設定

[Supabase](https://supabase.com) 提供免費的雲端託管 PostgreSQL 資料庫，免自己準備硬體或樹莓派，適合隨時隨地練習，也支援透過 AI（Claude Desktop + MCP）進行自然語言查詢。

---

## 📋 目錄導覽
1. [註冊 Supabase 與建立 PostgreSQL 專案](#1-註冊-supabase-與建立-postgresql-專案)
2. [取得資料庫連線字串 (Session Pooler)](#2-取得資料庫連線字串-session-pooler)
3. [使用 DBeaver 連線至 Supabase](#3-使用-dbeaver-連線至-supabase)
4. [設定 Supabase MCP Server（AI 中文查詢）](#4-設定-supabase-mcp-serverai-中文查詢)
5. [常見問題與注意事項](#5-常見問題與注意事項)

---

## 1. 註冊 Supabase 與建立 PostgreSQL 專案

### 步驟 1.1：註冊並登入
1. 前往 [Supabase 官網](https://supabase.com)。
2. 點選右上角 **Start your project**，可直接使用 **GitHub 帳號** 快速登入。

### 步驟 1.2：建立新專案 (New Project)
1. 進入後台點選 **New project**。
2. 填入專案設定：
   * **Name**：自訂專案名稱（例如 `postgres-practice`）。
   * **Database Password**：設定資料庫管理員密碼（⭐ **請務必記下此密碼**，後續連線必用）。
   * **Region**：選擇離台灣較近的地區（推薦 `Tokyo (ap-northeast-1)` 或 `Singapore (ap-southeast-1)`）。
   * **Pricing Plan**：選擇 **Free plan**（免費方案即足夠個人與學習使用）。
3. 點選 **Create new project**，系統會在雲端佈署 PostgreSQL（約需 1~2 分鐘）。

---

## 2. 取得資料庫連線字串 (Session Pooler)

在專案主頁面建立完成後：

1. 點選頂端導覽列或首頁的 **Connect** 按鈕。
2. 連線類型選擇 **Session pooler**（⚠️ **非常重要**：Direct Connection 只支援 IPv6，許多家用網路連不上；**Session pooler 支援 IPv4**）。
3. 選擇 **URI** 分頁，複製顯示的連線字串：
   ```text
   postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres
   ```
4. 記下以下關鍵欄位：
   * **Host**：`[POOLER-HOST]`（例如 `aws-0-ap-northeast-1.pooler.supabase.com`）
   * **Port**：`5432`
   * **Database**：`postgres`
   * **User**：`postgres.[PROJECT-REF]`（注意：**後面有一串專案代碼**，不是單純的 `postgres`）
   * **Password**：步驟 1.2 設定的密碼

> [!CAUTION]
> 如果密碼中包含 `@`、`#`、`?`、`&`、`%` 等特殊符號，在 URI 中必須進行 URL 編碼（例如 `#` 需寫為 `%23`）。

---

## 3. 使用 DBeaver 連線至 Supabase

您可以使用本機的 DBeaver 直連 Supabase 雲端資料庫：

1. 開啟 **DBeaver**，點選 **Database → New Database Connection**。
2. 選擇 **PostgreSQL**，點選 **Next**。
3. **【Main 分頁】填寫連線設定：**
   * **Host**：填入 Supabase 的 `[POOLER-HOST]`（例如 `aws-0-ap-northeast-1.pooler.supabase.com`）
   * **Port**：`5432`
   * **Database**：`postgres`
   * **Username**：`postgres.[PROJECT-REF]`
   * **Password**：您設定的資料庫密碼
   * 勾選 **Save password**
4. **【SSL 分頁】：**
   * 勾選 **Use SSL**
   * SSL 模式選擇 **require** 或 **verify-ca**
5. **【PostgreSQL 分頁】：**
   * 勾選 **Show all databases**
6. 點選左下角 **Test Connection**：
   * 連線成功會跳出 `Connected` 提示。
   * 點選 **Finish** 完成建立！

---

## 4. 設定 Antigravity 專案級 MCP Server（AI 中文查詢）

透過專案級 MCP 配置，免全域安裝，只要打開本專案，Antigravity 就會自動連線至您的 Supabase 雲端資料庫！

### 設定方式：
開啟專案根目錄下的 [`.agents/mcp_config.json`](file:///Users/roberthsu2003/Documents/GitHub/postgreSQL_MCP/.agents/mcp_config.json)，使用免安裝 Docker 的 **`uvx`** 加入 Supabase 連線設定（連線字串末尾加上 `?sslmode=require`）：

```json
{
  "mcpServers": {
    "supabase-postgres": {
      "command": "uvx",
      "args": [
        "--with",
        "mcp<2",
        "postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require"
      }
    }
  }
}
```

> [!TIP]
> * **免安裝 Docker**：只要個人電腦有安裝 `uv`（內建 `uvx`），Antigravity 就會自動喚起開源的 Postgres MCP 工具。
> * **連線驗證**：儲存後重新載入專案，直接在 Antigravity 聊天框輸入：「請幫我查詢目前 Supabase 資料庫中的資料表」，AI 就會調用 MCP 自動查詢！

---

## 5. 直觀實戰測試 — 讓 AI 在 Supabase 上新增、查詢選取、修改與刪除

因為我們在設定檔中啟用了 `--access-mode=unrestricted`（不受限模式），AI 具備完整的雲端資料庫操作權限。請依序貼入以下 5 個指令，完整體驗雲端資料庫的 **CRUD（建立、選取查詢、更新、刪除）** 與資料表管理：

---

### 🟢 測試 1：建立資料表並寫入多筆具體資料（CREATE TABLE & INSERT）
直接對 Antigravity 說：
> 「請在我的 Supabase 雲端資料庫中建立一張學生名單資料表 `students_test`，包含欄位：
> - 學號（id）：自動編號整數，主鍵
> - 姓名（name）：文字，必填
> - 年級（grade）：整數
> - 城市（city）：文字
> - 考試成績（score）：整數
>
> 建立好後，請幫我寫入以下 4 筆具體學生資料：
> 1. 陳小明，2年級，台北市，88分
> 2. 林美玲，3年級，新北市，95分
> 3. 張志豪，2年級，台中市，72分
> 4. 李佳穎，3年級，台北市，60分
>
> 新增完成後，請把整張資料表的所有內容列出來給我看。」

* **直觀成果**：AI 會調用 MCP 工具自動在 Supabase 執行 `CREATE TABLE` 與 `INSERT INTO`，並立刻以 Markdown 表格回傳這 4 位學生的完整資料。
* **雙重驗證方式**：
  1. **DBeaver**：在左側 Supabase 連線的資料表清單按 `F5`，立刻看到新建立的 `students_test`！
  2. **Supabase 網頁後台**：登入 Supabase 點選 **Table Editor**，也能即時看到這張表與這 4 筆資料！

---

### 🔍 測試 2：條件選取與篩選查詢（SELECT with WHERE & ORDER BY）
測試 AI 的條件選取與排序能力，對 Antigravity 說：
> 「請幫我從 `students_test` 選取查詢符合以下條件的學生：
> 1. 只選取住在『台北市』**或**成績大於等於 80 分的學生
> 2. 依照『考試成績』由高到低排序（ORDER BY DESC）
> 3. 只顯示學號、姓名、城市與成績 4 個欄位即可」

* **直觀成果**：AI 會在背後撰寫精準的 `SELECT id, name, city, score FROM students_test WHERE city = '台北市' OR score >= 80 ORDER BY score DESC;`，篩選出符合條件的學生並整齊列出。

---

### 🟡 測試 3：更新特定學生的資料（UPDATE）
接著測試資料修改，對 Antigravity 說：
> 「李佳穎同學補考通過了！請幫我把 `students_test` 資料表中『李佳穎』的成績更新為 85 分，並把她的最新資料單獨選取出來確認。」

* **直觀成果**：AI 會執行 `UPDATE students_test SET score = 85 WHERE name = '李佳穎';`，並重新選取顯示她修改後的最新成績。

---

### 🟠 測試 4：刪除特定一筆資料（DELETE FROM）
接著測試刪除單筆資料，對 Antigravity 說：
> 「張志豪同學轉學了，請幫我從 `students_test` 刪除他的資料，並列出目前剩下的所有學生確認。」

* **直觀成果**：AI 執行 `DELETE FROM students_test WHERE name = '張志豪';`，剩下的 3 筆資料會即時呈現，確認已被刪除。

---

### 🔴 測試 5：測試結束，刪除整張資料表（DROP TABLE）
最後清理雲端測試環境，對 Antigravity 說：
> 「測試結束了，請幫我把剛剛建立的測試資料表 `students_test` 完全刪除（DROP TABLE），並確認資料庫內是否已經沒有這張表。」

* **直觀成果**：AI 會執行 `DROP TABLE IF EXISTS students_test;`，確認刪除後回覆「資料表已順利清除」。
* **驗證方式**：回到 DBeaver 或 Supabase 網頁後台重新整理，確認資料表已消失，不留任何測試垃圾！

> [!TIP]
> 透過這個完整的實戰演練，學生能直觀地感受到：**不管是遠在區網的樹莓派，還是位於雲端的 Supabase，只要透過 Antigravity 說中文，AI 都能以完全相同的 MCP 工具進行精準的操作！**

---

## 6. 補充說明：為什麼不直接用 Supabase 官方後台給的 `serverUrl` 設定？

在 Supabase 後台的 Connect 選單中，您可能會看到官方提供類似這樣的 MCP 設定：
```json
{
  "mcpServers": {
    "supabase": {
      "serverUrl": "https://mcp.supabase.com/mcp?project_ref=...&features=docs,account,database..."
    }
  }
}
```

為什麼本課程建議使用 `uvx` + `DATABASE_URI`，而不是官方的這個 `serverUrl` 呢？

| 比較項目 | 課程採用的 `postgres-mcp` (推薦) | Supabase 官方的 `serverUrl` |
|---|---|---|
| **本質與目的** | **專注於 PostgreSQL 資料庫與 SQL 操作** | **整個 Supabase 雲端平台的後台管理介面** |
| **教學一致性** | ⭐⭐⭐ **極佳**：無論連樹莓派 Docker 還是連 Supabase，AI 工具完全一樣，操作心智模型 100% 統一。 | ❌ **不一致**：樹莓派不能用此網址，學生會面臨兩套完全不同的工具名稱與行為。 |
| **AI 聚焦度** | 只提供標準的 SQL 查詢與資料表結構工具，AI 不會分心。 | 會把查看 Logs、部署 Edge Functions、管理 Storage、查 API 文件等 20 多個管理工具通通塞給 AI，容易干擾 AI 寫 SQL。 |
| **身分驗證** | 只需資料庫連線字串，隨開隨用。 | 通常需要額外進行 Supabase 平台的 OAuth 授權登入。 |

> 💡 **結論**：本課程的核心是學會 **PostgreSQL 與 SQL 語法**，因此使用標準的 `postgres-mcp` 最乾淨、最直觀，也能無縫切換本機、樹莓派與雲端資料庫！

---

## 7. 常見問題與注意事項

1. **免費版專案自動休眠：**
   * Supabase 免費專案若連續 7 天沒有存取，會自動進入「休眠狀態（Paused）」。
   * 若 DBeaver 或 MCP 連不上，請登入 Supabase 後台點選 **Restore project**，約 1 分鐘後即可恢復正常。
2. **連線逾時 (Timeout)：**
   * 請確認使用的是 **Session pooler (IPv4)** 的主機位址，而非 Direct connection (IPv6)。
3. **密碼安全性提醒：**
   * `.agents/mcp_config.json` 包含資料庫密碼，切勿將含真實密碼的檔案推送到公開的 GitHub Repository。
