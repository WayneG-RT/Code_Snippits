--  category:  Db2 for i Services
--  description:  Automated index advice processor

-- Purpose: This procedure using the index advice and find those indexes that have 
--          been used by an MTI 500 times, and creates a permanent index.
--          Also, the existing indexes that are at least 7 Days old are examined
--          to determine if any of them should be removed due to lack of sufficient use.

CL: CRTLIB DBESTUDY;

CREATE OR REPLACE PROCEDURE DBESTUDY.WEEKLY_INDEX_MANAGEMENT()
LANGUAGE SQL
BEGIN

CALL SYSTOOLS.ACT_ON_INDEX_ADVICE('TOYSTORE', NULL, NULL, 500, NULL);
CALL SYSTOOLS.REMOVE_INDEXES('TOYSTORE', 500, ' 7 DAYS ');
END;


--
-- Add this call to a scheduled job that runs once per day
--
Call DBESTUDY.WEEKLY_INDEX_MANAGEMENT();


--  category:  Db2 for i Services
--  description:  Collect and study database statistics

CL: CRTLIB dbestudy;
--
-- Capture point-in-time database file detail 
-- for all files in the TOYSTORE library
--
CREATE OR REPLACE TABLE dbestudy.toystore_tables_runtime_details (table_schema,TABLE_NAME,
   table_partition, partition_type, number_deleted_rows, number_rows, data_size, overflow,
   variable_length_size, maintained_temporary_index_size, open_operations, close_operations,
   insert_operations, update_operations, delete_operations, physical_reads, sequential_reads,
   random_reads, keep_in_memory, media_preference, capture_time)
     as (select table_schema, table_name, table_partition, partition_type, number_deleted_rows,
           number_rows, data_size, overflow, variable_length_size,
           maintained_temporary_index_size, open_operations, close_operations, insert_operations,
           update_operations, delete_operations, physical_reads, sequential_reads, random_reads,
           varchar(case keep_in_memory when '1' then 'yes' else 'no' end, default, 37),
           varchar(case media_preference when 255 then 'ssd' else 'any' end, default, 37),
           CURRENT TIMESTAMP
          FROM qsys2.syspartitionstat
          WHERE table_schema = 'TOYSTORE') WITH DATA ON REPLACE DELETE ROWS;
  
--        
-- Identify candidates for physical file reorganization
-- Only examine those files with more than a million rows deleted
--
SELECT TABLE_SCHEMA,
       TABLE_NAME,
       NUMBER_ROWS AS VALID_ROWS,
       NUMBER_DELETED_ROWS AS DELETED_ROWS,
       DATA_SIZE AS DATA_SPACE_SIZE_IN_BYTES,
       DEC(DEC(NUMBER_DELETED_ROWS,19,2) / DEC(NUMBER_ROWS + NUMBER_DELETED_ROWS,19,2) *
          100,19,2) AS DELETED_ROW_PERCENTAGE
   FROM dbestudy.toystore_tables_runtime_details A
   WHERE NUMBER_DELETED_ROWS > 1000000
   ORDER BY DELETED_ROW_PERCENTAGE DESC;


--  category:  Db2 for i Services
--  description:  Compare IFS details across 2 partitions
--                (existence, not contents or attributes)

-- Note: Replace <remote-rdb> with the remote RDB name of the target IBM i

call              qsys2.qcmdexc('crtlib ifsinfo');
call <remote-rdb>.qsys2.qcmdexc('crtlib ifsinfo');

--
-- Generate the IFS object detail
--
call              qsys2.qcmdexc('RTVDIRINF DIR(''/'') INFFILEPFX(IFSINFO2) INFLIB(IFSINFO)');
call <remote-rdb>.qsys2.qcmdexc('RTVDIRINF DIR(''/'') INFFILEPFX(IFSINFO2) INFLIB(IFSINFO)');

stop;

