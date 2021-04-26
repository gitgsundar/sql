-- 	File 		:	GET_SPM_PLAN_INFO.SQL
--	Description	:	Provides Details of SPM (SQL Plan Management) Plan Information.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 long 9999
col Instance					heading "Environment Info"	format a100
col name						heading "Sqlset Name" 		format a30
col owner						heading "Owner"				format a15
col description					heading "Description"		format a50
col created						heading "Created Date"		
col statement_count				heading "Sql Count"
col executions  				heading "Exe(#)" 			format 999999
col buffer_gets  				heading "Avg LI/O(#)" 		format 9999999999
col disk_reads  				heading "Avg PI/O(#)" 		format 999999
col sorts						heading "Sorts"				format 999999
col parse_calls					heading "Parse(#)" 			format 999999
col Invalidations  				heading "Invalid(#)" 		format 999999
col version_count				heading "Child Cursors"		format 999999
col cpu_time					heading "Avg CPU Time(s)"	format 999999
col elapsed_time				heading "Elapsed(s)"		format 999999
col rows_processed				heading "Rows(#)"			format 999999


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_spm_plan_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'SQL Plan Baseline Handles Information :' skip 2
select sql_handle 
from dba_sql_plan_baselines
/

tti off

Accept lsql_handle char Prompt 'Enter Sql Handle Plan Display from SPM : '

tti off
tti Left 'SQL Plan Information :' skip 2
select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'&lsql_handle',format=>'basic'))
/

tti off

tti off
tti Left 'SQL Plan Details in SQLAREA :' skip 2
select sql_id, plan_hash_value plan_hash, sum(executions) executions,
	(sum(elapsed_time)*power(10,-6))/sum(executions) Elapsed_time,
	sum(disk_reads)/sum(executions) Disk_reads,
	sum(buffer_gets)/sum(executions) Buffer_gets,
	(sum(cpu_time)*power(10,-6))/sum(executions) cpu_time
from v$sql s
where sql_plan_baseline in (select plan_name from dba_sql_plan_baselines where sql_handle= '&lsql_handle')
group by sql_id, plan_hash_value
/

tti off
spool off