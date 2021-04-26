-- 	File 		:	GET_SPM_DETAILS_INFO.SQL
--	Description	:	Provides Details of SPM (SQL Plan Management) Information.
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
col sql_handle					heading "Sql Handle"		format a25
col plan_name					heading "Plan Name"
col Optimizer_Cost				heading "Cost"
col Parsing_schema_name			heading "Owner"				format a15

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_spm_details_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'SPM Activity Information :' skip 2

Accept ldays number Prompt 'Enter Historical Days for Checking SPM Activity : '

select distinct a.sql_handle,parsing_schema_name,count(*) 
from dba_sql_plan_baselines a
where a.PARSING_SCHEMA_NAME not in
	('SYS', 'OUTLN', 'SYSTEM', 'CTXSYS', 'DBSNMP', 'LOGSTDBY_ADMINISTRATOR', 'ORDSYS', 'ORDPLUGINS', 'OEM_MONITOR',
	'WKSYS', 'WKPROXY', 'WK_TEST', 'WKUSER', 'MDSYS', 'LBACSYS', 'DMSYS', 'WMSYS', 'EXFSYS', 'SYSMAN','MDDATA',
	'SI_INFORMTN_SCHEMA', 'XDB', 'ODM', 'GALAXY','LANDMARK2', 'ORACLE_OCM') 
	and not regexp_like(upper(parsing_schema_name),'A[0-9]{6}')
	and created > sysdate - &ldays
having count(*) > 1
group by a.sql_handle,parsing_schema_name
order by 2,3
/

tti off
tti Left 'SQL Handle and Plan Information :' skip 2

Accept lsql_handle char Prompt 'Enter Sql Handle Plan Display from SPM : '

select a.sql_handle,a.plan_name,a.optimizer_cost,a.accepted,a.fixed,a.parsing_schema_name, a.executions,
		(a.elapsed_time)*power(10,-6) elapsed_time,
		(a.cpu_time)*power(10,-6) cpu_time, 
		a.disk_reads disk_reads,
		a.buffer_gets buffer_gets,
		a.rows_processed rows_processed
from dba_sql_plan_baselines a 
where a.sql_handle='&lsql_handle'
/

select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'&lsql_handle',format=>'ALL'))
/

spool off