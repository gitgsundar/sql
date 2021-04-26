-- 	File 		:	GET_DDL_ROLE.SQL
--	Description	:	Extracts DDL for a User in the Database
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off 
set longchunksize 500000
col Instance		heading "Environment Info"		format a100
col sql_text   	    heading "User DDL Description" 	format a2000
col spoolfile		heading 'Spool File Name'		format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

tti off
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_role_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lrole char Prompt 'Enter the Role Name : '

tti Left 'Role DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

variable v_role VARCHAR2(30);
exec :v_role := upper('&lrole');

select dbms_metadata.get_ddl('ROLE', r.role) AS ddl
from   dba_roles r
where  r.role = :v_role
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_role
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee = :v_role
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee = :v_role
and    rownum = 1
/

tti off

spool off