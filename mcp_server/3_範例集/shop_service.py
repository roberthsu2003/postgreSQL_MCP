#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
範例 1:網路商店「客服助理」MCP Server
使用者:客服人員,接到會員來電時查詢會員、訂單與配送狀況
資料庫:繁體中文範例資料庫 shop.sql
"""

from typing import Literal

from mcp.server import MCPServer

from common import audit, query, run

mcp = MCPServer(
    "網路商店客服助理",
    instructions="你是網路商店的客服助理。回答時使用繁體中文,金額單位是新台幣元。不要透露會員的完整 email。",
)


@mcp.tool()
def search_customers(keyword: str) -> list[dict]:
    """用姓名或 email 的一部分搜尋會員,回傳會員編號、姓名、縣市、加入日期、遮罩後的 email。
    查詢會員訂單前,先用這個工具取得會員編號"""
    audit("search_customers", keyword=keyword)
    # 個資最小化:不回傳生日,email 只顯示前 3 個字元
    sql = """
        SELECT customer_id AS 會員編號,
               name        AS 姓名,
               city        AS 縣市,
               joined_on   AS 加入日期,
               LEFT(email, 3) || '***@' || SPLIT_PART(email, '@', 2) AS email
        FROM customers
        WHERE name LIKE %s OR email LIKE %s
        ORDER BY customer_id
        LIMIT 20
    """
    pattern = f"%{keyword}%"
    return query(sql, (pattern, pattern))


@mcp.tool()
def customer_orders(customer_id: int, limit: int = 10) -> list[dict]:
    """查詢某位會員最近的訂單(最多 50 筆),包含訂單編號、日期、狀態、付款方式、商品金額、運費"""
    audit("customer_orders", customer_id=customer_id, limit=limit)
    sql = """
        SELECT o.order_id AS 訂單編號,
               o.order_date AS 訂購日期,
               o.status AS 狀態,
               o.payment_method AS 付款方式,
               SUM(oi.quantity * oi.unit_price) AS 商品金額,
               o.shipping_fee AS 運費
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = %s
        GROUP BY o.order_id
        ORDER BY o.order_date DESC
        LIMIT %s
    """
    return query(sql, (customer_id, min(limit, 50)))


@mcp.tool()
def order_detail(order_id: int) -> list[dict]:
    """查詢一筆訂單買了哪些商品,包含商品名稱、數量、單價、小計"""
    audit("order_detail", order_id=order_id)
    sql = """
        SELECT p.name AS 商品名稱,
               oi.quantity AS 數量,
               oi.unit_price AS 單價,
               oi.quantity * oi.unit_price AS 小計
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        WHERE oi.order_id = %s
        ORDER BY p.name
    """
    return query(sql, (order_id,))


@mcp.tool()
def orders_by_status(status: Literal["已完成", "已取消", "配送中"] = "配送中", limit: int = 20) -> list[dict]:
    """依照狀態列出最近的訂單(最多 50 筆),例如列出所有「配送中」的訂單"""
    audit("orders_by_status", status=status, limit=limit)
    sql = """
        SELECT o.order_id AS 訂單編號, o.order_date AS 訂購日期,
               c.name AS 會員姓名, c.city AS 縣市, o.payment_method AS 付款方式
        FROM orders o
        JOIN customers c ON o.customer_id = c.customer_id
        WHERE o.status = %s
        ORDER BY o.order_date DESC
        LIMIT %s
    """
    return query(sql, (status, min(limit, 50)))


if __name__ == "__main__":
    run(mcp)
