-- 	File 		:	GET_DEPENDENCY_INFO.SQL
--	Description	:	Provides details of Database Object Dependencies
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance			heading 'Environment Info'		format a100
col bytes				heading	'Bytes'					format 99999999999
col object_name			heading 'Object Name'			format a30
col object_type			heading 'Object Type' 			format a20
col created				heading 'Created Date'
col last_ddl_time		heading 'Last Updated Time'
col name				heading 'Object Name'			format a30
col type				heading 'Object Type' 			format a20
col referenced_owner 	heading	'Owner'					format a15
col spoolfile			heading 'Spool File Name'		format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dependency_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lobject_name char Prompt 'Enter the Object Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lobject_name');


tti off
tti Left 'Object Information :' skip 2

select owner,object_name,object_type,created,status,last_ddl_time
from dba_objects
where object_name= :b0
/

tti off
tti Left 'Object References Information :' skip 2

select name, type, referenced_owner, dependency_type
from dba_dependencies
where referenced_name= :b0
order by 2,3,1
/

tti off
spool off