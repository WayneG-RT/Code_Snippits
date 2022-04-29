--  category:  IBM i Services
--  description:  Application - Bound Module - Optimization level detail

--
--  Are we taking advantage of ILE optimization?
--
select optimization_level, count(*) as optimization_level_count
  from qsys2.bound_module_info
  where program_library = 'APPLIB'
  group by optimization_level
  order by 2 desc;


--  category:  IBM i Services
--  description:  Application - Bound Module - What's not built from IFS source?

--
--  Which modules are not being built with source residing in the IFS?
--
select *
  from qsys2.bound_module_info
  where program_library = 'QGPL'
        and source_file_library not in ('QTEMP')
        and source_stream_file_path is null
  order by source_file_library, source_file, source_file_member desc;


--  category:  IBM i Services
--  description:  Application - Bound SRVPGM - Deferred Activation

--
--  Are we using deferred service program activation?
--
select bound_service_program_activation, count(*) as bound_service_program_activation_count
  from qsys2.BOUND_SRVPGM_INFO
  where program_library = 'APPLIB'
  group by bound_service_program_activation
  order by 2 desc;


--  category:  IBM i Services
--  description:  Application - Data Queue Entries
--

--
-- Data queue example
--
create schema TheQueen;
cl:CRTDTAQ DTAQ(TheQueen/OrderDQ) MAXLEN(100) SEQ(*KEYED) KEYLEN(3);
call qsys2.send_data_queue(message_data       => 'Sue - Dilly Bar',
                           data_queue         => 'ORDERDQ', 
                           data_queue_library => 'THEQUEEN',
                           key_data           => '010');
call qsys2.send_data_queue(message_data       => 'Sarah - Ice cream cake!',
                           data_queue         => 'ORDERDQ', 
                           data_queue_library => 'THEQUEEN',
                           key_data           => '020');
call qsys2.send_data_queue(message_data       => 'Scott - Strawberry Sundae',
                           data_queue         => 'ORDERDQ', 
                           data_queue_library => 'THEQUEEN',
                           key_data           => '030');
call qsys2.send_data_queue(message_data       => 'Scott - Pineapple Shake',
                           data_queue         => 'ORDERDQ', 
                           data_queue_library => 'THEQUEEN',
                           key_data           => '030');
stop;

-- Search what's on the DQ
select message_data, key_data from table
     (qsys2.data_queue_entries('ORDERDQ', 'THEQUEEN', 
                               selection_type => 'KEY',
                               key_data       => '030',
                               key_order      => 'EQ'));
stop;

-- Order fulfilled!
select message_data, message_data_utf8, message_data_binary, key_data, sender_job_name, sender_current_user
  from table (
      qsys2.receive_data_queue(
        data_queue => 'ORDERDQ', data_queue_library => 'THEQUEEN', 
        remove => 'YES',
        wait_time => 0, 
        key_data => '030', 
        key_order => 'EQ')
    );
stop;

-- What remains on the queue?
select * from table
     (qsys2.data_queue_entries('ORDERDQ', 'THEQUEEN', 
                               selection_type => 'KEY',
                               key_data       => '030',
                               key_order      => 'LE'));          


--  category:  IBM i Services
--  description:  Application - Data Queues - Info and detail
--

--
-- Review data queues, by percentage filled up
--
select data_queue_library, data_queue_name, data_queue_type, 
       current_messages, maximum_messages, 
       DEC(DEC(current_messages,19,2) / DEC(maximum_messages,19,2) * 100,19,2) AS percentage_used,
       maximum_message_length, 
       "SEQUENCE", key_length,
       include_sender_id, specified_maximum_messages, initial_message_allocation,
       current_message_allocation, force, automatic_reclaim, last_reclaim_timestamp,
       enforce_data_queue_locks, text_description, remote_data_queue_library,
       remote_data_queue, remote_location, relational_database_name,
       appc_device_description, local_location, "MODE", remote_network_id
  from qsys2.data_queue_info
  order by 6 desc;



--  category:  IBM i Services
--  description:  Application - Data Queues - Keyed
--

cl:CRTDTAQ DTAQ(COOLSTUFF/KEYEDDQ) MAXLEN(64000) SEQ(*KEYED) KEYLEN(8) SENDERID(*YES) SIZE(*MAX2GB) TEXT('DQueue Time');

select *
  from qsys2.data_queue_info
  where data_queue_library = 'COOLSTUFF';
  
stop;
-- Example of how to produce a key value
values lpad(3, 8, 0);
stop;

call qsys2.send_data_queue(data_queue_library => 'COOLSTUFF',
                           data_queue => 'KEYEDDQ',
                           message_data => 'Keyed message 1',
                           key_data => lpad(1, 8, 0) );  
                           
call qsys2.send_data_queue(data_queue_library => 'COOLSTUFF',
                           data_queue => 'KEYEDDQ',
                           message_data => 'Keyed message 2',
                           key_data => lpad(2, 8, 0) );  
                           
call qsys2.send_data_queue(data_queue_library => 'COOLSTUFF',
                           data_queue => 'KEYEDDQ',
                           message_data => 'Keyed message 3',
                           key_data => lpad(3, 8, 0) );

stop;

select *
  from qsys2.data_queue_info
  where data_queue_library = 'COOLSTUFF';
                            
stop;

select *
  from table(qsys2.receive_data_queue(
               data_queue_library => 'COOLSTUFF',
               data_queue => 'KEYEDDQ',
               key_data => lpad(3, 8, 0),
               key_order => 'EQ'));


select *
  from table(qsys2.receive_data_queue(
               data_queue_library => 'COOLSTUFF',
               data_queue => 'KEYEDDQ',
               key_data => lpad(99, 8, 0),
               key_order => 'LT')); 


select *
  from table(qsys2.receive_data_queue(
               data_queue_library => 'COOLSTUFF',
               data_queue => 'KEYEDDQ',
               key_data => lpad(0, 8, 0),
               key_order => 'GT')); 
               
                  


--  category:  IBM i Services
--  description:  Application - Data Queues - Send and Receive
--

-- create a data queue
cl: crtlib coolstuff;
cl:CRTDTAQ DTAQ(COOLSTUFF/SQLCANDOIT) MAXLEN(32000) SENDERID(*YES);
stop;

-- review the state and status of the data queue
select *
  from qsys2.data_queue_info
  where data_queue_library = 'COOLSTUFF';
stop;

-- Send a (character) message to the data queue
call qsys2.send_data_queue(
  message_data       => 'Hello World... today is ' concat current date, 
  data_queue         => 'SQLCANDOIT',
  data_queue_library => 'COOLSTUFF');

stop;

-- Retrieve the message from the data queue
select *
  from table (
      qsys2.receive_data_queue(
        data_queue => 'SQLCANDOIT', data_queue_library => 'COOLSTUFF')
    );


--  category:  IBM i Services
--  description:  Application - Data Queues - UTF8 data
--

--
-- Send unicode data to the data queue
--
call qsys2.send_data_queue_utf8(
  message_data       => 'Hello World... today is ' concat current date, 
  data_queue         => 'SQLCANDOIT',
  data_queue_library => 'COOLSTUFF');

stop;

-- Retrieve the message from the data queue
select message_data_utf8
  from table (
      qsys2.receive_data_queue(
        data_queue => 'SQLCANDOIT', data_queue_library => 'COOLSTUFF')
    );


--  category:  IBM i Services
--  description:  Application - Environment variable information

--
-- Retrieve the environment variables for the
-- current connection
--
SELECT * FROM QSYS2.ENVIRONMENT_VARIABLE_INFO;


--  category:  IBM i Services
--  description:  Application - Examine my stack 

--
-- Look at my thread's stack
-- 
SELECT * FROM TABLE(QSYS2.STACK_INFO('*')) AS x
  WHERE LIC_PROCEDURE_NAME IS NULL
     ORDINAL_POSITION;

--
-- Look at all threads in my job
-- 
SELECT * FROM TABLE(QSYS2.STACK_INFO('*', 'ALL')) AS x
  WHERE LIC_PROCEDURE_NAME IS NULL
     ORDER BY THREAD_ID, ORDINAL_POSITION;



--  category:  IBM i Services
--  description:  Application - Exit Point information
--

--
-- What are the CL command exit programs?
--
select *
  from qsys2.exit_point_info
  where exit_point_name like 'QIBM_QCA_%_COMMAND%';


--  category:  IBM i Services
--  description:  Application - Exit Program information
--

--
-- What are the CL command exit programs?
--
select a.*, b.*
  from qsys2.exit_program_info a, lateral 
  (select * from table(qsys2.object_statistics(exit_program_library, '*PGM', exit_program))) b
  where exit_point_name like 'QIBM_QCA_%_COMMAND%'
  order by exit_point_name, exit_program_number;


--  category:  IBM i Services
--  description:  Application - Messages being Watched
--

--
-- What messages are being watched?
--
select a.session_id, a.status, b.message_id, b.message_type,
       b.message_queue_library, b.message_queue, b.message_job_name, b.message_job_user,
       b.message_job_number, b.message_severity, b.message_relational_operator,
       b.message_comparison_data, b.message_compare_against, b.comparison_data_ccsid
  from qsys2.watch_info a, lateral (
         select *
           from table (
               qsys2.watch_detail(session_id => a.session_id)
             )
       ) b
  where watched_message_count > 0
  order by session_id;


--  category:  IBM i Services
--  description:  Application - PASE Shell 

--
-- Set the current user's shell to BASH shipped by 5733-OPS.
--
CALL QSYS2.SET_PASE_SHELL_INFO('*CURRENT', 
                               '/QOpenSys/QIBM/ProdData/OPS/tools/bin/bash');

--
-- Set the default shell to be ksh for any users that do not have an explicit shell set.
--
CALL QSYS2.SET_PASE_SHELL_INFO('*DEFAULT', '/QOpenSys/usr/bin/ksh');

--
-- Review shell configuration
--
select authorization_name, pase_shell_path 
  from qsys2.user_info where pase_shell_path is not null;


--  category:  IBM i Services
--  description:  Application - Pending database transactions
--

select job_name, state_timestamp, user_name, t.*
  from qsys2.db_transaction_info t
  where local_changes_pending = 'YES'
  order by t.state_timestamp;


--  category:  IBM i Services
--  description:  Application - Program Export/Import
--
--
--   Alternative to: DSPSRVPGM SRVPGM(QSYS/QP0ZCPA) DETAIL(*PROCEXP) 
--
select *
  from qsys2.PROGRAM_EXPORT_IMPORT_INFO 
  where program_library = 'QSYS'    and 
        program_name    = 'QP0ZCPA' and
        object_type     = '*SRVPGM' and
        symbol_usage    = '*PROCEXP';



--  category:  IBM i Services
--  description:  Application - Program info - Activation Group analysis
--
--
--  Summarize the activation group usage
--
select activation_group, count(*) as activation_group_name_count
  from qsys2.program_info
  where program_library = 'APPLIB'
        and program_type = 'ILE'
  group by activation_group
  order by 2 desc;



--  category:  IBM i Services
--  description:  Application - Program info - Ownership Summary
--
--
--  Review adopted ownership (summary)
--
select program_owner, object_type, count(*) as application_owner_count
  from qsys2.program_info
  where program_library = 'APPLIB' and 
        user_profile = '*OWNER'
  group by program_owner, object_type
  order by 2, 3 desc;
  



--  category:  IBM i Services
--  description:  Application - QCMDEXC scalar function
--

--
-- Hold any jobs that started running an SQL statement more than 2 hours ago.
--
select JOB_NAME,
       case
         when QSYS2.QCMDEXC('HLDJOB ' concat JOB_NAME) = 1 then 'Job Held'
         else 'Job not held'
       end as HLDJOB_RESULT
  from table (
      QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => 'ALL')
    )
  where SQL_STATEMENT_START_TIMESTAMP < current timestamp - 2 hours;


--  category:  IBM i Services
--  description:  Application - Service tracker

--
-- Review all the Security related IBM i Services 
--
SELECT * FROM QSYS2.SERVICES_INFO 
   WHERE SERVICE_CATEGORY = 'SECURITY';

--
-- Find the example for top storage consumers 
--
SELECT EXAMPLE
   FROM QSYS2.SERVICES_INFO
   WHERE EXAMPLE LIKE '%top 10 storage%';


--  category:  IBM i Services
--  description:  Application - Special case Data Areas

--
-- SQL alternative to RTVDTAARA
--
-- *GDA - Group data area.
-- *LDA - Local data area.
-- *PDA - Program initialization parameter data area.
--

select data_area_value from 
  table(qsys2.data_area_info(DATA_AREA_LIBRARY => '*LIBL',
                             DATA_AREA_NAME    => '*GDA'));
                             
select data_area_value from 
  table(qsys2.data_area_info(DATA_AREA_LIBRARY => '*LIBL',
                             DATA_AREA_NAME    => '*LDA'));
                             
select data_area_value from 
  table(qsys2.data_area_info(DATA_AREA_LIBRARY => '*LIBL',
                             DATA_AREA_NAME    => '*PDA'));
                             

                             


--  category:  IBM i Services
--  description:  Application - Split an aggregated list

-- Do the opposite of LISTAGG(), break apart a list of values
SELECT ordinal_position,
       LTRIM(element) AS special_authority
   FROM qsys2.user_info u,
        TABLE (
           systools.split(input_list => special_authorities, 
                          delimiter  => '   ')
        ) b
   WHERE u.authorization_name = 'SCOTTF';
   


--  category:  IBM i Services
--  description:  Application - User Indexes (*USRIDX)
--  minvrm: V7R3M0
--
   
--
--  Review user index attributes
--
select USER_INDEX_LIBRARY, USER_INDEX, ENTRY_TYPE, ENTRY_LENGTH, MAXIMUM_ENTRY_LENGTH, INDEX_SIZE,
       IMMEDIATE_UPDATE, OPTIMIZATION, KEY_INSERTION, KEY_LENGTH, ENTRY_TOTAL, ENTRIES_ADDED,
       ENTRIES_REMOVED, TEXT_DESCRIPTION
  from qsys2.user_index_info
  order by ENTRY_TOTAL * ENTRY_LENGTH desc;


--  category:  IBM i Services
--  description:  Application - User Indexes (*USRIDX)
--  minvrm: V7R3M0

--
--  Examine the user index entries
--
select *
  from table (
      QSYS2.USER_INDEX_ENTRIES(USER_INDEX         => 'USRINDEX1', 
                               USER_INDEX_LIBRARY => 'STORE42')
    );


--  category:  IBM i Services
--  description:  Application - User Spaces (*USRSPC)
--  minvrm: V7R3M0
--
--
--  Review user space attributes
--
select USER_SPACE_LIBRARY, USER_SPACE, SIZE, EXTENDABLE, INITIAL_VALUE
  from qsys2.user_space_info
  order by size desc;
  


--  category:  IBM i Services
--  description:  Application - User Spaces (*USRSPC)
--  minvrm: V7R3M0

--
--  Examine the data within a user space
-- 
select *
  from table (
      QSYS2.USER_SPACE(USER_SPACE         => 'USRSPACE1', 
                       USER_SPACE_LIBRARY => 'STORE42')
    );
  


--  category:  IBM i Services
--  description:  Application - Watches
--

--
-- What system watches exist?
--
select session_id, origin, origin_job, start_timestamp, user_id, status,
       watch_session_type, job_run_priority, watched_message_count, watched_lic_log_count,
       watched_pal_count, watch_program_library, watch_program, watch_program_call_start,
       watch_program_call_end, time_limit, time_interval
  from qsys2.watch_info order by session_id;


--  category:  IBM i Services
--  description:  Application - Work with Data areas in QTEMP

--
-- Use SQL to work with a data area
-- 
cl:qsys/CRTDTAARA DTAARA(QTEMP/SECRET) TYPE(*CHAR) LEN(50) VALUE(SAUCE);

select * from 
  table(qsys2.data_area_info(DATA_AREA_LIBRARY => 'QTEMP',
                             DATA_AREA_NAME    => 'SECRET'));

call qsys2.qcmdexc('qsys/CHGDTAARA DTAARA(QTEMP/SECRET) VALUE(''SQL is the secret sauce'')');


select * from 
  table(qsys2.data_area_info(DATA_AREA_LIBRARY => 'QTEMP',
                             DATA_AREA_NAME    => 'SECRET'));



--  category:  IBM i Services
--  description:  Application - Work with numeric Data areas

--
-- Use SQL to extract and manipulate a numeric type data area
-- 

call qsys.create_sql_sample('TOYSTORE');

call qsys2.qcmdexc('QSYS/CRTDTAARA DTAARA(TOYSTORE/SALESLEAD) TYPE(*DEC) LEN(20 2) VALUE(0.00) TEXT(''top dog'')');

select * from qsys2.data_area_info
  where data_area_library = 'TOYSTORE';

begin
declare temp_top_dog varchar(100);

select sales into temp_top_dog from toystore.sales 
  where sales is not null 
  order by sales desc limit 1;

call qsys2.qcmdexc('qsys/CHGDTAARA DTAARA(TOYSTORE/SALESLEAD) VALUE(' concat temp_top_dog concat ')');
end;

select * from qsys2.data_area_info
  where data_area_library = 'TOYSTORE';


--  category:  IBM i Services
--  description:  Communications - Active Database Connections

-- List the active database connections for my job
select * from table(qsys2.active_db_connections(qsys2.job_name));


--  category:  IBM i Services
--  description:  Communications - Active Database Connections

-- Extract the database application server job name
select c.remote_job_name, c.connection_type, c.*
  from table (
      qsys2.active_db_connections('*')
    ) c;


--  category:  IBM i Services
--  description:  Communications - Apache Real Time Server Statistics

-- Review the HTTP Servers thread usage detail
select server_active_threads, server_idle_threads, h.*
  from qsys2.http_server_info h
  where server_name = 'ADMIN'
  order by 1 desc, 2 desc;


--  category:  IBM i Services
--  description:  Communications - Network Statistics Info (NETSTAT)

--  
-- Description: Review the connections that are transferring the most data
--
SELECT * FROM QSYS2.NETSTAT_INFO
  ORDER BY BYTES_SENT_REMOTELY + BYTES_RECEIVED_LOCALLY DESC
  LIMIT 10;



--  category:  IBM i Services
--  description:  Communications - Network Statistics Interface (NETSTAT)

--
-- The following procedure was created to help clients prepare for improved enforcement of TCP/IP configuration problems.
-- Reference: https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/rzaq9/rzaq9osCLtcpifc.htm

