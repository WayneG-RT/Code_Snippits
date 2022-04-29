--  category:  SYSTOOLS for you
--  description:  Analyze IFS storage consumption

-- first time only
cl: crtlib ifsinfo;

-- On subsequent executions, delete these files before calling RTVDIRINF
drop table IFSINFO.IFSINFO2O;
drop table IFSINFO.IFSINFO2D;

-- indicate the root location for study
cl:RTVDIRINF DIR('/') INFFILEPFX(IFSINFO2) INFLIB(IFSINFO) OMIT('/QSYS.LIB');
stop;


--
-- description: List all objects and directories, in order with their sizes
--
SELECT QEZDIRNAM1 as IFS_DIRECTORY, 
       QEZOBJNAM as IFS_OBJECT_NAME, 
       VARCHAR_FORMAT(QEZDTASIZE, '999G999G999G999G999G999') as IFS_OBJECT_SIZE, 
       QEZOBJTYPE AS IFS_OBJECT_TYPE
FROM IFSINFO.IFSINFO2O O
INNER JOIN 
     IFSINFO.IFSINFO2D D
ON O.QEZDIRIDX = D.QEZDIRIDX
ORDER BY 3 desc;
 
--
-- description: Summarize the size count at the directory levels
--
WITH IFS_SIZE_INFO(IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX, IFS_OBJECT_NAME, IFS_OBJECT_SIZE, IFS_OBJECT_TYPE) AS (
  SELECT QEZDIRNAM1 as IFS_DIRECTORY, D.QEZDIRIDX AS IFS_DIRECTORY_INDEX, 
         QEZPARDIR AS IFS_PARENT_DIRECTORY_INDEX, QEZOBJNAM as IFS_OBJECT_NAME, 
         QEZDTASIZE as IFS_OBJECT_SIZE, QEZOBJTYPE AS IFS_OBJECT_TYPE
  FROM IFSINFO.IFSINFO2O O
    INNER JOIN 
      IFSINFO.IFSINFO2D D
    ON O.QEZDIRIDX = D.QEZDIRIDX
    ORDER BY 1,2,4
)
  SELECT IFS_DIRECTORY,
         VARCHAR_FORMAT(SUM(IFS_OBJECT_SIZE), '999G999G999G999G999G999') as TOTAL_SUBDIR_SIZE
    FROM IFS_SIZE_INFO
    GROUP BY IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX
    ORDER BY TOTAL_SUBDIR_SIZE DESC;

