# 專案規範與環境設定

## MCP 執行環境規範
- **免建立虛擬環境**：本專案採用微軟官方 MCP Server（`@microsoft/postgres-mcp`），位於全域設定 `~/.gemini/config/mcp_config.json`，透過 `npx` 直接執行，**完全不需要建立或使用 Python 虛擬環境（免建 `.venv`）**。
- **MCP Server 執行方式**：直接調用 `npx -y @microsoft/postgres-mcp run`，連線字串透過環境變數 `POSTGRES_MCP_CONNECTION_STRING` 傳入。
