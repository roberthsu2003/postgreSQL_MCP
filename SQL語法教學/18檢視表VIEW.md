# 進階-11｜檢視表 VIEW：把常用查詢存成一張「虛擬表」

> 💻 DBeaver（`cafe_shop`，第 6 節用 `cafe_perf`）｜ 📄 練習腳本：[`18檢視表VIEW.sql`](./18檢視表VIEW.sql) ｜ 🎯 學完你會：建立與修改 VIEW、用 VIEW 藏起敏感欄位再交給 AI，並分辨一般 VIEW 和物化檢視表

## 🎬 情境

王經理每週一都要看「訂單明細報表」：哪天、哪家店、誰買了什麼、花了多少。

這份報表要 JOIN 五張表，你每次都從筆記複製一大段 SQL 貼上。隔壁的小陳也要用，又複製了一份；後來規則改了，兩份 SQL 就對不起來了。

在 Excel 裡，你會把整理好的報表存成一張工作表。在資料庫裡，對應的做法就是 **VIEW（檢視表）**：

```mermaid
flowchart LR
    A["一大段 JOIN 查詢"] -->|"CREATE VIEW<br>取一個名字"| B["v_order_details"]
    B --> C["王經理：SELECT * FROM v_order_details"]
    B --> D["AI（MCP）：只看得到這張"]
    B --> E["第 5 章的 App：直接讀這張"]
```

> [!NOTE]
> **VIEW 只存「查詢語句」，不存資料。** 每次查 VIEW，資料庫都會重新跑一次裡面的 SELECT，所以結果永遠是最新的。

## 1. VIEW 和資料表有什麼不同

| | 資料表 TABLE | 檢視表 VIEW |
|---|---|---|
| 存什麼 | 真正的資料 | 一句 SELECT |
| 查詢方式 | `SELECT * FROM orders` | `SELECT * FROM v_order_details`，寫法完全一樣 |
| 原表改了 | — | 立刻反映，不用更新 |
| Excel 比喻 | 原始資料工作表 | 用公式參照原始資料的報表工作表 |

> [!TIP]
> 習慣在 VIEW 名稱前加 `v_`，在 DBeaver 和 AI 的眼裡一看就知道它不是資料表。

## 2. CREATE VIEW：把五表 JOIN 存起來

```sql
CREATE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

| 寫法 | 白話 |
|---|---|
| `CREATE VIEW v_order_details AS` | 把後面這句 SELECT 存起來，取名 `v_order_details` |
| `COALESCE(c.name, '散客')` | 散客沒有會員資料，名字是 `NULL`，改顯示「散客」 |
| `LEFT JOIN customers` | 散客的訂單也要留著，所以用 `LEFT JOIN`（[DML-5 JOIN](./JOIN.md)） |

建好之後，在 DBeaver 左邊重新整理，會在 **Views** 資料夾看到它。

**像查資料表一樣查它：**

```sql
SELECT *
FROM v_order_details
WHERE 日期 = '2024-02-14'
ORDER BY 訂單編號, 商品;
```

**執行結果**

| 訂單編號 | 日期 | 門市 | 顧客 | 商品 | 數量 | 單價 | 小計 | 狀態 |
|---:|---|---|---|---|---:|---:|---:|---|
| 159 | 2024-02-14 | 台中逢甲店 | 散客 | 燻雞雙起司三明治 | 1 | 85 | 85 | 已退款 |
| 188 | 2024-02-14 | 高雄巨蛋店 | 散客 | 法式經典可頌 | 1 | 65 | 65 | 已完成 |
| 188 | 2024-02-14 | 高雄巨蛋店 | 散客 | 翡翠檸檬綠 | 1 | 60 | 60 | 已完成 |
| 320 | 2024-02-14 | 台中逢甲店 | 散客 | 焦糖瑪奇朵 | 2 | 120 | 240 | 已完成 |
| 321 | 2024-02-14 | 台中逢甲店 | 謝哲瑋 | 焦糖瑪奇朵 | 2 | 120 | 240 | 已退款 |
| 321 | 2024-02-14 | 台中逢甲店 | 謝哲瑋 | 燻雞雙起司三明治 | 1 | 85 | 85 | 已退款 |
| 321 | 2024-02-14 | 台中逢甲店 | 謝哲瑋 | 翡翠檸檬綠 | 1 | 60 | 60 | 已退款 |

**後面一樣可以接 `GROUP BY`：**

```sql
SELECT 門市, SUM(小計) AS 營業額
FROM v_order_details
WHERE 狀態 = '已完成'
GROUP BY 門市
ORDER BY 營業額 DESC;
```

**執行結果**

| 門市 | 營業額 |
|---|---:|
| 台中逢甲店 | 18795 |
| 高雄巨蛋店 | 16440 |
| 台北信義店 | 16170 |
| 新竹巨城店 | 15365 |
| 台北車站店 | 14215 |

一行 JOIN 都沒寫，就得到和[進階-4 聚合與分組](./10聚合函式.md)一樣的報表。**複雜的部分寫一次，大家重複使用。**

## 3. VIEW 不存資料：原表一改，VIEW 立刻跟著變

用交易試試看，最後 `ROLLBACK` 還原：

```sql
BEGIN;

