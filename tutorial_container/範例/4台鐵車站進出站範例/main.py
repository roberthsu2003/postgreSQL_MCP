#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
台鐵資料查詢系統 - 主程式
這是一個簡單的命令列介面程式，用於查詢台鐵車站資訊和進出站人數
"""

import os
import sys

import psycopg2

# 資料庫連線設定(從環境變數讀取,沒有設定時使用預設值)
# 在 Dev Container 內連到電腦上的 PostgreSQL 時,DB_HOST 要設為 host.docker.internal
DB_CONFIG = {
    "dbname": os.environ.get("DB_NAME", "postgres"),
    "user": os.environ.get("DB_USER", "postgres"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "host": os.environ.get("DB_HOST", "localhost"),
    "port": os.environ.get("DB_PORT", "5432"),
}

def connect_to_database():
    """連接到 PostgreSQL 資料庫"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"資料庫連線錯誤: {e}")
        return None

def display_menu():
    """顯示主選單"""
    print("\n===== 台鐵資料查詢系統 =====")
    print("1. 查詢所有車站資訊")
    print("2. 查詢特定地區的車站")
    print("3. 查詢車站進出站人數")
    print("4. 統計分析")
    print("0. 離開系統")
    print("==========================")

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

def list_all_stations(conn):
    """列出所有車站資訊"""
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT "stationCode", "stationName", "stationAddrTw" FROM "台鐵車站資訊" ORDER BY "stationCode"')
        stations = cursor.fetchall()

        print("\n=== 所有車站列表 ===")
        print(f"{'車站代碼':<10}{'車站名稱':<15}{'地址':<30}")
        print("-" * 55)

        for station in stations:
            print(f"{station[0]:<10}{station[1]:<15}{station[2]:<30}")

        print(f"\n共有 {len(stations)} 個車站")
        cursor.close()
    except Exception as e:
        conn.rollback()  # 發生錯誤後要 rollback,這個連線才能繼續查詢
        print(f"查詢錯誤: {e}")

def list_stations_by_area(conn, area):
    """列出特定地區的車站"""
    # 地址中使用「臺」(例如 臺北市),使用者輸入「台」時也要找得到
    area = area.replace("台", "臺")
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT "stationCode", "stationName", "stationAddrTw" FROM "台鐵車站資訊" WHERE "stationAddrTw" LIKE %s ORDER BY "stationCode"', (f'%{area}%',))
        stations = cursor.fetchall()

        print(f"\n=== {area}地區車站列表 ===")
        print(f"{'車站代碼':<10}{'車站名稱':<15}{'地址':<30}")
        print("-" * 55)

        for station in stations:
            print(f"{station[0]:<10}{station[1]:<15}{station[2]:<30}")

        print(f"\n共有 {len(stations)} 個車站")
        cursor.close()
    except Exception as e:
        conn.rollback()
        print(f"查詢錯誤: {e}")

def list_passenger_data(conn, station_name):
    """列出特定車站的進出站人數"""
    station_name = station_name.replace("台", "臺")  # 車站名稱使用「臺」,例如 臺北
    try:
        cursor = conn.cursor()

        # 先查詢車站代碼
        cursor.execute('SELECT "stationCode", "stationName" FROM "台鐵車站資訊" WHERE "stationName" = %s', (station_name,))
        station = cursor.fetchone()

        if not station:
            print(f"找不到名為 {station_name} 的車站")
            return

        station_code = station[0]

        # 查詢進出站人數資料(明確寫出欄位,不要用 SELECT *,欄位順序才不會出錯)
        cursor.execute('SELECT "日期", "進站人數", "出站人數" FROM "每日各站進出站人數" WHERE "車站代碼" = %s ORDER BY "日期" DESC LIMIT 10', (station_code,))
        data = cursor.fetchall()

        if not data:
            print(f"{station_name} 車站沒有進出站人數資料")
            return

        print(f"\n=== {station_name} 車站進出站人數 (最近10筆) ===")
        print(f"{'日期':<15}{'進站人數':<10}{'出站人數':<10}")
        print("-" * 35)

        for row in data:
            # row[0] 是 date 型別,要先轉成字串才能用 :<15 對齊
            print(f"{str(row[0]):<15}{row[1]:<10}{row[2]:<10}")

        cursor.close()
    except Exception as e:
        conn.rollback()
        print(f"查詢錯誤: {e}")

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

if __name__ == "__main__":
    main()