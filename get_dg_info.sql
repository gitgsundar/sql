-- 	File 		:	GET_DG_INFO.SQL
--	Description	:	Provides details of the Oracle DataGuard Config. 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 	format a100
col	dest_id						heading 'Dest ID'			format 99999
col db_unique_name				heading 'DB Name'			format a10
col database					heading 'DB Name'			format a10
col connect_identifier			heading 'Connect String'	format a50
col dataguard_role				heading 'DB Role'			format a20
col version						heading 'Version'			format a10
col enabled						heading 'Enabled'			format a7
col redo_source					heading 'Redo Source'		format a15
col parent_dbun					heading 'Parent'			format a10
col dest_role					heading 'Role'				format a20
col	con_id						heading 'Con ID'			format 99999
col facility					heading 'Process'			format a30
col severity					heading 'Severity'			format a13
col message						heading 'Message'			format a80
col timestamp					heading 'Time'				format a20
col current_scn					heading 'Current SCN#'		format 999,999,999,999,999,999
col applied_scn					heading 'Applied SCN#'		format 999,999,999,999,999,999
col protection_mode				heading	'Protection Mode'	format a20
col protection_level			heading	'Protection Level'	format a20
col Database_Role				heading	'DB Role'			format a20
col switchover_status			heading 'Switchover Stat'	format a20

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dg_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Database Info :' skip 2

SELECT PROTECTION_MODE, PROTECTION_LEVEL, DATABASE_ROLE, SWITCHOVER_STATUS 
FROM V$DATABASE
/

tti off
tti Left 'Database Fast-Start Failover Info :' skip 2

SELECT FS_FAILOVER_STATUS "FSFO STATUS", FS_FAILOVER_CURRENT_TARGET TARGET, FS_FAILOVER_THRESHOLD THRESHOLD, FS_FAILOVER_OBSERVER_PRESENT "OBSERVER PRESENT" 
FROM V$DATABASE
/


tti off
tti Left 'DataGuard Info :' skip 2

select db_unique_name,parent_dbun, dest_role, current_scn, con_id
from v$dataguard_config
/

tti off
tti Left 'REDO SCN Applied Info :' skip 2

select dest_id, applied_scn 
from v$archive_dest 
where target='STANDBY'
/

tti off
tti Left 'DataGuard Broker Info :' skip 2

select database, connect_identifier, dataguard_role,redo_source,enabled, version
from v$dg_broker_config
/

tti off
tti Left 'DataGuard Status :' skip 2

select * 
from ( select facility, severity, message, timestamp
from v$dataguard_status
order by timestamp)
where rownum < 5
/

tti off
spool off