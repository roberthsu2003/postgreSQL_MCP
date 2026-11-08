# 步驟 3｜AI 產生資料交易檔：把寬表轉成 JSON

> 💻 AI 對話框 + DBeaver（資料庫：`devices`）｜ 🎯 學完你會：請 AI 把很多空白欄位轉成 JSON，並驗收結果

> 📚 先修：[專案 1 步驟 3](../excel1_supplies/3_AI產生資料交易檔.md)。

## 🎬 情境

這次 AI 要做的轉換比較多：把 CPU、記憶體這些欄位組成 JSON，空白的要略過，「是／否」要變成 `true` / `false`。

## 1. 請 AI 產生交易檔

附加 `設備規格表.xlsx`，貼上以下提示詞，並填入你手寫的 SQL：

```text
你是 PostgreSQL 教學助教。我附上一份 Excel，請只讀取「設備清單」工作表。

這是我親手建立的資料表，請嚴格依照它的表名和欄位名稱：
（貼上你的 CREATE TABLE）

規格欄位請組成 specs 的 JSON，名稱對照如下，空白的儲存格不要放進 JSON：
CPU=cpu、記憶體(GB)=ram_gb、螢幕(吋)=screen_inch、亮度(流明)=lumens、解析度=resolution、列印速度(頁/分)=ppm、雙面列印=duplex、紙張=paper

型別規則：ram_gb、screen_inch、lumens、ppm 是數字；duplex 是 true 或 false（是=true，否=false）；其他是文字。

請產生一份資料交易檔：
1. 只能有 BEGIN;、INSERT 和 COMMIT;，不要 CREATE、DROP、ALTER 或 TRUNCATE。
2. INSERT 要明確寫出欄位名稱。
3. 16 筆全部轉換，不可省略，也不可修改內容。

請直接輸出 SQL 程式碼，我會自己在 DBeaver 檢查後執行。
```

## 2. 執行前先檢查

| 檢查項目 | 應該看到 |
|---|---|
| 開頭和結尾 | `BEGIN;` 和 `COMMIT;` 都有 |
| 筆電的規格 | 只有 `cpu`、`ram_gb`、`screen_inch` |
| 數字 | `"ram_gb": 16`，16 沒有雙引號 |
| 雙面列印 | `"duplex": true`，不是 `"是"` |

可以和標準答案 [`devices_data.sql`](./devices_data.sql) 對照。

## 3. 匯入並對帳

按 `Alt + X`（Mac：`Opt + X`）執行整份。失敗時**先執行 `ROLLBACK;`**。

先在「設備清單」工作表輸入公式：

| 項目 | Excel 公式 | 答案 |
|---|---|---:|
| 設備數 | `=COUNTA(A2:A17)` | 16 |
| 總金額 | `=SUM(E2:E17)` | 466000 |
| 筆電數 | `=COUNTIF(C2:C17,"筆電")` | 8 |
| 記憶體 16 以上 | `=COUNTIF(H2:H17,">=16")` | 5 |

再用 SQL 算一次：

```sql
SELECT COUNT(*) AS 設備數,
       SUM(price) AS 總金額,
       COUNT(*) FILTER (WHERE device_type = '筆電') AS 筆電數,
       COUNT(*) FILTER (WHERE (specs->>'ram_gb')::INT >= 16) AS 記憶體16以上
FROM devices;
```

**執行結果**

| 設備數 | 總金額 | 筆電數 | 記憶體16以上 |
|---:|---:|---:|---:|
| 16 | 466000 | 8 | 5 |

## ⚠️ 常見卡關

| 狀況 | 原因 | 怎麼解 |
|---|---|---|
| `invalid input syntax for type json` | AI 的 JSON 格式有誤 | 先 `ROLLBACK;`，把錯誤訊息貼給 AI |
| 記憶體 16 以上是 0 筆 | AI 沒有存成數字，或欄位名稱不同 | 檢查 JSON 的名稱是不是 `ram_gb` |
| 結構真的修不好 | 想從乾淨狀態重來 | 執行 [`devices_full.sql`](./devices_full.sql)，它會**取代你手寫的表** |

---

| 上一步 | 目錄 | 下一步 |
|:---|:---:|---:|
| [⬅️ 步驟 2：手寫 DDL](./2_手寫DDL.md) | [🏠 專案說明](./README.md) | [步驟 4：JSONB 回答故事 ➡️](./4_JSONB回答故事.md) |
