# 3-2：自然語言查詢資料庫

> **本單元目標**：還沒學 SQL，也能用中文問問題，讓 AI 透過專案級 MCP 查詢資料庫。
> 你的角色是**提問的人**（不需要寫任何程式）。　[← 回第 3 章](../)

## 事前準備

- [ ] 已依照第 2 章，把[網路商店 shop.sql](../../範例資料庫/中文範例資料庫/#-網路商店-shop) 匯入 `practice` 資料庫
- [ ] 已依照 [3-1](../1_antigravity設定.md) 在專案 `.agents/mcp_config.json` 設定好 `postgres`（連到 `practice`）

> 💡 **免全域安裝**：只要在 Antigravity 中開啟本專案資料夾，專案專屬的 MCP 就會自動啟動，離開專案便不佔資源。

---

## 1. 先認識資料庫

第一次接觸一個資料庫，先請 AI 帶你認識它。直接在 **Antigravity 對話框**中輸入：

> 用 postgres 查詢 practice 資料庫，裡面有哪些資料表？每張資料表大概存什麼資料？

> customers、orders、order_items、products 這四張資料表之間有什麼關係？用圖或表格說明。

> 網路商店總共有幾位會員、幾項商品、幾筆訂單？

**對答案：** 150 位會員、47 項商品、700 筆訂單

### 觀察 AI 怎麼做

在 Antigravity 中點開工具呼叫紀錄，你會看到 AI 依序呼叫：

```mermaid
flowchart LR
    A["list_objects<br/>有哪些資料表"] --> B["get_object_details<br/>每張表有哪些欄位"] --> C["execute_sql<br/>執行查詢"]
```

AI 會**先了解資料表結構，再寫出查詢**。`execute_sql` 裡面那段文字就是 **SQL**，第 4 章開始你會學到怎麼自己寫出它。

---

## 2. 用中文問問題

每一題都附上答案，用來確認 AI 有沒有答對。

### 基本查詢

| # | 在 Antigravity 中提問 | 答案 |
|:---:|---|---|
| 1 | 最貴的商品是什麼？多少錢？ | 機械式鍵盤，2,490 元 |
| 2 | 哪些商品缺貨（庫存是 0）？ | 無線藍牙耳機、方格筆記本 A5、地瓜脆片、竹纖維毛巾 3 入、素面圓領 T 恤、護唇膏，共 6 項 |
| 3 | 哪個縣市的會員最多？ | 新北市 24 位，其次是高雄市 23 位 |
| 4 | 每種付款方式各有幾筆訂單？ | 信用卡 328、LINE Pay 163、貨到付款 130、ATM 轉帳 79 |

### 需要合併多張資料表

| # | 在 Antigravity 中提問 | 答案 |
|:---:|---|---|
| 5 | 2025 年（只算已完成的訂單）賣出數量最多的 3 項商品 | 防曬乳 SPF50（85）、USB-C 快充線（75）、竹纖維毛巾 3 入（73） |
| 6 | 營業額最高的商品分類是哪一個？ | 3C周邊 |
| 7 | 消費金額最高的會員是誰？（只算已完成的訂單） | 徐淑宜 |
| 8 | 有幾位會員從來沒有下過訂單？ | 18 位 |
| 9 | 哪個月的訂單最多？ | 12 月，89 筆 |
| 10 | 總經理王大明底下直接管理幾位主管？ | 4 位 |

> 💡 **答案不一樣怎麼辦？** 先追問「你是怎麼算的？」。常見原因：AI 把「已取消」的訂單也算進去、把「數量」和「金額」搞混。**問題描述得越清楚，答案越準確。**

### 讓 AI 幫你整理

> 把每個月的訂單數和營業額整理成表格，並畫成折線圖。

> 根據這些資料，寫一段 200 字的「2025 年銷售摘要」給主管看。

> 哪些商品快缺貨了（庫存少於 20）？幫我整理成補貨清單。

---

## 3. 看看 AI 寫的 SQL

挑一題剛才的問題，追問：

> 把你剛才執行的 SQL 給我看，並用中文逐行解釋每一行在做什麼。

你會看到類似這樣的 SQL：

```sql
SELECT name, price
FROM products
ORDER BY price DESC
LIMIT 1;
```

現在看不懂沒關係。**第 4 章會一步一步帶你親手學會這些語法**，每一課也會讓你練習如何透過 AI 輔助與比對。學完之後，你就能一眼判斷 AI 寫的 SQL 正不正確。

---

## 4. 準備第 4 章：多一條連到 `cafe_shop` 的唯讀連線

第 4 章會用 `cafe_shop` 練習，AI 助教要能看到它的結構，才能給你正確的建議。

### 4.1 建立資料庫並匯入

在 DBeaver 建立資料庫 `cafe_shop`，再執行 [`cafe_shop.sql`](../../範例資料庫/中文範例資料庫/cafe_shop.sql)。

> [!IMPORTANT]
> `cafe_shop` 和 `shop` 有同名的資料表，**不可以匯入同一個資料庫**，否則後者會覆蓋前者。

### 4.2 在專案 `.agents/mcp_config.json` 新增連線

**保留**原本的 `postgres`，**另外新增** `postgres-cafe`：

```json
{
  "mcpServers": {
    "postgres": {
      "command": "uvx",
      "args": ["--with", "mcp<2", "postgres-mcp", "--access-mode=restricted"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice"
      }
    },
    "postgres-cafe": {
      "command": "uvx",
      "args": ["--with", "mcp<2", "postgres-mcp", "--access-mode=restricted"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/cafe_shop"
      }
    }
  }
}
```

| 連線名稱 | 模式 | 資料庫 | 主要用途 |
|---|---|---|---|
| `postgres` | 唯讀 | `practice` | 查詢網路商店等範例資料 |
| `postgres-cafe` | 唯讀 | `cafe_shop` | 第 4 章請 AI 助教看結構、批改你的 SQL |

存檔後問 AI：「用 postgres-cafe 列出有哪些資料表」，回答 7 張表就成功了。再請它「新增一張資料表」，它應該要**拒絕**，這才代表唯讀保護有效。

> [!NOTE]
> 第 4 章的 SQL 都由你親手在 DBeaver 執行，AI 只負責解釋和批改。

## ✅ 過關檢查

- [ ] AI 回答的前 5 題，我都和上面的答案對過
- [ ] 我看過 AI 執行的 SQL，也知道答案不同時要追問
- [ ] AI 拒絕了寫入的要求

---

## 下一步

👉 **[進入第 4 章：SQL 語法與實戰練功](../../README.md#4-sql-語法與實戰練功)**：從建立資料庫開始，親自動手寫 SQL。
