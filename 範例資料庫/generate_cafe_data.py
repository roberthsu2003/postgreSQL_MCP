#!/usr/bin/env python3
"""
產生職場情境「連鎖咖啡門市」範例資料:
1. 3 個月份的 Excel 檔 (202401, 202402, 202403) 與單一彙整 CSV (模擬辦公室 Excel 檔案管理痛點)
2. 正規化後的 PostgreSQL 關聯資料庫 cafe_shop.sql (一鍵在 Supabase / DBeaver 執行)
3. 巨量資料產生器 generate_100k_orders.sql (免下載大檔, 資料庫自體秒生 10 萬筆)
"""
import random
from datetime import date, datetime, timedelta
from pathlib import Path
import csv
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

BASE_DIR = Path(__file__).resolve().parent
EXCEL_DIR = BASE_DIR / "excel範例" / "連鎖門市月報表"
SQL_DIR = BASE_DIR / "中文範例資料庫"

EXCEL_DIR.mkdir(parents=True, exist_ok=True)
SQL_DIR.mkdir(parents=True, exist_ok=True)

rng = random.Random(2024)

# 1. 基礎設定
STORES = [
    (1, "台北信義店", "台北市信義區忠孝東路五段", "北部", "02-2720-1111"),
    (2, "台北車站店", "台北市中正區忠孝西路一段", "北部", "02-2311-2222"),
    (3, "新竹巨城店", "新竹市東區中央路", "北部", "03-535-3333"),
    (4, "台中逢甲店", "台中市西屯區逢甲路", "中部", "04-2451-4444"),
    (5, "高雄巨蛋店", "高雄市左營區博愛二路", "南部", "07-555-5555"),
]

STAFF = [
    (1, "張志明", 1, "店長", "2021-03-01", 52000),
    (2, "陳美玲", 1, "正職咖啡師", "2022-07-15", 38000),
    (3, "林家豪", 1, "工讀生", "2023-10-01", 26000),
    (4, "黃雅婷", 2, "店長", "2020-11-01", 55000),
    (5, "李冠宇", 2, "正職咖啡師", "2023-02-20", 37000),
    (6, "吳欣宜", 3, "店長", "2022-05-10", 50000),
    (7, "蔡哲瑋", 3, "正職咖啡師", "2023-08-01", 36000),
    (8, "許淑芬", 4, "店長", "2021-08-15", 51000),
    (9, "鄭建誠", 4, "正職咖啡師", "2022-12-01", 38000),
    (10, "謝佩珊", 4, "工讀生", "2024-01-05", 26000),
    (11, "郭俊宏", 5, "店長", "2021-01-10", 53000),
    (12, "曾思妤", 5, "正職咖啡師", "2023-04-15", 37000),
]

CATEGORIES = [
    (1, "義式咖啡"),
    (2, "特調茶飲"),
    (3, "現烤點心"),
    (4, "輕食三明治"),
]

PRODUCTS = [
    # (id, cat_id, name, price, cost, launched_on)
    (1, 1, "美式咖啡", 70, 20, "2023-01-01"),
    (2, 1, "經典拿鐵", 95, 35, "2023-01-01"),
    (3, 1, "焦糖瑪奇朵", 120, 45, "2023-01-01"),
    (4, 1, "燕麥奶拿鐵", 130, 50, "2023-03-15"),
    (5, 1, "摩卡咖啡", 115, 42, "2023-01-01"),
    (6, 1, "冰滴咖啡", 150, 60, "2024-03-01"),  # 3月新品
    (7, 2, "蜜香紅茶", 50, 12, "2023-01-01"),
    (8, 2, "翡翠檸檬綠", 60, 15, "2023-01-01"),
    (9, 2, "珍珠醇奶茶", 65, 18, "2023-01-01"),
    (10, 2, "靜岡抹茶歐蕾", 110, 40, "2023-05-01"),
    (11, 2, "紅玉白桃烏龍", 75, 22, "2024-02-01"), # 2月新品
    (12, 3, "法式經典可頌", 65, 25, "2023-01-01"),
    (13, 3, "藍莓乳酪貝果", 60, 22, "2023-01-01"),
    (14, 3, "熔岩巧克力蛋糕", 90, 35, "2023-04-01"),
    (15, 3, "草莓生乳千層", 140, 55, "2024-02-05"), # 2月春節新品
    (16, 4, "經典牛肉起司堡", 120, 48, "2023-01-01"),
    (17, 4, "燻雞雙起司三明治", 85, 32, "2023-01-01"),
    (18, 4, "黑椒里肌吐司", 75, 28, "2023-06-01"),
]

