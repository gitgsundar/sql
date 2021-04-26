-- 	File 		:	GET_JOB_INFO.SQL
--	Description	:	Provides details of Database Jobs
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance		heading "Environment Info"	format a100
col log_user		heading "Owner"				format a10
col job				heading "Job"				format 999999
col job_type 		heading "Type"				format a25
col broken			heading "B"
col what			heading "What"				format a60
col interval		heading "Interval"			format a50
col last_date		heading "Last Run"
col next_date		heading "Next Run"
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile		heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_job_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Job Information :' skip 2

select log_user,job,what,broken,last_date,next_date,interval
from dba_jobs
order by 1,2
/

tti off
tti Left 'Current Running Jobs Information :' skip 2

select * 
from dba_jobs_running
/

spool off