--  
-- Analyze NETSTAT Interface detail, looking for problems. 
-- The example shows how TCP/IP would be incorrectly configured and the SQL below shows how to detect that this condition exists
--

-- Example:
CL: ADDTCPIFC INTNETADR('10.1.1.1') LIND(*VIRTUALIP) SUBNETMASK('255.255.252.0');
CL: ADDTCPIFC INTNETADR('10.1.1.2') LIND(*VIRTUALIP) SUBNETMASK('255.255.252.0');
CL: ADDTCPIFC INTNETADR('10.1.1.3') LIND(ETHLINE) SUBNETMASK('255.255.255.255') PREFIFC('10.1.1.1' '10.1.1.2');

CREATE OR REPLACE PROCEDURE FIND_INTERFACE_CONFIG_PROBLEMS()
LANGUAGE SQL
DYNAMIC RESULT SETS 1
SET OPTION DBGVIEW = *SOURCE, OUTPUT = *PRINT
BEGIN
  DECLARE Pref_IP, Int_Addr, Net_Addr VARCHAR(15);
  DECLARE Pref_IP_List VARCHAR(159);
  DECLARE at_end integer default 0;
  DECLARE not_found CONDITION FOR '02000';
  DECLARE Pref_Interface_Result_Cursor CURSOR FOR
    SELECT A.* FROM SESSION.CONFIG_ISSUES A
    INNER JOIN QSYS2.NETSTAT_INTERFACE_INFO B
    ON A.PREFERRED_IP_REFERENCED_AS_A_NON_ETHERNET_INTERFACE = B.INTERNET_ADDRESS
    WHERE B.INTERFACE_LINE_TYPE <> 'ELAN' AND B.INTERFACE_LINE_TYPE <> 'VETH';
  DECLARE PreferredIP_Cursor CURSOR FOR SELECT INTERNET_ADDRESS, NETWORK_ADDRESS, PREFERRED_INTERFACE_LIST
    FROM QSYS2.NETSTAT_INTERFACE_INFO WHERE PREFERRED_INTERFACE_LIST IS NOT NULL;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET at_end  = 1;
  DECLARE CONTINUE HANDLER FOR not_found    SET at_end  = 1;

  DECLARE GLOBAL TEMPORARY TABLE CONFIG_ISSUES(INTERNET_ADDRESS, NETWORK_ADDRESS, PREFERRED_IP_REFERENCED_AS_A_NON_ETHERNET_INTERFACE) AS (
  SELECT INTERNET_ADDRESS, NETWORK_ADDRESS, CAST(NULL AS VARCHAR(15)) FROM QSYS2.NETSTAT_INTERFACE_INFO)
  WITH NO DATA WITH REPLACE;

  OPEN PreferredIP_Cursor;
  FETCH FROM PreferredIP_Cursor INTO Int_Addr, Net_Addr, Pref_IP_List;
  WHILE (at_end = 0) DO
    BEGIN
      DECLARE v_loc integer;
      DECLARE v_start integer default 1;

      Pref_IP_loop: LOOP
        SET v_loc = LOCATE_IN_STRING(Pref_IP_List, ' ', v_start, 1);
        IF (v_loc = 0) THEN
          SET Pref_IP = SUBSTR(Pref_IP_List, v_start);
        ELSE
          SET Pref_IP = SUBSTR(Pref_IP_List, v_start, v_loc - v_start);
        END IF;

        INSERT INTO SESSION.CONFIG_ISSUES VALUES(Int_Addr, Net_Addr, Pref_IP);

        IF (v_loc = 0) THEN
          LEAVE Pref_IP_loop;
        END IF;
        SET v_start = v_loc + 1;
      END LOOP;
    END;
  FETCH FROM PreferredIP_Cursor INTO Int_Addr, Net_Addr, Pref_IP_List;
  END WHILE;
  CLOSE PreferredIP_Cursor;
  OPEN Pref_Interface_Result_Cursor;
END;

--
-- Look for NETSTAT interface problems. Any rows returned should be analyzed.
--
CALL FIND_INTERFACE_CONFIG_PROBLEMS();


--  category:  IBM i Services
--  description:  Communications - Network Statistics Interface (NETSTAT)

--  
-- Analyze NETSTAT Interface detail, looking for problems. 
-- The examples show how TCP/IP would be incorrectly configured and the SQL below shows how to detect that this condition exists
--

-- Example 1
CL: CRTLINETH LIND(MYETH) RSRCNAME(NOEXIST);
CL: ADDTCPIFC INTNETADR('10.1.1.1') LIND(*VIRTUALIP) SUBNETMASK('255.255.252.0');
CL: ADDTCPIFC INTNETADR('10.1.1.2') LIND(MYETH) SUBNETMASK('255.255.255.255') LCLIFC('10.1.1.1');

-- Description: Find instances where a TCP/IP interface contains an associated local interface
-- and the line description type of the interface is not set to *VIRTUALIP
SELECT * FROM QSYS2.NETSTAT_INTERFACE_INFO
WHERE ASSOCIATED_LOCAL_INTERFACE IS NOT NULL AND
      LINE_DESCRIPTION <> '*VIRTUALIP' AND
      INTERFACE_LINE_TYPE = 'ELAN';

-- Example 2
CL: ADDTCPIFC INTNETADR('10.1.1.1') LIND(ETHLINE) SUBNETMASK('255.255.255.255') PREFIFC(*AUTO);

-- Description: Find instances where a TCP/IP interface contains a preferred interface list
-- and the line description type of the interface is not set to *VIRTUALIP
-- and interface selection is performed automatically by the system
SELECT * FROM QSYS2.NETSTAT_INTERFACE_INFO
WHERE PREFERRED_INTERFACE_LIST IS NULL AND
      LINE_DESCRIPTION <> '*VIRTUALIP' AND
      PREFERRED_INTERFACE_DEFAULT_ROUTE = 'NO' AND
      PROXY_ARP_ALLOWED = 'YES' AND
      PROXY_ARP_ENABLED = 'YES';

-- Example 3
CL: CRTLINETH LIND(MYETH) RSRCNAME(NOEXIST);
CL: ADDTCPIFC INTNETADR('10.1.1.1') LIND(*VIRTUALIP) SUBNETMASK('255.255.252.0');
CL: ADDTCPIFC INTNETADR('10.1.1.2') LIND(MYETH) SUBNETMASK('255.255.255.255') PREFIFC('10.1.1.1');

-- Description: Find instances where a TCP/IP interface contains a preferred interface list
-- and the line description type of the interface is not set to *VIRTUALIP
-- and the line type of the interface is not set to Virtual Ethernet
SELECT * FROM QSYS2.NETSTAT_INTERFACE_INFO
WHERE PREFERRED_INTERFACE_LIST IS NOT NULL AND
      LINE_DESCRIPTION <> '*VIRTUALIP' AND
      INTERFACE_LINE_TYPE <> 'VETH';

-- Example 4
CL: ADDTCPIFC INTNETADR('10.1.1.1') LIND(*VIRTUALIP) SUBNETMASK('255.255.252.0');
CL: ADDTCPIFC INTNETADR('10.1.1.2') LIND(ETHLINE) SUBNETMASK('255.255.255.255') LCLIFC('10.1.1.1') PREFIFC('10.1.1.1');

-- Description: Find instances where a TCP/IP interface contains a preferred interface list
-- and an associated local interface list
SELECT * FROM QSYS2.NETSTAT_INTERFACE_INFO
WHERE PREFERRED_INTERFACE_LIST IS NOT NULL AND
      ASSOCIATED_LOCAL_INTERFACE IS NOT NULL;


--  category:  IBM i Services
--  description:  Communications - Network Statistics Job Info (NETSTAT)

--  
-- Analyze remote IP address detail for password failures
--
WITH ip_addrs(rmt_addr, rmt_count)
   AS (SELECT remote_address, COUNT(*)
          FROM TABLE(qsys2.display_journal('QSYS', 'QAUDJRN',
             journal_entry_types => 'PW', starting_timestamp => CURRENT
             TIMESTAMP - 24 HOURS)) AS x
          GROUP BY remote_address)
   SELECT i.rmt_addr, i.rmt_count, user_name, rmt_port
      FROM ip_addrs i LEFT OUTER JOIN 
      qsys2.netstat_job_info n ON i.rmt_addr = remote_address
      ORDER BY rmt_count DESC;


--  category:  IBM i Services
--  description:  Communications - Network Statistics Route Info (NETSTAT)

--  
-- Review the details of all TCP/IP routes
--
SELECT * FROM QSYS2.NETSTAT_ROUTE_INFO;


--  category:  IBM i Services
--  description:  Communications - TCP/IP Information

--
-- description: Who am I?
--
select * from qsys2.tcpip_info;

--
-- Using the well defined port #'s
-- Reference:
-- https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/rzaku/rzakuservertable.htm
--
CREATE OR REPLACE TRIGGER SHOESTORE.INSERT_EMPLOYEE
  BEFORE INSERT ON SHOESTORE.EMPLOYEE 
  REFERENCING NEW AS N 
  FOR EACH ROW 
  MODE DB2ROW  
  SET OPTION DBGVIEW = *SOURCE
IE : BEGIN ATOMIC 
    DECLARE V_SERVER_PORT_NUMBER INTEGER;
    --
    -- Perform extra validation for ODBC users
    --
    SET V_SERVER_PORT_NUMBER = 
      (select server_port_number from qsys2.tcpip_info);
    IF (V_SERVER_PORT_NUMBER = 8471) THEN
       SIGNAL SQLSTATE '80001' 
	 SET MESSAGE_TEXT = 'Employees cannot be added via this interface'; 
    END IF;
END IE  ; 


--  category:  IBM i Services
--  description:  Communications - Time server

-- Define a time server as the preferred time server
--
call qsys2.add_time_server(TIME_SERVER         => 'TICK.RCHLAND.IBM.COM',
                           PREFERRED_INDICATOR => 'YES');
--
-- Define a second time server in case the preferred time server is not reachable
--
call qsys2.add_time_server(TIME_SERVER         => 'TOCK.RCHLAND.IBM.COM',
                           PREFERRED_INDICATOR => 'NO');
--
-- List the time servers that have been defined
--
select * from qsys2.time_protocol_info;


--  category:  IBM i Services
--  description:  Find objects in a library, not included in an authorization list

SELECT a.objname, objdefiner, objtype, sql_object_type
 FROM TABLE(qsys2.object_statistics('TOYSTORE', 'ALL')) a
LEFT EXCEPTION JOIN LATERAL
 (SELECT system_object_name 
    FROM qsys2.authorization_list_info x 
      WHERE AUTHORIZATION_LIST = 'TOYSTOREAL') b
        ON a.objname = b.system_object_name;


--  category:  IBM i Services
--  description:  History Log - Study job longevity 

   WITH JOB_START(start_time, from_user, sbs, from_job) AS (
     SELECT message_timestamp as time, 
          from_user, 
          substr(message_tokens, 59, 10) as subsystem,
          from_job
     FROM TABLE(qsys2.history_log_info(START_TIME => CURRENT DATE,
                                       END_TIME   => CURRENT TIMESTAMP)) x           
     WHERE message_id = 'CPF1124'
     ORDER BY ORDINAL_POSITION DESC
   ) SELECT TIMESTAMPDIFF(4, CAST(b.message_timestamp - a.start_time AS CHAR(22)))
              AS execution_minutes, DAYNAME(b.message_timestamp) AS JOB_END_DAY, 
            a.from_user, a.from_job, a.sbs
     FROM JOB_START A  INNER JOIN
          TABLE(qsys2.history_log_info(START_TIME => CURRENT DATE,
                                       END_TIME   => CURRENT TIMESTAMP)) b
          ON b.from_job = a.from_job 
     WHERE b.message_id = 'CPF1164'
     ORDER BY execution_minutes desc limit 20;


--  category:  IBM i Services
--  description:  IBM PowerHA SystemMirror for i - CRG and Session Switch Readiness
--  minvrm: V7R2M0

--
-- Indicates if a device cluster resource group (CRG) is ready to switch with the READY_TO_SWITCH column. 
-- Contains YES if ready to switch, or NO if not ready to switch.
-- This also provides supporting data for why the CRG is or is not ready to switch. 
-- For example, the CRG status, PowerHA Session Status, or CRG recovery domain node status
--
select crg.cluster_resource_group, crg.crg_status, ssn_info.session_name,
       ssn_info.copy_status, rcydmn_nodes.*, (
       case
         when ((crg.crg_status = 'ACTIVE' or
               crg.crg_status = 'EXIT POINT OPERATION PENDING') and
             ssn_info.copy_status = 'ACTIVE' and
             rcydmn_nodes.number_of_crg_inactive_backup_nodes = 0 and
             rcydmn_nodes.number_of_crg_ineligible_backup_nodes = 0 and
             rcydmn_nodes.number_of_crg_partitioned_backup_nodes = 0) then 'YES'
         else 'NO'
       end) as ready_to_switch
  from qhasm.crg_list crg, (
         select coalesce(sum(
                    case node_status
                      when 'INACTIVE' then 1
                      else 0
                    end), 0) number_of_crg_inactive_backup_nodes, coalesce(sum(
                    case node_status
                      when 'INELIGIBLE' then 1
                      else 0
                    end), 0) number_of_crg_ineligible_backup_nodes, coalesce(sum(
                    case node_status
                      when 'PARTITIONED' then 1
                      else 0
                    end), 0) number_of_crg_partitioned_backup_nodes
           from qhasm.crg_list crg, table (
                  qhasm.crg_recovery_domain(
                    cluster_resource_group => crg.cluster_resource_group)
                ) rcydmn
           where rcydmn.node_status != 'ACTIVE' and
                 rcydmn.current_node_role > 0
       ) as rcydmn_nodes, qhasm.session_list ssn_list, table (
         qhasm.session_info(session => ssn_list.session_name)
       ) ssn_info
  where crg.crg_type = '*DEV' and
        crg.cluster_resource_group = ssn_list.cluster_resource_group; 


--  category:  IBM i Services
--  description:  IBM PowerHA SystemMirror for i - Monitored Resources Requiring Attention
--  minvrm: V7R2M0

--
-- A list of monitored resources that are either failed or inconsistent along with additional node level information
--
select details.monitored_resource, details.resource_type, details.library,
       details.global_status, details.node, details.local_status, details.message_id,
       details.message_text
  from table (
         qhasm.admin_domain_mre_list()
       ) list, table (
         qhasm.admin_domain_mre_details(
           monitored_resource => list.monitored_resource,
           resource_type => list.resource_type, library => list.library)
       ) details
  where (list.global_status = '*INCONSISTENT' or
          list.global_status = '*FAILED') and
        details.local_status != 'CURRENT';


--  category:  IBM i Services
--  description:  IBM PowerHA SystemMirror for i - Unmonitored Resources
--  minvrm: V7R2M0

--
-- Find the list of unmonitored resources in the administrative domain
--
select jobd.objname as "Unmonitored Resource", '*JOBD' as "Resource Type",
       jobd.objlongschema as "Resource Library"
  from table (
      qsys2.object_statistics('*ALL', '*JOBD', '*ALLSIMPLE')
    ) jobd
  where jobd.objlongschema != 'QSYS' and
        jobd.objlongschema != 'QINSYS' and
        jobd.objlongschema != 'QINPRIOR' and
        jobd.objlongschema != 'QINMEDIA' and
        not exists (
            select monitored_resource
              from table (
                  qhasm.admin_domain_mre_list(resource_type => '*JOBD')
                ) mre
              where mre.monitored_resource = jobd.objname)
union
select sbsd.objname as "Unmonitored Resource", '*SBSD' as "Resource Type",
       sbsd.objlongschema as "Resource Library"
  from table (
      qsys2.object_statistics('*ALL', '*SBSD', '*ALLSIMPLE')
    ) sbsd
  where sbsd.objlongschema != 'QSYS' and
        sbsd.objlongschema != 'QINSYS' and
        sbsd.objlongschema != 'QINPRIOR' and
        sbsd.objlongschema != 'QINMEDIA' and
        not exists (
            select monitored_resource
              from table (
                  qhasm.admin_domain_mre_list(resource_type => '*SBSD')
                ) mre
              where mre.monitored_resource = sbsd.objname)
union
select usrprf.objname as "Unmonitored Resource", '*USRPRF' as "Resource Type",
       usrprf.objlongschema as "Resource Library"
  from table (
      qsys2.object_statistics('QSYS', '*USRPRF', '*ALLSIMPLE')
    ) usrprf
  where not exists (
        select monitored_resource
          from table (
              qhasm.admin_domain_mre_list(resource_type => '*USRPRF')
            ) mre
          where mre.monitored_resource = usrprf.objname)
union
select autl.objname as "Unmonitored Resource", '*AUTL' as "Resource Type",
       autl.objlongschema as "Resource Library"
  from table (
      qsys2.object_statistics('QSYS', '*AUTL', '*ALLSIMPLE')
    ) autl
  where not exists (
        select monitored_resource
          from table (
              qhasm.admin_domain_mre_list(resource_type => '*AUTL')
            ) mre
          where mre.monitored_resource = autl.objname)
union
select cls.objname as "Unmonitored Resource", '*CLS' as "Resource Type",
       cls.objlongschema as "Resource Library"
  from table (
      qsys2.object_statistics('*ALL', '*CLS', '*ALLSIMPLE')
    ) cls
  where cls.objlongschema != 'QSYS' and
        cls.objlongschema != 'QINSYS' and
        cls.objlongschema != 'QINPRIOR' and
        cls.objlongschema != 'QINMEDIA' and
        not exists (
            select monitored_resource
              from table (
                  qhasm.admin_domain_mre_list(resource_type => '*CLS')
                ) mre
              where mre.monitored_resource = cls.objname);


--  category:  IBM i Services
--  description:  IFS -  10 largest files under a subdir and tree
--  minvrm: V7R3M0
--
select path_name, object_type, data_size, object_owner
  from table(qsys2.IFS_OBJECT_STATISTICS( 
                   start_path_name => '/usr',
                   subtree_directories => 'YES'))
   order by 3 desc
   limit 10;


--  category:  IBM i Services
--  description:  IFS -  IFS storage consumed for a specific user
--  minvrm: V7R3M0
--
with ifsobjs (path, type) as (
  select path_name, object_type
    from table(qsys2.object_ownership('SCOTTF')) a
      where path_name is not null
)
select i.*, data_size, z.*
  from ifsobjs i, lateral (
    select * from 
      table(qsys2.ifs_object_statistics(
              start_path_name => path, 
              subtree_directories => 'NO'))) z
