-- 	File 		:	GET_DDL_PUBLIC_SYNONYM.SQL
--	Description	:	Extracts DDL for Public SYNONYMS in the Database
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off
col Name 			heading "Parameter Name" 		format a40
col value		 	heading "Current Value" 		format a30
col sql_text   	    heading "Public Synonym DDL Description" 	format a2000
col spoolfile		heading 'Spool File Name'		format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_public_synonym_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Public Synonym DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select dbms_metadata.get_ddl(object_type=>'SYNONYM',name=>i.synonym_name,schema=>'PUBLIC') sql_text
from dba_synonyms i
where table_owner not in ('APPQOSSYS','EXFSYS','SYS','SYSTEM','WMSYS','XDB')
and owner='PUBLIC'
order by table_owner
/
spool off
