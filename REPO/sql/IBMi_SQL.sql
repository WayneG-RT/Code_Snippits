/*MERGE ALL SQL EXAMPLES
 
 Version 7.3
 */
/*sql/Built-in-Global-Variables.sql*/
--  category:  Built-in Global Variables
--  description:  Client Host
--  minvrm:  v7r2m0
VALUES (sysibm.client_host);
--  category:  Built-in Global Variables
--  description:  Client IP Address
--  minvrm:  v7r2m0
VALUES (sysibm.client_ipaddr);
--  category:  Built-in Global Variables
--  description:  Client Port
--  minvrm:  v7r2m0
VALUES (sysibm.client_port);
--  category:  Built-in Global Variables
--  description:  Job Name
--  minvrm:  v7r2m0
VALUES (qsys2.job_name);
--  category:  Built-in Global Variables
--  description:  Package Name
--  minvrm:  v7r2m0
VALUES (sysibm.package_name);
--  category:  Built-in Global Variables
--  description:  Package Schema
--  minvrm:  v7r2m0
VALUES (sysibm.package_schema);
--  category:  Built-in Global Variables
--  description:  Package Version
--  minvrm:  v7r2m0
VALUES (sysibm.package_version);
--  category:  Built-in Global Variables
--  description:  Process Identifier
--  minvrm:  v7r2m0
VALUES (qsys2.process_id);
--  category:  Built-in Global Variables
--  description:  Routine Schema
--  minvrm:  v7r2m0
VALUES (sysibm.routine_schema);
--  category:  Built-in Global Variables
--  description:  Routine Specific Name
--  minvrm:  v7r2m0
VALUES (sysibm.routine_specific_name);
--  category:  Built-in Global Variables
--  description:  Routine Type
--  minvrm:  v7r2m0
VALUES (sysibm.routine_type);
--  category:  Built-in Global Variables
--  description:  Server Mode Job Name
--  minvrm:  v7r2m0
VALUES (qsys2.server_mode_job_name);
--  category:  Built-in Global Variables
--  description:  Thread Identifier
VALUES (qsys2.thread_id);
/*sql/Data-Control-Language-(DCL).sql*/
--  category:  Data Control Language (DCL)
--  description:  Alter Mask Disable
--  minvrm:  v7r2m0
ALTER mask ssn_mask disable;
--  category:  Data Control Language (DCL)
--  description:  Alter Mask Enable
--  minvrm:  v7r2m0
ALTER mask ssn_mask enable;
--  category:  Data Control Language (DCL)
--  description:  Alter Mask Regenerate
--  minvrm:  v7r2m0
ALTER mask ssn_mask regenerate;
--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Disable
--  minvrm:  v7r2m0
ALTER permission nethmo.row_access disable;
--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Enable
--  minvrm:  v7r2m0
ALTER permission nethmo.row_access enable;
--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Regenerate
--  minvrm:  v7r2m0
ALTER permission nethmo.row_access regenerate;
--  category:  Data Control Language (DCL)
--  description:  Alter Table Activate Column Access Control
--  minvrm:  v7r2m0
ALTER TABLE employee activate COLUMN access control;
--  category:  Data Control Language (DCL)
--  description:  Alter Table Activate Row Access Control
--  minvrm:  v7r2m0
ALTER TABLE hospital.patient activate row access control;
--  category:  Data Control Language (DCL)
--  description:  Create or Replace Mask
--  minvrm:  v7r2m0
CREATE OR replace mask ssn_mask ON employee FOR COLUMN ssn RETURN CASE
    WHEN (
      VERIFY_GROUP_FOR_USER(SESSION_USER, 'PAYROLL') = 1
    ) THEN ssn
    WHEN (VERIFY_GROUP_FOR_USER(SESSION_USER, 'MGR') = 1) THEN 'XXX-XX-' concat SUBSTR(ssn, 8, 4)
    ELSE NULL
  END enable;
--  category:  Data Control Language (DCL)
--  description:  Create or Replace Permission
--  minvrm:  v7r2m0
CREATE OR replace permission nethmo.row_access ON hospital.patient FOR rows
WHERE (
    VERIFY_GROUP_FOR_USER(SESSION_USER, 'PATIENT') = 1
    AND hospital.patient.userid = SESSION_USER
  )
  OR (
    VERIFY_GROUP_FOR_USER(SESSION_USER, 'PCP') = 1
    AND hospital.patient.pcp_id = SESSION_USER
  )
  OR (
    VERIFY_GROUP_FOR_USER(SESSION_USER, 'MEMBERSHIP') = 1
    OR VERIFY_GROUP_FOR_USER(SESSION_USER, 'ACCOUNTING') = 1
    OR VERIFY_GROUP_FOR_USER(SESSION_USER, 'DRUG_RESEARCH') = 1
  ) enforced FOR ALL access enable;
--  category:  Data Control Language (DCL)
--  description:  Grant Alter, Index on Table to Public
GRANT ALTER,
  INDEX ON table3 TO PUBLIC;
--  category:  Data Control Language (DCL)
--  description:  Grant Select, Delete, Insert, Update on Table to Public with Grant Option
GRANT SELECT,
  DELETE,
  INSERT,
  UPDATE ON TABLE table3 TO PUBLIC WITH
GRANT OPTION;
--  category:  Data Control Language (DCL)
--  description:  Grant Update Column to Public
GRANT UPDATE (column1) ON table2 TO PUBLIC;
--  category:  Data Control Language (DCL)
--  description:  Grant all Privileges to Public
GRANT ALL privileges ON table3 TO PUBLIC;
--  category:  Data Control Language (DCL)
--  description:  Revoke Alter, Index on Table From Public
REVOKE ALTER,
INDEX ON table3
FROM PUBLIC;
--  category:  Data Control Language (DCL)
--  description:  Revoke Select, Delete, Insert, Update On Table From Public
REVOKE
SELECT,
  DELETE,
  INSERT,
  UPDATE ON TABLE table3
FROM PUBLIC;
--  category:  Data Control Language (DCL)
--  description:  Revoke Update Column from Public
REVOKE
UPDATE (column1) ON table2
FROM PUBLIC;
--  category:  Data-Control-Language-(DCL)
--  description:  Revoke all Privileges from Public
REVOKE ALL privileges ON table3
FROM PUBLIC;
/*sql/Data-Definition-Language-(DDL).sql*/
--  category:  Data Definition Language (DDL)
--  description:  (re)Attach a partition
ALTER TABLE account attach partition p2011
FROM archived_2011_accounts;
--  category:  Data Definition Language (DDL)
--  description:  Add generated columns to a table
ALTER TABLE account
ADD COLUMN audit_type_change CHAR (1) generated always AS (data change operation)
ADD COLUMN audit_user VARCHAR (128) generated always AS (SESSION_USER)
ADD COLUMN audit_client_ip VARCHAR (128) generated always AS (sysibm.client_ipaddr)
ADD COLUMN audit_job_name VARCHAR (28) generated always AS (qsys2.job_name);
--  category:  Data Definition Language (DDL)
--  description:  Alter Sequence
ALTER sequence seq1 data type BIGINT increment BY 10 minvalue 100 no maxvalue cycle cache 5 ORDER;
--  category:  Data Definition Language (DDL)
--  description:  Alter Sequence to Restart
ALTER sequence seq1 restart;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Add Column
ALTER TABLE table1
ADD COLUMN column3 integer;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Add Materialized Query
ALTER TABLE table1
ADD materialized QUERY(
    SELECT int_col,
      varchar_col
    FROM table3
  ) data initially immediate refresh deferred maintained BY USER enable query optimization;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Alter Column
ALTER TABLE table1
ALTER COLUMN column1
SET data type DECIMAL (31, 0);
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to Drop Column
ALTER TABLE table1 DROP COLUMN column3 integer;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Foreign Key Constraint
ALTER TABLE table1
ADD CONSTRAINT constraint3 FOREIGN KEY (column2) REFERENCES table2 ON DELETE RESTRICT ON
UPDATE RESTRICT;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Hash Partition
ALTER TABLE employee
ADD partition BY HASH(empno, firstnme, midinit, lastname) INTO 20 partitions;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Primary Key Constraint
ALTER TABLE table1
ADD CONSTRAINT constraint1 PRIMARY KEY (column1);
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Range Partition
ALTER TABLE employee
ADD partition BY RANGE(lastname nulls last) (
    partition a_l starting
    FROM ('A') inclusive ending AT('M') exclusive,
      partition m_z starting
    FROM ('M') inclusive ending AT(maxvalue) inclusive
  );
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to add Unique Constraint
ALTER TABLE table1
ADD CONSTRAINT constraint2 UNIQUE (column2);
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to be located in memory
ALTER TABLE table1 ALTER keep IN memory yes;
--  category:  Data Definition Language (DDL)
--  description:  Alter Table to be located on Solid State Drives
ALTER TABLE table1 ALTER unit ssd;
--  category:  Data Definition Language (DDL)
--  description:  Comment for Variable
comment ON variable myschema.myjob_printer IS 'Comment for this variable';
--  category:  Data Definition Language (DDL)
--  description:  Comment on Alias
comment ON alias alias1 IS 'comment';
--  category:  Data Definition Language (DDL)
--  description:  Comment on Column
comment ON COLUMN TABLE1(column2 IS 'comment', column3 IS 'comment');
--  category:  Data Definition Language (DDL)
--  description:  Create Alias for Table
CREATE alias alias1 FOR table1;
--  category:  Data Definition Language (DDL)
--  description:  Create Distinct Type
CREATE DISTINCT type type1 AS integer WITH comparisons;
--  category:  Data Definition Language (DDL)
--  description:  Create Schema
CREATE SCHEMA schema1;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Alias for Table
CREATE OR replace alias alias2 FOR TABLE2(member1);
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Hash Table
CREATE OR replace TABLE PHASHTABLE1(
    empno CHAR (6) NOT NULL,
    firstnme VARCHAR (12) NOT NULL,
    lastname VARCHAR (15) ccsid 37 NOT NULL,
    workdept CHAR (3)
  ) partition BY HASH(workdept) INTO 10 partitions;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Range Table
