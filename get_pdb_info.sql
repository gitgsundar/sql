-- 	File 		:	GET_PDB_INFO.SQL
--	Description	:	Provides details of the Oracle Pluggable Database 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance						heading 'Environment Info' format a100
col property_name					heading 'Name'					format a30
col property_value				heading 'Value'				format a35
col description					heading 'Description'		format a75
col name								heading 'PDB Name'			format a20
col con_id							heading 'Cont-ID'				format 99999999
col open_mode						heading 'Open Mode'			format a15
col restricted						heading 'Restricted'			format a15
col recovery_status				heading 'Status'				format a15
col size_MB							heading 'DB Size(MB)'		format 99,999,999,999
col force_logging 				heading 'Forced|Logging'	format a13
col supplemental_log_data_min	heading 'Supplemental|Log'	format a15
col Info                      heading 'Run below Command to manipulate Supplemental Logging'  for a80

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_pdb_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'PDB Database Info :' skip 2

select con_id, name,open_mode,restricted,recovery_status
from v$pdbs
/

select name, open_mode,total_size/1048576 size_MB
from v$containers
/

tti off
spool off