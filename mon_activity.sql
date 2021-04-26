-- 	File 		:	MON_ACTIVITY.SQL
--	Description	:	Monitor Database User Activity
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 200 verify off
col Instance		heading "Environment Info"	format a100
col sid      		heading "SID"				format 99999
col serial#  		heading "Serial#"			format 999999
col username 		heading "Username"			format a20
col program  		heading "Program"			format a40
col logon_time		heading "Logon Time"		format a22
col last_call_et	heading "Last_call_ET"		format 999999999
col osuser			heading "OS User"			format a15
col machine			heading "Machine"			format a25
col terminal 		heading "Terminal"			format a10
col status			heading "Status"			format a8
col spoolfile		heading 'Spool File Name'	format a50


col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_activity_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'User Information :' skip 2

select sid,serial#,username,logon_time,osuser,machine,terminal,program,status,last_call_et 
from gv$session 
where type='USER' 
order by 4
/

tti off
tti Left 'Sql Text of Active Users :' skip 2

select sql_text 
from gv$sqlarea where address in 
	(select sql_address from gv$session where status='ACTIVE' and type='USER') 
/

tti off
tti Left 'User Count Active Users :' skip 2

select username, count(*) 
from gv$session 
where type='USER' 
and status='ACTIVE' 
group by username
/

spool off