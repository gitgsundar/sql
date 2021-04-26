-- 	File 		:	MON_LOG_DAY.SQL
--	Description	:	Provides details of Database Log Activity
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col member 					heading "Member"				format a50
col first_change# 			heading "First Change#"			format 9999999999999999
col activity_date			heading 'Date'							
col switches				heading 'Archives(#)'			format 9999999
col size_in_MB				heading 'Size in MB'			format 999999999


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

select trunc(completion_time) activity_date,round(sum(blocks*block_size)/1024/1024) Size_in_MB
from v$archived_log 
where dest_id=1
group by trunc(completion_time)
order by 2
/

Accept lstart date format 'mmddyyyy' Prompt 'Enter the Start Date (MMDDYYYY) for Checking Log Activity : '
Accept lend	  date format 'mmddyyyy' Prompt 'Enter the End Date (MMDDYYYY) for Checking Log Activity: '   

select trunc(completion_time,'HH') activity_date, count(*) switches, 
		round(sum(blocks*block_size)/1024/1024) Size_in_MB
from v$archived_log 
where dest_id=1 and 
		completion_time between to_date('&lstart','MMDDYYYY') and to_date('&lend','MMDDYYYY')
group by trunc(completion_time,'HH')
order by 3
/

tti off
clear columns
