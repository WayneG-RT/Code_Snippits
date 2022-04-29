--  category:  Routine (Function or Procedure) Statements
--  description:  Alter Procedure

ALTER PROCEDURE procedure2 (INTEGER) REPLACE (INOUT parameter1 INTEGER, IN parameter2 INTEGER) MODIFIES SQL DATA
BEGIN
    DECLARE variable1 DECIMAL(5, 2);
    SELECT column1
        INTO variable1
        FROM table1
        WHERE column1 = parameter1;
    IF variable1 > parameter2 THEN
        INSERT INTO table2
            VALUES (100);
    END IF;
END;


--  category:  Routine (Function or Procedure) Statements
--  description:  Comment on Parameter for Procedure

COMMENT ON PARAMETER procedure1 (parameter1  IS 'comment', parameter2 IS 'comment');


--  category:  Routine (Function or Procedure) Statements
--  description:  Comment on Procedure

COMMENT ON PROCEDURE procedure1 IS 'comment';


--  category:  Routine (Function or Procedure) Statements
--  description:  Create Procedure Language C Modifies SQL

CREATE PROCEDURE xmlp1 (IN p1 XML AS CLOB(100) CCSID 1208, OUT p2 XML AS CLOB(100) CCSID 1208)
        LANGUAGE C
        EXTERNAL NAME lib.xmlp1
        MODIFIES SQL DATA
        SIMPLE CALL WITH NULLS;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create XML Variable

CREATE VARIABLE gxml1 XML;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Function Language C

CREATE OR REPLACE FUNCTION function1 (parameter1 INTEGER) RETURNS INTEGER LANGUAGE C EXTERNAL NAME 'lib1/pgm1(entryname)' PARAMETER STYLE GENERAL;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Function Language SQL

CREATE OR REPLACE FUNCTION function2 (
            parameter1 INTEGER
    )
    RETURNS INTEGER
    LANGUAGE SQL
    BEGIN
        DECLARE variable1 DECIMAL(5, 2);
        SELECT c1
            INTO variable1
            FROM table1
            WHERE column1 = parameter1;
        RETURN variable1;
    END;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language C

CREATE OR REPLACE PROCEDURE procedure1 (INOUT parameter1 INTEGER) LANGUAGE C EXTERNAL PARAMETER STYLE GENERAL;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language C External Name

CREATE OR REPLACE PROCEDURE procedure2 (INOUT parameter1 INTEGER) LANGUAGE C EXTERNAL NAME 'lib1/srvpgm1(entryname)' PARAMETER STYLE GENERAL;


--  category:  Routine (Function or Procedure) Statements
--  description:  Create or Replace Procedure Language SQL

CREATE OR REPLACE PROCEDURE procedure2 (INOUT parameter1 INTEGER)
        LANGUAGE SQL
BEGIN
    DECLARE variable1 DECIMAL(5, 2);
    SELECT column1
        INTO variable1
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
   DECLARE dup_object_hdlr CONDITION FOR SQLSTATE '42710';
   DECLARE CONTINUE HANDLER FOR dup_object_hdlr
      SET already_exists = 1;
   CREATE TABLE table1(col1 INT);
   IF already_exists > 0
   THEN
      DELETE FROM table1;
   END IF;
END;


--  category:  Routine (Function or Procedure) Statements
--  description:  Grant Execute on Procedure

GRANT EXECUTE ON PROCEDURE procedure1 TO PUBLIC;


--  category:  Routine (Function or Procedure) Statements
--  description:  Revoke Execute on Procedure

REVOKE EXECUTE ON SPECIFIC PROCEDURE specific1 FROM PUBLIC;


--  category:  Routine-(Function-or-Procedure)-Statements
--  description:  Set Variable to Parse XML

SET gxml1 = XMLPARSE(DOCUMENT '<run/>');


