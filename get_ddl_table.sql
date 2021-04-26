-- 	File 		:	GET_DDL_TABLE.SQL
--	Description	:	Extracts DDL for a table in the Database
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 long 99999
set echo off
col Name 			heading "Parameter Name" 			format a40
col value		 	heading "Current Value" 			format a30
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

Accept ltable_name char Prompt 'Enter the Table Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltable_name');

tti off
tti Left 'Table Owner Information :' skip 2

select owner,table_name 
from dba_tables
where table_name= :b0
/

Accept lowner char Prompt 'Enter the Table Owner : '
variable b1 varchar2(50);
exec 	:b1 := upper('&lowner');

tti Left 'Table DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select dbms_metadata.get_ddl(object_type=>'TABLE',name=>i.table_name,schema=>i.owner) sql_text
from dba_tables i
where table_name  = :b0
  and owner       = :b1
/
spool off
