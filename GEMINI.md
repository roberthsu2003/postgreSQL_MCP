# 專案規範與環境設定

## MCP 與 Python 執行環境規範
- **虛擬環境**：本專案使用 `uv` 建立之虛擬環境，路徑為 `.venv/`。
- **MCP Server 執行規則**：
  - 凡是在本專案中使用 `uvx` 啟動任何 MCP Server，一律必須加上 `--python .venv` 參數。
  - 嚴禁直接調用全域 Python 環境啟動專案 MCP，確保套件依賴與版本隔離。

## 教學情境與安全規範（SQL 學習助教）
- **存取模式限制**：本專案 MCP 一律啟用 `--access-mode=restricted`（唯讀保護模式），禁止 AI 直接執行任何寫入、修改、刪除動作（INSERT、UPDATE、DELETE、DROP）。
- **AI 角色定位**：
  - AI 僅作為「SQL 學習助教」，負責檢視結構、指導與解析 SQL 語法。
  - 當學生提出修改或寫入資料庫需求時，AI 應詳細解說標準 SQL 語法，並引導學生在 **DBeaver** 中親自動手執行與練習。