--
-- List all objects and directories
--
SELECT QEZDIRNAM1 as IFS_DIRECTORY, QEZOBJNAM as IFS_OBJECT_NAME, QEZOBJTYPE AS IFS_OBJECT_TYPE
FROM IFSINFO.IFSINFO2O O
     INNER JOIN  IFSINFO.IFSINFO2D D ON O.QEZDIRIDX = D.QEZDIRIDX
ORDER BY 1,3,2 desc;

--
-- Formalize the IFS detail from the local partition
--
CREATE TABLE IFSINFO.local_IFS_objects
   (IFS_DIRECTORY, IFS_OBJECT_NAME, IFS_OBJECT_TYPE)
   AS (SELECT QEZDIRNAM1 as IFS_DIRECTORY, 
              QEZOBJNAM  as IFS_OBJECT_NAME, 
              QEZOBJTYPE AS IFS_OBJECT_TYPE
          FROM IFSINFO.IFSINFO2O O
               INNER JOIN  
               IFSINFO.IFSINFO2D D 
               ON O.QEZDIRIDX = D.QEZDIRIDX)
WITH DATA;


--
-- Bring over the IFS detail from the remote partition
--
CREATE TABLE IFSINFO.remote_IFS_objects
   (IFS_DIRECTORY, IFS_OBJECT_NAME, IFS_OBJECT_TYPE)
   AS (SELECT QEZDIRNAM1 as IFS_DIRECTORY, 
              QEZOBJNAM  as IFS_OBJECT_NAME, 
              QEZOBJTYPE AS IFS_OBJECT_TYPE
          FROM <remote-rdb>.IFSINFO.IFSINFO2O O
               INNER JOIN  
               <remote-rdb>.IFSINFO.IFSINFO2D D 
               ON O.QEZDIRIDX = D.QEZDIRIDX)
WITH DATA;

-- Raw count of objects
select count(*) from IFSINFO.local_IFS_objects;
select count(*) from IFSINFO.remote_IFS_objects;

--
-- Compare and contrast the two partitions. 
-- Any rows returned represent an IFS difference
--
SELECT 'Production' AS "System Name", 
     a.IFS_DIRECTORY, a.IFS_OBJECT_NAME, a.IFS_OBJECT_TYPE
     FROM IFSINFO.local_IFS_objects a LEFT EXCEPTION JOIN 
          IFSINFO.remote_IFS_objects b 
          ON a.IFS_DIRECTORY   IS NOT DISTINCT FROM b.IFS_DIRECTORY   AND
             a.IFS_OBJECT_NAME IS NOT DISTINCT FROM b.IFS_OBJECT_NAME AND
             a.IFS_OBJECT_TYPE IS NOT DISTINCT FROM b.IFS_OBJECT_TYPE  
UNION ALL
SELECT 'Failover' AS "System Name", 
     b.IFS_DIRECTORY, b.IFS_OBJECT_NAME, b.IFS_OBJECT_TYPE
     FROM IFSINFO.local_IFS_objects a RIGHT EXCEPTION JOIN 
          IFSINFO.remote_IFS_objects b 
          ON b.IFS_DIRECTORY   IS NOT DISTINCT FROM a.IFS_DIRECTORY   AND
             b.IFS_OBJECT_NAME IS NOT DISTINCT FROM a.IFS_OBJECT_NAME AND
             b.IFS_OBJECT_TYPE IS NOT DISTINCT FROM a.IFS_OBJECT_TYPE
  ORDER BY IFS_DIRECTORY, IFS_OBJECT_NAME,IFS_OBJECT_TYPE;


--  category:  Db2 for i Services
--  description:  Compare SYSROUTINE across two IBM i partitions

-- Given a remote IBM i partition name and a library name
-- Search for procedure and function differences 
-- Receive a result set with any differences
CALL SYSTOOLS.CHECK_SYSROUTINE('MYREMOTE', 'TOYSTORE', default);

