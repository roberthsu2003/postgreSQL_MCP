#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
範例 2:學校「教務處助理」MCP Server
使用者:教務處職員、導師,查詢成績單、修課名單、課程統計、需要輔導的學生
資料庫:繁體中文範例資料庫 school.sql
"""

from typing import Literal

from mcp.server import MCPServer

from common import audit, query, run

Semester = Literal["113-1", "113-2", "114-1"]

mcp = MCPServer(
    "教務處助理",
    instructions="你是大學教務處的助理。回答時使用繁體中文。60 分及格;114-1 學期尚未結束,成績是空值代表還沒有給分。",
)


@mcp.tool()
def search_students(keyword: str) -> list[dict]:
    """用學號或姓名的一部分搜尋學生,回傳學號、姓名、學系、入學年度"""
    audit("search_students", keyword=keyword)
    sql = """
        SELECT s.student_id AS 學號, s.name AS 姓名, d.name AS 學系, s.enroll_year AS 入學年度
        FROM students s
        JOIN departments d ON s.dept_id = d.dept_id
        WHERE s.student_id ILIKE %s OR s.name LIKE %s
        ORDER BY s.student_id
        LIMIT 20
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))


@mcp.tool()
def student_transcript(student_id: str) -> list[dict]:
    """查詢某位學生的成績單:每門課的學期、課程名稱、學分、成績、是否及格。學號格式例如 S113001"""
    audit("student_transcript", student_id=student_id)
    sql = """
        SELECT c.semester AS 學期, c.course_id AS 課號, c.name AS 課程名稱,
               c.credits AS 學分, e.score AS 成績,
               CASE
                   WHEN e.score IS NULL THEN '尚未給分'
                   WHEN e.score >= 60 THEN '及格'
                   ELSE '不及格'
               END AS 結果
        FROM enrollments e
        JOIN courses c ON e.course_id = c.course_id
        WHERE e.student_id = %s
        ORDER BY c.semester, c.course_id
    """
    return query(sql, (student_id.upper(),))


@mcp.tool()
def course_stats(semester: Semester) -> list[dict]:
    """某學期每門課的修課人數、平均成績、最高分、最低分、不及格人數"""
    audit("course_stats", semester=semester)
    sql = """
        SELECT c.course_id AS 課號, c.name AS 課程名稱, t.name AS 授課老師,
               COUNT(e.student_id) AS 修課人數,
               ROUND(AVG(e.score), 1) AS 平均成績,
               MAX(e.score) AS 最高分,
               MIN(e.score) AS 最低分,
               COUNT(*) FILTER (WHERE e.score < 60) AS 不及格人數
        FROM courses c
        JOIN teachers t ON c.teacher_id = t.teacher_id
        LEFT JOIN enrollments e ON c.course_id = e.course_id
        WHERE c.semester = %s
        GROUP BY c.course_id, c.name, t.name
        ORDER BY c.course_id
    """
    return query(sql, (semester,))


@mcp.tool()
def students_need_help(semester: Semester, min_failed: int = 2) -> list[dict]:
    """找出某學期不及格科目數大於等於 min_failed 的學生(需要輔導的學生),回傳學號、姓名、學系、不及格科目"""
    audit("students_need_help", semester=semester, min_failed=min_failed)
    sql = """
        SELECT s.student_id AS 學號, s.name AS 姓名, d.name AS 學系,
               COUNT(*) AS 不及格科目數,
               STRING_AGG(c.name || '(' || e.score || ')', '、') AS 不及格科目
        FROM enrollments e
        JOIN students s    ON e.student_id = s.student_id
        JOIN departments d ON s.dept_id = d.dept_id
        JOIN courses c     ON e.course_id = c.course_id
        WHERE c.semester = %s AND e.score < 60
        GROUP BY s.student_id, s.name, d.name
        HAVING COUNT(*) >= %s
        ORDER BY 不及格科目數 DESC, s.student_id
    """
    return query(sql, (semester, min_failed))


if __name__ == "__main__":
    run(mcp)
