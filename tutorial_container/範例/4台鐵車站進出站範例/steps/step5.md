# 步驟 5：統計分析功能

## 學習重點
- 進階 SQL 查詢
- 資料分組與聚合
- 多資料表 JOIN 與聚合
- 資料分析與解釋

## 程式碼說明

在這個步驟中，我們將實現統計分析功能，使用 SQL 的分組和聚合函數來分析台鐵車站資料。

```python
def show_statistics(conn):
    """顯示統計分析資料"""
    try:
        cursor = conn.cursor()

        # 1. 各縣市車站數量統計
        print("\n=== 各縣市車站數量統計 ===")
        cursor.execute("""
            SELECT
                SUBSTRING("stationAddrTw" FROM '^[^市縣]*[市縣]') as city,
                COUNT(*) as count
            FROM "台鐵車站資訊"
            GROUP BY SUBSTRING("stationAddrTw" FROM '^[^市縣]*[市縣]')
            ORDER BY count DESC
        """)

        city_stats = cursor.fetchall()
        for city, count in city_stats:
            print(f"{city if city else '未知':<10}: {count} 個車站")

        # 2. 有無自行車服務的車站統計
        print("\n=== 自行車服務統計 ===")
        cursor.execute("""
            SELECT
                "haveBike",
                COUNT(*) as count
            FROM "台鐵車站資訊"
            GROUP BY "haveBike"
        """)

        bike_stats = cursor.fetchall()
        for have_bike, count in bike_stats:
            status = "提供" if have_bike == 'Y' else "不提供"
            print(f"{status}自行車服務的車站: {count} 個")

        # 3. 進出站人數最多的前 5 個車站
        print("\n=== 進出站人數最多的前 5 個車站 ===")
        cursor.execute("""
            SELECT
                s."stationName",
                SUM(p."進站人數") as total_in,
                SUM(p."出站人數") as total_out,
                SUM(p."進站人數" + p."出站人數") as total
            FROM "每日各站進出站人數" p
            JOIN "台鐵車站資訊" s ON p."車站代碼" = s."stationCode"
            GROUP BY s."stationName"
            ORDER BY total DESC
            LIMIT 5
        """)

        top_stations = cursor.fetchall()
        print(f"{'車站名稱':<10}{'進站總人數':<15}{'出站總人數':<15}{'總人數':<15}")
        print("-" * 55)
        for station, in_count, out_count, total in top_stations:
            print(f"{station:<10}{in_count:<15}{out_count:<15}{total:<15}")

        cursor.close()
    except Exception as e:
        conn.rollback()
        print(f"統計分析錯誤: {e}")
```

同時，我們需要更新 `main()` 函數中的相應部分：

```python
def main():
    """主程式"""
    conn = connect_to_database()
    if not conn:
        print("無法連接到資料庫，程式結束")
        sys.exit(1)

    while True:
        display_menu()
        choice = input("請選擇功能 (0-4): ")

        if choice == '0':
            print("感謝使用，再見！")
            break
        elif choice == '1':
            list_all_stations(conn)
        elif choice == '2':
            area = input("請輸入地區名稱 (例如: 基隆、臺北): ")
            list_stations_by_area(conn, area)
        elif choice == '3':
            station = input("請輸入車站名稱: ")
            list_passenger_data(conn, station)
        elif choice == '4':
            show_statistics(conn)
        else:
            print("無效的選擇，請重新輸入")

    conn.close()
```

## 程式碼解析

1. **複雜 SQL 查詢**：
   - 使用 `SUBSTRING` 函數從地址中提取縣市名稱
   - 使用 `GROUP BY` 子句進行資料分組
   - 使用 `COUNT`, `SUM` 等聚合函數
   - 使用 `ORDER BY` 和 `LIMIT` 控制結果排序和數量

2. **多個統計分析**：
   - 各縣市車站數量統計
   - 有無自行車服務的車站統計
   - 進出站人數最多的前 5 個車站

3. **JOIN 操作**：
   - 使用 `JOIN` 連接「台鐵車站資訊」和「每日各站進出站人數」表
   - 根據車站代碼建立關聯

4. **錯誤處理**：
   - 發生錯誤時執行 `conn.rollback()`，讓連線恢復正常，回到選單後還能繼續使用其它功能

## 執行結果

統計分析的輸出示例：

```
=== 各縣市車站數量統計 ===
花蓮縣       : 25 個車站
新北市       : 24 個車站
臺中市       : 23 個車站
宜蘭縣       : 22 個車站
屏東縣       : 20 個車站
高雄市       : 18 個車站
臺南市       : 17 個車站
苗栗縣       : 16 個車站
臺東縣       : 14 個車站
新竹縣       : 14 個車站
彰化縣       : 9 個車站
基隆市       : 7 個車站
桃園市       : 7 個車站
新竹市       : 6 個車站
臺北市       : 5 個車站
雲林縣       : 5 個車站
南投縣       : 5 個車站
嘉義縣       : 4 個車站
嘉義市       : 2 個車站

=== 自行車服務統計 ===
提供自行車服務的車站: 131 個
不提供自行車服務的車站: 112 個

=== 進出站人數最多的前 5 個車站 ===
車站名稱      進站總人數          出站總人數          總人數            
-------------------------------------------------------
臺北        88421749       87261561       175683310      
桃園        40453667       41594793       82048460       
臺南        37454585       38168096       75622681       
中壢        37395534       37896114       75291648       
臺中        36872010       36827889       73699899       
```

> 以上是使用[台鐵車站進出資訊_全部整合](../../../../範例資料庫/其它範例csv/台鐵車站進出資訊_全部整合/)（2020～2023 年）的實際執行結果。

## 練習

1. 擴展統計分析，加入更多有意義的統計指標，如每日平均進出站人數。
2. 實現一個功能，分析特定時間段內進出站人數的變化趨勢。
3. 加入地理分析，例如計算各縣市的平均每站進出站人數。
4. 實現一個功能，找出進站人數與出站人數差異最大的車站。

## 延伸閱讀

- [PostgreSQL 聚合函數](https://www.postgresql.org/docs/current/functions-aggregate.html)
- [SQL GROUP BY 子句](https://www.postgresql.org/docs/current/queries-table-expressions.html#QUERIES-GROUP)
- [SQL 子查詢](https://www.postgresql.org/docs/current/queries-subqueries.html)
- [資料分析基礎](https://pandas.pydata.org/docs/getting_started/intro_tutorials/index.html)