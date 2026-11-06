# 產品需求文件 (PRD)：門市營運分析與業績抽成 PyQt5 商業桌面 App

* **專案代號**：`CafeShop-PyQt5-Dashboard`
* **適用職務**：**門市店長、營運經理、連鎖零售主管、區域業務督導**
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase (對應 [`cafe_shop.sql`](../../範例資料庫/中文範例資料庫/cafe_shop.sql))
* **前端框架**：**PyQt5** (現代商業桌面視窗 GUI)
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 職場痛點與專案目標

連鎖門市店長或餐飲零售主管，過去每到月底最頭痛的就是用 Excel 跨月跨店記帳：
1. **每月複製一份 Excel 容易公式損壞**：計算第一季各店成長率時，跨檔案引用常變成 `#REF!`。
2. **明星熱銷商品統計耗時**：要手動在幾千筆銷售明細中用樞紐分析計算分類佔比。
3. **VIP 常客與店員業績難以即時掌握**：行銷要發送回購券，無法一秒挑出連續 3 個月消費的忠實會員。

本專案旨在將 `cafe_shop.sql` 資料庫開發為**高質感的 PyQt5 商業桌面管理 App**，讓店長在自己電腦前一秒切換門市與月份，營運決策一目了然！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 cafe_shop.sql 建立)

包含 7 張標準關聯表：
1. **`stores`**：門市資訊
2. **`staff`**：門市員工
3. **`categories`** 與 **`products`**：分類與品項
4. **`customers`**：會員名冊
5. **`orders`**：銷售訂單主檔
6. **`order_items`**：訂單明細

---

## 3. 前端介面與功能需求 (PyQt5 現代視窗)

### 3.1 頂部動態篩選工具列 (`QComboBox` + `QRadioButton`)
- 門市切換（全門市 / 指定分店）。
- 月份切換（2024-01 / 2024-02 / 2024-03 / 整季 Q1）。

### 3.2 頂部營運 KPI 指標面板
- 總銷售金額、總訂單筆數、平均客單價 (AOV)。

### 3.3 三大分析工作台 (`QTabWidget` 多分頁展示)
1. **明星商品排行分頁 (`QTableWidget`)**：手寫 SQL 多表 JOIN，按銷量列出品名、分類、售出份數與營收貢獻。
2. **門市店員業績分頁 (`QTableWidget`)**：手寫 SQL 統計各員工經手的訂單總金額與件數。
3. **VIP 常客名單分頁 (`QTableWidget`)**：手寫 SQL 使用 `GROUP BY + HAVING` 篩選出回購 2 次以上的高價值會員。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 學生在 DBeaver 執行 `cafe_shop.sql` 建立資料表無誤。
- [ ] 執行 `python app.py` 立即跳出 PyQt5 視窗，支援即時門市與月份切換。
- [ ] 多表 JOIN 與分組統計全數以手寫 SQL 在 `psycopg2` 中完成。

