# 產品需求文件 (PRD)：電商訂單履約與客戶 CRM 個人桌面小 App

* **專案代號**：`Shop-Desktop-OMS-CRM`
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase ([`shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql) 結構)
* **前端框架**：Python 內建 **Tkinter** (個人桌面視窗 GUI) 或 **PyQt5**
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 專案背景與痛點

中小型電商經營者或個人賣家，過去習慣使用 Excel 追蹤訂單，面臨三大困境：
1. **客戶改電話需在幾百列 Excel 逐一搜尋手動修改**，極易矛盾。
2. **缺乏即時訂單履約介面**：無法在個人電腦上一鍵篩選「待出貨」、「已出貨」或「已取消」名單。
3. **客戶回購分析困難**：無法一鍵計算客戶的 RFM（最近購買天數、下單頻率、消費金額）。

本專案旨在將已正規化儲存於 PostgreSQL 中的電商資料（`shop.sql`），開發為一個**在個人電腦上獨立運作的桌面小 App（Desktop GUI）**，支援即時訂單處理與客戶分群！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 shop.sql 建立)

包含 6 張標準關聯表：
1. **`categories`** 與 **`products`**：商品分類與庫存清單
2. **`customers`**：會員姓名、性別、電話、Email、城市
3. **`orders`**：訂單主檔（order_id, customer_id, order_date, payment_method, status）
4. **`order_items`**：訂單明細（item_id, order_id, product_id, quantity, unit_price）
5. **`staff`**：處理員工

---

## 3. 前端介面與功能需求 (Tkinter 桌面視窗)

使用 Python 內建 **Tkinter**（搭配 `ttk` 多分頁與表格）設計：

### 3.1 分頁一：訂單履約管理 (Order Fulfillment)
- **狀態過濾器**：下拉選單（全部 / 處理中 / 已完成 / 已取消）。
- **關鍵字搜尋**：輸入訂單號或客人姓名即時過濾。
- **訂單主檔列表 (`ttk.Treeview`)**：顯示訂單號、下單日期、客戶姓名、電話、總金額、狀態。
- **點擊訂單展開明細**：點擊列表中的任一筆訂單，下方手寫 SQL JOIN 即時帶出該訂單的所有品項與數量。

### 3.2 分頁二：客戶 RFM 價值分群 (Customer CRM)
- 手寫 SQL 計算每位會員的：
  - **R (Recency)**：`CURRENT_DATE - MAX(order_date)` 最近消費天數
  - **F (Frequency)**：`COUNT(order_id)` 累計訂單數
  - **M (Monetary)**：`SUM(quantity * unit_price)` 累計消費總金額
- **自動貼標篩選**：
  - 核心 VIP 客戶（累計金額最高 TOP 10%）
  - 沉睡客（超過 90 天未消費）

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 資料表由學生在 DBeaver 親自執行 `shop.sql` 建立完畢。
- [ ] 執行 `python app.py` 立即於個人電腦彈出桌面視窗，無需架設網站。
- [ ] 訂單展開與 RFM 運算全數以手寫原生 SQL 於 Python `psycopg2` 中完成。