-- Search for procedure and function differences 
-- Query SESSION.SYSRTNDIFF to see the differences
CALL SYSTOOLS.CHECK_SYSROUTINE('MYREMOTE', 'TOYSTORE', 1);
SELECT * FROM SESSION.SYSRTNDIFF;


--  category:  Db2 for i Services
--  description:  Compare database constraints across two IBM i partitions

-- Given a remote IBM i partition name and a library name
-- Search for constraint differences 
-- Receive a result set with any differences
CALL SYSTOOLS.CHECK_SYSCST('MYREMOTE', 'TOYSTORE', default);

-- Search for constraint differences 
-- Query SESSION.SYSCSTDIFF to see the differences
CALL SYSTOOLS.CHECK_SYSCST('MYREMOTE', 'TOYSTORE', 1);
SELECT * FROM SESSION.SYSCSTDIFF;


--  category:  Db2 for i Services
--  description:  Daily SQL Plan Cache management

CL: CRTLIB SNAPSHOTS;
CL: CRTLIB EVENTMONS;
-- Purpose: This procedure captures detail on SQL queries.
--          1) The 100 most expensive SQL queries are captured into a SQL Plan Cache Snapshot named SNAPSHOTS/SNP<julian-date>
--          2) An SQL Plan Cache Event Monitor is started using a name SNAPSHOTS/EVT<julian-date>. The previous event monitor is ended.
--          3) For both 1 & 2, only the 14 most recent days are kept online. 
--          4) For both 1 & 2, the new monitor and snap shot are imported into System i Navigator / ACS SQL Performance Monitor
CREATE OR REPLACE PROCEDURE SNAPSHOTS.DAILY_PC_MANAGEMENT()
LANGUAGE SQL
BEGIN
DECLARE not_found CONDITION FOR '02000';
DECLARE SNAP_NAME CHAR(10);
DECLARE OLDEST_SNAP_NAME CHAR(10);
DECLARE SNAP_COMMENT VARCHAR(100);
DECLARE EVENT_MONITOR_NAME CHAR(10);
DECLARE YESTERDAY_EVENT_MONITOR_NAME CHAR(10);
DECLARE OLDEST_EVENT_MONITOR_NAME CHAR(10);
DECLARE v_not_found BIGINT DEFAULT 0;

-- A Julian date is the integer value representing a number of days
-- from January 1, 4713 B.C. (the start of the Julian calendar) to 
-- the date specified in the argument.
SET SNAP_NAME = 'SNP' CONCAT JULIAN_DAY(current date);
SET OLDEST_SNAP_NAME = 'SNP' CONCAT JULIAN_DAY(current date - 14 days);
SET EVENT_MONITOR_NAME = 'EVT' CONCAT JULIAN_DAY(current date);
SET OLDEST_EVENT_MONITOR_NAME = 'EVT' CONCAT JULIAN_DAY(current date - 14 days);
SET YESTERDAY_EVENT_MONITOR_NAME = 'EVT' CONCAT JULIAN_DAY(current date - 1 day);
---------------------------------------------------------------------------------------------------------
-- Process the Top 100 most expensive queries
---------------------------------------------------------------------------------------------------------
-- Capture the topN queries and import the snapshot
CALL QSYS2.DUMP_PLAN_CACHE_topN('SNAPSHOTS', SNAP_NAME, 100);

-- Remove the oldest TOPN snapshot
BEGIN
  DECLARE CONTINUE HANDLER FOR not_found 
     SET v_not_found = 1; 
  CALL QSYS2.REMOVE_PC_SNAPSHOT('SNAPSHOTS', OLDEST_SNAP_NAME);
END;

---------------------------------------------------------------------------------------------------------
-- Process prune plans using the SQL Plan Cache Event Monitor
---------------------------------------------------------------------------------------------------------
-- If we found yesterdays event monitor, end it 
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
     SET v_not_found = 1; 
  CALL QSYS2.END_PLAN_CACHE_EVENT_MONITOR(YESTERDAY_EVENT_MONITOR_NAME);
END;

