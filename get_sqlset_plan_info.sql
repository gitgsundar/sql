-- 	File 		:	GET_SQLSET_INFO.SQL
--	Description	:	Provides Details of SQL Tuning Sets Plan Information.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 long 9999
col Instance					heading "Environment Info"	format a100
col name						heading "Sqlset Name" 		format a30
col owner						heading "Owner"				format a15
col description					heading "Description"		format a50
col created						heading "Created Date"		
col statement_count				heading "Sql Count"

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_sqlset_plan_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select name,owner,created,statement_count,nvl(description,'No Description') description
from dba_sqlset
/

Accept lsqlset char Prompt 'Enter Sqlset Name : '
Accept lsqlset_id char Prompt  'Enter Sql Id : '

select * from table(dbms_xplan.display_sqlset(upper('&lsqlset'),'&lsqlset_id'))
/

spool off