# 3-2：第一次用中文查詢資料庫

> **本單元目標**：還沒學 SQL，也能用中文問問題，讓 AI 透過 MCP 查詢資料庫。
> 你的角色是**提問的人**。　[← 回第 3 章](../)

## 事前準備

- [x] 已依照第 2 章，把[網路商店 shop.sql](../../範例資料庫/中文範例資料庫/#-網路商店-shop) 匯入 `practice` 資料庫
- [x] 已依照 [3-1](../1_postgres_mcp_pro/) 在 Claude Desktop 設定好 `postgres`（`restricted` 唯讀模式，連到 `practice`）

> `restricted` 模式只能查詢，**不會改到任何資料**，可以放心亂問。

---

## 1. 先認識資料庫

第一次接觸一個資料庫，先請 AI 帶你認識它：

> 用 postgres 查詢 practice 資料庫，裡面有哪些資料表？每張資料表大概存什麼資料？

> customers、orders、order_items、products 這四張資料表之間有什麼關係？用圖或表格說明。

> 網路商店總共有幾位會員、幾項商品、幾筆訂單？

**對答案：** 150 位會員、47 項商品、700 筆訂單

### 觀察 AI 怎麼做

在 Claude Desktop 中點開工具呼叫的紀錄，你會看到 AI 依序呼叫：

```mermaid
flowchart LR
    A["list_objects<br/>有哪些資料表"] --> B["get_object_details<br/>每張表有哪些欄位"] --> C["execute_sql<br/>執行查詢"]
```

AI 會**先了解資料表結構，再寫出查詢**。`execute_sql` 裡面那段文字就是 **SQL**，第 4 章開始你會學到怎麼看懂它。

---

## 2. 用中文問問題

每一題都附上答案，用來確認 AI 有沒有答對。

### 基本查詢

| # | 問 Claude | 答案 |
|:---:|---|---|
| 1 | 最貴的商品是什麼？多少錢？ | 機械式鍵盤，2,490 元 |
| 2 | 哪些商品缺貨（庫存是 0）？ | 無線藍牙耳機、方格筆記本 A5、地瓜脆片、竹纖維毛巾 3 入、素面圓領 T 恤、護唇膏，共 6 項 |
| 3 | 哪個縣市的會員最多？ | 新北市 24 位，其次是高雄市 23 位 |
| 4 | 每種付款方式各有幾筆訂單？ | 信用卡 328、LINE Pay 163、貨到付款 130、ATM 轉帳 79 |

### 需要合併多張資料表

| # | 問 Claude | 答案 |
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

> 根據這些資料，寫一段 200 字的「2025 年銷售摘要」給老闆看。

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

現在看不懂沒關係。**第 4 章會一句一句教你這些語法**，每一課的最後也會教你怎麼用 prompt 讓 AI 做出一樣的結果。學完之後，你就能判斷 AI 寫的 SQL 對不對。

---

## 4. 試試看：AI 不能做的事

> 刪除所有已取消的訂單。

因為是 `restricted` 模式，AI 會告訴你**無法修改資料**。這就是唯讀模式的保護。

---

## 5. 更多資料庫

把 `DATABASE_URI` 換成其他範例資料庫，重新啟動 Claude Desktop 再提問（`school.sql`、`library.sql` 也可以全部匯入 `practice`，不用換）：

| 資料庫 | 可以問 |
|---|---|
| 🎓 學校選課 | 「113-2 學期有哪些學生兩科以上不及格？」「哪門課的平均分數最低？」 |
| 📚 圖書館借閱 | 「現在有哪些書逾期還沒還？逾期幾天？」「2025 年最熱門的 5 本書」 |
| 🚆 台鐵進出站 | 「2022 年進站人數最多的 5 個車站」「臺北車站每個月的平均進站人數」 |

進階：Postgres MCP Pro 也能分析效能

> 幫我做一次資料庫健康檢查。

> 分析這個查詢為什麼慢，應該加什麼索引？（貼上一段 SQL）

---

## 6. 準備第 4 章：設定「可寫入」的連線

第 4 章每一課最後，會用 prompt 讓 AI **建立資料表、新增、修改、刪除資料**，需要一個可以寫入的連線。

### 6.1 用 pgAdmin 建立練習用的資料庫

```sql
CREATE DATABASE sql_tutorial;
```

> AI 透過 Postgres MCP Pro **不能建立資料庫**（會出現 `cannot run inside a transaction block`），這一步要自己在 pgAdmin 執行。

### 6.2 在 Claude Desktop 新增 `postgres-sql`

在 `claude_desktop_config.json` 的 `mcpServers` 中，**保留**原本的 `postgres`，**另外新增**一個 `unrestricted` 的連線：

```json
"postgres-sql": {
  "command": "docker",
  "args": ["run", "-i", "--rm", "-e", "DATABASE_URI", "crystaldba/postgres-mcp", "--access-mode=unrestricted"],
  "env": {
    "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/sql_tutorial"
  }
}
```

使用 uvx 時，`args` 改成 `["--with", "mcp<2", "postgres-mcp", "--access-mode=unrestricted"]`（見 [3-1](../1_postgres_mcp_pro/#使用-uvx-的設定)）。

| 連線名稱 | 模式 | 資料庫 | 用途 |
|---|---|---|---|
| `postgres` | restricted（唯讀） | practice | 查詢範例資料，不會改壞 |
| `postgres-sql` | **unrestricted（可寫入）** | sql_tutorial | 第 4 章跟著講義建立資料表、新增修改資料 |

> ⚠️ **`unrestricted` 只能連練習用的資料庫**。AI 可以建立、修改、刪除任何資料。

重新啟動 Claude Desktop 後問：「用 postgres-sql 列出 sql_tutorial 有哪些資料表」，回答「沒有資料表」就代表設定成功。

---

## 下一步

👉 [第 4 章：SQL 語法](../../README.md#4-sql-語法)：每一課先學 SQL，最後再用 prompt 讓 AI 做一次，對照 AI 寫的 SQL 和你學的是否一樣。