order by data_size desc;


--  category:  IBM i Services
--  description:  IFS -  Non-QSYS, IFS directory data size probe
--  minvrm: V7R3M0
--

-- Note... if not already enrolled, add this...
cl:ADDDIRE USRID(<user-profile> RST) USRD('Your name') USER(<user-profile>);
 
stop;
select path_name, object_type, data_size, object_owner, create_timestamp, access_timestamp,
       data_change_timestamp, object_change_timestamp
  from table (
      qsys2.ifs_object_statistics(
        start_path_name => '/', 
        subtree_directories => 'YES', 
        object_type_list => '*ALLDIR *NOQSYS'))
   where  data_size is not null and object_owner not in ('QSYS')                    
   order by 3 desc
   limit 10;


--  category:  IBM i Services
--  description:  IFS -  What IFS files are in use by a specific job?
--  minvrm: V7R3M0
--
select j.*
  from table (
      qsys2.ifs_job_info(
        '432732/SCOTTF/QPADEV000F')
    ) j;


--  category:  IBM i Services
--  description:  IFS -  Which jobs hold a lock on a specific IFS stream file?
--  minvrm: V7R3M0
--
-- 
select i.*
  from table (
      qsys2.ifs_object_lock_info(
        path_name => '/usr/local/guardium/guard_tap.ini')
    ) i;
    


--  category:  IBM i Services
--  description:  IFS - How *PUBLIC is configured for IFS objects I own
--  minvrm: V7R3M0
--
with ifsobjs (path) as (
    select path_name
      from table (
          qsys2.object_ownership(session_user)
        )
      where path_name is not null
  )
  select z.*
    from ifsobjs i, lateral (
           select *
             from table (
                 qsys2.ifs_object_privileges(path_name => path)
               )
         ) z
    where authorization_name = '*PUBLIC'
    order by data_authority;


--  category:  IBM i Services
--  description:  IFS - Reading a stream file
--  minvrm: V7R3M0

-- Read an IFS stream using character data 
--
select line_number, line
  from table (
      qsys2.ifs_read(
        path_name => '/usr/local/install.log', 
        end_of_line => 'ANY',
        maximum_line_length => default, 
        ignore_errors => 'NO')
    );  


--  category:  IBM i Services
--  description:  IFS - Server share info
--  minvrm: V7R3M0

--
-- IBM® i NetServer shares - IFS stream files being shared
--
select server_share_name, path_name, permissions 
  from qsys2.server_share_info
  where share_type = 'FILE';


--  category:  IBM i Services
--  description:  IFS - Server share info with security details
--  minvrm: V7R3M0

--
-- IBM® i NetServer shares - IFS stream files security
--
with shares (name, pn, perm) as (
    select server_share_name, path_name, permissions
      from qsys2.server_share_info
      where share_type = 'FILE'
  )
  select name, pn, perm, authorization_name as username,
         data_authority as actual_data_authority
    from shares, lateral (
           select *
             from table (
                 qsys2.ifs_object_privileges(path_name => pn)
               )
         );


--  category:  IBM i Services
--  description:  IFS - Summarize the current usage for an IFS stream file
--  minvrm: V7R3M0
--
-- 
select r.*
  from table (
      qsys2.ifs_object_references_info(
        path_name => '/usr/local/guardium/guard_tap.ini')
    ) r;
    


--  category:  IBM i Services
--  description:  IFS - Writing to a stream file
--  minvrm: V7R3M0

-- 
-- Find all the library names and write them to an IFS file
--
begin
  -- Make sure output file is empty to start
  call qsys2.ifs_write(
    path_name => '/tmp/library_names',
    line => '',
    overwrite => 'REPLACE',
    end_of_line => 'NONE'
  );
  -- Add lines to the output file
  for select objname as libname
    from table (
        qsys2.object_statistics('*ALLSIMPLE', 'LIB')
      )
    do
      call qsys2.ifs_write(
        path_name => '/tmp/library_names',
        line => libname
      );
  end for;
end;

select *
  from table (
      qsys2.ifs_read('/tmp/library_names')
    );
stop;



--  category:  IBM i Services
--  description:  Java - Find instances of old Java versions being used

select * from qsys2.jvm_info
 where JAVA_HOME not like '%/jdk7%' and 
       JAVA_HOME not like '%/jdk8%';
       


--  category:  IBM i Services
--  description:  Java - JVM Health

--
-- Find the top 10 JVM jobs by amount of time spent in Garbage Collection
--
SELECT TOTAL_GC_TIME, GC_CYCLE_NUMBER,JAVA_THREAD_COUNT, A.* FROM QSYS2.JVM_INFO A
 ORDER BY TOTAL_GC_TIME DESC
 FETCH FIRST 10 ROWS ONLY;

--
-- Change a specific web admin JVM to provide verbose garbage collection details:
--
CALL QSYS2.SET_JVM('121376/QWEBADMIN/ADMIN4','GC_ENABLE_VERBOSE') ;


--  category:  IBM i Services
--  description:  Journal - Journal Info
--  minvrm: V7R3M0

--
-- description: Which journal receivers are detached?
-- (replace SHOESTORE with your library name and QSQJRN with your journal name)
--
with attached(jl, jn, jrcv) as (
select attached_journal_receiver_library, 'QSQJRN', attached_journal_receiver_name
  from qsys2.journal_info
  where journal_library = 'SHOESTORE' and journal_name = 'QSQJRN'
)
select objname as detached_jrnrcv, a.*
  from attached, table (
      qsys2.object_statistics(jl, '*JRNRCV')
    ) as a
    where 
    a.journal_library = jl and a.journal_name = jn and
    objname not in (select jrcv from attached);


--  category:  IBM i Services
--  description:  Journal - Journaled Objects
--  minvrm: V7R3M0

--
-- Which objects are journaled to this journal?
--
select *
  from qsys2.journaled_objects
  where journal_library = 'TOYSTORE' and
        journal_name = 'QSQJRN';
        


--  category:  IBM i Services
--  description:  Journal - Systools Audit Journal AF
--  minvrm: V7R3M0

--
-- Is this IBM i configured to generated AF entries?
-- Note: auditing_control         == QAUDCTL 
--       auditing_level           == QAUDLVL and
--       auditing_level_extension == QAUDLVL2
--
select count(*) as "AF_enabled?"
  from qsys2.security_info
  where (auditing_control like '%*AUDLVL%') and
        ((auditing_level like '%*AUTFAIL%') or
         (auditing_level like '%*AUDLVL2%' and
          auditing_level_extension like '%*AUTFAIL%'));

--
-- Review the authorization violations, which occurred in the last 24 hours
-- 
select ENTRY_TIMESTAMP, VIOLATION_TYPE_DETAIL, USER_NAME, coalesce(
         path_name, object_library concat '/' concat object_name concat ' ' concat object_type) as object
  from table (
      SYSTOOLS.AUDIT_JOURNAL_AF(STARTING_TIMESTAMP => current timestamp - 24 hours)
    );

--
-- Review the authorization violations, which occurred in the last 24 hours (include all columns)
-- 
select ENTRY_TIMESTAMP, VIOLATION_TYPE_DETAIL, USER_NAME, coalesce(
         path_name, object_library concat '/' concat object_name concat ' ' concat object_type) as object, af.*
  from table (
      SYSTOOLS.AUDIT_JOURNAL_AF(STARTING_TIMESTAMP => current timestamp - 24 hours)
    ) af;
 


--  category:  IBM i Services
--  description:  Journal - Systools Audit Journal CA
--  minvrm: V7R3M0

--
-- Is this IBM i configured to generated CA entries?
-- Note: auditing_control         == QAUDCTL
--       auditing_level           == QAUDLVL and
--       auditing_level_extension == QAUDLVL2
--
select count(*) as "CA_enabled?"
  from qsys2.security_info
  where (auditing_control like '%*AUDLVL%') and
        ((auditing_level like '%*SECURITY%') or (auditing_level like '%*SECRUN%') or
         (auditing_level like '%*AUDLVL2%' and
           (auditing_level_extension like '%*SECURITY%') or (auditing_level_extension like '%*SECRUN%')));

--
-- Review the authorization changes, which occurred in the last 24 hours (include all columns)
-- 
select ENTRY_TIMESTAMP, USER_NAME, COMMAND_TYPE, USER_PROFILE_NAME,
coalesce(
         path_name, object_library concat '/' concat object_name concat ' ' concat object_type) as object, ca.*
  from table (
      SYSTOOLS.AUDIT_JOURNAL_CA(STARTING_TIMESTAMP => current timestamp - 24 hours)
    ) ca
    order by entry_timestamp desc;



--  category:  IBM i Services
--  description:  Journal - Systools Audit Journal OW
--  minvrm: V7R3M0

--
-- Is this IBM i configured to generated OW entries?
-- Note: auditing_control         == QAUDCTL 
--       auditing_level           == QAUDLVL and
--       auditing_level_extension == QAUDLVL2
--
select count(*) as "OW_enabled?"
  from qsys2.security_info
  where (auditing_control like '%*AUDLVL%') and
        ((auditing_level like '%*SECURITY%') or (auditing_level like '%*SECRUN%') or
         (auditing_level like '%*AUDLVL2%' and
           (auditing_level_extension like '%*SECURITY%') or (auditing_level_extension like '%*SECRUN%')));

--
-- Review the ownership changes, which occurred in the last 24 hours (include all columns)
-- 
select ENTRY_TIMESTAMP, USER_NAME, PREVIOUS_OWNER, NEW_OWNER,  
coalesce(
         path_name, object_library concat '/' concat object_name concat ' ' concat object_type) as object, ow.*
  from table (
      SYSTOOLS.AUDIT_JOURNAL_OW(STARTING_TIMESTAMP => current timestamp - 24 hours)
    ) ow
    order by entry_timestamp desc;


--  category:  IBM i Services
--  description:  Journal - Systools Audit Journal PW
--  minvrm: V7R3M0

--
-- Is this IBM i configured to generated PW entries?
-- Note: auditing_control         == QAUDCTL 
--       auditing_level           == QAUDLVL and
--       auditing_level_extension == QAUDLVL2
--
select count(*) as "PW_enabled?"
  from qsys2.security_info
  where (auditing_control like '%*AUDLVL%') and
        ((auditing_level like '%*AUTFAIL%') or
         (auditing_level like '%*AUDLVL2%' and
          auditing_level_extension like '%*AUTFAIL%'));

--
-- Review the password failures, which occurred in the last 24 hours (include all columns)
-- 
select ENTRY_TIMESTAMP, VIOLATION_TYPE_DETAIL, AUDIT_USER_NAME, DEVICE_NAME, pw.*
  from table (
      SYSTOOLS.AUDIT_JOURNAL_PW(STARTING_TIMESTAMP => current timestamp - 24 hours)
    ) pw
    order by entry_timestamp desc;


--  category:  IBM i Services
--  description:  Journal - Systools change user profile (CHGUSRPRF)
--  minvrm: V7R3M0

--
-- Find user profiles using a default password, generate the commands needed to disable them
--
select AUTHORIZATION_NAME, TEXT_DESCRIPTION, CHGUSRPRF_COMMAND
  from QSYS2.USER_INFO,
       table (
         SYSTOOLS.CHANGE_USER_PROFILE(
           P_USER_NAME => AUTHORIZATION_NAME, P_STATUS => '*DISABLED', PREVIEW => 'YES'
         ))
  where STATUS = '*ENABLED' and
        user_creator <> '*IBM' and
        USER_DEFAULT_PASSWORD = 'YES';
stop;
--
-- Take the action!
--
select cp.* from QSYS2.USER_INFO,
       table (
         SYSTOOLS.CHANGE_USER_PROFILE(
           P_USER_NAME => AUTHORIZATION_NAME, P_STATUS => '*DISABLED', PREVIEW => 'NO'
         )
       ) cp
  where STATUS = '*ENABLED' and
        user_creator <> '*IBM' and
        USER_DEFAULT_PASSWORD = 'YES';
stop;


--  category:  IBM i Services
--  description:  Librarian -  Library Info 
--  minvrm: V7R3M0
--

create or replace variable coolstuff.library_report_stmt varchar(10000) for sbcs data default
'create or replace table coolstuff.library_sizes
      (library_name, schema_name, 
      
       -- qsys2.library_info() columns
       library_size, library_size_formatted, 
       object_count, library_size_complete, library_type, text_description,
       iasp_name, iasp_number, create_authority, object_audit_create, journaled,
       journal_library, journal_name, inherit_journaling, journal_start_timestamp,
       apply_starting_receiver_library, apply_starting_receiver,
       apply_starting_receiver_asp,
       
       -- qsys2.object_statistics() columns
       objowner, objdefiner, objcreated, objsize, objtext, objlongname,
       change_timestamp, last_used_timestamp, last_used_object, days_used_count, last_reset_timestamp,
       save_timestamp, restore_timestamp, save_while_active_timestamp, 
       user_changed, source_file, source_library, source_member,
       source_timestamp, created_system, created_system_version, licensed_program,
       licensed_program_version, compiler, compiler_version, object_control_level,
       ptf_number, apar_id, user_defined_attribute, allow_change_by_program,
       changed_by_program, compressed, primary_group, storage_freed,
       associated_space_size, optimum_space_alignment, overflow_storage, object_domain,
       object_audit, object_signed, system_trusted_source, multiple_signatures,
       save_command, save_device, save_file_name, save_file_library, save_volume, save_label,
       save_sequence_number, last_save_size, journal_images, omit_journal_entry, remote_journal_filter, 
       authority_collection_value
       )
  as
      (select objname as lib, objlongname as schema, library_size,
              varchar_format(library_size, ''999G999G999G999G999G999G999G999G999G999'')
                as formatted_size, object_count, library_size_complete, library_type, text_description,
       b.iasp_name, b.iasp_number, create_authority, object_audit_create, a.journaled,
       b.journal_library, b.journal_name, inherit_journaling, b.journal_start_timestamp,
       b.apply_starting_receiver_library, b.apply_starting_receiver,
       b.apply_starting_receiver_asp,
              objowner, objdefiner, objcreated, objsize, objtext, objlongname,
       change_timestamp, last_used_timestamp, last_used_object, days_used_count, last_reset_timestamp,
       save_timestamp, restore_timestamp, save_while_active_timestamp, 
       user_changed, source_file, source_library, source_member,
       source_timestamp, created_system, created_system_version, licensed_program,
       licensed_program_version, compiler, compiler_version, object_control_level,
       ptf_number, apar_id, user_defined_attribute, allow_change_by_program,
       changed_by_program, compressed, primary_group, storage_freed,
       associated_space_size, optimum_space_alignment, overflow_storage, object_domain,
       object_audit, object_signed, system_trusted_source, multiple_signatures,
       save_command, save_device, save_file_name, save_file_library, save_volume, save_label,
       save_sequence_number, last_save_size, journal_images, omit_journal_entry, remote_journal_filter, 
       authority_collection_value
          from table (
                 qsys2.object_statistics(''*ALLUSR'', ''*LIB'')
               ) as a, lateral (
                 select *
                   from table (
                       qsys2.library_info(library_name => a.objname,
                                          ignore_errors => ''YES'',
                                          detailed_info => ''LIBRARY_SIZE'')
                     )
               ) b)
      with data   on replace delete rows';
stop;
  
cl:SBMJOB CMD(RUNSQL SQL('begin execute immediate coolstuff.library_report_stmt; end') commit(*NONE)) JOB(LIBSIZES);
stop;

--
-- jobs submitted from this job
--
select *
  from table (
      qsys2.job_info(job_submitter_filter => '*JOB', job_user_filter => '*ALL')
    );

-- once the job ends, it won't be returned by job_info... then you can query the results
select * from coolstuff.library_sizes ls order by library_size desc;
 


--  category:  IBM i Services
--  description:  Librarian -  Which IBM commands have had their command parameter defaults changed using CHGCMDDFT
--  minvrm: V7R3M0
--
select * from table(qsys2.object_statistics('QSYS', '*CMD'))
  where APAR_ID = 'CHGDFT';


--  category:  IBM i Services
--  description:  Librarian - Examine least and most popular routines

--
-- Note: Replace library-name with the target library name
-- Find unused procedures and functions
--
select OBJNAME,OBJTEXT,OBJCREATED,DAYS_USED_COUNT, x.* from table(qsys2.object_statistics('library-name', 'PGM SRVPGM')) x
WHERE SQL_OBJECT_TYPE IN ('PROCEDURE','FUNCTION')
AND LAST_USED_TIMESTAMP IS NULL OR DAYS_USED_COUNT = 0
ORDER BY OBJLONGNAME ASC;

-- Find the most frequently used procedures and functions
--
select LAST_USED_TIMESTAMP, DAYS_USED_COUNT, LAST_RESET_TIMESTAMP, x.* from table(qsys2.object_statistics('library-name', 'PGM SRVPGM')) x
WHERE SQL_OBJECT_TYPE IN ('PROCEDURE','FUNCTION')
AND LAST_USED_TIMESTAMP IS NOT NULL
ORDER BY DAYS_USED_COUNT DESC;


--  category:  IBM i Services
--  description:  Librarian - Find objects

--
-- Find user libraries that are available, return full details about the libraries
--
SELECT * FROM TABLE (QSYS2.OBJECT_STATISTICS('*ALLUSRAVL ', '*LIB') ) as a;

--
-- Super Fast retrieval of library and schema name
--
SELECT OBJNAME AS LIBRARY_NAME, OBJLONGNAME AS SCHEMA_NAME
   FROM TABLE(QSYS2.OBJECT_STATISTICS('*ALLSIMPLE', 'LIB')) Z
     ORDER BY 1 ASC;

--
-- Super Fast retrieval names of an object type within a library
--
SELECT objname
   FROM TABLE(qsys2.object_statistics('TOYSTORE', '*FILE', '*ALLSIMPLE')) AS x;

--
-- Find Program and Service programs within a library
-- Note: Replace library-name with the target library name
--
SELECT * FROM TABLE (QSYS2.OBJECT_STATISTICS('library-name', '*PGM *SRVPGM') ) as a;



--  category:  IBM i Services
--  description:  Librarian - Journal Inherit Rules
--  minvrm: V7R3M0

