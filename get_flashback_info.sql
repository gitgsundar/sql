-- File 			:	GET_FLASHBACK_INFO.SQL
--	Description	:	Provides details of FRA
--	Info		   :	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance		heading "Environment Info"	for a100
col name			heading 'Parameter Name'	for a50
col value			heading 'Value'				for a30
col flashback_on	heading 'Flashback Status'	for a20
col spoolfile		heading 'Spool File Name'	for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_flashback_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Flashback Parameters :' skip 2

select name,value 
from v$parameter 
where name like '%flashback%' OR name like '%db_recovery%'
/

tti off
tti Left 'Flashback Info :' skip 2

select flashback_on from v$database
/
select name,scn,time,storage_size from v$restore_point
/

tti off
tti Left 'Flashback Status :' skip 2

select * From v$flashback_database_stat
/
select * From v$flashback_database_log
/
select * from v$session_longops where opname like 'Flashback%'
/

tti off
tti Left 'FlashSpace Information :' skip 2

select (case when percent_used > 100 then 0 else (100-percent_used) end) percent_free
from (select (sum(percent_space_used)-sum(percent_space_reclaimable)) percent_used  from v$flash_recovery_area_usage)
/

tti off
tti Left 'FileTypes Information :' skip 2	

Select file_type, percent_space_used as used,percent_space_reclaimable as reclaimable, number_of_files as "number" 
from v$flash_recovery_area_usage
/

tti off
tti Left 'Space Usage Information :' skip 2	

select name, space_limit/1048576 as Total_size ,space_used/1048576 as Used, SPACE_RECLAIMABLE/1048576 as reclaimable ,NUMBER_OF_FILES as "number" 
from  V$RECOVERY_FILE_DEST
/
tti off

tti off
tti Left 'Archived Logs Information needed for Guaranteed Restore Point (GRP) :' skip 2	

SELECT DISTINCT al.thread#, al.sequence#, al.resetlogs_change#, al.resetlogs_time
     FROM v$archived_log al,
          (select grsp.rspfscn               from_scn,
                  grsp.rspscn                to_scn,
                  dbinc.resetlogs_change#    resetlogs_change#,
                  dbinc.resetlogs_time       resetlogs_time
             from x$kccrsp grsp,  v$database_incarnation dbinc
            where grsp.rspincarn = dbinc.incarnation#
              and bitand(grsp.rspflags, 2) != 0
              and bitand(grsp.rspflags, 1) = 1 -- guaranteed
              and grsp.rspfscn <= grsp.rspscn -- filter clean grp
              and grsp.rspfscn != 0
          ) grsp
       WHERE al.next_change#   >= grsp.from_scn
           AND al.first_change#    <= (grsp.to_scn + 1)
           AND al.resetlogs_change# = grsp.resetlogs_change#
           AND al.resetlogs_time       = grsp.resetlogs_time
           AND al.archived = 'YES'
/

spool off