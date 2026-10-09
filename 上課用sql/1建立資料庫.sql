/*建立資料庫*/
/*不可以使用 MySQL 的反引號寫法 `sql_tutorial`;沒有加雙引號的名稱會自動轉成小寫 sql_tutorial*/
CREATE DATABASE SQL_TUTORIAL;

/*
不可以使用 MySQL 的 SHOW DATABASES;
要使用 psql 的 \l,或在 DBeaver 左側連線底下的 Databases 查看
*/

/*刪除資料庫*/
DROP DATABASE SQL_TUTORIAL;
