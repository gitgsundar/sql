-- 	File 		:	MON_RESOURCE.SQL
--	Description	:	Monitor Database Resource
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Resource_name		heading 'Resource Name'		format a30
col current_utilization	heading	'Current Value'		format 999999
col max_utilization		heading	'Max Value'			format 999999999
col limit_value			heading	'Limit Set'			format a20
col spoolfile			heading 'Spool File Name'	format a50


col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_resource_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Resource Information :' skip 2

select resource_name,current_utilization,max_utilization,limit_value 
from v$resource_limit
order by 1
/

SELECT  'Open_cursors' resource_name, max(a.value) as current_utilization, p.value as limit_value 
FROM v$sesstat a, v$statname b, v$parameter p 
WHERE  a.statistic# = b.statistic#  and 
		b.name = 'opened cursors current' and 
		p.name= 'open_cursors' 
group by p.value
/

tti off
spool off