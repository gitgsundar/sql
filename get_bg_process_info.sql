-- 	File 		:	GET_BG_PROCESS_INFO.SQL
--	Description	:	Provides Description of all Oracle Database Background Processes.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance			heading 'Environment Info'	format a100
col name 				heading	'Name'				format a30
col description			heading	'Description'		format a70
col spoolfile			heading 'Spool File Name'	format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_bg_process_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti off
tti Left 'All Background Process Information :' skip 2

select bg.name name, bg.description description
from v$bgprocess bg
order by 1
/

spool off