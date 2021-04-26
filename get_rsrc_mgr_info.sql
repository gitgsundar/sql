-- 	File 		:	GET_RSRC_MGR_INFO.SQL
--	Description	:	Provides Details of Resource Manager in the Oracle DB
--	Info		:	Update Spool information as required to get the spool output.

set long 99999 pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col	sid							heading "Sid"
col serial#						heading "Serial#"
col pname	 					heading "Plan Name"			format a25
col is_top_plan					heading "Top Plan"			format a10
col cpu_managed					heading "CPU" 
col instance_caging				heading "Caging"			format a7
col utilization_limit			heading "Ulimit"
col memory_min					heading "Min Mem"
col memory_limit				heading "Memlimit"
col gname	 					heading "Group Name"		format a25
col active_sessions				heading "Sessions"			format 999,999
col queue_length				heading "Queue"				format 999,999
col consumed_cpu_time			heading "CPU|Time"			format 999,999,999,999,999
col cpu_waits					heading "CPU|Waits"			format 999,999,999,999,999
col cpu_wait_time				heading "CPU|Wait Time"		format 999,999,999,999,999
col pqs_completed				heading "Parallel|Completed"	format 99,999,999
col	pq_servers_used 			heading "Parallel|Used"		format 999,999,999

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_rsrc_mgr_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Resource Plans Information :' skip 2

select name pname, is_top_plan, cpu_managed, instance_caging, utilization_limit, memory_min, memory_limit 
from v$rsrc_plan
/

tti off
tti Left 'Resource Consumer Group Information :' skip 2

SELECT name gname, active_sessions, queue_length,consumed_cpu_time, cpu_waits, cpu_wait_time,pqs_completed,pq_servers_used 
FROM v$rsrc_consumer_group
order by 1
/

tti off
tti Left 'Sessions Affected by Resource Manager Information :' skip 2

SELECT se.sid sess_id, co.name consumer_group, se.state, se.consumed_cpu_time cpu_time, se.cpu_wait_time, se.queued_time
FROM v$rsrc_session_info se, v$rsrc_consumer_group co
WHERE se.current_consumer_group_id = co.id
  and se.state != 'NOT MANAGED'
/


tti off
tti Left 'CDB Resource Plan Information :' skip 2

select pluggable_database, shares, utilization_limit 
from dba_cdb_rsrc_plan_directives 
where plan = (select name from v$rsrc_plan where is_top_plan = 'TRUE' and con_id = 1)
/

tti off
tti Left 'PDB Avg Sessions Running and Waiting for CPU Resource :' skip 2

select to_char(begin_time, 'HH24:MI'), name, sum(avg_running_sessions) avg_running_sessions, sum(avg_waiting_sessions) avg_waiting_sessions 
from v$rsrcmgrmetric_history m, v$pdbs p 
where m.con_id = p.con_id 
group by begin_time, m.con_id, name 
order by begin_time
/

spool off