--
-- description: Summarize the size of directories including any subdirectory trees
--
WITH IFS_SIZE_INFO(IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX, IFS_OBJECT_NAME, IFS_OBJECT_SIZE, IFS_OBJECT_TYPE) AS (
  SELECT QEZDIRNAM1 as IFS_DIRECTORY, D.QEZDIRIDX AS IFS_DIRECTORY_INDEX, 
         QEZPARDIR AS IFS_PARENT_DIRECTORY_INDEX, QEZOBJNAM as IFS_OBJECT_NAME, 
         QEZDTASIZE as IFS_OBJECT_SIZE, QEZOBJTYPE AS IFS_OBJECT_TYPE
  FROM IFSINFO.IFSINFO2O O
    INNER JOIN 
      IFSINFO.IFSINFO2D D
    ON O.QEZDIRIDX = D.QEZDIRIDX
    ORDER BY 1,2,4
),   IFS_DIRECTORY_ROLLUP(IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX, TOTAL_SUBDIR_SIZE) AS (
  SELECT IFS_DIRECTORY, 
         CASE WHEN IFS_DIRECTORY_INDEX = 1 THEN 0 ELSE IFS_DIRECTORY_INDEX END AS IFS_DIRECTORY_INDEX, 
         IFS_PARENT_DIRECTORY_INDEX, SUM(IFS_OBJECT_SIZE) AS TOTAL_SUBDIR_SIZE
    FROM IFS_SIZE_INFO
    GROUP BY IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX
    ORDER BY TOTAL_SUBDIR_SIZE DESC
),   IFS_DIRECTORY_RCTE(LEVEL, IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX, TOTAL_SUBDIR_SIZE) AS (
  SELECT 1, IFS_DIRECTORY, IFS_DIRECTORY_INDEX, IFS_PARENT_DIRECTORY_INDEX, TOTAL_SUBDIR_SIZE
    FROM IFS_DIRECTORY_ROLLUP ROOT
    UNION ALL
  SELECT PARENT.LEVEL+1, PARENT.IFS_DIRECTORY, CHILD.IFS_DIRECTORY_INDEX, CHILD.IFS_PARENT_DIRECTORY_INDEX, CHILD.TOTAL_SUBDIR_SIZE
    FROM IFS_DIRECTORY_RCTE PARENT, IFS_DIRECTORY_ROLLUP CHILD
      WHERE PARENT.IFS_DIRECTORY_INDEX = CHILD.IFS_PARENT_DIRECTORY_INDEX
)
select IFS_DIRECTORY, 
       VARCHAR_FORMAT(SUM(TOTAL_SUBDIR_SIZE), '999G999G999G999G999G999') AS TOTAL_SIZE 
 from IFS_DIRECTORY_RCTE
 where IFS_DIRECTORY_INDEX > 1
 GROUP BY IFS_DIRECTORY
 ORDER BY TOTAL_SIZE DESC;
 
 

--
-- description: Summarize the object counts at each directory level
-- 
SELECT QEZDIRNAM1 as IFS_DIRECTORY, 
       COUNT(*)   as IFS_OBJECT_COUNT
FROM IFSINFO.IFSINFO2O O
INNER JOIN 
     IFSINFO.IFSINFO2D D
ON O.QEZDIRIDX = D.QEZDIRIDX
GROUP BY QEZDIRNAM1
ORDER BY 2 desc;


--  category:  SYSTOOLS for you
--  description:  Return Work Management Class info

call qsys2.override_qaqqini(1, '', '');
call qsys2.override_qaqqini(2,  
                            'SQL_GVAR_BUILD_RULE', 
                            '*EXIST');
--
CREATE OR REPLACE FUNCTION systools.class_info (
         p_library_name VARCHAR(10)
      )
   RETURNS TABLE (
      library VARCHAR(10) CCSID 1208, class VARCHAR(10) CCSID 1208, class_text VARCHAR(
      100) CCSID 1208, last_use TIMESTAMP, use_count INTEGER, run_priority INTEGER,
      timeslice_seconds INTEGER, default_wait_time_seconds INTEGER
   )
   NOT DETERMINISTIC
   EXTERNAL ACTION
   MODIFIES SQL DATA
   NOT FENCED
   SET OPTION COMMIT = *NONE
