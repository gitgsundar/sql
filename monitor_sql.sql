-- 	File 		:	MONITOR_SQL.SQL
--	Description	:	Provides details SQL Monitor Information
--	Info		:	Update Spool information as required to get the spool output.

set long 99999 pages 9999 verify off lines 10000
col Instance					heading "Environment Info"	format a100
col	sid					heading "Sid"
col serial#					heading "Serial#"
col username 					heading "Username"		format a15
col sql_text					heading "Sql Statement" 	format a50
col hash_value				    	heading "Hash Value"		format 99999999999
col plan_hash_value				heading "Plan Hash Value"	format 99999999999
col sql_profile					heading "Sql Profile"		format a30
col sql_id					heading "Sql ID"		format a15
col logon_time					heading "Logon Time-Stamp"
col status					heading "Status"		format a15
col executions  				heading "Exe(#)" 		format 9999999999
col buffer_gets  				heading "LI/O(#)" 		format 9999999999
col disk_reads  				heading "PI/O(#)" 		format 9999999999
col sorts					heading "Sorts"			format 999999
col parse_calls					heading "Parse(#)" 		format 999999
col Invalidations  				heading "Invalid(#)" 		format 999999
col version_count				heading "Child Cursors"		format 999999
col cpu_time					heading "CPU Time(s)"		format 9999999999
col elapsed_time				heading "Elapsed(s)"		format 999999
col rows_processed				heading "Rows(#)"		format 999999
col loads					heading "Loads(#)"		format 999999
col name					heading "Bind Variable"		format a30
col value_string				heading "Bind Value"		format a50
col child_number				heading "Child#"
col wait_class					heading "Wait Class"		format a30
col event					heading "Event"			format a40
col cnt						heading "Count"			format 999999999

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'monitor_sql_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Current Long Running SQLs :' skip 2

select sid, username, sql_id, sql_plan_hash_value plan_hash_value, elapsed_time/1000000 elapsed_time, 
			cpu_time/1000000 cpu_time, buffer_gets, disk_reads, substr(sql_text,1,50) sql_text
from v$sql_monitor
where status = 'EXECUTING'
/

Accept lsql_id char Prompt 'Enter Sql ID for further Analysis: '

tti off
tti Left 'SQL Monitoring Report :' skip 2

SET LONG 1000000
SET LONGCHUNKSIZE 10000000
SET LINESIZE 32767
SET PAGESIZE 0
SET TRIM ON
SET TRIMSPOOL ON
SET ECHO OFF
SET FEEDBACK OFF

SELECT DBMS_SQLTUNE.report_sql_monitor(sql_id => '&lsql_id', type => 'TEXT') AS report FROM dual
/
tti off 
tti Left 'Wait Events for the Specific Sql ID :' skip 2

SET FEEDBACK ON HEADING ON pages 9999
SELECT NVL(wait_class,'CPU') AS wait_class, NVL(event,'CPU') AS event, COUNT(*) cnt
FROM v$active_session_history a
WHERE sql_id = '&lsql_id'
GROUP BY wait_class, event
/

tti off 
spool off
