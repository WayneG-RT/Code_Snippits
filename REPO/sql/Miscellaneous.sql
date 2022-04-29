--  category:  Miscellaneous
--  description:  CL ADDRPYLE 

CL: ADDRPYLE SEQNBR(3333) MSGID(CPA32B2) RPY(I);


--  category:  Miscellaneous
--  description:  CL ADDRPYLE CMPDTA(table)

CL: ADDRPYLE SEQNBR(3333) MSGID(CPA32B2) CMPDTA(table1 1) RPY(I);


--  category:  Miscellaneous
--  description:  CL: CHGJOB INQMSGRPY(*DFT)

CL: CHGJOB INQMSGRPY(*DFT);


--  category:  Miscellaneous
--  description:  CL: CHGJOB INQMSGRPY(*SYSRPYL)

CL: CHGJOB INQMSGRPY(*SYSRPYL);


--  category:  Miscellaneous
--  description:  CL: RMVRPYLE SEQNBR(3333)

CL: RMVRPYLE SEQNBR(3333);


--  category:  Miscellaneous
--  description:  Call Create SQL Sample with Schema

CALL QSYS.CREATE_SQL_SAMPLE('SCHEMA-NAME');


--  category:  Miscellaneous
--  description:  Call QCMDEXC with schema

CALL QSYS2.QCMDEXC('addlible schema1');


--  category:  Miscellaneous
--  description:  Declare Global Temporary Table

DECLARE GLOBAL TEMPORARY TABLE TEMPTAB1 LIKE USER1.EMPTAB INCLUDING IDENTITY ON COMMIT PRESERVE ROWS;


--  category:  Miscellaneous
--  description:  Declare Global Temporary Table Session

DECLARE GLOBAL TEMPORARY TABLE SESSION.TEMP_EMP (EMPNO CHAR(6) NOT NULL, SALARY DECIMAL(9, 2), BONUS DECIMAL(9, 2), COMM DECIMAL(9, 2)) ON COMMIT PRESERVE ROWS;


--  category:  Miscellaneous
--  description:  Drop a schema without the CPA7025 inquiry messages
--  minvrm:  v7r3m0

DROP SCHEMA TOYSTORE CASCADE;


--  category:  Miscellaneous
--  description:  Lock Table in Exclusive Mode

LOCK TABLE table1 IN EXCLUSIVE MODE;


--  category:  Miscellaneous
--  description:  Lock Table in Exclusive Mode Allow Read

LOCK TABLE table1 IN EXCLUSIVE MODE ALLOW READ;


--  category:  Miscellaneous
--  description:  Lock Table in Share Mode

LOCK TABLE table1 IN SHARE MODE;


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
   WHERE function_id LIKE 'QIBM_DB_%' OR
         function_id LIKE 'QIBM_XE1_OPNAV_DB_%';


--  category:  Miscellaneous
--  description:  Set Path to *LIBL

SET PATH = *LIBL;


--  category:  Miscellaneous
--  description:  Set Path to schemas

SET PATH = schema1, schema2;


