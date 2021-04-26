-- 	File 		:	GET_PROFILE_INFO.SQL
--	Description	:	Provides details of Database Profiles
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance			heading "Environment Info"	format a100
col profile				heading "Profile" 			format a30
col username			heading "Account"			format a25
col resource_name		heading "Resource Name"		format a30
col resource_type		heading "Type"				format a8
col limit				heading "Limit"				format a30
col account_status		heading "Account Status"	format a25
col spoolfile			heading 'Spool File Name'	format a100
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_profile_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Profiles in this DB :' skip 2

select distinct profile
from dba_profiles
order by 1
/

Accept lprofile char Prompt 'Enter the Profile Name : '

tti off
tti Left 'Profile Information :' skip 2

select resource_name,resource_type,limit
from dba_profiles
where profile=upper('&lprofile')
/

tti off
tti Left 'Users with selected Profile :' skip 2

select username,account_status
from dba_users 
where profile=upper('&lprofile')
order by 1
/

tti off
spool off