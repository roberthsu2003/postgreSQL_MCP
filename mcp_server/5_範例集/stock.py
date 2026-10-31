#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
範例 5:股市大盤指數查詢 MCP Server
使用者:理財專員、投資人,查詢大盤走勢、年度表現、比較不同市場
資料庫:實戰專案「大盤股市」建立的 市場、股市 資料表
       (先執行 tutorial_container/範例/1stock_market 的 notebook 下載資料)
"""

from datetime import date
from typing import Literal

from mcp.server import MCPServer

from common import audit, query, run

mcp = MCPServer(
    "股市大盤查詢",
    instructions="你是股市資料查詢助理。回答時使用繁體中文。只提供歷史資料的整理,不提供投資建議。",
)


@mcp.tool()
def list_markets() -> list[dict]:
    """列出資料庫中有哪些市場(代號、國家),以及資料的起訖日期和筆數"""
    audit("list_markets")
    sql = """
        SELECT m.name AS 代號, m.country AS 國家,
               MIN(s.date) AS 最早日期, MAX(s.date) AS 最新日期, COUNT(s.stock_id) AS 資料筆數
        FROM 市場 m
        LEFT JOIN 股市 s ON m.name = s.name
        GROUP BY m.name, m.country
        ORDER BY m.name
    """
    return query(sql)


@mcp.tool()
def price_history(
    market: str,
    start_date: date,
    end_date: date,
    interval: Literal["日", "週", "月"] = "月",
) -> list[dict]:
    """查詢某個市場一段期間的收盤指數與成交量。market 可以是代號(^TWII)或國家(台灣)。
    期間很長時請用「月」,避免回傳太多資料;最多回傳 400 筆"""
    audit("price_history", market=market, start_date=str(start_date), end_date=str(end_date), interval=interval)
    # interval 用 Literal 限定,再對應到寫好的 SQL 片段,避免 SQL injection
    unit = {"日": "day", "週": "week", "月": "month"}[interval]
    sql = f"""
        SELECT DATE_TRUNC('{unit}', s.date)::date AS 期間,
               ROUND((ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1], 2) AS 收盤指數,
               ROUND(MAX(s.high), 2) AS 最高, ROUND(MIN(s.low), 2) AS 最低,
               SUM(s.volume)::bigint AS 成交量
        FROM 股市 s
        JOIN 市場 m ON s.name = m.name
        WHERE (m.name = %s OR m.country = %s)
          AND s.date BETWEEN %s AND %s
        GROUP BY 期間
        ORDER BY 期間
        LIMIT 400
    """
    return query(sql, (market, market, start_date, end_date))


@mcp.tool()
def yearly_summary(market: str) -> list[dict]:
    """某個市場每一年的年初、年底、最高、最低指數與全年漲跌幅百分比。market 可以是代號或國家"""
    audit("yearly_summary", market=market)
    # 注意:有傳參數的 SQL 裡,% 是參數符號,欄位名稱不能出現 %(例如「漲跌幅(%)」會出錯)
    sql = """
        SELECT EXTRACT(YEAR FROM s.date)::int AS 年度,
               ROUND((ARRAY_AGG(s.adj_close ORDER BY s.date))[1], 2) AS 年初,
               ROUND((ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1], 2) AS 年底,
               ROUND(MAX(s.high), 2) AS 最高, ROUND(MIN(s.low), 2) AS 最低,
               ROUND(((ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1]
                     / (ARRAY_AGG(s.adj_close ORDER BY s.date))[1] - 1) * 100, 2) AS 漲跌幅百分比
        FROM 股市 s
        JOIN 市場 m ON s.name = m.name
        WHERE m.name = %s OR m.country = %s
        GROUP BY 年度
        ORDER BY 年度
    """
    return query(sql, (market, market))


@mcp.tool()
def compare_markets(start_date: date, end_date: date) -> list[dict]:
    """比較所有市場在同一段期間的表現:期初、期末指數與漲跌幅百分比,漲幅大的排前面"""
    audit("compare_markets", start_date=str(start_date), end_date=str(end_date))
    sql = """
        SELECT m.name AS 代號, m.country AS 國家,
               ROUND((ARRAY_AGG(s.adj_close ORDER BY s.date))[1], 2) AS 期初,
               ROUND((ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1], 2) AS 期末,
               ROUND(((ARRAY_AGG(s.adj_close ORDER BY s.date DESC))[1]
                     / (ARRAY_AGG(s.adj_close ORDER BY s.date))[1] - 1) * 100, 2) AS 漲跌幅百分比
        FROM 股市 s
        JOIN 市場 m ON s.name = m.name
        WHERE s.date BETWEEN %s AND %s
        GROUP BY m.name, m.country
        ORDER BY 漲跌幅百分比 DESC
    """
    return query(sql, (start_date, end_date))


if __name__ == "__main__":
    run(mcp)