# 會員池 (共 50 位會員)
SURNAMES = list("陳林黃張李王吳劉蔡楊許鄭謝郭洪曾邱廖賴周")
FIRSTNAMES = ["冠宇", "雅婷", "家豪", "欣宜", "建誠", "淑芬", "志明", "美玲", "哲瑋", "佩珊", 
              "俊宏", "思妤", "宗翰", "佳穎", "柏翰", "怡君", "承恩", "雨萱", "文凱", "庭瑋"]

CUSTOMERS = []
for cid in range(1, 51):
    cname = SURNAMES[(cid * 3) % len(SURNAMES)] + FIRSTNAMES[(cid * 7) % len(FIRSTNAMES)]
    cphone = f"09{rng.randint(10, 89):02d}-{rng.randint(100, 999):03d}-{rng.randint(100, 999):03d}"
    cgender = "女" if cid % 2 == 0 else "男"
    cjoin = date(2023, 1, 1) + timedelta(days=(cid * 17) % 360)
    CUSTOMERS.append((cid, cname, cphone, cgender, cjoin.isoformat()))

PAY_METHODS = ["LINE Pay", "信用卡", "現金", "街口支付"]
STATUSES = ["已完成", "已完成", "已完成", "已完成", "已退款", "已完成"] # 極少數退款