-- Start today's event monitor
CALL QSYS2.START_PLAN_CACHE_EVENT_MONITOR('EVENTMONS', EVENT_MONITOR_NAME);

-- Remove the oldest event monitor
BEGIN
  DECLARE CONTINUE HANDLER FOR not_found 
     SET v_not_found = 1; 
  CALL QSYS2.REMOVE_PC_EVENT_MONITOR('EVENTMONS', OLDEST_EVENT_MONITOR_NAME);
END;
END;


--
-- Add this call to a scheduled job that runs once per day
--
Call SNAPSHOTS.DAILY_PC_MANAGEMENT();


--  category:  Db2 for i Services
--  description:  Enable alerts for files which are growing near the maximum

CL: ALCOBJ OBJ((QSYS2/SYSLIMTBL *FILE *EXCL)) CONFLICT(*RQSRLS) ;
CL: DLCOBJ OBJ((QSYS2/SYSLIMTBL *FILE *EXCL));

CREATE OR REPLACE TRIGGER SCOTTF.SYSTEM_LIMITS_LARGE_FILE
	AFTER INSERT ON QSYS2.SYSLIMTBL 
	REFERENCING NEW AS N FOR EACH ROW MODE DB2ROW 
SET OPTION USRPRF=*OWNER, DYNUSRPRF=*OWNER
BEGIN ATOMIC 
DECLARE V_CMDSTMT VARCHAR(200) ;
DECLARE V_ERROR INTEGER;

DECLARE EXIT HANDLER FOR SQLEXCEPTION 
   SET V_ERROR = 1;

/* ------------------------------------------------------------------ */
/* If a table has exceeded 80% of this limit, alert the operator     */
/* ------------------------------------------------------------------ */
/* 15000 == MAXIMUM NUMBER OF ALL ROWS IN A PARTITION                 */
/*          (max size = 4,294,967,288)                                */
/* ------------------------------------------------------------------ */
IF (N.LIMIT_ID = 15000 AND
    N.CURRENT_VALUE > ((select supported_value from qsys2.sql_sizing where sizing_id = 15000) * 0.8)) THEN 

SET V_CMDSTMT = 'SNDMSG MSG(''Table: ' 
     CONCAT N.SYSTEM_SCHEMA_NAME CONCAT '/' CONCAT N.SYSTEM_OBJECT_NAME
     CONCAT ' (' CONCAT N.SYSTEM_TABLE_MEMBER CONCAT 
     ') IS GETTING VERY LARGE - ROW COUNT =  '
     CONCAT CURRENT_VALUE CONCAT ' '') TOUSR(*SYSOPR) MSGTYPE(*INFO) ';
 CALL QSYS2.QCMDEXC( V_CMDSTMT );
END IF;
END;

commit;

-- Description: Determine if any user triggers have been created over the System Limits table
SELECT * FROM QSYS2.SYSTRIGGERS 
  WHERE EVENT_OBJECT_SCHEMA = 'QSYS2' AND EVENT_OBJECT_TABLE = 'SYSLIMTBL';


--  category:  Db2 for i Services
--  description:  Find and fix SQL DYNUSRPRF setting
--  minvrm: V7R3M0
--
-- Which SQL programs or services have a mismatch between user profile and dynamic user profile (full)
--
select user_profile, dynamic_user_profile, program_schema, program_name, program_type,
       module_name, program_owner, program_creator, creation_timestamp, default_schema,
       "ISOLATION", concurrentaccessresolution, number_statements, program_used_size,
       number_compressions, statement_contention_count, original_source_file,
       original_source_file_ccsid, routine_type, routine_body, function_origin,
       function_type, number_external_routines, extended_indicator, c_nul_required,
       naming, target_release, earliest_possible_release, rdb, consistency_token,
       allow_copy_data, close_sql_cursor, lob_fetch_optimization, decimal_point,
       sql_string_delimiter, date_format, date_separator, time_format, time_separator,
       dynamic_default_schema, current_rules, allow_block, delay_prepare, user_profile,
       dynamic_user_profile, sort_sequence, language_identifier, sort_sequence_schema,
       sort_sequence_name, rdb_connection_method, decresult_maximum_precision,
       decresult_maximum_scale, decresult_minimum_divide_scale, decfloat_rounding_mode,
       decfloat_warning, sqlpath, dbgview, dbgkey, last_used_timestamp, days_used_count,
       last_reset_timestamp, system_program_name, system_program_schema, iasp_number,
       system_time_sensitive
  from qsys2.sysprogramstat
  where system_program_schema = 'SCOTTF'
        and dynamic_user_profile = '*USER' and program_type in ('*PGM', '*SRVPGM')
        and ((user_profile = '*OWNER')
          or (user_profile = '*NAMING'
            and naming = '*SQL'))
  order by program_name;
