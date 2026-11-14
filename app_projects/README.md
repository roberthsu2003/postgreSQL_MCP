<div align="center">

# 🚀 第 5 章：實戰專案

**八張職場 Excel，自己手寫 SQL 建表、請 AI 寫出 Transaction 寫入資料，再用微軟 MCP 雙軌練功**

</div>

![八個實戰專案的學習路線](./images/projects_path.svg)

> [!IMPORTANT]
> **動手實作三大鐵則（所有主題一律遵守）**
> 1. **不用匯入資料，親手寫 DDL**：不匯入現成的 `.sql` 救援檔，也不使用 DBeaver CSV 匯入精靈。每個專案都要自己在 DBeaver 手寫 `CREATE DATABASE` 與 `CREATE TABLE`，再逐句塞入「有問題的資料」親自測試防呆約束。
> 2. **用 AI 建立 Transaction（交易）**：把你手寫好的 `CREATE TABLE` 與 Excel 交給 AI，請 AI 產生 `BEGIN; ... INSERT ...; COMMIT;` 交易檔（嚴禁叫 AI 直接透過 MCP 寫入），由你在 DBeaver 審查後親手執行並對帳。
> 3. **10 題 DML × Microsoft Postgres MCP 雙軌驗證**：每個主題都設計了 **10 題 DML 實戰題**（5 則核心故事＋5 題進階 CRUD 與交易）。先自己在 DBeaver 敲出 SQL 跑過，再打開折疊解答核對，並複製每題專屬的 **Microsoft Postgres MCP 查詢 Prompt** 讓 AI 查庫交叉驗證！

> [!TIP]
> 不用等第 4 章全部學完。**教完對應的課程，就可以開始做專案**，邊學語法邊用在真實的 Excel 上。

---

## 📋 八個 Excel 專案

<table>
<tr>
<td width="50%" valign="top">

**1. 🏢 耗材庫存表**

總務・單表

手寫規格與限制條件、AI 產生交易檔、10 題單表 CRUD 與交易練習

📍 教完 DDL-5、DML-3<br>
👉 [進入專案](./excel1_supplies/README.md)

</td>
<td width="50%" valign="top">

**2. 💻 IT 設備規格表**

資訊・單表 + JSONB

判斷固定欄位與 JSONB、寬表轉 JSON 交易、10 題 JSONB 查詢與局部更新

📍 教完 DML-6<br>
👉 [進入專案](./excel2_devices/README.md)

</td>
</tr>
<tr>
<td valign="top">

**3. 👥 打卡表**

人資・一對多

拆成兩張表、處理部門矛盾交易、10 題 `JOIN`、`LEFT JOIN` 與批次補卡交易

📍 教完一對多入門<br>
👉 [進入專案](./excel3_attendance/README.md)

</td>
<td valign="top">

**4. 💼 差旅報銷單**

會計 / 出納・一張拆四張

四表順序與 `setval`、防重複報帳、10 題多表 `JOIN`、審核流程與統計練習

📍 教完進階-2<br>
👉 [進入專案](./excel4_expense/README.md)

</td>
</tr>
<tr>
<td valign="top">

**5. 🛒 網路商店訂單**

業務 / 客服・多對多

明細表、成交單價與目前售價、10 題跨表查詢與 `INSERT ... SELECT` 建單交易

📍 教完進階-3<br>
👉 [進入專案](./excel5_shop/README.md)

</td>
<td valign="top">

**6. 🎧 客服案件紀錄**

客服・一張拆三張

保留原始大小寫交易、10 題 `ILIKE` 搜尋、`GROUP BY` / `HAVING` 與結案檢查交易

📍 教完進階-5<br>
👉 [進入專案](./excel6_tickets/README.md)

</td>
</tr>
<tr>
<td valign="top">

**7. 🎓 教育訓練報名表**

訓練承辦・兩份名單

三張工作表轉五表交易、10 題 `UNION` 合併與 `ON` vs `WHERE` 出席率統計

📍 教完進階-7<br>
👉 [進入專案](./excel7_training/README.md)

</td>
<td valign="top">

**8. ☕ 連鎖門市月報**

店長 / 營運・跨月樣本與暫存表

手寫暫存表＋正式六表、AI 產生跨月交易與 `ON CONFLICT` 防重、10 題樞紐與 CTE 報表

📍 教完進階-9<br>
👉 [進入專案](./excel8_stores/README.md)

</td>
</tr>
</table>

---

| 上一章 | 目錄 | 下一章 |
|:---|:---:|---:|
| [⬅️ 第 4 章 SQL 語法與實戰練功](../SQL語法教學/README.md) | [🏠 課程首頁](../README.md) | [第 6 章 自訂 MCP Server ➡️](../mcp_server/README.md) |
