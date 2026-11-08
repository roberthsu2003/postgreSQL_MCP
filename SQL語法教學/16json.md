# DML-6｜JSONB：飲料客製化這種「每筆都不一樣」的資料

> 💻 DBeaver（資料庫：`cafe_db`）｜ 🎯 學完你會：存 JSON、取值、用條件查詢，也知道什麼時候不該用

## 🎬 情境

點飲料時，每杯的要求都不同：

- 拿鐵：半糖、微冰、換燕麥奶、自備環保杯
- 美式：無糖、正常冰
- 黑糖拿鐵：全糖、熱的、加肉桂粉和雙倍濃縮

如果每種要求都開一個欄位，表會多出幾十個幾乎都是空的欄位。這種**每筆內容都不同**的資料，適合放進 `JSONB` 欄位。

## 1. JSON 長什麼樣？

就是一組「名稱：內容」：

```json
{"sugar": "半糖", "ice": "微冰", "bring_cup": true}
```

PostgreSQL 有兩種型別：**選 `JSONB` 就對了**。

| 型別 | 儲存方式 | 查詢速度 | 建議 |
|---|---|---|---|
| `JSON` | 原文照存 | 較慢 | 只想原樣保留內容時才用 |
| `JSONB` | 轉成二進位 | 快，還可建索引 | **一般都用這個** |

## 2. 建表與寫入

```sql
CREATE TABLE coffee_orders (
    order_id      SERIAL PRIMARY KEY,
    item_name     VARCHAR(50) NOT NULL,
    base_price    INT NOT NULL,
    customization JSONB
);

INSERT INTO coffee_orders (item_name, base_price, customization) VALUES
('經典拿鐵', 95,  '{"sugar": "半糖", "ice": "微冰", "milk": "燕麥奶", "bring_cup": true}'),
('美式咖啡', 70,  '{"sugar": "無糖", "ice": "正常冰", "bring_cup": false}'),
('黑糖拿鐵', 135, '{"sugar": "全糖", "ice": "熱", "toppings": ["肉桂粉", "雙倍濃縮"], "bring_cup": true}');
```

## 3. 取值：-> 和 ->>

| 符號 | 回傳 | 記法 |
|---|---|---|
| `->` | JSON（文字會帶雙引號） | 一個箭頭，還是 JSON |
| `->>` | 純文字 | 兩個箭頭，取到底 |

```sql
SELECT
    item_name,
    customization->'sugar'  AS 一個箭頭,
    customization->>'sugar' AS 兩個箭頭,
    customization->>'milk'  AS 換奶
FROM coffee_orders;
```

**執行結果**

| item_name | 一個箭頭 | 兩個箭頭 | 換奶 |
|---|---|---|---|
| 經典拿鐵 | 半糖 | 半糖 | 燕麥奶 |
| 美式咖啡 | 無糖 | 無糖 | *NULL* |
| 黑糖拿鐵 | 全糖 | 全糖 | *NULL* |

沒有 `milk` 的那幾筆顯示 `NULL`，不會報錯。

## 4. 用 JSON 內容當條件

**自備環保杯的訂單**，可以折 5 元。`->>` 取出來是文字，要用 `::BOOLEAN` 轉型：

```sql
SELECT item_name, base_price - 5 AS 折扣後
FROM coffee_orders
WHERE (customization->>'bring_cup')::BOOLEAN = true;
```

**執行結果**

| item_name | 折扣後 |
|---|---:|
| 經典拿鐵 | 90 |
| 黑糖拿鐵 | 130 |

**有加料的訂單**：`?` 用來檢查某個名稱是否存在：

```sql
SELECT item_name, customization->'toppings' AS 加料
FROM coffee_orders
WHERE customization ? 'toppings';
```

**執行結果**

| item_name | 加料 |
|---|---|
| 黑糖拿鐵 | `["肉桂粉", "雙倍濃縮"]` |

## 5. 修改 JSON 裡的一個值

顧客改成去冰。`jsonb_set` 可以只改其中一項：

```sql
UPDATE coffee_orders
SET customization = jsonb_set(customization, '{ice}', '"去冰"')
WHERE order_id = 1
RETURNING customization->>'ice' AS 冰塊;
```

**執行結果**

| 冰塊 |
|---|
| 去冰 |

新值要寫成 JSON 格式，所以文字外面是 `'"去冰"'`，單引號裡面還有雙引號。

## 6. 什麼時候不該用 JSONB？

| 情況 | 建議 |
|---|---|
| 每筆都有，而且常拿來篩選或計算（金額、日期） | ❌ 開正常欄位 |
| 要和其他表關聯 | ❌ 開正常欄位加外來鍵 |
| 內容不固定，每筆差很多（客製備註、設定值） | ✅ 用 `JSONB` |

> [!TIP]
> 不確定時，先用正常欄位。JSONB 是處理例外情況的工具，不是用來偷懶省略資料表設計的。

## ⚠️ 常見卡關

| 問題 | 原因 | 怎麼解 |
|---|---|---|
| `invalid input syntax for type json` | JSON 裡用了單引號，或多了逗號 | JSON 內部一律雙引號，外層才用單引號 |
| `operator does not exist: text > integer` | `->>` 取出來是文字 | 加上轉型，如 `(x->>'qty')::INT` |
| 比對不到值 | 用了 `->` 比對文字 | 改用 `->>` |
| DBeaver 把 `?` 當成參數 | 工具把 `?` 當佔位符 | 改用 `jsonb_exists(customization, 'toppings')` |

## ✍️ 動手練

**第 1 題**：查出所有「無糖」的訂單品名。

<details>
<summary>看答案</summary>

```sql
SELECT item_name
FROM coffee_orders
WHERE customization->>'sugar' = '無糖';
```

**執行結果**

| item_name |
|---|
| 美式咖啡 |

</details>

**第 2 題**：統計自備環保杯的杯數和總杯數。

<details>
<summary>看答案</summary>

```sql
SELECT
    COUNT(*) FILTER (WHERE (customization->>'bring_cup')::BOOLEAN) AS 自備杯數,
    COUNT(*) AS 總杯數
FROM coffee_orders;
```

**執行結果**

| 自備杯數 | 總杯數 |
|---:|---:|
| 2 | 3 |

`FILTER` 的意思是「只算符合條件的」。

</details>

## 🤖 問 AI 助教

> 我們要記錄設備的規格，筆電有 CPU 和記憶體，投影機有流明和解析度，規格差很多。請分析這適不適合用 JSONB，並比較另外開欄位的做法，給我建表語法讓我自己執行。

## ✅ 過關檢查

- [ ] 我分得清楚 `->` 和 `->>`
- [ ] 我知道 `->>` 取出來是文字，比較數字要轉型
- [ ] 我能判斷一個欄位該不該用 JSONB

> 🎉 **DML 全部完成！** 休息一下。接著要學把 Excel 拆成多張表的思維。

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ DML-5 JOIN](./JOIN.md) | [🏠 第 4 章目錄](../README.md#4-sql-語法與實戰練功) | [觀念：Excel 到正規化 ➡️](./../範例資料庫/從Excel到關聯資料庫_正規化.md) |
