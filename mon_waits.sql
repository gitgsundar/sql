set pages 9999 lines 200 verify off
col Instance						heading "Environment Info"	format a100
col sid      	format 99999		heading "Sid"
col serial#  	format 999999		heading "Serial#"
col username 	format a15      	heading "User"
col program  	format a30			heading "Program"
col logon_time						heading "Logon Time"
col status							heading "Status"
col event    	format a50			heading "Event"
col wait_class	format a30			heading "Class of Event" 

tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_waits_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Session Wait Information :' skip 2


select sid,serial#,username,Status,logon_Time,event,wait_class 
from gv$session 
where wait_time>0
/

tti off
tti Left 'Session Blocker Information :' skip 2
select * 
from gv$session_blockers
/

tti off
spool off