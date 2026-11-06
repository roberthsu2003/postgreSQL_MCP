# 單元 16：PostgreSQL 的 JSON / JSONB 彈性應用

在關聯式資料庫中，標準欄位（如姓名、價格、日期）結構嚴謹。但現代商業應用中，常有**「非固定欄位」**的需求——例如：每位顧客點咖啡時的**客製化備註**（甜度、冰塊、加料、自備環保杯等）。  
如果每有一種客製化就在資料表加一個欄位，表格會變得無比臃腫。  
**PostgreSQL 領先其他資料庫的超強特色，就是原生支援高效率的 `JSONB` 欄位！**

---

## 1. JSON 與 JSONB 的關鍵差異

| 型別名稱 | 儲存機制 | 查詢速度 | 索引支援 | 建議使用場景 |
|---|---|---|---|---|
| **`JSON`** | 原封不動存成字串 | 慢（每次查詢需重新解析字串） | 否 | 僅用於日誌紀錄 (Log) |
| **`JSONB`** | 轉為二進位 (Binary) 格式儲存 | **極速**（直接透過二進位跳轉讀取） | **支援 GIN 索引** | **所有商業業務首選！** |

---

## 2. ☕ 連鎖門市實戰：飲品客製化與外帶備註

在訂單明細表 (`order_items`) 中加入一個 `customization JSONB` 欄位：

```sql
DROP TABLE IF EXISTS demo_coffee_orders CASCADE;

CREATE TABLE demo_coffee_orders (
    order_id SERIAL PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    base_price INT NOT NULL,
    customization JSONB  -- 存放各類彈性客製化設定
);
```

### 寫入各具特色的客製化 JSON 資料

```sql
INSERT INTO demo_coffee_orders (item_name, base_price, customization) VALUES
(
    '原味拿鐵咖啡', 120, 
    '{"sugar": "半糖", "ice": "微冰", "milk": "燕麥奶", "bring_cup": true}'
),
(
    '經典美式咖啡', 85, 
    '{"sugar": "無糖", "ice": "正常冰", "bring_cup": false}'
),
(
    '黑糖風味拿鐵', 135, 
    '{"sugar": "全糖", "ice": "熱", "toppings": ["肉桂粉", "雙倍濃縮"], "bring_cup": true}'
);
```

---

## 3. 查詢 JSONB 資料的兩大核心運算子

PostgreSQL 提供了強大的符號來提取 JSON 內部的值：

| 運算子 | 說明 | 回傳型別 | 範例語法 | 輸出結果 |
|:---:|---|:---:|---|:---:|
| **`->`** | 依鍵名取出物件（保留雙引號） | `JSONB` | `customization->'sugar'` | `"半糖"` |
| **`->>`** | 依鍵名取出**純文字**（去除引號） | `TEXT` | `customization->>'sugar'` | `半糖` |

### 實用查詢範例

```sql
-- 1. 取出飲品名稱、甜度與冰塊設定 (轉為純文字呈現)
SELECT 
    item_name AS 飲品,
    customization->>'sugar' AS 甜度,
    customization->>'ice' AS 冰塊,
    customization->>'milk' AS 換奶選擇
FROM demo_coffee_orders;

-- 2. 使用 WHERE 過濾：找出所有「自備環保杯 (bring_cup = true)」可享有 5 元折價的訂單
SELECT item_name, base_price, customization->>'sugar' AS 甜度
FROM demo_coffee_orders
WHERE (customization->>'bring_cup')::boolean = true;

-- 3. 檢查 JSON 陣列或屬性是否存在 (使用 ? 運算子)
-- 找出客製化中有額外加料 (toppings) 的飲品
SELECT item_name, customization->'toppings' AS 加料清單
FROM demo_coffee_orders
WHERE customization ? 'toppings';
```

---

## 🤖 助教提示詞：運用 MCP 產生建議 SQL（學生手動執行）

> 💡 **學習規範**：  
> 請直接在對話框中發問。AI 會透過 MCP 檢查資料表欄位，並為你產生**建議的測試 SQL 語法**；請將語法**複製到 DBeaver 手動執行**！

### 練習 1：請 AI 產生統計環保杯訂單比例的 SQL
> **Prompt 範例**：  
> 「在包含 `customization JSONB` 的咖啡訂單表中，如何統計出『有多少比例的顧客選擇自備環保杯』？請給我標準的 SQL 語法，我會在 DBeaver 中手動執行驗證。」

### 練習 2：請 AI 示範使用 jsonb_set 修改 JSON 內部的值
> **Prompt 範例**：  
> 「如果顧客臨時想要把微冰改成『去冰』，在 PostgreSQL 中如何使用 `jsonb_set` 直接修改 JSON 欄位內的某個 key？請給我 UPDATE 範例 SQL。」

---

## 🧭 課程導覽

| ⬅️ 上一單元 | 🏠 返回目錄 | ➡️ 下一單元 |
|:---|:---:|---:|
| [單元 15：外來鍵連鎖動作](./15on_delete_action.sql) | [第 4 章：SQL 語法與實戰練功](../README.md#dml資料操作語言) | [第 5 章：Python 串接教學](../python/) |
