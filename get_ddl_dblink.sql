-- 	File 		:	GET_DDL_DBLINK.SQL
--	Description	:	Extracts DDL for DBLinks in the Database
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off
col Name 			heading "Parameter Name" 		format a40
col value		 	heading "Current Value" 		format a30
col sql_text   	    heading "DB Link Description" 	format a200
col spoolfile		heading 'Spool File Name'		format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_dblink_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Link Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select dbms_metadata.get_ddl('DB_LINK',l.db_link,l.owner) sql_text 
from dba_db_links l
/

tti off
spool off