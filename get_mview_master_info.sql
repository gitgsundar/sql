set pages 9999 verify off long 9999

col Instance	 		heading 'Environment Info'    format a100
col name				heading 'MView Name'      	  format a30
col snapshot_site		heading 'Link'				  format a20
col current_snapshots	heading 'Current Time'	  
col owner				heading 'Owner'				  format a15
col master_owner		heading 'Master Owner'		  format a15
col master				heading 'Master'		  	  format a30
col log_table			heading 'Log Table'			  format a30
col refresh_mode		heading 'Mode'	  			  format a10
col refresh_method		heading 'Method'	  		  format a10
col last_refresh		heading 'Last Refresh'
col spoolfile			heading 'Spool File Name'	  format a100
tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_mview_master_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/


tti off
tti Left 'Master Site Materialized View Information :' skip 2

select l.master,l.log_table, r.name, r.snapshot_site, l.current_snapshots
from dba_registered_snapshots r, dba_snapshot_logs l
where r.snapshot_id = l.snapshot_id
  and r.snapshot_site like '%CM%'
order by snapshot_site, current_snapshots, master
/

tti off
spool off