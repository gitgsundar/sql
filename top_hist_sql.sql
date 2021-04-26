set pages 9999 
set verify off
set linesize 200
set pagesize 100

col Instance				heading 'Environment Info' 	format a100
col buffer_gets_total		heading 'Buffer Gets'		format 99999999999
col executions_total		heading 'Executions'		format 99999999999
col sql_id					heading 'Sql_Id'					
col plan_hash_value			heading 'Plan Hash Value'				
col disk_reads_total		heading 'Disk Reads'
col parse_calls				heading 'Parses'			format 99999999999
col version_count			heading 'Versions'
col rows_processed_total 	heading	'Rows'
col spoolfile				heading 'Spool File Name'	format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/top_hist_sql_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

tti off
tti Left 'Top 20 CPU Sqls :' skip 2


SELECT * FROM
(SELECT s.sql_id,round(cpu_time_total/1000000) cpu_time, 
	executions_total, 
	round(cpu_time_total/1000000/decode(nvl(executions_total,0),0,1,executions_total)) "Avg CPU/Exec", plan_hash_value
 FROM dba_hist_sqlstat s,
	   dba_hist_snapshot h
 WHERE round(cpu_time_total/1000000,2) > 10
	and s.snap_id= h.snap_id 
	and begin_interval_time > trunc(sysdate-&ldays)
	and rownum <= 20
 ORDER BY cpu_time DESC)
where rownum < 20
/

tti off
tti Left 'Top 20 LIO Sqls :' skip 2


SELECT * FROM
(SELECT s.sql_id,buffer_gets_total, executions_total, 
	round(buffer_gets_total/decode(nvl(executions_total,0),0,1,executions_total),2) "Avg LIO",plan_hash_value
 FROM dba_hist_sqlstat s,
	   dba_hist_snapshot h
 WHERE buffer_gets_total > 100000
	and s.snap_id=h.snap_id
	and begin_interval_time > trunc(sysdate-&ldays)
	and rownum <= 20
 ORDER BY buffer_gets_total DESC)
where rownum < 20
/

tti off
tti Left 'Top 20 PIO Sqls :' skip 2


SELECT * FROM
(SELECT distinct s.sql_id,disk_reads_total, executions_total, 
	round(disk_reads_total/decode(nvl(executions_total,0),0,1,executions_total),2) "Avg PIO",plan_hash_value
 FROM dba_hist_sqlstat s,
	   dba_hist_snapshot h
 WHERE disk_reads_total > 100000
	and s.snap_id=h.snap_id
	and begin_interval_time > trunc(sysdate-&ldays)
	and rownum <= 20 
 ORDER BY disk_reads_total DESC)
where rownum < 20
/


tti off
tti Left 'Top 20 Elapsed SQLs :' skip 2


SELECT * FROM
(SELECT s.sql_id,round(elapsed_time_total/1000000) cpu_time, 
	executions_total, 
	round(elapsed_time_total/1000000/decode(nvl(executions_total,0),0,1,executions_total)) "Avg Elap/Exec", plan_hash_value
 FROM dba_hist_sqlstat s,
	   dba_hist_snapshot h
 WHERE round(cpu_time_total/1000000,2) > 10
	and s.snap_id= h.snap_id 
	and begin_interval_time > trunc(sysdate-&ldays)
	and rownum <= 20
 ORDER BY cpu_time DESC)
where rownum < 20
/

tti off
tti Left 'Top 20 Executions Sqls :' skip 2


SELECT * FROM
(SELECT distinct s.sql_id,executions_total, rows_processed_total, 
	round(rows_processed_total/decode(nvl(executions_total,0),0,1,executions_total),2) "Rows/Exec",plan_hash_value
 FROM dba_hist_sqlstat s,
	   dba_hist_snapshot h
 WHERE executions_total > 1000
	and s.snap_id=h.snap_id
	and begin_interval_time > trunc(sysdate-&ldays)
 	and rownum <= 20 
ORDER BY executions_total DESC)
where rownum < 20
/

spool off