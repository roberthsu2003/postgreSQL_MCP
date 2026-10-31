#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
範例 3:圖書館「櫃台館員助理」MCP Server
使用者:圖書館館員,查詢館藏是否可借、逾期未還、會員借閱紀錄、熱門書籍
資料庫:繁體中文範例資料庫 library.sql
"""

from typing import Literal

from mcp.server import MCPServer

from common import audit, query, run

Category = Literal["全部", "文學小說", "歷史", "科普", "商業理財", "電腦資訊", "兒童繪本", "旅遊", "心理勵志"]

mcp = MCPServer(
    "圖書館館員助理",
    instructions="你是社區圖書館的櫃台館員助理。回答時使用繁體中文。歸還日期是空值代表還沒有還書。",
)


@mcp.tool()
def search_books(keyword: str) -> list[dict]:
    """用書名、作者或出版社的一部分搜尋館藏,回傳書名、作者、出版社、分類、館藏冊數、目前可借冊數"""
    audit("search_books", keyword=keyword)
    sql = """
        SELECT b.book_id AS 書籍編號, b.title AS 書名, a.name AS 作者, p.name AS 出版社,
               b.category AS 分類, b.copies AS 館藏冊數,
               GREATEST(b.copies - COUNT(l.loan_id), 0) AS 可借冊數
        FROM books b
        LEFT JOIN authors a    ON b.author_id = a.author_id
        LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
        LEFT JOIN loans l      ON b.book_id = l.book_id AND l.return_date IS NULL
        WHERE b.title LIKE %s OR a.name LIKE %s OR p.name LIKE %s
        GROUP BY b.book_id, a.name, p.name
        ORDER BY b.title
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern, pattern))


@mcp.tool()
def overdue_loans() -> list[dict]:
    """列出今天為止已經超過到期日、但還沒有歸還的借閱,依逾期天數由多到少排序"""
    audit("overdue_loans")
    sql = """
        SELECT m.member_id AS 會員編號, m.name AS 會員姓名, b.title AS 書名,
               l.loan_date AS 借出日, l.due_date AS 到期日,
               CURRENT_DATE - l.due_date AS 逾期天數
        FROM loans l
        JOIN members m ON l.member_id = m.member_id
        JOIN books b   ON l.book_id = b.book_id
        WHERE l.return_date IS NULL AND l.due_date < CURRENT_DATE
        ORDER BY 逾期天數 DESC
    """
    return query(sql)


@mcp.tool()
def member_loans(member_id: int, only_unreturned: bool = False) -> list[dict]:
    """查詢某位會員的借閱紀錄(最近 30 筆),only_unreturned 為 true 時只列出還沒歸還的書"""
    audit("member_loans", member_id=member_id, only_unreturned=only_unreturned)
    sql = """
        SELECT m.name AS 會員姓名, m.member_type AS 會員類型, b.title AS 書名,
               l.loan_date AS 借出日, l.due_date AS 到期日, l.return_date AS 歸還日
        FROM loans l
        JOIN members m ON l.member_id = m.member_id
        JOIN books b   ON l.book_id = b.book_id
        WHERE l.member_id = %s
          AND (%s = FALSE OR l.return_date IS NULL)
        ORDER BY l.loan_date DESC
        LIMIT 30
    """
    return query(sql, (member_id, only_unreturned))


@mcp.tool()
def popular_books(year: int = 2025, category: Category = "全部", limit: int = 10) -> list[dict]:
    """某一年借閱次數最多的書(最多 50 筆),可以指定分類;同樣次數會是同一個名次"""
    audit("popular_books", year=year, category=category, limit=limit)
    sql = """
        SELECT RANK() OVER (ORDER BY COUNT(*) DESC) AS 名次,
               b.title AS 書名, b.category AS 分類, COUNT(*) AS 借閱次數
        FROM loans l
        JOIN books b ON l.book_id = b.book_id
        WHERE EXTRACT(YEAR FROM l.loan_date) = %s
          AND (%s = '全部' OR b.category = %s)
        GROUP BY b.book_id, b.title, b.category
        ORDER BY 借閱次數 DESC, b.title
        LIMIT %s
    """
    return query(sql, (year, category, category, min(limit, 50)))


if __name__ == "__main__":
    run(mcp)
