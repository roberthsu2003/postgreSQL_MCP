"""
產生繁體中文範例資料庫的 SQL 檔(網路商店、學校選課、圖書館借閱)

    python generate.py

使用固定亂數種子,每次產生的內容都相同。
所有人名、書名、出版社皆為虛構,email 使用 example.com 保留網域。
"""
import random
from datetime import date, timedelta
from pathlib import Path

OUT = Path(__file__).parent

SURNAMES = list("陳林黃張李王吳劉蔡楊許鄭謝郭洪曾邱廖賴周徐蘇葉莊呂江何蕭羅高")
SURNAME_W = [11, 8, 6, 5, 5, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1]
MALE = list("志明家豪俊宏冠宇承恩建誠柏翰彥廷哲瑋信偉傑文凱政育德仁宗")
FEMALE = list("怡君雅婷淑芬佳穎欣宜庭詩涵雨萱筱慧佩珊思妤心瑜美玲靜")

CITIES = ["臺北市", "新北市", "桃園市", "臺中市", "臺南市", "高雄市", "基隆市", "新竹市", "新竹縣",
          "苗栗縣", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "屏東縣", "宜蘭縣", "花蓮縣",
          "臺東縣", "澎湖縣", "金門縣"]
CITY_W = [10, 16, 9, 11, 7, 11, 2, 2, 2, 2, 5, 2, 3, 1, 2, 3, 2, 1, 1, 1, 1]


def q(v):
    """把 Python 值轉成 SQL 常值"""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, date):
        return f"'{v.isoformat()}'"
    return "'" + str(v).replace("'", "''") + "'"


def insert(table, cols, rows, chunk=200):
    out = []
    for i in range(0, len(rows), chunk):
        part = rows[i:i + chunk]
        values = ",\n".join("(" + ", ".join(q(v) for v in r) + ")" for r in part)
        out.append(f"INSERT INTO {table} ({', '.join(cols)}) VALUES\n{values};\n")
    return "\n".join(out)


def reset_identity(table, col):
    return f"SELECT setval(pg_get_serial_sequence('{table}', '{col}'), (SELECT MAX({col}) FROM {table}));\n"


def person(rng, used):
    while True:
        gender = rng.choice(["男", "女"])
        pool = MALE if gender == "男" else FEMALE
        name = rng.choices(SURNAMES, SURNAME_W)[0] + rng.choice(pool) + rng.choice(pool)
        if name[1] != name[2] and name not in used:
            used.add(name)
            return name, gender


def rand_date(rng, start, end):
    return start + timedelta(days=rng.randint(0, (end - start).days))


def header(title, tables, topics):
    return f"""-- =====================================================================
-- 繁體中文範例資料庫:{title}
-- 資料表:{tables}
-- 適合練習:{topics}
--
-- 使用方式(擇一):
--   pgAdmin / DBeaver:開啟 SQL 編輯器 → 開啟本檔 → 全部執行
--   psql            :psql -U postgres -d 資料庫名稱 -f 本檔名.sql
--
-- 本檔可以重複執行:會先刪除同名資料表再重建。
-- 內容皆為虛構資料,僅供教學使用。
-- =====================================================================

SET client_encoding = 'UTF8';
BEGIN;

"""


FOOTER = "\nCOMMIT;\n"


