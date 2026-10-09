#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
台鐵進出站查詢 MCP Server
提供 Claude Desktop 查詢台鐵車站資訊和每日進出站人數的工具
"""

import os
from datetime import date
from typing import Literal

import psycopg2
import psycopg2.extras
from mcp.server import MCPServer

# 資料庫連線設定(從環境變數讀取,沒有設定時使用上課預設值)
DATABASE_URI = os.environ.get(
    "DATABASE_URI",
    "postgresql://postgres:raspberry@localhost:5432/postgres",
)

# 建立 MCP Server,名稱會顯示在 Claude Desktop 中
mcp = MCPServer("台鐵進出站查詢")


def query(sql, params=None):
    """執行唯讀查詢,回傳 list[dict]"""
    with psycopg2.connect(DATABASE_URI) as conn:
        # 設定為唯讀,即使 SQL 寫錯也不會修改資料
        conn.set_session(readonly=True)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
    conn.close()
    # 日期轉成字串,方便轉成 JSON 回傳給 AI
    return [
        {key: str(value) if hasattr(value, "isoformat") else value for key, value in row.items()}
        for row in rows
    ]


@mcp.tool()
def search_stations(keyword: str) -> list[dict]:
    """用關鍵字搜尋台鐵車站(車站名稱或地址),回傳車站代碼、名稱、地址、電話、是否有 YouBike"""
    sql = """
        SELECT "stationCode" AS 車站代碼,
               "stationName" AS 車站名稱,
               "stationAddrTw" AS 地址,
               "stationTel" AS 電話,
               "haveBike" AS 有youbike
        FROM 台鐵車站資訊
        WHERE "stationName" LIKE %s OR "stationAddrTw" LIKE %s
        ORDER BY "stationCode"
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))


@mcp.tool()
def get_station_traffic(station_name: str, start_date: date, end_date: date) -> list[dict]:
    """查詢某個車站在一段期間內每日的進站和出站人數。日期格式為 YYYY-MM-DD"""
    sql = """
        SELECT p.日期, s."stationName" AS 車站名稱, p.進站人數, p.出站人數
        FROM 每日各站進出站人數 p
        JOIN 台鐵車站資訊 s ON p.車站代碼 = s."stationCode"
        WHERE s."stationName" = %s
          AND p.日期 BETWEEN %s AND %s
        ORDER BY p.日期
    """
    return query(sql, (station_name, start_date, end_date))


@mcp.tool()
def top_stations(
    year: int, limit: int = 10, order_by: Literal["進站人數", "出站人數"] = "進站人數"
) -> list[dict]:
    """查詢某一年總人數最多的車站排行,可以依進站人數或出站人數排序"""
    # 欄位名稱不能用 %s 傳遞,所以用 Literal 限定只能是這兩個值,避免 SQL injection
    sql = f"""
        SELECT s."stationName" AS 車站名稱,
               SUM(p.進站人數) AS 進站人數,
               SUM(p.出站人數) AS 出站人數
        FROM 每日各站進出站人數 p
        JOIN 台鐵車站資訊 s ON p.車站代碼 = s."stationCode"
        WHERE EXTRACT(YEAR FROM p.日期) = %s
        GROUP BY s."stationName"
        ORDER BY {order_by} DESC
        LIMIT %s
    """
    return query(sql, (year, limit))


if __name__ == "__main__":
    # 預設使用 stdio 傳輸,讓 Claude Desktop 啟動並溝通
    mcp.run()