CREATE OR replace TABLE PRANGETABLE1(
    empnum integer,
    firstnme VARCHAR (12) NOT NULL,
    lastname VARCHAR (15) NOT NULL,
    workdept CHAR (3)
  ) partition BY RANGE(empnum) (
    starting
    FROM (minvalue) inclusive ending AT(1000) inclusive,
      starting
    FROM (1001) inclusive ending AT(maxvalue) inclusive
  );
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Range Table 2
CREATE OR replace TABLE PRANGETABLE2(
    widget CHAR(100),
    price DECIMAL(6, 2),
    date_sold DATE
  ) partition BY RANGE(date_sold) (
    starting
    FROM ('2015-01-01') inclusive ending AT('2021-01-01') exclusive every 3 months
  );
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Sequence
CREATE OR replace sequence seq1 start WITH 10 increment BY 10;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table
CREATE OR replace TABLE TABLE1(
    column1 integer NOT NULL,
    column2 VARCHAR(100) ALLOCATE(20)
  );
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table With Constraints
CREATE OR replace TABLE TABLE2(
    column1 integer NOT NULL CONSTRAINT constraint9 PRIMARY KEY,
    column2 DECIMAL (5, 2)
  );
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Table With Data Deferred
CREATE OR replace TABLE mqt1 AS (
    SELECT sys_tname,
      label
    FROM qsys2.systables
    WHERE sys_dname = 'QGPL'
  ) data initially deferred refresh deferred maintained BY USER enable query optimization;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger After Insert
CREATE OR replace TRIGGER new_hire
AFTER
INSERT ON employee FOR each row mode db2sql
UPDATE company_stats
SET nbemp = nbemp + 1;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger After Update
CREATE OR replace TRIGGER sal_adj
AFTER
UPDATE OF salary ON employee referencing old AS old_emp new AS new_emp FOR each row mode db2sql
  WHEN (new_emp.salary > (old_emp.salary * 1.20)) BEGIN atomic signal sqlstate '75001' ('Invalid Salary Increase - Exceeds 20%');
END;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Trigger Instead of Insert
CREATE OR replace TRIGGER trig2 instead OF
INSERT ON view1 referencing new newrow FOR each row
INSERT INTO TABLE1(column1, column2)
VALUES (
    newrow.column1,
    ENCRYPT_RC2(newrow.column2, 'pwd456')
  );
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace Variable
CREATE OR replace variable myschema.myjob_printer VARCHAR (30) DEFAULT 'Default printer';
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace View
CREATE OR replace VIEW view1 AS
SELECT column1,
  column2,
  column3
FROM table2
WHERE column1 > 5;
--  category:  Data Definition Language (DDL)
--  description:  Create or Replace View With Check Options
CREATE OR replace VIEW view1 AS
SELECT *
FROM table2
WHERE column1 > 5 WITH CHECK OPTION;
--  category:  Data Definition Language (DDL)
--  description:  Detach a partition
ALTER TABLE account detach partition p2011 INTO archived_2011_accounts;
--  category:  Data Definition Language (DDL)
--  description:  Drop Alias
DROP alias alias1;
--  category:  Data Definition Language (DDL)
--  description:  Drop Distinct Type Cascade
DROP DISTINCT type type1 CASCADE;
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
call QSYS.CREATE_SQL_SAMPLE('BIERHAUS');
--
-- Generate the column list for a table or view
--
SELECT LISTAGG(
    CAST(QSYS2.DELIMIT_NAME(column_name) AS CLOB(1 m)),
    ', '
  ) WITHIN GROUP (
    ORDER BY ordinal_position
  ) AS column_list
FROM qsys2.syscolumns2 c
WHERE table_name = 'EMPLOYEE'
  AND table_schema = 'BIERHAUS'
  AND hidden = 'N';
-- Don't include hidden columns
--
-- Generate a valid CREATE VIEW statement
--
BEGIN
DECLARE create_view_statement CLOB(1 m) ccsid 37;
WITH GEN(column_list) AS (
  SELECT LISTAGG(
      CAST(QSYS2.DELIMIT_NAME(column_name) AS CLOB(1 m)),
      ', '
    ) WITHIN GROUP (
      ORDER BY ordinal_position
    ) AS column_list
  FROM qsys2.syscolumns2 c
  WHERE table_name = 'EMPLOYEE'
    AND table_schema = 'BIERHAUS'
    AND hidden = 'N' -- Don't include hidden columns
)
SELECT 'create or replace view BIERHAUS.employee_view( ' concat column_list concat ' )
        as (SELECT ' concat column_list concat ' from BIERHAUS.employee)' INTO create_view_statement
FROM gen;
EXECUTE immediate create_view_statement;
END;
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
ADD COLUMN row_birth TIMESTAMP(12) NOT NULL implicitly hidden generated always AS row BEGIN
ADD COLUMN row_death TIMESTAMP(12) NOT NULL implicitly hidden generated always AS row
END
ADD COLUMN transaction_time TIMESTAMP(12) implicitly hidden generated always AS TRANSACTION start id
ADD period SYSTEM_TIME(row_birth, row_death);
CREATE TABLE account_hist LIKE account;
ALTER TABLE account
ADD versioning USE history TABLE account_hist;
--  category:  Data Definition Language (DDL)
--  description:  Establish a Temporal table using a partitioned history table
--  minvrm:  v7r3m0
--
--  Note: Partitioning support is enabled via 5770SS1 Option 27 - DB2 Multisystem
--        Email Scott Forstie (forstie@us.ibm.com) to get a free trial version of this priced option
ALTER TABLE account
ADD COLUMN row_birth TIMESTAMP(12) NOT NULL implicitly hidden generated always AS row BEGIN
ADD COLUMN row_death TIMESTAMP(12) NOT NULL implicitly hidden generated always AS row
END
ADD COLUMN transaction_time TIMESTAMP(12) implicitly hidden generated always AS TRANSACTION start id
ADD period SYSTEM_TIME(row_birth, row_death);
CREATE TABLE account_hist LIKE account partition BY RANGE(row_death) (
  partition p2016 STARTING('01/01/2016') inclusive ENDING('01/01/2017') exclusive,
  partition p2017 STARTING('01/01/2017') inclusive ENDING('01/01/2018') exclusive,
  partition p2018 STARTING('01/01/2018') inclusive ENDING('01/01/2019') exclusive,
  partition p2019 STARTING('01/01/2019') inclusive ENDING('01/01/2020') exclusive
);
ALTER TABLE account
ADD versioning USE history TABLE account_hist;
--  category:  Data Definition Language (DDL)
--  description:  Label for Variable
label ON variable myschema.myjob_printer IS 'Label for this variable';
--  category:  Data Definition Language (DDL)
--  description:  Label on Alias
label ON alias alias1 IS 'label';
--  category:  Data Definition Language (DDL)
--  description:  Label on Column
label ON COLUMN TABLE1(column2 IS 'label', column3 IS 'label');
--  category:  Data Definition Language (DDL)
--  description:  Refresh Table
refresh TABLE mqt1;
--  category:  Data Definition Language (DDL)
--  description:  Rename Table
rename TABLE table1 TO table3;
--  category:  Data Definition Language (DDL)
--  description:  Start or stop history tracking for a Temporal table
--  minvrm:  v7r3m0
ALTER TABLE account
ADD period SYSTEM_TIME(row_birth, row_death);
ALTER TABLE account
ADD versioning USE history TABLE account_history;
ALTER TABLE account DROP versioning;
ALTER TABLE account DROP period system_time;
/*sql/Data-Manipulation-Language-(DML).sql*/
--  category:  Data-Manipulation-Language-(DML)
--  description:  Delete From Table
DELETE FROM table1
WHERE column1 = 0;
--  category:  Data Manipulation Language (DML)
--  description:  Insert into Column in Table
INSERT INTO TABLE1(column1)
VALUES (0);
--  category:  Data Manipulation Language (DML)
--  description:  Insert into Column in Table From Another Column
INSERT INTO TABLE1(column1)
SELECT column1
FROM table2
WHERE column1 > 5;
--  category:  Data Manipulation Language (DML)
--  description:  Insert into Table
INSERT INTO table1
VALUES (0, 'AAA', 1);
--  category:  Data Manipulation Language (DML)
--  description:  Merge into Table
MERGE INTO t1 USING(
  SELECT id,
    c2
  FROM t2
) x ON t1.id = x.id
WHEN NOT matched THEN
INSERT
VALUES (id, c2)
  WHEN matched THEN
