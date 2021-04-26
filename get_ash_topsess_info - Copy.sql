-- 	File 		:	GET_ASH_TOPSESS_INFO.SQL
--	Description	:	Provides details of Top Sessions from ASH.
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col SID						heading 'SID'					for 99999999
col serial#					heading 'Serial#'				for 99999999
col NAME					heading 'User'					for a15
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

select 
	 decode(nvl(to_char(s.sid),-1),-1,'DISCONNECTED','CONNECTED') "STATUS", 
	 topsession.sid             "SID", 
	 topsession.serial#			"SERIAL#",
	 u.username  				"NAME", 
	 topsession.program         "PROGRAM", 
	 max(topsession.CPU)        "CPU", 
	 max(topsession.WAIT)       "WAITING", 
	 max(topsession.IO)         "IO", 
	 max(topsession.TOTAL)      "TOTAL" 
	 from ( 
select * from ( 
select 
	ash.session_id sid, 
	ash.session_serial# serial#, 
	ash.user_id user_id, 
	ash.program, 
	sum(decode(ash.session_state,'ON CPU',1,0))     "CPU", 
	sum(decode(ash.session_state,'WAITING',1,0))    - 
	sum(decode(ash.session_state,'WAITING',decode(wait_class,'User I/O',1, 0 ), 0))    "WAIT" , 
	sum(decode(ash.session_state,'WAITING',decode(wait_class,'User I/O',1, 0 ), 0))    "IO" , 
	sum(decode(session_state,'ON CPU',1,1))     "TOTAL" 
from v$active_session_history ash 
group by session_id,user_id,session_serial#,program 
order by sum(decode(session_state,'ON CPU',1,1)) desc 
) where rownum < 10 
)    topsession, 
	 v$session s, 
	 all_users u 
where 
	 u.user_id =topsession.user_id and 
	 /* outer join to v$session because the session might be disconnected */ 
	 topsession.sid         = s.sid         (+) and 
	 topsession.serial# = s.serial#   (+) 
group by  topsession.sid, topsession.serial#, 
		  topsession.user_id, topsession.program, s.username, 
		  s.sid,s.paddr,u.username 
order by max(topsession.TOTAL) desc 
/ 

spool off