stop;

--
-- Which SQL programs or services have a mismatch between user profile and dynamic user profile (full)
--
select qsys2.delimit_name(system_program_schema) as lib, 
       qsys2.delimit_name(system_program_name) as pgm, 
       program_type as type
  from qsys2.sysprogramstat
  where system_program_schema = 'SCOTTF'
        and dynamic_user_profile = '*USER' 
        and program_type in ('*PGM', '*SRVPGM')
        and ((user_profile = '*OWNER')
          or (user_profile = '*NAMING'
            and naming = '*SQL'))
  order by program_name;

stop;  

  

--
-- Find misaligned use of SQL's Dynamic User Profile and swap the setting
--
CREATE OR REPLACE PROCEDURE coolstuff.swap_dynusrprf(target_library varchar(10))
   BEGIN
      DECLARE v_eof INTEGER DEFAULT 0;
      DECLARE Prepare_Attributes VARCHAR(100) default ' ';
      declare sql_statement_text clob(10K) ccsid 37;
      declare v_lib varchar(10) ccsid 37;
      declare v_pgm varchar(10) ccsid 37;
      declare v_type varchar(7) ccsid 37;
      DECLARE obj_cursor CURSOR FOR 
select qsys2.delimit_name(system_program_schema) as lib, 
       qsys2.delimit_name(system_program_name) as pgm, 
       program_type as type
  from qsys2.sysprogramstat
  where program_schema = target_library
        and dynamic_user_profile = '*USER'
        and program_type in ('*PGM', '*SRVPGM')
        and ((user_profile = '*OWNER')
          or (user_profile = '*NAMING'
            and naming = '*SQL'))
  order by program_name;
 
      OPEN obj_cursor;
      loop_through_data: BEGIN
                            DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
                               BEGIN
                               SET v_eof = 1;
                         END;                                                       
       l3 : LOOP
           FETCH obj_cursor INTO v_lib, v_pgm, v_type;
           IF (v_eof = 1)
           THEN
              LEAVE l3;
           END IF;
           
           -- Swap the SQL DYNUSRPRF setting
           CALL QSYS2.SWAP_DYNUSRPRF(v_lib, v_pgm, v_type);
           call systools.lprintf('DYNUSRPRF swapped for: ' concat v_lib concat '/' concat v_pgm concat ' ' concat v_type);

        END LOOP; /* L3 */
      CLOSE obj_cursor;
   END loop_through_data;
END;

stop;

-- Process all the misaligned SQL DynUsrPrf settings for a specific library
call coolstuff.swap_dynusrprf('SCOTTF');

  


--  category:  Db2 for i Services
--  description:  Index Advice - Analyzing advice since last IPL 

-- Examine the condensed index advice where the index advice has occurred since the last IPL
WITH last_ipl(ipl_time)
   AS (SELECT job_entered_system_time
          FROM TABLE(qsys2.job_info(job_status_filter => '*ACTIVE', 
                                    job_user_filter   => 'QSYS')) x
            WHERE job_name = '000000/QSYS/SCPF')
   SELECT
      * from  last_ipl, qsys2.condidxa where last_advised > ipl_time;
      