UPDATE
SET c2 = x.c2;
--  category:  Data Manipulation Language (DML)
--  description:  Select All From Table
SELECT *
FROM qsys2.systables;
--  category:  Data Manipulation Language (DML)
--  description:  Select All from Table with Where Clause
SELECT *
FROM qsys2.systables
WHERE table_name LIKE 'FILE%';
--  category:  Data Manipulation Language (DML)
--  description:  Select Table Schema and Group By
SELECT table_schema,
  COUNT(*) AS "COUNT"
FROM qsys2.systables
GROUP BY table_schema
ORDER BY "COUNT" DESC;
--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Continue Identity
TRUNCATE table1 CONTINUE IDENTITY;
--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Ignoring Delete Triggers
TRUNCATE table1 ignore DELETE triggers;
--  category:  Data Manipulation Language (DML)
--  description:  Truncate Table Restart Identity Immediate
TRUNCATE table1 restart IDENTITY immediate;
--  category:  Data Manipulation Language (DML)
--  description:  Update Column in Table
UPDATE table1
SET column1 = 0
WHERE column1 < 0;
--  category:  Data Manipulation Language (DML)
--  description:  Update Columns in Table with Columns from another Table
UPDATE table1
SET (column1, column2) = (
    SELECT column1,
      column2
    FROM table2
    WHERE table1.column3 = column3
  );
--  category:  Data Manipulation Language (DML)
--  description:  Update Row in Table
UPDATE table1
SET row = (column1, ' ', column3);
--  category:  Data Manipulation Language (DML)
--  description:  Use FOR UPDATE to launch Edit Table
call QSYS.CREATE_SQL_SAMPLE('BUSINESS_NAME');
-- Normal query - read only
SELECT *
FROM business_name.sales;
-- Edit Table mode in ACS
SELECT *
FROM business_name.sales FOR
UPDATE;
/*sql/Db2-for-i-Services.sql*/
--  category:  Db2 for i Services
--  description:  Automated index advice processor
-- Purpose: This procedure using the index advice and find those indexes that have
--          been used by an MTI 500 times, and creates a permanent index.
--          Also, the existing indexes that are at least 7 Days old are examined
--          to determine if any of them should be removed due to lack of sufficient use.
cl: crtlib dbestudy;
CREATE OR replace PROCEDURE DBESTUDY.WEEKLY_INDEX_MANAGEMENT() language sql BEGIN call SYSTOOLS.ACT_ON_INDEX_ADVICE('TOYSTORE', NULL, NULL, 500, NULL);
call SYSTOOLS.REMOVE_INDEXES('TOYSTORE', 500, ' 7 DAYS ');
END;
--
-- Add this call to a scheduled job that runs once per day
--
call DBESTUDY.WEEKLY_INDEX_MANAGEMENT();
--  category:  Db2 for i Services
--  description:  Collect and study database statistics
cl: crtlib dbestudy;
--
-- Capture point-in-time database file detail
-- for all files in the TOYSTORE library
--
CREATE OR replace TABLE DBESTUDY.TOYSTORE_TABLES_RUNTIME_DETAILS(
    table_schema,
    table_name,
    table_partition,
    partition_type,
    number_deleted_rows,
    number_rows,
    data_size,
    overflow,
    variable_length_size,
    maintained_temporary_index_size,
    open_operations,
    close_operations,
    insert_operations,
    update_operations,
    delete_operations,
    physical_reads,
    sequential_reads,
    random_reads,
    keep_in_memory,
    media_preference,
    capture_time
  ) AS (
    SELECT table_schema,
      table_name,
      table_partition,
      partition_type,
      number_deleted_rows,
      number_rows,
      data_size,
      overflow,
      variable_length_size,
      maintained_temporary_index_size,
      open_operations,
      close_operations,
      insert_operations,
      update_operations,
      delete_operations,
      physical_reads,
      sequential_reads,
      random_reads,
      VARCHAR (
        CASE
          keep_in_memory
          WHEN '1' THEN 'yes'
          ELSE 'no'
        END,
        DEFAULT,
        37
      ),
      VARCHAR (
        CASE
          media_preference
          WHEN 255 THEN 'ssd'
          ELSE 'any'
        END,
        DEFAULT,
        37
      ),
      CURRENT timestamp
    FROM qsys2.syspartitionstat
    WHERE table_schema = 'TOYSTORE'
  ) WITH data ON replace DELETE rows;
--
-- Identify candidates for physical file reorganization
-- Only examine those files with more than a million rows deleted
--
SELECT table_schema,
  table_name,
  number_rows AS valid_rows,
  number_deleted_rows AS deleted_rows,
  data_size AS data_space_size_in_bytes,
  DEC(
    DEC(number_deleted_rows, 19, 2) / DEC(number_rows + number_deleted_rows, 19, 2) * 100,
    19,
    2
  ) AS deleted_row_percentage
FROM dbestudy.toystore_tables_runtime_details a
WHERE number_deleted_rows > 1000000
ORDER BY deleted_row_percentage DESC;
--  category:  Db2 for i Services
--  description:  Compare IFS details across 2 partitions
--                (existence, not contents or attributes)
- - Note: Replace < remote - rdb > with the remote RDB name of the target IBM i call QSYS2.QCMDEXC('crtlib ifsinfo');
call < remote - rdb >.QSYS2.QCMDEXC('crtlib ifsinfo');
--
-- Generate the IFS object detail
--
call QSYS2.QCMDEXC(
  'RTVDIRINF DIR(''/'') INFFILEPFX(IFSINFO2) INFLIB(IFSINFO)'
);
call < remote - rdb >.QSYS2.QCMDEXC(
  'RTVDIRINF DIR(''/'') INFFILEPFX(IFSINFO2) INFLIB(IFSINFO)'
);
stop;
--
-- List all objects and directories
--
SELECT qezdirnam1 AS ifs_directory,
  qezobjnam AS ifs_object_name,
  qezobjtype AS ifs_object_type
FROM ifsinfo.ifsinfo2o o
  INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
ORDER BY 1,
  3,
  2 DESC;
--
-- Formalize the IFS detail from the local partition
--
CREATE TABLE IFSINFO.LOCAL_IFS_OBJECTS(ifs_directory, ifs_object_name, ifs_object_type) AS (
  SELECT qezdirnam1 AS ifs_directory,
    qezobjnam AS ifs_object_name,
    qezobjtype AS ifs_object_type
  FROM ifsinfo.ifsinfo2o o
    INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
) WITH data;
--
-- Bring over the IFS detail from the remote partition
--
CREATE TABLE IFSINFO.REMOTE_IFS_OBJECTS(ifs_directory, ifs_object_name, ifs_object_type) AS (
  SELECT qezdirnam1 AS ifs_directory,
    qezobjnam AS ifs_object_name,
    qezobjtype AS ifs_object_type
  FROM < remote - rdb >.ifsinfo.ifsinfo2o o
    INNER JOIN < remote - rdb >.ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
) WITH data;
-- Raw count of objects
SELECT COUNT(*)
FROM ifsinfo.local_ifs_objects;
SELECT COUNT(*)
FROM ifsinfo.remote_ifs_objects;
--
-- Compare and contrast the two partitions.
-- Any rows returned represent an IFS difference
--
SELECT 'Production' AS "System Name",
  a.ifs_directory,
  a.ifs_object_name,
  a.ifs_object_type
FROM ifsinfo.local_ifs_objects a LEFT exception
  JOIN ifsinfo.remote_ifs_objects b ON a.ifs_directory IS NOT DISTINCT
FROM b.ifs_directory
  AND a.ifs_object_name IS NOT DISTINCT
FROM b.ifs_object_name
  AND a.ifs_object_type IS NOT DISTINCT
FROM b.ifs_object_type
UNION ALL
SELECT 'Failover' AS "System Name",
  b.ifs_directory,
  b.ifs_object_name,
  b.ifs_object_type
FROM ifsinfo.local_ifs_objects a RIGHT exception
  JOIN ifsinfo.remote_ifs_objects b ON b.ifs_directory IS NOT DISTINCT
FROM a.ifs_directory
  AND b.ifs_object_name IS NOT DISTINCT
FROM a.ifs_object_name
  AND b.ifs_object_type IS NOT DISTINCT
FROM a.ifs_object_type
ORDER BY ifs_directory,
  ifs_object_name,
  ifs_object_type;
