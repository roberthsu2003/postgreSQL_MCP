<div align="center">

# 🚀 第 5 章：實戰專案

**八張職場 Excel，由淺入深，做成八個自己電腦上的小工具**

[← 回課程首頁](../README.md)

</div>

![八個實戰專案的學習路線](./images/projects_path.svg)

<div align="center">

**快速前往**　[📋 八個專案](#-八個-excel-專案)　·　[🛠 怎麼做](#-每個專案怎麼做)　·　[📍 教到哪裡可以用](#-教到哪裡可以用)　·　[🎓 畢業專題](#-畢業專題換你的-excel)　·　[✅ 專案驗收](#-專案驗收)

</div>

> [!TIP]
> 不用等第 4 章全部學完。**教完對應的課程，就可以開始做專案**，邊學語法邊用在真實的 Excel 上。

---

## 📋 八個 Excel 專案

<table>
<tr>
<td width="50%" valign="top">

**1. 🏢 耗材庫存表**

總務・單表

從 Excel 訂欄位規格、限制條件、基本 DML

📍 教完 DDL-5、DML-3<br>
👉 [進入專案](./excel1_supplies/README.md)

</td>
<td width="50%" valign="top">

**2. 💻 IT 設備規格表**

資訊・單表 + JSONB

判斷哪些資料適合 JSONB，查詢和修改規格

📍 教完 DML-6<br>
👉 [進入專案](./excel2_devices/README.md)

</td>
</tr>
<tr>
<td valign="top">

**3. 👥 打卡表**

人資・一對多

拆成兩張表、處理矛盾資料、`JOIN` 與 `LEFT JOIN`

📍 教完一對多入門<br>
👉 [進入專案](./excel3_attendance/README.md)

</td>
<td valign="top">

**4. 💼 差旅報銷單**

會計 / 出納・一張拆四張

自動編號與 `setval`、防重複報帳、審核流程

📍 教完進階-2<br>
👉 [進入專案](./excel4_expense/README.md)

</td>
</tr>
<tr>
<td valign="top">

**5. 🛒 網路商店訂單**

業務 / 客服・多對多

明細表、成交單價與目前售價、用交易建立訂單

📍 教完進階-3<br>
👉 [進入專案](./excel5_shop/README.md)

</td>
<td valign="top">

**6. 🎧 客服案件紀錄**

客服・一張拆三張

搜尋寫法不一致的文字、分組統計工作量

📍 教完進階-5<br>
👉 [進入專案](./excel6_tickets/README.md)

</td>
</tr>
<tr>
<td valign="top">

**7. 🎓 教育訓練報名表**

訓練承辦・兩份名單

合併內外部名單、`ON` 與 `WHERE` 的差別

📍 教完進階-7<br>
👉 [進入專案](./excel7_training/README.md)

</td>
<td valign="top">

**8. ☕ 連鎖門市月報**

店長 / 營運・跨月多檔

CSV 暫存表、每月重複匯入、SQL 版樞紐分析

📍 教完進階-9<br>
👉 [進入專案](./excel8_stores/README.md)

</td>
</tr>
</table>

---

## 🛠 每個專案怎麼做

每個專案都是同樣的八個步驟，前半段親手寫 SQL，後半段請 AI 做成 App。

<table>
<tr>
<td width="50%" valign="top">

**✍️ 步驟 1～4：親手寫 SQL**

1. 看懂 Excel 和工作需求
2. 手寫 DDL，建立資料表
3. AI 轉資料，匯入後和 Excel 對帳
4. 手寫 DML，完成每則需求

</td>
<td width="50%" valign="top">

**🤖 步驟 5～8：AI 做成 App**

5. AI 用唯讀 MCP 讀結構，寫 `PRD.md`
6. AI 把 PRD 拆成 `todolist.md`
7. 設定資料庫連線
8. AI 一次做一項，你一次驗收一項

</td>
</tr>
</table>

| 工作 | 學員 | AI |
|---|:---:|:---:|
| 寫 user story、驗收條件 | ✅ | 協助檢查 |
| 手寫 DDL、DML | ✅ | 只當助教 |
| 把 Excel 轉成資料交易檔 | 檢查與對帳 | ✅ |
| `PRD.md`、`todolist.md` | 審核與修改 | ✅ 用唯讀 MCP 讀結構 |
| Python 與視窗程式 | 依 `todolist.md` 驗收 | ✅ |

> [!NOTE]
> 步驟 5 之前，請先依照 [MCP 設定教學](../MCP操作資料庫/1_antigravity設定.md)連線。

---

## 📍 教到哪裡可以用

給老師備課用：照第 4 章的順序上課，**教完左邊這一課，就可以帶學生做右邊的專案**。

| 教完這一課 | 可以做 | 步驟 | 課堂上要提醒 |
|---|---|:---:|---|
| DDL-5 限制條件 | [專案 1 耗材庫存表](./excel1_supplies/README.md) | 1、2 | 步驟 2 的測試 `INSERT` 直接貼上即可，DML-1 才正式教 |
| DML-3 修改與刪除 | [專案 1 耗材庫存表](./excel1_supplies/README.md) | 3、4 | `SUM` 講義有一句說明，當成 Excel 的 SUM 即可 |
| DML-6 JSONB | [專案 2 IT 設備規格表](./excel2_devices/README.md) | 1～4 | 空白的規格不放進 JSON |
| 一對多入門 | [專案 3 打卡表](./excel3_attendance/README.md) | 1～4 | 不需要先學 DML-6 JSONB |
| 進階-2 關聯新增 | [專案 4 差旅報銷單](./excel4_expense/README.md) | 1～4 | `SUM` 講義有一句說明 |
| 進階-3 關聯搜尋 | [專案 5 網路商店訂單](./excel5_shop/README.md) | 1～4 | `SUM` 講義有一句說明；`INSERT ... SELECT` 專案內會解釋 |
| 進階-5 模糊搜尋 | [專案 6 客服案件紀錄](./excel6_tickets/README.md) | 1～4 | 也會用到進階-4 的 `GROUP BY`、`HAVING` |
| 進階-7 綜合連結 | [專案 7 教育訓練報名表](./excel7_training/README.md) | 1～4 | 也會用到進階-6 的 `UNION` |
| 進階-9 ON DELETE | [專案 8 連鎖門市月報](./excel8_stores/README.md) | 1～4 | 暫存表、`ON CONFLICT` 專案內會解釋 |
| 學完第 4 章 | 任一專案 | 5～8 | 建議挑 1～2 個專案做到 App；需要第 3 章的 MCP 設定 |

📚 完整規劃請見[實戰專案大綱](./實戰專案大綱.md)。

---

## 🎓 畢業專題：換你的 Excel

做完專案後，拿自己工作上的 Excel 走一次同樣的流程：先脫敏、自己手寫建表，再請 AI 處理資料，最後做成自己的小工具。

### 👉 [開始畢業專題](./畢業專題_換你的Excel.md)

---

## ✅ 專案驗收

每個專案做到 App 時，都打勾了才算完成：

- [ ] `python app.py` 能開啟視窗，資料來自資料庫
- [ ] 所有 SQL 都是我看得懂、驗收過的
- [ ] 使用者輸入一律用 `%s` 傳遞，密碼放在 `.env`
- [ ] 故意輸入錯誤資料，App 不會當掉，也會顯示中文訊息

---

| 上一章 | 目錄 | 下一章 |
|:---|:---:|---:|
| [⬅️ 第 4 章 SQL 語法與實戰練功](../SQL語法教學/README.md) | [🏠 課程首頁](../README.md) | [第 6 章 自訂 MCP Server ➡️](../mcp_server/README.md) |
