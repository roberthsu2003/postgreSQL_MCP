# 範例 5：📈 股市大盤查詢

程式：[stock.py](./stock.py)　資料來源：[實戰專案：大盤股市](../../tutorial_container/範例/1stock_market/)　[← 回範例集](./README.md)

## 情境

理財專員要準備客戶簡報：「今年台股表現如何？跟港股比呢？」以前要到處找資料、自己算漲跌幅。

## 事前準備

先執行實戰專案的 notebook，把大盤資料存進 `市場`、`股市` 兩張資料表（實戰專案使用 `stock_market` 資料庫）：

```bash
export DATABASE_URI="postgresql://postgres:你的密碼@localhost:5432/stock_market"
```

## 工具

| 工具 | 用途 | 參數 |
|---|---|---|
| `list_markets` | 有哪些市場、資料的起訖日期 | — |
| `price_history` | 一段期間的收盤指數與成交量，可依日／週／月彙總 | 市場、起訖日期、間隔 |
| `yearly_summary` | 每一年的年初、年底、最高、最低與漲跌幅 | 市場 |
| `compare_markets` | 所有市場同一段期間的漲跌幅比較 | 起訖日期 |

`market` 參數可以輸入代號（`^TWII`）或國家（`台灣`），AI 不用記代號。

## 可以這樣問

- 「資料庫裡有哪些市場？資料從什麼時候開始？」
- 「台股過去每一年的漲跌幅是多少？哪一年最好？」
- 「2025 年台股和港股誰表現比較好？」
- 「台股 2025 年每個月的收盤指數，畫成折線圖」

> 💡 最後一題 Claude 會把工具回傳的資料畫成圖表。**MCP Server 只負責提供資料，呈現方式交給 AI。**

## 學到的技巧

### 1. 避免一次回傳太多資料

從 1997 年開始的每日資料有好幾千筆，全部丟給 AI 既慢又浪費。用 `interval` 讓 AI 選擇彙總的單位，再加上筆數上限：

```python
def price_history(market: str, start_date: date, end_date: date,
                  interval: Literal["日", "週", "月"] = "月"):
    unit = {"日": "day", "週": "week", "月": "month"}[interval]   # 對應到寫好的 SQL 片段
    sql = f"SELECT DATE_TRUNC('{unit}', s.date) AS 期間, … LIMIT 400"
```

工具說明寫「期間很長時請用『月』」，AI 就會自己選擇適當的間隔。

### 2. 期初、期末與漲跌幅

```sql
(ARRAY_AGG(s.adj_close ORDER BY s.date))[1]        AS 期初   -- 依日期排序後的第一筆
(ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1]   AS 期末   -- 依日期反向排序後的第一筆
(期末 / 期初 - 1) * 100                             AS 漲跌幅百分比
```

### 3. 踩過的坑：欄位名稱不能有 `%`

原本欄位名稱寫成 `"漲跌幅(%)"`，執行時發生錯誤。因為在有傳參數的 SQL 裡，**`%` 是參數符號**（`%s`），psycopg2 會把 `%)` 當成錯誤的參數。改成 `漲跌幅百分比` 就解決了。

> 💡 這類錯誤訊息直接貼給 AI，它通常能馬上找出原因。

## 產生這個範例的提示詞

````markdown
請參考 common.py 的寫法,用 MCP Python SDK(mcp 2.x 的 MCPServer)建立「股市大盤查詢」MCP Server。
使用者是理財專員。

## 規定
- 使用 common.py 的 query()、audit()、run(),每個工具開頭都要呼叫 audit()
- 所有參數用 %s 參數化查詢;彙總間隔用 Literal["日", "週", "月"] 限定
- market 參數可以是代號(例如 ^TWII)或國家(例如 台灣)
- 每次最多回傳 400 筆
- 在 instructions 說明:只提供歷史資料的整理,不提供投資建議

## 資料表
【貼上 2資料表建立.sql 的內容】

## 工具
1. list_markets():所有市場、資料起訖日期、筆數
2. price_history(market, start_date, end_date, interval):依日/週/月彙總的收盤指數、最高、最低、成交量
3. yearly_summary(market):每年的年初、年底、最高、最低、漲跌幅百分比
4. compare_markets(start_date, end_date):所有市場同期間的漲跌幅比較
````

## 延伸挑戰

1. 新增 `biggest_moves(market, year, limit)`：某一年單日漲跌幅最大的幾天
2. 新增 `moving_average(market, days)`：最近的 N 日移動平均（提示：視窗函式 `AVG() OVER`）
3. 在實戰專案的 notebook 多下載幾個市場（例如日經 `^N225`、道瓊 `^DJI`），再用 `compare_markets` 比較