--  category:  Db2 for i Services
--  description:  Compare SYSROUTINE across two IBM i partitions
-- Given a remote IBM i partition name and a library name
-- Search for procedure and function differences
-- Receive a result set with any differences
call SYSTOOLS.CHECK_SYSROUTINE('MYREMOTE', 'TOYSTORE', DEFAULT);
-- Search for procedure and function differences
-- Query SESSION.SYSRTNDIFF to see the differences
call SYSTOOLS.CHECK_SYSROUTINE('MYREMOTE', 'TOYSTORE', 1);
SELECT *
FROM session.sysrtndiff;
--  category:  Db2 for i Services
--  description:  Compare database constraints across two IBM i partitions
-- Given a remote IBM i partition name and a library name
-- Search for constraint differences
-- Receive a result set with any differences
call SYSTOOLS.CHECK_SYSCST('MYREMOTE', 'TOYSTORE', DEFAULT);
-- Search for constraint differences
-- Query SESSION.SYSCSTDIFF to see the differences
call SYSTOOLS.CHECK_SYSCST('MYREMOTE', 'TOYSTORE', 1);
SELECT *
FROM session.syscstdiff;
--  category:  Db2 for i Services
--  description:  Daily SQL Plan Cache management
cl: crtlib snapshots;
cl: crtlib eventmons;
-- Purpose: This procedure captures detail on SQL queries.
- -          1
) The 100 most expensive SQL queries are captured into a SQL Plan Cache Snapshot named SNAPSHOTS / SNP < julian - date > - -          2
) An SQL Plan Cache Event Monitor is started using a name SNAPSHOTS / EVT < julian - date >.The previous event monitor is ended.--          3) For both 1 & 2, only the 14 most recent days are kept online.
--          4) For both 1 & 2, the new monitor and snap shot are imported into System i Navigator / ACS SQL Performance Monitor
CREATE OR replace PROCEDURE SNAPSHOTS.DAILY_PC_MANAGEMENT() language sql BEGIN
DECLARE not_found condition FOR '02000';
DECLARE snap_name CHAR (10);
DECLARE oldest_snap_name CHAR (10);
DECLARE snap_comment VARCHAR (100);
DECLARE event_monitor_name CHAR (10);
DECLARE yesterday_event_monitor_name CHAR (10);
DECLARE oldest_event_monitor_name CHAR (10);
DECLARE v_not_found BIGINT DEFAULT 0;
-- A Julian date is the integer value representing a number of days
-- from January 1, 4713 B.C. (the start of the Julian calendar) to
-- the date specified in the argument.
SET snap_name = 'SNP' concat JULIAN_DAY(CURRENT DATE);
SET oldest_snap_name = 'SNP' concat JULIAN_DAY(CURRENT DATE - 14 days);
SET event_monitor_name = 'EVT' concat JULIAN_DAY(CURRENT DATE);
SET oldest_event_monitor_name = 'EVT' concat JULIAN_DAY(CURRENT DATE - 14 days);
SET yesterday_event_monitor_name = 'EVT' concat JULIAN_DAY(CURRENT DATE - 1 DAY);
---------------------------------------------------------------------------------------------------------
-- Process the Top 100 most expensive queries
---------------------------------------------------------------------------------------------------------
-- Capture the topN queries and import the snapshot
call QSYS2.DUMP_PLAN_CACHE_TOPN('SNAPSHOTS', snap_name, 100);
-- Remove the oldest TOPN snapshot
BEGIN
DECLARE CONTINUE handler FOR not_found
SET v_not_found = 1;
call QSYS2.REMOVE_PC_SNAPSHOT('SNAPSHOTS', oldest_snap_name);
END;
---------------------------------------------------------------------------------------------------------
-- Process prune plans using the SQL Plan Cache Event Monitor
---------------------------------------------------------------------------------------------------------
-- If we found yesterdays event monitor, end it
BEGIN
DECLARE CONTINUE handler FOR sqlexception
SET v_not_found = 1;
call QSYS2.END_PLAN_CACHE_EVENT_MONITOR(yesterday_event_monitor_name);
END;
-- Start today's event monitor
call QSYS2.START_PLAN_CACHE_EVENT_MONITOR('EVENTMONS', event_monitor_name);
-- Remove the oldest event monitor
BEGIN
DECLARE CONTINUE handler FOR not_found
SET v_not_found = 1;
call QSYS2.REMOVE_PC_EVENT_MONITOR('EVENTMONS', oldest_event_monitor_name);
END;
END;
--
-- Add this call to a scheduled job that runs once per day
--
call SNAPSHOTS.DAILY_PC_MANAGEMENT();
--  category:  Db2 for i Services
--  description:  Enable alerts for files which are growing near the maximum
cl: alcobj OBJ((qsys2 / syslimtbl * FILE * excl)) CONFLICT(* rqsrls);
cl: dlcobj OBJ((qsys2 / syslimtbl * FILE * excl));
CREATE OR replace TRIGGER scottf.system_limits_large_file
AFTER
INSERT ON qsys2.syslimtbl referencing new AS n FOR each row mode db2row
SET OPTION usrprf = * owner,
  dynusrprf = * owner BEGIN atomic
DECLARE v_cmdstmt VARCHAR (200);
DECLARE v_error integer;
DECLARE EXIT handler FOR sqlexception
SET v_error = 1;
/* ------------------------------------------------------------------ */
/* If a table has exceeded 80% of this limit, alert the operator     */
/* ------------------------------------------------------------------ */
/* 15000 == MAXIMUM NUMBER OF ALL ROWS IN A PARTITION                 */
/*          (max size = 4,294,967,288)                                */
/* ------------------------------------------------------------------ */
IF (
  n.limit_id = 15000
  AND n.current_value > (
    (
      SELECT supported_value
      FROM qsys2.sql_sizing
      WHERE sizing_id = 15000
    ) * 0.8
  )
) THEN
SET v_cmdstmt = 'SNDMSG MSG(''Table: ' concat n.system_schema_name concat '/' concat n.system_object_name concat ' (' concat n.system_table_member concat ') IS GETTING VERY LARGE - ROW COUNT =  ' concat current_value concat ' '') TOUSR(*SYSOPR) MSGTYPE(*INFO) ';
call QSYS2.QCMDEXC(v_cmdstmt);
END IF;
END;
COMMIT;
-- Description: Determine if any user triggers have been created over the System Limits table
SELECT *
FROM qsys2.systriggers
WHERE event_object_schema = 'QSYS2'
  AND event_object_table = 'SYSLIMTBL';
--  category:  Db2 for i Services
--  description:  Find and fix SQL DYNUSRPRF setting
--  minvrm: V7R3M0
--
-- Which SQL programs or services have a mismatch between user profile and dynamic user profile (full)
--
SELECT user_profile,
  dynamic_user_profile,
  program_schema,
  program_name,
  program_type,
  module_name,
  program_owner,
  program_creator,
  creation_timestamp,
  default_schema,
  "ISOLATION",
  concurrentaccessresolution,
  number_statements,
  program_used_size,
  number_compressions,
  statement_contention_count,
  original_source_file,
  original_source_file_ccsid,
  routine_type,
  routine_body,
  function_origin,
  function_type,
  number_external_routines,
  extended_indicator,
  c_nul_required,
  naming,
  target_release,
  earliest_possible_release,
  rdb,
  consistency_token,
  allow_copy_data,
  close_sql_cursor,
  lob_fetch_optimization,
  decimal_point,
  sql_string_delimiter,
  date_format,
  date_separator,
  time_format,
  time_separator,
  dynamic_default_schema,
  current_rules,
  allow_block,
  delay_prepare,
  user_profile,
  dynamic_user_profile,
  sort_sequence,
  language_identifier,
  sort_sequence_schema,
  sort_sequence_name,
  rdb_connection_method,
  decresult_maximum_precision,
  decresult_maximum_scale,
  decresult_minimum_divide_scale,
  decfloat_rounding_mode,
  decfloat_warning,
  sqlpath,
  dbgview,
  dbgkey,
  last_used_timestamp,
  days_used_count,
  last_reset_timestamp,
  system_program_name,
  system_program_schema,
  iasp_number,
  system_time_sensitive
FROM qsys2.sysprogramstat
WHERE system_program_schema = 'SCOTTF'
  AND dynamic_user_profile = '*USER'
  AND program_type IN ('*PGM', '*SRVPGM')
  AND (
    (user_profile = '*OWNER')
    OR (
      user_profile = '*NAMING'
      AND naming = '*SQL'
    )
  )
ORDER BY program_name;
stop;
--
-- Which SQL programs or services have a mismatch between user profile and dynamic user profile (full)
--
SELECT QSYS2.DELIMIT_NAME(system_program_schema) AS lib,
  QSYS2.DELIMIT_NAME(system_program_name) AS pgm,
  program_type AS type
FROM qsys2.sysprogramstat
WHERE system_program_schema = 'SCOTTF'
  AND dynamic_user_profile = '*USER'
  AND program_type IN ('*PGM', '*SRVPGM')
  AND (
    (user_profile = '*OWNER')
    OR (
      user_profile = '*NAMING'
      AND naming = '*SQL'
    )
  )
