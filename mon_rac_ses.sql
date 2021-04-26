set pages 9999 verify off
col sid      		format 99999		heading "Sid"
col serial#  		format 999999		heading "Serial#"
col username 		format a15       	heading "User"
col program  		format a30			heading "Program"
col event    		format a50			heading "Event"
col osuser	 		format a10			heading "OSUser"
col machine	 		format a25			heading "Machine"
col logon_time	 	format a21			heading "Logon Time"
col status	 		format a10			heading "Staus"
col program	 		format a30			heading "Program"
col shadow_process 	format 99999999  	heading "Shadow PID"
col client_process 	format 99999999 	heading "Client PID"
col idle			format a10			heading "Idle"

tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_rac_ses_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

select count(*), sestype, lifecycle from
(select decode(bitand(ksuseflg,1)+bitand(ksuseflg,2), 0, 'NEVERUSED', 1, 'USER',2, 'RECURSIVE') sestype,
	decode(bitand(ksspaflg,1), 1, 'ACTIVE', 'FREEABLE') lifecycle from x$ksuse)
group by sestype, lifecycle
/

Accept lusername char Prompt 'Enter the Username : '

select sid,serial#,username,logon_time,status,program,osuser,machine ,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session 
where type='USER' and username like upper(NVL('&lusername','%%')) 
order by logon_time
/

Accept lsid number Prompt 'Enter the Session Id : '

select s.sid,s.serial#,s.status,s.logon_time, p.spid Shadow_process, s.process Client_process,s.username,s.program,s.osuser,s.machine,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session s, gv$process p
where s.paddr = p.addr and
		s.sid   = &lsid;

select sql_text Sql from v$sqlarea where address in 
	(select sql_address from gv$session where sid=&lsid) 
/

select used_ublk,used_urec,log_io,phy_io,status 
from gv$transaction 
where addr in (select taddr from gv$session where sid=&lsid) 
/

select event,total_waits,total_timeouts 
from gv$session_event 
where sid=&lsid order by 2 desc
/

select * from gv$sess_io where sid=&lsid
/

select * from gv$session_wait where sid=&lsid
/

select * from gv$session_longops where sid=&lsid and serial# in (select serial# from gv$session where sid=&lsid)
and rownum < 5
order by last_update_time desc
/

spool off