--
-- Review library specific journal inheritance rules
--
select library_name, 
       ordinal_position,  
       object_type, 
       operation, 
       rule_action,  
       name_filter, 
       journal_images,  
       omit_journal_entry, 
       remote_journal_filter 
  from qsys2.journal_inherit_rules
  where journaled = 'YES'
  order by library_name, ordinal_position;


--  category:  IBM i Services
--  description:  Librarian - Library list

--
-- Description: Ensure that the TOYSTORE library is the first library 
--              in the user portion of the library list 
 BEGIN 
 DECLARE V_ROW_NUM INTEGER; 
 WITH CTE1(SCHEMA_NAME, ROW_NUM) AS ( 
   SELECT SCHEMA_NAME, ROW_NUMBER() OVER (ORDER BY ORDINAL_POSITION) AS ROW_NUM 
     FROM QSYS2.LIBRARY_LIST_INFO WHERE TYPE = 'USER' 
 ) SELECT ROW_NUM INTO V_ROW_NUM FROM CTE1 WHERE SCHEMA_NAME = 'TOYSTORE'; 
 IF (V_ROW_NUM IS NULL) THEN 
   CALL QSYS2.QCMDEXC('ADDLIBLE TOYSTORE'); 
 ELSEIF (V_ROW_NUM > 1) THEN 
   BEGIN 
     CALL QSYS2.QCMDEXC('RMVLIBLE TOYSTORE'); 
     CALL QSYS2.QCMDEXC('ADDLIBLE TOYSTORE'); 
   END; 
 END IF; 
 END;


--  category:  IBM i Services
--  description:  License Management - Expiration processing
--  minvrm:  v7r2m0

--
-- Detect if any license is expired or will expire soon (within the next 45 days)
--         
CALL systools.license_expiration_check(45);         

--
-- Review messages sent to the system operator message queue with license expiration details
--
SELECT MESSAGE_TEXT, m.*
   FROM qsys2.message_queue_info m
   WHERE message_queue_name = 'QSYSOPR' AND
         MESSAGE_TEXT LIKE '%EXPIRE%';

--
-- Review license usage violations
--
SELECT a.*
   FROM qsys2.license_info a
   WHERE log_violation = 'YES'
   ORDER BY peak_usage DESC;


--  category:  IBM i Services
--  description:  Message Handling  - Query a message file

SELECT
  MESSAGE_FILE_LIBRARY,               -- MSGF_LIB    VARCHAR(10)       
  MESSAGE_FILE,                       -- MSGF        VARCHAR(10)       
  MESSAGE_ID,                         -- MSGID       CHARACTER(7)      
  MESSAGE_TEXT,                       -- MSG_TEXT    VARGRAPHIC(132)   
  MESSAGE_SECOND_LEVEL_TEXT,          -- SECLVL      VARGRAPHIC(3000)  
  SEVERITY,                           -- SEVERITY    INTEGER           
  MESSAGE_DATA_COUNT,                 -- MSGDATACNT  INTEGER           
  MESSAGE_DATA,                       -- MSGDATA     VARCHAR(2078)     
  LOG_PROBLEM,                        -- LOGPRB      VARCHAR(4)        
  CREATION_DATE,                      -- CRT_DATE    DATE              
  CREATION_LEVEL,                     -- CRT_LEVEL   INTEGER           
  MODIFICATION_DATE,                  -- MOD_DATE    DATE              
  MODIFICATION_LEVEL,                 -- MOD_LEVEL   INTEGER           
  CCSID,                              -- CCSID       INTEGER           
  DEFAULT_PROGRAM_LIBRARY,            -- DFT_PGMLIB  VARCHAR(10)       
  DEFAULT_PROGRAM,                    -- DFT_PGM     VARCHAR(10)       
  REPLY_TYPE,                         -- REPLY_TYPE  VARCHAR(6)        
  REPLY_LENGTH,                       -- REPLY_LEN   INTEGER           
  REPLY_DECIMAL_POSITIONS,            -- REPLY_DEC   INTEGER           
  DEFAULT_REPLY,                      -- DFT_REPLY   VARCHAR(132)      
  VALID_REPLY_VALUES_COUNT,           -- REPLY_CNT   INTEGER           
  VALID_REPLY_VALUES,                 -- REPLY_VALS  VARCHAR(659)      
  VALID_REPLY_LOWER_LIMIT,            -- LOWERLIMIT  VARCHAR(32)       
  VALID_REPLY_UPPER_LIMIT,            -- UPPERLIMIT  VARCHAR(32)       
  VALID_REPLY_RELATIONSHIP_OPERATOR,  -- REL_OP      CHARACTER(3)      
  VALID_REPLY_RELATIONSHIP_VALUE,     -- REL_VALUE   VARCHAR(32)       
  SPECIAL_REPLY_VALUES_COUNT,         -- SPECIALCNT  INTEGER           
  SPECIAL_REPLY_VALUES,               -- SPECIALVAL  VARCHAR(1319)     
  DUMP_LIST_COUNT,                    -- DUMP_COUNT  INTEGER           
  DUMP_LIST,                          -- DUMP_LIST   VARCHAR(815)      
  ALERT_OPTION,                       -- ALERTOPT    VARCHAR(9)        
  ALERT_INDEX                         -- ALERTINDEX  INTEGER           
FROM QSYS2.MESSAGE_FILE_DATA 
where MESSAGE_FILE_LIBRARY = 'QSYS' and MESSAGE_FILE = 'QSQLMSG';



--  category:  IBM i Services
--  description:  Message Handling - Abnormal IPL Predictor 
--  minvrm:  v7r2m0

--
-- Examine history log messages since the previous IPL and
-- determine whether the next IPL will be abnormal or normal
--
WITH last_ipl(ipl_time)
   AS (SELECT job_entered_system_time
          FROM TABLE(qsys2.job_info(job_status_filter => '*ACTIVE',
             job_user_filter => 'QSYS')) x
          WHERE job_name = '000000/QSYS/SCPF'), 
   abnormal(abnormal_count) 
   AS (SELECT COUNT(*)
          FROM last_ipl, 
          TABLE(qsys2.history_log_info(ipl_time, CURRENT TIMESTAMP)) x
          WHERE message_id IN ('CPC1225'))
   SELECT
      CASE
         WHEN abnormal_count = 0
            THEN 'NEXT IPL WILL BE NORMAL'
            ELSE 'NEXT IPL WILL BE ABNORMAL - ABNORMAL END COUNT: ' 
               concat abnormal_count
      END AS next_ipl_indicator FROM abnormal ; 


--  category:  IBM i Services
--  description:  Message Handling - Reply List

-- Review reply list detail for all messages which begin with CPA 
SELECT * FROM QSYS2.REPLY_LIST_INFO WHERE message_ID LIKE 'CPA%';


--  category:  IBM i Services
--  description:  Message Handling - Review system operator inquiry messages

--
-- Examine all system operator inquiry messages that have a reply
--
SELECT a.message_text AS "INQUIRY", b.message_text AS "REPLY", B.FROM_USER, B.*, A.*
 FROM qsys2.message_queue_info a INNER JOIN   
      qsys2.message_queue_info b
ON a.message_key = b.associated_message_key
WHERE A.MESSAGE_QUEUE_NAME = 'QSYSOPR' AND
      A.MESSAGE_QUEUE_LIBRARY = 'QSYS' AND
      B.MESSAGE_QUEUE_NAME = 'QSYSOPR' AND
      B.MESSAGE_QUEUE_LIBRARY = 'QSYS'
ORDER BY b.message_timestamp DESC; 


--  category:  IBM i Services
--  description:  Message Handling - Review system operator unanswered inquiry messages

--
-- Examine all system operator inquiry messages that have no reply
--
WITH REPLIED_MSGS(KEY) AS (
SELECT a.message_key
 FROM qsys2.message_queue_info a INNER JOIN   
      qsys2.message_queue_info b
ON a.message_key = b.associated_message_key
WHERE A.MESSAGE_QUEUE_NAME = 'QSYSOPR' AND
      A.MESSAGE_QUEUE_LIBRARY = 'QSYS' AND
      B.MESSAGE_QUEUE_NAME = 'QSYSOPR' AND
      B.MESSAGE_QUEUE_LIBRARY = 'QSYS'
ORDER BY b.message_timestamp DESC
)
SELECT a.message_text AS "INQUIRY", A.*
 FROM qsys2.message_queue_info a 
      LEFT EXCEPTION JOIN REPLIED_MSGS b
ON a.message_key = b.key
WHERE MESSAGE_QUEUE_NAME = 'QSYSOPR' AND
      MESSAGE_QUEUE_LIBRARY = 'QSYS' AND
      message_type = 'INQUIRY'  
ORDER BY message_timestamp DESC; 



--  category:  IBM i Services
--  description:  Message Handling - Send Alert messages to QSYSOPR
--  minvrm:  v7r3m0

--
-- Send the SQL7064 message to the QSYSOPR message queue
--
values length('Query Supervisor - terminated a query for ' concat qsys2.job_name);

call QSYS2.SEND_MESSAGE('SQL7064', 65, 'Query Supervisor - terminated a query for ' concat
      qsys2.job_name);

--
-- Review the most recent messages on the QSYSOPR message queue
--
select *
  from table (
      QSYS2.MESSAGE_QUEUE_INFO(MESSAGE_FILTER => 'ALL')
    )
  order by MESSAGE_TIMESTAMP desc; 


--  category:  IBM i Services
--  description:  PTF - Firmware Currency 

--
-- Compare the current Firmware against IBM's 
-- Fix Level Request Tool (FLRT) to determine if the 
-- firmware level is current or upgrades are available
--   
SELECT * 
  FROM SYSTOOLS.FIRMWARE_CURRENCY;


--  category:  IBM i Services
--  description:  PTF - Group PTF Currency 

--
-- Derive the IBM i operating system level and then 
-- determine the level of currency of PTF Groups
--   
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
  SELECT P.*
     FROM iLevel, systools.group_ptf_currency P
     WHERE ptf_group_release = 
           'R' CONCAT iVersion CONCAT iRelease concat '0'
     ORDER BY ptf_group_level_available -
        ptf_group_level_installed DESC;
        
