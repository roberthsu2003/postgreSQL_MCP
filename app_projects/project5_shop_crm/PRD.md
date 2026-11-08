# 產品需求文件 (PRD)：業務客戶 CRM 與訂單履約 Tkinter 系統

* **專案代號**：`Sales-Tkinter-CRM-Orders`
* **適用職務**：**業務專員 (Sales)、業務助理 (Sales Assistant)、電商營運人員**
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase (對應 [`shop.sql`](../../範例資料庫/中文範例資料庫/shop.sql))
* **前端框架**：Python 內建 **Tkinter** (個人桌面視窗 GUI)
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，不使用 ORM 遮蔽 SQL

---

## 1. 職場痛點與專案目標

業務同仁與業務助理，在管理客戶名冊與追蹤客戶訂單時面臨諸多痛點：
1. **客戶電話與地址修改常矛盾**：同一位客人在 Excel 出現幾十次，只要有一列漏改，聯絡資訊直接衝突。
2. **缺乏即時訂單履約工作台**：業務無法在個人電腦上一秒點看「這個月王老闆下了哪些單、是否已出貨」。
3. **沒有客戶分群模型**：無法精準挑出誰是「很久沒來買的老客戶（即將流失）」或「消費最高的核心 VIP 客戶」。

本專案旨在將 `shop.sql` 資料庫開發為**免安裝環境、雙擊即可啟動的 Tkinter 個人桌面小工具**，協助業務人員一手掌握客戶名冊、訂單明細與 RFM 價值標籤！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 shop.sql 建立)

包含 6 張標準關聯表：
1. **`categories`** 與 **`products`**：商品清單與分類
2. **`customers`**：會員顧客名冊（姓名、性別、生日、城市、信箱、加入日）
3. **`orders`**：銷售訂單主檔（日期、客戶、狀態、付款方式）
4. **`order_items`**：訂單明細
5. **`staff`**：經手業務/客服

---

## 3. 前端介面與功能需求 (Tkinter 桌面視窗)

### 3.1 訂單履約工作台 (`ttk.Notebook` 分頁一)
- **狀態過濾選單 (`ttk.Combobox`)**：全部 / 處理中 / 已出貨 / 已完成 / 已取消。
- **訂單主列表 (`ttk.Treeview`)**：顯示單號、日期、客戶姓名、電話、狀態。
- **點擊訂單展開明細**：點擊列表任一列，下方手寫 SQL JOIN 即時帶出該訂單購買的品項清單與小計。

### 3.2 客戶 RFM 價值分群管理 (`ttk.Notebook` 分頁二)
- 手寫 SQL 計算每位會員的：
  - **R (Recency)**：`CURRENT_DATE - MAX(order_date)` 最近消費天數
  - **F (Frequency)**：`COUNT(order_id)` 累計訂單數
  - **M (Monetary)**：`SUM(quantity * unit_price)` 累計消費總金額
- **客群自動貼標**：
  - 🥇 核心 VIP 客戶
  - 💤 沉睡客（超過 90 天未消費）

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 學生在 DBeaver 執行 `shop.sql` 建立資料表無誤。
- [ ] 執行 `python app.py` 立即跳出 Tkinter 本機視窗，點選訂單能即時展開明細。
- [ ] 訂單展開與 RFM 運算全數以手寫 SQL 在 `psycopg2` 中完成。

