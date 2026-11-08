# 🐘 PostgreSQL 職場實戰學習指南

<div align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PyQt5](https://img.shields.io/badge/GUI-PyQt5-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![Tkinter](https://img.shields.io/badge/GUI-Tkinter-FFD43B?style=for-the-badge&logo=python&logoColor=3776AB)
![DBeaver](https://img.shields.io/badge/Client-DBeaver-382923?style=for-the-badge&logo=dbeaver&logoColor=white)
![FastMCP](https://img.shields.io/badge/Protocol-Model%20Context%20Protocol-8A2BE2?style=for-the-badge)

<br/>

**專為上班族（會計、出納、總務、業務、人資）量身打造！**  
**告別混亂 Excel 痛點 ➡️ 透過 AI 轉換為關聯式 SQL 交易檔 ➡️ 在 DBeaver 親自動手執行 ➡️ 打造專屬個人本機桌面小 App（PyQt5 / Tkinter）**

</div>

---

## 🗺️ 學習路線

![學習路線](./mcp_server/images/learning_roadmap.svg)

---

## 🎯 核心教學理念與安全規範

> [!IMPORTANT]
> **本專案的核心目標是「讓學員扎實學會 SQL 與資料庫架構」，嚴格遵循以下兩大規範：**
> 
> 1. **AI 是助教，手寫才是真功夫**：學員**不可以叫 MCP 寫入資料庫**（建表、新增、修改、刪除），但**可以讓 MCP 讀取**資料庫的結構和資料。AI 提供建議與 SQL，學員必須親自在 **DBeaver** 中檢視並手動執行。第 5 章的實戰專案不受此限。
> 2. **SQL 自己寫，App 由 AI 做**：每則需求的 SQL 都由學員親手寫好並在 DBeaver 跑過。桌面 App 的 Python 由 AI 產生，學員依 `todolist.md` 逐項驗收畫面，並確認每句 SQL 都看得懂。

---

## 🚀 第一次來？這樣開始

1. **選環境**：依個人設備選擇樹莓派 Docker 或 Supabase 雲端方案（免硬體最快）。
2. **照順序走**：第 1 章走到第 6 章，每一章都接著前一章。第 4 章學完一個段落，就可以接著做第 5 章對應的實戰專案。
3. **每課都親手打**：看懂不等於會寫，親自執行每一步再往下走。
4. **卡住了**：先看該課的「⚠️ 常見卡關」，再把 SQL 和錯誤訊息貼給 AI，問它「錯在哪裡，為什麼」。

| 章 | 主題 | 完成後你能 |
|:---:|---|---|
| 1 | [環境安裝](./環境安裝/README.md) | 選擇樹莓派 Docker 或 Supabase 雲端，用 DBeaver 連上資料庫 |
| 2 | [範例資料庫](./範例資料庫/README.md) | 練習匯入資料，建好範例資料庫 |
| 3 | [用中文查詢資料庫](./MCP操作資料庫/README.md) | 不寫 SQL 也能問 AI 查資料 |
| 4 | [SQL 語法與練功](./SQL語法教學/README.md) | **親手寫出跨表報表，並抓出 AI 的錯** |
| 5 | [Excel 實戰專案](./app_projects/README.md) | 把工作上的 Excel 變成資料庫和個人小工具 |
| 6 | [自訂 MCP Server](./mcp_server/README.md) | 讓 AI 只能呼叫你設計的工具 |

**只想學 SQL？** 做完第 1、2 章，直接跳到第 4 章。

---

<div align="center">
<b>為自己的日常工作賦能，從手寫每一句 SQL 開始！</b>
</div>