BEGIN
   DECLARE v_print_line CHAR(133);
   DECLARE local_sqlcode INTEGER;
   DECLARE local_sqlstate CHAR(5);
   DECLARE v_message_text VARCHAR(70);
   DECLARE v_dspcls VARCHAR(300);
   --
   -- DSPCLS detail
   --
   DECLARE v_class CHAR(10);
   DECLARE v_class_library CHAR(10);
   DECLARE v_run_priority INTEGER;
   DECLARE v_timeslice_seconds INTEGER;
   DECLARE v_default_wait_time_seconds INTEGER;
   --
   -- OBJECT_STATISTICS detail
   --
   DECLARE find_classes_query_text VARCHAR(500);
   DECLARE v_class_text CHAR(100);
   DECLARE v_job_name VARCHAR(28);
   DECLARE v_last_use TIMESTAMP;
   DECLARE v_use_count INTEGER;
   DECLARE c_find_classes CURSOR FOR find_classes_query;
   DECLARE c_find_dspcls_output CURSOR FOR SELECT job_name
      FROM qsys2.output_queue_entries_basic
      WHERE user_name = SESSION_USER AND
            spooled_file_name = 'QPDSPCLS' AND
            user_data = 'DSPCLS'
      ORDER BY create_timestamp DESC
      LIMIT 1;
   DECLARE c_dspcls_output CURSOR FOR SELECT c1
      FROM SESSION.splf x
      WHERE RRN(x) > 4
      ORDER BY RRN(x);
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   BEGIN
      GET DIAGNOSTICS CONDITION 1
            local_sqlcode = db2_returned_sqlcode, local_sqlstate = returned_sqlstate;
      SET v_message_text = 'systools.class_info() failed with: ' CONCAT local_sqlcode
               CONCAT '  AND ' CONCAT local_sqlstate;
      SIGNAL SQLSTATE 'QPC01' SET MESSAGE_TEXT = v_message_text;
   END;
   DECLARE GLOBAL TEMPORARY TABLE splf (c1 CHAR(133))
      WITH REPLACE;
   SET find_classes_query_text =
   'select OBJNAME  , rtrim(OBJTEXT)  , LAST_USED_TIMESTAMP  , DAYS_USED_COUNT  FROM TABLE (OBJECT_STATISTICS('''
            CONCAT p_library_name CONCAT ''',''CLS    '')) AS a ';
   PREPARE find_classes_query FROM find_classes_query_text;
   OPEN c_find_classes;
   l1: LOOP
      FETCH FROM c_find_classes INTO v_class, v_class_text, v_last_use, v_use_count;
      GET DIAGNOSTICS CONDITION 1 local_sqlcode = db2_returned_sqlcode,
                  local_sqlstate = returned_sqlstate;
      IF (local_sqlstate = '02000') THEN
         CLOSE c_find_classes;
         RETURN;
      END IF;
      SET v_dspcls = 'DSPCLS CLS(' CONCAT RTRIM(p_library_name) CONCAT '/' CONCAT
               RTRIM(v_class) CONCAT ') OUTPUT(*PRINT)';
      CALL qsys2.qcmdexc(v_dspcls);
      OPEN c_find_dspcls_output;
      FETCH FROM c_find_dspcls_output INTO v_job_name;
      CLOSE c_find_dspcls_output;
      CALL qsys2.qcmdexc('CPYSPLF FILE(QPDSPCLS) TOFILE(QTEMP/SPLF) SPLNBR(*LAST) JOB('
            CONCAT v_job_name CONCAT ') ');
      OPEN c_dspcls_output;
      FETCH FROM c_dspcls_output INTO v_print_line;
      SET v_run_priority = INT(SUBSTR(v_print_line, 56, 10));
      FETCH FROM c_dspcls_output INTO v_print_line;
      SET v_timeslice_seconds = INT(SUBSTR(v_print_line, 56, 10)) / 1000;
      FETCH FROM c_dspcls_output INTO v_print_line; /* skip eligible for purge */
      FETCH FROM c_dspcls_output INTO v_print_line;
      IF SUBSTR(v_print_line, 56, 6) = '*NOMAX' THEN
         SET v_default_wait_time_seconds = NULL;
      ELSE SET v_default_wait_time_seconds = INT(SUBSTR(v_print_line, 56, 10));
      END IF;
      CLOSE c_dspcls_output;
      CALL qsys2.qcmdexc('DLTSPLF FILE(QPDSPCLS)  SPLNBR(*LAST) JOB(' CONCAT v_job_name
            CONCAT ') ');
      PIPE (
         p_library_name,
         v_class, v_class_text, v_last_use, v_use_count, v_run_priority,
         v_timeslice_seconds, v_default_wait_time_seconds);
   END LOOP; /* L1 */
   CLOSE c_find_classes;
END;


create or replace table classtoday.cdetail as (
SELECT *
   FROM TABLE (
         systools.class_info('QSYS')
      )) with data on replace delete rows;
      
select * from classtoday.cdetail;


