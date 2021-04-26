-- 	File 		:	MON_RMAN.SQL
--	Description	:	Monitor RMAN Jobs Running 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
col Instance			heading 'Environment Info'	format a100
col name				heading	'Configuration'		format a30
col sid  				heading	'Sid'				format 999999
col spid				heading 'SPid'				format 999999
col client_info			heading 'RMAN Info'			format a80
col serial#  			heading	'Serial#'			format 999999
col sofar				heading 'Sofar'				format 999999999
col totalwork			heading 'Totalwork'			format 999999999
col %_complete			heading	'% Complete'		format 99.99
col event				heading	'Wait Event'		format a30
col sec_wait			heading	'Wait(s)'			format 999999
col program  			heading 'Program'			format a50	
col idle				heading "Idle"				format a15
col logon_time			heading "Logon Time"		format a25
col status				heading "Status"			format a10

col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_rman_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

tti Left 'Sessions Running RMAN Information :' skip 2
tti off

select inst_id,sid,serial#,username,logon_time,program,status,
floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session
where program like '%rman%'
/

select s.inst_id, s.sid sid, p.spid spid, s.client_info client_info
from gv$process p, gv$session s
where p.addr = s.paddr
and client_info like '%rman%'
order by sid
/

tti Left 'Work done by RMAN Sessions :' skip 2
tti off

select inst_id, sid, serial#, sofar, totalwork, round(sofar/totalwork*100,2) "%_complete"
from gv$session_longops
where opname like 'RMAN%'
  and opname not like '%aggregate%'
  and totalwork != 0
  and sofar <> totalwork
order by sid
/

tti Left 'RMAN Session Waits :' skip 2
tti off

select s.inst_id,p.spid, sw.event, sw.seconds_in_wait as sec_wait, 
       sw.state, client_info
from gv$session_wait sw, gv$session s, gv$process p
where sw.event like '%s%bt%'
       and s.sid=sw.sid
       and s.paddr=p.addr
/

tti off

spool off