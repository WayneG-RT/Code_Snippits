--  category:  Data-Manipulation-Language-(DML)
--  description:  Delete From Table

DELETE FROM table1 WHERE column1 = 0;


--  category:  Data Manipulation Language (DML)
--  description:  Insert into Column in Table

INSERT INTO table1 (column1) VALUES(0);


--  category:  Data Manipulation Language (DML)
--  description:  Insert into Column in Table From Another Column

INSERT INTO table1 (column1) SELECT column1 FROM table2 WHERE column1 > 5;


--  category:  Data Manipulation Language (DML)
--  description:  Insert into Table

INSERT INTO table1 VALUES(0, 'AAA', 1);


--  category:  Data Manipulation Language (DML)
--  description:  Merge into Table

MERGE INTO t1 USING 
  (SELECT id, c2 FROM t2) x ON 
     t1.id = x.id 
  WHEN NOT MATCHED THEN INSERT VALUES (id, c2) 
  WHEN MATCHED THEN UPDATE SET c2 = x.c2;


--  category:  Data Manipulation Language (DML)
--  description:  Select All From Table

SELECT * FROM QSYS2.SYSTABLES;


--  category:  Data Manipulation Language (DML)
--  description:  Select All from Table with Where Clause

SELECT * FROM QSYS2.SYSTABLES WHERE TABLE_NAME LIKE 'FILE%';


--  category:  Data Manipulation Language (DML)
--  description:  Select Table Schema and Group By

SELECT TABLE_SCHEMA, COUNT(*) AS "COUNT" FROM QSYS2.SYSTABLES GROUP BY TABLE_SCHEMA ORDER BY "COUNT" DESC;


--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Continue Identity

TRUNCATE table1 CONTINUE IDENTITY;


--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Ignoring Delete Triggers

TRUNCATE table1 IGNORE DELETE TRIGGERS;


--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Restart Identity Immediate

TRUNCATE table1 RESTART IDENTITY IMMEDIATE;


--  category:  Data Manipulation Language (DML)
--  description:  Update Column in Table

UPDATE table1 SET column1 = 0 WHERE column1 < 0;


--  category:  Data Manipulation Language (DML)
--  description:  Update Columns in Table with Columns from another Table

UPDATE table1 SET (column1, column2) = (SELECT column1, column2 FROM table2 WHERE table1.column3 = column3);


--  category:  Data Manipulation Language (DML)
--  description:  Update Row in Table

UPDATE table1 SET ROW = (column1, ' ', column3);


--  category:  Data Manipulation Language (DML)
--  description:  Use FOR UPDATE to launch Edit Table

CALL qsys.create_sql_sample('BUSINESS_NAME');

-- Normal query - read only
SELECT *
   FROM business_name.sales;

-- Edit Table mode in ACS
SELECT *
   FROM business_name.sales
   FOR UPDATE;


