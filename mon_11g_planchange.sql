set pages 9999 lines 300 verify off
col Instance					heading "Environment Info"	format a100
col sql_id						heading 'SQL Id'					for a13
col cela							heading 'Current|ELA(sec)'
col oela							heading 'Old|ELA(sec)'
col sql_profile 				heading 'SQL|Profile'			for a7
col last_active_time 		heading 'Active Date'
col parsing_schema_name		heading 'Schema'					

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldate date format 'mmddyyyy:hh24miss' Prompt 'Enter the Start Date (MMDDYYYY:HH24MISS) for Checking PlanChange Activity : '

select distinct(a.sql_id),
		round(sum(a.elapsed_time)*power(10,-6),2) cela,
		round(sum(b.elapsed_time)*power(10,-6),2) oela,
		round(sum(a.OPTIMIZER_COST),2) "Current_Cost",
		round(sum(b.OPTIMIZER_COST),2) "OLD_Cost",
		a.plan_hash_value "Current plan",
		b.plan_hash_value "Old Plan",
		a.parsing_schema_name parsing_schema_name,
		NVL(a.SQL_PROFILE,'NONE') sql_profile, 
		a.last_active_time 
from v$sql a,dba_sqlset_statements b 
where a.sql_id=b.sql_id and 
		a.PLAN_HASH_VALUE!=b.PLAN_HASH_VALUE and 
		a.last_active_time > to_date('&ldate','MMDDYYYY:HH24MISS') 
-- having (sum(a.elapsed_time)/sum(a.executions))/100000 - (sum(b.elapsed_time)/sum(b.executions))/100000 > 1
group by a.sql_id,a.plan_hash_value,b.plan_hash_value,a.parsing_schema_name,a.SQL_PROFILE,a.last_active_time 
order by 2 desc,a.sql_id,a.last_active_time
/
