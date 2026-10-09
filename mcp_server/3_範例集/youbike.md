# 範例 4：🚲 台北市 YouBike 查詢

程式：[youbike.py](./youbike.py)　資料來源：[實戰專案：台北市 YouBike](../../tutorial_container/範例/2taipei_youbike/)　[← 回範例集](./README.md)

## 情境

把實戰專案下載的 YouBike 資料，從 Streamlit 網頁「升級」成 AI 助理：不用點選單，直接問「大安區哪裡有車？」

## 事前準備

先執行實戰專案的 notebook，把台北市 YouBike 開放資料存進 `站點資訊`、`youbike` 兩張資料表。
`DATABASE_URI` 要指向這兩張資料表所在的資料庫。

```mermaid
flowchart LR
    API["台北市開放資料<br/>YouBike 即時 JSON"] -->|"實戰專案的 notebook<br/>定時下載"| DB[("站點資訊<br/>youbike")]
    DB --> MCP["YouBike 查詢<br/>MCP Server"] --> AI["Claude"]
```

> ⚠️ 資料庫裡是**最後一次下載**的資料，不是即時資料。所以每個工具都會回傳「資料時間」，`instructions` 也要求 AI 告訴使用者資料時間。

## 工具

| 工具 | 用途 | 參數 |
|---|---|---|
| `list_districts` | 各行政區的站點數 | — |
| `find_bikes` | 某行政區有車可借的站點 | 行政區、最少可借數量 |
| `find_parking` | 某行政區有空位可還的站點 | 行政區、最少空位 |
| `search_station` | 用站名或地址找站點 | 關鍵字 |

## 可以這樣問

- 「我在大安區，哪幾站至少有 10 台車可以借？」
- 「信義區哪裡比較好還車？」
- 「台大附近的站現在狀況如何？」
- 「哪個行政區的站點最多？」

## 學到的技巧

### 1. 每個站點只取「最新一筆」：`DISTINCT ON`

`youbike` 資料表每次下載都會新增一筆，同一個站有很多筆。用 `DISTINCT ON` 只留每站最新的那一筆：

```sql
SELECT DISTINCT ON (y.編號) s.站點名稱, y.可借, y.可還, y.日期 AS 資料時間
FROM youbike y JOIN 站點資訊 s ON y.編號 = s.站點編號
ORDER BY y.編號, y.日期 DESC          -- 每個編號依日期由新到舊,DISTINCT ON 取第一筆
```

### 2. 「台」和「臺」的搜尋問題

官方站名寫「**臺**大」，使用者常打「**台**大」，直接 `LIKE '%台大%'` 會找不到任何站。比對前統一換成「臺」：

```python
sql = "… WHERE REPLACE(站點名稱, '台', '臺') LIKE %s"
pattern = f"%{keyword.replace('台', '臺')}%"
```

> 💡 這種問題 AI 寫程式時不一定會想到，是**測試時才會發現**的。這就是為什麼一定要用 Inspector 實際測試。

## 產生這個範例的提示詞

````markdown
請參考 common.py 的寫法,用 MCP Python SDK(mcp 2.x 的 MCPServer)建立「台北市 YouBike 查詢」MCP Server。
使用者是一般民眾。

## 規定
- 使用 common.py 的 query()、audit()、run(),每個工具開頭都要呼叫 audit()
- 所有參數用 %s 參數化查詢,列表最多回傳 30 筆
- youbike 資料表同一個站點有很多筆(每次下載一筆),每個站點只取最新一筆,並回傳「資料時間」
- 只顯示「活動」為 true 的站點
- 搜尋站名時,「台」和「臺」要視為相同
- 在 instructions 要求 AI 告訴使用者資料時間,因為資料不是即時的

## 資料表
【貼上 lesson1_建立資料表.sql 的內容】

## 工具
1. list_districts():各行政區的站點數
2. find_bikes(district, min_available):某行政區可借車輛 >= min_available 的站點
3. find_parking(district, min_empty):某行政區可還空位 >= min_empty 的站點
4. search_station(keyword):用站名或地址搜尋
````

## 延伸挑戰

1. 新增 `station_trend(station_name)`：某一站最近幾次下載的可借數量變化
2. 新增 `nearby_stations(lat, lng)`：用經緯度找最近的 5 個站（提示：用距離公式排序）
3. 思考：如果要讓 MCP Server 查到**真正即時**的資料，可以怎麼做？（直接呼叫開放資料 API，而不是查資料庫）
