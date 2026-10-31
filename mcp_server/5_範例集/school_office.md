# 範例 2：🎓 教務處助理

程式：[school_office.py](./school_office.py)　資料庫：[school.sql](../../範例資料庫/中文範例資料庫/#-學校選課-school)　[← 回範例集](./README.md)

## 情境

期中考後，導師想知道班上誰需要輔導；教務處要統計每門課的成績分布。不用再匯出 Excel 自己算。

## 工具

| 工具 | 用途 | 參數 |
|---|---|---|
| `search_students` | 用學號或姓名找學生 | 關鍵字 |
| `student_transcript` | 學生的成績單（含及格與否） | 學號 |
| `course_stats` | 某學期每門課的人數、平均、最高、最低、不及格人數 | 學期 |
| `students_need_help` | 某學期不及格科目達一定數量的學生 | 學期、不及格科目數 |

## 可以這樣問

- 「113-2 學期有哪些學生兩科以上不及格？是哪幾科？」
- 「S111016 這位學生目前修了幾學分？有沒有不及格的課？」
- 「113-1 學期哪門課的平均最低？不及格的人有幾個？」
- 「資訊工程學系 113 年入學的學生有哪些？」

## 學到的技巧

### 1. 學期用 `Literal` 限定

```python
Semester = Literal["113-1", "113-2", "114-1"]

def course_stats(semester: Semester) -> list[dict]:
```

AI 輸入「112-1」這種不存在的學期，會直接被擋下並收到錯誤訊息，AI 會自己改用正確的學期。

### 2. `HAVING` 找出需要輔導的學生，`STRING_AGG` 把科目串成一行

```sql
SELECT s.name AS 姓名,
       COUNT(*) AS 不及格科目數,
       STRING_AGG(c.name || '(' || e.score || ')', '、') AS 不及格科目   -- 電路學(52)、會計學(48)
FROM enrollments e …
WHERE c.semester = %s AND e.score < 60
GROUP BY s.student_id, s.name
HAVING COUNT(*) >= %s
```

### 3. 用 `instructions` 告訴 AI 資料的規則

```python
instructions="……60 分及格;114-1 學期尚未結束,成績是空值代表還沒有給分。"
```

AI 看到成績是空值時，就不會誤以為是 0 分。

## 產生這個範例的提示詞

````markdown
請參考 common.py 的寫法,用 MCP Python SDK(mcp 2.x 的 MCPServer)建立「教務處助理」MCP Server。
使用者是教務處職員和導師。

## 規定
- 使用 common.py 的 query()、audit()、run(),每個工具開頭都要呼叫 audit()
- 所有參數用 %s 參數化查詢;學期用 Literal["113-1", "113-2", "114-1"] 限定
- 在 instructions 說明:60 分及格;114-1 學期尚未結束,成績空值代表還沒有給分
- 工具說明用繁體中文

## 資料表
【貼上 school.sql 的 CREATE TABLE 語法】

## 工具
1. search_students(keyword):用學號或姓名搜尋學生(學號不分大小寫)
2. student_transcript(student_id):成績單,顯示及格、不及格或尚未給分
3. course_stats(semester):某學期每門課的修課人數、平均、最高、最低、不及格人數
4. students_need_help(semester, min_failed):不及格科目數 >= min_failed 的學生,列出不及格的科目和分數
````

## 延伸挑戰

1. 新增 `teacher_courses(teacher_name)`：某位老師開了哪些課、各課的平均成績
2. 新增 `course_capacity(semester)`：哪些課已經額滿或快額滿（修課人數 ÷ 人數上限）
3. 思考：如果開放給**學生自己**使用，哪些工具要拿掉？`student_transcript` 要怎麼確保學生只能查自己的成績？（提示：用 token 對應的使用者）
