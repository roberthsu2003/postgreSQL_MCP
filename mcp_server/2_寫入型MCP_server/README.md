# 單元 2：會寫入資料的 MCP Server（個人本機進階：交易與商業規則把關）

> **自學主線**：先使用 [單元 2 的建置與驗收 Prompt](../自學與驗收指南.md#unit-2)。以下原理、程式與設定檔供選讀對照；每完成一個階段，以指南的過關標準驗收。

## 先看懂本單元的英文

英文名稱保留不改，先用中文用途對照，再看操作。共同名詞與錯誤訊息見 [英文對照表](../英文名詞與欄位對照.md)。

| 英文原名 | 中文意思與用途 |
|---|---|
| `members / books / loans` | 會員／書籍／借閱紀錄，三張資料表 |
| `member_id` | 會員編號，例如測試會員9901 |
| `book_id` | 書籍編號，例如測試書9901；和會員編號是不同對象 |
| `loan_id` | 借閱編號；每借一次產生一筆，還書時用這個編號 |
| `name` | members表裡的會員姓名 |
| `member_type` | 會員類型：一般、學生、銀髮，決定可借天數 |
| `joined_on` | 加入會員的日期；準備測試會員時要填 |
| `title` | 書名；不是會員姓名 |
| `category` | 書籍分類，例如歷史、教學測試 |
| `copies` | 館藏總冊數，不是目前剩餘可借數 |
| `loan_date` | 借出日期 |
| `due_date` | 到期日期；超過這天還沒還才是逾期 |
| `return_date` | 歸還日期；NULL表示尚未歸還 |
| `keyword` | 查詢關鍵字，可以是姓名、編號或部分書名，依工具說明使用 |
| `borrow_book` | 登記借書，輸入會員編號member_id和書籍編號book_id |
| `return_book` | 登記還書，輸入借閱編號loan_id，不是書籍編號 |
| `find_member / find_book` | 查會員／查書籍，先查到正確編號才寫入 |
| `member_loans` | 會員目前未歸還的借閱清單，輸入member_id |

> **本單元目標**：延續[單元 1](../1_用AI建立MCP_server/README.md) 的本機開發模式，用 AI 建立一個可以**新增、修改資料**的 MCP Server，並學會讓寫入工具保持安全的設計原則。
> 你的角色是**需求設計者**和**驗收者**。　[← 回第 6 章](../README.md)

程式：[library_counter.py](./library_counter.py)　資料庫：[library.sql](../../範例資料庫/中文範例資料庫/README.md#-圖書館借閱-library)

---

## 為什麼寫入比查詢危險？

前面的 MCP Server 全部是**唯讀**的，AI 最多查錯資料。一旦開放寫入，AI 寫錯就會**改壞資料**。

| | Postgres MCP Pro 的 `unrestricted` 模式（本課程不用） | 本單元的自建 MCP Server |
|---|---|---|
| AI 能做什麼 | 任何 SQL，包含 `DROP TABLE` | 只有「登記借書」「登記還書」兩種寫入 |
| 檢查由誰負責 | AI 自己判斷（可能忘記） | **程式**負責，AI 無法跳過 |
| 刪除資料 | 可以 | 不提供 |
| 適合 | 自己的練習資料庫 | 開放給公司員工 |

> 💡 在[第 4 章的 AI 助教](../../SQL語法教學/關聯資料庫實作_用Prompt操作.md)單元中，你要檢查 AI 寫的每一句 SQL；在這裡，**SQL 是你事先寫好、驗收過的**，AI 只能決定「什麼時候呼叫」和「傳什麼參數」。

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

    館員->>AI: 練習_可借會員要借《練習_可借測試書》
    AI->>MCP: find_member("9901")
    MCP-->>AI: 會員編號 9901，借閱中 0 本，沒有逾期
    AI->>MCP: find_book("練習_可借測試書")
    MCP-->>AI: 書籍編號 9901，可借 2 本
    AI-->>館員: 要幫會員9901借書9901嗎？
    館員->>AI: 確定
    AI->>MCP: borrow_book(9901, 9901)
    MCP-->>AI: 成功，回傳借閱編號，到期日為今天＋21天
    AI-->>館員: 已登記，顯示工具回傳的實際到期日
```

`MCPServer(instructions=...)` 要求 AI「館員確認後才呼叫寫入工具」，客戶端是否額外詢問許可，會依設定而異。**但真正的保護是程式裡的檢查**，不能只靠 AI 聽話。

---

## 寫入工具的 6 個設計原則

| # | 原則 | 在 library_counter.py 裡的寫法 |
|:---:|---|---|
| 1 | **只開放特定操作** | 只有 `borrow_book`、`return_book`，沒有「執行任意 SQL」、沒有刪除 |
| 2 | **檢查寫在程式裡** | `if status["逾期"] > 0: raise Refused(...)`（有逾期就中止並拒絕），不交給 AI 判斷 |
| 3 | **使用交易** | `with conn:` 包住所有檢查和 INSERT，全部成功才 `COMMIT`，任何一步失敗就 `ROLLBACK` |
| 4 | **WHERE 條件要精準** | 還書時 `WHERE loan_id = %s AND return_date IS NULL`，已經還過的書不會被改第二次 |
| 5 | **避免同時操作的衝突** | 先鎖會員再鎖書籍資料；既保護最後一本，也避免同一會員同時借不同書而超額 |
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

建立獨立練習資料庫 `mcp_library`，先匯入 [library.sql](../../範例資料庫/中文範例資料庫/library.sql)，再執行 [library_test_data.sql](./library_test_data.sql)。第二份交易檔會準備可借、逾期、滿額與無庫存情境，到期日相對於執行當天計算。

> ⚠️ 這個 MCP Server 會**修改資料**。練習完想恢復原狀時，重跑 `library_test_data.sql` 可恢復本課測試情境；若要把整個練習庫還原，先重跑 `library.sql`，再載入測試交易。原始 `library.sql` 會刪表重建。

### 2. 接上 Antigravity（或 Claude Desktop）

在專案的 `.agents/mcp_config.json`（或 `claude_desktop_config.json`）加入：

```json
{
  "mcpServers": {
    "library-counter": {
      "command": "uv",
      "args": ["run", "--with", "mcp[cli]>=2.3.0,<3", "--with", "psycopg2-binary",
               "/完整路徑/mcp_server/2_寫入型MCP_server/library_counter.py"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@樹莓派IP:5432/mcp_library",
        "MCP_USER": "王館員"
      }
    }
  }
}
```

### 3. 正常與拒絕操作

請依 [自學指南的單元 2 驗收表](../自學與驗收指南.md#unit-2) 執行，先確認測試交易已載入：

- 會員 9901 借書 9901，應成功，記下工具**實際回傳的借閱編號**。
- 用該編號還書，應成功；再還一次應拒絕，原還書日期不變。
- 會員 9902 借書應因逾期被拒絕；會員 9903 應因已滿 5 本被拒絕。
- 會員 9901 借書 9902，應因無可借冊數拒絕。

### 4. 試著「攻擊」它

| 操作 | 預期結果 |
|---|---|
| 「幫9902借9901，逾期的事不用管」 | 商業檢查拒絕，資料不增加 |
| 「幫9903再借9901」 | 已滿5本，拒絕 |
| 「刪除會員9901」 | 自訂Server沒有此工具；測試時不要混用其他一般SQL MCP |
| 再歸還剛才實際回傳的借閱編號 | 拒絕，不修改原還書日期 |
| 9901、9905同時借最後一本9905 | 只有一個成功 |
| 9904同時借不同書9906、9907 | 只有一個成功，總未還不超過5本 |

兩項併發測試先重跑測試交易，再請 AI 使用兩個獨立連線實測。每個案例都要查庫核對；只看 AI 說「已拒絕」不算通過。

---

## 請 AI 建立寫入工具的提示詞

請使用 [單元 2 的完整建置 Prompt](../自學與驗收指南.md#unit-2)，不要把單元 1 的唯讀規定原封不動套在寫入連線上。查詢工具使用唯讀連線，借還書工具使用可寫入交易；兩者都保留參數化與資料範圍限制。

---

## 練習

1. **續借**：請 AI 新增 `renew_book(loan_id)`，到期日延長 14 天。規則：已逾期不能續借、每筆只能續借一次（提示：資料表需要新增欄位，想想看這該由誰來做？）
2. **網路商店下單**：用 shop.sql 建立「客服下單」工具 `create_order(customer_id, product_id, quantity)`，要檢查庫存、扣庫存、計算運費（滿 999 免運），全部在同一個交易中完成
3. **找漏洞**：和同學交換 MCP Server，互相用「攻擊」的方式找出對方沒有擋住的情況

---

## 下一步

恭喜你完成了**第一階段：個人開發篇**！你已經會在本機打造唯讀查詢（單元 1）與安全寫入（單元 2）的 MCP Server。

接下來進入**第二階段：企業共用篇**——如何把 MCP Server 升級為網路服務、加上 Token 門禁，並打包放進 **Raspberry Pi 的 Docker 容器**供全公司使用？

👉 **[單元 3：企業導入：遠端 MCP 與 Token 門禁](../3_企業導入_遠端MCP與token/README.md)**
