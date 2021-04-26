-- 	File 		:	GET_DB_REGISTRY_INFO.SQL
--	Description	:	Provides details of the Oracle Database Registry 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 250 escape on 
col Instance			heading 'Environment Info'				format a100
col	Schema				heading 'Schema'						format a10
col comp_id				heading	'Component'						format a15
col comp_name 			heading	'Component Name'				format a40
col version				heading	'Version'						format a15
col status				heading 'Status'						format a10
col modified			heading	'Timestamp'						format a20
col procedure			heading 'Procedure Name'				format a35
col spoolfile			heading 'Spool File Name'				format a100


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_db_registry_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'DB Registry Information :' skip 2

select schema, comp_id,comp_name,version,status,modified,procedure 
from dba_registry
order by 1
/

spool off