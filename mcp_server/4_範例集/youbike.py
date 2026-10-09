#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
範例 4:台北市 YouBike 車位查詢 MCP Server
使用者:一般民眾、通勤族,查詢哪裡有車可借、哪裡有位可還
資料庫:實戰專案「台北市 YouBike」建立的 站點資訊、youbike 資料表
       (先執行 tutorial_container/範例/2taipei_youbike 的 notebook 下載資料)
"""

from mcp.server import MCPServer

from common import audit, query, run

mcp = MCPServer(
    "台北市YouBike查詢",
    instructions="你是台北市 YouBike 查詢助理。回答時使用繁體中文,並告訴使用者資料時間,因為資料不是即時的。",
)

# 每個站點只取「最新一筆」資料
LATEST = """
    SELECT DISTINCT ON (y.編號)
           s.站點名稱, s.行政區, s.站點地址, y.可借, y.可還, y.總車輛, y.日期 AS 資料時間
    FROM youbike y
    JOIN 站點資訊 s ON y.編號 = s.站點編號
    WHERE y.活動 = TRUE
    ORDER BY y.編號, y.日期 DESC
"""


@mcp.tool()
def list_districts() -> list[dict]:
    """列出所有行政區和各區的站點數"""
    audit("list_districts")
    sql = """
        SELECT 行政區, COUNT(*) AS 站點數
        FROM 站點資訊
        GROUP BY 行政區
        ORDER BY 站點數 DESC
    """
    return query(sql)


@mcp.tool()
def find_bikes(district: str, min_available: int = 1) -> list[dict]:
    """找出某個行政區(例如:大安區)可借車輛數大於等於 min_available 的站點,可借數量多的排前面,最多 30 筆"""
    audit("find_bikes", district=district, min_available=min_available)
    sql = f"""
        SELECT * FROM ({LATEST}) latest
        WHERE 行政區 = %s AND 可借 >= %s
        ORDER BY 可借 DESC
        LIMIT 30
    """
    return query(sql, (district, min_available))


@mcp.tool()
def find_parking(district: str, min_empty: int = 1) -> list[dict]:
    """找出某個行政區可以還車的空位數大於等於 min_empty 的站點,空位多的排前面,最多 30 筆"""
    audit("find_parking", district=district, min_empty=min_empty)
    sql = f"""
        SELECT * FROM ({LATEST}) latest
        WHERE 行政區 = %s AND 可還 >= %s
        ORDER BY 可還 DESC
        LIMIT 30
    """
    return query(sql, (district, min_empty))


@mcp.tool()
def search_station(keyword: str) -> list[dict]:
    """用站名或地址的一部分搜尋站點(例如:台大、捷運科技大樓),回傳最新的可借、可還數量"""
    audit("search_station", keyword=keyword)
    # 官方站名用「臺」,使用者常打「台」,所以比對前把「台」統一換成「臺」
    sql = f"""
        SELECT * FROM ({LATEST}) latest
        WHERE REPLACE(站點名稱, '台', '臺') LIKE %s OR REPLACE(站點地址, '台', '臺') LIKE %s
        ORDER BY 站點名稱
        LIMIT 30
    """
    pattern = f"%{keyword.replace('台', '臺')}%"
    return query(sql, (pattern, pattern))


if __name__ == "__main__":
    run(mcp)
