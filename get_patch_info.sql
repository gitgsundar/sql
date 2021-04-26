-- 	File 		:	GET_PATCH_INFO.SQL
--	Description	:	Provides details of Database Patches.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col action_time					heading "Date" 				format a30
col action						heading "Action"			format a15
col namespace					heading "Name Space"		format a15
col version						heading "Version"			format a25
col patch_id					heading "Patch Id"			format 999999999
col id							heading "Id"				format 99999
col bundle_series				heading "Bundle"			format a20
col comments					heading "Comments"			format a40	
col Info                        heading 'Run below Scripts on Server to get Complete information' for a150
col spoolfile					heading 'Spool File Name'	format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_patch_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Patch Information :' skip 2

select *
from dba_registry_history
order by 1 desc
/

select patch_id,action,status,description, bundle_id, bundle_series
from dba_registry_sqlpatch
/

tti off
tti Left 'OPatch Information :' skip 2
select 'DATABASE PSU           - $ORACLE_HOME/OPatch/opatch lsinventory -bugs_fixed | grep -i "DATABASE PSU"' Info
from dual
union
select 'GRID INFRA (ASM) PSU   - $ORACLE_HOME/OPatch/opatch lsinventory -bugs_fixed | grep -i "gi psu"' Info
from dual
union
select 'Datbase Bundle Patches - $ORACLE_HOME/OPatch/opatch lspatches' Info
from dual
union
select 'PL/SQL Package         - exec dbms_qopatch.get_sqlpatch_status as SYS User' Info
from dual
/

spool off