ORDER BY program_name;
stop;
--
-- Find misaligned use of SQL's Dynamic User Profile and swap the setting
--
CREATE OR replace PROCEDURE COOLSTUFF.SWAP_DYNUSRPRF(target_library VARCHAR(10)) BEGIN
DECLARE v_eof integer DEFAULT 0;
DECLARE prepare_attributes VARCHAR (100) DEFAULT ' ';
DECLARE sql_statement_text CLOB(10 k) ccsid 37;
DECLARE v_lib VARCHAR (10) ccsid 37;
DECLARE v_pgm VARCHAR (10) ccsid 37;
DECLARE v_type VARCHAR (7) ccsid 37;
DECLARE obj_cursor CURSOR FOR
SELECT QSYS2.DELIMIT_NAME(system_program_schema) AS lib,
  QSYS2.DELIMIT_NAME(system_program_name) AS pgm,
  program_type AS type
FROM qsys2.sysprogramstat
WHERE program_schema = target_library
  AND dynamic_user_profile = '*USER'
  AND program_type IN ('*PGM', '*SRVPGM')
  AND (
    (user_profile = '*OWNER')
    OR (
      user_profile = '*NAMING'
      AND naming = '*SQL'
    )
  )
ORDER BY program_name;
OPEN obj_cursor;
loop_through_data: BEGIN
DECLARE CONTINUE handler FOR sqlstate '02000' BEGIN
SET v_eof = 1;
END;
l3: loop FETCH obj_cursor INTO v_lib,
v_pgm,
v_type;
IF (v_eof = 1) THEN leave l3;
END IF;
-- Swap the SQL DYNUSRPRF setting
call QSYS2.SWAP_DYNUSRPRF(v_lib, v_pgm, v_type);
call SYSTOOLS.LPRINTF(
  'DYNUSRPRF swapped for: ' concat v_lib concat '/' concat v_pgm concat ' ' concat v_type
);
END loop;
/* L3 */
CLOSE obj_cursor;
END loop_through_data;
END;
stop;
-- Process all the misaligned SQL DynUsrPrf settings for a specific library
call COOLSTUFF.SWAP_DYNUSRPRF('SCOTTF');
--  category:  Db2 for i Services
--  description:  Index Advice - Analyzing advice since last IPL
-- Examine the condensed index advice where the index advice has occurred since the last IPL
WITH LAST_IPL(ipl_time) AS (
  SELECT job_entered_system_time
  FROM TABLE (
      QSYS2.JOB_INFO(
        job_status_filter = > '*ACTIVE',
        job_user_filter = > 'QSYS'
      )
    ) x
  WHERE job_name = '000000/QSYS/SCPF'
)
SELECT *
FROM last_ipl,
  qsys2.condidxa
WHERE last_advised > ipl_time;
--
-- Examine the condensed index advice where Maintained Temporary Indexes (MTI)
-- have been used since the last IPL
--
WITH LAST_IPL(ipl_time) AS (
  SELECT job_entered_system_time
  FROM TABLE (
      QSYS2.JOB_INFO(
        job_status_filter = > '*ACTIVE',
        job_user_filter = > 'QSYS'
      )
    ) x
  WHERE job_name = '000000/QSYS/SCPF'
)
SELECT *
FROM last_ipl,
  qsys2.condidxa
WHERE last_mti_used > ipl_time
  OR last_mti_used_for_stats > ipl_time;
--  category:  Db2 for i Services
--  description:  Interrogate interactive jobs
WITH INTERACTIVE_JOBS(jobname, status, cpu, io) AS (
  SELECT job_name,
    job_status,
    cpu_time,
    total_disk_io_count
  FROM TABLE (QSYS2.ACTIVE_JOB_INFO('YES', 'QINTER', '*ALL')) AS a
  WHERE job_status IN ('LCKW', 'RUN')
)
SELECT jobname,
  status,
  cpu,
  io,
  program_library_name,
  program_name,
  module_library_name,
  module_name,
  HEX(BIGINT(statement_identifiers)) AS stmt,
  procedure_name,
  activation_group_name,
  objtext,
  v_client_ip_address
FROM interactive_jobs i,
  LATERAL(
    SELECT *
    FROM TABLE (QSYS2.STACK_INFO(jobname)) j
    WHERE program_library_name NOT LIKE 'Q%'
    ORDER BY ordinal_position DESC
    LIMIT 1
  ) x, LATERAL(
    SELECT objtext
    FROM TABLE (
        QSYS2.OBJECT_STATISTICS(
          x.program_library_name,
          '*PGM *SRVPGM',
          x.program_name
        )
      ) AS c
  ) AS y,
  LATERAL(
    SELECT v_client_ip_address
    FROM TABLE (QSYS2.GET_JOB_INFO(jobname)) AS d
  ) AS z
ORDER BY cpu DESC;
--  category:  Db2 for i Services
--  description:  Reset indexes statistics while in production
-- This procedure resets QUERY_USE_COUNT and QUERY_STATISTICS_COUNT.
-- The LAST_QUERY_USE, LAST_STATISTICS_USE, LAST_USE_DATE and
-- NUMBER_DAYS_USED are not affected.
--
-- Reset Query statistics over TOYSTORE/EMPLOYEE
--
call QSYS2.RESET_TABLE_INDEX_STATISTICS('TOYSTORE', 'EMPLOYEE');
--
-- Reset Query statistics over all tables in the TOYSTORE library
--
call QSYS2.RESET_TABLE_INDEX_STATISTICS('TOYSTORE', '%');
--  category:  Db2 for i Services
--  description:  Review the distribution of deleted records
SELECT 1000000 - COUNT(*) AS deletedcnt
FROM star100g.item_fact a
GROUP BY BIGINT (RRN(a) / 1000000)
ORDER BY BIGINT (RRN(a) / 1000000);
--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Add a threshold
--  minvrm: V7R3M0
--
--
-- Add a threshold for elapsed time of queries coming in over QZDA jobs
--
call QSYS2.ADD_QUERY_THRESHOLD(
  threshold_name = > 'ZDA QUERY TIME > 30',
  threshold_type = > 'ELAPSED TIME',
  threshold_value = > 30,
  subsystems = > 'QUSRWRK',
  job_names = > 'QZDA*',
  long_comment = > 'ZDA Queries running longer than 30 seconds'
);
--
-- Review configured Query Supervisor thresholds
--
SELECT *
FROM qsys2.query_supervisor;
--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Exit programs
--  minvrm: V7R3M0
--
--
-- Review the Query Supervisor exit programs
--
SELECT *
FROM qsys2.exit_program_info
WHERE exit_point_name = 'QIBM_QQQ_QRY_SUPER';
--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Remove a threshold
--  minvrm: V7R3M0
--
--
-- Remove a Query Supervisor threshold
--
call QSYS2.REMOVE_QUERY_THRESHOLD(threshold_name = > 'ZDA QUERY TIME > 30');
--
-- Review configured Query Supervisor thresholds
--
SELECT *
FROM qsys2.query_supervisor;
--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Working example
--  minvrm: V7R3M0
--
--
-- This example shows how to establish a Query Supervisor threshold
-- that is looking at job name of QZDA* and supervising queries that
-- are taking longer than 30 seconds of elapsed time to complete.
--
-- When such a query is encountered, the exit program sends an
-- SQL7064 message to QSYSOPR and then directs SQE to
-- terminate the query.
--
stop;
call QSYS2.QCMDEXC('CRTSRCPF FILE(QTEMP/ZDA_ELAP1) RCDLEN(140)');
call QSYS2.QCMDEXC('addpfm file(qtemp/ZDA_ELAP1) mbr(ZDA_ELAP1)');
INSERT INTO qtemp.zda_elap1
VALUES (1, 010101, '#include <stdlib.h>'),
  (2, 010101, '#include <string.h>'),
  (3, 010101, '#include <stddef.h> '),
  (4, 010101, '#include <iconv.h>'),
  (5, 010101, '#include <stdio.h>'),
  (6, 010101, '#include <except.h>'),
  (7, 010101, '#include <eqqqrysv.h>'),
  (
    8,
    010101,
    'static void convertThresholdNameToJobCCSID(const char* input, char* output)'
  ),
  (9, 010101, '{'),
  (10, 010101, '  iconv_t converter;'),
  (
    11,
    010101,
    '  char from_code[32], to_code[32];'
  ),
  (
    12,
    010101,
    '  size_t input_bytes, output_bytes;'
  ),
  (13, 010101, '  int iconv_rc;'),
  (
    14,
    010101,
    '  memset(from_code, 0, sizeof(from_code));'
  ),
  (
    15,
    010101,
    '  memset(to_code, 0, sizeof(to_code));'
  ),
  (
    16,
    010101,
    '  memcpy(from_code, "IBMCCSID012000000000", 20);'
  ),
  (
    17,
    010101,
    '  memcpy(to_code, "IBMCCSID00000", 13);'
  ),
  (
    18,
    010101,
    '  converter = iconv_open(to_code, from_code);'
  ),
  (
    19,
    010101,
    '  if (converter.return_value == 0) {'
  ),
  (20, 010101, '    input_bytes = 60;'),
  (21, 010101, '   output_bytes = 30;'),
  (22, 010101, '    iconv_rc = iconv(converter,'),
  (
    23,
    010101,
    '                     &input, &input_bytes,'
  ),
  (
    24,
    010101,
    '                     &output, &output_bytes);'
  ),
  (25, 010101, '    iconv_close(converter);'),
  (26, 010101, '    if (iconv_rc >= 0)'),
  (
    27,
    010101,
    '      return; /* Conversion was successful. */'
  ),
  (28, 010101, '  }'),
  (
    29,
    010101,
    '  sprintf(output, "iconv_open() failed with: %d", converter.return_value);'
  ),
  (30, 010101, '}'),
  (
    31,
    010101,
    'int trimmed_length(const char* str, int len)'
  ),
  (32, 010101, '{'),
  (
    33,
    010101,
    '  const char* first_blank = memchr(str, '' '', len);'
  ),
  (34, 010101, '  if (first_blank)'),
  (35, 010101, '    return first_blank - str;'),
  (36, 010101, '  return len;'),
  (37, 010101, '}'),
  (38, 010101, 'int main(int argc, char* argv[])'),
  (39, 010101, '{'),
  (40, 010101, '  char length_string[10];'),
  (41, 010101, '  char cmd[600];'),
  (
    42,
    010101,
    '  char thresholdNameInJobCCSID[31];'
  ),
  (43, 010101, '  char msg[512];'),
  (
    44,
    010101,
    '  const QQQ_QRYSV_QRYS0100_t* input = (QQQ_QRYSV_QRYS0100_t*)argv[1];'
  ),
  (45, 010101, '  int* rc = (int*)argv[2];'),
  (
    46,
    010101,
    '  memset(thresholdNameInJobCCSID, 0, sizeof(thresholdNameInJobCCSID));'
  ),
  (
    47,
    010101,
    '  convertThresholdNameToJobCCSID(input->Threshold_Name,thresholdNameInJobCCSID);'
  ),
  (
    48,
    010101,
    '  if (memcmp("ZDA QUERY TIME > 30", thresholdNameInJobCCSID, 19) != 0) '
  ),
  (49, 010101, '    { return; } '),
  (
    50,
    010101,
    '  *rc = 1; /* terminate the query */'
  ),
  (51, 010101, '  memset(msg, 0, sizeof(msg));'),
  (
    52,
    010101,
    '  strcat(msg, "Query Supervisor: ");'
  ),
  (
    53,
    010101,
    '  strcat(msg, thresholdNameInJobCCSID);'
  ),
  (
    54,
    010101,
    '  strcat(msg," REACHED IN JOB ");'
  ),
  (
    55,
    010101,
    '  strncat(msg, input->Job_Number, trimmed_length(input->Job_Number,6));'
  ),
  (56, 010101, '  strcat(msg, "/");'),
  (
    57,
    010101,
    '  strncat(msg, input->Job_User, trimmed_length(input->Job_User,10));'
  ),
  (58, 010101, '  strcat(msg, "/");'),
  (
    59,
    010101,
    '  strncat(msg, input->Job_Name, trimmed_length(input->Job_Name,10));'
  ),
  (60, 010101, '  strcat(msg, " FOR USER: ");'),
  (
    61,
    010101,
    '  strncat(msg, input->User_Name, 10);'
  ),
  (
    62,
    010101,
    '  memset(length_string, 0, sizeof(length_string));'
  ),
  (
    63,
    010101,
    '  sprintf(length_string,"%d",strlen(msg));'
  ),
  (64, 010101, '  memset(cmd, 0, sizeof(cmd));'),
  (
    65,
    010101,
    '  strcat(cmd, "SBMJOB CMD(RUNSQL SQL(''call qsys2.send_message(''''SQL7064'''',");'
  ),
  (66, 010101, '  strcat(cmd,length_string);'),
  (67, 010101, '  strcat(cmd,",''''");'),
  (68, 010101, '  strcat(cmd, msg);'),
  (69, 010101, '  strcat(cmd, "'''')''))");'),
  (70, 010101, '  system(cmd);'),
  (71, 010101, '}');
