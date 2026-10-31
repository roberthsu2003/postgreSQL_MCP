#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
圖書館「借還書櫃台」MCP Server(會寫入資料的版本)

使用者:圖書館館員,用自然語言幫讀者登記借書、還書
資料庫:繁體中文範例資料庫 library.sql

和唯讀版本最大的不同:
- 只開放「借書」「還書」兩種寫入,沒有刪除、沒有任意 SQL
- 所有檢查(有沒有書、有沒有逾期)都寫在程式裡,不交給 AI 判斷
- 每次寫入都在交易(transaction)中完成,失敗就全部取消
- 每次寫入都留下稽核紀錄
"""

import os
import sys
from datetime import date, datetime, timedelta

import psycopg2
import psycopg2.extras
from mcp.server import MCPServer
from mcp.types import ToolAnnotations

DATABASE_URI = os.environ.get(
    "DATABASE_URI",
    "postgresql://postgres:yourpassword@localhost:5432/practice",
)
USER = os.environ.get("MCP_USER", "本機館員")

LOAN_DAYS = {"一般": 14, "學生": 21, "銀髮": 28}  # 各會員類型的借期
MAX_LOANS = 5                                       # 每人最多同時借 5 本

mcp = MCPServer(
    "圖書館借還書櫃台",
    instructions=(
        "你是圖書館櫃台館員的助理。回答時使用繁體中文。"
        "登記借書或還書之前,先用查詢工具確認會員和書籍,並把要登記的內容告訴館員,館員確認後才呼叫寫入工具。"
    ),
)

# 工具標註:讓 Claude Desktop 知道哪些工具只是查詢、哪些會修改資料
READ_ONLY = ToolAnnotations(read_only_hint=True)
WRITE = ToolAnnotations(read_only_hint=False, destructive_hint=False, idempotent_hint=False)


def audit(action, **detail):
    """稽核紀錄:印到 stderr(stdio 模式下 stdout 是和 Claude Desktop 溝通用的)"""
    print(f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {USER} {action} {detail}", file=sys.stderr)


def to_json(rows):
    return [{k: (v.isoformat() if hasattr(v, "isoformat") else v) for k, v in r.items()} for r in rows]


def query(sql, params=None):
    """唯讀查詢"""
    conn = psycopg2.connect(DATABASE_URI)
    try:
        conn.set_session(readonly=True)
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            return to_json(cur.fetchall())
    finally:
        conn.close()


class Refused(Exception):
    """檢查沒有通過,拒絕寫入(訊息會回傳給 AI)"""


# ---------------------------------------------------------------------
# 查詢工具(唯讀)
# ---------------------------------------------------------------------

@mcp.tool(annotations=READ_ONLY)
def find_member(keyword: str) -> list[dict]:
    """用會員姓名或會員編號查詢會員,回傳會員類型、目前借了幾本、有幾本逾期"""
    sql = """
        SELECT m.member_id AS 會員編號, m.name AS 姓名, m.member_type AS 會員類型,
               COUNT(l.loan_id) AS 借閱中,
               COUNT(l.loan_id) FILTER (WHERE l.due_date < CURRENT_DATE) AS 逾期未還
        FROM members m
        LEFT JOIN loans l ON m.member_id = l.member_id AND l.return_date IS NULL
        WHERE m.name LIKE %s OR m.member_id::text = %s
        GROUP BY m.member_id
        ORDER BY m.member_id
        LIMIT 10
    """
    return query(sql, (f"%{keyword}%", keyword))


@mcp.tool(annotations=READ_ONLY)
def find_book(keyword: str) -> list[dict]:
    """用書名的一部分查詢書籍,回傳書籍編號、館藏冊數、目前可借冊數"""
    sql = """
        SELECT b.book_id AS 書籍編號, b.title AS 書名, b.copies AS 館藏冊數,
               GREATEST(b.copies - COUNT(l.loan_id), 0) AS 可借冊數
        FROM books b
        LEFT JOIN loans l ON b.book_id = l.book_id AND l.return_date IS NULL
        WHERE b.title LIKE %s
        GROUP BY b.book_id
        ORDER BY b.title
        LIMIT 10
    """
    return query(sql, (f"%{keyword}%",))


@mcp.tool(annotations=READ_ONLY)
def member_loans(member_id: int) -> list[dict]:
    """查詢某位會員目前還沒歸還的書,包含借閱編號和到期日"""
    sql = """
        SELECT l.loan_id AS 借閱編號, b.title AS 書名, l.loan_date AS 借出日, l.due_date AS 到期日,
               GREATEST(CURRENT_DATE - l.due_date, 0) AS 逾期天數
        FROM loans l
        JOIN books b ON l.book_id = b.book_id
        WHERE l.member_id = %s AND l.return_date IS NULL
        ORDER BY l.due_date
    """
    return query(sql, (member_id,))


# ---------------------------------------------------------------------
# 寫入工具
# ---------------------------------------------------------------------

@mcp.tool(title="登記借書", annotations=WRITE)
def borrow_book(member_id: int, book_id: int) -> dict:
    """幫會員登記借一本書。會檢查:會員存在、沒有逾期未還、借閱中未超過 5 本、這本書還有可借的冊數。
    呼叫前請先用 find_member、find_book 確認編號,並請館員確認"""
    conn = psycopg2.connect(DATABASE_URI)
    try:
        with conn:  # 交易:全部成功才 commit,任何錯誤都 rollback
            with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
                # 1. 會員是否存在
                cur.execute("SELECT name, member_type FROM members WHERE member_id = %s", (member_id,))
                member = cur.fetchone()
                if not member:
                    raise Refused(f"找不到會員編號 {member_id}")

                # 2. 鎖住這本書的資料列,避免兩個人同時借走最後一本
                cur.execute("SELECT title, copies FROM books WHERE book_id = %s FOR UPDATE", (book_id,))
                book = cur.fetchone()
                if not book:
                    raise Refused(f"找不到書籍編號 {book_id}")

                # 3. 會員目前的借閱狀況
                cur.execute("""
                    SELECT COUNT(*) AS 借閱中,
                           COUNT(*) FILTER (WHERE due_date < CURRENT_DATE) AS 逾期
                    FROM loans WHERE member_id = %s AND return_date IS NULL
                """, (member_id,))
                status = cur.fetchone()
                if status["逾期"] > 0:
                    raise Refused(f"{member['name']} 有 {status['逾期']} 本書逾期未還,請先還書")
                if status["借閱中"] >= MAX_LOANS:
                    raise Refused(f"{member['name']} 已經借了 {status['借閱中']} 本,最多 {MAX_LOANS} 本")

                # 4. 這本書還有沒有可借的冊數
                cur.execute("SELECT COUNT(*) AS 借出 FROM loans WHERE book_id = %s AND return_date IS NULL", (book_id,))
                if cur.fetchone()["借出"] >= book["copies"]:
                    raise Refused(f"《{book['title']}》目前全部借出")

                # 5. 通過所有檢查,新增借閱紀錄(參數化查詢)
                due = date.today() + timedelta(days=LOAN_DAYS[member["member_type"]])
                cur.execute("""
                    INSERT INTO loans (book_id, member_id, loan_date, due_date)
                    VALUES (%s, %s, CURRENT_DATE, %s)
                    RETURNING loan_id
                """, (book_id, member_id, due))
                loan_id = cur.fetchone()["loan_id"]
    except Refused as e:
        audit("借書被拒絕", member_id=member_id, book_id=book_id, reason=str(e))
        return {"結果": "失敗", "原因": str(e)}
    finally:
        conn.close()

    audit("登記借書", loan_id=loan_id, member_id=member_id, book_id=book_id)
    return {"結果": "成功", "借閱編號": loan_id, "會員": member["name"],
            "書名": book["title"], "到期日": due.isoformat()}


@mcp.tool(title="登記還書", annotations=WRITE)
def return_book(loan_id: int) -> dict:
    """登記歸還一筆借閱。請先用 member_loans 查詢借閱編號。逾期歸還時會回傳逾期天數"""
    conn = psycopg2.connect(DATABASE_URI)
    try:
        with conn:
            with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
                # 只更新「還沒歸還」的那一筆,WHERE 條件同時檢查 loan_id 和 return_date
                cur.execute("""
                    UPDATE loans SET return_date = CURRENT_DATE
                    WHERE loan_id = %s AND return_date IS NULL
                    RETURNING member_id, book_id, due_date
                """, (loan_id,))
                row = cur.fetchone()
                if not row:
                    raise Refused(f"借閱編號 {loan_id} 不存在,或已經歸還")
                # 確認真的只改了一筆
                if cur.rowcount != 1:
                    raise Refused("預期只修改 1 筆資料,已取消")
    except Refused as e:
        audit("還書被拒絕", loan_id=loan_id, reason=str(e))
        return {"結果": "失敗", "原因": str(e)}
    finally:
        conn.close()

    overdue = max((date.today() - row["due_date"]).days, 0)
    audit("登記還書", loan_id=loan_id, overdue_days=overdue)
    return {"結果": "成功", "借閱編號": loan_id, "逾期天數": overdue}


if __name__ == "__main__":
    mcp.run()
