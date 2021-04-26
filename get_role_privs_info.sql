-- 	File 		:	GET_ROLE_PRIVS_INFO.SQL
--	Description	:	Provides details of DBA Role Privileges
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 verify off
col Instance	 	heading 'Environment Info'   	format a100
col granted_role    heading 'Roles Granted'      	format a30
col privilege		heading 'Privileges Granted' 	format a30
col owner			heading 'Owner'				 	format a15
col table_name		heading 'Object Name'			format a30
col Grantee			heading 'Grantee'	
col spoolfile		heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\get_role_privs_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Roles in DB :' skip 2
select role 
from dba_roles 
order by 1
/

Accept lrole char Prompt 'Enter the Rolename : '

tti off
tti Left 'Role Information :' skip 2

select granted_role from role_role_privs
where role= upper(ltrim(rtrim(('&lrole')))) 
order by 1
/

tti off
tti Left 'SYS Privilege Information :' skip 2

select privilege from role_sys_privs
where role= upper(ltrim(rtrim(('&lrole')))) 
union
select privilege from dba_sys_privs
where grantee= upper(ltrim(rtrim(('&lrole')))) 
order by 1
/

tti off
tti Left 'Grantee Information :' skip 2

select grantee from dba_role_privs
where granted_role = upper(ltrim(rtrim(('&lrole')))) 
order by 1
/

tti off
tti Left 'Object Privilege Information :' skip 2

select owner, table_name, privilege from role_tab_privs
where role= upper(ltrim(rtrim(('&lrole')))) 
union
select owner, table_name, privilege from dba_tab_privs
where grantee= upper(ltrim(rtrim(('&lrole')))) 
order by 1,2
/

tti off
tti Left 'Object Column Information :' skip 2

select owner, table_name, column_name, privilege from dba_col_privs
where grantee= upper(ltrim(rtrim(('&lrole')))) 
order by 1,2
/

spool off