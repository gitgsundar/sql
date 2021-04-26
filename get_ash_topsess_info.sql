-- 	File 		:	GET_ASH_TOPSESS_INFO.SQL
--	Description	:	Provides details of Top Sessions from ASH.
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col SID						heading 'SID'					for 99999999
col serial#					heading 'Serial#'				for 99999999
col NAME					heading 'User'					for a15
col ttl_wait_time_in_minutes heading 'TTL (min)'			for 99,999.99
col PROGRAM					heading 'Program'				for a45
col	STATUS					heading 'Status'				for a15
col WAITING 				heading 'Wait#'					for 999999999999
col cpu						heading 'CPU Wait#'				for 999999999999
col IO						heading 'IO Wait#'				for 999999999999
col total					heading 'Total Wait#'			for 999999999999
col client_id				heading 'Client Info'			for a20
col machine 				heading 'Machine'			    for a15

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile 				new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ash_topsess_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Top Sessions :' skip 2

select s.sid,s.serial#,
	s.username name,
	sum(ash.wait_time + ash.time_waited)/1000000/60 ttl_wait_time_in_minutes,
	s.sql_id
--	decode(nvl(to_char(s.sid),-1),-1,'DISCONNECTED','CONNECTED') "STATUS"
from v$active_session_history ash, v$session s
where sample_time between sysdate - 60/2880 and sysdate
	and ash.session_id = s.sid
	and username is not null
	group by s.sid, s.serial#, s.username, s.sql_id
order by 4 desc
/

spool off