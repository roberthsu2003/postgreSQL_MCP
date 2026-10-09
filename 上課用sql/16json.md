# PostgreSQL 的 JSON 應用

PostgreSQL 可以直接在欄位中儲存 JSON 資料，並用 SQL 查詢 JSON 裡面的內容。

## 1. 認識 JSON

- **JSON（JavaScript Object Notation）** 是一種輕量的資料交換格式，人和程式都容易讀寫
- 由「鍵：值」組成，也可以有陣列和巢狀結構

```json
{"name": "小明", "age": 30, "city": "台北", "skills": ["SQL", "Python"]}
```

## 2. JSON 和 JSONB

PostgreSQL 有兩種 JSON 型別：

| 型別 | 儲存方式 | 特色 |
|---|---|---|
| `JSON` | 原封不動儲存文字 | 保留原本的格式、空白和鍵的順序；每次查詢都要重新解析 |
| `JSONB` | 轉成二進位格式儲存 | 查詢速度快、可以建立索引；**一般建議使用 JSONB** |

## 3. 建立資料庫和資料表

```sql
CREATE DATABASE json_example;
```

切換到 `json_example` 資料庫（psql 輸入 `\c json_example`；DBeaver 請在左側選取 `json_example`，按右鍵 **SQL Editor → New SQL script**），再建立資料表：

```sql
CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    data JSON
);
```

## 4. 新增 JSON 資料

JSON 用字串的方式寫入，PostgreSQL 會檢查格式是否正確：

```sql
INSERT INTO people (data) VALUES ('{"name": "小明", "age": 30, "city": "台北"}');
INSERT INTO people (data) VALUES ('{"name": "小美", "age": 25, "city": "高雄"}');
```

## 5. 查詢 JSON 資料

### 5.1 取出整個 JSON

```sql
SELECT data FROM people;
```

### 5.2 取出 JSON 中的欄位

| 運算子 | 回傳 | 範例 | 結果 |
|---|---|---|---|
| `->` | JSON | `data->'name'` | `"小明"`（有雙引號） |
| `->>` | 文字 | `data->>'name'` | `小明` |

```sql
SELECT data->'name' AS name FROM people;
SELECT data->>'name' AS name FROM people;
```

### 5.3 用 JSON 欄位過濾資料

```sql
SELECT * FROM people WHERE data->>'city' = '台北';
```

## 6. 使用 JSONB

### 6.1 建立 JSONB 資料表

```sql
CREATE TABLE people_b (
    id SERIAL PRIMARY KEY,
    data JSONB
);

INSERT INTO people_b (data) VALUES ('{"name": "小明", "age": 30, "city": "台北"}');
INSERT INTO people_b (data) VALUES ('{"name": "小美", "age": 25, "city": "高雄"}');
```

### 6.2 取出欄位並計算

`->>` 取出來的是**文字**，要計算時先轉成數字，而且要用**括號**包起來：

```sql
SELECT data->'name' FROM people_b;

-- ✅ 正確:先取出 age,再轉成整數
SELECT (data->>'age')::int + 5 AS age_plus_five FROM people_b;

-- ❌ 錯誤:::int 會先作用在 'age' 這個字串上,出現 invalid input syntax for type integer: "age"
-- SELECT data->>'age'::int + 5 FROM people_b;
```

### 6.3 JSONB 常用函式

| 函式 | 說明 |
|---|---|
| `jsonb_each` | 把 JSON 物件展開成多列「鍵、值」 |
| `jsonb_array_elements` | 把 JSON 陣列展開成多列 |
| `jsonb_set` | 修改 JSON 中某個鍵的值 |
| `jsonb_build_object` | 用鍵和值組成 JSON 物件 |
| `jsonb_pretty` | 把 JSON 排版成容易閱讀的格式 |

```sql
SELECT * FROM jsonb_each('{"name": "小明", "age": 30, "city": "台北"}'::jsonb);

SELECT jsonb_set('{"name": "小明", "age": 30, "city": "台北"}'::jsonb, '{age}', '35'::jsonb);
```

### 6.4 修改資料表中的 JSONB

```sql
UPDATE people_b
SET data = jsonb_set(data, '{age}', '31'::jsonb)
WHERE data->>'name' = '小明';
```

### 6.5 包含查詢 `@>`

`@>` 判斷 JSONB 是否「包含」某些鍵和值（只有 JSONB 可以用）：

```sql
SELECT * FROM people_b WHERE data @> '{"city": "台北"}';
```

## 7. 建立索引

JSONB 欄位可以建立 GIN 索引，加快 `@>` 這類查詢：

```sql
CREATE INDEX idx_people_data ON people_b USING GIN (data);
```

## 8. 練習

1. 建立一個有 JSONB 欄位的資料表，新增 3 筆含有巢狀結構的資料（例如 `"address": {"city": "台北", "zip": "100"}`）
2. 查詢巢狀欄位：`data->'address'->>'city'`
3. 用 `jsonb_set` 修改其中一筆資料
4. 用 `@>` 查詢住在台北的人

## 參考資料

- [PostgreSQL JSON 型別](https://www.postgresql.org/docs/current/datatype-json.html)
- [PostgreSQL JSON 函式與運算子](https://www.postgresql.org/docs/current/functions-json.html)


---

## 🤖 不寫 SQL，用 Prompt 完成

> 在 Claude Desktop 使用[第 3 章](../MCP操作資料庫/2_用中文查詢資料庫/#6-準備第-4-章設定可寫入的連線)設定的 **`postgres-sql`**（可寫入，連到 `sql_tutorial` 資料庫）。
> 每個 prompt 執行後，點開工具呼叫（`execute_sql`），**對照 AI 執行的 SQL 和上面學的是否一樣**。

> 本課改用 `sql_tutorial` 資料庫練習，不需要另外建立 `json_example`。

| # | Prompt | 對照上面 |
|:---:|---|---|
| 1 | 用 postgres-sql 建立 people 資料表：id 是 SERIAL 主鍵，data 是 JSON。新增兩筆：小明 30 歲住台北、小美 25 歲住高雄 | 3、4 |
| 2 | 分別用 `->` 和 `->>` 取出每個人的 name，說明結果有什麼不同 | 5.2 |
| 3 | 找出住在台北的人 | 5.3 |
| 4 | 建立 people_b，data 改用 JSONB，資料一樣。查詢每個人的年齡加 5 | 6.1、6.2 |
| 5 | 把 people_b 中小明的年齡改成 31 | 6.4 |
| 6 | 用 `@>` 找出住在台北的人，並為 people_b 的 data 建立 GIN 索引 | 6.5、7 |

✅ 檢查重點：
- 第 2 題：`->` 的結果有雙引號（`"小明"`），`->>` 沒有（`小明`）
- **第 4 題**：AI 寫的必須是 `(data->>'age')::int + 5`，**有括號**。如果寫成 `data->>'age'::int + 5` 會出錯，對照上面 6.2 的說明
- 第 5 題：AI 用 `jsonb_set` 修改，而不是把整個 JSON 重寫