--
-- Examine the condensed index advice where Maintained Temporary Indexes (MTI)
-- have been used since the last IPL
--      
WITH last_ipl(ipl_time)
   AS (SELECT job_entered_system_time
          FROM TABLE(qsys2.job_info(job_status_filter => '*ACTIVE', 
                                    job_user_filter   => 'QSYS')) x
            WHERE job_name = '000000/QSYS/SCPF')
   SELECT
      * from  last_ipl, qsys2.condidxa 
        where last_mti_used > ipl_time or last_mti_used_for_stats > ipl_time;
      


--  category:  Db2 for i Services
--  description:  Interrogate interactive jobs

WITH INTERACTIVE_JOBS(JOBNAME, STATUS, CPU, IO) AS (
  SELECT job_name, job_status, cpu_time, total_disk_io_count 
    FROM TABLE(qsys2.active_job_info('YES', 'QINTER', '*ALL')) AS a
    WHERE JOB_STATUS IN ('LCKW', 'RUN') 
)
  SELECT JOBNAME, STATUS, CPU, IO, 
         PROGRAM_LIBRARY_NAME,  PROGRAM_NAME,                       
         MODULE_LIBRARY_NAME,   MODULE_NAME,                        
         HEX(BIGINT(STATEMENT_IDENTIFIERS)) AS STMT,
         PROCEDURE_NAME,        ACTIVATION_GROUP_NAME,
         OBJTEXT,               v_client_ip_address
     FROM INTERACTIVE_JOBS I,
     LATERAL  
     (SELECT * FROM TABLE(qsys2.stack_info(JOBNAME)) j
       WHERE program_library_name not like 'Q%'
         order by ordinal_position desc
           LIMIT 1) x,
     LATERAL 
     (SELECT OBJTEXT from table(qsys2.object_statistics(x.PROGRAM_LIBRARY_NAME, 
                                                        '*PGM *SRVPGM',
                                                        x.PROGRAM_NAME)) AS c) AS Y, 
     LATERAL 
     (SELECT v_client_ip_address from table(qsys2.get_job_info(JOBNAME)) AS d) AS z
  ORDER BY CPU DESC;


--  category:  Db2 for i Services
--  description:  Reset indexes statistics while in production

-- This procedure resets QUERY_USE_COUNT and QUERY_STATISTICS_COUNT.
-- The LAST_QUERY_USE, LAST_STATISTICS_USE, LAST_USE_DATE and 
-- NUMBER_DAYS_USED are not affected.
-- 
-- Reset Query statistics over TOYSTORE/EMPLOYEE
--
CALL QSYS2.RESET_TABLE_INDEX_STATISTICS('TOYSTORE', 'EMPLOYEE');

--
-- Reset Query statistics over all tables in the TOYSTORE library
--
CALL QSYS2.RESET_TABLE_INDEX_STATISTICS('TOYSTORE','%');


--  category:  Db2 for i Services
--  description:  Review the distribution of deleted records

SELECT 1000000 - COUNT(*) AS DELETEDCNT
   FROM star100g.item_fact A
   GROUP BY BIGINT(RRN(A) / 1000000)
   ORDER BY BIGINT(RRN(A) / 1000000);
   


--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Add a threshold
--  minvrm: V7R3M0
--

--
-- Add a threshold for elapsed time of queries coming in over QZDA jobs
--
CALL QSYS2.ADD_QUERY_THRESHOLD(THRESHOLD_NAME  => 'ZDA QUERY TIME > 30',
                               THRESHOLD_TYPE  => 'ELAPSED TIME',
                               THRESHOLD_VALUE => 30,
                               SUBSYSTEMS      => 'QUSRWRK',
                               JOB_NAMES       =>  'QZDA*', 
                               LONG_COMMENT    => 'ZDA Queries running longer than 30 seconds');

--
-- Review configured Query Supervisor thresholds
--
select *
  from qsys2.query_supervisor;


