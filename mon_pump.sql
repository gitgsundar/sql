set pages 9999 verify off
col Instance					heading 'Environment Info' 		format a100
col name 						heading 'Name' 					format a30
col status 						heading 'Status' 				format a20
col timeout 					heading 'Timeout' 				format 999999
col error_number 				heading 'Error Number' 			format 999999
col error_msg 					heading 'Message' 				format a44 
col owner_name					heading 'Job Owner'				format a20
col job_name	 				heading 'Job'					format a20
col operation					heading 'Operation'				format a12
col job_mode					heading 'Job Mode'				format a12
col state						heading 'Job State'				format a12
col status 						heading 'Job Status'			format a10
col attached_sessions           heading 'Sessions'				format 9999999
col degree						heading 'Parallel'				format 9999999
col object_id					heading 'Object #'				format 9999999999
col object_type 				heading 'Object Type'			format a20
col object_name					heading 'Object Name'			format a40
col start_time					heading 'Start Time'
col Username					heading 'Username'				format a15
col sid							heading 'Sid'					format 9999999
col serial						heading 'Serial'				format 9999999
col opname						heading 'Operation'				format a20
col target						heading 'Target'				format a20
col %done						heading '%Done'					format a10
col time_remaining				heading 'Time Left'				format 99999
col spoolfile					heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_pump_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile
tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Data Pump Jobs Information :' skip 2

select owner_name, job_name, operation, job_mode,state,degree,attached_sessions
from dba_datapump_jobs
where job_name NOT LIKE 'BIN$%'
order by 1,2
/

tti off
tti Left 'Data Pump Master Table Information :' skip 2

select o.object_id, o.owner||'.'||object_name object_name, o.object_type, o.status
from dba_objects o, dba_datapump_jobs j
where o.owner=j.owner_name and o.object_name=j.job_name
and j.job_name not like 'BIN$%' 
order by 4,2
/

tti off

tti Left '% of Work Information :' skip 2

SELECT to_char(b.start_time,'YYYY/MM/DD HH24:MI:SS') start_time,
	b.username username, a.sid sid, b.opname opname, b.target,
    round(b.SOFAR*100/b.TOTALWORK,0) || '%' as "%DONE", 
    b.TIME_REMAINING
FROM v$session_longops b, v$session a
WHERE a.sid = b.sid  
	and (b.opname like '%EXPORT%' OR b.opname like '%IMPORT%')
ORDER BY 1
/
    
tti off

SELECT sl.sid sid, sl.serial# serial, sl.sofar sofar, sl.totalwork totalwork, dp.owner_name owner, dp.state state, dp.job_mode job_mode
FROM v$session_longops sl, v$datapump_job dp
WHERE sl.opname = dp.job_name
AND sl.sofar != sl.totalwork
/

tti off

tti Left 'Error Information :' skip 2

select name,status, timeout, error_number, error_msg 
from dba_resumable
/
    
tti off

spool off