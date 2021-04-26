set pages 9999 verify off
col Instance			heading 'Environment Info'		format a100
col sid  				heading	'Sid'					format 999999
col serial#  			heading	'Serial#'				format 999999
col username 			heading	'Username'				format a15
col program  			heading	'Program'				format a30
col event    			heading	'Event'					format a50
col status				heading	'Status'		
col logon_time			heading	'Logon Time'		
col shadow_process		heading	'Shadow Process'
col client_process		heading	'Client Process'
col spoolfile			heading 'Spool File Name'		format a150

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_spid_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lspid char Prompt 'Enter the OS Shadow Process Id : '

tti Left 'Session Information :' skip 2

select s.sid sid,s.serial# serial#,s.status status,s.logon_time, p.spid Shadow_process, s.process Client_process,s.username,s.program 
from v$session s, v$process p
where s.paddr = p.addr and
	  p.spid  = '&lspid';

tti off
tti Left 'SqlText Information :' skip 2

select sql_text Sql from v$sqlarea where address in 
	(select sql_address from v$session where paddr in (select addr from v$process where spid='&lspid'))
/

tti off
tti Left 'Transaction Information :' skip 2

select used_ublk,used_urec,log_io,phy_io,status from v$transaction 
where addr in (select taddr from v$session where paddr in (select addr from v$process where spid='&lspid'))
/

tti off
tti Left 'Session Event Information :' skip 2

select event,total_waits,total_timeouts from v$session_event 
where sid in (select sid from v$session where paddr in (select addr from v$process where spid='&lspid'))
order by 2 desc
/

tti off
tti Left 'Session I/O Information :' skip 2

select * from v$sess_io 
where sid in (select sid from v$session where paddr in (select addr from v$process where spid='&lspid'))
/

tti off
tti Left 'Session Wait Information :' skip 2

select * from v$session_wait 
where sid in (select sid from v$session where paddr in (select addr from v$process where spid='&lspid'))
/


tti off
tti Left 'Long Operations Information :' skip 2

select * from v$session_longops 
where sid in (select sid from v$session where paddr in (select addr from v$process where spid='&lspid'))
   and serial# in (select serial# from v$session where paddr in (select addr from v$process where spid='&lspid'))
order by last_update_time desc
/

tti off
tti Left 'Complete SQL Text Information :' skip 2

select sql_text
from v$sqltext
where hash_value in (select sql_hash_value from v$session where paddr in (select addr from v$process where spid='&lspid'))
order by piece
/

spool off