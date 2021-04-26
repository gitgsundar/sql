-- 	File 		:	GET_SPM_INFO.SQL
--	Description	:	Provides SPM (SQL Plan Management) Information.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col creator					heading 'Owner'					for a30
col cnt						heading 'Num of Plans'			for 999,999,999
col Parameter_name			heading 'Parameter Name'		for a35
col Parameter_value			heading 'Value'					for 99999
col Instance				heading 'Environment Info'		for a100
col Info                    heading 'Run below Command to manipulate SPM Settings'  for a80
col sql_handle						heading 'SQL Handle'				format a30
col sql_text						heading 'SQL Text'					format a50
col plan_name						heading 'Plan Name'						
col origin							heading 'Origin'
col enabled							heading 'Enabled'							
col accepted						heading 'Accepted'		
col fixed							heading 'Fixed'
col autopurge						heading 'Autopurge'
col spoolfile				heading 'Spool File Name'		format a50
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_spm_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Baseline Parameter Information :' skip 2

show parameter baseline

select parameter_name, parameter_value 
from dba_sql_management_config
/

tti off
tti Left 'Plan Count Information :' skip 2

select creator, count(*) cnt
from dba_sql_plan_baselines
where accepted='YES'
group by creator
order by 1
/

tti off
tti Left 'SQL Plan Baseline Information :' skip 2
select sql_handle, sql_text,plan_name,origin,enabled,accepted,fixed,autopurge
from dba_sql_plan_baselines
where rownum < 5
/

tti off
tti Left 'To Change Plan Retention Parameter :' skip 2
select 'exec DBMS_SPM.CONFIGURE(''plan_retention_weeks'',105);' Info 
from dual
/

tti off
tti Left 'To Change Space Budget Percent Parameter :' skip 2
select 'exec DBMS_SPM.CONFIGURE(''space_budget_percent'',105);' Info 
from dual
/

-- BEGIN
--  DBMS_SPM.CONFIGURE('space_budget_percent',30);
--END;
--/


--BEGIN
--  DBMS_SPM.CONFIGURE('plan_retention_weeks',105);
--END;
--/

spool off