-- 	File 		:	GET_MVIEW_INFO.SQL
--	Description	:	Provides details of Materialized View in the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off long 9999

col Instance	 	heading 'Environment Info'    format a100
col mview_name		heading 'MView Name'      	  format a30
col owner			heading 'Owner'				  format a15
col master_owner	heading 'Master Owner'		  format a15
col master			heading 'Master'		  	  format a30
col master_link		heading 'DBLink'			  format a30
col refresh_mode	heading 'Mode'	  			  format a10
col refresh_method	heading 'Method'	  		  format a10
col last_refresh	heading 'Last Refresh'
col staleness		heading 'Status'			  for a20
col spoolfile		heading 'Spool File Name'	  format a100
tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_mview_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/


tti off
tti Left 'Materialized View Information :' skip 2

select owner,mview_name,master_link,refresh_mode,refresh_method,staleness
from dba_mviews
order by 1,2
/

tti off
tti Left 'Materialized View Refresh Information :' skip 2

select owner, name mview_name,master_owner, master, last_refresh 
from dba_mview_refresh_times
order by last_refresh
/

spool off