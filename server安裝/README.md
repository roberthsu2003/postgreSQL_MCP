## postgreSQL on raspberry pi

### 1. 安裝
#### 1.1 更新raspberry

```bash
sudo apt update
sudo apt upgrade
``` 

#### 1.2. 安裝postgresql

```bash
sudo apt install postgresql
```

#### 1.3. 建立postgres user

##### 1.3.1 切換成 postgres 系統帳號（安裝時自動建立的資料庫管理員）

```bash
sudo su postgres
```

##### 1.3.2 建立使用者pi

```bash
createuser pi -P --interactive
```

##### 1.3.3 輸入密碼

```bash
Enter password for new role:
Enter it again:
```

##### 1.3.4 詢問是否為最高管理的使用者
- ###### 按:y

```bash
Shall the new role be a superuser? (y/n) y
```

##### 1.3.5 離開postgresql的設定

```bash
exit
```

### 2. 環境設定(主要是要讓外部的 DBeaver 可以連線)

#### 2.1 更改postgresql.conf

```bash
sudo vim /etc/postgresql/版本號碼/main/postgresql.conf
```

#### 2.2 將listen_addresses由'localhost'更改為'*'

```
# postgresql.conf
listen_addresses = '*'
```

> `max_connections` 預設是 100，教室使用通常足夠。每個連線都會占用記憶體，Raspberry Pi 記憶體有限，不建議調到 1000。

#### 2.3 更改pg_hba.conf

```bash
sudo vim /etc/postgresql/版本號碼/main/pg_hba.conf
```

#### 2.4 在檔案最後加入允許外部連線的設定

建議**新增**以下兩行，而不是修改原本 `127.0.0.1/32`、`::1/128` 那兩行：

```
# pg_hba.conf
# TYPE  DATABASE  USER  ADDRESS      METHOD
host    all       all   0.0.0.0/0    scram-sha-256
host    all       all   ::/0         scram-sha-256
```

> ⚠️ `0.0.0.0/0` 代表**任何 IP** 都可以嘗試連線。只在教室或家中的區網使用；如果只開放給區網，可以改成 `192.168.1.0/24` 這類網段。舊版 PostgreSQL（13 以前）的 METHOD 請改用 `md5`。

#### 2.5 重啟服務

```bash
sudo service postgresql restart
```

### 3. DBeaver 設定

1. 上方選單 **Database → New Database Connection**，選擇 **PostgreSQL**
2. 填入連線資訊：

	| 欄位 | 填入 |
	|---|---|
	| Host | Raspberry Pi 的 IP 或主機名稱（例如 `raspberrypi.local`） |
	| Port | `5432`（預設） |
	| Database | `postgres`（預設） |
	| Username | 1.3 建立的使用者，例如 `pi` |
	| Password | 1.3 設定的密碼，勾選 **Save password** |

3. **PostgreSQL** 分頁勾選 **Show all databases**
4. 按 **Test Connection**，成功後按 **Finish**

> 連不上時，確認第 2 節的 `listen_addresses`、`pg_hba.conf` 都改好並重啟服務，以及 Raspberry Pi 的防火牆有開放 5432 埠。

### 4. 使用命令列(psql)增加使用者
#### 4.1 登入
- pi 是username
- postgres是進入的database
- localhost是本機
```
psql -U pi -d postgres -h localhost
```

#### 4.2 檢查目前的使用者
- **4.2.1 psql語法**

```
postgres=# \du
```

- **4.2.2 sql語法**

```sql
SELECT * FROM pg_roles;
```

#### 4.3 新增使用者
**新使用者沒有建立資料庫的權限**（PostgreSQL 15 起，預設也無法在 `public` schema 建立資料表）

```sql
-- 新增使用者
CREATE USER new_user WITH PASSWORD 'password';
```

**增加使用者建立資料庫的權限**

```sql
-- user 是 SQL 的保留字,不能當作使用者名稱,這裡用 new_user
ALTER USER new_user WITH CREATEDB;
```

**新增使用者,並同時給予建立資料庫的權限**

```sql
CREATE ROLE your_username WITH LOGIN PASSWORD 'your_password' CREATEDB;
```

#### 4.4 刪除使用者

```sql
DROP USER IF EXISTS user_1;
DROP USER IF EXISTS user_1, user_2, user_3;  -- 一次刪除多個
```

#### 4.5 使用者可以透過 DBeaver 連線至 postgres server

依照[第 3 節](#3-dbeaver-設定)的方式，用新使用者的帳號密碼建立連線。

