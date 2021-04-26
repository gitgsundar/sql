-- 	File 		:	GET_SCHEDULER_INFO.SQL
--	Description	:	Provides details of Oracle Scheduler.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance			heading "Environment Info"	format a100
col owner 				heading "Owner"				format a15
col job_name			heading "Name"				format a30
col job_type 			heading "Type"				format a25
col state				heading "State"
col job_action			heading "What"				format a60
col repeat_interval		heading "Interval"			format a90
col spoolfile			heading 'Spool File Name'	format a70

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_scheduler_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Job Information :' skip 2

select object_name 
from dba_objects
where object_type='JOB'
order by 1
/

tti off
tti Left 'Job Scheduler Information :' skip 2

select owner,job_name,job_type,state,repeat_interval
from dba_scheduler_jobs
order by 1,2
/

Accept ljob char Prompt 'Enter Job Name : '

tti off
tti Left 'Job Scheduler Log Information :' skip 2

select * 
from dba_scheduler_job_log
where job_name=upper('&ljob')
/

tti off
tti Left 'Job Scheduler Run Information :' skip 2

select * 
from dba_scheduler_job_run_details
where job_name=upper('&ljob')
/

tti off
tti Left 'Job Details Information :' skip 2

select job_name, job_action,last_start_date,next_run_Date
from dba_scheduler_jobs
where job_name=upper('&ljob')
/

tti off
spool off