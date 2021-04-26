-- 	File 		:	GET_HIST_SQLDETAIL_INFO.SQL
--	Description	:	Provides details of Historical Database File IO Stats
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col Sql		  					heading "Sql Statement" 			format a60
col Sql_ID						heading "Sql ID"					format a13
col Plan_Hash_Value				heading "Plan Hash Value"			format 999999999999
col timestamp					heading "Exe Plan First Produced"	format a30
col plan_table_output			heading "Execution Plan"
col snap_id						heading "Snap ID"					format 9999999
col begin_interval_time			heading "Time"						format a30
col plan_hash_value				heading "Plan Hash"					format 9999999999999
col profile 	  				heading "Profile"					format a30
col executions_total			heading "Exe #"						format 9999999999
col buffer_gets_total			heading "Buffer(LIO)"				format 9999999999
col cpu_time_total				heading "CPU"						format 99999.99
col ela_time_total				heading "Ela"						format 999,999,999.99
col disk_reads_total			heading "Disk(PIO)"					format 9999999999
col iowait_total				heading "IO-Wait"					format 99999.99
col rows_processed_total		heading "Rows"						format 9999999999

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_sqldetail_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

Accept lsql_id char Prompt 'Enter the Sql ID: '

tti off
tti Left 'Execution Details :' skip 2

select
  s.snap_id,
  h.begin_interval_time,
  s.sql_id,
  plan_hash_value,
  nvl(sql_profile,'No Profile') profile,
  executions_total,
  cpu_time_total*power(10,-6) "cpu_time_total",
  elapsed_time_total*power(10,-6) "ela_time_total",
  iowait_total*power(10,-6) "iowait_total",
  buffer_gets_total,
  disk_reads_total "disk_reads_total",
  rows_processed_total
from
  dba_hist_sqlstat s,
  dba_hist_snapshot h
where s.sql_id='&lsql_id'
and s.snap_id=h.snap_id
and begin_interval_time > trunc(sysdate-&ldays)
order by 2,4
/

tti off
tti Left 'SQL Details :' skip 2

select sql_text Sql 
from dba_hist_sqltext 
where sql_id='&lsql_id'
/

tti off
tti Left 'Plan Details :' skip 2

select distinct sql_id Sql_ID, PLAN_HASH_VALUE Plan_Hash_Value, to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') timestamp
from DBA_HIST_SQL_PLAN 
where sql_id= '&lsql_id'
order by timestamp
/

SELECT tf.* 
FROM DBA_HIST_SQLTEXT ht, table(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf
WHERE ht.sql_id='&lsql_id'
/

tti off
tti Left 'Bind Value Details :' skip 2

select name,value_string from dba_hist_sqlbind where sql_id='&lsql_id'
/

spool off