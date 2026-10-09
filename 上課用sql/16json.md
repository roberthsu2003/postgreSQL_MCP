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

切換到 `json_example` 資料庫（psql 輸入 `\c json_example`；pgAdmin 請在左側選取 `json_example` 再開啟 Query Tool），再建立資料表：

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