UPDATE stores SET name = '台北信義旗艦店' WHERE store_id = 1;

SELECT DISTINCT 門市
FROM v_order_details
ORDER BY 門市;

ROLLBACK;
```

**執行結果**（`ROLLBACK` 之前）

| 門市 |
|---|
| 台中逢甲店 |
| 台北信義旗艦店 |
| 台北車站店 |
| 新竹巨城店 |
| 高雄巨蛋店 |

我們沒有動 VIEW，它卻馬上顯示新店名，因為 VIEW 每次都是即時去原表查。這也是 VIEW 和「把查詢結果複製到另一張表」最大的差別：**不會有兩份資料對不起來的問題。**

## 4. 修改與刪除 VIEW

### 在最後面加欄位：用 `CREATE OR REPLACE`

王經理想多看「付款方式」：

```sql
CREATE OR REPLACE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態,
    o.payment_method              AS 付款方式   -- 新欄位加在最後
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;
```

**執行結果**：`CREATE VIEW`

### ❌ 把欄位插在中間、刪掉欄位：會報錯

如果把「時間」插在「訂單編號」和「日期」中間，會看到：

```text
ERROR: cannot change name of view column "日期" to "時間"
HINT:  Use ALTER VIEW ... RENAME COLUMN ... to change name of view column instead.
```

拿掉欄位則會看到 `cannot drop columns from view`。

| 想做的事 | `CREATE OR REPLACE VIEW` 可以嗎 | 怎麼辦 |
|---|:---:|---|
| 在最後加欄位 | ✅ | 直接改 |
| 改計算方式，欄位名稱、型別不變 | ✅ | 直接改 |
| 中間插欄位、刪欄位、改型別 | ❌ | 先 `DROP VIEW`，再 `CREATE VIEW` |
| 只改欄位名稱 | ❌ | `ALTER VIEW v_order_details RENAME COLUMN 舊名 TO 新名;` |

刪除 VIEW 不會影響原表的任何資料（**先不要執行**，後面還會用到這個 VIEW）：

```sql
DROP VIEW v_order_details;
```

### VIEW 會保護它用到的欄位

有了 VIEW 之後，試著刪掉 `customers.name`：

```sql
ALTER TABLE customers DROP COLUMN name;
```

**執行結果**

```text
ERROR:  cannot drop column name of table customers because other objects depend on it
DETAIL:  view v_order_details depends on column name of table customers
HINT:  Use DROP ... CASCADE to drop the dependent objects too.
```

資料庫知道 VIEW 正在用這個欄位，所以擋下來。查某個 VIEW 用到哪些表：

```sql
SELECT DISTINCT table_name AS 用到的資料表
FROM information_schema.view_table_usage
WHERE view_name = 'v_order_details'
ORDER BY table_name;
```

**執行結果**

| 用到的資料表 |
|---|
| customers |
| order_items |
| orders |
| products |
| stores |

> [!CAUTION]
> **HINT 叫你加 `CASCADE`，先停下來。** 就像[進階-9 ON DELETE](./15on_delete_action.md) 的 `CASCADE`，它會把依賴的 VIEW 一起刪掉，別人每天在用的報表就這樣消失了。先查依賴、預測後果，再決定。

## 5. 用 VIEW 藏起敏感欄位，再交給 AI

第 3 章我們讓 AI 透過 MCP 直接查資料庫。但 `customers` 有會員電話、`staff` 有薪水，**你真的想讓 AI 看到全部嗎？**

VIEW 可以只露出需要的欄位，甚至遮掉一部分：

```sql
CREATE VIEW v_customer_public AS
SELECT
    customer_id                                   AS 會員編號,
    name                                          AS 姓名,
    LEFT(phone, 4) || '-***-' || RIGHT(phone, 3)  AS 電話,
    gender                                        AS 性別,
    joined_on                                     AS 加入日期
