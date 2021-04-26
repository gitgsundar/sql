-- 	File 		:	GET_DB_INFO.SQL
--	Description	:	Provides details of the Oracle Database 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 	format a100
col property_name				heading 'Name'				format a30
col property_value				heading 'Value'				format a35
col description					heading 'Description'		format a75
col db_unique_name				heading 'DB Name'			format a10
col database_role				heading 'DB Role'			format a15
col open_mode					heading 'Open Mode'			format a15
col log_mode					heading 'Log Mode'			format a15
col protection_mode				heading 'Protection Mode'	format a20
col dataguard_broker			heading 'DG Enabled'		format a10
col force_logging 				heading 'Forced|Logging'	format a13
col supplemental_log_data_min	heading 'Supplemental|Log'	format a15
col Info                        heading 'Run below Command to manipulate Supplemental Logging'  for a80

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_db_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Database Info :' skip 2

select db_unique_name,database_role, open_mode, log_mode, protection_mode,dataguard_broker, force_logging, supplemental_log_data_min
from gv$database
/

tti off
tti Left 'Database Properties :' skip 2

select property_name,property_value,description 
from database_properties
order by 1
/

tti off
tti Left 'Supplemental/Force Logging Command Information :' skip 2
select 'Enable Supplemental Logging - alter database add supplemental log data;' Info 
from dual
union
select 'Drop Supplemental Logging   - alter database drop supplemental log data;' Info
from dual
union
select 'Enable Force Logging        - alter database force logging;' Info
from dual
union
select 'Disable Force Logging       - alter database nologging;' Info
from dual
/

tti off
spool off