clear columns
set pages 9999 lines 300 verify off
col Instance			heading "Environment Info"	format a100
col sql_id				heading 'SQL Id'			for a13
col plan_hash_value		heading 'Plan Hash#'		for 9999999999999
col executions_total	heading '# exec'			for 99999999
col date_time 			heading 'Date time'
col rows_avg 			heading 'ROWs/exec' 		for 99999999999.99
col buffer_gets_avg		heading 'LIO/exec' 			for 99999999999.99
col disk_reads_avg		heading 'PIO/exec' 			for 99999999999.99
col cpu_time_avg 		heading 'CPUTIM/exec' 		for 9999999.99
col elapsed_time_avg	heading 'ETIME/exec' 		for 9999999.99

tti off
col spoolfile			heading 'Spool File Name'	format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_awr_sql_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldays number Prompt 'How many days back we want to go: '
Accept ltime number Prompt 'What Avg Execution Time (in Sec) we want to check: '

select sql_id,  plan_hash_value,  executions_total,
	to_char(s.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24mi')|| to_char(s.END_INTERVAL_TIME,'_hh24mi') Date_Time,
	trunc(decode(executions_total, 0, 0, rows_processed_total/executions_total)) 			rows_avg,
	trunc(decode(executions_total, 0, 0, elapsed_time_total*power(10,-6)/executions_total)) 	elapsed_time_avg,
	trunc(decode(executions_total, 0, 0, cpu_time_total*power(10,-6)/executions_total)) 		cpu_time_avg,
--	trunc(decode(executions_total, 0, 0, fetches_total/executions_total)) 				fetches_avg,
	trunc(decode(executions_total, 0, 0, disk_reads_total/executions_total)) 			disk_reads_avg,
	trunc(decode(executions_total, 0, 0, buffer_gets_total/executions_total)) 			buffer_gets_avg,
	trunc(decode(executions_total, 0, 0, iowait_total/executions_total)) 				iowait_time_avg,
	trunc(decode(executions_total, 0, 0, clwait_total/executions_total)) 				clwait_time_avg,
	trunc(decode(executions_total, 0, 0, apwait_total/executions_total)) 				apwait_time_avg,
	trunc(decode(executions_total, 0, 0, ccwait_total/executions_total)) 				ccwait_time_avg,
	trunc(decode(executions_total, 0, 0, plsexec_time_total*power(10,-6)/executions_total)) 	plsexec_time_avg,
	trunc(decode(executions_total, 0, 0, javexec_time_total*power(10,-6)/executions_total)) 	javexec_time_avg
from dba_hist_sqlstat  h,
     dba_hist_snapshot s
where s.snap_id=h.snap_id
	and begin_interval_time > trunc(sysdate-&ldays)
	and parsing_schema_name not in ('SYS','SYSTEM','SYSAUX')
	and trunc(decode(executions_total, 0, 0, elapsed_time_total*power(10,-6)/executions_total)) > &ltime
order by elapsed_time_avg;

spool off