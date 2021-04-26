clear columns
set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col cela					heading 'Current|ELA(sec)'
col oela					heading 'Old|ELA(sec)'
col sql_profile 			heading 'SQL|Profile'			for a7
col last_active_time 		heading 'Active Date'
col parsing_schema_name		heading 'Schema'					
col date_time 				heaind  'Date/Time'				for a18
col snap_id 				heading 'SnapId'
col executions_delta 		heading 'No. of exec'
col sql_profile 			heading 'SQL|Profile'			for a7
col date_time 				heading 'Date time'
col avg_lio 				heading 'LIO/exec' 				for 99999999999.99
col avg_cputime 			heading 'CPUTIM/exec' 			for 9999999.99
col avg_etime 				heading 'ETIME/exec' 			for 9999999.99
col avg_pio 				heading 'PIO/exec' 				for 9999999.99
col avg_row 				heading 'ROWs/exec' 			for 9999999.99

tti off
col spoolfile				heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_awr_plan_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldate date format 'mmddyyyy:hh24miss' Prompt 'Enter the Start Date (MMDDYYYY:HH24MISS) for Checking PlanChange Activity : '

SELECT distinct s.snap_id ,
		to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
		sql.sql_id,
		a.plan_hash_value "Current Plan",
		sql.PLAN_HASH_VALUE "Old Plan",
		SQL.executions_delta,
		SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio,
		(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime ,
		(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime,
		SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
		SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_row,
		SQL.sql_profile
FROM	v$sql a,
		dba_hist_sqlstat SQL,
		dba_hist_snapshot s
WHERE
	SQL.instance_number     = (select instance_number from v$instance)
	and SQL.dbid            = (select dbid from v$database)
	and s.snap_id 				= SQL.snap_id
	and a.sql_id				= sql.sql_id
	and a.plan_hash_value  != sql.plan_hash_value
	and (a.elapsed_time*power(10,-6)) - (sql.elapsed_time_delta*power(10,-6)) > 1
	and s.begin_interval_time > to_date('&ldate','MMDDYYYY:HH24MISS') 
order by s.snap_id
/


spool off