cl: crtlib supervisor;
call QSYS2.QCMDEXC(
  'CRTCMOD MODULE(QTEMP/ZDA_ELAP1) SRCFILE(QTEMP/ZDA_ELAP1)  OUTPUT(*print)  '
);
call QSYS2.QCMDEXC(
  'CRTPGM PGM(SUPERVISOR/ZDA_ELAP1) MODULE(QTEMP/ZDA_ELAP1) ACTGRP(*CALLER) USRPRF(*OWNER) DETAIL(*NONE)'
);
call QSYS2.QCMDEXC(
  'ADDEXITPGM EXITPNT(QIBM_QQQ_QRY_SUPER) FORMAT(QRYS0100) PGMNBR(*LOW) PGM(SUPERVISOR/ZDA_ELAP1) THDSAFE(*YES) TEXT(''ZDA Elapsed Time > 30 seconds'')'
);
--
-- Review any instances where the Query Supervisor exit program terminated a ZDA query
--
SELECT *
FROM TABLE (
    QSYS2.MESSAGE_QUEUE_INFO(message_filter = > 'ALL')
  )
WHERE message_id = 'SQL7064'
ORDER BY message_timestamp DESC;
--  category:  Db2 for i Services
--  description:  Utilities - Database Catalog analyzer
--  minvrm: V7R3M0
--
--  Find all database files in the QGPL library and validate that associated
--  Database Cross Reference file entries contain the correct and complete detail
--
SELECT *
FROM TABLE (
    QSYS2.ANALYZE_CATALOG(OPTION = > 'DBXREF', library_name = > 'QGPL')
  );
stop;
--  category:  Db2 for i Services
--  description:  Utilities - Database file data validation
--  Note: If no rows are returned, there are no instances of invalid data
--  minvrm: V7R3M0
--
--
-- Validate all rows within the last member of one file
--
SELECT *
FROM TABLE (
    SYSTOOLS.VALIDATE_DATA(
      library_name = > 'MARYNA',
      file_name = > 'BADDATA',
      member_name = > '*LAST'
    )
  );
stop;
--
-- Validate all rows within all members of one file
--
SELECT *
FROM TABLE (
    SYSTOOLS.VALIDATE_DATA_FILE(library_name = > 'MARYNA', file_name = > 'BADDATA')
  );
stop;
--
-- Validate all rows within all members of all files within a library
--
SELECT *
FROM TABLE (
    SYSTOOLS.VALIDATE_DATA_LIBRARY(library_name = > 'MARYNA')
  );
stop;
--  category:  Db2-for-i-Services
--  description:  __ Where to find more detail __
--
--  Documentation can be found here:
--  --------------------------------
--  https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/rzajq/rzajqservicesdb2.htm
--
--  Enabling Db2 PTF Group level and enhancement details can be found here:
--  -----------------------------------------------------------------------
--  https://ibm.biz/DB2foriServices
--
;
/*sql/Miscellaneous.sql*/
--  category:  Miscellaneous
--  description:  CL ADDRPYLE
cl: addrpyle SEQNBR(3333) MSGID(cpa32b2) RPY(i);
--  category:  Miscellaneous
--  description:  CL ADDRPYLE CMPDTA(table)
cl: addrpyle SEQNBR(3333) MSGID(cpa32b2) CMPDTA(table1 1) RPY(i);
--  category:  Miscellaneous
--  description:  CL: CHGJOB INQMSGRPY(*DFT)
cl: chgjob INQMSGRPY(* dft);
--  category:  Miscellaneous
--  description:  CL: CHGJOB INQMSGRPY(*SYSRPYL)
cl: chgjob INQMSGRPY(* sysrpyl);
--  category:  Miscellaneous
--  description:  CL: RMVRPYLE SEQNBR(3333)
cl: rmvrpyle SEQNBR(3333);
--  category:  Miscellaneous
--  description:  Call Create SQL Sample with Schema
call QSYS.CREATE_SQL_SAMPLE('SCHEMA-NAME');
--  category:  Miscellaneous
--  description:  Call QCMDEXC with schema
call QSYS2.QCMDEXC('addlible schema1');
--  category:  Miscellaneous
--  description:  Declare Global Temporary Table
DECLARE global temporary TABLE temptab1 LIKE user1.emptab including IDENTITY ON COMMIT preserve rows;
--  category:  Miscellaneous
--  description:  Declare Global Temporary Table Session
DECLARE global temporary TABLE SESSION.TEMP_EMP(
    empno CHAR (6) NOT NULL,
    salary DECIMAL (9, 2),
    bonus DECIMAL (9, 2),
    comm DECIMAL (9, 2)
  ) ON COMMIT preserve rows;
--  category:  Miscellaneous
--  description:  Drop a schema without the CPA7025 inquiry messages
--  minvrm:  v7r3m0
DROP SCHEMA toystore CASCADE;
--  category:  Miscellaneous
--  description:  Lock Table in Exclusive Mode
lock TABLE table1 IN exclusive mode;
--  category:  Miscellaneous
--  description:  Lock Table in Exclusive Mode Allow Read
lock TABLE table1 IN exclusive mode allow READ;
--  category:  Miscellaneous
--  description:  Lock Table in Share Mode
lock TABLE table1 IN share mode;
--  category:  Miscellaneous
--  description:  Review ACS function usage configuration
--
--  Note: Here is the default configuration
--
--  Function ID              Default Usage
--  -----------              -------------
--  QIBM_DB_SQLADM           DENIED
--  QIBM_DB_SYSMON           DENIED
--  QIBM_DB_SECADM           DENIED
--  QIBM_DB_DDMDRDA          ALLOWED
--  QIBM_DB_ZDA              ALLOWED
--  QIBM_XE1_OPNAV_DBNAV     ALLOWED
--  QIBM_XE1_OPNAV_DBSQLPM   ALLOWED
--  QIBM_XE1_OPNAV_DBSQLPCS  ALLOWED
--  QIBM_XE1_OPNAV_DBXACT    ALLOWED
SELECT function_id,
  default_usage,
  f.*
