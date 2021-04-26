-- 	File 		:	GET_AWR_INFO.SQL
--	Description	:	Provides details AWR (Automatic Workload Repository) Info
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col snap_interval		heading	'Snap Interaval(Hour)'	format a30
col retention			heading	'Retention(Days)'		format a30
col topnsql				heading  'TopNSql(#)'			format 999,999,999,999,999
col spoolfile			heading 'Spool File Name'		format a100
col most_recent_purge_time	heading	'Last Purge'		format a30
col Info				heading 'AWR Command Info'		format a150
tti off


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_awr_info_'||to_char(sysdate,'yyyymmdd:hh24miss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

-- exec dbms_workload_repository.modify_snapshot_settings(retention=>5760);
-- i.e. the parameter value is in minutes so 4 x 24 x 60 = 5760 minutes
-- exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(topnsql => 100);
-- execute DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval => 0);

-- To get Comparison Report 
-- select * from TABLE(DBMS_WORKLOAD_REPOSITORY.awr_diff_report_html(1178795725,1,26823,26895,1178795725,1,26902,26938)); 
-- You can also use awrddrpt.sql from $OH/rdbms/admin

tti Left 'AWR Config values :' skip 2

select snap_interval,retention,topnsql,most_recent_purge_time
from sys.wrm$_wr_control
/

tti off

select * from DBA_HIST_WR_CONTROL
/

tti off
tti Left 'AWR Command Information :' skip 2
select 'To Create AWR Snapshot             -> exec dbms_workload_repository.create_snapshot();' Info 
from dual
union
select 'To Modify AWR Retention in Minutes -> exec dbms_workload_repository.modify_snapshot_settings(retention=>5760);' Info
from dual
union
select 'To Modify AWR Interval in Minutes  -> exec dbms_workload_repository.modify_snapshot_settings(interval=>60);' Info
from dual
union
select 'To Modify AWR TopSql Count         -> exec dbms_workload_repository.modify_snapshot_settings(topnsql=>1000);' Info
from dual
union
select 'To Size SYSAUX Tablespace          -> Run $OH/rdbms/admin/utlsyxsz.sql' Info
from dual
union
select 'To Capture more AWR Info           -> Run $OH/rdbms/admin/awrinfo.sql' Info
from dual
union
select 'To Generate AWR Report Info        -> Run $OH/rdbms/admin/awrrpt.sql' Info
from dual
/


tti off
spool off