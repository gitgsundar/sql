set pages 9999 lines 300 verify off
col Instance					heading 'Environment Info' 			format a100
col occupant_name      		heading 	'Occupant'				format a30
col occupant_desc			  	heading 	'Description'			format a60
col schema_name				heading	'Schema'					format a20
col space_usage_kbytes		heading	'Space(Kbytes)'		format 999,999,999
col snap_interval				heading	'Snap Interaval(Hour)'	format a30
col retention					heading	'Retention(Days)'		format a30
col topnsql						heading  'TopNSql(#)'			
col most_recent_purge_time	heading	'Last Purge'			format a30
col tablespace_name			heading 'Tablespace Name'		format a30
col alloted_bytes 			heading 'Alloted Bytes'			format 99,999,999,999,999
col free_bytes 				heading 'Free Bytes'				format 99,999,999,999,999
col percent_free  			heading 'Free %'					format 999.99

tti off

col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_sysaux_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Sysaux Tablespace Information :' skip 1

select occupant_name,occupant_desc,schema_name,space_usage_kbytes from v$sysaux_occupants
order by 4
/

tti off

-- exec dbms_workload_repository.modify_snapshot_settings(retention=>5760);
-- i.e. the parameter value is in minutes so 4 x 24 x 60 = 5760 minutes
-- exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(topnsql => 100);
-- execute DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval => 0);
tti Left 'AWR Config values :' skip 2

select snap_interval,retention,topnsql,most_recent_purge_time from sys.wrm$_wr_control;
select * from DBA_HIST_WR_CONTROL;
tti off

tti off
tti Left 'SYSAUX Sizing Information :' skip 2

select a.tablespace_name, alloted_bytes, nvl(free_bytes,0) free_bytes, nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from 
(select tablespace_name, sum(bytes) alloted_bytes from dba_data_files where tablespace_name='SYSAUX' group by tablespace_name) a,
(select tablespace_name, sum(bytes) free_bytes from dba_free_space where tablespace_name='SYSAUX' group by tablespace_name) b
/

tti off
spool off