# Supabase 雲端 PostgreSQL 資料庫申請、DBeaver 連線與 MCP Server 設定

> ⏱️ **約 40 分鐘** ｜ 🎯 學完你會：擁有一個雲端 PostgreSQL，並用 DBeaver 和 AI 助教連上它
>
> 💡 DBeaver 的快捷鍵和常用操作，請見 [DBeaver 速查表](../raspberry_docker安裝/3_dbeaver連線.md#步驟-33dbeaver-常用操作速查表)。

[Supabase](https://supabase.com) 提供免費的雲端託管 PostgreSQL 資料庫，免自己準備硬體或樹莓派，適合隨時隨地練習，也支援透過 AI（Claude Desktop + MCP）進行自然語言查詢。

---

## 📋 目錄導覽
1. [註冊 Supabase 與建立 PostgreSQL 專案](#1-註冊-supabase-與建立-postgresql-專案)
2. [取得資料庫連線字串 (Session Pooler)](#2-取得資料庫連線字串-session-pooler)
3. [使用 DBeaver 連線至 Supabase](#3-使用-dbeaver-連線至-supabase)
4. [設定 Antigravity 專案級 MCP Server（AI 助教連線）](#4-設定-antigravity-專案級-mcp-serverai-助教連線)
5. [SQL 學習助教實戰 — 讓 AI 看庫解題，學生在 DBeaver 親自執行](#5-sql-學習助教實戰--讓-ai-看庫解題學生在-dbeaver-親自執行)
6. [補充說明：為什麼不直接用 Supabase 官方後台給的 serverUrl 設定？](#6-補充說明為什麼不直接用-supabase-官方後台給的-serverurl-設定)
7. [常見問題與注意事項](#7-常見問題與注意事項)

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

## 4. 設定 Antigravity 專案級 MCP Server（AI 助教連線）

透過專案級 MCP 配置，免全域安裝，只要打開本專案，Antigravity 就會自動連線至您的 Supabase 雲端資料庫！

因為本教材是**為了學生學習 SQL 語法**，我們將 MCP 設定為受限唯讀模式（`--access-mode=restricted`），讓 AI 專職擔任「**SQL 學習助教**」，只負責查庫解題與指導語法，保護雲端資料庫安全，並由學生親自在 DBeaver 中敲 SQL 執行。

### 🌟 讓 Antigravity 自動幫你設定（複製貼上自然語言）
您可以直接在 Antigravity 聊天框發送以下指令，讓 AI 一鍵為您設定好設定檔（請自行替換密碼、專案代碼與 Pooler Host）：

> 「請幫我在專案的 `.agents/mcp_config.json` 中設定名為 `supabase-postgres` 的 MCP Server：
> 1. command 使用 `uvx`
> 2. args 指定使用本專案虛擬環境 `--python .venv`，指定版本 `postgres-mcp==0.3.0`，並啟用唯讀保護模式 `--access-mode=restricted`
> 3. DATABASE_URI 設定為：`postgresql://postgres.[PROJECT-REF]:<您的密碼>@[POOLER-HOST]:5432/postgres?sslmode=require`」

* **AI 自動化成果**：Antigravity 會自動在專案中建立或更新 [`.agents/mcp_config.json`](../.agents/mcp_config.json)，內容如下（供檢閱確認）：

```json
{
  "mcpServers": {
    "supabase-postgres": {
      "command": "uvx",
      "args": [
        "--python",
        ".venv",
        "postgres-mcp==0.3.0",
        "--access-mode=restricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@[POOLER-HOST]:5432/postgres?sslmode=require"
      }
    }
  }
}
```

> 💡 **關鍵參數說明**：
> 1. **`"--python", ".venv"`**：**環境隔離！** 明確指定 `uvx` 必須使用專案虛擬環境 `.venv` 內的 Python 來載入與運行 MCP Server。
> 2. **`"postgres-mcp==0.3.0"`**：**鎖定版本！** 鎖定 `0.3.0` 版本，確保 MCP 功能與語法解析穩定運作。
> 3. **`"--access-mode=restricted"`**：**學習階段唯讀保護！** 啟用受限唯讀模式，AI 只能做 `SELECT` 查詢資料表與欄位綱要，**禁止直接寫入、更新或刪除資料庫**，防呆又安全。（未來學成後，可隨時改為 `unrestricted` 解鎖完整權限）
> 4. **`?sslmode=require`**：**雲端必備！** 連線 Supabase 雲端資料庫一律必須在字串最後加上 SSL 加密連線參數。
> 5. **`[PROJECT-REF]`、`[YOUR-PASSWORD]`、`[POOLER-HOST]`**：請替換為步驟 2 取得的連線參數。

> [!TIP]
> **關於 `--access-mode` 存取模式（學習階段 vs 未來實務）：**
> * 🎓 **學習階段（當前設定：`restricted` 唯讀保護）**：
>   * AI 僅能進行 `SELECT` 查詢資料表與綱要架構，防止誤刪或弄亂雲端資料庫。
>   * AI 的職責是**「指導老師／助教」**：遇到不會寫的語法時向 AI 請教，AI 負責給出標準 SQL 語法與逐行解析，最後由**學生親自複製到 DBeaver 中手動執行**，真正動手練就紮實的 SQL 功力！
> * 🚀 **未來實務階段（未來可改為：`unrestricted` 不受限模式）**：
>   * 等到未來 SQL 已經學得很熟練、需要進行真實專案開發時，如果想讓 AI 直接幫您建立資料表（CREATE TABLE）、自動匯入大量測試資料或執行批次更新，只要回到 `.agents/mcp_config.json` 將參數改為 `--access-mode=unrestricted` 即可完全解鎖！

---

## 5. SQL 學習助教實戰 — 讓 AI 看庫解題，學生在 DBeaver 親自執行

因為我們啟用了 `--access-mode=restricted`（唯讀保護模式），AI 成為最強大的**「專屬 SQL 助教」**：它看得到 Supabase 雲端資料庫的現況，能精確教你寫 SQL，但**不會直接幫你改資料庫**。

請依序嘗試以下 4 個情境，體驗身歷其境的 SQL 輔助學習：

---

### 🔍 情境 1：請 AI 查看現有資料庫結構並詳細講解（Schema 探索）
直接對 Antigravity 說：
> 「請連線我的 Supabase 資料庫，幫我檢查目前資料庫裡有哪些資料表？並挑一張表詳細列出它的所有欄位、資料型態（Data Type）與主鍵設定，教我該怎麼看懂這張表的架構。」

* **直觀成果**：AI 會調用 MCP 讀取 Supabase 的資料字典，以整齊的 Markdown 表格列出欄位名稱與型別（如 `VARCHAR`、`INTEGER`、`TIMESTAMP`），並用白話文解釋各欄位用途。

---

### 💡 情境 2：提出查詢需求，請 AI 教導撰寫 SELECT 語法（學生在 DBeaver 執行）
想查特定條件的數據卻卡關時，對 Antigravity 說：
> 「我想在 Supabase 資料庫中查詢符合以下條件的資料：
> 1. 篩選出特定的分類或分數及格的紀錄
> 2. 依照時間或分數由大到小排序（DESC）
> 3. 只取前 5 筆
>
> 請不要直接幫我跑，請教我這段 SQL 語法該怎麼寫？並逐行詳細解釋 `SELECT`、`WHERE`、`ORDER BY` 與 `LIMIT` 的用法。」

* **直觀成果**：AI 會根據現有資料表結構，寫出完全正確的 SQL 語法，並提供清晰易懂的關鍵字教學。
* **學生動手練**：學生將 AI 提供的 SQL 複製，貼到本機 **DBeaver** 的 SQL 編輯器中按下執行（Ctrl + Enter），親眼看到查詢結果！

---

### ✍️ 情境 3：想新增或修改資料，請 AI 教寫語法並解釋防呆觀念
學習資料修改（DML）時，對 Antigravity 說：
> 「如果我想在資料庫中把某筆紀錄更新，請教我正確的 `UPDATE` 語法該怎麼寫？另外請特別提醒我，撰寫 `UPDATE` 時如果不小心漏掉什麼子句會造成嚴重的災難？」

* **直觀成果**：AI 會示範標準 `UPDATE 表名 SET 欄位 = 值 WHERE 條件;` 語法，並強烈警告學生：**「千萬不能漏掉 WHERE 條件，否則整張表的資料都會被一起改掉！」**
* **學生動手練**：學生理解觀念後，在 DBeaver 中親自執行修改，並用 `SELECT` 驗證數據變更。

---

### 🛡️ 情境 4：安全防護驗證 — 測試 AI 是否真的無法改庫（防呆測試）
故意命令 AI 直接去刪除資料，對 Antigravity 說：
> 「請直接幫我刪除 Supabase 資料庫裡的某張資料表（DROP TABLE）！」

* **直觀成果**：因為我們設定了 `--access-mode=restricted`，MCP 工具會嚴格拒絕寫入與刪除請求，AI 會回覆：**「目前處於唯讀保護模式，無法直接對資料庫執行刪除操作」**，並改為提供語法給學生參考。這保證了雲端資料庫的絕對安全！

> [!TIP]
> **教學總結與未來進階指南**：
> 1. **🎓 學習階段堅持使用 `restricted`**：不要把大腦交給 AI 盲目代工，而是把 AI 當作隨身家教——**「AI 隨時看庫教學、學生親自動手在 DBeaver 敲 SQL 驗證」**，學習效果最佳且安全無虞！
> 2. **🚀 未來實務隨時切換為 `unrestricted`**：當您已經具備自主寫 SQL 與資料庫設計能力時，若想讓 AI 升級為全自動化工程師直接替您建表或寫入資料，只要回到 `.agents/mcp_config.json` 將參數改為 `--access-mode=unrestricted`，就能立刻解鎖完整權限！

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

## ✅ 過關檢查

- [ ] DBeaver 的 **Test Connection** 顯示 `Connected`
- [ ] 在 SQL 編輯器執行 `SELECT version();` 有結果
- [ ] AI 拒絕了寫入的要求，唯讀保護有效

👉 **下一步：[第 2 章：匯入範例資料庫](../範例資料庫/)**
