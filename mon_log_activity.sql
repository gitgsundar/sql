set pages 9999 verify off
col member format a50
col first_change# 																		format 9999999999999999
col activity_date							heading 'Date'							
col switches								heading 'Archives(#)'						format 9999999
col size_in_MB								heading 'Size in MB'						format 999999999
col first_time								heading 'Log Start Time'
col next_time								heading 'Log End Time'
col completion_time							heading 'Arch End Time'
col switch_time								heading 'Time for LogSwitch'
col sequence#								heading 'Log Seq#'
tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Log Buffer Information :' skip 2

show parameter log_buffer

tti off
tti Left 'Log File Information :' skip 2

select * from v$logfile
/

tti off
tti Left 'Log Sequence Information :' skip 2

select * from v$log
/

tti off
tti Left 'Log Activity Information :' skip 2

Accept lstart date format 'mmddyyyy:hh24miss' Prompt 'Enter the Start Date (MMDDYYYY:HH24MISS) for Checking Log Activity : '

Accept lend	  date format 'mmddyyyy:hh24miss' Prompt 'Enter the End Date (MMDDYYYY:HH24MISS) for Checking Log Activity: '   

select sequence#,to_char(first_time,'mm-dd hh24:mi:ss') first_time,
		first_change#,
		to_char(next_time,'mm-dd hh24:mi:ss') next_time,
		next_change#,
		round(mod((next_time-first_time)*24*60,60),2) switch_time,
		round((blocks*block_size)/1024/1024) Size_in_MB, 
		to_char(completion_time,'mm-dd hh24:mi:ss') completion_time
from v$archived_log 
where dest_id=1 and 
		completion_time between to_date('&lstart','MMDDYYYY:HH24MISS') and to_date('&lend','MMDDYYYY:HH24MISS')
order by 1
/

tti off
