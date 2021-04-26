-- 	File 		:	GET_USER_PRIVS_INFO.SQL
--	Description	:	Provides Details of User Privileges.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance	 		heading 'Environment Info'   format a100
col granted_role     	heading 'Roles Granted'      format a30
col privilege			heading 'Privileges Granted' format a30
col owner				heading 'Owner'				 format a15
col table_name			heading 'Table Name'		 format a30
col username			heading 'User'				 format a20
col all_containers		heading 'All Cnt'
col container_name		heading 'Container Name'	 format a30


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_user_privs_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lusername char Prompt 'Enter the Username : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lusername');


tti off
tti Left 'Role Information :' skip 2

select granted_role from dba_role_privs
where grantee=ltrim(rtrim(:b0)) 
order by 1
/

tti off
tti Left 'SYS Privilege Information :' skip 2

select privilege from role_sys_privs
where role=ltrim(rtrim(:b0))
union
select privilege from dba_sys_privs
where grantee=ltrim(rtrim(:b0)) 
order by 1
/

tti off
tti Left 'Object Privilege Information :' skip 2

select owner, table_name, privilege 
from dba_tab_privs
where grantee=ltrim(rtrim(:b0)) 
order by 1
/

tti off
tti Left 'Container Data Information :' skip 2
select owner, object_name, all_containers,nvl(container_name,'All Containers') container_name
from dba_container_data
where username=ltrim(rtrim(:b0))
/	

spool off
