-- 	File 		:	GET_OPENCURSOR_INFO.SQL
--	Description	:	Provides details Open Cursors in DB.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance						heading "Environment Info"	format a100
col sid								heading "Sid" 				format 9999999
col sql_text						heading "Sql"				format a60
col sql_fulltext					heading "Sql"				format a200
col user_name						heading "User"				format a19
col osuser							heading "OS User"			format a15
col machine							heading "Machine"			format a50
col num_curs						heading "Count"				format 99999
col Resource_name					heading 'Resource Name'		format a30
col current_utilization				heading	'Current Value'		format 999999
col max_utilization					heading	'Max Value'			format 999999
col limit_value						heading	'Limit Set'			format a20
col spoolfile						heading 'Spool File Name'	format a50
col Info							heading 'Information'		format a100
col sql_address						heading "SQL Address" 		format a30
col instance new_value instance

set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile						heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_opencursor_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

sho parameter open_cursors

SELECT  'Open_cursors' resource_name, max(a.value) as current_utilization, p.value as limit_value 
FROM v$sesstat a, v$statname b, v$parameter p 
WHERE  a.statistic# = b.statistic#  and 
		b.name = 'opened cursors current' and 
		p.name= 'open_cursors' 
group by p.value
/

tti off
tti Left 'Sessions Having Open Cursors :' skip 2

select o.sid sid, osuser, machine, count(*) num_curs
from v$open_cursor o, v$session s
where o.sid=s.sid
  and cursor_type like '%OPEN%'
having count(*) > 50
group by o.sid, osuser, machine
order by  num_curs desc
/

Accept lsid number Prompt 'Enter the Session Id : '
variable b0 number;
exec 	:b0 :=&lsid;

tti off
tti Left 'Details of the Sessions Having Open Cursors :' skip 2

select  user_name, sid ,address||':'|| hash_value sql_address, sql_text, count(*) as "Open Cursors"
from v$open_cursor 
where sid=:b0
group by user_name, sid,address||':'|| hash_value, sql_text
/

Accept laddr char Prompt 'Enter the SQL Address for Complete SQL Text: '
variable b1 varchar2(50);
exec 	:b1 := '&laddr';

tti off
tti Left 'Complete SQL Text Information :' skip 2

select SQL_FULLTEXT 
from v$sql 
where ADDRESS ||':'||HASH_VALUE = :b1
/

tti off
tti Left 'Parameter Change Information :' skip 2

select 'If MAX_VALUE is nearing LIMIT SET, you may want to increase OPEN_CURSORS Parameter' Info
from dual
/

tti off
spool off