FROM qsys2.function_info f
WHERE function_id LIKE 'QIBM_DB_%'
  OR function_id LIKE 'QIBM_XE1_OPNAV_DB_%';
--  category:  Miscellaneous
--  description:  Set Path to *LIBL
SET path = * libl;
--  category:  Miscellaneous
--  description:  Set Path to schemas
SET path = schema1,
  schema2;
/*sql/Routine-(Function-or-Procedure)-Statements.sql*/
--  category:  Routine (Function or Procedure) Statements
--  description:  Alter Procedure
ALTER PROCEDURE PROCEDURE2(integer) REPLACE(inout parameter1 integer, IN parameter2 integer) modifies sql data BEGIN
DECLARE variable1 DECIMAL (5, 2);
SELECT column1 INTO variable1
FROM table1
WHERE column1 = parameter1;
IF variable1 > parameter2 THEN
INSERT INTO table2
VALUES (100);
END IF;
END;
--  category:  Routine (Function or Procedure) Statements
--  description:  Comment on Parameter for Procedure
comment ON parameter PROCEDURE1(parameter1 IS 'comment', parameter2 IS 'comment');
--  category:  Routine (Function or Procedure) Statements
--  description:  Comment on Procedure
comment ON PROCEDURE procedure1 IS 'comment';
--  category:  Routine (Function or Procedure) Statements
--  description:  Create Procedure Language C Modifies SQL
CREATE PROCEDURE XMLP1(
  IN p1 XML AS CLOB(100) ccsid 1208,
  out p2 XML AS CLOB(100) ccsid 1208
) language c EXTERNAL name lib.xmlp1 modifies sql data simple call WITH nulls;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create XML Variable
CREATE variable gxml1 XML;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Function Language C
CREATE OR replace FUNCTION FUNCTION1(parameter1 integer) returns integer language c EXTERNAL name 'lib1/pgm1(entryname)' parameter style general;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Function Language SQL
CREATE OR replace FUNCTION FUNCTION2(parameter1 integer) returns integer language sql BEGIN
DECLARE variable1 DECIMAL (5, 2);
SELECT c1 INTO variable1
FROM table1
WHERE column1 = parameter1;
RETURN variable1;
END;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language C
CREATE OR replace PROCEDURE PROCEDURE1(inout parameter1 integer) language c EXTERNAL parameter style general;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language C External Name
CREATE OR replace PROCEDURE PROCEDURE2(inout parameter1 integer) language c EXTERNAL name 'lib1/srvpgm1(entryname)' parameter style general;
--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language SQL
CREATE OR replace PROCEDURE PROCEDURE2(inout parameter1 integer) language sql BEGIN
DECLARE variable1 DECIMAL (5, 2);
SELECT column1 INTO variable1
FROM table1
WHERE column1 = parameter1;
IF variable1 > 5 THEN
INSERT INTO table2
VALUES (100);
END IF;
END;
--  category:  Routine (Function or Procedure) Statements
--  description:  Drop Function
DROP FUNCTION function1;
--  category:  Routine (Function or Procedure) Statements
--  description:  Drop Procedure
DROP PROCEDURE procedure1;
--  category:  Routine (Function or Procedure) Statements
--  description:  Dynamic Compound statement
BEGIN
DECLARE already_exists SMALLINT DEFAULT 0;
DECLARE dup_object_hdlr condition FOR sqlstate '42710';
DECLARE CONTINUE handler FOR dup_object_hdlr
SET already_exists = 1;
CREATE TABLE TABLE1(col1 INT);
IF already_exists > 0 THEN
DELETE FROM table1;
END IF;
END;
--  category:  Routine (Function or Procedure) Statements
--  description:  Grant Execute on Procedure
GRANT EXECUTE ON PROCEDURE procedure1 TO PUBLIC;
--  category:  Routine (Function or Procedure) Statements
--  description:  Revoke Execute on Procedure
REVOKE EXECUTE ON specific PROCEDURE specific1
FROM PUBLIC;
--  category:  Routine-(Function-or-Procedure)-Statements
--  description:  Set Variable to Parse XML
SET gxml1 = XMLPARSE(document '<run/>');
/*sql/Special-Registers.sql*/
--  category:  Special Registers
--  description:  Select  Decimal Float Rounding Mode
SELECT CURRENT decfloat rounding mode
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select  Decimal Float Rounding Mode
SELECT CURRENT decfloat rounding mode
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select  Implicit XML Parse option
VALUES (CURRENT implicit xmlparse OPTION);
--  category:  Special Registers
--  description:  Select Client Special Registers
SELECT client applname,
  client acctng,
  client programid,
  client userid,
  client wrkstnname
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Date
SELECT CURRENT_DATE
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Debug Mode
SELECT CURRENT debug mode
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Degree
SELECT CURRENT degree
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Path
SELECT current_path
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Schema
SELECT CURRENT SCHEMA
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Server
SELECT CURRENT server
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Time
SELECT CURRENT_TIME
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Time Zone
SELECT CURRENT timezone
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current Timestamp
SELECT CURRENT_TIMESTAMP
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select Current User
VALUES (CURRENT USER);
--  category:  Special Registers
--  description:  Select Session User
SELECT SESSION_USER
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select System User
SELECT SYSTEM_USER
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select User
SELECT USER
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Select maximum precision Current Timestamp
--  minvrm:  v7r2m0
SELECT CURRENT_TIMESTAMP (12)
FROM sysibm.sysdummy1;
--  category:  Special Registers
--  description:  Set Decfloat Rounding to Round Half Even
SET CURRENT decfloat rounding mode = round_half_even;
--  category:  Special Registers
--  description:  Set Degree to 5
SET CURRENT degree = '5';
--  category:  Special Registers
--  description:  Set Degree to Any
SET CURRENT degree = 'ANY';
--  category:  Special Registers
--  description:  Set Degree to Default
SET CURRENT degree = DEFAULT;
--  category:  Special Registers
--  description:  Set Path
SET path = myschema,
  system path;
--  category:  Special Registers
--  description:  Set Session Authorization to JOEUSER
SET session AUTHORIZATION = ' joeuser ';
--  category:  Special Registers
--  description:  Set client special registers
CALL SYSPROC.WLM_SET_CLIENT_INFO(
  ' db2user ',
  ' machine.rchland.ibm.com ',
  ' auditor ',
  ' accounting department ',
  ' automatic '
);
SELECT UPPER(CURRENT CLIENT_USERID),
  CURRENT CLIENT_WRKSTNNAME,
  CURRENT CLIENT_APPLNAME,
  CURRENT CLIENT_ACCTNG,
  CURRENT CLIENT_PROGRAMID
FROM SYSIBM.SYSDUMMY1;
-- Selectively change a subset of registers
CALL SYSPROC.WLM_SET_CLIENT_INFO(
  CLIENT_PROGRAMID = > ' warehouse extraction process - v2.4 '
);
SELECT UPPER(CURRENT CLIENT_USERID),
  CURRENT CLIENT_WRKSTNNAME,
  CURRENT CLIENT_APPLNAME,
  CURRENT CLIENT_ACCTNG,
  CURRENT CLIENT_PROGRAMID
FROM SYSIBM.SYSDUMMY1;
--  category:  Special Registers
--  description:  Set current schema
SET SCHEMA = MYSCHEMA;
--  category:  Special-Registers
--  description:  Set the system time to one hour in the past
--  minvrm:  v7r3m0
SET CURRENT TEMPORAL SYSTEM_TIME = current timestamp - 1 hour;
/*sql/SYSTOOLS.sql*/
--  category:  SYSTOOLS for you
--  description:  Analyze IFS storage consumption
-- first time only
cl: crtlib ifsinfo;
-- On subsequent executions, delete these files before calling RTVDIRINF
drop table IFSINFO.IFSINFO2O;
drop table IFSINFO.IFSINFO2D;
-- indicate the root location for study
cl :RTVDIRINF DIR(' /') INFFILEPFX(ifsinfo2) INFLIB(ifsinfo) OMIT('/QSYS.LIB');
stop;
--
-- description: List all objects and directories, in order with their sizes
--
SELECT qezdirnam1 AS ifs_directory,
  qezobjnam AS ifs_object_name,
  VARCHAR_FORMAT(qezdtasize, '999G999G999G999G999G999') AS ifs_object_size,
  qezobjtype AS ifs_object_type
FROM ifsinfo.ifsinfo2o o
  INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
