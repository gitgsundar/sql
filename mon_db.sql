-- 	File 		:	MON_DB.SQL
--	Description	:	Monitor Database..
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col inst_id			format 9999			heading 'Inst'		
col sid      		format 99999		heading "Sid"
col serial#  		format 999999		heading "Serial#"
col username 		format a15       	heading "User"
col program  		format a30			heading "Program"
col event    		format a50			heading "Event"
col sql_text 		format a500
col idle			format a15			heading "Idle"
col status			format a10			heading "Status"
col logon_time		format a30			heading "Logon Time"
col eq_name			heading "Name"			
col eq_type			heading "Eq"
col req_description	format a50			heading "Description"		
col req_reason		format a20			heading "Reason"		

tti off
col spoolfile		heading 'Spool File Name'	format a150
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_db_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from gv$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from gv$instance
/

tti off
tti Left 'Sql Information :' skip 2

SELECT sql_text "Stmt", count(*),	        
	        sum(sharable_mem)    "Mem",
	        sum(users_opening)   "Open",
	        sum(executions)      "Exec"
FROM gv$sql
GROUP BY sql_text
HAVING sum(sharable_mem) > 524288 
ORDER BY sum(sharable_mem)
/

tti off
tti Left 'User Information :' skip 2

select inst_id,sid,serial#,username,logon_time,program,status,
floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session 
where type='USER' 
order by 4
/

tti off
tti Left 'Sql Text of Active Users :' skip 2

select sql_text from gv$sqlarea where address in 
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

tti off
tti Left 'SGA Status :' skip 2

select * 
from gv$sgastat 
where name in ('library cache','sql area','free memory') order by 2
/

tti off
tti Left 'Enqueue Status :' skip 2

select * 
from gv$enqueue_statistics 
where cum_wait_time > 0 order by 7
/

tti off
spool off
