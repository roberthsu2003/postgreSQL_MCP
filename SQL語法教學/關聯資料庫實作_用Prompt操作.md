# 進階-11｜AI 助教：問得好，還要驗得出來

> 💻 DBeaver 加上 AI 工具 ｜ 🎯 學完你會：寫出好的提問、抓出 AI 的錯誤，並完成第 4 章結業挑戰

## 🎬 情境

SQL 學完了，以後大可以叫 AI 寫。但 **AI 會寫錯，而且錯的 SQL 看起來跟對的一樣**。這一課就是要你當得了 AI 的主管。

## 1. 提問公式

| 元素 | 範例 |
|---|---|
| **資料庫** | 我的 `cafe_shop` 資料庫，請先用 MCP 查看結構 |
| **問題** | 各門市 3 月的營業額 |
| **條件** | 只算已完成的訂單 |
| **輸出** | 依營業額由高到低，欄位用中文 |
| **規範** | 只給 SQL 和逐行說明，我自己在 DBeaver 執行 |

```text
❌ 不好的問法：幫我查業績。

✅ 好的問法：我的 cafe_shop 資料庫，請先用 MCP 查看結構。
請寫出 2024 年 3 月各門市的營業額，只算已完成的訂單，
依金額由高到低排序，欄位用中文。
請只給我 SQL 和逐行說明，我會自己在 DBeaver 執行。
```

## 2. 驗收四問

拿到 AI 的 SQL 後，**先問這四題再執行**：

1. **表和欄位真的存在嗎？** AI 常用猜的，例如 `city`、`total_amount`。
2. **條件有寫對嗎？** 退款有沒有排除？`UPDATE`、`DELETE` 有 `WHERE` 嗎？
3. **JOIN 有放大資料嗎？** 訂單接明細後，訂單數還對嗎？
4. **結果合理嗎？** 用另一種方式驗算，或和 Excel 比對。

## 3. 抓錯遊戲

下面每一段都是 AI 可能給的答案。**先自己找錯，再看解析。**

### 第 1 關：「各門市有幾張訂單？」

```sql
SELECT s.city, COUNT(*) FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY s.city;
```

<details>
<summary>哪裡錯了？</summary>

`stores` 沒有 `city` 欄位，只有 `region`。AI 沒看結構就用猜的。解法：提問時要求「先用 MCP 查看結構」。

</details>

### 第 2 關：「第一季總營業額多少？」

```sql
SELECT SUM(quantity * unit_price) AS 總營業額 FROM order_items;
```

**執行結果**

| 總營業額 |
|---:|
| 97655 |

<details>
<summary>哪裡錯了？</summary>

可以執行，數字也很漂亮，但**把退款也算進去了**。正確答案：

```sql
SELECT SUM(i.quantity * i.unit_price) AS 總營業額
FROM order_items i
JOIN orders o ON i.order_id = o.order_id
WHERE o.status = '已完成';
```

**執行結果**

| 總營業額 |
|---:|
| 80985 |

差了不少。最危險的錯誤，就是這種**不會報錯**的錯。

</details>

### 第 3 關：「每張訂單平均幾項商品？」

```sql
SELECT ROUND(AVG(cnt), 2) AS 平均品項數
FROM (SELECT o.order_id, COUNT(*) AS cnt FROM orders o, order_items i GROUP BY o.order_id) x
LIMIT 1;
```

**執行結果**

| 平均品項數 |
|---:|
| 782.00 |

<details>
<summary>哪裡錯了？</summary>

`FROM orders o, order_items i` 沒有連接條件，變成 CROSS JOIN：每張訂單配上全部 782 筆明細，所以算出 782。正確寫法：

```sql
SELECT ROUND(AVG(cnt), 2) AS 平均品項數
FROM (SELECT order_id, COUNT(*) AS cnt FROM order_items GROUP BY order_id) x;
```

**執行結果**

| 平均品項數 |
|---:|
| 1.60 |

**看到不合常理的數字，就要懷疑。**

</details>

### 第 4 關：「沒消費過的會員」

```sql
SELECT name FROM customers WHERE customer_id NOT IN (SELECT customer_id FROM orders);
```

<details>
<summary>哪裡錯了？</summary>

`orders.customer_id` 有 `NULL`，`NOT IN` 永遠查不到資料。要改用 `NOT EXISTS`，請見 [進階-8](./14子查詢.md)。

</details>

## 4. 各職務的練習

每一題都已實測可執行。先自己寫，或請 AI 寫，再對答案。

### ☕ 店長（`cafe_shop`）：跨月營收並排

<details>
<summary>看答案</summary>

