# 產品需求文件 (PRD)：門市店長營運分析個人桌面小 App

* **專案代號**：`CafeShop-Desktop-Manager`
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase (對應 `cafe_shop.sql`)
* **前端框架**：Python 內建 **Tkinter** (個人桌面視窗 GUI) 或 **PyQt5**
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 專案背景與痛點

連鎖門市店長或個人咖啡館經營者，過去每到月底就用 Excel 檔案記帳並手動計算各類報表：
1. **跨月份報表繁瑣**：每個月開新工作表，計算第一季成長率時公式容易出錯。
2. **缺乏即時查詢工具**：想查特定員工績效或熱門商品排行，必須在 Excel 裡一層層篩選。

本專案旨在將已正規化儲存於 PostgreSQL 中的門市銷售資料（`cafe_shop.sql`），開發為一個**在個人電腦上獨立執行的桌面小 App（Desktop GUI）**，讓店長點擊圖示即可秒開，掌握全店營運指標！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 cafe_shop.sql 建立)

包含 7 張標準關聯表：
1. **`stores`**：門市資訊 (store_id, name, city, address)
2. **`staff`**：門市員工 (staff_id, store_id, name, position, salary)
3. **`categories`** 與 **`products`**：分類與品項 (product_id, category_id, name, price, cost)
4. **`customers`**：會員名冊 (customer_id, name, phone, gender)
5. **`orders`**：銷售訂單 (order_id, store_id, staff_id, customer_id, order_date, payment_method, status)
6. **`order_items`**：訂單明細 (item_id, order_id, product_id, quantity, unit_price)

---

## 3. 前端介面與功能需求 (Tkinter 桌面視窗)

使用 Python 內建 **Tkinter**（搭配 `ttk` 元件）設計個人桌面視窗：

### 3.1 視窗頂部篩選工具列
- **門市下拉選單 (`ttk.Combobox`)**：手寫 SQL 載入所有門市名稱，可選擇「全部門市」或指定分店。
- **月份切換單選鈕 (`ttk.Radiobutton`)**：切換「2024-01」、「2024-02」、「2024-03」或「整季 Q1」。
- **「查詢統計」按鈕**：點擊觸發手寫 SQL 查詢並刷新下方介面。

### 3.2 營運 KPI 面板 (Summary Cards)
- 總銷售金額（手寫 `SUM(quantity * unit_price)`）
- 總訂單筆數（手寫 `COUNT(DISTINCT order_id)`）
- 平均客單價 (AOV)

### 3.3 核心分析表格 (`ttk.Treeview` 分頁展示)
1. **熱銷商品排行分頁**：手寫 SQL 多表 JOIN，按銷量由高到低列出品名、分類、售出份數與營業額。
2. **門市員工績效分頁**：手寫 SQL 統計各員工經手的訂單金額與件數。
3. **VIP 常客名單分頁**：手寫 SQL 使用 `GROUP BY + HAVING` 篩選出回購 2 次以上的高價值會員。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 資料表由學生在 DBeaver 親自執行 `cafe_shop.sql` 建立完畢。
- [ ] 執行 `python app.py` 能立即跳出 Tkinter 本機視窗，不依賴網頁瀏覽器或遠端伺服器。
- [ ] 所有按鈕動作皆透過 `psycopg2` 執行手寫原生 SQL，無任何 MCP 代勞。
