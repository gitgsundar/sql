set pages 9999 lines 300
set verify off
col Instance						heading 'Environment Info' 			format a100
col parameter_name				heading 'Parameter Name'				format a30
col parameter_value 				heading 'Value'							format 99,999,999,999,999
col sql_handle						heading 'SQL Handle'						format a30
col sql_text						heading 'SQL Text'						format a50
col plan_name						heading 'Plan Name'						
col origin							heading 'Origin'
col enabled							heading 'Enabled'							
col accepted						heading 'Accepted'		
col fixed							heading 'Fixed'
col autopurge						heading 'Autopurge'

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'SPM Parameter Information :' skip 2

select parameter_name, parameter_value from sys.smb$config
order by 1
/

tti off
tti Left 'SQL Plan Baseline Information :' skip 2
select sql_handle, sql_text,plan_name,origin,enabled,accepted,fixed,autopurge
from dba_sql_plan_baselines
where rownum < 5
/

tti off


-- select s.sql_text,b.plan_name,b.origin,b.accepted
-- from dba_sql_plan_baselines b, v$sql s
-- where s.exact_matching_signature = b.signature
--  and s.sql_plan_baseline = b.plan_name