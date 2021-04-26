clear columns
set pages 9999 lines 300 verify off
col client_name				heading 'Task Name'					for a35
col status						heading 'Job|Status'					for a15
col Instance					heading 'Environment Info'			for a100
col window_name				heading 'Window Name'				for a20
col window_start_time		heading 'Window Start Time'		for a40
col job_start_time			heading 'Job Start Time'			for a40
col job_duration				heading 'Job|Duration'				for a15
col job_error					heading 'Error'

tti off


col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_autotask_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select client_name,status from dba_autotask_client
/

Accept lautotask char Prompt 'Enter Autotask Name : '

tti off
tti Left 'Autotask Run History Information :' skip 2

select client_name, job_status status, window_name,window_start_time, job_start_time,job_duration,job_error
from dba_autotask_job_history
where client_name like '%&lautotask%'
order by job_start_time
/

spool off