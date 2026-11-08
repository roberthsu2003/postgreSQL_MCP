# 專案規範與環境設定

## MCP 執行環境規範
- **免建立虛擬環境**：本專案的 MCP Server 採用全域設定（位於 `~/.gemini/config/mcp_config.json`），使用 `uvx` 直接執行，**不需要建立或使用本機專案虛擬環境（免建 `.venv`）**。
- **MCP Server 執行方式**：直接調用 `uvx postgres-mcp`，由 `uvx` 自行管理暫存隔離環境，無需加上 `--python .venv` 參數。
