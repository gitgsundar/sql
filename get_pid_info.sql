-- 	File 		:	GET_PID_INFO.SQL
--	Description	:	Provides details of Client Session based on PID.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance			heading 	'Environment Info'	format a100
col sid  				heading	'Sid'					format 999999
col serial#  			heading	'Serial#'				format 999999
col username 			heading	'Username'				format a15
col program  			heading	'Program'				format a30
col event    			heading	'Event'					format a30
col status				heading	'Status'		
col logon_time			heading	'Logon Time'	
col machine				heading  'Machine'				format a30
col shadow_process		heading	'Shadow Process'
col client_process		heading	'Client Process'
col action 				heading 'Action'
col p1text				heading 'First Wait Event'		format a30
col p2text				heading 'Second Wait Event'		format a30
col p3text				heading 'Third Wait Event'		format a30
col seconds_in_wait		heading	'Time(s)'				format 999,999,999
col state				heading	'Status'

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'	format a150
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_pid_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lpid char Prompt 'Enter the Client OS Pid : '

tti Left 'Session Information :' skip 2

select s.sid sid,s.serial# serial#,s.status status,s.logon_time, p.spid Shadow_process, s.process Client_process, machine, s.username,s.program,s.action 
from v$session s, v$process p
where s.paddr = p.addr and
   s.process  = '&lpid';

tti off
tti Left 'Transaction Information :' skip 2

select used_ublk,used_urec,log_io,phy_io,status from v$transaction 
where addr in (select taddr from v$session s where s.process='&lpid')
/

tti off
tti Left 'Session Event Information :' skip 2

select event,total_waits,total_timeouts from v$session_event 
where sid in (select sid from v$session s where s.process='&lpid')
order by 2 desc
/

tti off
tti Left 'Session I/O Information :' skip 2

select * from v$sess_io 
where sid in (select sid from v$session s where s.process='&lpid')
/

tti off
tti Left 'Session Wait Information :' skip 2

select Event,p1text,nvl(p2text,'None') p2text,nvl(p3text,'None') p3text,seconds_in_wait,state from v$session_wait 
where sid in (select sid from v$session s where s.process='&lpid')
/


tti off
tti Left 'Long Operations Information :' skip 2

select * from v$session_longops 
where sid in (select sid from v$session s where s.process='&lpid')
   and serial# in (select serial# from v$session s where s.process='&lpid')
order by last_update_time desc
/

tti off
tti Left 'Complete SQL Text Information :' skip 2

select sql_text
from v$sqltext
where hash_value in (select sql_hash_value from v$session s where s.process='&lpid')
order by piece
/
spool off