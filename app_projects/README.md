<div align="center">

# 🚀 第 5 章：實戰專案

**八張職場 Excel，自己手寫 SQL 建表、請 AI 寫出 Transaction 寫入資料，再用微軟 MCP 雙軌練功**

</div>

![八個實戰專案的學習路線](./images/projects_path.svg)

> [!IMPORTANT]
> **動手實作三大鐵則（所有主題一律遵守）**
> 1. **親手寫 DDL**：每個專案先在 DBeaver 手寫 `CREATE DATABASE` 與 `CREATE TABLE`，再逐句塞入「有問題的資料」測試限制條件。主流程不使用 DBeaver CSV 匯入精靈；步驟 3 提供的純資料交易下載檔，留到自己產生交易後核對，不會代替你建表。
> 2. **用 AI 建立 Transaction（交易）**：把你手寫好的 `CREATE TABLE` 與 Excel 交給 AI，請 AI 產生 `BEGIN; ... INSERT ...; COMMIT;` 交易檔（嚴禁叫 AI 直接透過 MCP 寫入），由你在 DBeaver 審查後親手執行並對帳。
> 3. **10 題 DML × Microsoft Postgres MCP 雙軌驗證**：每個主題都設計了 **10 題 DML 實戰題**（5 則核心故事＋5 題進階 CRUD 與交易）。先自己在 DBeaver 敲出 SQL 跑過，再打開折疊解答核對，並複製每題專屬的 **Microsoft Postgres MCP 查詢 Prompt** 讓 AI 查庫交叉驗證！

> [!TIP]
> 不用等第 4 章全部學完。**教完對應的課程，就可以開始做專案**，邊學語法邊用在真實的 Excel 上。

## 第一次做，照這個順序

先讀 [共用操作指南](./學習與操作指南.md)，再挑一個專案。每個專案的 `README` 是導覽；真正的操作在它連出的步驟 1～4。

| 學習階段 | 要做的事 | 完成時應留下什麼 |
|---|---|---|
| 先完成資料庫實作 | 步驟 1 看 Excel → 步驟 2 手寫建表與測試 → 步驟 3 產生交易並對帳 → 步驟 4 核心故事 S1～S5 | `我的建表.sql`、`建立資料.sql`、`我的查詢.sql` |
| 再完成進階題 | 接著做步驟 4 的 E1～E5；每題使用前面操作後的資料狀態 | 10 題結果與你的解釋 |
| 最後開發桌面 App | 還原初始資料 → 步驟 5 寫 PRD → 步驟 6 拆待辦 → [步驟 7～8 開發與驗收](./桌面App實作指南.md) | 可執行的 App 與逐項驗收紀錄 |

**不用一次完成三個階段。** 下方卡片標的是「可以開始」的時間；要做完所有進階題，還需要下面這些語法。桌面 App 階段由 AI 依 Prompt 協助產生程式與準備環境，學生負責操作與驗收，不要求手寫 Python。

| 專案 | 核心故事所需基礎 | 完成進階題前再補 |
|---|---|---|
| 1 耗材 | 基本查詢、CRUD、交易；`COUNT` / `SUM` 可先跟例子練習 | [聚合與分組](../SQL語法教學/10聚合函式.md)、[子查詢](../SQL語法教學/14子查詢.md)，E4 另有 `CASE` / `STRING_AGG` |
| 2 設備 | JSONB 取值、轉型、局部更新 | [聚合與分組](../SQL語法教學/10聚合函式.md) |
| 3 打卡 | [外來鍵](../SQL語法教學/7_0FOREIGN_KEY.md)、[JOIN](../SQL語法教學/JOIN.md)、交易 | [聚合與分組](../SQL語法教學/10聚合函式.md)、[條件放 ON 或 WHERE](../SQL語法教學/13連結.md) |
| 4 報銷 | 多表 JOIN、外來鍵、SERIAL、交易 | [聚合與分組](../SQL語法教學/10聚合函式.md)，練習 `FILTER` |
| 5 商店 | 多對多、LEFT JOIN、交易、歷史價格 | [聚合與分組](../SQL語法教學/10聚合函式.md)、[子查詢與 CTE](../SQL語法教學/14子查詢.md)，E4 另有視窗彙總 |
| 6 客服 | 模糊搜尋、GROUP BY、HAVING、JOIN | 本專案補充 `FILTER` 與日期相減 |
| 7 訓練 | UNION、LEFT JOIN、分組與三態布林 | [子查詢與 CTE](../SQL語法教學/14子查詢.md) |
| 8 門市 | 多表 JOIN、聚合、CTE、交易 | 本專案補充暫存區、`INSERT ... SELECT`、`ON CONFLICT` |

📥 八個專案的 Excel 與純資料交易下載連結，集中在 [共用操作指南的下載表](./學習與操作指南.md#範例下載與初始對帳)，各專案步驟 3 也有連結。

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

📍 教完一對多入門、DML-4 外來鍵與 DML-5 JOIN<br>
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
