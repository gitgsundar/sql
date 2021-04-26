-- 	File 		:	GET_FBDA_INFO.SQL
--	Description	:	Provides details of Flash Back Data Archive (Oracle Total Recall) Used.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 500
set echo off
col Instance						heading "Environment Info"		for a100
col flashback_archive_name	    	heading 'FBA Name'				for a20
col flashback_archive#				heading 'FBA #'					for 999,999
col retention_in_days				heading	'Retention|Days'			for 999,999,999
col create_time						heading 'Created'				for a20
col last_purge_time					heading 'Last Purge Time'		for a20
col tablespace_name					heading 'Tablespace'			for a30
col quota_in_mb						heading 'Quota(MB)'				for a15
col owner_name						heading 'Owner'					for a20
col table_name						heading 'Table'					for a20
col archive_table_name				heading 'Archive Table'			for a20
col spoolfile						heading 'Spool File Name'		for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_fbda_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Oracle Flash Back Archive Info :' skip 2

SELECT owner_name,
       flashback_archive_name,
       flashback_archive#,
       retention_in_days,
       TO_CHAR(create_time, 'DD-MON-YYYY HH24:MI:SS') AS create_time,
       TO_CHAR(last_purge_time, 'DD-MON-YYYY HH24:MI:SS') AS last_purge_time,
       status
FROM   dba_flashback_archive
ORDER BY owner_name, flashback_archive_name
/

tti off
tti Left 'Oracle FBDA Tablespace Info:' skip 2

SELECT flashback_archive_name,
       flashback_archive#,
       tablespace_name,
       quota_in_mb
FROM   dba_flashback_archive_ts
ORDER BY flashback_archive_name
/

tti off
tti Left 'Oracle FBDA Tables Info:' skip 2

SELECT owner_name,
       table_name,
       flashback_archive_name,
       archive_table_name,
       status
FROM   dba_flashback_archive_tables
ORDER BY owner_name, table_name
/

tti off
spool off