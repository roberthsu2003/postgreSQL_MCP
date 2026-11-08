# 步驟 4｜JSONB 回答故事：從規格裡取出需要的資料

> 💻 DBeaver（資料庫：`devices`）｜ 🎯 學完你會：查詢和修改 JSONB 裡的內容

> 📚 先修：[DML-6 JSONB](../../SQL語法教學/16json.md)。

開一個新的 SQL 分頁，存成 `我的查詢.sql`。請照順序做，S4、S5 會改變資料。

## S1｜記憶體 16GB 以上的筆電

`->>` 取出來是文字，比較大小前要用 `::INT` 轉成數字：

```sql
SELECT device_id AS 編號,
       name AS 品名,
       specs->>'cpu' AS CPU,
       (specs->>'ram_gb')::INT AS 記憶體
FROM devices
WHERE device_type = '筆電' AND (specs->>'ram_gb')::INT >= 16
ORDER BY 記憶體 DESC, device_id;
```

**執行結果**

| 編號 | 品名 | CPU | 記憶體 |
|---|---|---|---:|
| NB-008 | Dell XPS 15 | i7-13700H | 32 |
| NB-002 | MacBook Pro 14 | M3 | 18 |
| NB-001 | ThinkPad X1 Carbon | i7-1365U | 16 |
| NB-004 | ASUS ExpertBook B5 | i5-1340P | 16 |
| NB-005 | Dell Latitude 5440 | i5-1335U | 16 |

## S2｜投影機的亮度和解析度

```sql
SELECT name AS 品名,
       (specs->>'lumens')::INT AS 亮度,
       specs->>'resolution' AS 解析度
FROM devices
WHERE device_type = '投影機'
ORDER BY 亮度 DESC;
```

**執行結果**

| 品名 | 亮度 | 解析度 |
|---|---:|---|
| Epson EB-L200F | 4500 | 1920x1080 |
| BenQ MH560 | 3800 | 1920x1080 |
| ViewSonic PA503X | 3600 | 1024x768 |
| Epson CO-FH02 | 3000 | 1920x1080 |

## S3｜支援雙面列印的印表機

```sql
SELECT name AS 品名, specs->>'paper' AS 紙張, department AS 部門
FROM devices
WHERE (specs->>'duplex')::BOOLEAN = true
ORDER BY device_id;
```

**執行結果**

| 品名 | 紙張 | 部門 |
|---|---|---|
| HP LaserJet M404dn | A4 | 管理行政部 |
| Brother HL-L2375DW | A4 | 業務發展部 |
| Epson WF-7310 | A3 | 資訊技術部 |

筆電和投影機沒有 `duplex`，取出來是 `NULL`，不會被列出，也不會報錯。

## S4｜升級記憶體

`jsonb_set` 只改其中一項，其他規格不受影響。數字不用雙引號：

```sql
BEGIN;

UPDATE devices
SET specs = jsonb_set(specs, '{ram_gb}', '16')
WHERE device_id = 'NB-003'
RETURNING device_id, specs;
```

**執行結果**：`NB-003 | {"cpu": "i5-1235U", "ram_gb": 16, "screen_inch": 14}`

確認無誤就送出：

```sql
COMMIT;
```

## S5｜新類型的設備

公司買了平板，規格完全不同，但**不用修改資料表**：

```sql
INSERT INTO devices VALUES ('TB-001', 'iPad Air', '平板', '2024-04-02', 19900, '業務發展部', '{"os": "iPadOS", "storage_gb": 256}')
RETURNING device_id, device_type, specs;
```

**執行結果**：`TB-001 | 平板 | {"os": "iPadOS", "storage_gb": 256}`

如果還是 Excel，這裡就要再新增兩欄，其他 16 列全部空白。

## 你的 `我的查詢.sql`

| 故事 | SQL | 未來 App 的功能 |
|:---:|---|---|
| S1 | `(specs->>'ram_gb')::INT >= 16` | 找高規格筆電 |
| S2 | `specs->>'lumens'` | 投影機清單 |
| S3 | `(specs->>'duplex')::BOOLEAN = true` | 雙面印表機 |
| S4 | `jsonb_set(specs, '{ram_gb}', '16')` | 升級記憶體 |
| S5 | `INSERT ... '{"os": ...}'` | 新增設備 |

> [!TIP]
> 資料被改亂了？執行 [`devices_full.sql`](./devices_full.sql) 就會回到初始狀態。

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| `operator does not exist: text >= integer` | `->>` 取出來是文字 | 加上 `::INT` |
| DBeaver 把 `?` 當成參數 | 工具把 `?` 當佔位符 | 改用 `jsonb_exists(specs, '名稱')` |
| `jsonb_set` 後變成文字 | 數字多包了雙引號 | 數字寫 `'16'`，文字才寫 `'"文字"'` |

## ✍️ 動手練

**第 1 題**：列出 CPU 是 Apple M 系列（以 M 開頭）的設備。

<details>
<summary>看答案</summary>

```sql
SELECT name AS 品名, specs->>'cpu' AS CPU
FROM devices
WHERE specs->>'cpu' LIKE 'M%'
ORDER BY device_id;
```

| 品名 | CPU |
|---|---|
| MacBook Pro 14 | M3 |
| MacBook Air 13 | M2 |

</details>

**第 2 題**：找出規格裡有 `lumens` 的設備。

<details>
<summary>看答案</summary>

```sql
SELECT device_type AS 類型, name AS 品名
FROM devices
WHERE jsonb_exists(specs, 'lumens')
ORDER BY device_id;
```

會列出 4 台投影機。

</details>

**第 3 題**：找出每分鐘可以印 30 頁以上的印表機。

<details>
<summary>看答案</summary>

```sql
SELECT device_id AS 編號, name AS 品名
FROM devices
WHERE (specs->>'ppm')::INT >= 30
ORDER BY device_id;
```

| 編號 | 品名 |
|---|---|
| PR-001 | HP LaserJet M404dn |
| PR-002 | Brother HL-L2375DW |

</details>

## ✅ 過關檢查

- [ ] 五則故事都完成，SQL 都存進 `我的查詢.sql`
- [ ] 我知道比較數字時要加 `::INT`
- [ ] 我親眼看到新類型的設備不用修改資料表

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 3：AI 產生資料交易檔](./3_AI產生資料交易檔.md) | [🏠 實戰專案大綱](../實戰專案大綱.md) | [步驟 5：產生 PRD ➡️](./prompts/01_MCP讀結構產生PRD.md) |