# ---------------------------------------------------------------------
# 1. 網路商店
# ---------------------------------------------------------------------
def build_shop():
    rng = random.Random(2025)
    used = set()

    categories = ["3C周邊", "文具", "零食", "飲料", "生活用品", "書籍", "服飾", "美妝"]
    products = [  # (分類, 名稱, 售價, 成本)
        (1, "無線藍牙耳機", 1290, 780), (1, "行動電源 10000mAh", 690, 390), (1, "USB-C 快充線 1 公尺", 199, 80),
        (1, "無線滑鼠", 450, 220), (1, "機械式鍵盤", 2490, 1500), (1, "手機立架", 149, 50),
        (1, "螢幕掛燈", 990, 560), (1, "筆電散熱墊", 590, 300),
        (2, "中性筆(黑)10 入", 120, 50), (2, "方格筆記本 A5", 65, 25), (2, "便利貼組", 89, 30),
        (2, "螢光筆 5 色組", 99, 40), (2, "修正帶", 45, 18), (2, "B5 活頁夾", 150, 70),
        (3, "海苔脆片", 59, 28), (3, "鳳梨酥禮盒 12 入", 480, 260), (3, "花生牛軋糖", 199, 95),
        (3, "綜合堅果", 299, 160), (3, "地瓜脆片", 79, 35), (3, "太陽餅禮盒", 360, 190),
        (4, "高山烏龍茶包 50 入", 350, 170), (4, "冷萃咖啡 6 入", 299, 150), (4, "無糖綠茶 24 入", 420, 260),
        (4, "黑糖薑茶", 180, 80), (4, "蜂蜜檸檬飲 6 入", 210, 110),
        (5, "不鏽鋼保溫瓶", 750, 380), (5, "環保餐具組", 260, 110), (5, "竹纖維毛巾 3 入", 199, 85),
        (5, "防潑水雨傘", 399, 180), (5, "大型收納箱", 320, 150), (5, "香氛蠟燭", 450, 180),
        (6, "SQL 資料庫入門", 520, 350), (6, "Python 程式設計實戰", 580, 390), (6, "資料分析一本通", 650, 430),
        (6, "臺灣小吃散步地圖", 380, 240), (6, "理財從零開始", 350, 220),
        (7, "素面圓領 T 恤", 390, 150), (7, "連帽外套", 1280, 600), (7, "機能運動襪 3 入", 250, 90),
        (7, "棒球帽", 490, 200), (7, "帆布托特包", 590, 250),
        (8, "保濕面膜 10 入", 399, 160), (8, "防曬乳 SPF50", 520, 230), (8, "護手霜", 180, 70),
        (8, "卸妝油", 480, 210), (8, "護唇膏", 120, 45),
        (1, "智慧手環", 1690, 980),  # 新品,還沒有人買過
    ]
    launched = []
    for i, _ in enumerate(products):
        launched.append(date(2025, 12, 20) if i == len(products) - 1 else rand_date(rng, date(2023, 1, 1), date(2024, 12, 31)))
    stock = [rng.randint(0, 300) if i % 9 else 0 for i in range(len(products))]  # 部分商品缺貨

    customers = []
    for cid in range(1, 151):
        name, gender = person(rng, used)
        birthday = rand_date(rng, date(1965, 1, 1), date(2006, 12, 31)) if rng.random() > 0.08 else None
        city = rng.choices(CITIES, CITY_W)[0]
        joined = rand_date(rng, date(2023, 1, 1), date(2025, 10, 31))
        customers.append((cid, name, gender, birthday, city, f"user{cid:03d}@example.com", joined))

    # 2025 全年訂單,11、12 月(雙 11、年底)比較多
    month_w = [7, 6, 7, 7, 8, 8, 7, 8, 8, 9, 15, 12]
    pay = ["信用卡", "LINE Pay", "貨到付款", "ATM 轉帳"]
    pop = [rng.uniform(0.3, 3) for _ in products[:-1]]
    active = [c for c in customers if c[0] % 13 != 0]  # 部分會員從未下單
    loyal = rng.sample(active, 15)
    orders, items = [], []
    oid = 0
    for _ in range(700):
        m = rng.choices(range(1, 13), month_w)[0]
        last = (date(2025, m % 12 + 1, 1) - timedelta(days=1)).day if m < 12 else 31
        od = date(2025, m, rng.randint(1, last))
        pool = loyal if rng.random() < 0.3 else active
        pool = [c for c in pool if c[6] <= od]  # 只能挑當時已經註冊的會員
        if not pool:
            continue
        cust = rng.choice(pool)
        oid += 1
        if od >= date(2025, 12, 24):
            status = rng.choices(["配送中", "已完成"], [6, 4])[0]
        else:
            status = rng.choices(["已完成", "已取消"], [93, 7])[0]
        picked = set()
        subtotal = 0
        for _ in range(rng.choices([1, 2, 3, 4, 5], [35, 30, 20, 10, 5])[0]):
            p = rng.choices(range(len(products) - 1), pop)[0]
            if p in picked:
                continue
            picked.add(p)
            qty = rng.choices([1, 2, 3, 5], [70, 20, 7, 3])[0]
            items.append((oid, p + 1, qty, products[p][2]))
            subtotal += qty * products[p][2]
        fee = 0 if subtotal >= 999 else 80
        orders.append((oid, cust[0], od, rng.choices(pay, [45, 25, 18, 12])[0], status, fee))
    orders.sort(key=lambda o: o[2])
    # 依日期重新編號,讓 order_id 順序 = 時間順序
    remap = {o[0]: i + 1 for i, o in enumerate(orders)}
    orders = [(remap[o[0]],) + o[1:] for o in orders]
    items = sorted([(remap[i[0]],) + i[1:] for i in items])

    staff = [
        (1, "王大明", "總經理", "管理部", None, date(2018, 3, 1), 120000),
        (2, "林美玲", "業務經理", "業務部", 1, date(2019, 6, 15), 85000),
        (3, "陳志豪", "資深業務", "業務部", 2, date(2020, 2, 3), 62000),
        (4, "黃怡君", "業務專員", "業務部", 2, date(2022, 9, 1), 45000),
        (5, "張家豪", "業務專員", "業務部", 2, date(2023, 4, 10), 43000),
        (6, "李佳穎", "行銷經理", "行銷部", 1, date(2019, 11, 1), 82000),
        (7, "吳承翰", "行銷專員", "行銷部", 6, date(2021, 7, 19), 48000),
        (8, "劉雅婷", "社群小編", "行銷部", 6, date(2024, 1, 8), 38000),
        (9, "蔡宗翰", "客服主管", "客服部", 1, date(2020, 5, 4), 60000),
        (10, "楊淑芬", "客服專員", "客服部", 9, date(2021, 3, 22), 40000),
        (11, "許冠宇", "客服專員", "客服部", 9, date(2024, 8, 5), 36000),
        (12, "鄭建誠", "倉管主管", "物流部", 1, date(2019, 1, 14), 58000),
        (13, "謝佩珊", "倉管人員", "物流部", 12, date(2022, 2, 7), 38000),
        (14, "郭俊宏", "倉管人員", "物流部", 12, date(2023, 10, 16), 36000),
        (15, "洪詩涵", "工讀生", "物流部", 12, date(2025, 7, 1), None),
    ]

    sql = header("網路商店(shop)", "categories, products, customers, orders, order_items, staff",
                 "SELECT、WHERE、ORDER BY、JOIN、GROUP BY、HAVING、日期函式、子查詢、自我連結")
    sql += """DROP TABLE IF EXISTS order_items, orders, customers, products, categories, staff CASCADE;

CREATE TABLE categories (
    category_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name        VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id  INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(category_id),
    name        VARCHAR(50) NOT NULL,
    price       INT NOT NULL CHECK (price >= 0),
    cost        INT NOT NULL CHECK (cost >= 0),
    stock       INT NOT NULL DEFAULT 0,
    launched_on DATE
);

CREATE TABLE customers (
    customer_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('男', '女')),
    birthday    DATE,
    city        VARCHAR(10),
    email       VARCHAR(100) UNIQUE,
    joined_on   DATE NOT NULL
);

CREATE TABLE orders (
    order_id       INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    order_date     DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    status         VARCHAR(10) NOT NULL CHECK (status IN ('已完成', '已取消', '配送中')),
    shipping_fee   INT NOT NULL DEFAULT 0
);

CREATE TABLE order_items (
    order_id   INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity   INT NOT NULL CHECK (quantity > 0),
    unit_price INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE staff (
    staff_id   INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    title      VARCHAR(20) NOT NULL,
    department VARCHAR(20) NOT NULL,
    manager_id INT REFERENCES staff(staff_id),
    hired_on   DATE NOT NULL,
    salary     INT
);

COMMENT ON TABLE categories  IS '商品分類';
COMMENT ON TABLE products    IS '商品';
COMMENT ON COLUMN products.price IS '售價(元)';
COMMENT ON COLUMN products.cost  IS '進貨成本(元)';
COMMENT ON COLUMN products.stock IS '庫存數量,0 代表缺貨';
COMMENT ON TABLE customers   IS '會員';
COMMENT ON TABLE orders      IS '訂單(2025 年)';
COMMENT ON COLUMN orders.shipping_fee IS '運費,商品金額滿 999 元免運';
COMMENT ON TABLE order_items IS '訂單明細';
COMMENT ON COLUMN order_items.unit_price IS '下單當時的單價';
COMMENT ON TABLE staff       IS '員工,manager_id 指向直屬主管';
COMMENT ON COLUMN staff.salary IS '月薪,工讀生為 NULL';

"""
    sql += insert("categories", ["category_id", "name"], [(i + 1, n) for i, n in enumerate(categories)])
    sql += insert("products", ["product_id", "category_id", "name", "price", "cost", "stock", "launched_on"],
                  [(i + 1, p[0], p[1], p[2], p[3], stock[i], launched[i]) for i, p in enumerate(products)])
    sql += insert("customers", ["customer_id", "name", "gender", "birthday", "city", "email", "joined_on"], customers)
    sql += insert("orders", ["order_id", "customer_id", "order_date", "payment_method", "status", "shipping_fee"], orders)
    sql += insert("order_items", ["order_id", "product_id", "quantity", "unit_price"], items)
    sql += insert("staff", ["staff_id", "name", "title", "department", "manager_id", "hired_on", "salary"], staff)
    sql += "\n" + "".join(reset_identity(t, c) for t, c in [
        ("categories", "category_id"), ("products", "product_id"), ("customers", "customer_id"),
        ("orders", "order_id"), ("staff", "staff_id")])
    sql += FOOTER
    return sql


