-- 	File 		:	GET_SESSION_TRACE_INFO.SQL
--	Description	:	Enable Session Level Tracing for a specific Session.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance			heading 'Environment Info'	format a100
col sid  				heading	'Sid'				format 999999
col serial#  			heading	'Serial#'			format 999999
col username 			heading	'Username'			format a15
col program  			heading	'Program'			format a30
col event    			heading	'Event'				format a50
col status				heading	'Status'		
col logon_time			heading	'Logon Time'		
col shadow_process		heading	'Shadow Process'
col client_process		heading	'Client Process'
col trace_disable		heading 'Disable Trace using below'	format a150
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_session_trace_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsid number Prompt 'Session SID : '
Accept lserial number Prompt 'Session Serial#: '

tti Left 'Session Information :' skip 2

select s.sid sid,s.serial# serial#,s.status status,s.logon_time, p.spid Shadow_process, s.process Client_process,s.username,s.program 
from v$session s, v$process p
where s.paddr = p.addr and
		s.sid   = '&lsid' and
		s.serial# = '&lserial'
/

tti off
tti Left 'Session Event Information :' skip 2

select event,total_waits,total_timeouts from v$session_event 
where sid = '&lsid'
order by 2 desc
/

tti off
tti Left 'Session I/O Information :' skip 2

select * from v$sess_io 
where sid = '&lsid'
/

tti off
tti Left 'Session Wait Information :' skip 2

select * from v$session_wait 
where sid = '&lsid'
/

tti off
tti Left 'Long Operations Information :' skip 2

select * from v$session_longops 
where sid = '&lsid' and 
      serial# = '&lserial'
order by last_update_time desc
/

tti off
tti Left 'Complete SQL Text Information :' skip 2

select sql_text
from v$sqltext
where sql_id ='&lsid'
order by piece
/

tti off
tti Left 'Enabling Trace :' skip 2

begin
	sys.dbms_monitor.session_trace_enable(&lsid,&lserial,TRUE,TRUE);
end;
/

select 'Dont forget to Disable Trace using sys.dbms_monitor.session_trace_disable('||&lsid||','||&lserial||');' trace_disable from dual
/


tti off
spool off