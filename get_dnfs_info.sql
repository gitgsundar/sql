-- 	File 		:	GET_DNFS_INFO.SQL
--	Description	:	Provides details of the Oracle Direct NFS (dNFS) 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 	format a100
col property_name				heading 'Name'				format a30
col property_value				heading 'Value'				format a35
col description					heading 'Description'		format a75
col name						heading 'PDB Name'			format a10
col con_id						heading 'Cont-ID'			format 99999999
col svrname						heading 'Server Name'		format a15
col ID							heading 'ID'				format 9999
col dirname						heading 'Directory'			format a75
col pnum						heading 'PNum'				format 99999
col filename					heading 'File Name'			format a110
col filesize					heading 'Size (MB)'			format 999,999,999,999
col path						heading 'Path'				format a15
col local						heading 'Local'				format a15
col Info                        heading 'Run below Command to manipulate Supplemental Logging'  for a80

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dnfs_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'dNFS Servers Info :' skip 2
select * 
from v$dnfs_servers
/

tti off
tti Left 'dNFS Files Info :' skip 2
select pnum, filename, filesize/1048576 filesize
from v$dnfs_files
/

tti off
tti Left 'dNFS Channels Info :' skip 2
select * 
from v$dnfs_channels
/

tti off
tti Left 'dNFS Stats :' skip 2
select * 
from v$dnfs_stats
/

tti off
spool off