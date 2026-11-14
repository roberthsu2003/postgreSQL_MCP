# 步驟 5｜用 Microsoft Postgres MCP 讀結構產生 PRD

> 你已經親手建立多對多的 `customers`、`products`、`orders`、`order_items` 四張表，並完成 10 題訂單 DML 實戰。  
> 現在透過課程統一安裝好的微軟官方 **`@microsoft/postgres-mcp`**，讓 AI 讀取四張表與 `CASCADE` 結構，產生 `PRD.md`。

---

## 步驟 1：確認全域 `@microsoft/postgres-mcp` 設定（免建 `.venv`）

本課程採用微軟官方 **`@microsoft/postgres-mcp`**（透過全域 `~/.gemini/config/mcp_config.json` 以 `npx -y @microsoft/postgres-mcp run` 執行，不需要建立 Python 虛擬環境）。

### 方法 A｜沿用全域 MCP 並切換至 `online_shop` 資料庫（推薦）
若已完成 [第 1 章設定](../../../raspberry_docker安裝/4_單獨安裝mcp_server.md) 或 [Supabase 設定](../../../supabase安裝/README.md)，直接請 AI 呼叫 `postgres_mcp_connect` 切換到 `online_shop` 資料庫即可。

### 方法 B｜選用：建立專屬 `ai_readonly` 唯讀 Profile
1. 在 DBeaver 連進 `online_shop` 執行 [00_建立唯讀帳號.sql](./00_建立唯讀帳號.sql)。
2. 若需獨立 Profile，在 `~/.gemini/config/mcp_config.json` 加入以下設定並重開 Antigravity：

```json
    "shop-readonly": {
      "command": "npx",
      "args": ["-y", "@microsoft/postgres-mcp", "run"],
      "env": {
        "POSTGRES_MCP_CONNECTION_STRING": "postgresql://ai_readonly:你的密碼@主機IP:5432/online_shop"
      }
    }
```

---

## 步驟 2：確認 MCP 連得到 `online_shop`

```text
請透過 Microsoft Postgres MCP（@microsoft/postgres-mcp）連線到我的 online_shop 資料庫，只用唯讀方式確認看得到 customers, products, orders, order_items 四張表，並回報目前各自的筆數。
```

---

## 步驟 3：把下面這段貼給 AI，產生 `PRD.md`

```text
請幫我把「網路商店訂單小工具」的 PRD（產品需求文件）寫到這個資料夾的 PRD.md。

請務必先透過 Microsoft Postgres MCP（使用 postgres_mcp_connect 連線到 online_shop 資料庫，搭配 postgres_mcp_db_context 與唯讀 postgres_mcp_query）直接讀取真實資料表結構、主外來鍵與雙價位欄位；嚴禁呼叫任何修改或寫入工具。

請結合這個資料夾裡的：
1. 網路商店訂單表.xlsx（特別是「需求」工作表的 S1～S5）
2. 4_訂單查詢回答故事.md（我已經手寫驗證過 S1～S5 與 E1～E5 的查詢與結果）

我的條件：
- 我是一般上班族，會一點 SQL，想做本地桌面小工具（Python + Tkinter + psycopg2 + python-dotenv）
- 驗收數字以「5 位會員、7 項商品、10 張訂單、16 筆明細（1001 總額 1,790）」為基準，且可示範調漲快充行動電源到 950 後舊單不變、為張大同建立訂單 1011 總額 3,480 再刪除
- 這個階段只要寫 PRD，不要寫任何程式碼
- 使用繁體中文，條理清楚
```

---

## 下一步

前往 [步驟 6｜從 PRD 產生 todolist](02_PRD產生todolist.md)。
