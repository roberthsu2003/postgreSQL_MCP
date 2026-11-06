# 產品需求文件 (PRD)：企業資產借還與耗材庫存 PyQt5 系統

* **專案代號**：`Assets-PyQt5-Inventory`
* **適用職務**：**總務 (General Affairs)、行政庶務、IT 資產管理、倉管**
* **開發模式**：規格驅動開發 (SDD, Spec-Driven Development)
* **資料庫環境**：PostgreSQL / Supabase (對應 [`assets_inventory.sql`](../../範例資料庫/中文範例資料庫/assets_inventory.sql))
* **前端框架**：**PyQt5** (現代商業桌面視窗 GUI)
* **資料庫存取方式**：Python 原生手寫 SQL (`psycopg2`)，嚴禁使用 MCP 或 ORM 遮蔽 SQL

---

## 1. 職場痛點與專案目標

公司總務或 IT 網管，經常在幾千列的「資產清冊 Excel」中迷航：
1. **設備借走不知去向**：筆電、測試手機、會議投影機被同仁借走，Excel 沒及時更新，急用時找不到人。
2. **耗材臨時斷貨影響辦公**：A4 影印紙、印表機碳粉匣用完了才被同仁催促，缺乏低庫存自動預警機制。
3. **固定資產盤點困難**：資產編號在 Excel 裡常常重複或漏登，折舊與報廢難以管理。

本專案旨在將 `assets_inventory.sql` 資料庫開發為**高質感的 PyQt5 總務資產管理系統**，具備設備借還登記、逾期未還紅字警示與耗材低庫存自動補貨提示！

---

## 2. 資料庫結構 (由學生在 DBeaver 執行 assets_inventory.sql 建立)

包含 4 張標準關聯表：
1. **`asset_categories`**：分類（固定資產設備 / 辦公事務耗材）
2. **`assets`**：資產與耗材主檔（編號、品名、規格、單價、現有庫存、安全庫存警戒水位、存放位置、狀態）
3. **`asset_borrow_logs`**：設備借用與歸還流通紀錄檔（借用人、部門、借出日、預計還期、實際還期、用途、狀態）
4. **`asset_purchase_requests`**：耗材請購採購單

---

## 3. 前端介面與功能需求 (PyQt5 現代視窗)

### 3.1 分頁一：固定設備借還流通櫃台 (`QTableWidget`)
- **借出登記快速面板**：下拉選擇設備編號、輸入同仁姓名與部門、設定預計歸還日期，手寫 SQL 新增借用紀錄並將設備狀態更新為「借出中」。
- **借出中設備追蹤清單**：
  - 顯示目前所有未歸還設備。
  - **逾期未還醒目警示**：若 `CURRENT_DATE > expected_return_date`，整列以紅色高亮標示 🚨 逾期未還。
- **「一鍵歸還核銷」按鈕**：手寫 SQL 更新 `actual_return_date = CURRENT_DATE`，並將設備恢復為「在庫可用」。

### 3.2 分頁二：辦公耗材庫存與安全水位預警 (`QTableWidget`)
- 顯示所有事務耗材（影印紙、碳粉匣、文具）。
- **智能庫存水位警報**：
  - 當 `current_stock <= safety_stock` 時，狀態欄自動顯示黃色警報「需補貨」！
- **「產生請購單」按鈕**：點擊一鍵手寫 SQL 新增至 `asset_purchase_requests`。

---

## 4. 驗收標準 (Acceptance Criteria)

- [ ] 學生在 DBeaver 執行 `assets_inventory.sql` 建立資料表無誤。
- [ ] 執行 `python app.py` 立即跳出 PyQt5 視窗，雙分頁切換流暢。
- [ ] 借還設備狀態切換與耗材庫存扣減全數以手寫 SQL 在 `psycopg2` 中完成。

