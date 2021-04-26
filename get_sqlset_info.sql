-- 	File 		:	GET_SQLSET_INFO.SQL
--	Description	:	Provides Details of SQL Tuning Sets.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 long 9999
col Instance					heading "Environment Info"	format a100
col name						heading "Sqlset Name" 		format a30
col owner						heading "Owner"				format a15
col description					heading "Description"		format a50
col created						heading "Created Date"		
col last_modified				heading "Last Timestamp"		
col statement_count				heading "Sql Count"
col parsing_schema_name			heading "Schema"			format a20
col sqls						heading "Sql Count"
col sql_id						heading "Sql_Id"
col sql_text					heading "Sql"				format a50
col fetches						heading "Fetches"
col executions					heading "Executions"
col elapsed_time				heading "etime"	
col cpu_time					heading "CPU Time"
col buffer_gets					heading "LIO"
col disk_reads					heading "PIO"
col rows_processed				heading "Rows"
col plan_hash_value				heading "Plan Hash Value"

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_sqlset_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select name,owner,created,last_modified,statement_count,nvl(description,'No Description') description
from dba_sqlset
order by last_modified
/

Accept lsqlset char Prompt 'Enter Sqlset Name : '
Accept lowner char Prompt  'Enter Sqlset Owner : '


variable b0 varchar2(50);
exec 	:b0 := upper('&lsqlset');

variable b1 varchar2(50);
exec 	:b1 := upper('&lowner');


select parsing_schema_name, count(*) sqls
from dba_sqlset_statements
where sqlset_name = :b0
  and sqlset_owner = :b1
group by parsing_schema_name
order by 2
/

Accept lschema char Prompt  'Enter Application Schema Owner : '
variable b2 varchar2(50);
exec 	:b2 := upper('&lschema');


select sql_id,plan_hash_value,substr(sql_text,1,50) sql_text,fetches,executions,
		round(elapsed_time*power(10,-6),2) elapsed_time ,round(cpu_time*power(10,-6),2) cpu_time,
		buffer_gets,disk_reads,rows_processed
from dba_sqlset_statements
where sqlset_name = :b0
  and sqlset_owner = :b1
  and parsing_schema_name = :b2
order by cpu_time desc
/

spool off