FROM customers;

SELECT * FROM v_customer_public ORDER BY 會員編號 LIMIT 3;
```

**執行結果**

| 會員編號 | 姓名 | 電話 | 性別 | 加入日期 |
|---:|---|---|---|---|
| 1 | 張美玲 | 0970-\*\*\*-845 | 女 | 2023-01-18 |
| 2 | 吳柏翰 | 0984-\*\*\*-305 | 男 | 2023-02-04 |
| 3 | 楊雅婷 | 0962-\*\*\*-833 | 女 | 2023-02-21 |

員工通訊錄也一樣，不放薪水：

```sql
CREATE VIEW v_staff_directory AS
SELECT s.name AS 姓名, st.name AS 門市, s.title AS 職稱
FROM staff s
JOIN stores st ON s.store_id = st.store_id;
```

### 建立「只能看 VIEW」的帳號

光有 VIEW 不夠，AI 用的帳號如果能直接查 `customers`，藏了也沒用。

第 5 章實戰專案的 `ai_readonly` 帳號用的是 `GRANT SELECT ON ALL TABLES`，所有資料表都看得到。這裡更嚴格：另外開一個帳號，**只授權 VIEW**：

```sql
CREATE ROLE mcp_reader LOGIN PASSWORD 'change_me_123';
GRANT CONNECT ON DATABASE cafe_shop TO mcp_reader;
GRANT USAGE ON SCHEMA public TO mcp_reader;
GRANT SELECT ON v_order_details, v_customer_public, v_staff_directory TO mcp_reader;
```

| 寫法 | 白話 |
|---|---|
| `CREATE ROLE ... LOGIN PASSWORD` | 建立一個可以登入的帳號 |
| `GRANT CONNECT ON DATABASE` | 允許連進 `cafe_shop` |
| `GRANT USAGE ON SCHEMA public` | 允許看到 `public` 裡的東西 |
| `GRANT SELECT ON v_...` | **只**允許查這三個 VIEW，其他一律不行 |

用 `SET ROLE` 模擬這個帳號：

```sql
SET ROLE mcp_reader;

SELECT * FROM v_staff_directory LIMIT 3;   -- ✅
SELECT * FROM customers LIMIT 3;           -- ❌
SELECT salary FROM staff LIMIT 3;          -- ❌

RESET ROLE;
```

**執行結果**

| 姓名 | 門市 | 職稱 |
|---|---|---|
| 張志明 | 台北信義店 | 店長 |
| 陳美玲 | 台北信義店 | 正職咖啡師 |
| 林家豪 | 台北信義店 | 工讀生 |

```text
ERROR:  permission denied for table customers
ERROR:  permission denied for table staff
```

`v_order_details` 裡面明明有用到 `customers`，為什麼 `mcp_reader` 查得到？因為 VIEW 預設用**建立者**的權限去讀原表。使用者只要有 VIEW 的權限就好，碰不到原表。

**接到 MCP：** 把第 3 章 MCP 設定裡的連線字串，帳號密碼換成這個帳號：

```text
postgresql://mcp_reader:change_me_123@localhost:5432/cafe_shop
```

之後不管你怎麼問 AI，它都只看得到這三張 VIEW。

> [!WARNING]
> - 密碼 `change_me_123` 只是示範，正式環境請換成強密碼，也不要把連線字串上傳到 GitHub。
> - 用完要收拾，回到 `postgres` 帳號執行：`DROP OWNED BY mcp_reader; DROP ROLE mcp_reader;`
> - 雲端資料庫（例如 Supabase）建立帳號的方式可能不同，請以平台文件為準。

## 6. 物化檢視表 MATERIALIZED VIEW：把結果先算好存起來

一般 VIEW 每次都重新查，資料很多時就會慢。**物化檢視表（MATERIALIZED VIEW）** 會把結果真的存起來，像一張快照。

切換到[進階-10](./17索引與效能.md)建立的 `cafe_perf`（5 萬筆訂單），先看直接算「各門市每月營業額」要多久：

```sql
EXPLAIN ANALYZE
SELECT s.name AS 門市,
       DATE_TRUNC('month', o.order_date)::date AS 月份,
       SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s      ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name, 月份;
