# 產品需求文件 (PRD)：企業費用報銷審核與預算預警 PyQt5 系統

* **專案代號**：`Expense-PyQt5-Manager`
* **適用職務**：**會計 (Accounting)、出納 (Cashier)、財務主管**
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase (對應 [`expense_tracker.sql`](../../範例資料庫/中文範例資料庫/expense_tracker.sql))
* **前端框架**：**PyQt5** (現代商業桌面視窗 GUI)
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 職場痛點與專案目標

在一般中小型企業，會計與出納每到月底最痛苦的流程就是「整理員工差旅費用報銷單」：
1. **Excel 報銷單分散混亂**：各部門同仁各自交一份 Excel，格式不統一、公式常損壞，會計必須手動貼到總表。
2. **缺乏即時預算防超支警報**：業務部或行銷部常在預算花超了之後才報帳，財務無法在事前或審核當下即時比對預算額度。
3. **單據審批與出納撥款斷層**：出納不知哪些款項主管已核准、哪些已撥款，容易重複報銷或漏撥款。

本專案將基於已正規化建置的 `expense_tracker.sql`，打造一個**專為會計與出納設計的個人電腦桌面管理系統**，實現**部門預算動態監控、單據一鍵審批與撥款紀錄**！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 expense_tracker.sql 建立)

包含 4 張標準關聯表：
1. **`expense_departments`**：部門與主管 (dept_id, name, manager_name)
2. **`expense_employees`**：員工資料 (emp_id, name, dept_id)
3. **`expense_categories`**：費用分類 (category_id, name)（如：市區交通、長途交通、雲端服務、商務餐敘、差旅住宿等）
4. **`expense_claims`**：報銷單主檔 (claim_id, claim_date, emp_id, category_id, invoice_no, amount, description, status)

> [!NOTE]
> **範例資料庫沒有預算資料。** 要做「部門預算消耗進度」，請先自己設計並建立 `expense_budgets` 資料表（部門、年度、預算金額），這是本專案的第一個手寫 DDL 任務。

<details>
<summary>卡住了再看參考答案（預算金額是自訂的示範值）</summary>

```sql
CREATE TABLE expense_budgets (
    dept_id VARCHAR(10) NOT NULL REFERENCES expense_departments(dept_id),
    year    INT NOT NULL,
    amount  NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    PRIMARY KEY (dept_id, year)
);

INSERT INTO expense_budgets (dept_id, year, amount) VALUES
    ('D01', 2024, 50000), ('D02', 2024, 60000), ('D03', 2024, 40000), ('D04', 2024, 20000);

-- 各部門預算使用率（只算已撥款）
SELECT
    d.name AS 部門,
    b.amount AS 預算,
    COALESCE(SUM(x.amount), 0) AS 已撥款,
    ROUND(COALESCE(SUM(x.amount), 0) / b.amount * 100, 1) AS 使用率
FROM expense_budgets b
JOIN expense_departments d ON b.dept_id = d.dept_id
LEFT JOIN expense_employees e ON d.dept_id = e.dept_id
LEFT JOIN expense_claims x ON e.emp_id = x.emp_id AND x.status = '已撥款'
WHERE b.year = 2024
GROUP BY d.dept_id, d.name, b.amount
ORDER BY 使用率 DESC;
```

</details>

---

## 3. 前端介面與功能需求 (PyQt5 現代視窗)

### 3.1 頂部統計指標卡片 (`QFrame` + QSS 美化)
- **待審核金額**：手寫 SQL 計算 `status = '待審核'` 的加總金額。
- **本月已撥款金額**：手寫 SQL 統計本月已結案金額。
- **部門預算消耗進度**：各部門累計支出佔比。

### 3.2 核心單據審核工作台 (`QTableWidget`)
- **部門與狀態篩選工具列 (`QComboBox`)**：可切換部門（業務部/技術部/行銷部）與狀態（待審核/已批准/待撥款/已撥款）。
- **報銷單明細表格**：顯示報銷單號、申請日期、員工姓名、費用類別、發票號碼、金額、用途說明。
- **審批控制按鈕 (`QPushButton`)**：
  - 🟢 **批准單據**：手寫 SQL 更新 `status = '已批准'`。
  - 🔵 **出納確認撥款**：手寫 SQL 更新 `status = '已撥款'`。
  - 🔴 **退回駁回**：更新 `status = '已駁回'`。

### 3.3 費用分類統計圖表分頁 (`QTabWidget` + Matplotlib)
- 手寫 SQL `GROUP BY c.name` 統計各費用類別（交通/差旅/廣告/餐敘）佔比圓餅圖。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 學生在 DBeaver 執行 `expense_tracker.sql` 建立資料表無誤。
- [ ] 執行 `python app.py` 立即跳出 PyQt5 視窗，表格流暢支援排序與點選審核。
- [ ] 所有狀態更新與金額統計全數以 `psycopg2` 手寫原生 SQL 呈現。

