-- 	File 		:	GET_DBSTAT_INFO.SQL
--	Description	:	Provides details of the Oracle Database Statistics
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance			heading "Environment Info"			for a100
col operation			heading 'Operation'					for a35
col start_time			heading 'Window Start Time'			for a40
col duration			heading 'Duration'					for a30
col history_date		heading 'Historical Date'			for a40
col history_days		heading 'History Rentention Days'	
col spoolfile			heading 'Spool File Name'			for a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dbstat_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Statistics History Information :' Skip 1

select DBMS_STATS.GET_STATS_HISTORY_AVAILABILITY history_date,
	   DBMS_STATS.GET_STATS_HISTORY_RETENTION history_days
from dual
/

tti off
tti Left 'Statistics Operation Information'
select distinct operation 
from dba_optstat_operations
/

Accept loperation char Prompt 'Enter Stats Operation Name : '

tti off
tti Left 'Statistics Operation Run History Information :' skip 2

select operation,start_time, (end_time-start_time) day(1) to second(0) as duration
from dba_optstat_operations
where operation like '%&loperation%'
order by start_time
/

spool off