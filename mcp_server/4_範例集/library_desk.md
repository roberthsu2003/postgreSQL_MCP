# 範例 3：📚 圖書館館員助理

程式：[library_desk.py](./library_desk.py)　資料庫：[library.sql](../../範例資料庫/中文範例資料庫/#-圖書館借閱-library)　[← 回範例集](./README.md)

## 情境

讀者在櫃台問：「這本書還有沒有？」館員每週還要整理逾期名單、打電話催還，月底要做熱門書排行。

## 工具

| 工具 | 用途 | 參數 |
|---|---|---|
| `search_books` | 用書名、作者、出版社找書，顯示**目前可借冊數** | 關鍵字 |
| `overdue_loans` | 逾期未還的清單，依逾期天數排序 | — |
| `member_loans` | 某位會員的借閱紀錄 | 會員編號、是否只看未還 |
| `popular_books` | 某年借閱次數排行，可指定分類 | 年份、分類、筆數 |

## 可以這樣問

- 「有沒有跟臺灣歷史有關的書？現在可以借嗎？」
- 「列出逾期超過 30 天還沒還書的人，幫我寫一則催還簡訊範本」
- 「2025 年電腦資訊類最熱門的 3 本書」
- 「會員 3 號現在手上有幾本書還沒還？」

## 學到的技巧

### 1. 可借冊數：館藏冊數 − 借出未還

```sql
LEFT JOIN loans l ON b.book_id = l.book_id AND l.return_date IS NULL   -- 只 JOIN「還沒還」的借閱
…
GREATEST(b.copies - COUNT(l.loan_id), 0) AS 可借冊數                     -- 最少是 0
```

### 2. 日期相減：逾期天數

```sql
CURRENT_DATE - l.due_date AS 逾期天數
```

`CURRENT_DATE` 是今天，所以每天查詢的結果都不一樣。

### 3. 可選的篩選條件

「分類」可以不指定（全部），也可以指定某一類，一段 SQL 就能處理：

```python
Category = Literal["全部", "文學小說", "歷史", "科普", …]

sql = "… AND (%s = '全部' OR b.category = %s)"
query(sql, (year, category, category, limit))
```

## 產生這個範例的提示詞

````markdown
請參考 common.py 的寫法,用 MCP Python SDK(mcp 2.x 的 MCPServer)建立「圖書館館員助理」MCP Server。
使用者是社區圖書館的櫃台館員。

## 規定
- 使用 common.py 的 query()、audit()、run(),每個工具開頭都要呼叫 audit()
- 所有參數用 %s 參數化查詢;書籍分類用 Literal 限定(包含「全部」)
- 在 instructions 說明:歸還日期是空值代表還沒有還書
- 工具說明用繁體中文

## 資料表
【貼上 library.sql 的 CREATE TABLE 語法】

## 工具
1. search_books(keyword):用書名、作者、出版社搜尋,顯示館藏冊數和目前可借冊數(館藏冊數 - 未還的借閱,最少為 0)
2. overdue_loans():逾期未還清單,包含逾期天數,依逾期天數由多到少排序
3. member_loans(member_id, only_unreturned):某會員最近 30 筆借閱紀錄
4. popular_books(year, category, limit):某年借閱次數排行,用 RANK() 排名,最多 50 筆
````

## 延伸挑戰

1. 新增 `overdue_fine(member_id)`：計算逾期罰款（每本每天 5 元，最多 100 元）
2. 新增 `never_borrowed_books()`：從來沒有被借過的書，作為汰舊或推廣的參考
3. 思考：如果要讓 AI **登記借書**，要檢查哪些事情？（可借冊數、會員是否有逾期未還……）
