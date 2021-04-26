set pages 9999 long 99999 verify off
col Instance						heading "Environment Info"	format a100
col Sql		  						heading "Sql Statement" 	format a60
col Sql_ID							heading "Sql ID"				format a13
col Plan_Hash_Value				heading "Plan Hash Value"	format 999999999999
col timestamp						heading "Timestamp"
col plan_table_output			heading "Execution Plan"

col snap_id							heading "Snap ID"				format 9999999
col begin_interval_time			heading "Time"					format a30
col plan_hash_value				heading "Plan Hash"			format 9999999999999
col profile 	  					heading "Profile"				format a10
col executions_total				heading "Exe"					format 9999
col buffer_gets_total			heading "Buffer"				format 9999999999
col cpu_time_total				heading "CPU"					format 99999.99
col ela_time_total				heading "Ela"					format 99999.99
col disk_reads_total				heading "Disk(R)"				format 9999999999
col iowait_total					heading "IO"					format 99999.99
col rows_processed_total		heading "Rows"					format 9999999999


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lsql_text char Prompt 'Enter the Sql: '

select tf.* 
from dba_hist_sqltext ht, table(dbms_xplan.display_awr(ht.sql_id,null, null, 'ALL' )) tf
where ht.sql_text like '%&lsql_text%'
/

accept lsql_id char prompt 'enter sql id : '

select
  s.snap_id,
  h.begin_interval_time,
  plan_hash_value,
  nvl(sql_profile,'no profile') profile,
  executions_total,
  buffer_gets_total,
  cpu_time_total*power(10,-6) "cpu_time_total",
  elapsed_time_total*power(10,-6) "ela_time_total",
  disk_reads_total "disk_reads_total",
  iowait_total*power(10,-6) "iowait_total",
  rows_processed_total
from
  dba_hist_sqlstat s,
  dba_hist_snapshot h
where sql_id='&lsql_id'
and s.snap_id=h.snap_id
order by 1
/
