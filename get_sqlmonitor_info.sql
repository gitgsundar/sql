-- 	File 		:	GET_SQLMONITOR_INFO.SQL
--	Description	:	Provides Real time SQL Monitor Details of SQL based on SQLID.
--	Info		:	Update Spool information as required to get the spool output.

set long 99999 pages 0 verify off trimspool ON TRIM ON linesize 32767 LONG 1000000 longchunksize 1000000

col Instance					heading "Environment Info"	format a100
col info						heading 'More Information'	format a150   wrap

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_sqlmonitor_info_'||to_char(sysdate,'yyyymmdd-hh24miss')||'.html' spoolfile from dual
/

Accept lsql_id char Prompt 'Enter Sql ID : '
spool &spoolfile
 
SELECT dbms_sqltune.Report_sql_monitor(SQL_ID=>'&lsql_id',TYPE=>'active')
FROM   dual;
 
spool off

tti off
tti Left 'More Info :' skip 2

select 'Use $OH/rdbms/admin/perfhubrpt.sql to generate Historical SQL Monitor Reports for all Sqls for a given period of Time' Info
from dual
/
