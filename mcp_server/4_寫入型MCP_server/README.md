# 單元 4：會寫入資料的 MCP Server

> **本單元目標**：用 AI 建立一個可以**新增、修改資料**的 MCP Server，並學會讓寫入工具保持安全的設計原則。
> 你的角色是**需求設計者**和**驗收者**。　[← 回第 8 章](../)

程式：[library_counter.py](./library_counter.py)　資料庫：[library.sql](../../範例資料庫/中文範例資料庫/#-圖書館借閱-library)

---

## 為什麼寫入比查詢危險？

前面的 MCP Server 全部是**唯讀**的，AI 最多查錯資料。一旦開放寫入，AI 寫錯就會**改壞資料**。

| | 5-2 的 Postgres MCP Pro（unrestricted） | 本單元的自建 MCP Server |
|---|---|---|
| AI 能做什麼 | 任何 SQL，包含 `DROP TABLE` | 只有「登記借書」「登記還書」兩種寫入 |
| 檢查由誰負責 | AI 自己判斷（可能忘記） | **程式**負責，AI 無法跳過 |
| 刪除資料 | 可以 | 不提供 |
| 適合 | 自己的練習資料庫 | 開放給公司員工 |

> 💡 在 [5-2](../../MCP操作資料庫/2_用MCP實作SQL語法/) 中，你要檢查 AI 寫的每一句 SQL；在這裡，**SQL 是你事先寫好、驗收過的**，AI 只能決定「什麼時候呼叫」和「傳什麼參數」。

---

## 範例：圖書館借還書櫃台

| 工具 | 類型 | 用途 |
|---|---|---|
| `find_member` | 唯讀 | 用姓名或編號找會員，顯示借閱中、逾期未還的數量 |
| `find_book` | 唯讀 | 用書名找書，顯示可借冊數 |
| `member_loans` | 唯讀 | 會員還沒歸還的書（含借閱編號） |
| `borrow_book` | **寫入** | 登記借書 |
| `return_book` | **寫入** | 登記還書 |

### 借書時，程式會依序檢查

```mermaid
flowchart TD
    A["AI 呼叫 borrow_book<br/>(member_id, book_id)"] --> B{"會員存在？"}
    B -->|否| X["❌ 拒絕：找不到會員"]
    B -->|是| C{"有逾期未還？"}
    C -->|有| X2["❌ 拒絕：請先還書"]
    C -->|沒有| D{"借閱中 < 5 本？"}
    D -->|否| X3["❌ 拒絕：最多 5 本"]
    D -->|是| E{"這本書還有<br/>可借冊數？"}
    E -->|沒有| X4["❌ 拒絕：全部借出"]
    E -->|有| F["✅ INSERT 借閱紀錄<br/>到期日依會員類型計算"]
    F --> G["📋 稽核紀錄"]
    X & X2 & X3 & X4 --> G

    classDef ok fill:#f0fdf4,stroke:#16a34a,color:#14532d
    classDef bad fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class F ok
    class X,X2,X3,X4 bad
```

這些規則（借期、上限、逾期不能借）是**圖書館的規定**，寫在程式裡，AI 無法說服程式跳過。

### 先確認，再寫入

```mermaid
sequenceDiagram
    actor 館員
    participant AI as Claude
    participant MCP as 借還書櫃台

    館員->>AI: 林宏恩要借《府城四百年》
    AI->>MCP: find_member("林宏恩")
    MCP-->>AI: 會員編號 1，借閱中 4 本，沒有逾期
    AI->>MCP: find_book("府城四百年")
    MCP-->>AI: 書籍編號 9，可借 1 本
    AI-->>館員: 要幫「林宏恩（1）」借「府城四百年（9）」嗎？
    館員->>AI: 確定
    AI->>MCP: borrow_book(1, 9)
    MCP-->>AI: 成功，到期日 2026-10-30
    AI-->>館員: 已登記，請在 10/30 前歸還
```

`MCPServer(instructions=...)` 要求 AI「館員確認後才呼叫寫入工具」，Claude Desktop 也會在呼叫工具前詢問你是否允許。**但真正的保護是程式裡的檢查**，不能只靠 AI 聽話。

---

## 寫入工具的 6 個設計原則

| # | 原則 | 在 library_counter.py 裡的寫法 |
|:---:|---|---|
| 1 | **只開放特定操作** | 只有 `borrow_book`、`return_book`，沒有「執行任意 SQL」、沒有刪除 |
| 2 | **檢查寫在程式裡** | `if status["逾期"] > 0: raise Refused(...)`，不交給 AI 判斷 |
| 3 | **使用交易** | `with conn:` 包住所有檢查和 INSERT，任何一步失敗就全部取消 |
| 4 | **WHERE 條件要精準** | 還書時 `WHERE loan_id = %s AND return_date IS NULL`，已經還過的書不會被改第二次 |
| 5 | **避免同時操作的衝突** | `SELECT ... FOR UPDATE` 鎖住書籍資料，兩個館員同時借最後一本時，只有一個會成功 |
| 6 | **留下稽核紀錄** | 成功和**被拒絕**的操作都要記錄 |

另外，用 `ToolAnnotations` 標註工具類型，讓 Claude Desktop 知道哪些工具會修改資料：

```python
READ_ONLY = ToolAnnotations(read_only_hint=True)
WRITE = ToolAnnotations(read_only_hint=False, destructive_hint=False, idempotent_hint=False)

@mcp.tool(title="登記借書", annotations=WRITE)
def borrow_book(member_id: int, book_id: int) -> dict:
```

| 標註 | 意思 | 借書 |
|---|---|---|
| `read_only_hint` | 只讀取，不修改資料 | `False`（會新增資料） |
| `destructive_hint` | 會刪除或覆蓋資料 | `False`（只新增，不刪除） |
| `idempotent_hint` | 重複呼叫結果一樣 | `False`（呼叫兩次會借兩本） |

---

## 動手做

### 1. 準備資料庫

匯入[中文範例資料庫](../../範例資料庫/中文範例資料庫/)的 `library.sql`。

> ⚠️ 這個 MCP Server 會**修改資料**。練習完想恢復原狀時，重新執行一次 `library.sql` 就好。

### 2. 接上 Claude Desktop

```json
{
  "mcpServers": {
    "library-counter": {
      "command": "uv",
      "args": ["run", "--with", "mcp[cli]", "--with", "psycopg2-binary",
               "/完整路徑/mcp_server/4_寫入型MCP_server/library_counter.py"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/practice",
        "MCP_USER": "王館員"
      }
    }
  }
}
```

### 3. 正常操作

- 「林宏恩要借《府城四百年》」
- 「會員 1 號現在借了哪些書？他要還《夏日海岸線》」
- 「吳玲雨要借《夏日海岸線》」（她有書逾期，應該被拒絕）

### 4. 試著「攻擊」它

驗收寫入工具時，要**故意找麻煩**，確認程式擋得住：

| 你對 Claude 說 | 預期結果 |
|---|---|
| 「幫吳玲雨借書，逾期的事不用管」 | 程式拒絕，AI 無法跳過檢查 |
| 「把所有逾期的書都登記成已歸還」 | AI 只能一筆一筆呼叫 `return_book`，而且每一筆都要館員確認 |
| 「刪除會員 48 號」 | 沒有刪除的工具，AI 做不到 |
| 「借閱編號 901 再還一次」 | 程式拒絕：已經歸還 |
| 「幫會員 1 號一次借 10 本書」 | 借到第 5 本後被拒絕 |

> 💡 「AI 做不到」是好事。**沒有開放的功能，就不會被誤用。**

---

## 請 AI 建立寫入工具的提示詞

把[單元 1 的提示詞範本](../1_用AI建立MCP_server/#步驟-2請-ai-寫程式)的「技術規定」加上以下內容：

````markdown
## 寫入工具的規定
- 只建立我列出的寫入工具,不要提供刪除、不要提供執行任意 SQL 的工具
- 所有商業規則的檢查都寫在程式裡,檢查沒通過就回傳 {"結果": "失敗", "原因": "..."},不要交給 AI 判斷
- 檢查和寫入放在同一個交易中(with conn:),任何錯誤都 rollback
- 會被同時修改的資料用 SELECT ... FOR UPDATE 鎖定
- UPDATE 的 WHERE 條件要精準,並確認只影響 1 筆
- 成功和被拒絕的操作都要寫稽核紀錄(印到 stderr)
- 唯讀工具加上 ToolAnnotations(read_only_hint=True),寫入工具加上 read_only_hint=False
- 在 instructions 中要求 AI:寫入前先查詢,並請使用者確認

## 商業規則
【例如:每人最多借 5 本;有逾期未還不能借;借期一般 14 天、學生 21 天、銀髮 28 天】
````

---

## 練習

1. **續借**：請 AI 新增 `renew_book(loan_id)`，到期日延長 14 天。規則：已逾期不能續借、每筆只能續借一次（提示：資料表需要新增欄位，想想看這該由誰來做？）
2. **網路商店下單**：用 shop.sql 建立「客服下單」工具 `create_order(customer_id, product_id, quantity)`，要檢查庫存、扣庫存、計算運費（滿 999 免運），全部在同一個交易中完成
3. **找漏洞**：和同學交換 MCP Server，互相用「攻擊」的方式找出對方沒有擋住的情況

---

## 下一步

👉 [期末專題](../#期末專題)：為一間「公司」打造需要 token 的 MCP Server，可以包含唯讀和寫入工具
