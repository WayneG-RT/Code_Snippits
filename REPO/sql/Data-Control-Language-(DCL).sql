--  category:  Data Control Language (DCL)
--  description:  Alter Mask Disable
--  minvrm:  v7r2m0

ALTER MASK SSN_MASK DISABLE;


--  category:  Data Control Language (DCL)
--  description:  Alter Mask Enable
--  minvrm:  v7r2m0

ALTER MASK SSN_MASK ENABLE;


--  category:  Data Control Language (DCL)
--  description:  Alter Mask Regenerate
--  minvrm:  v7r2m0

ALTER MASK SSN_MASK REGENERATE;


--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Disable
--  minvrm:  v7r2m0

ALTER PERMISSION NETHMO.ROW_ACCESS DISABLE;


--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Enable
--  minvrm:  v7r2m0

ALTER PERMISSION NETHMO.ROW_ACCESS ENABLE;


--  category:  Data Control Language (DCL)
--  description:  Alter Permission Row Access Regenerate
--  minvrm:  v7r2m0

ALTER PERMISSION NETHMO.ROW_ACCESS REGENERATE;


--  category:  Data Control Language (DCL)
--  description:  Alter Table Activate Column Access Control
--  minvrm:  v7r2m0

ALTER TABLE EMPLOYEE ACTIVATE COLUMN ACCESS CONTROL;


--  category:  Data Control Language (DCL)
--  description:  Alter Table Activate Row Access Control
--  minvrm:  v7r2m0

ALTER TABLE HOSPITAL.PATIENT ACTIVATE ROW ACCESS CONTROL;


--  category:  Data Control Language (DCL)
--  description:  Create or Replace Mask
--  minvrm:  v7r2m0

CREATE OR REPLACE MASK SSN_MASK ON EMPLOYEE FOR COLUMN SSN RETURN
CASE
    WHEN (VERIFY_GROUP_FOR_USER(SESSION_USER, 'PAYROLL') = 1) THEN SSN
    WHEN (VERIFY_GROUP_FOR_USER(SESSION_USER, 'MGR') = 1) THEN 'XXX-XX-' CONCAT SUBSTR(SSN, 8, 4)
    ELSE NULL
END ENABLE;


--  category:  Data Control Language (DCL)
--  description:  Create or Replace Permission
--  minvrm:  v7r2m0

CREATE OR REPLACE PERMISSION NETHMO.ROW_ACCESS ON HOSPITAL.PATIENT FOR ROWS WHERE (VERIFY_GROUP_FOR_USER(
        SESSION_USER, 'PATIENT') = 1 AND HOSPITAL.PATIENT.USERID = SESSION_USER) OR (VERIFY_GROUP_FOR_USER(
        SESSION_USER, 'PCP') = 1 AND HOSPITAL.PATIENT.PCP_ID = SESSION_USER) OR (VERIFY_GROUP_FOR_USER(
        SESSION_USER, 'MEMBERSHIP') = 1 OR VERIFY_GROUP_FOR_USER(SESSION_USER, 'ACCOUNTING') = 1 OR
    VERIFY_GROUP_FOR_USER(SESSION_USER, 'DRUG_RESEARCH') = 1) ENFORCED FOR ALL ACCESS ENABLE;


--  category:  Data Control Language (DCL)
--  description:  Grant Alter, Index on Table to Public

GRANT ALTER, INDEX ON table3 TO PUBLIC;


--  category:  Data Control Language (DCL)
--  description:  Grant Select, Delete, Insert, Update on Table to Public with Grant Option

GRANT SELECT, DELETE, INSERT, UPDATE ON TABLE table3 TO PUBLIC WITH GRANT OPTION;


--  category:  Data Control Language (DCL)
--  description:  Grant Update Column to Public

GRANT UPDATE (column1) ON table2 TO PUBLIC;


--  category:  Data Control Language (DCL)
--  description:  Grant all Privileges to Public

GRANT ALL PRIVILEGES ON table3 TO PUBLIC;


--  category:  Data Control Language (DCL)
--  description:  Revoke Alter, Index on Table From Public

REVOKE ALTER, INDEX on table3 FROM PUBLIC;


--  category:  Data Control Language (DCL)
--  description:  Revoke Select, Delete, Insert, Update On Table From Public

REVOKE SELECT, DELETE, INSERT, UPDATE ON TABLE table3 FROM PUBLIC;


--  category:  Data Control Language (DCL)
--  description:  Revoke Update Column from Public

REVOKE UPDATE (column1) ON table2 FROM PUBLIC;


--  category:  Data-Control-Language-(DCL)
--  description:  Revoke all Privileges from Public

REVOKE ALL PRIVILEGES ON table3 FROM PUBLIC;