ORDER BY 3 DESC;
--
-- description: Summarize the size count at the directory levels
--
WITH IFS_SIZE_INFO(
  ifs_directory,
  ifs_directory_index,
  ifs_parent_directory_index,
  ifs_object_name,
  ifs_object_size,
  ifs_object_type
) AS (
  SELECT qezdirnam1 AS ifs_directory,
    d.qezdiridx AS ifs_directory_index,
    qezpardir AS ifs_parent_directory_index,
    qezobjnam AS ifs_object_name,
    qezdtasize AS ifs_object_size,
    qezobjtype AS ifs_object_type
  FROM ifsinfo.ifsinfo2o o
    INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
  ORDER BY 1,
    2,
    4
)
SELECT ifs_directory,
  VARCHAR_FORMAT(SUM(ifs_object_size), '999G999G999G999G999G999') AS total_subdir_size
FROM ifs_size_info
GROUP BY ifs_directory,
  ifs_directory_index,
  ifs_parent_directory_index
ORDER BY total_subdir_size DESC;
--
-- description: Summarize the size of directories including any subdirectory trees
--
WITH IFS_SIZE_INFO(
  ifs_directory,
  ifs_directory_index,
  ifs_parent_directory_index,
  ifs_object_name,
  ifs_object_size,
  ifs_object_type
) AS (
  SELECT qezdirnam1 AS ifs_directory,
    d.qezdiridx AS ifs_directory_index,
    qezpardir AS ifs_parent_directory_index,
    qezobjnam AS ifs_object_name,
    qezdtasize AS ifs_object_size,
    qezobjtype AS ifs_object_type
  FROM ifsinfo.ifsinfo2o o
    INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
  ORDER BY 1,
    2,
    4
),
IFS_DIRECTORY_ROLLUP(
  ifs_directory,
  ifs_directory_index,
  ifs_parent_directory_index,
  total_subdir_size
) AS (
  SELECT ifs_directory,
    CASE
      WHEN ifs_directory_index = 1 THEN 0
      ELSE ifs_directory_index
    END AS ifs_directory_index,
    ifs_parent_directory_index,
    SUM(ifs_object_size) AS total_subdir_size
  FROM ifs_size_info
  GROUP BY ifs_directory,
    ifs_directory_index,
    ifs_parent_directory_index
  ORDER BY total_subdir_size DESC
),
IFS_DIRECTORY_RCTE(
  level,
  ifs_directory,
  ifs_directory_index,
  ifs_parent_directory_index,
  total_subdir_size
) AS (
  SELECT 1,
    ifs_directory,
    ifs_directory_index,
    ifs_parent_directory_index,
    total_subdir_size
  FROM ifs_directory_rollup root
  UNION ALL
  SELECT parent.level + 1,
    parent.ifs_directory,
    child.ifs_directory_index,
    child.ifs_parent_directory_index,
    child.total_subdir_size
  FROM ifs_directory_rcte parent,
    ifs_directory_rollup child
  WHERE parent.ifs_directory_index = child.ifs_parent_directory_index
)
SELECT ifs_directory,
  VARCHAR_FORMAT(
    SUM(total_subdir_size),
    '999G999G999G999G999G999'
  ) AS total_size
FROM ifs_directory_rcte
WHERE ifs_directory_index > 1
GROUP BY ifs_directory
ORDER BY total_size DESC;
--
-- description: Summarize the object counts at each directory level
--
SELECT qezdirnam1 AS ifs_directory,
  COUNT(*) AS ifs_object_count
FROM ifsinfo.ifsinfo2o o
  INNER JOIN ifsinfo.ifsinfo2d d ON o.qezdiridx = d.qezdiridx
GROUP BY qezdirnam1
ORDER BY 2 DESC;
--  category:  SYSTOOLS for you
--  description:  Return Work Management Class info
call QSYS2.OVERRIDE_QAQQINI(1, '', '');
call QSYS2.OVERRIDE_QAQQINI(2, 'SQL_GVAR_BUILD_RULE', '*EXIST');
--
CREATE OR replace FUNCTION SYSTOOLS.CLASS_INFO(p_library_name VARCHAR(10)) returns TABLE (
    library VARCHAR (10) ccsid 1208,
    class VARCHAR (10) ccsid 1208,
    class_text VARCHAR (100) ccsid 1208,
    last_use timestamp,
    use_count integer,
    run_priority integer,
    timeslice_seconds integer,
    default_wait_time_seconds integer
  ) NOT deterministic EXTERNAL action modifies sql data NOT fenced
SET OPTION COMMIT = * none BEGIN
DECLARE v_print_line CHAR (133);
DECLARE local_sqlcode integer;
DECLARE local_sqlstate CHAR (5);
DECLARE v_message_text VARCHAR (70);
DECLARE v_dspcls VARCHAR (300);
--
-- DSPCLS detail
--
DECLARE v_class CHAR (10);
DECLARE v_class_library CHAR (10);
DECLARE v_run_priority integer;
DECLARE v_timeslice_seconds integer;
DECLARE v_default_wait_time_seconds integer;
--
-- OBJECT_STATISTICS detail
--
DECLARE find_classes_query_text VARCHAR (500);
DECLARE v_class_text CHAR (100);
DECLARE v_job_name VARCHAR (28);
DECLARE v_last_use timestamp;
DECLARE v_use_count integer;
DECLARE c_find_classes CURSOR FOR find_classes_query;
DECLARE c_find_dspcls_output CURSOR FOR
SELECT job_name
FROM qsys2.output_queue_entries_basic
WHERE user_name = SESSION_USER
  AND spooled_file_name = 'QPDSPCLS'
  AND user_data = 'DSPCLS'
ORDER BY create_timestamp DESC
LIMIT 1;
DECLARE c_dspcls_output CURSOR FOR
SELECT c1
FROM session.splf x
WHERE RRN(x) > 4
ORDER BY RRN(x);
DECLARE CONTINUE handler FOR sqlexception BEGIN get diagnostics condition 1 local_sqlcode = db2_returned_sqlcode,
  local_sqlstate = returned_sqlstate;
SET v_message_text = 'systools.class_info() failed with: ' concat local_sqlcode concat '  AND ' concat local_sqlstate;
signal sqlstate 'QPC01'
SET message_text = v_message_text;
END;
DECLARE global temporary TABLE SPLF(c1 CHAR(133)) WITH replace;
SET find_classes_query_text = 'select OBJNAME  , rtrim(OBJTEXT)  , LAST_USED_TIMESTAMP  , DAYS_USED_COUNT  FROM TABLE (OBJECT_STATISTICS(''' concat p_library_name concat ''',''CLS    '')) AS a ';
prepare find_classes_query
FROM find_classes_query_text;
OPEN c_find_classes;
l1: loop FETCH
FROM c_find_classes INTO v_class,
  v_class_text,
  v_last_use,
  v_use_count;
get diagnostics condition 1 local_sqlcode = db2_returned_sqlcode,
local_sqlstate = returned_sqlstate;
IF (local_sqlstate = '02000') THEN CLOSE c_find_classes;
RETURN;
END IF;
SET v_dspcls = 'DSPCLS CLS(' concat RTRIM(p_library_name) concat '/' concat RTRIM(v_class) concat ') OUTPUT(*PRINT)';
call QSYS2.QCMDEXC(v_dspcls);
OPEN c_find_dspcls_output;
FETCH
FROM c_find_dspcls_output INTO v_job_name;
CLOSE c_find_dspcls_output;
call QSYS2.QCMDEXC(
  'CPYSPLF FILE(QPDSPCLS) TOFILE(QTEMP/SPLF) SPLNBR(*LAST) JOB(' concat v_job_name concat ') '
);
OPEN c_dspcls_output;
FETCH
FROM c_dspcls_output INTO v_print_line;
SET v_run_priority = INT (SUBSTR(v_print_line, 56, 10));
FETCH
FROM c_dspcls_output INTO v_print_line;
SET v_timeslice_seconds = INT (SUBSTR(v_print_line, 56, 10)) / 1000;
FETCH
FROM c_dspcls_output INTO v_print_line;
/* skip eligible for purge */
FETCH
FROM c_dspcls_output INTO v_print_line;
IF SUBSTR(v_print_line, 56, 6) = '*NOMAX' THEN
SET v_default_wait_time_seconds = NULL;
ELSE
SET v_default_wait_time_seconds = INT (SUBSTR(v_print_line, 56, 10));
END IF;
CLOSE c_dspcls_output;
call QSYS2.QCMDEXC(
  'DLTSPLF FILE(QPDSPCLS)  SPLNBR(*LAST) JOB(' concat v_job_name concat ') '
);
PIPE(
  p_library_name,
  v_class,
  v_class_text,
  v_last_use,
  v_use_count,
  v_run_priority,
  v_timeslice_seconds,
  v_default_wait_time_seconds
);
END loop;
/* L1 */
CLOSE c_find_classes;
END;
CREATE OR replace TABLE classtoday.cdetail AS (
    SELECT *
    FROM TABLE (SYSTOOLS.CLASS_INFO('QSYS'))
  ) WITH data ON replace DELETE rows;
SELECT *
FROM classtoday.cdetail;
/*copyright*/
1