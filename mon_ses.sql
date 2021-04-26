-- 	File 		:	MON_SES.SQL
--	Description	:	Monitor Session based on Schema/SID Inputs.
--	Info		:	Update Spool information as required to get the spool output.
set pages 9999 verify off
col inst_id	 		format 99999			heading "Inst ID"
col sid      		format 99999			heading "Sid"
col serial#  		format 999999			heading "Serial#"
col username 		format a15       		heading "User"
col program  		format a30				heading "Program"
col event    		format a40				heading "Event"
col osuser	 		format a10				heading "OSUser"
col type			format a30				heading "User Type"
col machine	 		format a25				heading "Machine"
col logon_time	 	format a21				heading "Logon Time"
col total_waits		format 999,999,999,999	heading "Total Waits"
col total_timeouts	format 999,999,999,999	heading "Total Timeouts"
col status	 		format a10				heading "Staus"
col program	 		format a30				heading "Program"
col shadow_process 	format a10		  		heading "S-PID"
col client_process 	format a10		 		heading "C-PID"
col p1				format a25				heading "P1Text->P1"
col p2				format a25				heading "P2Text->P2"
col p3				format a25				heading "P3Text->P3"
col wait_class		format a20				heading "Wait Class"
col wait_time		format 9999				heading "Wait Time"
col seconds_in_wait	format 999,999,999		heading "Wait(s)"
col log_io			format 999,999,999,999	heading "LIO"
col phy_io			format 999,999,999,999	heading "PIO"
col idle			format a10				heading "Idle"
col block_gets		format 999,999,999,999	heading "Block Gets"
col	consistent_gets	format 999,999,999,999	heading "Consistent Gets"
col physical_reads	format 999,999,999,999	heading "Physical Gets"
col	block_changes	format 999,999,999,999	heading	"Block Changes"
col	consistent_changes	format 999,999,999	heading "Consistent Changes"

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on

col spoolfile		heading 'Spool File Name'			format a150
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_ses_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lusername char Prompt 'Enter the Username : '

select inst_id,sid,serial#,username,type,logon_time,status,program,osuser,machine ,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session 
where username like upper(NVL('&lusername','%%')) 
order by logon_time,type
/

Accept lsid number Prompt 'Enter the Session Id : '
select s.inst_id inst_id,s.sid,s.serial#,s.status,s.logon_time, p.spid Shadow_process, s.process Client_process,s.username,s.program,s.osuser,s.machine,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session s, gv$process p
where s.paddr = p.addr and
		s.sid   = &lsid;

select sql_text Sql from gv$sqlarea where address in 
	(select sql_address from gv$session where sid=&lsid) 
/

tti off
tti Left 'Transaction Information :' skip 2

select inst_id,used_ublk,used_urec,log_io,phy_io,status 
from gv$transaction 
where addr in (select taddr from gv$session where sid=&lsid) 
/

tti off
tti Left 'Session Event Waits Information :' skip 2

select event,total_waits,total_timeouts 
from gv$session_event 
where sid=&lsid order by 2 desc
/

tti off
tti Left 'Session IO Characteristics Information :' skip 2

select sid,block_gets,consistent_gets,physical_reads,block_changes,consistent_changes 
from gv$sess_io 
where sid=&lsid
/

tti off
tti Left 'Session Wait Information :' skip 2

select sid, event, p1text||'->'||p1 p1,p2text||'->'||p2 p2, p3text||'->'||p3 p3, wait_class, wait_time, seconds_in_wait
from gv$session_wait 
where sid=&lsid
/

tti off
tti Left 'Session Long Running Transaction Information :' skip 2

select * 
from gv$session_longops 
where sid=&lsid and serial# in (select serial# from gv$session where sid=&lsid)
and rownum < 5
order by last_update_time desc
/

spool off