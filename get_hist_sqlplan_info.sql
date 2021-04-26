-- 	File 		:	GET_HIST_SQLPLAN_INFO.SQL
--	Description	:	Provides Historical SQL Plan Information of SQLID
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"	format a100
col Sql		  					heading "Sql Statement" 	format a60
col Sql_ID						heading "Sql ID"			format a13
col Plan_Hash_Value				heading "Plan Hash Value"	format 999999999999
col timestamp					heading "Timestamp"
col plan_table_output			heading "Execution Plan"

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_sqlplan_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_id char Prompt 'Enter the Sql ID: '

select distinct sql_id Sql_ID, PLAN_HASH_VALUE Plan_Hash_Value, to_char(timestamp,'DD-MON-YYYY HH24:MI:SS') timestamp
from DBA_HIST_SQL_PLAN 
where sql_id= '&lsql_id'
/

SELECT tf.* 
FROM DBA_HIST_SQLTEXT ht, table(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf
WHERE ht.sql_id='&lsql_id'
/

spool off
