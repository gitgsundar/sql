-- 	File 		:	GET_NLS_INFO.SQL
--	Description	:	Provides NLS (National Language Support) Details of the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance	heading 'Environment Info'	format a100
col Parameter 	heading	'Parameter'			format a45
col Value		heading	'Value'				format a45
col spoolfile 	heading 'Spool File Name'	format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_nls_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/
tti off
tti Left 'Database NLS Information :' skip 2

select *
from nls_database_parameters
order by 1
/

spool off