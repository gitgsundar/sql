-- 	File 		:	GET_HIST_SQLPLAN1_INFO.SQL
--	Description	:	Provides Historical SQL Plan Information of Sql Text
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"		format a100
col Sql		  					heading "Sql Statement" 		format a120
col Sql_ID						heading "Sql ID"				format a13
col plan_table_output			heading "Execution Plan"
col spoolfile					heading 'Spool File Name'		format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_sqlplan1_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql char Prompt 'Enter the Sql: '

select sql_id Sql_ID, sql_text Sql
from DBA_HIST_SQLTEXT 
where sql_text like '%&lsql%'
/

Accept lsql_id char Prompt 'Enter the Sql ID: '

SELECT tf.* 
FROM DBA_HIST_SQLTEXT ht, table(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf
WHERE ht.sql_id='&lsql_id'
/

spool off