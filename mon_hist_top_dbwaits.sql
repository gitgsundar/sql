set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col Event						heading "Event"						format a60
col Waits						heading "Waits #"					format 99999999999
col btime						heading "Date"
col time		  				heading "Time(S)"					format 99999999999
col waitclass	 				heading "Wait Class"				format a20
col spoolfile					heading 'Spool File Name'			format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_hist_top_dbwaits_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information by Day : '
Accept ltop number Prompt 'Top ? Wait Events: '

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
	and s.begin_interval_time > trunc(sysdate-&ldays)         
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
tti Left 'Historical Wait Event Details by Day:' skip 2

break on btime skip 1
select distinct btime, event, sum(avg_ms) time
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
			and s.begin_interval_time > trunc(sysdate-&ldays)         
		order by begin_interval_time
	)
	where round((time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0),3) > 5
	order by btime
)
having nvl(sum(avg_ms),0) != 0
group by btime,event
order by btime,3
/

tti off
spool off