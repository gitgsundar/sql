-- 	File 		:	GET_DDL_JOBS.SQL
--	Description	:	Extracts DDL for a table in the Database
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 long 99999
set echo off
col job 			heading "Job Name" 					format a50
col schema_user	 	heading "Owner" 					format a50
col sql_text   	    heading "Table DDL Description" 	format a2000
col spoolfile		heading 'Spool File Name'			format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_table_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select job, schema_user 
from dba_jobs
where schema_user != 'SYS'
/

Accept ljob_name char Prompt 'Enter the Job Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ljob_name');

Accept lowner char Prompt 'Enter the Job Owner : '
variable b1 varchar2(50);
exec 	:b1 := upper('&lowner');

tti Left 'Table DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select dbms_metadata.get_ddl(object_type=>'PROCOBJ',name=>:b0,schema=>:b1) sql_text
from dual
/
spool off
