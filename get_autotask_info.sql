-- 	File 		:	GET_AUTOTASK_INFO.SQL
--	Description	:	Provides details of Auto Tasks, Schedules, Runs in the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance				heading "Environment Info"		for a100
col client_name				heading 'Client Name'			for a35
col task_name				heading 'Task Name'				for a35
col status					heading 'Job|Status'			for a15
col current_job_name		heading 'Current Job'			for a35
col job_scheduler_status	heading 'Job Status'			for a15
col Instance				heading 'Environment Info'		for a100
col window_name				heading 'Window Name'			for a20
col window_start_time		heading 'Window Start Time'		for a40
col window_duration			heading 'Duration'				for a30
col window_next_time		heading 'Windown Next Time'		for a50
col autotask_status			heading 'AutoTask'
col optimizer_stats			heading 'Optimizer Task'
col segment_advisor			heading 'Segment Advisor'
col sql_tune_advisor		heading 'SQL Tune Advisor'
col health_monitor			heading 'Health Monitor' 
col spoolfile				heading 'Spool File Name'		for a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_autotask_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Autotask Information :' skip 2

select client_name,status 
from dba_autotask_client
/

--
-- To Disable all All Automated Maintenance Tasks
-- execute DBMS_AUTO_TASK_ADMIN.DISABLE;
--


--
-- To Enable/Disable Individual Automated Maintenance Tasks
-- 	BEGIN
--       dbms_auto_task_admin.disable(
--       client_name => 'sql tuning advisor',
--       operation => NULL,
--       window_name => NULL);
--    END; 
--    /


-- To Check/Change Degree of DBMS_STATS Job
--
-- select dbms_stats.get_param('DEGREE') from dual;
-- exec dbms_stats.set_global_prefs('DEGREE','8');
-- select dbms_stats.get_param('DEGREE') from dual;
-- 


-- To Check/Change STALE_PERCENT of DBMS_STATS Job
--
-- select dbms_stats.get_prefs('STALE_PERCENT') from dual;
-- exec dbms_stats.set_global_prefs('STALE_PERCENT','8');
-- select dbms_stats.get_prefs('STALE_PERCENT') from dual;
-- 


-- To Change the Scheduler Window
--
--	DECLARE
--		type wday is table of varchar2(15);
--		days wday:= wday('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY');
--	BEGIN
--		for i in days.first .. days.last loop
--			BEGIN
--				dbms_scheduler.disable(name => days(i)||'_WINDOW');
--				dbms_scheduler.set_attribute(days(i)||'_WINDOW','repeat_interval','freq=weekly;byday='||substr(days(i),1,3)||';byhour=18;byminute=0;bysecond=0');
--				dbms_scheduler.set_attribute(
--					name => days(i)||'_WINDOW',
--					attribute => 'DURATION',
--					value => numtodsinterval(6, 'hour'));
--				dbms_scheduler.enable(name => days(i)||'_WINDOW');
--			END;
--		end loop;
--	END;
--	/
-- 

-- Note ID - 731935.1
-- To Manually Collect the Stats
-- exec DBMS_AUTO_TASK_IMMEDIATE.GATHER_OPTIMIZER_STATS;
--
-- To Check the Status of the Job
-- select job_name,state from dba_scheduler_jobs where program_name='GATHER_STATS_PROG';
--
-- To Interrupt the Job
-- variable jobid varchar2(32)
-- exec select job_name into :jobid from dba_scheduler_jobs where program_name='GATHER_STATS_PROG';
-- print :jobid
-- exec dbms_scheduler.stop_job(:jobid,false)
--

tti off
tti Left 'Window Information'
select window_name,window_next_time,autotask_status,optimizer_stats,segment_advisor,sql_tune_advisor,health_monitor
from dba_autotask_window_clients
/

Accept lautotask char Prompt 'Enter Autotask Name : '

tti off
tti Left 'Autotask Task Information :' skip 2

select client_name,task_name,current_job_name,job_scheduler_status
from dba_autotask_task
where client_name like '%&lautotask%'
/

tti off
tti Left 'Autotask Current Information :' skip 2

select client_name,job_name,task_name,job_scheduler_status
from dba_autotask_client_job
where client_name like '%&lautotask%'
/


tti off
tti Left 'Autotask Run History Information :' skip 2

select client_name, window_name,window_start_time, window_duration
from dba_autotask_client_history
where client_name like '%&lautotask%'
order by window_start_time
/

spool off