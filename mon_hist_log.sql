-- 	File 		:	MON_HIST_LOG.SQL
--	Description	:	Provides details of Historical Database Log Activity
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col member 					heading "Member"				format a50
col first_change# 			heading "First Change#"			format 9999999999999999
col activity_date			heading 'Date'
col activity_hr				heading 'HH'
col switches				heading 'Archives(#)'			format 9,999,999
col size_in_MB				heading 'Size in MB'			format 999,999,999

tti off

col instance new_value instance
select  instance_name || '_' instance from  sys.v_$instance
/
col spoolfile						heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_hist_log_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/

spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Log File Information :' skip 2

select * from v$logfile
/

tti off
tti Left 'Log Sequence Information :' skip 2

select * from v$log
/

Accept lstart date format 'mmddyyyy' Prompt 'Enter the Start Date (MMDDYYYY) for Checking Log Activity : '
Accept lend	  date format 'mmddyyyy' Prompt 'Enter the End Date (MMDDYYYY) for Checking Log Activity: '   

tti off
tti Left 'By Hour Log Activity Information:' skip 2

select to_char(completion_time,'MM-DD-YYYY') activity_date, 
	   to_char(completion_time,'HH24') activity_hr, count(*) switches, 
		round(sum(blocks*block_size)/1024/1024) Size_in_MB
from v$archived_log 
where dest_id=1 and 
		completion_time between to_date('&lstart','MMDDYYYY') and to_date('&lend','MMDDYYYY')
group by to_char(completion_time,'MM-DD-YYYY'), to_char(completion_time,'HH24') 
order by to_char(completion_time,'MM-DD-YYYY'), to_char(completion_time,'HH24') 
/

tti off
tti Left 'By Day Log Activity Information:' skip 2

select to_char(completion_time,'MM-DD-YYYY') activity_date,count(*) switches, 
		round(sum(blocks*block_size)/1024/1024) Size_in_MB
from v$archived_log 
where dest_id=1 and 
		completion_time between to_date('&lstart','MMDDYYYY') and to_date('&lend','MMDDYYYY')
group by to_char(completion_time,'MM-DD-YYYY')
order by to_char(completion_time,'MM-DD-YYYY')
/

tti off
spool off
