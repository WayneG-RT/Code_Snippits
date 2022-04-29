--  category:  Data Definition Language (DDL)
--  description:  (re)Attach a partition

ALTER TABLE account 
ATTACH PARTITION p2011 FROM Archived_2011_Accounts;


--  category:  Data Definition Language (DDL)
--  description:  Add generated columns to a table

ALTER TABLE account
ADD COLUMN audit_type_change CHAR(1) GENERATED ALWAYS AS (DATA CHANGE OPERATION)
ADD COLUMN audit_user VARCHAR(128) GENERATED ALWAYS AS (SESSION_USER) 
ADD COLUMN audit_client_IP VARCHAR(128) GENERATED ALWAYS AS (SYSIBM.CLIENT_IPADDR) 
ADD COLUMN audit_job_name VARCHAR(28) GENERATED ALWAYS AS (QSYS2.JOB_NAME);



--  category:  Data Definition Language (DDL)
--  description:  Alter Sequence

ALTER SEQUENCE seq1 DATA TYPE BIGINT INCREMENT BY 10 MINVALUE 100 NO MAXVALUE CYCLE CACHE 5 ORDER;


--  category:  Data Definition Language (DDL)
--  description:  Alter Sequence to Restart

ALTER SEQUENCE seq1 RESTART;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Add Column

ALTER TABLE table1 ADD COLUMN column3 INTEGER;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Add Materialized Query

ALTER TABLE table1 ADD MATERIALIZED QUERY (select int_col, varchar_col from table3) DATA INITIALLY IMMEDIATE REFRESH DEFERRED MAINTAINED BY USER ENABLE QUERY OPTIMIZATION;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Alter Column

ALTER TABLE table1 ALTER COLUMN column1 SET DATA TYPE DECIMAL(31, 0);


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Drop Column

ALTER TABLE table1 DROP COLUMN column3 INTEGER;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Foreign Key Constraint

ALTER TABLE table1 ADD CONSTRAINT constraint3 FOREIGN KEY (column2) REFERENCES table2 ON DELETE RESTRICT ON UPDATE RESTRICT;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Hash Partition

ALTER TABLE employee ADD PARTITION BY HASH (empno, firstnme, midinit, lastname) INTO 20 PARTITIONS;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Primary Key Constraint

ALTER TABLE table1 ADD CONSTRAINT constraint1 PRIMARY KEY (column1);


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Range Partition

ALTER TABLE employee
  ADD PARTITION BY RANGE (lastname NULLS LAST) (
    PARTITION a_l STARTING FROM ('A') INCLUSIVE ENDING AT ('M') EXCLUSIVE ,
    PARTITION m_z STARTING FROM ('M') INCLUSIVE ENDING AT (MAXVALUE) INCLUSIVE
  );


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Unique Constraint

ALTER TABLE table1 ADD CONSTRAINT constraint2 UNIQUE (column2);


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to be located in memory

ALTER TABLE table1 ALTER KEEP IN MEMORY YES;


--  category:  Data Definition Language (DDL)
--  description:  Alter Table to be located on Solid State Drives

ALTER TABLE table1 ALTER UNIT SSD;


--  category:  Data Definition Language (DDL)
--  description:  Comment for Variable

COMMENT ON VARIABLE MYSCHEMA.MYJOB_PRINTER IS 'Comment for this variable';


--  category:  Data Definition Language (DDL)
--  description:  Comment on Alias

COMMENT ON ALIAS alias1 IS 'comment';


--  category:  Data Definition Language (DDL)
--  description:  Comment on Column

COMMENT ON COLUMN table1 (column2 IS 'comment', column3 IS 'comment');


--  category:  Data Definition Language (DDL)
--  description:  Create Alias for Table

CREATE ALIAS alias1 FOR table1;


--  category:  Data Definition Language (DDL)
--  description:  Create Distinct Type

CREATE DISTINCT TYPE type1 AS INTEGER WITH COMPARISONS;


--  category:  Data Definition Language (DDL)
--  description:  Create Schema

CREATE SCHEMA schema1;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Alias for Table

CREATE OR REPLACE ALIAS alias2 FOR table2(member1);


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Hash Table

CREATE OR REPLACE TABLE phashtable1 (
            empno CHAR(6) NOT NULL, firstnme VARCHAR(12) NOT NULL, lastname VARCHAR(15) CCSID 37 NOT NULL,
            workdept CHAR(3))
    PARTITION BY HASH (workdept) INTO 10 PARTITIONS ;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Range Table

CREATE OR REPLACE TABLE prangetable1 (
            empnum INTEGER, firstnme VARCHAR(12) NOT NULL, lastname VARCHAR(15) NOT NULL, workdept CHAR(3))
    PARTITION BY RANGE (empnum) (
            STARTING FROM (MINVALUE) INCLUSIVE ENDING AT (1000) INCLUSIVE,
            STARTING FROM (1001) INCLUSIVE ENDING AT (MAXVALUE) INCLUSIVE
        );


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Range Table 2