# ---------------------------------------------------------------------
# 2. 學校選課
# ---------------------------------------------------------------------
def build_school():
    rng = random.Random(114)
    used = set()

    departments = [  # (代碼, 名稱, 大樓)
        ("CS", "資訊工程學系", "工程館"), ("EE", "電機工程學系", "工程館"),
        ("BA", "企業管理學系", "管理學院大樓"), ("FN", "財務金融學系", "管理學院大樓"),
        ("FL", "外國語文學系", "人文館"), ("DM", "數位媒體設計學系", "設計館"),
    ]
    course_names = {
        "CS": [("程式設計(一)", 3), ("資料結構", 3), ("資料庫系統", 3), ("作業系統", 3), ("人工智慧導論", 3)],
        "EE": [("電路學", 3), ("電子學", 3), ("訊號與系統", 3), ("微處理機", 3), ("嵌入式系統實作", 2)],
        "BA": [("管理學", 3), ("行銷管理", 3), ("組織行為", 3), ("人力資源管理", 3), ("創業管理", 2)],
        "FN": [("會計學", 3), ("財務管理", 3), ("投資學", 3), ("金融科技概論", 2), ("公司理財", 3)],
        "FL": [("英文寫作", 2), ("日語(一)", 2), ("英語會話", 2), ("翻譯實務", 3), ("跨文化溝通", 2)],
        "DM": [("設計概論", 2), ("影像處理", 3), ("網頁設計", 3), ("3D 動畫", 3), ("使用者經驗設計", 3)],
    }
    titles = ["教授", "副教授", "助理教授", "講師"]

    teachers = []
    tid = 0
    for d, _, _ in departments:
        for _ in range(3):
            tid += 1
            name, _g = person(rng, used)
            teachers.append((tid, name, d, rng.choices(titles, [3, 3, 3, 1])[0],
                             rand_date(rng, date(1998, 8, 1), date(2023, 8, 1))))
    for _ in range(2):  # 通識中心老師,不屬於任何學系
        tid += 1
        name, _g = person(rng, used)
        teachers.append((tid, name, None, "講師", rand_date(rng, date(2010, 8, 1), date(2022, 8, 1))))

    semesters = ["113-1", "113-2", "114-1"]
    courses = []
    for d, _, _ in departments:
        dept_teachers = [t for t in teachers if t[2] == d][:2]  # 每系第三位老師這學年沒開課
        for i, (cname, credit) in enumerate(course_names[d]):
            cid = f"{d}{101 + i * 100 + (i % 2)}"
            courses.append((cid, cname, d, dept_teachers[i % 2][0], credit, semesters[i % 3], rng.choice([40, 50, 60])))
    gen_t = [t[0] for t in teachers if t[2] is None]
    courses += [
        ("GE101", "大學國文", None, gen_t[0], 2, "113-1", 80),
        ("GE102", "體育", None, gen_t[1], 0, "113-2", 80),
        ("GE103", "生活中的統計", None, gen_t[0], 2, "114-1", 60),
        ("CS601", "量子計算入門", "CS", teachers[0][0], 2, "114-1", 30),  # 新開課,還沒有人選
    ]

    students = []
    for i in range(1, 201):
        year = rng.choice([111, 112, 113, 114])
        d = rng.choices(departments, [5, 4, 4, 3, 3, 3])[0][0]
        name, gender = person(rng, used)
        sid = f"S{year}{i:03d}"
        city = rng.choices(CITIES, CITY_W)[0]
        students.append((sid, name, gender, d, year, city, f"{sid.lower()}@example.com"))

    count = {c[0]: 0 for c in courses}
    cap = {c[0]: c[6] for c in courses}
    by_dept = {}
    for c in courses[:-1]:
        by_dept.setdefault(c[2], []).append(c)
    enrollments = []
    for s in students:
        own = by_dept[s[3]]
        others = [c for c in courses[:-1] if c[2] not in (s[3], None)]
        picks = rng.sample(own, rng.randint(2, 4)) + rng.sample(others, rng.randint(0, 2)) + \
            rng.sample(by_dept[None], rng.randint(1, 3))
        skill = rng.gauss(0, 8)
        for c in picks:
            if count[c[0]] >= cap[c[0]]:
                continue
            count[c[0]] += 1
            score = None if c[5] == "114-1" else max(0, min(100, round(rng.gauss(74, 12) + skill)))
            enrollments.append((s[0], c[0], score))

    sql = header("學校選課(school)", "departments, teachers, students, courses, enrollments",
                 "JOIN(多對多)、LEFT JOIN、GROUP BY、HAVING、子查詢、NULL 處理、CASE WHEN")
    sql += """DROP TABLE IF EXISTS enrollments, courses, students, teachers, departments CASCADE;

CREATE TABLE departments (
    dept_id  VARCHAR(4) PRIMARY KEY,
    name     VARCHAR(20) NOT NULL UNIQUE,
    building VARCHAR(20)
);

CREATE TABLE teachers (
    teacher_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    dept_id    VARCHAR(4) REFERENCES departments(dept_id),
    title      VARCHAR(10) NOT NULL,
    hired_on   DATE NOT NULL
);

CREATE TABLE students (
    student_id  VARCHAR(10) PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('男', '女')),
    dept_id     VARCHAR(4) NOT NULL REFERENCES departments(dept_id),
    enroll_year INT NOT NULL,
    hometown    VARCHAR(10),
    email       VARCHAR(100) UNIQUE
);

CREATE TABLE courses (
    course_id  VARCHAR(10) PRIMARY KEY,
    name       VARCHAR(30) NOT NULL,
    dept_id    VARCHAR(4) REFERENCES departments(dept_id),
    teacher_id INT NOT NULL REFERENCES teachers(teacher_id),
    credits    INT NOT NULL,
    semester   VARCHAR(6) NOT NULL,
    capacity   INT NOT NULL
);

CREATE TABLE enrollments (
    student_id VARCHAR(10) REFERENCES students(student_id) ON DELETE CASCADE,
    course_id  VARCHAR(10) REFERENCES courses(course_id) ON DELETE CASCADE,
    score      INT CHECK (score BETWEEN 0 AND 100),
    PRIMARY KEY (student_id, course_id)
);

COMMENT ON TABLE departments IS '學系';
COMMENT ON TABLE teachers    IS '教師,dept_id 為 NULL 代表通識中心';
COMMENT ON TABLE students    IS '學生,學號格式 S + 入學年度 + 流水號';
COMMENT ON COLUMN students.enroll_year IS '入學年度(民國年)';
COMMENT ON COLUMN students.hometown    IS '戶籍縣市';
COMMENT ON TABLE courses     IS '課程,dept_id 為 NULL 代表通識課';
COMMENT ON COLUMN courses.semester IS '學期,例如 113-2 代表 113 學年度下學期';
COMMENT ON COLUMN courses.capacity IS '修課人數上限';
COMMENT ON TABLE enrollments IS '選課紀錄(學生與課程的多對多關係)';
COMMENT ON COLUMN enrollments.score IS '學期成績,60 分及格;114-1 學期尚未結束所以是 NULL';

"""
    sql += insert("departments", ["dept_id", "name", "building"], departments)
    sql += insert("teachers", ["teacher_id", "name", "dept_id", "title", "hired_on"], teachers)
    sql += insert("students", ["student_id", "name", "gender", "dept_id", "enroll_year", "hometown", "email"], students)
    sql += insert("courses", ["course_id", "name", "dept_id", "teacher_id", "credits", "semester", "capacity"], courses)
    sql += insert("enrollments", ["student_id", "course_id", "score"], enrollments)
    sql += "\n" + reset_identity("teachers", "teacher_id")
    sql += FOOTER
    return sql