```

**執行結果（節錄）**：`Execution Time: 78.886 ms`

把同一句存成物化檢視表：

```sql
CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT s.name AS 門市,
       DATE_TRUNC('month', o.order_date)::date AS 月份,
       SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s      ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name, 月份;

EXPLAIN ANALYZE
SELECT * FROM mv_monthly_sales;
```

**執行結果（節錄）**

```text
Seq Scan on mv_monthly_sales  (actual time=0.002..0.004 rows=60 loops=1)
Execution Time: 0.009 ms
```

| | 一般查詢 | 物化檢視表 |
|---|---|---|
| 做了什麼 | 掃 10 萬筆明細、JOIN、分組 | 直接讀 60 列算好的結果 |
| 執行時間 | 約 79 ms | 約 0.01 ms |

### 代價：資料不會自動更新

先記下台北信義店 12 月的營業額，再新增一筆 12 月大訂單（美式咖啡 100 杯）：

```sql
SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';

WITH new_order AS (
    INSERT INTO orders (order_date, order_time, store_id, staff_id, customer_id, payment_method, status)
    VALUES ('2024-12-31', '10:00', 1, 1, NULL, '現金', '已完成')
    RETURNING order_id
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT order_id, 1, 100, 70 FROM new_order;

SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';
```

**執行結果**：新增前後都是 `226285`，數字沒變！

物化檢視表是快照，要手動重新整理：

```sql
REFRESH MATERIALIZED VIEW mv_monthly_sales;

SELECT * FROM mv_monthly_sales
WHERE 門市 = '台北信義店' AND 月份 = '2024-12-01';
```

**執行結果**：`233285`，剛好多了 100 × 70 = 7000。

> [!NOTE]
> `cafe_perf` 的訂單是隨機產生的，你的營業額和時間會不一樣。重點是**時間的差距**和**重新整理前後的差 7000**。

| | 一般 VIEW | 物化檢視表 |
|---|---|---|
| 存什麼 | 查詢語句 | 查詢**結果** |
| 資料新不新 | 永遠最新 | 停在上次 `REFRESH` |
| 速度 | 和原查詢一樣 | 很快 |
| 適合 | 日常報表、隱藏欄位、給 AI 和 App 用 | 資料量大、可接受「昨天的數字」的月報、儀表板 |

## 7. VIEW、WITH、暫存表，該用哪個？

| | `WITH`（[進階-8](./14子查詢.md)） | VIEW | 暫存表 / 另建一張表 |
|---|---|---|---|
| 存活多久 | 這一句查詢結束就消失 | 永久，直到 `DROP VIEW` | 暫存表到斷線為止；一般表永久 |
| 誰能用 | 只有這一句 | 所有有權限的人、AI、App | 暫存表只有自己 |
| 資料新不新 | 最新 | 最新 | 複製當下的資料，之後不會變 |
| 適合 | 一次性分析 | **會一直重複用的查詢** | 資料清洗、匯入過渡（專案 8） |

**判斷口訣：這個查詢下週還會用、別人也會用 → 存成 VIEW。**

## 8. 其他部門也用得上

**會計（`expense_tracker`）：待處理報銷總表**

```sql
CREATE VIEW v_pending_claims AS
SELECT x.claim_id AS 單號, x.claim_date AS 日期, e.name AS 申請人,
       c.name AS 類別, x.amount AS 金額, x.status AS 狀態
FROM expense_claims x
JOIN expense_employees e  ON x.emp_id = e.emp_id
JOIN expense_categories c ON x.category_id = c.category_id
WHERE x.status IN ('待審核', '待撥款');

SELECT * FROM v_pending_claims ORDER BY 日期;
```

**執行結果**

| 單號 | 日期 | 申請人 | 類別 | 金額 | 狀態 |
|---|---|---|---|---:|---|
| EXP20240309 | 2024-03-18 | 周美玲 | 長途交通 | 2980.00 | 待撥款 |
| EXP20240310 | 2024-03-20 | 周美玲 | 差旅住宿 | 2200.00 | 待撥款 |
| EXP20240312 | 2024-03-25 | 黃雅婷 | 商務餐敘 | 2500.00 | 待審核 |
| EXP20240313 | 2024-03-28 | 陳小華 | 市區交通 | 320.00 | 待審核 |

**總務（`assets_inventory`）：需要補貨的品項**

```sql
CREATE VIEW v_low_stock AS
SELECT name AS 品項, current_stock AS 庫存, safety_stock AS 安全存量,
       safety_stock - current_stock AS 至少要補
FROM assets
WHERE current_stock < safety_stock;

SELECT * FROM v_low_stock ORDER BY 至少要補 DESC, 品項;
```

**執行結果**

| 品項 | 庫存 | 安全存量 | 至少要補 |
|---|---:|---:|---:|
| Double A A4 70g 影印紙(箱) | 3 | 5 | 2 |
| HP LaserJet 原廠黑色碳粉匣 | 1 | 2 | 1 |
| MacBook Pro 14吋 M3 | 0 | 1 | 1 |
| 無線便攜雷射投影機 | 0 | 1 | 1 |

總務每天打開 DBeaver 點一下 `v_low_stock` 就知道要買什麼，不用記任何 SQL。

> [!NOTE]
> **VIEW 能不能拿來 UPDATE？** 只從**一張表**查出來、沒有 `GROUP BY`、`DISTINCT` 的簡單 VIEW 可以，改的是背後的原表。像 `v_order_details` 這種 JOIN 多表的就不行（`cannot update view`）。如果要限制「透過 VIEW 改的資料，改完還要符合 VIEW 的條件」，可以在最後加 `WITH CHECK OPTION`。實務上 VIEW 主要拿來**讀**，修改還是直接對原表做比較清楚。

## ⚠️ 常見卡關

| 錯誤訊息或現象 | 原因 | 怎麼解 |
|---|---|---|
| `relation "v_order_details" already exists` | 已經建過 | 改用 `CREATE OR REPLACE VIEW`，或先 `DROP VIEW` |
| `cannot change name of view column` | 欄位插在中間或改了名稱 | 新欄位放最後；不然先 `DROP VIEW` 再重建 |
| `cannot drop columns from view` | 新版 VIEW 少了欄位 | 先 `DROP VIEW` 再重建 |
| `cannot drop column ... because other objects depend on it` | 原表欄位被 VIEW 用到 | 先查依賴、改 VIEW，不要直接 `CASCADE` |
| `cannot update view` | VIEW 用了多張表或 `GROUP BY` | 直接修改原表 |
| `permission denied for view ...` | 帳號沒被授權這個 VIEW | 用管理者帳號 `GRANT SELECT ON 該VIEW TO 帳號` |
| 物化檢視表的數字是舊的 | 沒有重新整理 | `REFRESH MATERIALIZED VIEW 名稱;` |
| DBeaver 左邊看不到 VIEW | 沒有重新整理 | 在 **Views** 資料夾按右鍵 → **Refresh**（F5） |

## ✍️ 動手練

**第 1 題**：建立 `v_product_margin`，列出分類、商品、售價、成本、毛利、毛利率（%，四捨五入到小數 1 位），再查毛利最高的 3 項。

<details>
<summary>看答案</summary>

```sql
CREATE VIEW v_product_margin AS
SELECT c.name AS 分類, p.name AS 商品, p.price AS 售價, p.cost AS 成本,
       p.price - p.cost AS 毛利,
       ROUND((p.price - p.cost) * 100.0 / p.price, 1) AS 毛利率
FROM products p
JOIN categories c ON p.category_id = c.category_id;

SELECT * FROM v_product_margin ORDER BY 毛利 DESC, 商品 LIMIT 3;
```

**執行結果**

| 分類 | 商品 | 售價 | 成本 | 毛利 | 毛利率 |
|---|---|---:|---:|---:|---:|
| 義式咖啡 | 冰滴咖啡 | 150 | 60 | 90 | 60.0 |
| 現烤點心 | 草莓生乳千層 | 140 | 55 | 85 | 60.7 |
| 義式咖啡 | 燕麥奶拿鐵 | 130 | 50 | 80 | 61.5 |

`100.0` 要有小數點，不然整數相除會被捨去成 0。

</details>

**第 2 題（陷阱題）**：小陳用 `v_order_details` 查「消費最多的 3 位會員」，寫了下面這句。結果哪裡不對？要怎麼修？

```sql
SELECT 顧客, SUM(小計) AS 消費總額
FROM v_order_details
WHERE 狀態 = '已完成' AND 顧客 <> '散客'
GROUP BY 顧客
ORDER BY 消費總額 DESC
LIMIT 3;
```

| 顧客 | 消費總額 |
|---|---:|
| 謝哲瑋 | 5125 |
| 林佩珊 | 4285 |
| 張美玲 | 3475 |

<details>
<summary>看答案</summary>

`cafe_shop` 裡有很多**同名的會員**（例如有 3 位「謝哲瑋」），用姓名分組會把不同人的錢加在一起。VIEW 裡沒有會員編號，所以要先把它加到**最後面**：

```sql
CREATE OR REPLACE VIEW v_order_details AS
SELECT
    o.order_id                    AS 訂單編號,
    o.order_date                  AS 日期,
    s.name                        AS 門市,
    COALESCE(c.name, '散客')      AS 顧客,
    p.name                        AS 商品,
    i.quantity                    AS 數量,
    i.unit_price                  AS 單價,
    i.quantity * i.unit_price     AS 小計,
    o.status                      AS 狀態,
    o.payment_method              AS 付款方式,
    o.customer_id                 AS 會員編號
FROM orders o
JOIN stores s       ON o.store_id = s.store_id
JOIN order_items i  ON o.order_id = i.order_id
JOIN products p     ON i.product_id = p.product_id
LEFT JOIN customers c ON o.customer_id = c.customer_id;

SELECT 會員編號, 顧客, SUM(小計) AS 消費總額
FROM v_order_details
WHERE 狀態 = '已完成' AND 會員編號 IS NOT NULL
GROUP BY 會員編號, 顧客
ORDER BY 消費總額 DESC, 會員編號
LIMIT 3;
```

**執行結果**

| 會員編號 | 顧客 | 消費總額 |
|---:|---|---:|
| 24 | 謝哲瑋 | 2530 |
| 7 | 林佩珊 | 2335 |
| 22 | 吳柏翰 | 1635 |

第一名的實際消費只有 2530，不是 5125。**設計 VIEW 時，記得把主鍵也放進去**，之後才分得出「同名不同人」。

</details>

**第 3 題**：把[進階-8](./14子查詢.md) 動手練第 3 題的「門市業績」從 `WITH` 改成 VIEW，再列出高於平均的門市。

<details>
<summary>看答案</summary>

```sql
CREATE VIEW v_store_sales AS
SELECT 門市, SUM(小計) AS 營業額
FROM v_order_details
WHERE 狀態 = '已完成'
GROUP BY 門市;

SELECT 門市, 營業額
FROM v_store_sales
WHERE 營業額 > (SELECT AVG(營業額) FROM v_store_sales)
ORDER BY 營業額 DESC;
```

**執行結果**

| 門市 | 營業額 |
|---|---:|
| 台中逢甲店 | 18795 |
| 高雄巨蛋店 | 16440 |

VIEW 可以建在另一個 VIEW 上面，一層一層疊。但不要疊太多層，出錯時會很難追。

</details>

## 🤖 問 AI 助教

> 這是我們公司資料庫的結構：（貼上 DDL）。我想讓 AI 透過 MCP 查詢資料，但不能看到個資和薪資。請幫我設計 2～3 個 VIEW，並寫出只授權這些 VIEW 的唯讀帳號 SQL，說明每個 VIEW 藏了哪些欄位、為什麼。請不要執行，我會自己在 DBeaver 檢查後執行。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 進階-10 索引與效能](./17索引與效能.md) | [🏠 第 4 章目錄](./README.md) | [進階-12 AI 助教 ➡️](./關聯資料庫實作_用Prompt操作.md) |
