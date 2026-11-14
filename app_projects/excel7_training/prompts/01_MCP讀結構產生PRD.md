# 步驟 2：讓 AI 透過 Microsoft Postgres MCP 讀結構，寫出 PRD.md

這一步讓 AI 透過全域設定的 **Microsoft Postgres MCP**（`@microsoft/postgres-mcp`）讀取你親手建立的資料庫結構，並明確限制 AI **只做唯讀查詢**。

## 1. 確認全域 Microsoft Postgres MCP 與連線資料庫

本專案採用全域設定 `~/.gemini/config/mcp_config.json`，透過 `npx -y @microsoft/postgres-mcp run` 執行（**不需要建立 Python 虛擬環境 `.venv`**），連線字串透過環境變數 `POSTGRES_MCP_CONNECTION_STRING` 傳入。

切換目標資料庫有兩種做法，選一種即可：

- **做法 A（推薦，不用改設定檔）**：沿用既有的連線設定檔，直接請 AI 用 `postgres_mcp_connect` 工具切換至 `training` 資料庫。
- **做法 B（專用唯讀連線，選用）**：先在 DBeaver 切換至 `training` 執行 [`00_建立唯讀帳號.sql`](./00_建立唯讀帳號.sql)，再在 `~/.gemini/config/mcp_config.json` 新增或使用 `ai_readonly` 的連線字串：
  ```json
  "training-postgres": {
    "command": "npx",
    "args": ["-y", "@microsoft/postgres-mcp", "run"],
    "env": {
      "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:專案1設定的密碼@你的主機位址:5432/training"
    }
  }
  ```

> [!WARNING]
> 若有將連線密碼寫入設定檔，絕對不要把含密碼的設定檔上傳到 GitHub 或傳給別人。

## 2. 複製以下提示詞給 AI

把你在步驟 4 整理好的 `我的查詢.sql` 附加到對話，並貼上 Excel「需求」工作表的五則故事。

```markdown
你是協助上班族規劃個人工具的產品經理。

請使用 Microsoft Postgres MCP 工具連線至 training 資料庫（若預設不在 training，請先用 postgres_mcp_connect 切換），並用 postgres_mcp_db_context 與 postgres_mcp_query 讀取 courses、employees、guests、employee_enrollments、guest_enrollments 五張資料表的實際結構與幾筆樣本資料。
只能進行唯讀查詢，嚴禁使用 postgres_mcp_modify 新增、修改或刪除任何資料。

我的使用者故事：
（貼上五則故事與驗收條件）

我已經在 DBeaver 驗證過的 SQL 在附件 我的查詢.sql。

請在目前資料夾產生 PRD.md，內容包含：
1. 這個工具要解決什麼問題、給誰用
2. 不做的事情（這是單人使用的本機桌面工具，不做登入、不做網站）
3. 功能清單：每個功能都標明對應的故事編號，以及 我的查詢.sql 裡的哪一句
4. 每個功能的驗收條件：用「我做什麼，應該看到什麼」來寫，並盡量使用資料庫的真實資料當例子
5. 用到的資料欄位：只能列出你從資料庫實際讀到的欄位

寫作規則：
- 使用繁體中文和業務語言，讓不會寫程式的訓練承辦人員看得懂
- 不要寫視窗元件名稱、程式檔案名稱或程式語言細節
- 如果故事有不清楚或矛盾的地方，先列出來問我，不要自己假設
```

## 3. 檢查 AI 的 PRD

- [ ] 五則故事都有對應的功能，沒有多出你沒要求的功能
- [ ] 列出的欄位在這五張表裡都真的存在
- [ ] 看到「我做什麼，應該看到什麼」，就知道要怎麼驗收
- [ ] 沒有出現你看不懂的技術名詞

有問題就請 AI 修改，確認後再進行下一步。可以和[範例 PRD](../PRD.md) 對照。

下一步：[PRD 產生 todolist](./02_PRD產生todolist.md)
