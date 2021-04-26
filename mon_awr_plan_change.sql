-- 	File 		:	MON_AWR_PLAN_CHANGE_INFO.SQL
--	Description	:	Provides details AWR (Automatic Workload Repository) Info
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 lines 300 verify off
col snap_interval				heading	'Snap Interaval(Hour)'	format a30
col retention					heading	'Retention(Days)'		format a30
col topnsql						heading 'TopNSql(#)'			format 999,999,999,999,999
col most_recent_purge_time		heading	'Last Purge'			format a30
col BEGIN_INTERVAL_TIME 		heading 'Date/Time'				for a23
col PLAN_HASH_VALUE 			heading 'Plan Hash'			for 9999999999
col date_time 													for a18
col snap_id 					heading 'SnapId'
col executions_delta 			heading 'No. of exec'
col sql_profile 				heading 'SQL|Profile'			for a7
col date_time 					heading 'Date time'
col avg_lio 					heading 'LIO/exec' 				for 9999999999999.99
col avg_cputime 				heading 'CPUTIM/exec' 			for 9999999999999.99
col avg_etime 					heading 'ETIME/exec' 			for 9999999999999.99
col avg_pio 					heading 'PIO/exec' 				for 9999999999999.99
col avg_row 					heading 'ROWs/exec' 			for 99999999999999
col spoolfile					heading 'Spool File Name'		format a150

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_awr_plan_change_info_'||to_char(sysdate,'yyyymmddhh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_id char Prompt 'Enter the Sql ID: '

SELECT distinct s.snap_id ,
		PLAN_HASH_VALUE,
		to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
		SQL.executions_delta,
		SQL.buffer_gets_delta/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_lio,
--SQL.ccwait_delta,
		(SQL.cpu_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_cputime ,
		(SQL.elapsed_time_delta/1000000)/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_etime,
		SQL.DISK_READS_DELTA/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_pio,
		SQL.rows_processed_total/decode(nvl(SQL.executions_delta,0),0,1,SQL.executions_delta) avg_row
--,SQL.sql_profile
FROM
	dba_hist_sqlstat SQL,
	dba_hist_snapshot s
WHERE
	SQL.instance_number = (select instance_number from v$instance)
	and SQL.dbid        = (select dbid from v$database)
	and s.snap_id 		  = SQL.snap_id
	AND sql_id in	('&lsql_id') 
order by s.snap_id
/

spool off