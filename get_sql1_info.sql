-- 	File 		:	GET_SQL1_INFO.SQL
--	Description	:	Provides Details of SQL based on SQL Text.
--	Info		:	Update Spool information as required to get the spool output.

set long 99999 pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col sql_fulltext				heading "Sql Statement" 	format a1000
col hash_value				    heading "Hash Value"		format 99999999999
col plan_hash_value				heading "Plan Hash Value"	format 99999999999
col sql_profile					heading "Sql Profile"		format a30
col sql_id						heading "Sql ID"			format a15
col executions  				heading "Exe(#)" 			format 999999
col buffer_gets  				heading "Avg LI/O(#)" 		format 9999999999
col disk_reads  				heading "Avg PI/O(#)" 		format 999999
col sorts						heading "Sorts"				format 999999
col parse_calls					heading "Parse(#)" 			format 999999
col Invalidations  				heading "Invalid(#)" 		format 999999
col version_count				heading "Child Cursors"		format 999999
col cpu_time					heading "Avg CPU Time(s)"	format 999999
col elapsed_time				heading "Elapsed(s)"		format 999999
col rows_processed				heading "Rows(#)"			format 999999
col loads						heading "Loads(#)"			format 999999
col name						heading "Bind Variable"		format a30
col value_string				heading "Bind Value"		format a50
col spoolfile					heading 'Spool File Name'		format a150

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_sql1_info_'||to_char(sysdate,'yyyymmddhh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_text char Prompt 'Enter the Sql : '

select sql_fulltext Sql,hash_value,plan_hash_value,sql_id,version_count 
from v$sqlarea_plan_hash 
where sql_text like '%&lsql_text%' and upper(sql_text) not like '%EXPLAIN%'
/

select sql_id, plan_hash_value,nvl(sql_profile,'None') sql_profile,buffer_gets,disk_reads,sorts,parse_calls,executions,invalidations,round(cpu_time/1000000) cpu_time,round(elapsed_time/1000000) elapsed_time,rows_processed,loads
from v$sqlarea_plan_hash
where sql_text like '%&lsql_text%' and upper(sql_text) not like '%EXPLAIN%'
and address not in (select sql_address from v$session where sid in (select sid from v$mystat))
/

Accept lsql_id char Prompt 'Enter Sql ID : '

select sql_id, child_number, plan_hash_value plan_hash, last_active_time,executions,
	(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) Elapsed_time,
	disk_reads/decode(nvl(executions,0),0,1,executions) Disk_reads,
	buffer_gets/decode(nvl(executions,0),0,1,executions) Buffer_gets,
	(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) cpu_time
	,sql_text
	,address,child_address
from v$sql s
where sql_id = '&lsql_id'
order by 1, 2, 3
/

tti off
tti Left 'SQL Bind Information :' skip 2

select s.sql_id
	, c.bind_vars
	, b.datatype
	, b.value
	,address,child_address
from v$sql s, v$sql_bind_data b, v$sql_cursor c
where s.sql_id  = '&lsql_id'
  and s.address = c.parent_handle
  and c.curno   = b.cursor_num
/

tti off

select t.* 
from v$sql s, table(dbms_xplan.display_cursor(s.sql_id,s.child_number)) t
where s.sql_id = '&lsql_id'  
/

-- select name,value_string from dba_hist_sqlbind where sql_id='&lsql_id'
-- /
spool off