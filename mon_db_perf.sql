-- 	File 		:	MON_DB_PERF.SQL
--	Description	:	Monitor Database Performance.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading 'Environment Info'			for a100
col host_name 				heading 'HostName'					for a20
col instance_name			heading 'Instance Name'				for a15
col metric_name				heading 'Metric'					for a50
col wait_class				heading 'Wait Class'				for	a20
col total_waits				heading 'Total Waits'				for 999,999,999,999,999
col pct_totwaits			heading 'Total Waits(%)'			for 99999.99
col tot_time_waited			heading 'Total Waits(s)'			for 999,999,999,999,999.99
col time_waited				heading	'Total Waits(s)'			for 999,999,999,999,999.99
col pct_time				heading 'Time (%)'					for 99999.99
col event					heading 'Event'						for a60
col version 				heading 'Version'					for a12
col role 					heading 'DB Role'					for a18 
col sql_text 				heading 'Sql Text'					for a100 Wrap

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile				heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_db_perf_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'DB Performance :' skip 2

select metric_name, value
from v$sysmetric
where metric_name in ('Database CPU Time Ratio',
		'Database Wait Time Ratio') AND
	intsize_csec =(select max(intsize_csec) from v$sysmetric)
/

tti off
tti Left 'Top Wait Class and its Percentages :' skip 2

select wait_class,
	total_waits,
	round(100 * (total_waits / sum_waits),2) pct_totwaits,
	round((time_waited / 100),2) tot_time_waited,
	round(100 * (time_waited / sum_time),2) pct_time
from
	(select wait_class,
	total_waits,
	time_waited
	from v$system_wait_class
	where wait_class != 'Idle'),
	(select sum(total_waits) sum_waits,
	sum(time_waited) sum_time
	from v$system_wait_class
	where wait_class != 'Idle')
order by pct_time desc
/

tti off
tti Left 'Top Events with waits > 60(s) :' skip 2

select EVENT, TOTAL_WAITS, round((time_waited / 100),2) tot_time_waited, WAIT_CLASS 
from V$SYSTEM_EVENT
where wait_class != 'Idle'
  and time_waited > 6000
order by time_waited desc
/

tti off
tti Left 'Top Sessions with waits > 60(s) :' skip 2

select sid, event, total_waits, time_waited, wait_class
from v$session_event
where wait_class != 'Idle'
  and time_waited > 6000
order by time_waited
/

tti off
tti Left 'Top Waits in the last 15min :' skip 2

select a.event, sum(a.wait_time + a.time_waited) tot_time_waited
from v$active_session_history a
where a.sample_time between sysdate - 15/1440 and sysdate
group by a.event
having sum(a.wait_time + a.time_waited) > 60
order by tot_time_waited desc
/

tti off
tti Left 'Top Users with most Waits in the last 15min :' skip 2

select s.sid, s.username, sum(a.wait_time + a.time_waited) tot_time_waited
from v$active_session_history a,
	v$session s
where a.sample_time between sysdate - 15/1440 and sysdate
	and a.session_id=s.sid
group by s.sid, s.username
having sum(a.wait_time + a.time_waited) > 60
order by tot_time_waited desc
/

tti off
tti Left 'Top SQLs with most Waits in the last 15min :' skip 2

select d.username,s.sql_text,sum(a.wait_time + a.time_waited) tot_time_waited
from v$active_session_history a,
	v$sqlarea s,
	dba_users d
where a.sample_time between sysdate - 15/1440 and sysdate
	and a.sql_id  = s.sql_id
	and a.user_id = d.user_id
group by s.sql_text, d.username
having sum(a.wait_time + a.time_waited) > 60
order by tot_time_waited desc
/

tti off
spool off