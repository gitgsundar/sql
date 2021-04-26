-- 	File 		:	GET_DIAG_INFO.SQL
--	Description	:	Provides details of any Database Diagnostics Information
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
col Instance			heading 'Environment Info'	format a100
col name				heading	'Configuration'		format a30
col value				heading	'Value'				format a100
col spoolfile			heading 'Spool File Name'	format a100
tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_diag_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

tti Left 'Diag Information :' skip 2

select name,value 
from v$diag_info
/

tti off

spool off