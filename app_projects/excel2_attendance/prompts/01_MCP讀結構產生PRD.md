# 步驟 2：讓 AI 讀資料庫結構，寫出 PRD.md

這一步讓 AI 透過 MCP 讀取資料庫結構，用唯讀帳號就夠了。

## 1. 授權唯讀帳號

`ai_readonly` 帳號在專案 1 已經建立過，不用重建。打開 [`00_建立唯讀帳號.sql`](./00_建立唯讀帳號.sql)，在 DBeaver 切換到 `attendance` 後執行，補上這個資料庫的權限。

## 2. 新增 MCP 連線

依照 [MCP 設定教學](../../../MCP操作資料庫/1_antigravity設定.md)，在專案的 `.agents/mcp_config.json` 的 `mcpServers` 裡新增一組連線。主機位址請換成你自己的：

```json
"postgres-attendance": {
  "command": "uvx",
  "args": ["--with", "mcp<2", "postgres-mcp", "--access-mode=restricted"],
  "env": {
    "DATABASE_URI": "postgresql://ai_readonly:專案1設定的密碼@localhost:5432/attendance"
  }
}
```

> [!WARNING]
> 這個檔案有密碼，不要上傳到 GitHub 或傳給別人。

## 3. 複製以下提示詞給 AI

把 `我的查詢.sql` 附加到對話，並貼上 Excel「需求」工作表的五則故事。

```markdown
你是協助上班族規劃個人工具的產品經理。

請用 MCP 連線 postgres-attendance 讀取 employees、attendance 兩張資料表的實際結構和幾筆資料。
只能讀取，不要嘗試新增、修改或刪除任何資料。

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
- 使用繁體中文和業務語言，讓不會寫程式的人資人員看得懂
- 不要寫視窗元件名稱、程式檔案名稱或程式語言細節
- 如果故事有不清楚或矛盾的地方，先列出來問我，不要自己假設
```

## 4. 檢查 AI 的 PRD

- [ ] 五則故事都有對應的功能，沒有多出你沒要求的功能
- [ ] 列出的欄位在 `employees`、`attendance` 表裡都真的存在
- [ ] 看到「我做什麼，應該看到什麼」，就知道要怎麼驗收
- [ ] 沒有出現你看不懂的技術名詞

有問題就請 AI 修改，確認後再進行下一步。可以和[範例 PRD](../PRD.md) 對照。

下一步：[PRD 產生 todolist](./02_PRD產生todolist.md)
