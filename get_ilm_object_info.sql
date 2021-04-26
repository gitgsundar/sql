-- 	File 		:	GET_ILM_OBJECT_INFO.SQL
--	Description	:	Provides details of the ILM - Information LifeCycle Management using ADO (Automatic Data Optimization)
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance									heading 'Environment Info' 	format a100
col name											heading 'Name'							format a30
col value											heading 'Value'							format 99999
col con_id										heading 'ConID'							format 99999
col object_name								heading 'Object'						format a30
col subobject_name						heading 'Sub Object'				format a30
col track_time								heading 'Track Time'				format a30
col policy_name								heading 'Policy Name'				format a20
col action_type								heading 'Action Type'
col inherited_from 						heading 'Inherited From'
col scope											heading 'Scope'
col compression_level					heading 'Compression Lvl'		format a20
col tier_tablespace						heading 'Tablespace Tier'		format a50
col tier_status								heading 'Tier Status'
col condition_days						heading 'Days'							format 9999
col policy_subtype						heading 'Policy Subtype'
col action_clause							heading 'Action Clause'			format a20
col enabled										heading 'Enabled'
col Info                      heading 'Run below Command to manipulate Heat Map Settings'  for a80
col Cust_Info                 heading 'Use below Packages to manage ILM Parameters'  for a80

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ilm_object_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/


Accept lowner char Prompt 'Enter the Object Owner : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lowner');

tti off
tti Left 'ILM Object Information :' skip 2
select policy_name, object_name, object_type, inherited_from, enabled, deleted
from dba_ilmobjects
where object_owner=:b0
/

tti off
tti Left 'ILM Object Policy Information :' skip 2
select policy_name, action_type, scope, compression_level, tier_tablespace, tier_status, condition_type, condition_days, policy_subtype, action_clause 
from dba_ilmdatamovementpolicies
/

tti off
spool off


/*

-- Force ADO Task to run 

declare
	ltask_id	number;
begin
	dbms_ilm.execute_ilm(ilm_scope => dbms_ilm.scope_schema,
											execution_mode => dbms_ilm.ilm_execution_offline,
											task_id	=> ltask_id);
end;
/


*/