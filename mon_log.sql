-- 	File 		:	MON_LOG.SQL
--	Description	:	Monitor Database Log Activity
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col member format a50
col first_change# 				heading 'First SCN'			format 9999999999999999
col next_change# 				heading 'Last SCN'			format 9999999999999999
col first_time					heading 'First SCN Time'
col next_time					heading 'Last SCN Time'
col activity_date				heading 'Date'							
col switches					heading 'Archives(#)'		format 9999999
col size_in_MB					heading 'Size in MB'		format 999999999
col dest_id						heading 'Dest ID'			format 9999999
col	group#						heading 'Grp'				format 999
col thread#						heading 'Thr'				format 999
col sequence#					heading 'Seq'				format 99999999
col bytes						heading 'Bytes'				format 999,999,999,999
col blocksize					heading 'Blk'
col Members						heading 'Mem'				format 999
col Status						heading 'Status'			format a10
col archived_date				heading 'Archived Date'	
col member						heading 'Logfile Name'		format a50
col switch_time					heading 'Switch Time'
col switches					heading 'Switches'			
col	log_mode					heading 'Log Mode'			
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_log_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Log Buffer Activity :' skip 2

show parameter log_buffer

tti off
tti Left 'Log File Information :' skip 2

select * from v$logfile
/

tti off
tti Left 'Online Redo Log - ORL Information :' skip 2

select * from v$log
/

tti off
tti Left 'Log Mode Information :' skip 2

select log_mode from v$database;

tti off
tti Left 'Log Switch Information :' skip 2

select trunc(first_time,'HH') switch_time ,count(*) switches
from v$log_history 
where trunc(first_time) > sysdate -1 
group by trunc(first_time,'HH') 
order by 1
/


tti off
tti Left 'Standby Redo Log - SRL Information :' skip 2

select * 
from v$standby_log
/

tti off
tti Left 'Past 1 Week Log Activity Information :' skip 2

select trunc(completion_time) activity_date, count(*) switches, 
		round(sum(blocks*block_size)/1024/1024) Size_in_MB
from gv$archived_log 
where dest_id=1
	and completion_time > sysdate -7
group by trunc(completion_time)
order by 1
/

tti off
tti Left 'Past 6Hrs Archive Activity Information :' skip 2

select dest_id, sequence# log_seq, archived, standby_dest, applied, completion_time archived_date
from v$archived_log 
where completion_time > sysdate - 6/24 
order by completion_time
/

tti off
tti Left 'Log Received-Apply on DR Info:' skip 2


select al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied"
from (select thread# thrd, max(sequence#) almax
  	   from v$archived_log
  	   where resetlogs_change#=(select resetlogs_change# from v$database)
  	   group by thread#) al,
  	  (select thread# thrd, max(sequence#) lhmax
  	   from v$log_history
  	   where resetlogs_change#=(select resetlogs_change# from v$database)
  	   group by thread#) lh
where al.thrd = lh.thrd
/

spool off