-- 	File 		:	MON_HIS_DBWAIT1.SQL
--	Description	:	Monitor History Waits for Specific Time
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col Event						heading "Event"						format a60
col Waits						heading "Waits #"					format 99999999999
col btime						heading "Date"
col time		  				heading "Time(S)"					format 99999999999
col waitclass	 				heading "Wait Class"				format a20
col spoolfile					heading 'Spool File Name'			format a150

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_hist_dbwait1_'||'&instance'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile

tti Left 'Instance Information :' skip 2
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lstart date format 'mmddyyyy:hh24miss' Prompt 'Enter the Start Date (MMDDYYYY:HH24MISS) for Checking Wait Activity : '
Accept lend	  date format 'mmddyyyy:hh24miss' Prompt 'Enter the End Date (MMDDYYYY:HH24MISS) for Checking Wait Activity: '   
Accept ltop number Prompt 'Number of Top Wait Events: '

tti off
tti Left 'Top Wait Events :' skip 2

select event, time from 
(
select distinct event, sum(avg_ms) time
from 
(
select
       btime,
       event,
       round((time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0),3) avg_ms
from (
select
       to_char(s.BEGIN_INTERVAL_TIME,'DD-MON-YY')  btime,
       e.event_name event,
       total_waits count_end,
       time_waited_micro/1000 time_ms_end,
       Lag (e.time_waited_micro/1000) OVER( PARTITION BY e.event_name ORDER BY s.snap_id) time_ms_beg,
       Lag (e.total_waits)            OVER( PARTITION BY e.event_name ORDER BY s.snap_id) count_beg
from
       DBA_HIST_SYSTEM_EVENT e,
       DBA_HIST_SNAPSHOT s
where
         s.snap_id=e.snap_id
	and e.wait_class <> 'Idle'
	and s.begin_interval_time between to_date('&lstart','MMDDYYYY:HH24MISS') and to_date('&lend','MMDDYYYY:HH24MISS')
order by begin_interval_time
)
order by btime
)
having nvl(sum(avg_ms),0) > 0
group by event
order by 2 desc)
where rownum < &ltop +1 
/

tti off
spool off