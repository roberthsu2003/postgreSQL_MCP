# 第 1 章：環境安裝

> 🎯 學完你會：用 DBeaver 連上自己的 PostgreSQL 資料庫

[← 回課程首頁](../README.md)

本課程採用**容器化標準（Docker）**或**雲端免安裝託管**，免除繁瑣的原生環境設定。資料庫管理一律使用開源直覺的 **DBeaver** 圖形客戶端：

| 環境 / 安裝方式 | 包含內容 | 推薦對象 | 教學連結 |
|---|---|:---:|:---:|
| 🍓 **Raspberry Pi（Docker 容器推薦）** | 樹莓派 Docker 安裝、PostgreSQL 容器化運行、DBeaver SSH 隧道、專案 MCP 雙容器整合 | 想在家中打造專屬常駐資料庫伺服器者 | [查看教學](../raspberry_docker安裝/README.md) |
| ☁️ **Supabase（免費雲端託管）** | 免硬體！申請免費雲端託管 PostgreSQL、取得連線字串、DBeaver 直連設定 | 零硬體負擔、想隨開即用立即開始者 | [查看教學](../supabase安裝/README.md) |

> 💡 **連線字串格式範例**：`postgresql://使用者名稱:密碼@主機IP:5432/資料庫名稱`
>
> 📖 DBeaver 的常用操作，請見 [DBeaver 速查表](../raspberry_docker安裝/3_dbeaver連線.md#步驟-33dbeaver-常用操作速查表)。

👉 **下一步：[第 2 章：範例資料庫](../範例資料庫/README.md)**
