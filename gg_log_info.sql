set pages 9999 lines 300 verify off
col member format a50
col current_scn 				heading 'Current SCN'		format 9999999999999999
col capture_name				heading 'Capture Name'		format a25
col capture_user				heading 'Capture User'		format a15
col first_change# 				heading 'First SCN'			format 9999999999999999
col next_change# 				heading 'Last SCN'			format 9999999999999999
col first_scn	 				heading 'First SCN'			format 9999999999999999
col start_scn	 				heading 'Start SCN'			format 9999999999999999
col tfscn						heading 'First SCN Time'	format a35
col sscn						heading 'Start SCN Time'	format a35
col captured_scn	 			heading 'Captured SCN'		format 9999999999999999
col applied_scn	 				heading 'Applied SCN'		format 9999999999999999
col first_time					heading 'First SCN Time'
col next_time					heading 'Last SCN Time'
col activity_date				heading 'Date'							
col switches					heading 'Archives(#)'		format 9999999
col size_in_MB					heading 'Size in MB'		format 999999999
col dest_id						heading 'Dest ID'			format 9999999
col	group#						heading 'Grp'				format 999
col thread#						heading 'Thr'				format 999
col sequence#					heading 'Seq'				format 99999999
col bytes						heading 'Bytes'				format 999,999,999
col blocksize					heading 'Blk'
col Members						heading 'Mem'				format 999
col Status						heading 'Status'			format a10
col archived_date				heading 'Archived Date'	
col member						heading 'Logfile Name'		format a50
col	log_mode					heading 'Log Mode'			
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'gg_log_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Current DB SCN  Information :' skip 2

select current_scn from v$database;

tti off
tti Left 'GG Capture Information :' skip 2

select capture_name, capture_user,first_scn, scn_to_timestamp(first_scn) tfscn ,start_scn,scn_to_timestamp(start_scn) sscn
from dba_capture
/

tti off
tti Left 'Capture Archive History Information :' skip 2

select dest_id, sequence# log_seq,first_change#,next_change#, archived, standby_dest, applied, completion_time archived_date
from v$archived_log 
where completion_time > (select scn_to_timestamp(start_scn) from dba_capture)
order by completion_time
/

tti off
tti Left 'Current Log Activity Information :' skip 2
select * from v$log
/

tti off

spool off