```sql
SELECT
    s.name AS 門市,
    SUM(i.quantity * i.unit_price) FILTER (WHERE EXTRACT(MONTH FROM o.order_date) = 1) AS 一月,
    SUM(i.quantity * i.unit_price) FILTER (WHERE EXTRACT(MONTH FROM o.order_date) = 2) AS 二月,
    SUM(i.quantity * i.unit_price) FILTER (WHERE EXTRACT(MONTH FROM o.order_date) = 3) AS 三月
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.store_id, s.name
ORDER BY s.store_id;
```

**執行結果**

| 門市 | 一月 | 二月 | 三月 |
|---|---:|---:|---:|
| 台北信義店 | 3690 | 8005 | 4475 |
| 台北車站店 | 4425 | 5500 | 4290 |
| 新竹巨城店 | 2780 | 7440 | 5145 |
| 台中逢甲店 | 6205 | 6675 | 5915 |
| 高雄巨蛋店 | 4620 | 6520 | 5300 |

</details>

### 💼 會計（`expense_tracker`）：各部門各狀態的金額

<details>
<summary>看答案</summary>

```sql
SELECT
    d.name AS 部門,
    SUM(x.amount) FILTER (WHERE x.status = '待審核') AS 待審核,
    SUM(x.amount) FILTER (WHERE x.status = '已撥款') AS 已撥款,
    SUM(x.amount) AS 合計
FROM expense_claims x
JOIN expense_employees e   ON x.emp_id = e.emp_id
JOIN expense_departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.name
ORDER BY 合計 DESC;
```

**執行結果**

| 部門 | 待審核 | 已撥款 | 合計 |
|---|---:|---:|---:|
| 技術部 | *NULL* | 8350.00 | 11950.00 |
| 行銷部 | 2500.00 | 8780.00 | 11280.00 |
| 業務部 | 320.00 | 3430.00 | 8930.00 |
| 人事部 | *NULL* | 1200.00 | 1200.00 |

</details>

### 👥 人資（`hr_attendance`）：用 CASE WHEN 判斷出勤

<details>
<summary>看答案</summary>

```sql
SELECT
    e.name AS 員工,
    a.work_date AS 日期,
    CASE
        WHEN a.is_late AND a.overtime_hours > 0 THEN '遲到但有加班'
        WHEN a.is_late THEN '遲到'
        WHEN a.overtime_hours > 0 THEN '加班'
        ELSE '正常'
    END AS 判定
FROM hr_attendance_records a
JOIN hr_employees e ON a.emp_id = e.emp_id
ORDER BY a.work_date, e.emp_id;
```

**執行結果**

| 員工 | 日期 | 判定 |
|---|---|---|
| 陳小華 | 2024-03-01 | 正常 |
| 林志明 | 2024-03-01 | 遲到但有加班 |
| 黃雅婷 | 2024-03-01 | 正常 |
| 張大同 | 2024-03-01 | 正常 |
| 陳小華 | 2024-03-04 | 加班 |

`CASE WHEN` 就是 Excel 的 `IF`。

</details>

### 🏢 總務（`assets_inventory`）：需要補貨的清單

<details>
<summary>看答案</summary>

```sql
SELECT
    name AS 品項,
    current_stock AS 庫存,
    safety_stock AS 安全存量,
    safety_stock - current_stock AS 至少補貨量,
    location AS 位置
FROM assets
WHERE current_stock < safety_stock
ORDER BY 至少補貨量 DESC;
```

**執行結果**

| 品項 | 庫存 | 安全存量 | 至少補貨量 | 位置 |
|---|---:|---:|---:|---|
| Double A A4 70g 影印紙(箱) | 3 | 5 | 2 | 3F 總務庫房 B-01 |
| MacBook Pro 14吋 M3 | 0 | 1 | 1 | 4F IT庫房 |
| 無線便攜雷射投影機 | 0 | 1 | 1 | 5F 貴賓會議室 |
| HP LaserJet 原廠黑色碳粉匣 | 1 | 2 | 1 | 3F 總務庫房 C-03 |

</details>

### 🛒 業務（`shop`）：RFM 客戶分析

<details>
<summary>看答案</summary>

```sql
SELECT
    c.name AS 客戶,
    MAX(o.order_date) AS 最近下單,
    COUNT(DISTINCT o.order_id) AS 下單次數,
    SUM(i.quantity * i.unit_price) AS 消費總額
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY c.customer_id, c.name
ORDER BY 消費總額 DESC
LIMIT 5;
```

**執行結果**

| 客戶 | 最近下單 | 下單次數 | 消費總額 |
|---|---|---:|---:|
| 徐淑宜 | 2025-12-08 | 20 | 41369 |
| 曾恩志 | 2025-12-30 | 18 | 33663 |
| 李宏彥 | 2025-12-23 | 21 | 31594 |
| 江美瑜 | 2025-12-23 | 15 | 28796 |
| 陳偉建 | 2025-12-10 | 16 | 27297 |

