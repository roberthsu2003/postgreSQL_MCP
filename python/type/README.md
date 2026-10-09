## python type vs postgreSQL type

| python | PostgreSQL |
|:--|:--|
| None | NULL |
| bool | bool |
| float | real, double precision |
| int   | smallint, integer, bigint |
| Decimal | numeric |
| str | varchar, text |
| bytes | bytea |
| date  | date |
| time  | time |
| datetime | timestamp, timestamptz |
| timedelta | interval |
| list | ARRAY |
| UUID | uuid |

> 參考：[psycopg2 官方文件 - Python 型別與 SQL 型別的對應](https://www.psycopg.org/docs/usage.html#adaptation-of-python-values-to-sql-types)
