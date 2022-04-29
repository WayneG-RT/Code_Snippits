--  category:  Special Registers
--  description:  Select  Decimal Float Rounding Mode

SELECT CURRENT DECFLOAT ROUNDING MODE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select  Decimal Float Rounding Mode

SELECT CURRENT DECFLOAT ROUNDING MODE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select  Implicit XML Parse option

VALUES( CURRENT IMPLICIT XMLPARSE OPTION );


--  category:  Special Registers
--  description:  Select Client Special Registers

SELECT CLIENT APPLNAME   , 
       CLIENT ACCTNG     ,
       CLIENT PROGRAMID  , 
       CLIENT USERID     , 
       CLIENT WRKSTNNAME   
FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Date

SELECT CURRENT_DATE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Debug Mode

SELECT CURRENT DEBUG MODE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Degree

SELECT CURRENT DEGREE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Path

SELECT CURRENT_PATH FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Schema

SELECT CURRENT SCHEMA FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Server

SELECT CURRENT SERVER FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Time

SELECT CURRENT_TIME FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Time Zone

SELECT CURRENT TIMEZONE FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current Timestamp

SELECT CURRENT_TIMESTAMP FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select Current User

VALUES(CURRENT USER);


--  category:  Special Registers
--  description:  Select Session User

SELECT SESSION_USER FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select System User

SELECT SYSTEM_USER FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select User

SELECT USER FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Select maximum precision Current Timestamp
--  minvrm:  v7r2m0

SELECT CURRENT_TIMESTAMP(12) FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Set Decfloat Rounding to Round Half Even

SET CURRENT DECFLOAT ROUNDING MODE = ROUND_HALF_EVEN;


--  category:  Special Registers
--  description:  Set Degree to 5

SET CURRENT DEGREE = '5';


--  category:  Special Registers
--  description:  Set Degree to Any

SET CURRENT DEGREE = 'ANY';


--  category:  Special Registers
--  description:  Set Degree to Default

SET CURRENT DEGREE = DEFAULT;


--  category:  Special Registers
--  description:  Set Path

SET PATH = MYSCHEMA, SYSTEM PATH;


--  category:  Special Registers
--  description:  Set Session Authorization to JOEUSER

SET SESSION AUTHORIZATION ='JOEUSER';


--  category:  Special Registers
--  description:  Set client special registers

CALL SYSPROC.WLM_SET_CLIENT_INFO(
    'db2user', 
    'machine.rchland.ibm.com', 
    'Auditor', 
    'Accounting department', 
    'AUTOMATIC' );

SELECT 
UPPER(CURRENT CLIENT_USERID) , 
CURRENT CLIENT_WRKSTNNAME , 
CURRENT CLIENT_APPLNAME , 
CURRENT CLIENT_ACCTNG , 
CURRENT CLIENT_PROGRAMID 
FROM SYSIBM.SYSDUMMY1;

-- Selectively change a subset of registers
CALL SYSPROC.WLM_SET_CLIENT_INFO(
    CLIENT_PROGRAMID => 'Warehouse Extraction Process - V2.4' 
 );

SELECT 
UPPER(CURRENT CLIENT_USERID) , 
CURRENT CLIENT_WRKSTNNAME , 
CURRENT CLIENT_APPLNAME , 
CURRENT CLIENT_ACCTNG , 
CURRENT CLIENT_PROGRAMID 
FROM SYSIBM.SYSDUMMY1;


--  category:  Special Registers
--  description:  Set current schema

SET SCHEMA = MYSCHEMA;


--  category:  Special-Registers
--  description:  Set the system time to one hour in the past
--  minvrm:  v7r3m0

SET CURRENT TEMPORAL SYSTEM_TIME = current timestamp - 1 hour;


