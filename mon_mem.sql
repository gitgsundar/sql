-- 	File 		:	MON_MEM.SQL
--	Description	:	Monitor Database Session Memory Activity
--	Info		:	Update Spool information as required to get the spool output.

col Instance	heading  "Environment Info"	format a100
col sid      	heading	"Sid"					format 999
col serial#  	heading	"Serial#"				format 999999
col username 	heading	"Username"				format a15
col program  	heading	"Program"				format a50
col status		heading	"Status"				format a9
col sql_text	heading	"Sql Text"				format a80
col pool		heading	"Pool Type"				format a15
col name		heading	"Pool Name"				format a20
col bytes		heading	"Bytes"					format 999,999,999,999

tti Left 'Instance Information :' skip 2

col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_mem_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
tti off

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Current User Session Information :' skip 2

select sid,serial#,username,logon_time,program,status 
from v$session 
where type='USER' 
order by 4
/

tti off
tti Left 'User Session SQL Information :' skip 2

select sql_text 
from v$sqlarea 
where address in (select sql_address from v$session where status='ACTIVE' and type='USER') 
/

tti off
tti Left 'User Session Groups Information :' skip 2

select username, count(*) 
from v$session 
where type='USER' and status='ACTIVE' 
group by username
/

tti off
tti Left 'SGA Status Information :' skip 2

select * 
from v$sgastat 
where name in ('library cache','sql area','free memory') 
order by 2
/

tti off
tti Left 'Total Session Memory Consumed by Session Information :' skip 2

SELECT   NVL (username, 'SYS-BKGD') username, sess.SID, SUM (VALUE) sess_mem
FROM v$session sess, v$sesstat stat, v$statname NAME
WHERE sess.SID = stat.SID
     AND stat.statistic# = NAME.statistic#
     AND NAME.NAME LIKE 'session % memory'
GROUP BY username, sess.SID
order by 1
/ 