# ---------------------------------------------------------------------
# 3. 圖書館借閱
# ---------------------------------------------------------------------
def build_library():
    rng = random.Random(1999)
    used = set()

    publishers = [("晨光出版社", "臺北市"), ("青松文化", "新北市"), ("海風書房", "高雄市"),
                  ("星河出版", "臺北市"), ("木棉文創", "臺南市"), ("遠山圖書", "臺中市")]
    authors = []
    for aid in range(1, 23):
        name, _g = person(rng, used)
        authors.append((aid, name, rng.randint(1950, 1995)))

    books_by_cat = {
        "文學小說": ["雨季的最後一班公車", "鹿港巷弄的貓", "夏日海岸線", "霧中的燈塔", "外婆的灶腳",
                 "島嶼來信", "午夜的便利商店", "走過稻田的風"],
        "歷史": ["府城四百年", "大航海時代的臺灣", "鐵道與城市", "茶葉貿易簡史", "老街的故事", "地圖裡的臺灣"],
        "科普": ["一杯咖啡裡的化學", "星空觀測入門", "臺灣的山與海", "賞鳥入門圖鑑", "天氣為什麼會變",
               "你不知道的昆蟲世界", "大腦的祕密"],
        "商業理財": ["小資存錢術", "第一次買 ETF 就上手", "斜槓工作學", "品牌從一間小店開始", "會計其實不難", "談判的藝術"],
        "電腦資訊": ["SQL 查詢從零開始", "Python 資料分析實戰", "網頁設計入門", "生成式 AI 應用指南",
                 "資料庫設計的思考", "資訊安全基礎", "Excel 自動化"],
        "兒童繪本": ["小熊去郊遊", "月亮上的兔子", "會唱歌的雨滴", "阿公的腳踏車", "恐龍搬新家"],
        "旅遊": ["花東慢遊", "離島跳島計畫", "京都散步地圖", "臺灣鐵道旅行", "山屋與步道", "一個人的東南亞"],
        "心理勵志": ["好好休息也是一種能力", "和焦慮做朋友", "慢慢來比較快", "練習說不", "每天進步一點點"],
    }
    books = []
    bid = 0
    for cat, titles in books_by_cat.items():
        for t in titles:
            bid += 1
            isbn = f"978-626-{rng.randint(1000, 9999)}-{rng.randint(10, 99)}-{rng.randint(0, 9)}"
            books.append((bid, isbn, t, rng.randint(1, len(authors)), rng.randint(1, len(publishers)), cat,
                          rng.randint(2012, 2025), rng.choice([280, 320, 350, 380, 420, 450, 480, 520]),
                          rng.choices([1, 2, 3], [5, 3, 1])[0]))

    members = []
    for mid in range(1, 101):
        name, gender = person(rng, used)
        mtype = rng.choices(["一般", "學生", "銀髮"], [6, 3, 1])[0]
        members.append((mid, name, gender, mtype, rng.choices(CITIES, CITY_W)[0],
                        rand_date(rng, date(2020, 1, 1), date(2026, 6, 30))))

    # 借閱期限:一般 14 天、學生 21 天、銀髮 28 天
    days = {"一般": 14, "學生": 21, "銀髮": 28}
    pop = [0 if i % 17 == 16 else rng.uniform(0.3, 3) for i in range(len(books))]  # 幾本書從沒被借過
    loans = []
    for _ in range(900):
        m = rng.choice(members)
        start = max(m[5], date(2025, 1, 1))
        if start > date(2026, 9, 30):
            continue
        ld = rand_date(rng, start, date(2026, 9, 30))
        due = ld + timedelta(days=days[m[3]])
        r = rng.random()
        if ld > date(2026, 9, 10) and r < 0.6:
            ret = None  # 最近借的,還沒還
        elif r < 0.03:
            ret = None  # 逾期未還
        elif r < 0.18:
            ret = due + timedelta(days=rng.randint(1, 20))  # 逾期歸還
        else:
            ret = ld + timedelta(days=rng.randint(1, days[m[3]]))
        if ret and ret > date(2026, 10, 8):
            ret = None
        b = rng.choices(books, pop)[0]
        loans.append([None, b[0], m[0], ld, due, ret])
    loans.sort(key=lambda x: x[3])
    for i, l in enumerate(loans):
        l[0] = i + 1

    sql = header("圖書館借閱(library)", "publishers, authors, books, members, loans",
                 "JOIN、LEFT JOIN 找出沒被借過的書、日期計算(逾期天數)、IS NULL、GROUP BY、排名")
    sql += """DROP TABLE IF EXISTS loans, books, members, authors, publishers CASCADE;

CREATE TABLE publishers (
    publisher_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name         VARCHAR(30) NOT NULL UNIQUE,
    city         VARCHAR(10)
);

CREATE TABLE authors (
    author_id  INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    birth_year INT
);

CREATE TABLE books (
    book_id        INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    isbn           VARCHAR(20) UNIQUE,
    title          VARCHAR(50) NOT NULL,
    author_id      INT REFERENCES authors(author_id),
    publisher_id   INT REFERENCES publishers(publisher_id),
    category       VARCHAR(10) NOT NULL,
    published_year INT,
    price          INT,
    copies         INT NOT NULL DEFAULT 1
);

CREATE TABLE members (
    member_id   INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name        VARCHAR(20) NOT NULL,
    gender      CHAR(1) CHECK (gender IN ('男', '女')),
    member_type VARCHAR(4) NOT NULL CHECK (member_type IN ('一般', '學生', '銀髮')),
    city        VARCHAR(10),
    joined_on   DATE NOT NULL
);

CREATE TABLE loans (
    loan_id     INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    book_id     INT NOT NULL REFERENCES books(book_id),
    member_id   INT NOT NULL REFERENCES members(member_id),
    loan_date   DATE NOT NULL,
    due_date    DATE NOT NULL,
    return_date DATE,
    CHECK (due_date > loan_date)
);

COMMENT ON TABLE publishers IS '出版社(虛構)';
COMMENT ON TABLE authors    IS '作者(虛構)';
COMMENT ON TABLE books      IS '館藏書籍(書名皆為虛構)';
COMMENT ON COLUMN books.copies IS '館藏冊數';
COMMENT ON TABLE members    IS '借書證會員';
COMMENT ON COLUMN members.member_type IS '一般借期 14 天、學生 21 天、銀髮 28 天';
COMMENT ON TABLE loans      IS '借閱紀錄(2025-01 ~ 2026-09)';
COMMENT ON COLUMN loans.return_date IS '歸還日期,NULL 代表尚未歸還';

"""
    sql += insert("publishers", ["publisher_id", "name", "city"], [(i + 1,) + p for i, p in enumerate(publishers)])
    sql += insert("authors", ["author_id", "name", "birth_year"], authors)
    sql += insert("books", ["book_id", "isbn", "title", "author_id", "publisher_id", "category", "published_year",
                            "price", "copies"], books)
    sql += insert("members", ["member_id", "name", "gender", "member_type", "city", "joined_on"], members)
    sql += insert("loans", ["loan_id", "book_id", "member_id", "loan_date", "due_date", "return_date"],
                  [tuple(l) for l in loans])
    sql += "\n" + "".join(reset_identity(t, c) for t, c in [
        ("publishers", "publisher_id"), ("authors", "author_id"), ("books", "book_id"),
        ("members", "member_id"), ("loans", "loan_id")])
    sql += FOOTER
    return sql


if __name__ == "__main__":
    for name, fn in [("shop.sql", build_shop), ("school.sql", build_school),
                     ("library.sql", build_library)]:
        path = OUT / name
        path.write_text(fn(), encoding="utf-8")
        print(f"{name}: {path.stat().st_size / 1024:.0f} KB")