CREATE OR REPLACE TABLE prangetable2 (widget CHAR(100), price DECIMAL(6, 2), date_sold DATE)
    PARTITION BY RANGE (date_sold) (
            STARTING FROM ('2015-01-01') INCLUSIVE ENDING AT ('2021-01-01') EXCLUSIVE EVERY 3 MONTHS
        );


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Sequence

CREATE OR REPLACE SEQUENCE seq1 START WITH 10 INCREMENT BY 10;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table

CREATE OR REPLACE TABLE table1 (column1 INTEGER NOT NULL, column2 VARCHAR(100) ALLOCATE(20));


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table With Constraints

CREATE OR REPLACE TABLE table2 (column1 INTEGER NOT NULL CONSTRAINT constraint9 PRIMARY KEY, column2 DECIMAL(5, 2));


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table With Data Deferred

CREATE OR REPLACE TABLE mqt1 AS
            (SELECT sys_tname, LABEL
                    FROM qsys2.systables
                    WHERE sys_dname = 'QGPL')
            DATA INITIALLY DEFERRED REFRESH DEFERRED MAINTAINED BY USER ENABLE QUERY OPTIMIZATION;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger After Insert

CREATE OR REPLACE TRIGGER NEW_HIRE AFTER INSERT ON EMPLOYEE FOR EACH ROW MODE DB2SQL UPDATE COMPANY_STATS SET NBEMP = NBEMP + 1;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger After Update

CREATE OR REPLACE TRIGGER SAL_ADJ
        AFTER UPDATE OF SALARY ON EMPLOYEE
        REFERENCING OLD AS OLD_EMP NEW AS NEW_EMP FOR EACH ROW MODE DB2SQL
    WHEN (NEW_EMP.SALARY > (OLD_EMP.SALARY * 1.20))
    BEGIN ATOMIC
        SIGNAL SQLSTATE '75001' ('Invalid Salary Increase - Exceeds 20%');
    END;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger Instead of Insert

CREATE OR REPLACE TRIGGER trig2
        INSTEAD OF INSERT ON view1
        REFERENCING NEW newrow FOR EACH ROW
    INSERT INTO table1 (
                column1, column2)
        VALUES (newrow.column1, ENCRYPT_RC2(newrow.column2, 'pwd456'));


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Variable

CREATE OR REPLACE VARIABLE MYSCHEMA.MYJOB_PRINTER VARCHAR(30)DEFAULT 'Default printer';


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace View

CREATE OR REPLACE VIEW view1 AS SELECT column1, column2, column3 FROM table2 WHERE column1 > 5;


--  category:  Data Definition Language (DDL)
--  description:  Create or Replace View With Check Options

CREATE OR REPLACE VIEW view1 AS SELECT * FROM table2 WHERE column1 > 5 WITH CHECK OPTION;


--  category:  Data Definition Language (DDL)
--  description:  Detach a partition

ALTER TABLE account 
DETACH PARTITION p2011 INTO Archived_2011_Accounts;


--  category:  Data Definition Language (DDL)
--  description:  Drop Alias

DROP ALIAS alias1;


--  category:  Data Definition Language (DDL)
--  description:  Drop Distinct Type Cascade

DROP DISTINCT TYPE type1 CASCADE;


--  category:  Data Definition Language (DDL)
--  description:  Drop Schema

DROP SCHEMA schema1;


--  category:  Data Definition Language (DDL)
--  description:  Drop Table and Restrict

DROP TABLE table3 RESTRICT;


--  category:  Data Definition Language (DDL)
--  description:  Drop View Cascade

DROP VIEW view3 CASCADE;


--  category:  Data Definition Language (DDL)
--  description:  Dynamically built CREATE VIEW statement

--  create a sample database
CALL QSYS.CREATE_SQL_SAMPLE('BIERHAUS');

--
-- Generate the column list for a table or view
--
SELECT LISTAGG(CAST(QSYS2.DELIMIT_NAME(COLUMN_NAME) AS CLOB(1M)), 
                   ', ') 
                   WITHIN GROUP ( ORDER BY ORDINAL_POSITION ) AS COLUMN_LIST
      FROM QSYS2.SYSCOLUMNS2 C
        WHERE TABLE_NAME   = 'EMPLOYEE' AND
              TABLE_SCHEMA = 'BIERHAUS'
              AND HIDDEN = 'N'; -- Don't include hidden columns

--
-- Generate a valid CREATE VIEW statement
--

