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
開啟專案根目錄下的 [`.agents/mcp_config.json`](file:///Users/roberthsu2003/Documents/GitHub/postgreSQL_MCP/.agents/mcp_config.json)，加入 Supabase 連線設定（連線字串末尾建議加上 `?sslmode=require`）：

```json
{
  "mcpServers": {
    "supabase-postgres": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "DATABASE_URI",
        "crystaldba/postgres-mcp",
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
> 儲存後，直接在 Antigravity 聊天框輸入：「請幫我查詢目前 Supabase 資料庫中的資料表」，AI 就會調用 MCP 自動查詢！

---

## 5. 常見問題與注意事項

1. **免費版專案自動休眠：**
   * Supabase 免費專案若連續 7 天沒有存取，會自動進入「休眠狀態（Paused）」。
   * 若 DBeaver 或 MCP 連不上，請登入 Supabase 後台點選 **Restore project**，約 1 分鐘後即可恢復正常。
2. **連線逾時 (Timeout)：**
   * 請確認使用的是 **Session pooler (IPv4)** 的主機位址，而非 Direct connection (IPv6)。
3. **密碼安全性提醒：**
   * `.agents/mcp_config.json` 包含資料庫密碼，切勿將含真實密碼的檔案推送到公開的 GitHub Repository。
