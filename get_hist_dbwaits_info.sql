-- 	File 		:	GET_HIST_DBWAITS_INFO.SQL
--	Description	:	Provides details of Historical DBWaits
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col Event						heading "Event"						format a60
col Waits						heading "Waits #"					format 99999999999
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
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_dbwaits_info_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '
Accept ltop number Prompt 'Top ? Wait Events: '

tti off
tti Left 'Historical Wait Event Details :' skip 2

select  e.event_name event, 
	e.total_waits waits,
	round(e.time_waited_micro /1000000) time,
	e.wait_class waitclass
from
	dba_hist_system_event e ,
	dba_hist_snapshot     h
where e.snap_id     = h.snap_id
  and nvl(e.total_waits,0) > 0
  and e.wait_class <> 'Idle'
  and h.begin_interval_time > trunc(sysdate-&ldays)
  and rownum < &ltop + 1  
order by time desc
/

tti off

spool off