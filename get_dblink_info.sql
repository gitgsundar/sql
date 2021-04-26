-- 	File 		:	GET_DBLINK_INFO.SQL
--	Description	:	Provides details of the Oracle Database Links
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off
col Name 			heading "Parameter Name" 	format a40
col value		 	heading "Current Value" 	format a30
col owner 			heading "Owner"				format a20
col db_link			heading "DB-Link"			format a30
col username 		heading "Username"			format a15
col host			heading "Host"				format a30
col created			heading "Created"
col spoolfile		heading 'Spool File Name'	format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dblink_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Database Link Information :' skip 2

select * from dba_db_links
/

tti off

tti Left 'Open Links Information :' skip 2

select * from v$dblink
/
 
spool off 