begin
  declare create_view_statement clob(1M) ccsid 37;

  WITH Gen(Column_list) as (
    SELECT LISTAGG(CAST(QSYS2.DELIMIT_NAME(COLUMN_NAME) AS CLOB(1M)), 
                   ', ') 
                   WITHIN GROUP ( ORDER BY ORDINAL_POSITION ) AS COLUMN_LIST
      FROM QSYS2.SYSCOLUMNS2 C
        WHERE TABLE_NAME   = 'EMPLOYEE' AND
              TABLE_SCHEMA = 'BIERHAUS'
              AND HIDDEN = 'N' -- Don't include hidden columns
  )
  select 'create or replace view BIERHAUS.employee_view( '   concat Column_list concat ' )
        as (SELECT ' concat Column_list concat ' from BIERHAUS.employee)'
    into create_view_statement
    from Gen;
  execute immediate create_view_statement;
end;

-- Results in this view being created:
-- create or replace view BIERHAUS.employee_view( EMPNO, FIRSTNME, MIDINIT, LASTNAME, 
--                                                WORKDEPT, PHONENO, HIREDATE, JOB, 
--                                                EDLEVEL, SEX, BIRTHDATE, SALARY, 
--                                                BONUS, COMM )
--   as (SELECT EMPNO, FIRSTNME, MIDINIT, LASTNAME, WORKDEPT, 
--              PHONENO, HIREDATE, JOB, EDLEVEL, SEX, BIRTHDATE, 
--              SALARY, BONUS, COMM from BIERHAUS.employee)
        
        
;

--  category:  Data Definition Language (DDL)
--  description:  Establish a Temporal table
--  minvrm:  v7r3m0

ALTER TABLE account
 ADD COLUMN row_birth TIMESTAMP(12) NOT NULL IMPLICITLY HIDDEN GENERATED ALWAYS AS ROW BEGIN
 ADD COLUMN row_death  TIMESTAMP(12) NOT NULL IMPLICITLY HIDDEN 
   GENERATED ALWAYS AS ROW END    
 ADD COLUMN transaction_time 
   TIMESTAMP(12) IMPLICITLY HIDDEN GENERATED ALWAYS AS TRANSACTION START ID
 ADD PERIOD SYSTEM_TIME (row_birth, row_death);

CREATE TABLE account_hist LIKE account;

ALTER TABLE account 
   ADD VERSIONING USE HISTORY TABLE account_hist;


--  category:  Data Definition Language (DDL)
--  description:  Establish a Temporal table using a partitioned history table
--  minvrm:  v7r3m0

--
--  Note: Partitioning support is enabled via 5770SS1 Option 27 - DB2 Multisystem 
--        Email Scott Forstie (forstie@us.ibm.com) to get a free trial version of this priced option

ALTER TABLE account
 ADD COLUMN row_birth TIMESTAMP(12) NOT NULL IMPLICITLY HIDDEN GENERATED ALWAYS AS ROW BEGIN
 ADD COLUMN row_death  TIMESTAMP(12) NOT NULL IMPLICITLY HIDDEN GENERATED ALWAYS AS ROW END    
 ADD COLUMN transaction_time TIMESTAMP(12) IMPLICITLY HIDDEN GENERATED ALWAYS AS TRANSACTION START ID
 ADD PERIOD SYSTEM_TIME (row_birth, row_death);

CREATE TABLE account_hist LIKE account
PARTITION BY RANGE (row_death)
(PARTITION  p2016 STARTING ('01/01/2016') INCLUSIVE ENDING ('01/01/2017') EXCLUSIVE, 
 PARTITION  p2017 STARTING ('01/01/2017') INCLUSIVE ENDING ('01/01/2018') EXCLUSIVE, 
 PARTITION  p2018 STARTING ('01/01/2018') INCLUSIVE ENDING ('01/01/2019') EXCLUSIVE, 
 PARTITION  p2019 STARTING ('01/01/2019') INCLUSIVE ENDING ('01/01/2020') EXCLUSIVE );

ALTER TABLE account 
   ADD VERSIONING USE HISTORY TABLE account_hist;


--  category:  Data Definition Language (DDL)
--  description:  Label for Variable

LABEL ON VARIABLE MYSCHEMA.MYJOB_PRINTER IS 'Label for this variable';


--  category:  Data Definition Language (DDL)
--  description:  Label on Alias

LABEL ON ALIAS alias1 IS 'label';


--  category:  Data Definition Language (DDL)
--  description:  Label on Column

LABEL ON COLUMN table1 (column2 IS 'label', column3 IS 'label');


--  category:  Data Definition Language (DDL)
--  description:  Refresh Table

REFRESH TABLE mqt1;


--  category:  Data Definition Language (DDL)
--  description:  Rename Table

RENAME TABLE table1 TO table3;


--  category:  Data Definition Language (DDL)
--  description:  Start or stop history tracking for a Temporal table
--  minvrm:  v7r3m0

ALTER TABLE account ADD PERIOD SYSTEM_TIME (row_birth, row_death);
ALTER TABLE account ADD VERSIONING USE HISTORY TABLE account_history;


ALTER TABLE account DROP VERSIONING;
ALTER TABLE account DROP PERIOD SYSTEM_TIME;