--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Exit programs
--  minvrm: V7R3M0
--

--
-- Review the Query Supervisor exit programs
--  
select *
  from QSYS2.EXIT_PROGRAM_INFO where EXIT_POINT_NAME = 'QIBM_QQQ_QRY_SUPER';


--  category:  Db2 for i Services
--  description:  SQE - Query Supervisor - Remove a threshold
--  minvrm: V7R3M0
--

--
-- Remove a Query Supervisor threshold 
--
CALL QSYS2.REMOVE_QUERY_THRESHOLD(THRESHOLD_NAME  => 'ZDA QUERY TIME > 30');

--
-- Review configured Query Supervisor thresholds
--
select *
  from qsys2.query_supervisor;


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

call qsys2.qcmdexc('CRTSRCPF FILE(QTEMP/ZDA_ELAP1) RCDLEN(140)');
call qsys2.qcmdexc('addpfm file(qtemp/ZDA_ELAP1) mbr(ZDA_ELAP1)');
insert into qtemp.ZDA_ELAP1
  values
 (1, 010101, '#include <stdlib.h>'),
 (2, 010101, '#include <string.h>'),
 (3, 010101, '#include <stddef.h> '),
 (4, 010101, '#include <iconv.h>'),
 (5, 010101, '#include <stdio.h>'),
 (6, 010101, '#include <except.h>'), 
 (7, 010101, '#include <eqqqrysv.h>'),
 (8, 010101, 'static void convertThresholdNameToJobCCSID(const char* input, char* output)'),
 (9, 010101, '{'),
 (10,010101, '  iconv_t converter;'),
 (11,010101, '  char from_code[32], to_code[32];'),
 (12,010101, '  size_t input_bytes, output_bytes;'),
 (13,010101, '  int iconv_rc;'),
 (14,010101, '  memset(from_code, 0, sizeof(from_code));'),
 (15,010101, '  memset(to_code, 0, sizeof(to_code));'),
 (16,010101, '  memcpy(from_code, "IBMCCSID012000000000", 20);'),
 (17,010101, '  memcpy(to_code, "IBMCCSID00000", 13);'),
 (18,010101, '  converter = iconv_open(to_code, from_code);'),
 (19,010101, '  if (converter.return_value == 0) {'),
 (20,010101, '    input_bytes = 60;'),
 (21,010101, '   output_bytes = 30;'),
 (22,010101, '    iconv_rc = iconv(converter,'),
 (23,010101, '                     &input, &input_bytes,'),
 (24,010101, '                     &output, &output_bytes);'),
 (25,010101, '    iconv_close(converter);'),
 (26,010101, '    if (iconv_rc >= 0)'),
 (27,010101, '      return; /* Conversion was successful. */'),
 (28,010101, '  }'),
 (29,010101, '  sprintf(output, "iconv_open() failed with: %d", converter.return_value);'),
 (30,010101, '}'),
 (31,010101, 'int trimmed_length(const char* str, int len)'),
 (32,010101, '{'),
 (33,010101, '  const char* first_blank = memchr(str, '' '', len);'),
 (34,010101, '  if (first_blank)'),
 (35,010101, '    return first_blank - str;'),
 (36,010101, '  return len;'),
 (37,010101, '}'),
 (38,010101, 'int main(int argc, char* argv[])'),
 (39,010101, '{'),
 (40,010101, '  char length_string[10];'),
 (41,010101, '  char cmd[600];'),
 (42,010101, '  char thresholdNameInJobCCSID[31];'),
 (43,010101, '  char msg[512];'),
 (44,010101, '  const QQQ_QRYSV_QRYS0100_t* input = (QQQ_QRYSV_QRYS0100_t*)argv[1];'),
 (45,010101, '  int* rc = (int*)argv[2];'),
 (46,010101, '  memset(thresholdNameInJobCCSID, 0, sizeof(thresholdNameInJobCCSID));'),
 (47,010101, '  convertThresholdNameToJobCCSID(input->Threshold_Name,thresholdNameInJobCCSID);'),
 (48,010101, '  if (memcmp("ZDA QUERY TIME > 30", thresholdNameInJobCCSID, 19) != 0) '),
 (49,010101, '    { return; } '),
 (50,010101, '  *rc = 1; /* terminate the query */'),
 (51,010101, '  memset(msg, 0, sizeof(msg));'),
 (52,010101, '  strcat(msg, "Query Supervisor: ");'),
 (53,010101, '  strcat(msg, thresholdNameInJobCCSID);'),
 (54,010101, '  strcat(msg," REACHED IN JOB ");'),
 (55,010101, '  strncat(msg, input->Job_Number, trimmed_length(input->Job_Number,6));'),
 (56,010101, '  strcat(msg, "/");'),
 (57,010101, '  strncat(msg, input->Job_User, trimmed_length(input->Job_User,10));'),
 (58,010101, '  strcat(msg, "/");'),
 (59,010101, '  strncat(msg, input->Job_Name, trimmed_length(input->Job_Name,10));'),
 (60,010101, '  strcat(msg, " FOR USER: ");'),
 (61,010101, '  strncat(msg, input->User_Name, 10);'),
 (62,010101, '  memset(length_string, 0, sizeof(length_string));'),
 (63,010101, '  sprintf(length_string,"%d",strlen(msg));'),
 (64,010101, '  memset(cmd, 0, sizeof(cmd));'),
 (65,010101, '  strcat(cmd, "SBMJOB CMD(RUNSQL SQL(''call qsys2.send_message(''''SQL7064'''',");'),
 (66,010101, '  strcat(cmd,length_string);'),
 (67,010101, '  strcat(cmd,",''''");'),
 (68,010101, '  strcat(cmd, msg);'),
 (69,010101, '  strcat(cmd, "'''')''))");'),
 (70,010101, '  system(cmd);'),
 (71,010101, '}');
 
