-- 	File 		:	GET_HIST_SQLMONITOR_INFO.SQL
--	Description	:	Provides Historical Real time SQL Monitor Details of SQL based on SQLID
--	Info		:	Update Spool information as required to get the spool output.

col Instance					heading "Environment Info"			format a100
col Sql_ID						heading "Sql ID"					format a13
col report_id					heading 'Report ID'					format 9999999
col generation_time				heading 'Report Date'
col info						heading 'More Information'			format a150   wrap
col spoolfile					heading 'Spool File Name'			format a100		

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_sqlmonitor_info_'||to_char(sysdate,'yyyymmdd_hhmiss')||'.html' spoolfile from dual
/

Accept ldays number Prompt 'How many Days of Historical Information: '
Accept lsql_id char Prompt 'Enter the Sql ID: '

tti off
tti Left 'Historical Report ID Details :' skip 2


SELECT report_id, generation_time
FROM dba_hist_reports
WHERE component_name = 'sqlmonitor'
	AND report_name = 'main'
	AND period_start_time >= trunc(sysdate-&ldays)
AND key1 = '&lsql_id'
/

tti off
tti Left 'Historical SQL Monitor Report :' skip 2
tti off

Accept lid number Prompt 'Enter the Report ID: '

set long 99999 pages 0 verify off trimspool ON TRIM ON linesize 32767 LONG 1000000 longchunksize 1000000
spool &spoolfile

SELECT dbms_auto_report.Report_repository_detail(rid=>'&lid', TYPE=>'active')
FROM dual;

spool off

tti off
tti Left 'More Info :' skip 2

select 'Use $OH/rdbms/admin/perfhubrpt.sql to generate Historical SQL Monitor Reports for all Sqls for a given period of Time' Info
from dual
/

