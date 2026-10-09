# 5-2：用 MCP 實作 SQL 語法

> **本單元目標**：學完 SQL 語法後，改成**用中文請 AI 透過 MCP 操作資料庫**，再由你檢查 AI 寫的 SQL 對不對。
> 你的角色是**下指令的人**和**檢查 SQL 的人**。　[← 回第 5 章](../)

## 為什麼學完 SQL 還要用 AI？

| | 自己寫 SQL | 請 AI 透過 MCP 執行 |
|---|---|---|
| 速度 | 慢，要記語法 | 快，用中文描述就好 |
| 正確性 | 自己負責 | **AI 可能寫錯**（WHERE 漏掉、JOIN 條件錯、型別選錯） |
| 你需要的能力 | 會寫 SQL | **看得懂 SQL、判斷對不對** |

學過 SQL 的人用 AI 才安全：看得出 AI 漏了 `WHERE`，才不會把整張表都改掉。

## 目錄

- [準備](#準備)
- [練習流程與三個原則](#練習流程與三個原則)
- [1. 建立資料表](#1-建立資料表) ・ [2. 修改資料表](#2-修改資料表) ・ [3. 新增資料](#3-新增資料)
- [4. 取得資料](#4-取得資料) ・ [5. 修改和刪除](#5-修改和刪除) ・ [6. FOREIGN KEY](#6-foreign-key)
- [7. JOIN](#7-join) ・ [8. 聚合函式與 GROUP BY](#8-聚合函式與-group-by) ・ [9. 子查詢](#9-子查詢)
- [10. 萬用字元與 UNION](#10-萬用字元與-union) ・ [11. JSON](#11-json)
- [綜合挑戰](#綜合挑戰)

---

## 準備

### 1. 用 pgAdmin 建立練習用的資料庫

```sql
CREATE DATABASE ai_practice;
```

> AI **不能**幫你建立資料庫：Postgres MCP Pro 執行 SQL 時會包在交易（transaction）裡，`CREATE DATABASE` 會出現 `cannot run inside a transaction block` 的錯誤。資料庫要自己建，資料表以後的事都可以交給 AI。

### 2. 新增一個「可以寫入」的 MCP Server

在 `claude_desktop_config.json` 中，**另外**新增一個連到 `ai_practice`、使用 `unrestricted` 模式的 MCP Server（原本唯讀的 `postgres` 保留不動）：

```json
{
  "mcpServers": {
    "postgres": {
      "...": "5-1 設定的唯讀版本,保留不動"
    },
    "postgres-practice": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "-e", "DATABASE_URI", "crystaldba/postgres-mcp", "--access-mode=unrestricted"],
      "env": {
        "DATABASE_URI": "postgresql://postgres:yourpassword@localhost:5432/ai_practice"
      }
    }
  }
}
```

使用 uvx 時，`args` 改成 `["--with", "mcp<2", "postgres-mcp", "--access-mode=unrestricted"]`（詳見 [5-1](../1_postgres_mcp_pro/#使用-uvx-的設定)）。

> ⚠️ **`unrestricted` 只能連練習用的資料庫**。AI 可以建立、修改、刪除任何資料，連到重要的資料庫時一律用 `restricted`。

### 3. 確認設定成功

重新啟動 Claude Desktop 後問：「用 postgres-practice 列出 ai_practice 資料庫有哪些資料表」，AI 應該回答目前沒有資料表。

---

## 練習流程與三個原則

```mermaid
flowchart LR
    A["你：用中文<br/>描述需求"] --> B["AI：寫出 SQL<br/>透過 MCP 執行"]
    B --> C{"你：檢查 SQL<br/>對不對？"}
    C -->|對| D["用 SELECT<br/>或 pgAdmin 確認結果"]
    C -->|不對| E["告訴 AI 哪裡錯<br/>請它修正"]
    E --> B

    classDef you fill:#f0fdfa,stroke:#0f766e,color:#134e4a
    classDef ai fill:#f5f3ff,stroke:#7c3aed,color:#4c1d95
    class A,C,D,E you
    class B ai
```

| # | 原則 | 怎麼做 |
|:---:|---|---|
| 1 | **看 AI 寫的 SQL** | 在 Claude Desktop 展開工具呼叫（`execute_sql`），看實際執行的 SQL |
| 2 | **用 SELECT 驗證結果** | `UPDATE`、`DELETE` 執行後，MCP 只會回傳「No results」，**不會告訴你改了幾筆**，一定要再查詢確認 |
| 3 | **危險操作先確認** | 修改、刪除前先請 AI「列出會影響哪些資料，等我確認再執行」 |

> 💡 每一節都附上「參考 SQL」。AI 寫的不一定和參考答案一模一樣，**結果一樣就是對的**。

---

## 1. 建立資料表

📖 對應講義：[資料表與基本型別](../../上課用sql/2_0基本型別.md)、[建立資料表](../../上課用sql/2建立資料表.md)、[限制](../../上課用sql/4限制.md)

**對 Claude 說：**

> 用 postgres-practice，建立一個 students 資料表，欄位有：
> - 學號：自動編號，主鍵
> - 姓名：最多 20 個字，必填
> - email：不可以重複
> - 主修：沒有填的話預設是「未定」
> - 分數：整數，只能是 0 到 100
>
> 建立之前先把 SQL 給我看。

**你要檢查：**

- [ ] 學號用 `SERIAL`（或 `GENERATED ... AS IDENTITY`）而且有 `PRIMARY KEY`
- [ ] 姓名有 `NOT NULL`、email 有 `UNIQUE`、主修有 `DEFAULT '未定'`
- [ ] 分數有 `CHECK`，範圍是 0～100（不是 1～100）

<details>
<summary>參考 SQL</summary>

```sql
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    name       VARCHAR(20) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    major      VARCHAR(20) DEFAULT '未定',
    score      INT CHECK (score BETWEEN 0 AND 100)
);
```

</details>

**動手題：** 請 AI 再建立一個 `courses` 資料表（課程代碼為主鍵、課程名稱必填、學分 1～4），檢查 AI 選的型別是否合理。

<details>
<summary>參考 SQL</summary>

```sql
CREATE TABLE courses (
    course_id VARCHAR(10) PRIMARY KEY,
    name      VARCHAR(30) NOT NULL,
    credits   INT CHECK (credits BETWEEN 1 AND 4)
);
```

</details>

---

## 2. 修改資料表

📖 對應講義：[建立資料表](../../上課用sql/2建立資料表.md)（ALTER TABLE）

**對 Claude 說：**

> students 資料表加上一個「生日」欄位，型別用日期。

**你要檢查：**

- [ ] 用的是 `ALTER TABLE ... ADD`，而不是把整個資料表刪掉重建
- [ ] 型別是 `DATE`，不是 `VARCHAR`

<details>
<summary>參考 SQL</summary>

```sql
ALTER TABLE students ADD birthday DATE;
```

</details>

---

## 3. 新增資料

📖 對應講義：[新增資料](../../上課用sql/3新增資料.md)、[INSERT 練習](../../練習/5INSERT_INTO/)

**對 Claude 說：**

> 在 students 新增 5 位學生：
> 小明（資訊，85 分）、小美（英語，92 分）、小華（資訊，58 分）、小強（歷史，73 分）、小芳（主修還沒決定，66 分），
> email 用 名字拼音@example.com。

**你要檢查：**

- [ ] 一個 `INSERT` 新增多筆（`VALUES (...), (...)`），而不是 5 個 `INSERT`
- [ ] 沒有自己指定 `student_id`（讓 SERIAL 自動編號）
- [ ] 小芳沒有填主修，查詢後應該是「未定」

<details>
<summary>參考 SQL</summary>

```sql
INSERT INTO students (name, email, major, score) VALUES
    ('小明', 'xiaoming@example.com', '資訊', 85),
    ('小美', 'xiaomei@example.com',  '英語', 92),
    ('小華', 'xiaohua@example.com',  '資訊', 58),
    ('小強', 'xiaoqiang@example.com','歷史', 73);

INSERT INTO students (name, email, score) VALUES
    ('小芳', 'xiaofang@example.com', 66);
```

</details>

**觀察 AI 怎麼處理錯誤：**

> 再新增一位學生：小明二號，email 是 xiaoming@example.com，分數 120。

這筆同時違反了 `UNIQUE`（email 重複）和 `CHECK`（分數超過 100），但 PostgreSQL **一次只會回報一個錯誤**（這裡會先回報 `students_score_check`）。觀察：

- AI 收到錯誤訊息後，有沒有說明是哪個限制被違反？
- 請 AI 把分數改成 100 再試一次，這時才會看到 email 重複的錯誤
- AI 會不會「自作主張」改掉 email 或分數再新增？**這種情況應該要先問你**

---

## 4. 取得資料

📖 對應講義：[取得資料](../../上課用sql/6取得資料.md)

**對 Claude 說：**

> 1. 列出所有主修資訊的學生，分數由高到低
> 2. 分數最高的 3 位學生
> 3. 分數不及格（低於 60）的學生

**你要檢查：**

- [ ] 「由高到低」有用 `DESC`
- [ ] 「最高的 3 位」要先 `ORDER BY ... DESC` 再 `LIMIT 3`，順序不能反
- [ ] 「低於 60」是 `< 60`，不是 `<= 60`

<details>
<summary>參考 SQL</summary>

```sql
SELECT * FROM students WHERE major = '資訊' ORDER BY score DESC;

SELECT * FROM students ORDER BY score DESC LIMIT 3;

SELECT * FROM students WHERE score < 60;
```

</details>

**動手題：** 自己先寫出「主修是資訊或英語，而且分數 80 分以上」的 SQL，再請 AI 做一次，比較兩個 SQL 和結果。

---

## 5. 修改和刪除

📖 對應講義：[修改和刪除](../../上課用sql/5修改和刪除.md)

這一節最重要。**先請 AI 列出會影響的資料，確認後再執行。**

**對 Claude 說：**

> 小華的分數要改成 62 分。先列出會被修改的資料給我確認，我說「確定」你再執行。

**你要檢查：**

- [ ] `UPDATE` 有 `WHERE`，而且條件只會選到小華
- [ ] 執行後再 `SELECT` 確認只有小華被改

<details>
<summary>參考 SQL</summary>

```sql
-- 先確認會影響哪些資料
SELECT * FROM students WHERE name = '小華';

-- 確認後再執行
UPDATE students SET score = 62 WHERE name = '小華';
```

</details>

**陷阱題：** 對 Claude 說「**分數加 5 分**」——沒有說是誰。

- AI 有沒有問你「是所有學生嗎？」
- 如果 AI 直接執行 `UPDATE students SET score = score + 5`，**所有人**都會被加分
- 如果有人原本是 98 分，加 5 分會違反 `CHECK`，**整個 UPDATE 都會失敗**（一筆都不會改），請 AI 解釋原因

> 💡 這就是為什麼學過 SQL 很重要：**看到沒有 WHERE 的 UPDATE、DELETE，要立刻警覺**。

**刪除：**

> 刪除主修是歷史的學生，一樣先列出來給我確認。

<details>
<summary>參考 SQL</summary>

```sql
SELECT * FROM students WHERE major = '歷史';

DELETE FROM students WHERE major = '歷史';
```

</details>

---

## 6. FOREIGN KEY

📖 對應講義：[FOREIGN KEY](../../上課用sql/7_0FOREIGN_KEY.md)、[ON DELETE 動作](../../上課用sql/15on_delete_action.sql)

**對 Claude 說：**

> 建立選課資料表 enrollments，記錄哪個學生選了哪門課，以及學期成績。
> - 同一個學生不能重複選同一門課
> - 學生被刪除時，他的選課紀錄也一起刪除
> - 課程如果還有人選，不能刪除
>
> 然後新增幾筆選課資料：先在 courses 新增 DB101 資料庫系統（3 學分）、PY101 Python 程式設計（3 學分）、EN101 英文寫作（2 學分），再讓小明、小美、小華選課。

**你要檢查：**

- [ ] 主鍵是 `(student_id, course_id)` 兩個欄位的組合
- [ ] 學生的 foreign key 有 `ON DELETE CASCADE`
- [ ] 課程的 foreign key 是 `ON DELETE RESTRICT` 或不寫（預設 `NO ACTION`）
- [ ] 新增選課時，AI 有先查詢學生的 `student_id`，而不是自己猜編號

<details>
<summary>參考 SQL</summary>

```sql
CREATE TABLE enrollments (
    student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
    course_id  VARCHAR(10) REFERENCES courses(course_id) ON DELETE RESTRICT,
    grade      INT CHECK (grade BETWEEN 0 AND 100),
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO courses (course_id, name, credits) VALUES
    ('DB101', '資料庫系統', 3),
    ('PY101', 'Python 程式設計', 3),
    ('EN101', '英文寫作', 2);

-- 用子查詢找學號,不要自己猜編號
INSERT INTO enrollments (student_id, course_id, grade)
SELECT student_id, 'DB101', 88 FROM students WHERE name = '小明'
UNION ALL SELECT student_id, 'PY101', 79 FROM students WHERE name = '小明'
UNION ALL SELECT student_id, 'EN101', 95 FROM students WHERE name = '小美'
UNION ALL SELECT student_id, 'DB101', 91 FROM students WHERE name = '小美'
UNION ALL SELECT student_id, 'DB101', 55 FROM students WHERE name = '小華';
```

</details>

**驗證 foreign key：**

> 1. 刪除 DB101 這門課
> 2. 刪除學生小華，再查詢 enrollments

第 1 題應該**失敗**（還有人選），第 2 題成功而且小華的選課紀錄也不見了。請 AI 解釋為什麼。

---

## 7. JOIN

📖 對應講義：[JOIN](../../上課用sql/JOIN.md)、[JOIN 練習](../../練習/8JOIN/)

**對 Claude 說：**

> 1. 列出每位學生選了哪些課，顯示學生姓名、課程名稱、學期成績
> 2. 列出**所有**學生和他們選的課，沒有選課的學生也要列出來

**你要檢查：**

- [ ] 第 1 題要 JOIN 三張表：students、enrollments、courses
- [ ] 第 2 題要用 `LEFT JOIN`，而且 students 放在左邊
- [ ] JOIN 的條件（`ON`）有沒有對到正確的欄位

<details>
<summary>參考 SQL</summary>

```sql
SELECT s.name AS 學生, c.name AS 課程, e.grade AS 成績
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c  ON e.course_id = c.course_id
ORDER BY s.name;

SELECT s.name AS 學生, c.name AS 課程
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c     ON e.course_id = c.course_id
ORDER BY s.name;
```

</details>

---

## 8. 聚合函式與 GROUP BY

📖 對應講義：[聚合函式](../../上課用sql/10聚合函式.sql)、[GROUP BY、HAVING 練習](../../練習/9HAVING/)

**對 Claude 說：**

> 1. 每個主修有幾位學生、平均分數多少（四捨五入到小數 1 位）
> 2. 平均分數超過 70 分的主修
> 3. 每門課的選課人數，沒有人選的課也要顯示 0

**你要檢查：**

- [ ] 「超過 70 分」的條件放在 `HAVING`，不是 `WHERE`
- [ ] 第 3 題要用 `LEFT JOIN` 和 `COUNT(e.student_id)`，**不能**用 `COUNT(*)`（沒有人選的課會變成 1）

<details>
<summary>參考 SQL</summary>

```sql
SELECT major AS 主修, COUNT(*) AS 人數, ROUND(AVG(score), 1) AS 平均分數
FROM students
GROUP BY major;

SELECT major AS 主修, ROUND(AVG(score), 1) AS 平均分數
FROM students
GROUP BY major
HAVING AVG(score) > 70;

SELECT c.name AS 課程, COUNT(e.student_id) AS 選課人數
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.name;
```

</details>

---

## 9. 子查詢

📖 對應講義：[子查詢](../../上課用sql/14子查詢.sql)、[SubQuery 練習](../../練習/10subQuery/)

**對 Claude 說：**

> 1. 分數高於全班平均的學生
> 2. 有選「資料庫系統」的學生姓名

**你要檢查：**

- [ ] 第 1 題的平均是用子查詢 `(SELECT AVG(score) FROM students)` 算出來的，不是 AI 自己先算好寫死的數字
- [ ] 第 2 題用 `IN (子查詢)` 或 `JOIN` 都可以，結果要一樣

<details>
<summary>參考 SQL</summary>

```sql
SELECT name, score
FROM students
WHERE score > (SELECT AVG(score) FROM students);

SELECT name
FROM students
WHERE student_id IN (
    SELECT e.student_id
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
    WHERE c.name = '資料庫系統'
);
```

</details>

---

## 10. 萬用字元與 UNION

📖 對應講義：[萬用字元](../../上課用sql/11萬用字元.sql)、[聯集 UNION](../../上課用sql/12聯集.sql)

**對 Claude 說：**

> 1. email 開頭是 xiao 的學生
> 2. 把學生姓名和課程名稱列在同一欄（不要重複）

<details>
<summary>參考 SQL</summary>

```sql
SELECT name, email FROM students WHERE email LIKE 'xiao%';

SELECT name FROM students
UNION
SELECT name FROM courses;
```

</details>

**想一想：** `UNION` 和 `UNION ALL` 差在哪裡？請 AI 用這兩張表舉例說明。

---

## 11. JSON

📖 對應講義：[JSON 應用](../../上課用sql/16json.md)

**對 Claude 說：**

> students 加上一個 JSONB 欄位「聯絡資訊」，小明的聯絡資訊是電話 0912-000-111、住在台北；小美住在高雄。
> 然後列出住在台北的學生。

**你要檢查：**

- [ ] 型別是 `JSONB`
- [ ] 查詢 JSON 裡的值用 `->>`（回傳文字），或用 `@>` 判斷包含

<details>
<summary>參考 SQL</summary>

```sql
ALTER TABLE students ADD contact JSONB;

UPDATE students SET contact = '{"phone": "0912-000-111", "city": "台北"}' WHERE name = '小明';
UPDATE students SET contact = '{"city": "高雄"}' WHERE name = '小美';

SELECT name, contact->>'phone' AS 電話
FROM students
WHERE contact->>'city' = '台北';
```

</details>

---

## 綜合挑戰

### 挑戰一：請 AI 設計整個資料庫

> 我要做一個「社團管理」系統：有社團、學生、社團幹部（社長、副社長、總務）、活動、活動報名。
> 請先設計資料表（欄位、型別、主鍵、foreign key），**用表格列給我看，等我確認後再建立**，最後新增一些測試資料。

用下面的清單審查 AI 的設計：

- [ ] 每張表都有主鍵
- [ ] 多對多的關係（學生 ↔ 社團、學生 ↔ 活動）有中介資料表
- [ ] foreign key 的 `ON DELETE` 合理嗎？（社團被刪除時，活動要一起刪除嗎？）
- [ ] 有沒有該加 `NOT NULL`、`UNIQUE`、`CHECK` 的欄位？

### 挑戰二：角色互換——你寫 SQL，請 AI 檢查

自己寫一段 SQL（可以故意寫錯），請 AI：

> 1. 解釋這段 SQL 每一行在做什麼
> 2. 指出有沒有錯誤或可以改進的地方
> 3. 實際執行看看結果

### 挑戰三：用 CSV 新增資料

Postgres MCP Pro 沒辦法讀取你電腦上的檔案，但可以把 CSV 檔**附加到 Claude Desktop 的對話中**：

> 這是學生名單 CSV，請新增到 students 資料表。

檢查 AI 產生的 `INSERT` 筆數和 CSV 是否相同。

---

## 下一步

你已經會「請 AI 操作資料庫」了。但 Postgres MCP Pro 讓 AI 可以執行**任何 SQL**，不適合開放給公司的一般員工。

在學完 Python 之後，第 8 章會教你**用 AI 建立自己的 MCP Server**：只開放設計好的查詢，加上 token 驗證，讓企業可以安全地導入。👉 [自訂 MCP Server](../../mcp_server/)
