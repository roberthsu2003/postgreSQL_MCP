/*ON DELETE action*/
/*ON DELETE SET NULL->當foreign key 對應的primary key 被刪除時,對應的foreign key資料全設為NULL*/
/*ON DELETE CASCADE->當foreign key 對應的primary key 被刪除時,對應的資料全部刪除*/

/*
以下是 7創建關聯資料庫.sql 建立資料表時的設定(只是複習,不要再執行):

CREATE TABLE branch(
	...
	FOREIGN KEY(manager_id)
	REFERENCES employee(emp_id) ON DELETE SET NULL      <- 經理離職,部門的 manager_id 設為 NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(sup_id)
REFERENCES employee(emp_id) ON DELETE SET NULL;      <- 主管離職,部屬的 sup_id 設為 NULL

CREATE TABLE works_with(
	...
	FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,   <- 員工離職,銷售紀錄一起刪除
	...
);
*/

/*小綠(emp_id=207)是行政部門的經理,也是小白、小藍的主管*/
DELETE FROM employee
WHERE name = '小綠';

/*ON DELETE SET NULL:行政部門的 manager_id 變成 NULL*/
SELECT *
FROM branch;

/*ON DELETE SET NULL:小白、小藍的 sup_id 變成 NULL*/
SELECT *
FROM employee;

/*ON DELETE CASCADE:works_with 中小綠(emp_id=207)的銷售紀錄被刪除*/
SELECT *
FROM works_with;