def generate_orders():
    orders = []
    order_items = []
    
    # 產生 2024 年 1、2、3 月資料
    # 1月: 140 筆, 2月(春節): 190 筆, 3月: 160 筆
    target_months = [(1, 140), (2, 190), (3, 160)]
    
    oid = 1
    for m, count in target_months:
        days_in_m = 29 if m == 2 else 31
        for _ in range(count):
            day = rng.randint(1, days_in_m)
            odate = date(2024, m, day)
            
            # 隨機產生時間 07:30 ~ 20:30
            hour = rng.choices(
                [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
                weights=[3, 10, 8, 4, 6, 12, 8, 6, 7, 5, 8, 7, 4, 2] # 早尖峰、午尖峰權重高
            )[0]
            minute = rng.randint(0, 59)
            otime = f"{hour:02d}:{minute:02d}"
            
            # 挑選門市與對應店員
            store = rng.choice(STORES)
            store_staff = [s for s in STAFF if s[2] == store[0]]
            staff_member = rng.choice(store_staff)
            
            # 會員: 70% 有會員, 30% 散客 (None)
            cust = rng.choice(CUSTOMERS) if rng.random() < 0.70 else None
            pay = rng.choice(PAY_METHODS)
            status = rng.choice(STATUSES)
            
            orders.append({
                "order_id": oid,
                "order_date": odate.isoformat(),
                "order_time": otime,
                "store_id": store[0],
                "store_name": store[1],
                "store_region": store[3],
                "staff_id": staff_member[0],
                "staff_name": staff_member[1],
                "customer_id": cust[0] if cust else None,
                "customer_name": cust[1] if cust else "散客",
                "customer_phone": cust[2] if cust else "",
                "payment_method": pay,
                "status": status
            })
            
            # 挑選 1 ~ 3 種商品
            item_count = rng.choices([1, 2, 3], weights=[55, 35, 10])[0]
            # 只能挑當時已上市的商品
            avail_products = [p for p in PRODUCTS if p[5] <= odate.isoformat()]
            picked_products = rng.sample(avail_products, item_count)
            
            for prod in picked_products:
                qty = rng.choices([1, 2, 3, 4], weights=[70, 20, 7, 3])[0]
                order_items.append({
                    "order_id": oid,
                    "product_id": prod[0],
                    "product_name": prod[2],
                    "category_id": prod[1],
                    "unit_price": prod[3],
                    "quantity": qty,
                    "subtotal": prod[3] * qty
                })
            
            oid += 1
            
    return orders, order_items

def write_excel_monthly(orders, order_items):
    """
    產生 3 個未正規化的 Excel 檔 (模擬行政分月管理檔案的日常)
    """
    # 組合每列平坦化明細
    items_by_oid = {}
    for item in order_items:
        items_by_oid.setdefault(item["order_id"], []).append(item)
        
    flat_rows = []
    cat_map = {c[0]: c[1] for c in CATEGORIES}
    
    for ord_info in orders:
        oid = ord_info["order_id"]
        for it in items_by_oid[oid]:
            flat_rows.append({
                "銷售單號": f"ORD{oid:05d}",
                "銷售日期": ord_info["order_date"],
                "時間": ord_info["order_time"],
                "門市名稱": ord_info["store_name"],
                "區域": ord_info["store_region"],
                "經手店員": ord_info["staff_name"],
                "會員姓名": ord_info["customer_name"],
                "會員電話": ord_info["customer_phone"],
                "商品分類": cat_map[it["category_id"]],
                "商品名稱": it["product_name"],
                "單價": it["unit_price"],
                "數量": it["quantity"],
                "小計": it["subtotal"],
                "付款方式": ord_info["payment_method"],
                "狀態": ord_info["status"]
            })
            
    # 依月份拆分輸出
    headers = ["銷售單號", "銷售日期", "時間", "門市名稱", "區域", "經手店員", 
               "會員姓名", "會員電話", "商品分類", "商品名稱", "單價", "數量", "小計", "付款方式", "狀態"]
               
    months = ["2024-01", "2024-02", "2024-03"]
    
    # 樣式設定
    header_fill = PatternFill(start_color="1F497D", end_color="1F497D", fill_type="solid")
    header_font = Font(name="微軟正黑體", size=11, bold=True, color="FFFFFF")
    cell_font = Font(name="微軟正黑體", size=10)
    thin_border = Border(
        left=Side(style='thin', color='D9D9D9'),
        right=Side(style='thin', color='D9D9D9'),
        top=Side(style='thin', color='D9D9D9'),
        bottom=Side(style='thin', color='D9D9D9')
    )
    align_center = Alignment(horizontal='center', vertical='center')
    align_right = Alignment(horizontal='right', vertical='center')
    align_left = Alignment(horizontal='left', vertical='center')
    
    for m in months:
        m_num = m.split("-")[1]
        m_rows = [r for r in flat_rows if r["銷售日期"].startswith(m)]
        
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = f"{m}門市明細"
        ws.views.sheetView[0].showGridLines = True
        
        # 標題列
        ws.append(headers)
        for col_idx in range(1, len(headers) + 1):
            cell = ws.cell(row=1, column=col_idx)
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = align_center
            
        # 資料列
        for r_idx, row_data in enumerate(m_rows, start=2):
            for c_idx, h in enumerate(headers, start=1):
                val = row_data[h]
                cell = ws.cell(row=r_idx, column=c_idx, value=val)
                cell.font = cell_font
                cell.border = thin_border
                
                # 對齊設定
                if h in ["銷售單號", "銷售日期", "時間", "區域", "付款方式", "狀態"]:
                    cell.alignment = align_center
                elif h in ["單價", "數量", "小計"]:
                    cell.alignment = align_right
                    if h in ["單價", "小計"]:
                        cell.number_format = "#,##0"
                else:
                    cell.alignment = align_left
                    
        # 自動欄寬
        for col in ws.columns:
            max_len = max(len(str(cell.value or '')) for cell in col)
            col_letter = get_column_letter(col[0].column)
            ws.column_dimensions[col_letter].width = max(max_len * 2.2, 12)
            
        file_path = EXCEL_DIR / f"門市銷售明細_{m.replace('-', '')}.xlsx"
        wb.save(file_path)
        print(f"✅ 已產生 Excel 檔: {file_path.name} (筆數: {len(m_rows)})")
        
    # 同時輸出一份第一季合體 CSV，方便學生練習 CSV 匯入
    csv_path = EXCEL_DIR / "門市銷售明細_2024Q1_全部.csv"
    with open(csv_path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        writer.writerows(flat_rows)
    print(f"✅ 已產生完整單表 CSV: {csv_path.name} (筆數: {len(flat_rows)})")
    
    return flat_rows

def write_sql_script(orders, order_items):
    """
    產生乾淨正規化、一鍵執行的 PostgreSQL 腳本 cafe_shop.sql
    """
    out_path = SQL_DIR / "cafe_shop.sql"
    
    def q(v):
        if v is None:
            return "NULL"
        if isinstance(v, (int, float)):
            return str(v)
        return "'" + str(v).replace("'", "''") + "'"
        
    sql = []
    sql.append("-- =====================================================================")
    sql.append("-- 繁體中文範例資料庫: 連鎖咖啡門市 (cafe_shop)")
    sql.append("-- 專為「從 Excel 檔案管理跨入 SQL 資料庫」打造的教學範例")
    sql.append("-- 資料表: stores, staff, categories, products, customers, orders, order_items")
    sql.append("-- 適合練習: WHERE 日期篩選、GROUP BY 跨月報表、JOIN 關聯、HAVING、Window Functions")
    sql.append("--")
    sql.append("-- 使用方式:")
    sql.append("--   Supabase: 開啟 SQL Editor → 貼上全部內容 → 點選 Run 執行")
    sql.append("--   DBeaver : 開啟檔案 (Alt+X) 執行全部")
    sql.append("-- =====================================================================")
    sql.append("")
    sql.append("SET client_encoding = 'UTF8';")
    sql.append("SET search_path TO public;")
    sql.append("BEGIN;")
    sql.append("")
    sql.append("DROP TABLE IF EXISTS order_items, orders, customers, products, categories, staff, stores CASCADE;")
    sql.append("")
    
    # 建表 DDL
    sql.append("""-- 1. 門市資料表
CREATE TABLE stores (
    store_id   INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name       VARCHAR(30) NOT NULL UNIQUE,
    address    VARCHAR(100) NOT NULL,
    region     VARCHAR(10) NOT NULL CHECK (region IN ('北部', '中部', '南部', '東部')),
    phone      VARCHAR(20)
);

-- 2. 員工資料表
CREATE TABLE staff (
    staff_id   INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    store_id   INT NOT NULL REFERENCES stores(store_id),
    title      VARCHAR(20) NOT NULL,
    hired_on   DATE NOT NULL,
    salary     INT NOT NULL CHECK (salary >= 0)
);

-- 3. 商品分類表
CREATE TABLE categories (
    category_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name        VARCHAR(20) NOT NULL UNIQUE
);

-- 4. 商品目錄表
CREATE TABLE products (
    product_id  INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(category_id),
    name        VARCHAR(50) NOT NULL,
    price       INT NOT NULL CHECK (price >= 0),
    cost        INT NOT NULL CHECK (cost >= 0),
    launched_on DATE NOT NULL
);

-- 5. 會員資料表
CREATE TABLE customers (
    customer_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    phone       VARCHAR(20) UNIQUE,
    gender      CHAR(1) CHECK (gender IN ('男', '女')),
    joined_on   DATE NOT NULL
);

-- 6. 銷售訂單主表 (每筆訂單一列)
CREATE TABLE orders (
    order_id       INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    order_date     DATE NOT NULL,
    order_time     TIME NOT NULL,
    store_id       INT NOT NULL REFERENCES stores(store_id),
    staff_id       INT NOT NULL REFERENCES staff(staff_id),
    customer_id    INT REFERENCES customers(customer_id), -- 允許 NULL 代表非會員散客
    payment_method VARCHAR(20) NOT NULL,
    status         VARCHAR(10) NOT NULL CHECK (status IN ('已完成', '已退款', '已取消'))
);

-- 7. 訂單商品明細表 (每筆訂單內的各項商品)
CREATE TABLE order_items (
    order_id   INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

COMMENT ON TABLE stores      IS '門市據點';
COMMENT ON TABLE staff       IS '門市正職與計時人員';
COMMENT ON TABLE products    IS '飲品與餐點目錄';
COMMENT ON TABLE customers   IS '會員資料 (散客不在此表)';
COMMENT ON TABLE orders      IS '訂單主檔 (時間、門市、經手人)';
COMMENT ON TABLE order_items IS '訂單明細 (品項、單價、購買數量)';
""")

    # 寫入 INSERT 資料
    # Stores
    sql.append("-- 插入門市資料")
    store_vals = [f"({s[0]}, {q(s[1])}, {q(s[2])}, {q(s[3])}, {q(s[4])})" for s in STORES]
    sql.append(f"INSERT INTO stores (store_id, name, address, region, phone) VALUES\n" + ",\n".join(store_vals) + ";\n")
    
    # Staff
    sql.append("-- 插入員工資料")
    staff_vals = [f"({s[0]}, {q(s[1])}, {s[2]}, {q(s[3])}, {q(s[4])}, {s[5]})" for s in STAFF]
    sql.append(f"INSERT INTO staff (staff_id, name, store_id, title, hired_on, salary) VALUES\n" + ",\n".join(staff_vals) + ";\n")
    
    # Categories
    sql.append("-- 插入分類資料")
    cat_vals = [f"({c[0]}, {q(c[1])})" for c in CATEGORIES]
    sql.append(f"INSERT INTO categories (category_id, name) VALUES\n" + ",\n".join(cat_vals) + ";\n")
    
    # Products
    sql.append("-- 插入商品資料")
    prod_vals = [f"({p[0]}, {p[1]}, {q(p[2])}, {p[3]}, {p[4]}, {q(p[5])})" for p in PRODUCTS]
    sql.append(f"INSERT INTO products (product_id, category_id, name, price, cost, launched_on) VALUES\n" + ",\n".join(prod_vals) + ";\n")
    
    # Customers
    sql.append("-- 插入會員資料")
    cust_vals = [f"({c[0]}, {q(c[1])}, {q(c[2])}, {q(c[3])}, {q(c[4])})" for c in CUSTOMERS]
    sql.append(f"INSERT INTO customers (customer_id, name, phone, gender, joined_on) VALUES\n" + ",\n".join(cust_vals) + ";\n")
    
    # Orders (chunk 100)
    sql.append("-- 插入 2024 年第一季銷售訂單 (共 490 筆)")
    for i in range(0, len(orders), 100):
        chunk = orders[i:i+100]
        o_rows = []
        for o in chunk:
            cid_str = str(o["customer_id"]) if o["customer_id"] else "NULL"
            o_rows.append(f"({o['order_id']}, {q(o['order_date'])}, {q(o['order_time'])}, {o['store_id']}, {o['staff_id']}, {cid_str}, {q(o['payment_method'])}, {q(o['status'])})")
        sql.append(f"INSERT INTO orders (order_id, order_date, order_time, store_id, staff_id, customer_id, payment_method, status) VALUES\n" + ",\n".join(o_rows) + ";")
    sql.append("")
    
    # Order Items (chunk 150)
    sql.append("-- 插入銷售訂單明細 (共 700+ 筆)")
    for i in range(0, len(order_items), 150):
        chunk = order_items[i:i+150]
        it_rows = []
        for it in chunk:
            it_rows.append(f"({it['order_id']}, {it['product_id']}, {it['quantity']}, {it['unit_price']})")
        sql.append(f"INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES\n" + ",\n".join(it_rows) + ";")
    sql.append("")
    
    # 重設 sequence
    sql.append("-- 重設各主鍵序列起始值")
    sql.append("SELECT setval(pg_get_serial_sequence('stores', 'store_id'), (SELECT MAX(store_id) FROM stores));")
    sql.append("SELECT setval(pg_get_serial_sequence('staff', 'staff_id'), (SELECT MAX(staff_id) FROM staff));")
    sql.append("SELECT setval(pg_get_serial_sequence('categories', 'category_id'), (SELECT MAX(category_id) FROM categories));")
    sql.append("SELECT setval(pg_get_serial_sequence('products', 'product_id'), (SELECT MAX(product_id) FROM products));")
    sql.append("SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), (SELECT MAX(customer_id) FROM customers));")
    sql.append("SELECT setval(pg_get_serial_sequence('orders', 'order_id'), (SELECT MAX(order_id) FROM orders));")
    sql.append("")
    sql.append("COMMIT;")
    sql.append("")
    
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(sql))
        
    print(f"✅ 已產生關聯資料庫 SQL 腳本: {out_path.name} (大小: {out_path.stat().st_size / 1024:.1f} KB)")

def write_generator_sql():
    """
    產生免下載、資料庫自體生成 10 萬筆訂單的 SQL 腳本 generate_100k_orders.sql
    """
    out_path = BASE_DIR / "中文範例資料庫" / "generate_100k_orders.sql"
    
    content = """-- =====================================================================
-- 🚀 巨量資料產生器 (PostgreSQL generate_series)
-- 目的: 體驗 10 萬筆訂單查詢效能與索引 (INDEX) 威力，免下載、免匯入幾十 MB 檔案！
--
-- 執行方式:
--   請先確保已執行過 cafe_shop.sql 建立好基本資料表。
--   在 Supabase SQL Editor 或 DBeaver 中直接執行本檔，約 1~2 秒即可瞬間產生 10 萬筆明細。
-- =====================================================================

DO $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    cur_orders INT;
BEGIN
    SELECT COUNT(*) INTO cur_orders FROM orders;
    IF cur_orders = 0 THEN
        RAISE EXCEPTION '請先執行 cafe_shop.sql 建立基礎門市與商品資料！';
    END IF;

    RAISE NOTICE '⚡ 開始動態生成 50,000 筆訂單與 100,000 筆商品明細...';
    start_time := clock_timestamp();

    -- 1. 產生 50,000 筆延伸訂單 (日期涵蓋 2024 全年)
    INSERT INTO orders (order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
    SELECT 
        DATE '2024-01-01' + (TRUNC(random() * 365))::INT AS order_date,
        (TIME '07:30:00' + (TRUNC(random() * 46800))::INT * INTERVAL '1 second')::TIME AS order_time,
        (TRUNC(random() * 5) + 1)::INT AS store_id,
        (TRUNC(random() * 12) + 1)::INT AS staff_id,
        CASE WHEN random() < 0.75 THEN (TRUNC(random() * 50) + 1)::INT ELSE NULL END AS customer_id,
        (ARRAY['LINE Pay', '信用卡', '現金', '街口支付'])[floor(random() * 4 + 1)] AS payment_method,
        (ARRAY['已完成', '已完成', '已完成', '已退款'])[floor(random() * 4 + 1)] AS status
    FROM generate_series(1, 50000);

    -- 2. 為最新產生的這批訂單，隨機配發 1~3 項商品明細 (合計約 10 萬列)
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    SELECT 
        o.order_id,
        p.product_id,
        (TRUNC(random() * 3) + 1)::INT AS quantity,
        p.price AS unit_price
    FROM (
        SELECT order_id FROM orders WHERE order_id > 490
    ) o
    CROSS JOIN LATERAL (
        SELECT product_id, price 
        FROM products 
        ORDER BY random() 
        LIMIT (TRUNC(random() * 2) + 1)::INT
    ) p
    ON CONFLICT (order_id, product_id) DO NOTHING;

    end_time := clock_timestamp();
    RAISE NOTICE '🎉 完成！總耗時: %', (end_time - start_time);
END $$;

-- 驗證成果
SELECT 
    (SELECT COUNT(*) FROM orders) AS 總訂單筆數,
    (SELECT COUNT(*) FROM order_items) AS 總明細筆數,
    (SELECT MIN(order_date) FROM orders) AS 起始日期,
    (SELECT MAX(order_date) FROM orders) AS 結束日期;
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"✅ 已產生巨量產生器 SQL: {out_path.name}")

if __name__ == "__main__":
    print("🚀 開始生成範例資料...")
    ords, items = generate_orders()
    write_excel_monthly(ords, items)
    write_sql_script(ords, items)
    write_generator_sql()
    print("✨ 所有資料產生完成！")