R（最近一次）、F（頻率）、M（金額）是業務常用的客戶分級方法。

</details>

## 🏆 第 4 章結業挑戰

王經理要在季度會議上報告，請寫出下面五題。全部答對，第 4 章就過關了！

**1.** 第一季各門市的已完成訂單數和營業額，由高到低。

**2.** 第一季賣得最好的 5 項商品（看數量）。

**3.** 會員和散客各貢獻多少營業額？

**4.** 哪位店員的業績最高？任職於哪一家門市？

**5.** 哪些商品的毛利率（`(售價 - 成本) / 售價`）超過 70%？

<details>
<summary>第 1 題答案</summary>

```sql
SELECT s.name AS 門市, COUNT(DISTINCT o.order_id) AS 訂單數, SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY s.name
ORDER BY 營業額 DESC;
```

**執行結果**

| 門市 | 訂單數 | 營業額 |
|---|---:|---:|
| 台中逢甲店 | 91 | 18795 |
| 高雄巨蛋店 | 79 | 16440 |
| 台北信義店 | 82 | 16170 |
| 新竹巨城店 | 77 | 15365 |
| 台北車站店 | 83 | 14215 |

</details>

<details>
<summary>第 2 題答案</summary>

```sql
SELECT p.name AS 商品, SUM(i.quantity) AS 銷量
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN orders o ON i.order_id = o.order_id
WHERE o.status = '已完成'
GROUP BY p.name
ORDER BY 銷量 DESC
LIMIT 5;
```

**執行結果**

| 商品 | 銷量 |
|---|---:|
| 翡翠檸檬綠 | 78 |
| 焦糖瑪奇朵 | 65 |
| 珍珠醇奶茶 | 61 |
| 經典牛肉起司堡 | 60 |
| 美式咖啡 | 58 |

</details>

<details>
<summary>第 3 題答案</summary>

```sql
SELECT
    CASE WHEN o.customer_id IS NULL THEN '散客' ELSE '會員' END AS 客群,
    COUNT(DISTINCT o.order_id) AS 訂單數,
    SUM(i.quantity * i.unit_price) AS 營業額
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY 客群
ORDER BY 營業額 DESC;
```

**執行結果**

| 客群 | 訂單數 | 營業額 |
|---|---:|---:|
| 會員 | 278 | 52365 |
| 散客 | 134 | 28620 |

</details>

<details>
<summary>第 4 題答案</summary>

```sql
SELECT e.name AS 店員, s.name AS 門市, SUM(i.quantity * i.unit_price) AS 業績
FROM staff e
JOIN stores s ON e.store_id = s.store_id
JOIN orders o ON e.staff_id = o.staff_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.status = '已完成'
GROUP BY e.staff_id, e.name, s.name
ORDER BY 業績 DESC
LIMIT 1;
```

**執行結果**

| 店員 | 門市 | 業績 |
|---|---|---:|
| 郭俊宏 | 高雄巨蛋店 | 9525 |

</details>

<details>
<summary>第 5 題答案</summary>

```sql
SELECT name AS 商品, price AS 售價, cost AS 成本,
       ROUND((price - cost)::NUMERIC / price * 100, 1) AS 毛利率
FROM products
WHERE (price - cost)::NUMERIC / price > 0.7
ORDER BY 毛利率 DESC;
```

**執行結果**

| 商品 | 售價 | 成本 | 毛利率 |
|---|---:|---:|---:|
| 蜜香紅茶 | 50 | 12 | 76.0 |
| 翡翠檸檬綠 | 60 | 15 | 75.0 |
| 珍珠醇奶茶 | 65 | 18 | 72.3 |
| 美式咖啡 | 70 | 20 | 71.4 |
| 紅玉白桃烏龍 | 75 | 22 | 70.7 |

兩個整數相除會無條件捨去，所以要先用 `::NUMERIC` 轉型。

</details>

## ✅ 第 4 章結業檢查

- [ ] 我能寫出五要素俱全的提問
- [ ] 我會在執行前用驗收四問檢查 AI 的 SQL
- [ ] 抓錯遊戲四關，我至少自己抓到三關
- [ ] 結業挑戰五題，我不看答案能寫出至少四題

> 🎓 **恭喜完成第 4 章！** 下一章要把這些 SQL 用在真實的 Excel 上，做出自己的小工具。

## 🚀 接著做實戰專案

SQL 都學完了，可以把自己工作上的情境做成專案。

👉 **[實戰專案大綱](../app_projects/實戰專案大綱.md)**：查看五張 Excel 分別用到哪些章節，以及目前的製作進度。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 進階-10 索引與效能](./17索引與效能.md) | [🏠 第 4 章目錄](./README.md) | [第 5 章 實戰專案 ➡️](../app_projects/) |
