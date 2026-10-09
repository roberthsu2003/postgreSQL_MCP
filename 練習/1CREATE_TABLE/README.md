## 練習建立資料表

> 💡 用 DBeaver 匯入：在資料表上按右鍵 → **Import Data** → **CSV**（詳細步驟見[匯入 CSV](../../上課用sql/2_1匯入csv.md)）。
> CSV 的欄位名稱和資料表不同時，在 **Tables mapping** 頁面按 **Columns...** 手動對應；資料表多出來的 `id` 欄位（SERIAL）不用對應，會自動產生。

- 使用city.csv檔
- 使用employees.csv檔
- 使用invoices.csv檔
- 使用artists.csv檔

### 建立artists
- 匯入artists.csv檔
- 欄位名稱改為id,name

```sql
CREATE TABLE IF NOT EXISTS artists(
	id SERIAL PRIMARY KEY,
	name VARCHAR
);

```

匯入後查詢確認：

```sql
SELECT * FROM artists;   -- 275 筆,第一筆是 1 | AC/DC
```

---

###  建立city資料表
- 匯入city.csv檔
- 建立id,primary key

```sql
CREATE TABLE IF NOT EXISTS city(
	id SERIAL PRIMARY KEY,
	name VARCHAR(30),
	population INT
);
```

匯入後查詢確認：

```sql
SELECT * FROM city;      -- 274 筆,第一筆是 1 | Abilene | 115930
```

---

### 建立invoices資料表
- 匯入invoices.csv檔
- id,客戶,日期,地址,城市,州,國家,郵遞區號,金額

```sql
CREATE TABLE IF NOT EXISTS invoices(
	id SERIAL PRIMARY KEY,
	客戶id INT,
	日期 DATE,
	地址 VARCHAR(100),
	城市 VARCHAR(20),
	州 VARCHAR(10),
	國家 VARCHAR(20),
	郵遞區號 VARCHAR(20),
	金額 real
);
```

匯入後查詢確認：

```sql
SELECT * FROM invoices;  -- 412 筆
```

---

### 建立employees資料表
- 匯入employees.csv

```sql
CREATE TABLE IF NOT EXISTS employees(
	id SERIAL PRIMARY KEY,
	lastName VARCHAR(20),
	firstName VARCHAR(20),
	title VARCHAR(20),
	reportsTo VARCHAR(20),
	birthDate DATE,
	hireDate DATE,
	address VARCHAR(100),
	city VARCHAR(20),
	state VARCHAR(20),
	country VARCHAR(20),
	postalCode VARCHAR(20),
	phone VARCHAR(30),
	fax VARCHAR(30),
	email VARCHAR(30)
);
```

匯入後查詢確認：

```sql
SELECT * FROM employees; -- 8 筆
```




