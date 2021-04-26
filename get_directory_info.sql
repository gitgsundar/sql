-- 	File 		:	GET_DIRECTORY_INFO.SQL
--	Description	:	Provides Directory Information in the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance				heading "Environment Info"			for a100
col name					heading 'Parameter Name'			for a50
col value					heading 'Value'						for a30
col owner					heading 'Owner'						for a15
col directory_name			heading 'Directory Name'			for a30
col directory_path			heading 'Path'						for a65
col spoolfile				heading 'Spool File Name'			for a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_directory_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'UTL Parameters :' skip 2

sho parameter utl_file_dir

tti off

tti Left 'Directory Information:' skip 2

select * 
from dba_directories
/

tti off

spool off