cl: crtlib supervisor;

call qsys2.qcmdexc('CRTCMOD MODULE(QTEMP/ZDA_ELAP1) SRCFILE(QTEMP/ZDA_ELAP1)  OUTPUT(*print)  ');
call qsys2.qcmdexc('CRTPGM PGM(SUPERVISOR/ZDA_ELAP1) MODULE(QTEMP/ZDA_ELAP1) ACTGRP(*CALLER) USRPRF(*OWNER) DETAIL(*NONE)');
 
call qsys2.qcmdexc('ADDEXITPGM EXITPNT(QIBM_QQQ_QRY_SUPER) FORMAT(QRYS0100) PGMNBR(*LOW) PGM(SUPERVISOR/ZDA_ELAP1) THDSAFE(*YES) TEXT(''ZDA Elapsed Time > 30 seconds'')') ;


--
-- Review any instances where the Query Supervisor exit program terminated a ZDA query
--
select *
  from table (
      QSYS2.MESSAGE_QUEUE_INFO(MESSAGE_FILTER => 'ALL')
    )
  where message_id = 'SQL7064'
  order by MESSAGE_TIMESTAMP desc; 
  



--  category:  Db2 for i Services
--  description:  Utilities - Database Catalog analyzer
--  minvrm: V7R3M0
--
--  Find all database files in the QGPL library and validate that associated 
--  Database Cross Reference file entries contain the correct and complete detail
--
select *
  from table (
      qsys2.analyze_catalog(option => 'DBXREF', library_name => 'QGPL')
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
select *
  from table (
      systools.validate_data(
        library_name => 'MARYNA', file_name => 'BADDATA', member_name => '*LAST')
    );
stop;

--
-- Validate all rows within all members of one file
--
select *
  from table (
      systools.validate_data_file(
        library_name => 'MARYNA', file_name => 'BADDATA')
    );
stop;

--
-- Validate all rows within all members of all files within a library
--
select *
  from table (
      systools.validate_data_library(
        library_name => 'MARYNA')
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