--
-- For those that need to use STRSQL ;-(
-- 
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
SELECT VARCHAR(GRP_CRNCY,26) AS "GRPCUR",
       GRP_ID,  VARCHAR(GRP_TITLE, 20) AS "NAME",
       GRP_LVL, GRP_IBMLVL, GRP_LSTUPD,
       GRP_RLS, GRP_SYSSTS
FROM iLevel, systools.group_ptf_currency P
WHERE ptf_group_release =
'R' CONCAT iVersion CONCAT iRelease concat '0'
ORDER BY ptf_group_level_available -
ptf_group_level_installed DESC;


--  category:  IBM i Services
--  description:  PTF - Group PTF Currency 

--
-- Derive the IBM i operating system level and then 
-- determine the level of currency of PTF Groups
--   
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
  SELECT P.*
     FROM iLevel, systools.group_ptf_currency P
     WHERE ptf_group_release = 
           'R' CONCAT iVersion CONCAT iRelease concat '0'
     ORDER BY ptf_group_level_available -
        ptf_group_level_installed DESC;
        

-- 
-- For those that like STRSQL ;-(
--
With iLevel(iVersion, iRelease) AS
(
select OS_VERSION, OS_RELEASE from sysibmadm.env_sys_info
)
SELECT VARCHAR(GRP_CRNCY,26) AS "GRPCUR",
       GRP_ID,  VARCHAR(GRP_TITLE, 20) AS "NAME",
       GRP_LVL, GRP_IBMLVL, GRP_LSTUPD,
       GRP_RLS, GRP_SYSSTS
FROM iLevel, systools.group_ptf_currency P
WHERE ptf_group_release =
'R' CONCAT iVersion CONCAT iRelease concat '0'
ORDER BY ptf_group_level_available -
ptf_group_level_installed DESC;


--  category:  IBM i Services
--  description:  PTF - Group PTF Details 

--
-- Review all unapplied PTFs contained within PTF Groups installed on the partition 
-- against the live PTF detail available from IBM
--
SELECT * FROM SYSTOOLS.GROUP_PTF_DETAILS
  WHERE PTF_STATUS <> 'PTF APPLIED'
  ORDER BY PTF_GROUP_NAME;


--  category:  IBM i Services
--  description:  PTF - Group PTF Details 

--
-- Determine if this IBM i is missing any IBM i Open Source PTFs
-- 
SELECT *
   FROM TABLE(systools.group_ptf_details('SF99225')) a
     WHERE PTF_STATUS = 'PTF MISSING'; /* SF99225 == 5733OPS */
;

--  category:  IBM i Services
--  description:  PTF - PTF information 

--
-- Find which PTFs will be impacted by the next IPL.
--
SELECT PTF_IDENTIFIER, PTF_IPL_ACTION, A.*
  FROM QSYS2.PTF_INFO A
  WHERE PTF_IPL_ACTION <> 'NONE';

--
-- Find which PTFs are loaded but not applied
--
SELECT PTF_IDENTIFIER, PTF_IPL_REQUIRED, A.*
  FROM QSYS2.PTF_INFO A
  WHERE PTF_LOADED_STATUS = 'LOADED'
  ORDER BY PTF_PRODUCT_ID;


--  category:  IBM i Services
--  description:  Password failures over the last 24 hours

CREATE OR REPLACE VIEW coolstuff.Password_Failures_24hrs  FOR SYSTEM NAME PW_LAST24
  (TIME, JOBNAME, USERNAME, IPADDR)
   AS
SELECT ENTRY_TIMESTAMP, 
       JOB_NUMBER CONCAT '/' CONCAT RTRIM(JOB_USER) CONCAT '/' CONCAT RTRIM(JOB_NAME) AS JOB_NAME, 
       RTRIM(CAST(SUBSTR(entry_data, 2, 10) AS VARCHAR(10))), REMOTE_ADDRESS
  FROM TABLE(qsys2.display_journal(
            'QSYS', 'QAUDJRN',              -- Journal library and name
            STARTING_RECEIVER_NAME => '*CURAVLCHN',
            journal_entry_types => 'PW',    -- Journal entry types
            starting_timestamp => CURRENT TIMESTAMP - 24 HOURS -- Time period
)) X;

--
-- description: Review the password failure detail
--
SELECT * FROM coolstuff.PW_LAST24
  order by TIME asc;        


--  category:  IBM i Services
--  description:  Performance - Collection Services 
--  minvrm: V7R3M0
--

  
--
-- Review the Collection Services (CS) configuration
--
select *
  from QSYS2.COLLECTION_SERVICES_INFO;

--
-- Shred the CS categories and interval settings
--
select a.*
  from QSYS2.COLLECTION_SERVICES_INFO, lateral (select * from JSON_TABLE(CATEGORY_LIST, 'lax $.category_list[*]' 
  columns(cs_category clob(1k) ccsid 1208 path 'lax $."category"', 
          cs_interval clob(1k) ccsid 1208 path 'lax $."interval"'))) a;
  
  


--  category:  IBM i Services
--  description:  Product - Expiring license info

--
-- Return information about all licensed products and features 
-- that will expire within the next 2 weeks.
--
SELECT * FROM QSYS2.LICENSE_INFO
WHERE LICENSE_EXPIRATION <= CURRENT DATE + 50 DAYS;

-- Return information about all licensed products and features 
-- that will expire within the next 2 weeks, for installed products only
--
SELECT * FROM QSYS2.LICENSE_INFO
WHERE INSTALLED = 'YES' AND
LICENSE_EXPIRATION <= CURRENT DATE + 50 DAYS;


--  category:  IBM i Services
--  description:  Product - Software Product Info 
--  minvrm:  v7r3m0

-- Is QSYSINC installed? (DSPSFWRSC alternative)
--
select count(*) as gtg_count
  from qsys2.software_product_info
  where upper(text_description) like '%SYSTEM OPENNESS%'
        and load_error = 'NO'
        and load_state = 90
        and symbolic_load_state = 'INSTALLED';


--  category:  IBM i Services
--  description:  Review public authority to files in library TOYSTORE

SELECT OBJECT_AUTHORITY AS PUBLIC_AUTHORITY,  
       COUNT(*) AS COUNT FROM TABLE(QSYS2.OBJECT_STATISTICS('TOYSTORE', 'FILE')) F, 
LATERAL 
(SELECT OBJECT_AUTHORITY FROM QSYS2.OBJECT_PRIVILEGES 
    WHERE SYSTEM_OBJECT_NAME   = F.OBJNAME 
      AND USER_NAME            = '*PUBLIC'
      AND SYSTEM_OBJECT_SCHEMA = 'TOYSTORE'
      AND OBJECT_TYPE          = '*FILE') P 
GROUP BY OBJECT_AUTHORITY ORDER BY 2 DESC;


--  category:  IBM i Services
--  description:  Review the object ownership summary for objects in a library

SELECT OBJOWNER, COUNT(*) AS OWN_COUNT
  FROM TABLE(QSYS2.OBJECT_STATISTICS('TOYSTORE', 'ALL')) X
  GROUP BY OBJOWNER
  ORDER BY 2 DESC;


--  category:  IBM i Services
--  description:  Security - Authority Collection
--  minvrm:  v7r3m0

--
-- Use authority collection to capture and study the enforcement of security.
-- In this example, JOEUSER needs to be given read data privileges to 
-- the TOYSTORE/SALES file. Authority collection can be used to iterate through
-- the process of identifying and granting granular authorities.
--
CL: STRAUTCOL USRPRF(JOEUSER) LIBINF((TOYSTORE));
stop; -- Ask JOEUSER to attempt the data access on the TOYSTORE/SALES table
CL: ENDAUTCOL USRPRF(JOEUSER);

-- Review the authorization failures
SELECT SYSTEM_OBJECT_NAME, DETAILED_REQUIRED_AUTHORITY FROM QSYS2.AUTHORITY_COLLECTION
 WHERE AUTHORIZATION_NAME = 'JOEUSER'
  AND  AUTHORITY_CHECK_SUCCESSFUL = '0';

CL: DLTAUTCOL USRPRF(JOEUSER);

CL: GRTOBJAUT OBJ(TOYSTORE) OBJTYPE(*LIB) USER(JOEUSER) AUT(*EXECUTE);
CL: GRTOBJAUT OBJ(TOYSTORE/SALES) OBJTYPE(*FILE) USER(JOEUSER) AUT(*OBJOPR);
CL: GRTOBJAUT OBJ(TOYSTORE/SALES) OBJTYPE(*FILE) USER(JOEUSER) AUT(*READ);


--  category:  IBM i Services
--  description:  Security - Authority Collection (analyze)

-- Review the authorization failures
SELECT system_object_schema concat '/' concat system_object_name as Object, 
       system_object_type, authority_source, 
       detailed_current_authority,
       detailed_required_authority, ac.*
     FROM qsys2.authority_collection ac
     WHERE authorization_name = 'JOEUSER' and authority_check_successful = '0';
           

-- Review the successes
SELECT system_object_schema concat '/' concat system_object_name as Object, 
       system_object_type, authority_source, 
       detailed_current_authority,
       detailed_required_authority, ac.*
     FROM qsys2.authority_collection ac
     WHERE authorization_name = 'JOEUSER' and
      (system_object_schema concat '/' concat system_object_name like '%SQL123%' or system_object_schema concat '/' concat system_object_name like '%TOYSTORE%') and
           authority_check_successful = '1';

-- Review use of adopted authority 
SELECT adopting_program_schema concat '/' concat adopting_program_name as Object, 
       adopting_program_type,    current_adopted_authority, 
       adopted_authority_source, detailed_required_authority, 
       multiple_adopting_programs_used, ac.*
     FROM qsys2.authority_collection ac
     WHERE authorization_name = 'JOEUSER' and
           adopt_authority_used = '1';
           
-- Which commands and programs are being used?           
SELECT SYSTEM_OBJECT_SCHEMA concat '/' concat SYSTEM_OBJECT_NAME as Object, COUNT(*) as COUNT
 FROM QSYS2.AUTHORITY_COLLECTION A
 WHERE SYSTEM_OBJECT_TYPE IN ('*PGM', '*CMD') and authorization_name = 'JOEUSER' 
 GROUP BY SYSTEM_OBJECT_SCHEMA concat '/' concat SYSTEM_OBJECT_NAME   
 ORDER BY 2 DESC;


--  category:  IBM i Services
--  description:  Security - Authority Collection (capture)

--
-- Capture and save authority collection detail for JOEUSER
--
CL:STRAUTCOL USRPRF(JOEUSER) LIBINF((TOYSTORE));
stop; -- Ask JOEUSER to attempt the data access on the TOYSTORE/SALES table
CL: ENDAUTCOL USRPRF(JOEUSER);

--
-- Save JOEUSER's authority collection detail
--
CL: CRTLIB AUTCOLDATA;

CREATE TABLE AUTCOLDATA.JOEUSER AS (
  SELECT * FROM qsys2.authority_collection 
    WHERE AUTHORIZATION_NAME = 'JOEUSER'
) WITH DATA;

-- delete the authority collection detail 
CL: DLTAUTCOL USRPRF(JOEUSER);


--  category:  IBM i Services
--  description:  Security - Authority Collection (review)

--
-- Use authority collection to capture and study the enforcement of security.
-- In this example, JOEUSER needs to be given read data privileges to 
-- the TOYSTORE/SALES file. Authority collection can be used to iterate through
-- the process of identifying and granting granular authorities.
--
-- Which users have ACTIVE authority collection on-going?
--                  ======
--
SELECT AUTHORIZATION_NAME, AUTHORITY_COLLECTION_REPOSITORY_EXISTS 
  FROM QSYS2.USER_INFO 
    WHERE AUTHORITY_COLLECTION_ACTIVE = 'YES';

--
-- Which users have authority collection detail?
--
SELECT AUTHORIZATION_NAME, AUTHORITY_COLLECTION_ACTIVE 
  FROM QSYS2.USER_INFO 
    WHERE AUTHORITY_COLLECTION_REPOSITORY_EXISTS = 'YES';

--
-- How much Authority Collection detail was captured?
--
SELECT AUTHORIZATION_NAME, count(*) as AC_COUNT
  FROM qsys2.authority_collection 
  GROUP BY AUTHORIZATION_NAME
  ORDER BY 2 DESC;


--  category:  IBM i Services
--  description:  Security - Authorization List detail

--
-- List the public security settings for all authorization lists.
--
SELECT *
FROM QSYS2.AUTHORIZATION_LIST_USER_INFO
WHERE AUTHORIZATION_NAME = '*PUBLIC';


--  category:  IBM i Services
--  description:  Security - Certificate attribute analysis
--  minvrm:  v7r3m0

-- Use a global variable to avoid having source code include password values
create or replace variable coolstuff.system_cert_pw varchar(30);
set coolstuff.system_cert_pw = 'PWDVALUE1234567';

select *
  from table (
      qsys2.certificate_info(certificate_store_password => coolstuff.system_cert_pw)
    )
  where validity_end < current date + 1 month;


--  category:  IBM i Services
--  description:  Security - Certificate attribute analysis
--  minvrm:  v7r3m0

--
--  Review the certificate store detail using the stashed password file
--  Find the certificates that are no longer valid, or that become invalid within a month
--
select *
  from table (
      qsys2.certificate_info(certificate_store_password => '*NOPWD')
    )
  where validity_end < current date + 1 month
  order by validity_end;


--  category:  IBM i Services
--  description:  Security - Check authority to query

--
-- Description: Does this user have authority to query this file 
--
VALUES ( 
   CASE WHEN QSYS2.SQL_CHECK_AUTHORITY('QSYS2','SYSLIMITS') = 1 
        THEN 'I can query QSYS2/SYSLIMITS' 
        ELSE 'No query access for me' END 
);


--  category:  IBM i Services
--  description:  Security - DISPLAY_JOURNAL() of the audit journal
--  minvrm:  v7r2m0
--  Note: this is available at IBM i 7.2 and higher, because it relies upon UDTF default & named parameter support 

--
--  Use Display_Journal() to examine the Change Profile (CP) entries that have occurred over the last 24 hours.
--
SELECT journal_code, journal_entry_type, object, object_type, X.* 
FROM TABLE (
QSYS2.Display_Journal(
  'QSYS', 'QAUDJRN',                       -- Journal library and name
  JOURNAL_ENTRY_TYPES => 'CP' ,            -- Journal entry types
  STARTING_TIMESTAMP => CURRENT TIMESTAMP - 24 HOURS  -- Time period
) ) AS x
;

--  category:  IBM i Services
--  description:  Security - DRDA Authentication Entry info

--
-- Review the DRDA & DDM Server authentication entry configuration
--
SELECT * FROM QSYS2.DRDA_AUTHENTICATION_ENTRY_INFO
  ORDER BY AUTHORIZATION_NAME, SERVER_NAME;


--  category:  IBM i Services
--  description:  Security - Dashboard 
--  minvrm:  v7r3m0

--
-- How is my IBM i Security configured?
--
select *
  from qsys2.security_info;


--  category:  IBM i Services
--  description:  Security - Function Usage

--
-- Compare Security Function Usage details between production and backup 
--

DECLARE GLOBAL TEMPORARY TABLE SESSION . Remote_function_usage 
( function_id, user_name, usage, user_type )
AS (SELECT * FROM gt73p2.qsys2.function_usage) WITH DATA
WITH REPLACE;

SELECT 'GT73P1' AS "Source Partition",
   a.function_id, a.user_name, a.usage, a.user_type
   FROM qsys2.function_usage a LEFT EXCEPTION JOIN 
        session.remote_function_usage b ON 
   a.function_id = b.function_id AND a.user_name   = b.user_name AND
   a.usage   = b.usage           AND a.user_type   = b.user_type
UNION ALL
SELECT 'GT73P2' AS "Target Partition",
   b.function_id, b.user_name, b.usage, b.user_type
   FROM qsys2.function_usage a RIGHT EXCEPTION JOIN 
        session.remote_function_usage b ON 
   a.function_id = b.function_id AND a.user_name   = b.user_name AND
   a.usage   = b.usage           AND a.user_type   = b.user_type
ORDER BY 2, 3;



--  category:  IBM i Services
--  description:  Security - Group profile detail

--
-- Review Group and Supplemental Group settings
--
SELECT group_profile_name,
       supplemental_group_count,
       supplemental_group_list,
       u.*
   FROM qsys2.user_info u
   WHERE supplemental_group_count > 0
   ORDER BY 2 DESC;


--  category:  IBM i Services
--  description:  Security - Object Ownership
--  minvrm:  v7r3m0

with qsysobjs (lib, obj, type) as (
    select object_library, object_name, object_type
      from table (qsys2.object_ownership('SCOTTF'))
      where path_name is null
  )
  select q.*, z.*
    from qsysobjs q, lateral (
           select objcreated, last_used_timestamp, objsize
             from table (qsys2.object_statistics(lib, type, obj))
         ) z
  order by OBJSIZE DESC;


--  category:  IBM i Services
--  description:  Security - QSYS objects owned by the #1 storage consumer
--  minvrm:  v7r3m0

with top_dog (username, storage) as (
       select authorization_name, sum(storage_used)
         from qsys2.user_storage
         where authorization_name not like 'Q%'
         group by authorization_name
         order by 2 desc
         limit 1),
     qsysobjs (lib, obj, type) as (
       select object_library, object_name, object_type
         from top_dog, table (
                qsys2.object_ownership(username)
              )
         where path_name is null
     )
  select username, q.*, z.*
    from top_dog, qsysobjs q, lateral (
           select objcreated, last_used_timestamp, objsize
             from table (
                 qsys2.object_statistics(lib, type, obj)
               )
         ) z
    order by objsize desc;
  


--  category:  IBM i Services
--  description:  Security - Review *ALLOBJ users

--
-- Which users have *ALLOBJ authority either directly
-- or via a Group or Supplemental profile?
--
SELECT AUTHORIZATION_NAME, STATUS, NO_PASSWORD_INDICATOR, PREVIOUS_SIGNON,
TEXT_DESCRIPTION
FROM QSYS2.USER_INFO
WHERE SPECIAL_AUTHORITIES LIKE '%*ALLOBJ%'
OR AUTHORIZATION_NAME IN (
SELECT USER_PROFILE_NAME
FROM QSYS2.GROUP_PROFILE_ENTRIES
WHERE GROUP_PROFILE_NAME IN (
SELECT AUTHORIZATION_NAME
FROM QSYS2.USER_INFO
WHERE SPECIAL_AUTHORITIES like '%*ALLOBJ%'
)
)
ORDER BY AUTHORIZATION_NAME;


--  category:  IBM i Services
--  description:  Security - Review *JOBCTL users

--
-- Which users have *JOBCTL authority either directly
-- or via a Group or Supplemental profile?
--
SELECT AUTHORIZATION_NAME, STATUS, NO_PASSWORD_INDICATOR, PREVIOUS_SIGNON,
TEXT_DESCRIPTION
FROM QSYS2.USER_INFO
WHERE SPECIAL_AUTHORITIES LIKE '%*JOBCTL%'
OR AUTHORIZATION_NAME IN (
SELECT USER_PROFILE_NAME
FROM QSYS2.GROUP_PROFILE_ENTRIES
WHERE GROUP_PROFILE_NAME IN (
SELECT AUTHORIZATION_NAME
FROM QSYS2.USER_INFO
WHERE SPECIAL_AUTHORITIES like '%*JOBCTL%'
)
)
ORDER BY AUTHORIZATION_NAME;


--  category:  IBM i Services
--  description:  Security - Secure column values within SQL tooling

--
-- Secure salary column values in the SQL Performance Center  
--
CALL SYSPROC.SET_COLUMN_ATTRIBUTE('TOYSTORE',
                                  'EMPLOYEE',
                                  'SALARY', 
                                  'SECURE YES'); 

--
-- Review configuration of SECURE column values for the tools 
-- used by DBEs & Database Performance analysts 
--
 SELECT COLUMN_NAME,SECURE 
    FROM QSYS2.SYSCOLUMNS2 
    WHERE SYSTEM_TABLE_SCHEMA = 'TOYSTORE' AND
          SYSTEM_TABLE_NAME   = 'EMPLOYEE';


--  category:  IBM i Services
--  description:  Security - User Info Basic (faster than User Info)
--  minvrm:  v7r3m0

--
-- Review all user profiles that have an expired password
--
select *
  from QSYS2.USER_INFO_BASIC
  where DAYS_UNTIL_PASSWORD_EXPIRES = 0
  order by coalesce(PREVIOUS_SIGNON, current timestamp - 100 years) asc;


--  category:  IBM i Services
--  description:  Security - User Info Sign On Failures

--
-- Which users are having trouble signing on?
--
SELECT * FROM QSYS2.USER_INFO 
 WHERE SIGN_ON_ATTEMPTS_NOT_VALID > 0;


--  category:  IBM i Services
--  description:  Security - User Info close to disabled

--
-- Which users are at risk of becoming disabled due to lack of use? 
--
SELECT * FROM QSYS2.USER_INFO 
 WHERE STATUS = '*ENABLED' AND LAST_USED_TIMESTAMP IS NOT NULL
 ORDER BY LAST_USED_TIMESTAMP ASC
 FETCH FIRST 20 ROWS ONLY;


--  category:  IBM i Services
--  description:  Security - Which users are changing data via a remote connection?
--  minvrm:  v7r2m0
--  Note: this is available at IBM i 7.2 and higher because this example uses the named and default parameters on a function invocation

SELECT OBJECT,"CURRENT_USER",remote_address,
COUNT(*) AS change_count
   FROM TABLE(qsys2.display_journal('QSYS', 'QAUDJRN', -- Journal library and name
journal_entry_types => 'ZC', -- Journal entry types
starting_timestamp => CURRENT TIMESTAMP - 24 HOURS -- Time period
)) AS x
   WHERE remote_address IS NOT NULL
   GROUP BY OBJECT, "CURRENT_USER", remote_address;


--  category:  IBM i Services
--  description:  Spool - Consume my most recent spooled file

--
-- Query my most recent spooled file
--
WITH my_spooled_files (
      job,
      FILE,
      file_number,
      user_data,
      create_timestamp
   )
      AS (SELECT job_name,
                 spooled_file_name,
                 file_number,
                 user_data,
                 create_timestamp
            FROM qsys2.output_queue_entries_basic
            WHERE user_name = USER
            ORDER BY create_timestamp DESC
            LIMIT 1)
   SELECT job,
          FILE,
          file_number,
          spooled_data
      FROM my_spooled_files,
           TABLE (
              systools.spooled_file_data(
                 job_name => job, spooled_file_name => FILE,
                 spooled_file_number => file_number)
           );
           




--  category:  IBM i Services
--  description:  Spool - Generate PDF into the IFS
--  minvrm: V7R3M0

--
-- What spooled files exist for a user?
--
select *
  from qsys2.output_queue_entries_basic
  where status = 'READY' and
        user_name = 'JOEUSER';

cl: mkdir '/usr/timmr';

--
-- What files exist under this path?
--
select *
  from table (
      qsys2.ifs_object_statistics(START_PATH_NAME => '/usr/JOEUSER', SUBTREE_DIRECTORIES => 'YES')
    );

--
-- Take the spooled files and generate pdfs into IFS path
-- Note: prerequisite software: 5770TS1 - Option 1 - Transform Services - AFP to PDF Transform 
--
select job_name, spooled_file_name, file_number, 
  SYSTOOLS.Generate_PDF( 
   job_name            => job_name, 
   spooled_file_name   => spooled_file_name, 
   spooled_file_number => file_number, 
   path_name   => '/usr/timmr/' concat regexp_replace(job_name, '/', '_') 
      concat '_' concat spooled_file_name concat '_' concat file_number) 
      as "pdf_created?",
   '/usr/timmr/' concat regexp_replace(job_name, '/', '_') 
      concat '_' concat spooled_file_name concat '_' concat file_number
      as pdf_path from qsys2.output_queue_entries_basic 
      where status = 'READY' and user_name = 'TIMMR';

--
-- What files exist under this path?
--
select *
  from table (
      qsys2.ifs_object_statistics(START_PATH_NAME => '/usr/timmr/', SUBTREE_DIRECTORIES => 'YES')
    );

--
-- and the data is there
--
select path_name, line_number, line
  from table (
         qsys2.ifs_object_statistics(START_PATH_NAME => '/usr/timmr/', SUBTREE_DIRECTORIES => 'YES')
       ), lateral (
         select *
           from table (
               qsys2.ifs_read_binary(
                 path_name => path_name,   maximum_line_length => default,
                 ignore_errors => 'NO')
             )
       ) where object_type = '*STMF';

 


--  category:  IBM i Services
--  description:  Spool - Output queue basic detail

--
-- Find the 100 largest spool files in the QEZJOBLOG output queue.
--
SELECT * FROM QSYS2.OUTPUT_QUEUE_ENTRIES_BASIC
  WHERE OUTPUT_QUEUE_NAME = 'QEZJOBLOG'
  ORDER BY SIZE DESC
  FETCH FIRST 100 ROWS ONLY;

--
-- Find the top 10 consumers of SPOOL storage.
--
SELECT USER_NAME, SUM(SIZE) AS TOTAL_SPOOL_SPACE
  FROM QSYS2.OUTPUT_QUEUE_ENTRIES_BASIC
  WHERE USER_NAME NOT LIKE 'Q%'
  GROUP BY USER_NAME
  ORDER BY TOTAL_SPOOL_SPACE DESC LIMIT 10;


--  category:  IBM i Services
--  description:  Spool - Output queue exploration

--
-- Find the output queue with the most files & see the details
WITH BIGGEST_OUTQ(LIBNAME, QUEUENAME, FILECOUNT)
   AS (SELECT OUTPUT_QUEUE_LIBRARY_NAME, OUTPUT_QUEUE_NAME, NUMBER_OF_FILES
          FROM QSYS2.OUTPUT_QUEUE_INFO
          ORDER BY NUMBER_OF_FILES DESC
          FETCH FIRST 1 ROWS ONLY)
   SELECT LIBNAME, QUEUENAME, X.*  FROM BIGGEST_OUTQ,   
          TABLE(QSYS2.OUTPUT_QUEUE_ENTRIES(LIBNAME, QUEUENAME, '*NO')) X
 ORDER BY TOTAL_PAGES DESC;


-- Review the files on the top 5 output queues with the most files
WITH outqs_manyfiles ( libname, queuename )
   AS (SELECT OUTPUT_QUEUE_LIBRARY_NAME, OUTPUT_QUEUE_NAME
          FROM QSYS2.OUTPUT_QUEUE_INFO
          ORDER BY NUMBER_OF_FILES DESC
          FETCH FIRST 5 ROWS ONLY)
   SELECT libname, queuename, create_timestamp, spooled_file_name, user_name, total_pages, size 
	FROM outqs_manyfiles INNER JOIN QSYS2.OUTPUT_QUEUE_ENTRIES 
	ON queuename=OUTPUT_QUEUE_NAME AND libname=OUTPUT_QUEUE_LIBRARY_NAME 
 	ORDER BY TOTAL_PAGES DESC;


--  category:  IBM i Services
--  description:  Spool - Search all QZDASOINIT spooled files

--
-- Find QZDASONIT joblogs related to a specific TCP/IP address
--
with my_spooled_files (
        job,
        file,
        file_number,
        user_data,
        create_timestamp
     )
        as (select job_name,
                   spooled_file_name,
                   file_number,
                   user_data,
                   create_timestamp
              from qsys2.output_queue_entries_basic
              where user_data = 'QZDASOINIT' and spooled_file_name = 'QPJOBLOG'
                 and CREATE_TIMESTAMP > CURRENT TIMESTAMP - 24 hours
              order by create_timestamp desc),
     all_my_spooled_file_data (
        job,
        file,
        file_number,
        spool_data
     )
     as (
        select job,
               file,
               file_number,
               spooled_data
           from my_spooled_files,
                table (
                   systools.spooled_file_data(
                      job_name => job, spooled_file_name => file,
                      spooled_file_number => file_number)
                )
     )
   select *
      from all_my_spooled_file_data
      where upper(spool_data) like upper('%client 9.85.200.78 connected to server%') ;     




--  category:  IBM i Services
--  description:  Spool - Top 10 consumers of spool storage

--
-- Find the top 10 consumers of SPOOL storage 
-- Note: Replace library-name with the target library name
--
SELECT USER_NAME, SUM(SIZE) AS TOTAL_SPOOL_SPACE FROM 
   TABLE (QSYS2.OBJECT_STATISTICS('QSYS      ', '*LIB') ) as a, 
   TABLE (QSYS2.OBJECT_STATISTICS(a.objname, 'OUTQ')  ) AS b, 
   TABLE (QSYS2.OUTPUT_QUEUE_ENTRIES(a.objname, b.objname, '*NO')) AS c
WHERE USER_NAME NOT LIKE 'Q%'
GROUP BY USER_NAME
ORDER BY TOTAL_SPOOL_SPACE DESC
LIMIT 10;


--  category:  IBM i Services
--  description:  Spool - managing spool

--
-- Preview spooled files to remove
--
call systools.delete_old_spooled_files(delete_older_than => current timestamp - 30 days, 
-- p_output_queue_library_name => , 
-- p_output_queue_name => , 
-- p_user_name => , 
                                       preview => 'YES');

--
-- Remove the spooled files
--
call systools.delete_old_spooled_files(delete_older_than => current timestamp - 30 days, 
                                       preview => 'NO');


--  category:  IBM i Services
--  description:  Storage - ASP management

--
-- description: Review ASP and IASP definition and status
--
select * from qsys2.asp_info
  order by ASP_NUMBER;

--
-- description: Review ASP and IASP storage status
--
select ASP_NUMBER, DEVD_NAME, DISK_UNITS, PRESENT, 
       TOTAL_CAPACITY_AVAILABLE, TOTAL_CAPACITY, 
       DEC(DEC(TOTAL_CAPACITY_AVAILABLE, 19, 2) /
       DEC(TOTAL_CAPACITY, 19, 2) * 100, 19, 2) AS
       AVAILABLE_SPACE
       from qsys2.asp_info ORDER BY 7 ASC;


--  category:  IBM i Services
--  description:  Storage - ASP management

--
-- description: SQL alternative to WRKASPJOB
--
SELECT iasp_name AS iasp,
       iasp_number AS iasp#,
       job_name,
       job_status AS status,
       job_type AS TYPE,
       user_name AS "User",
       subsystem_name AS sbs,
       sql_status,
       sql_stmt,
       sql_time,
       asp_type,
       rdb_name
   FROM qsys2.asp_job_info;


--  category:  IBM i Services
--  description:  Storage - IASP Vary ON and OFF steps

--
-- description: Review the most expensive steps in recent vary ONs
--
SELECT v.* FROM qsys2.asp_vary_info v 
WHERE OPERATION_TYPE = 'VARY ON'
AND END_TIMESTAMP > CURRENT TIMESTAMP - 21 DAYS 
ORDER BY duration DESC; 

--
-- description: Review the most expensive steps in recent vary ONs
--
SELECT iasp_name,       operation_type,
       operation_number,MAX(start_timestamp) AS WHEN,
       BIGINT(SUM(duration)) AS total_seconds
   FROM qsys2.asp_vary_info WHERE DURATION IS NOT NULL
   AND END_TIMESTAMP > CURRENT TIMESTAMP - 21 DAYS
   GROUP BY iasp_name, operation_type, operation_number
   ORDER BY total_seconds DESC;


--  category:  IBM i Services
--  description:  Storage - Media Library

-- Check for unavailable tape drives 
SELECT * FROM QSYS2.MEDIA_LIBRARY_INFO 
  WHERE DEVICE_STATUS = 'VARIED OFF';


--  category:  IBM i Services
--  description:  Storage - NVMe Fuel Gauge

--
-- NVMe health detail
--      
select CAP_MET, LIFE, DEGRADED, TEMP_WARN, TEMP_CRIT, 
       DEVICE_TYPE, RESOURCE_NAME, DEVICE_MODEL,
       SERIAL_NUMBER
  from QSYS2.NVME_INFO;


--  category:  IBM i Services
--  description:  Storage - Review status of all storage H/W

--
-- Query information for all DISKs, order by percentage used
--
SELECT PERCENT_USED, 
       CASE WHEN UNIT_TYPE = 1 
          THEN 'SSD' 
          ELSE 'DISK' END as STORAGE_TYPE, 
       A.* 
FROM QSYS2.SYSDISKSTAT A 
ORDER BY PERCENT_USED DESC;


--  category:  IBM i Services
--  description:  Storage - Storage details for a specific user 

--
-- Retrieve the details of objects owned by a specific user
-- Note: replace user-name with the user profile name of interest
--
SELECT b.objlongschema, b.objname, b.objtype, b.objattribute, b.objcreated, b.objsize, b.objtext, b.days_used_count, b.last_used_timestamp,b.* FROM 
   TABLE (QSYS2.OBJECT_STATISTICS('*ALLUSRAVL ', '*LIB') ) as a, 
   TABLE (QSYS2.OBJECT_STATISTICS(a.objname, 'ALL')  ) AS b
WHERE b.OBJOWNER = 'user-name'
ORDER BY b.OBJSIZE DESC
FETCH FIRST 100 ROWS ONLY;


--  category:  IBM i Services
--  description:  Storage - Temporary storage consumption, by DB workload

--
-- Which active database server connections 
-- are consuming the most temporary storage
--
WITH TOP_TMP_STG (bucket_current_size, q_job_name) AS (
SELECT bucket_current_size, rtrim(job_number) concat '/' concat rtrim(job_user_name) concat '/' concat rtrim(job_name) as q_job_name 
FROM QSYS2.SYSTMPSTG 
WHERE job_status = '*ACTIVE' AND JOB_NAME IN ('QZDASOINIT', 'QZDASSINIT', 'QRWTSRVR', 'QSQSRVR')
ORDER BY bucket_current_size desc fetch first 10 rows only
) SELECT bucket_current_size, q_job_name, V_SQL_STATEMENT_TEXT, B.* FROM TOP_TMP_STG, TABLE(QSYS2.GET_JOB_INFO(q_job_name)) B;


--  category:  IBM i Services
--  description:  Storage - Temporary storage consumption, by active jobs

--
-- Which active jobs are the top consumers of temporary storage?
--
SELECT bucket_current_size, bucket_peak_size, 
  rtrim(job_number) concat '/' 
  concat rtrim(job_user_name) 
  concat '/' 
  concat rtrim(job_name) as q_job_name 
FROM QSYS2.SYSTMPSTG 
WHERE job_status = '*ACTIVE' 
ORDER BY bucket_current_size desc;


--  category:  IBM i Services
--  description:  Storage - Top 10 Spool consumers, by user 

--
-- Find the top 10 consumers of SPOOL storage 
--
SELECT USER_NAME, SUM(SIZE) AS TOTAL_SPOOL_SPACE FROM 
   TABLE (QSYS2.OBJECT_STATISTICS('QSYS      ', '*LIB') ) as a, 
   TABLE (QSYS2.OBJECT_STATISTICS(a.objname, 'OUTQ')  ) AS b, 
   TABLE (QSYS2.OUTPUT_QUEUE_ENTRIES(a.objname, b.objname, '*NO')) AS c
WHERE USER_NAME NOT LIKE 'Q%' 
GROUP BY USER_NAME
ORDER BY TOTAL_SPOOL_SPACE DESC
FETCH FIRST 10 ROWS ONLY;


--  category:  IBM i Services
--  description:  Storage - Top 10 consumers, by user 

--
-- Review the top 10 storage consumers
SELECT A.AUTHORIZATION_NAME, SUM(A.STORAGE_USED) AS TOTAL_STORAGE_USED, B.TEXT_DESCRIPTION, B.ACCOUNTING_CODE, B.MAXIMUM_ALLOWED_STORAGE
  FROM QSYS2.USER_STORAGE A 
  INNER JOIN QSYS2.USER_INFO B ON B.USER_NAME = A.AUTHORIZATION_NAME WHERE B.USER_NAME NOT LIKE 'Q%' 
  GROUP BY A.AUTHORIZATION_NAME, B.TEXT_DESCRIPTION, B.ACCOUNTING_CODE, B.MAXIMUM_ALLOWED_STORAGE
  ORDER BY TOTAL_STORAGE_USED DESC FETCH FIRST 10 ROWS ONLY;


--  category:  IBM i Services
--  description:  Storage - iASP storage consumption

--
--  Format output and break down by iASP
--
SELECT USER_NAME, ASPGRP,
       VARCHAR_FORMAT(MAXSTG, '999,999,999,999,999,999,999,999') AS MAXIMUM_STORAGE_KB,
       VARCHAR_FORMAT(STGUSED,'999,999,999,999,999,999,999,999') AS STORAGE_KB
       FROM QSYS2.USER_STORAGE 
  ORDER BY 4 DESC;


--  category:  IBM i Services
--  description:  System Health - Fastest query of System Limits detail
--  minvrm: V7R3M0

--
-- Show me the historical percentage used for Maximum # of Jobs
--
-- https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_74/rzajq/rzajqserviceshealth.htm
--
with tt (job_maximum) as (
    select current_numeric_value
      from qsys2.system_value_info
      where system_value_name = 'QMAXJOB'
  )
  select last_change_timestamp as increment_time, current_value as job_count,
         tt.job_maximum,
         dec(dec(current_value, 19, 2) / dec(tt.job_maximum, 19, 2) * 100, 19, 2)
           as percent_consumed
    from qsys2.syslimits_basic, tt
    where limit_id = 19000
    order by Increment_time desc;


--  category:  IBM i Services
--  description:  System Health - System Limits tracking

--
-- Description: Enable alerts for files which are growing near the maximum
--
CL: ALCOBJ OBJ((QSYS2/SYSLIMTBL *FILE *EXCL)) CONFLICT(*RQSRLS) ;
CL: DLCOBJ OBJ((QSYS2/SYSLIMTBL *FILE *EXCL));

CREATE OR REPLACE TRIGGER QSYS2.SYSTEM_LIMITS_LARGE_FILE
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
--
-- Description: Determine if any user triggers have been created over the System Limits table
--
SELECT * FROM QSYS2.SYSTRIGGERS 
  WHERE EVENT_OBJECT_SCHEMA = 'QSYS2' AND EVENT_OBJECT_TABLE = 'SYSLIMTBL';


--  category:  IBM i Services
--  description:  System Health - Tracking the largest database tables

--
-- Review the largest tables in System Limits 
-- 
 WITH X AS (SELECT ROW_NUMBER() 
            OVER(PARTITION BY SYSTEM_SCHEMA_NAME, 
                 SYSTEM_OBJECT_NAME, SYSTEM_TABLE_MEMBER ORDER BY 
                CURRENT_VALUE DESC NULLS LAST) AS R, U.* 
            FROM QSYS2.SYSLIMITS U 
            WHERE LIMIT_ID = 15000) 
        SELECT LAST_CHANGE_TIMESTAMP, SYSTEM_SCHEMA_NAME, 
          SYSTEM_OBJECT_NAME, SYSTEM_TABLE_MEMBER, 
        CURRENT_VALUE 
        FROM X WHERE R = 1 
        ORDER BY CURRENT_VALUE DESC;


--  category:  IBM i Services
--  description:  What is our journaling setup, by object type
  
SELECT JOURNAL_LIBRARY, JOURNAL_NAME, OBJTYPE, COUNT(*) 
  FROM TABLE(QSYS2.OBJECT_STATISTICS('TOYSTORE', '*ALL')) X
  GROUP BY JOURNAL_LIBRARY, JOURNAL_NAME, OBJTYPE
  ORDER BY 1, 2, 3, 4 DESC;
  

--
-- Which files in a library, are not being journaled?
--  
SELECT * 
  FROM TABLE(QSYS2.OBJECT_STATISTICS('TOYSTORE', '*ALL')) X
  WHERE JOURNAL_LIBRARY IS NULL AND OBJTYPE = '*FILE'
  ORDER BY OBJNAME ASC;


--  category:  IBM i Services
--  description:  What unofficial IBM i code exists in QSYS?

SELECT * FROM TABLE(QSYS2.OBJECT_STATISTICS('QSYS', '*PGM *SRVPGM')) X
  WHERE OBJECT_DOMAIN = '*SYSTEM' and OBJECT_SIGNED = 'NO'
  ORDER BY LAST_USED_TIMESTAMP DESC;


--  category:  IBM i Services
--  description:  Work Management - Active Job Info - Largest Query

--
-- description: Find the 10 QZDASOINIT jobs that have executed the most expensive (by storage) queries
--
SELECT JOB_NAME, LARGEST_QUERY_SIZE, J.*
FROM TABLE(QSYS2.ACTIVE_JOB_INFO(
  subsystem_list_filter => 'QUSRWRK', 
  job_name_filter       => 'QZDASOINIT', 
  detailed_info         => 'ALL')) J
ORDER BY LARGEST_QUERY_SIZE DESC
LIMIT 10;




--  category:  IBM i Services
--  description:  Work Management - Active Job Info - Lock contention

--
-- description: Find the jobs that are encountering the most lock contention
--
SELECT JOB_NAME, DATABASE_LOCK_WAITS, NON_DATABASE_LOCK_WAITS, 
       DATABASE_LOCK_WAITS + NON_DATABASE_LOCK_WAITS as Total_Lock_Waits, J.*
FROM TABLE (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => 'ALL')) J
ORDER BY 4 DESC
LIMIT 20;


--  category:  IBM i Services
--  description:  Work Management - Active Job Info - Long running SQL statements

--
-- description: Look for long-running SQL statements for a subset of users
--
SELECT JOB_NAME, authorization_name as "User", 
  TIMESTAMPDIFF(2, CAST(CURRENT TIMESTAMP - SQL_STATEMENT_START_TIMESTAMP AS CHAR(22))) AS execution_seconds,
  TIMESTAMPDIFF(4, CAST(CURRENT TIMESTAMP - SQL_STATEMENT_START_TIMESTAMP AS CHAR(22))) AS execution_minutes,
  TIMESTAMPDIFF(8, CAST(CURRENT TIMESTAMP - SQL_STATEMENT_START_TIMESTAMP AS CHAR(22))) AS execution_hours,
  SQL_STATEMENT_TEXT, J.*      
FROM TABLE(QSYS2.ACTIVE_JOB_INFO(
             CURRENT_USER_LIST_FILTER => 'SCOTTF,SLROMANO,JELSBURY',
             DETAILED_INFO            => 'ALL')) J
WHERE SQL_STATEMENT_STATUS = 'ACTIVE'  
ORDER BY 2 DESC
LIMIT 30;
 


--  category:  IBM i Services
--  description:  Work Management - Active Job Info - QTEMP consumption
 
--
-- description: Identify Host Server jobs currently using >10 Meg of QTEMP
--
SELECT qtemp_size, job_name,
   internal_job_id, subsystem, subsystem_library_name, authorization_name, job_type,
   function_type, "FUNCTION", job_status, memory_pool, run_priority, thread_count,
   temporary_storage, cpu_time, total_disk_io_count, elapsed_interaction_count,
   elapsed_total_response_time, elapsed_total_disk_io_count,
   elapsed_async_disk_io_count, elapsed_sync_disk_io_count, elapsed_cpu_percentage,
   elapsed_cpu_time, elapsed_page_fault_count, job_end_reason, server_type, elapsed_time
FROM TABLE(qsys2.active_job_info(
  subsystem_list_filter => 'QUSRWRK', 
  job_name_filter       => 'QZDASOINIT', 
  detailed_info         => 'QTEMP'))
WHERE qtemp_size > 10; 


--  category:  IBM i Services
--  description:  Work Management - Active Job Info - Temp storage top consumers
 
--
-- description: Find active jobs using the most temporary storage. 
--
SELECT JOB_NAME, AUTHORIZATION_NAME, TEMPORARY_STORAGE, SQL_STATEMENT_TEXT, J.*
  FROM TABLE (QSYS2.ACTIVE_JOB_INFO(DETAILED_INFO => 'ALL')) J
   WHERE JOB_TYPE <> 'SYS' ORDER BY TEMPORARY_STORAGE DESC ;


--  category:  IBM i Services
--  description:  Work Management - Active Job info - Longest active DRDA connections

--
-- Find the active DRDA jobs and compute the connection duration
--
WITH ACTIVE_USER_JOBS (Q_JOB_NAME,  CPU_TIME, RUN_PRIORITY) AS ( 
SELECT JOB_NAME, CPU_TIME, RUN_PRIORITY FROM TABLE (ACTIVE_JOB_INFO('NO','','QRWTSRVR','')) x 
WHERE JOB_STATUS <> 'PSRW'
) SELECT Q_JOB_NAME, 
ABS( CURRENT TIMESTAMP - MESSAGE_TIMESTAMP ) AS CONNECTION_DURATION, CPU_TIME, RUN_PRIORITY, B.* 
FROM ACTIVE_USER_JOBS, TABLE(QSYS2.JOBLOG_INFO(Q_JOB_NAME)) B 
WHERE MESSAGE_ID = 'CPI3E01'   
ORDER BY CONNECTION_DURATION DESC ; 


--  category:  IBM i Services
--  description:  Work Management - Active Job info - Longest running SQL statements

--
-- Find the jobs with SQL statements executing and order the results by duration of SQL statement execution
--
WITH ACTIVE_USER_JOBS (Q_JOB_NAME, AUTHORIZATION_NAME, CPU_TIME, RUN_PRIORITY) AS ( 
SELECT JOB_NAME, AUTHORIZATION_NAME, CPU_TIME, RUN_PRIORITY FROM TABLE (ACTIVE_JOB_INFO('NO','','','')) x 
WHERE JOB_TYPE <> 'SYS' 
) SELECT Q_JOB_NAME, AUTHORIZATION_NAME, CPU_TIME, RUN_PRIORITY, V_SQL_STATEMENT_TEXT, 
ABS( CURRENT TIMESTAMP - V_SQL_STMT_START_TIMESTAMP )  AS SQL_STMT_DURATION, B.* 
FROM ACTIVE_USER_JOBS, TABLE(QSYS2.GET_JOB_INFO(Q_JOB_NAME)) B 
WHERE V_SQL_STMT_STATUS = 'ACTIVE'   
ORDER BY SQL_STMT_DURATION DESC ; 


--  category:  IBM i Services
--  description:  Work Management - Active Job info - SQL Server Mode study

--
-- Find active QSQSRVR jobs and the owning application job
--
WITH tt (authorization_name, job_name, cpu_time, total_disk_io_count)
AS (
select authorization_name, job_name, cpu_time, total_disk_io_count from
table(qsys2.active_job_info(
SUBSYSTEM_LIST_FILTER=>'QSYSWRK',
JOB_NAME_FILTER=>'QSQSRVR')) x
)
select authorization_name, ss.message_text, job_name, cpu_time,
total_disk_io_count
from tt, table(qsys2.joblog_info(job_name)) ss where message_id = 'CPF9898' and
from_program = 'QSQSRVR'
ORDER BY CPU_TIME DESC;


--  category:  IBM i Services
--  description:  Work Management - Active Job info - Temp storage consumers, by memory pool

--
-- Find the top 4 consumers of temporary storage, by memory pool
--
WITH TOP_CONSUMERS (JOB_NAME, MEMORY_POOL, AUTHORIZATION_NAME, FUNCTION_TYPE, FUNCTION, TEMPORARY_STORAGE, RANK) AS (
        SELECT JOB_NAME, MEMORY_POOL, AUTHORIZATION_NAME, FUNCTION_TYPE, FUNCTION, TEMPORARY_STORAGE, RANK() OVER (
                   PARTITION BY MEMORY_POOL
                   ORDER BY TEMPORARY_STORAGE DESC
               )
            FROM TABLE (
                    ACTIVE_JOB_INFO()
                ) x
            WHERE JOB_TYPE <> 'SYS'
    )
    SELECT JOB_NAME, MEMORY_POOL, AUTHORIZATION_NAME, FUNCTION_TYPE CONCAT '-' CONCAT FUNCTION AS FUNCTION,
           TEMPORARY_STORAGE
        FROM TOP_CONSUMERS
        WHERE RANK IN (1, 2, 3, 4)
        ORDER BY MEMORY_POOL DESC;


--  category:  IBM i Services
--  description:  Work Management - Active Job info - Top ZDA CPU consumers
--  minvrm:  v7r2m0
--  Note: this is available at IBM i 7.2 and higher, because it uses named parameter syntax... <parameter name> => <parameter value>


-- Examine active Host Server jobs and find the top consumers
SELECT JOB_NAME, AUTHORIZATION_NAME,  ELAPSED_CPU_PERCENTAGE,ELAPSED_TOTAL_DISK_IO_COUNT, ELAPSED_PAGE_FAULT_COUNT, X.*
	FROM TABLE(ACTIVE_JOB_INFO(
		   JOB_NAME_FILTER => 'QZDASOINIT',
		   SUBSYSTEM_LIST_FILTER => 'QUSRWRK')) x
ORDER BY ELAPSED_CPU_PERCENTAGE DESC
FETCH FIRST 10 ROWS ONLY;


--  category:  IBM i Services
--  description:  Work Management - Active Subsystem detail

select subsystem_description_library, subsystem_description, maximum_active_jobs,
       current_active_jobs, subsystem_monitor_job, text_description,
       controlling_subsystem, workload_group, signon_device_file_library,
       signon_device_file, secondary_language_library, iasp_name
  from qsys2.subsystem_info
  where status = 'ACTIVE'
  order by current_active_jobs desc;


--  category:  IBM i Services
--  description:  Work Management - Communications Entry Info
--  minvrm: V7R3M0
--

-- List all the communications entries defined for the QCMN subsystem
select *
  from qsys2.communications_entry_info
  where subsystem_description_library = 'QSYS' and
        subsystem_description = 'QCMN';


--  category:  IBM i Services
--  description:  Work Management - Interactive jobs

--
-- Find all interactive jobs 
--
SELECT * FROM TABLE(QSYS2.JOB_INFO(JOB_TYPE_FILTER => '*INTERACT')) X;


--  category:  IBM i Services
--  description:  Work Management - Job Description Initial Library List

--
-- If we plan to delete a library, use SQL to determine whether any job descriptions 
-- include that library name in its INLLIBL.

-- Examine the library lists for every job description.
-- Since the library list column returns a character string containing a list of libraries,
-- to see the individual library names it needs to be broken apart. 
-- To do this, you can create a table function that takes the library list string and returns a list of library names.

CREATE OR REPLACE FUNCTION systools.get_lib_names (
         jobd_libl VARCHAR(2750),
         jobd_libl_cnt INT
      )
   RETURNS TABLE (
      libl_position INT, library_name VARCHAR(10)
   )
   BEGIN
      DECLARE in_pos INT;
      DECLARE lib_cnt INT;
      SET in_pos = 1;
      SET lib_cnt = 1;
      WHILE lib_cnt <= jobd_libl_cnt DO
         PIPE (
            lib_cnt,
            RTRIM((SUBSTR(jobd_libl, in_pos, 10)))
         );
         SET in_pos = in_pos + 11;
         SET lib_cnt = lib_cnt + 1;
      END WHILE;
      RETURN;
   END;
 
--
-- Use the function to interrogate the use of libraries in jobd's libl
--
SELECT job_description,
       job_description_library,
       libl_position,
       library_name
   FROM qsys2.job_description_info,
        TABLE (
           systools.get_lib_names(library_list, library_list_count)
        ) x
   WHERE library_name = 'QGPL';
                             


--  category:  IBM i Services
--  description:  Work Management - Job Descriptions

--
-- description: compare job descriptions between production and DR or HA
-- (note change xxxxxxx to be the RDB name of the target for comparison)
--           
DECLARE GLOBAL TEMPORARY TABLE SESSION . remote_job_descriptions
   (job_description_library, job_description, authorization_name, job_date,
      accounting_code, routing_data, request_data, library_list_count, library_list,
      job_switches, text_description, job_queue_library, job_queue, job_queue_priority,
      hold_on_job_queue, output_queue_library, output_queue, output_queue_priority,
      spooled_file_action, printer_device, print_text, job_message_queue_maximum_size,
      job_message_queue_full_action, syntax_check_severity, job_end_severity,
      joblog_output, inquiry_message_reply, message_logging_level,
      message_logging_severity, message_logging_text, log_cl_program_commands,
      device_recovery_action, time_slice_end_pool, allow_multiple_threads,
      workload_group, aspgrp, ddm_conversation)
   AS (SELECT *
          FROM xxxxxxx.qsys2.job_description_info jd)
   WITH DATA WITH REPLACE;

-- 
-- Any rows returned represent a difference
--
SELECT 'Production' AS "System Name",
  A.JOB_DESCRIPTION_LIBRARY, A.JOB_DESCRIPTION, A.AUTHORIZATION_NAME, A.JOB_DATE, A.ACCOUNTING_CODE, A.ROUTING_DATA, A.REQUEST_DATA, A.LIBRARY_LIST_COUNT,
  A.LIBRARY_LIST, A.JOB_SWITCHES, A.TEXT_DESCRIPTION, A.JOB_QUEUE_LIBRARY, A.JOB_QUEUE, A.JOB_QUEUE_PRIORITY, A.HOLD_ON_JOB_QUEUE, A.OUTPUT_QUEUE_LIBRARY,
  A.OUTPUT_QUEUE, A.OUTPUT_QUEUE_PRIORITY, A.SPOOLED_FILE_ACTION, A.PRINTER_DEVICE, A.PRINT_TEXT, A.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE,
  A.JOB_MESSAGE_QUEUE_FULL_ACTION, A.SYNTAX_CHECK_SEVERITY, A.JOB_END_SEVERITY, A.JOBLOG_OUTPUT, A.INQUIRY_MESSAGE_REPLY, A.MESSAGE_LOGGING_LEVEL,
  A.MESSAGE_LOGGING_SEVERITY, A.MESSAGE_LOGGING_TEXT, A.LOG_CL_PROGRAM_COMMANDS, A.DEVICE_RECOVERY_ACTION, A.TIME_SLICE_END_POOL, A.ALLOW_MULTIPLE_THREADS,
  A.ASPGRP, A.DDM_CONVERSATION
	FROM qsys2.job_description_info A LEFT EXCEPTION JOIN SESSION.remote_job_descriptions B 
    ON  A.JOB_DESCRIPTION_LIBRARY IS NOT DISTINCT FROM b.JOB_DESCRIPTION_LIBRARY
	AND A.JOB_DESCRIPTION IS NOT DISTINCT FROM b.JOB_DESCRIPTION
	AND A.AUTHORIZATION_NAME IS NOT DISTINCT FROM b.AUTHORIZATION_NAME
	AND A.JOB_DATE IS NOT DISTINCT FROM b.JOB_DATE
	AND A.ACCOUNTING_CODE IS NOT DISTINCT FROM b.ACCOUNTING_CODE
	AND A.ROUTING_DATA IS NOT DISTINCT FROM b.ROUTING_DATA
	AND A.REQUEST_DATA IS NOT DISTINCT FROM b.REQUEST_DATA
	AND A.LIBRARY_LIST_COUNT IS NOT DISTINCT FROM b.LIBRARY_LIST_COUNT
	AND A.LIBRARY_LIST IS NOT DISTINCT FROM b.LIBRARY_LIST
	AND A.JOB_SWITCHES IS NOT DISTINCT FROM b.JOB_SWITCHES
	AND A.TEXT_DESCRIPTION IS NOT DISTINCT FROM b.TEXT_DESCRIPTION
	AND A.JOB_QUEUE_LIBRARY IS NOT DISTINCT FROM b.JOB_QUEUE_LIBRARY
	AND A.JOB_QUEUE IS NOT DISTINCT FROM b.JOB_QUEUE
	AND A.JOB_QUEUE_PRIORITY IS NOT DISTINCT FROM b.JOB_QUEUE_PRIORITY
	AND A.HOLD_ON_JOB_QUEUE IS NOT DISTINCT FROM b.HOLD_ON_JOB_QUEUE
	AND A.OUTPUT_QUEUE_LIBRARY IS NOT DISTINCT FROM b.OUTPUT_QUEUE_LIBRARY
	AND A.OUTPUT_QUEUE IS NOT DISTINCT FROM b.OUTPUT_QUEUE
	AND A.OUTPUT_QUEUE_PRIORITY IS NOT DISTINCT FROM b.OUTPUT_QUEUE_PRIORITY
	AND A.SPOOLED_FILE_ACTION IS NOT DISTINCT FROM b.SPOOLED_FILE_ACTION
	AND A.PRINTER_DEVICE IS NOT DISTINCT FROM b.PRINTER_DEVICE
	AND A.PRINT_TEXT IS NOT DISTINCT FROM b.PRINT_TEXT
	AND A.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE IS NOT DISTINCT FROM b.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE
	AND A.JOB_MESSAGE_QUEUE_FULL_ACTION IS NOT DISTINCT FROM b.JOB_MESSAGE_QUEUE_FULL_ACTION
	AND A.SYNTAX_CHECK_SEVERITY IS NOT DISTINCT FROM b.SYNTAX_CHECK_SEVERITY
	AND A.JOB_END_SEVERITY IS NOT DISTINCT FROM b.JOB_END_SEVERITY
	AND A.JOBLOG_OUTPUT IS NOT DISTINCT FROM b.JOBLOG_OUTPUT
	AND A.INQUIRY_MESSAGE_REPLY IS NOT DISTINCT FROM b.INQUIRY_MESSAGE_REPLY
	AND A.MESSAGE_LOGGING_LEVEL IS NOT DISTINCT FROM b.MESSAGE_LOGGING_LEVEL
	AND A.MESSAGE_LOGGING_SEVERITY IS NOT DISTINCT FROM b.MESSAGE_LOGGING_SEVERITY
	AND A.MESSAGE_LOGGING_TEXT IS NOT DISTINCT FROM b.MESSAGE_LOGGING_TEXT
	AND A.LOG_CL_PROGRAM_COMMANDS IS NOT DISTINCT FROM b.LOG_CL_PROGRAM_COMMANDS
	AND A.DEVICE_RECOVERY_ACTION IS NOT DISTINCT FROM b.DEVICE_RECOVERY_ACTION
	AND A.TIME_SLICE_END_POOL IS NOT DISTINCT FROM b.TIME_SLICE_END_POOL
	AND A.ALLOW_MULTIPLE_THREADS IS NOT DISTINCT FROM b.ALLOW_MULTIPLE_THREADS
	AND A.ASPGRP IS NOT DISTINCT FROM b.ASPGRP
	AND A.DDM_CONVERSATION IS NOT DISTINCT FROM b.DDM_CONVERSATION
union all
SELECT 'Failover' AS "System Name",
  B.JOB_DESCRIPTION_LIBRARY, B.JOB_DESCRIPTION, B.AUTHORIZATION_NAME, B.JOB_DATE, B.ACCOUNTING_CODE, B.ROUTING_DATA,
  B.REQUEST_DATA, B.LIBRARY_LIST_COUNT, B.LIBRARY_LIST, B.JOB_SWITCHES, B.TEXT_DESCRIPTION, B.JOB_QUEUE_LIBRARY,
  B.JOB_QUEUE, B.JOB_QUEUE_PRIORITY, B.HOLD_ON_JOB_QUEUE, B.OUTPUT_QUEUE_LIBRARY, B.OUTPUT_QUEUE, B.OUTPUT_QUEUE_PRIORITY, B.SPOOLED_FILE_ACTION,
  B.PRINTER_DEVICE, B.PRINT_TEXT, B.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE, B.JOB_MESSAGE_QUEUE_FULL_ACTION, B.SYNTAX_CHECK_SEVERITY, B.JOB_END_SEVERITY,
  B.JOBLOG_OUTPUT, B.INQUIRY_MESSAGE_REPLY, B.MESSAGE_LOGGING_LEVEL, B.MESSAGE_LOGGING_SEVERITY, B.MESSAGE_LOGGING_TEXT, B.LOG_CL_PROGRAM_COMMANDS,
  B.DEVICE_RECOVERY_ACTION, B.TIME_SLICE_END_POOL, B.ALLOW_MULTIPLE_THREADS, B.ASPGRP, B.DDM_CONVERSATION
	FROM qsys2.job_description_info A RIGHT EXCEPTION JOIN SESSION.remote_job_descriptions B 
    ON  A.JOB_DESCRIPTION_LIBRARY IS NOT DISTINCT FROM b.JOB_DESCRIPTION_LIBRARY
	AND A.JOB_DESCRIPTION IS NOT DISTINCT FROM b.JOB_DESCRIPTION
	AND A.AUTHORIZATION_NAME IS NOT DISTINCT FROM b.AUTHORIZATION_NAME
	AND A.JOB_DATE IS NOT DISTINCT FROM b.JOB_DATE
	AND A.ACCOUNTING_CODE IS NOT DISTINCT FROM b.ACCOUNTING_CODE
	AND A.ROUTING_DATA IS NOT DISTINCT FROM b.ROUTING_DATA
	AND A.REQUEST_DATA IS NOT DISTINCT FROM b.REQUEST_DATA
	AND A.LIBRARY_LIST_COUNT IS NOT DISTINCT FROM b.LIBRARY_LIST_COUNT
	AND A.LIBRARY_LIST IS NOT DISTINCT FROM b.LIBRARY_LIST
	AND A.JOB_SWITCHES IS NOT DISTINCT FROM b.JOB_SWITCHES
	AND A.TEXT_DESCRIPTION IS NOT DISTINCT FROM b.TEXT_DESCRIPTION
	AND A.JOB_QUEUE_LIBRARY IS NOT DISTINCT FROM b.JOB_QUEUE_LIBRARY
	AND A.JOB_QUEUE IS NOT DISTINCT FROM b.JOB_QUEUE
	AND A.JOB_QUEUE_PRIORITY IS NOT DISTINCT FROM b.JOB_QUEUE_PRIORITY
	AND A.HOLD_ON_JOB_QUEUE IS NOT DISTINCT FROM b.HOLD_ON_JOB_QUEUE
	AND A.OUTPUT_QUEUE_LIBRARY IS NOT DISTINCT FROM b.OUTPUT_QUEUE_LIBRARY
	AND A.OUTPUT_QUEUE IS NOT DISTINCT FROM b.OUTPUT_QUEUE
	AND A.OUTPUT_QUEUE_PRIORITY IS NOT DISTINCT FROM b.OUTPUT_QUEUE_PRIORITY
	AND A.SPOOLED_FILE_ACTION IS NOT DISTINCT FROM b.SPOOLED_FILE_ACTION
	AND A.PRINTER_DEVICE IS NOT DISTINCT FROM b.PRINTER_DEVICE
	AND A.PRINT_TEXT IS NOT DISTINCT FROM b.PRINT_TEXT
	AND A.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE IS NOT DISTINCT FROM b.JOB_MESSAGE_QUEUE_MAXIMUM_SIZE
	AND A.JOB_MESSAGE_QUEUE_FULL_ACTION IS NOT DISTINCT FROM b.JOB_MESSAGE_QUEUE_FULL_ACTION
	AND A.SYNTAX_CHECK_SEVERITY IS NOT DISTINCT FROM b.SYNTAX_CHECK_SEVERITY
	AND A.JOB_END_SEVERITY IS NOT DISTINCT FROM b.JOB_END_SEVERITY
	AND A.JOBLOG_OUTPUT IS NOT DISTINCT FROM b.JOBLOG_OUTPUT
	AND A.INQUIRY_MESSAGE_REPLY IS NOT DISTINCT FROM b.INQUIRY_MESSAGE_REPLY
	AND A.MESSAGE_LOGGING_LEVEL IS NOT DISTINCT FROM b.MESSAGE_LOGGING_LEVEL
	AND A.MESSAGE_LOGGING_SEVERITY IS NOT DISTINCT FROM b.MESSAGE_LOGGING_SEVERITY
	AND A.MESSAGE_LOGGING_TEXT IS NOT DISTINCT FROM b.MESSAGE_LOGGING_TEXT
	AND A.LOG_CL_PROGRAM_COMMANDS IS NOT DISTINCT FROM b.LOG_CL_PROGRAM_COMMANDS
	AND A.DEVICE_RECOVERY_ACTION IS NOT DISTINCT FROM b.DEVICE_RECOVERY_ACTION
	AND A.TIME_SLICE_END_POOL IS NOT DISTINCT FROM b.TIME_SLICE_END_POOL
	AND A.ALLOW_MULTIPLE_THREADS IS NOT DISTINCT FROM b.ALLOW_MULTIPLE_THREADS
	AND A.ASPGRP IS NOT DISTINCT FROM b.ASPGRP
	AND A.DDM_CONVERSATION IS NOT DISTINCT FROM b.DDM_CONVERSATION 
ORDER BY JOB_DESCRIPTION_LIBRARY, JOB_DESCRIPTION;


--  category:  IBM i Services
--  description:  Work Management - Job Queues

--
-- Review the job queues with the most pending jobs
--
SELECT * FROM qsys2.job_queue_info
 ORDER BY NUMBER_OF_JOBS DESC
 LIMIT 10;


--  category:  IBM i Services
--  description:  Work Management - Jobs that are waiting to run

--
-- Find jobs sitting on a job queue, waiting to run
--
SELECT * FROM TABLE(QSYS2.JOB_INFO(JOB_STATUS_FILTER    => '*JOBQ')) X;


--  category:  IBM i Services
--  description:  Work Management - Locks held by the current job

select *
  from table (
      qsys2.job_lock_info(job_name => '*')
    )
  order by object_library, object_name, object_type;
                             


--  category:  IBM i Services
--  description:  Work Management - Object lock info

--
-- Review detail about all object lock holders over TOYSTORE/EMPLOYEE *FILE
--
WITH LOCK_CONFLICT_TABLE (object_name, lock_state, q_job_name) AS (
SELECT object_name, lock_state, job_name
FROM QSYS2.OBJECT_LOCK_INFO where 
 object_schema = 'TOYSTORE' and 
 object_name = 'EMPLOYEE'
) SELECT object_name, lock_state, q_job_name, V_SQL_STATEMENT_TEXT, V_CLIENT_IP_ADDRESS, 
   B.* FROM LOCK_CONFLICT_TABLE, 
TABLE(QSYS2.GET_JOB_INFO(q_job_name)) B;


--  category:  IBM i Services
--  description:  Work Management - Object lock info

--  Example showing how to use IBM i Services to capture point of failure
--  detail within an SQL procedure, function or trigger

--  One time setup steps
CL: CRTLIB APPLIB;
CREATE OR REPLACE TABLE APPLIB.HARD_TO_DEBUG_PROBLEMS AS 
   (SELECT * FROM TABLE(QSYS2.JOBLOG_INFO('*')) X) WITH NO DATA ON REPLACE PRESERVE ROWS;
CREATE OR REPLACE TABLE APPLIB.HARD_TO_DEBUG_LOCK_PROBLEMS LIKE 
   QSYS2.OBJECT_LOCK_INFO ON REPLACE PRESERVE ROWS;

create or replace procedure toystore.update_sales(IN P_PERSON VARCHAR(50),
IN P_SALES INTEGER, IN P_DATE DATE)
LANGUAGE SQL
BEGIN
-- Handler code
DECLARE EXIT HANDLER FOR SQLSTATE '57033' 
  BEGIN  /* Message: [SQL0913] Object in use. */
  DECLARE SCHEMA_NAME VARCHAR(128);
  DECLARE TABLE_NAME VARCHAR(128);
  DECLARE DOT_LOCATION INTEGER;
  DECLARE MSG_TOKEN CLOB(1K);

  GET DIAGNOSTICS condition 1 MSG_TOKEN = db2_ordinal_token_1;
  SET DOT_LOCATION = LOCATE_IN_STRING(MSG_TOKEN, '.');

  SET SCHEMA_NAME = RTRIM(SUBSTR(MSG_TOKEN, 1, DOT_LOCATION - 1));
  SET TABLE_NAME = RTRIM(SUBSTR(MSG_TOKEN, DOT_LOCATION + 1, LENGTH(MSG_TOKEN) - DOT_LOCATION));
  INSERT INTO APPLIB.HARD_TO_DEBUG_PROBLEMS
    SELECT * FROM TABLE(QSYS2.JOBLOG_INFO('*')) A
    ORDER BY A.ORDINAL_POSITION DESC
    FETCH FIRST 5 ROWS ONLY;

  INSERT INTO APPLIB.HARD_TO_DEBUG_LOCK_PROBLEMS
    SELECT * FROM QSYS2.OBJECT_LOCK_INFO
     WHERE OBJECT_SCHEMA = SCHEMA_NAME AND OBJECT_NAME = TABLE_NAME;
  SET MSG_TOKEN =
	 SCHEMA_NAME CONCAT '.' CONCAT TABLE_NAME CONCAT ' LOCK FAILURE. See APPLIB.HARD_TO_DEBUG_LOCK_PROBLEMS';  
  RESIGNAL SQLSTATE '57033' SET MESSAGE_TEXT = MSG_TOKEN;
  END;

-- Mainline procedure code
update toystore.sales set sales = sales + p_sales
where sales_person = p_person and sales_date = p_date;

end;

--
-- From a different job:
CL:ALCOBJ OBJ((TOYSTORE/SALES *FILE *EXCLRD)) CONFLICT(*RQSRLS);

--
-- Try to update the sales
CALL toystore.update_sales('LUCCHESSI', 14, '1995-12-31');
-- SQL State: 57033 
-- Vendor Code: -438 
-- Message: [SQL0438] TOYSTORE.SALES LOCK FAILURE. See APPLIB.HARD_TO_DEBUG_LOCK_PROBLEMS
 
SELECT * FROM APPLIB.HARD_TO_DEBUG_PROBLEMS;
SELECT * FROM APPLIB.HARD_TO_DEBUG_LOCK_PROBLEMS;



--  category:  IBM i Services
--  description:  Work Management - Open Files
--  minvrm: V7R3M0
--

--
-- Examine the open files in jobs that have pending database changes
--
select job_name, commitment_definition, state_timestamp,o.*
  from qsys2.db_transaction_info d, lateral (
         select *
           from table (
               qsys2.open_files(d.job_name)
             )
       ) o
  where (local_record_changes_pending = 'YES' or
         local_object_changes_pending = 'YES') and
        o.library_name not in ('QSYS', 'QSYS2', 'SYSIBM'); 
        


--  category:  IBM i Services
--  description:  Work Management - Prestart job statistical review

-- Review the prestart job statistics for all active prestart jobs
with pjs (sbslib, sbs, pgmlib, pgm, pj) as (
       -- active subsystems that have prestart jobs
       select subsystem_description_library, subsystem_description,
              prestart_job_program_library, prestart_job_program, prestart_job_name
         from qsys2.prestart_job_info
         where active = 'YES'
     ),
     active_pjs (sbslib, sbs, pgmlib, pgm, pj) as (
       -- active pjs
       select distinct sbslib, sbs, pgmlib, pgm, pj
         from pjs,
              lateral (
                select *
                  from table (
                      qsys2.job_info(
                        job_status_filter => '*ACTIVE', job_subsystem_filter => sbs,
                        job_user_filter => '*ALL')
                    )
                  where job_type_enhanced = 'PRESTART_BATCH'
                        and trim(
                          substr(job_name, locate_in_string(job_name, '/', 1, 2) + 1, 10))
                        = pj
              ) xpj
     )
  -- active pjs and statistics
  select sbslib, sbs, pgmlib, pgm, pj, stat.*
    from active_pjs, lateral (
           select *
             from table (
                 qsys2.prestart_job_statistics(sbs, pgmlib, pgm)
               )
         ) as stat
    order by 1, 2, 3;
         
;
     


--  category:  IBM i Services
--  description:  Work Management - QBATCH routing entries

select sequence_number, program_library, program_name, class_library, class_name,
       comparison_data, comparison_start
  from qsys2.routing_entry_info
  where subsystem_description_library = 'QSYS'
        and subsystem_description = 'QBATCH'
  order by sequence_number;


--  category:  IBM i Services
--  description:  Work Management - QSYSWRK subsystem autostart jobs

select autostart_job_name, job_description_library, job_description
  from qsys2.autostart_job_info
  where subsystem_description_library = 'QSYS'
        and subsystem_description = 'QSYSWRK'
  order by 1, 2, 3;


--  category:  IBM i Services
--  description:  Work Management - QUSRWRK prestart jobs configured with limited reuse

select maximum_uses, pj.*
  from qsys2.prestart_job_info pj
  where subsystem_description_library = 'QSYS'
        and subsystem_description = 'QUSRWRK'
        and pj.maximum_uses <> -1
  order by 1;
                             


--  category:  IBM i Services
--  description:  Work Management - Record lock info

--
-- Review detail about all record locks held over TOYSTORE/EMPLOYEE *FILE
--
WITH LOCK_CONFLICT_TABLE (
  table_name, lock_state, rrn, q_job_name) AS (
SELECT table_name, lock_state, rrn, job_name
FROM QSYS2.RECORD_LOCK_INFO where 
  table_schema = 'TOYSTORE' and 
  table_name = 'EMPLOYEE'
) SELECT table_name, lock_state, rrn, 
         q_job_name, V_SQL_STATEMENT_TEXT, 
         V_CLIENT_IP_ADDRESS, 
         B.* FROM LOCK_CONFLICT_TABLE, 
TABLE(QSYS2.GET_JOB_INFO(q_job_name)) B;



--  category:  IBM i Services
--  description:  Work Management - SET_SERVER_SBS_ROUTING and ad hoc users

--
-- Construct a subsystem that will constrain the amount of system resources
-- available to users who are known to execute ad hoc queries.
--
CL: CRTSBSD SBSD(QGPL/ADHOCSBS) POOLS((1 *BASE)) TEXT('Ad hoc users SBS');
CL: CRTJOBQ QGPL/ADHOCJOBQ TEXT('Ad hoc users job queue');
CL: ADDJOBQE SBSD(QGPL/ADHOCSBS) JOBQ(QGPL/ADHOCJOBQ) MAXACT(100) SEQNBR(40);
CL: CRTCLS CLS(QGPL/ADHOCCLS) RUNPTY(55) TIMESLICE(100) TEXT('Ad hoc class');
CL: ADDPJE SBSD(QGPL/ADHOCSBS) PGM(QSYS/QRWTSRVR) JOBD(QGPL/QDFTSVR) 	CLS(QGPL/ADHOCCLS);
CL: ADDPJE SBSD(QGPL/ADHOCSBS) PGM(QSYS/QZDASOINIT) JOBD(QGPL/QDFTSVR) 	CLS(QGPL/ADHOCCLS);
CL: STRSBS SBSD(QGPL/ADHOCSBS);
--
-- Relocate SCOTT's server jobs to the ADHOCSBS
--
CALL QSYS2.SET_SERVER_SBS_ROUTING('SCOTT','*ALL','ADHOCSBS');

--
-- Review existing configurations for users and groups
--
SELECT * FROM QSYS2.SERVER_SBS_ROUTING;


--  category:  IBM i Services
--  description:  Work Management - Scheduled Job Info

--
-- Example: Review the job scheduled entries which are no longer in effect, either because they 
-- were explicitly held or because they were scheduled to run a single time and the date has 
-- passed.
--
SELECT * FROM QSYS2.SCHEDULED_JOB_INFO  WHERE STATUS IN ('HELD', 'SAVED') ORDER BY SCHEDULED_BY;


--  category:  IBM i Services
--  description:  Work Management - Subsystem pool detail

select subsystem_description_library, subsystem_description, pool_id, pool_name,
       maximum_active_jobs, pool_size
  from qsys2.subsystem_pool_info
  order by pool_id, pool_size desc;


--  category:  IBM i Services
--  description:  Work Management - Subsystem workstation configuration

select subsystem_description_library, subsystem_description, workstation_name,
       workstation_type, job_description_library, job_description, allocation,
       maximum_active_jobs, subsystem_description, workstation_type,
       job_description_library, job_description, allocation, maximum_active_jobs
  from qsys2.workstation_info
  order by subsystem_description_library, subsystem_description;


--  category:  IBM i Services
--  description:  Work Management - System Status

--
-- Return storage and CPU status for the partition. 
-- Specify to reset all the elapsed values to 0.
--
SELECT * FROM TABLE(QSYS2.SYSTEM_STATUS(RESET_STATISTICS=>'YES')) X;

-- deleay 60 seconds
cl: dllyjob dly(60);

--
-- Repeat the query, observing the elapsed detail
-- 
SELECT elapsed_time, elapsed_cpu_used, elapsed_cpu_shared,
   elapsed_cpu_uncapped_capacity, total_jobs_in_system, maximum_jobs_in_system,
   active_jobs_in_system, interactive_jobs_in_system, configured_cpus,
   cpu_sharing_attribute, current_cpu_capacity, average_cpu_rate,
   average_cpu_utilization, minimum_cpu_utilization, maximum_cpu_utilization,
   sql_cpu_utilization, main_storage_size, system_asp_storage, total_auxiliary_storage,
   system_asp_used, current_temporary_storage, maximum_temporary_storage_used,
   permanent_address_rate, temporary_address_rate, temporary_256mb_segments,
   temporary_4gb_segments, permanent_256mb_segments, permanent_4gb_segments, host_name
   FROM TABLE(qsys2.system_status()) x;


--  category:  IBM i Services
--  description:  Work Management - System Status

--
-- Review the ASP consumption vs limit
--
with sysval(low_limit) as (
select current_numeric_value/10000.0 as QSTGLOWLMT
  from qsys2.system_value_info
  where system_value_name = 'QSTGLOWLMT'
)
select SYSTEM_ASP_USED, 
       DEC((100.00 - low_limit),4,2) as SYSTEM_ASP_LIMIT 
from sysval, qsys2.SYSTEM_STATUS_INFO ;
   


--  category:  IBM i Services
--  description:  Work Management - System Status Info Basic
--  minvrm: V7R3M0
--

--
-- Review the ASP consumption vs limit
--
with sysval (low_limit) as (
       select current_numeric_value / 10000.0
         from qsys2.system_value_info
         where system_value_name = 'QSTGLOWLMT'
     ),
     sysval2 (low_limit_action) as (
       select current_character_value
         from qsys2.system_value_info
         where system_value_name = 'QSTGLOWACN'
     )
  select system_asp_used, 
         dec((100.00 - low_limit), 4, 2) as system_asp_limit, 
         low_limit,
         low_limit_action
    from sysval, sysval2, qsys2.system_status_info_basic;


--  category:  IBM i Services
--  description:  Work Management - System Values

-- Note: replace REMOTEPART with the name of the remote partition
--       (WRKRDBDIRE or QSYS2.SYSCATALOGS)

-- Compare System Values across two partitions 
 DECLARE GLOBAL TEMPORARY TABLE SESSION.Remote_System_Values 
 ( SYSTEM_VALUE_NAME,CURRENT_NUMERIC_VALUE,CURRENT_CHARACTER_VALUE ) 
 AS (SELECT * FROM REMOTEPART.QSYS2.SYSTEM_VALUE_INFO) WITH DATA 
 WITH REPLACE; 

-- Use exception join to reveal any differences 
  SELECT 'REMOTEPART' AS "System Name", A.SYSTEM_VALUE_NAME, 
  A.CURRENT_NUMERIC_VALUE,A.CURRENT_CHARACTER_VALUE FROM QSYS2.SYSTEM_VALUE_INFO A 
 LEFT EXCEPTION JOIN SESSION.Remote_System_Values B 
 ON A.SYSTEM_VALUE_NAME = B.SYSTEM_VALUE_NAME AND 
    A.CURRENT_NUMERIC_VALUE IS NOT DISTINCT FROM B.CURRENT_NUMERIC_VALUE AND 
    A.CURRENT_CHARACTER_VALUE IS NOT DISTINCT FROM B.CURRENT_CHARACTER_VALUE 
 UNION ALL 
  SELECT 'LOCALPART' AS "System Name", B.SYSTEM_VALUE_NAME, 
  B.CURRENT_NUMERIC_VALUE, 
  B.CURRENT_CHARACTER_VALUE FROM QSYS2.SYSTEM_VALUE_INFO A 
 RIGHT EXCEPTION JOIN SESSION.Remote_System_Values B 
 ON A.SYSTEM_VALUE_NAME = B.SYSTEM_VALUE_NAME AND 
    A.CURRENT_NUMERIC_VALUE IS NOT DISTINCT FROM B.CURRENT_NUMERIC_VALUE AND 
    A.CURRENT_CHARACTER_VALUE IS NOT DISTINCT FROM B.CURRENT_CHARACTER_VALUE 
 ORDER BY SYSTEM_VALUE_NAME;


--  category:  IBM i Services
--  description:  Work Management - Workload Group Info
--  minvrm: V7R3M0
--

--
-- Review the configured workload groups
--
select *
  from QSYS2.WORKLOAD_GROUP_INFO;

--
-- Review active jobs, that utilize a workload group
--
select w.*, b.*
  from QSYS2.WORKLOAD_GROUP_INFO w, lateral (
         select a.*
           from table (
               qsys2.active_job_info(DETAILED_INFO => 'ALL')
             ) a
           where WORKLOAD_GROUP = w.workload_group
       ) b;


--  category:  IBM-i-Services
--  description:  __ Where to find more detail __

--  Documentation can be found here:
--  --------------------------------
--  https://www.ibm.com/support/knowledgecenter/ssw_ibm_i_73/rzajq/rzajqservicessys.htm
-- 
--  Enabling DB2 PTF Group level and enhancement details can be found here:
--  -----------------------------------------------------------------------
--  https://ibm.biz/DB2foriServices
--
;

