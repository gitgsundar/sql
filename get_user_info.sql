-- 	File 		:	GET_USER_INFO.SQL
--	Description	:	Provides Details of a User.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col username					heading "Username" 			format a20
col account_status				heading "Status"			format a15
col lock_date					heading "Locked Date"	
col expiry_date					heading "Expiry Date"		
col created						heading "Created Date"		
col profile						heading "Profile"			format a30
col default_tablespace			heading "Default TS"		format a15
col resource_name				heading "Resource Name"		format a25
col resource_type				heading "Type"					
col limit						heading "Limit"				format a25
col lcount						heading "LoginFailed#"


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_user_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept luser char Prompt 'Enter the Userid : '
variable b0 varchar2(50);
exec 	:b0 := upper('&luser');

select username,account_status,lock_date,expiry_date,created,profile,default_tablespace 
from dba_users
where username=:b0
/

tti off
tti Left 'User Failed Login Count Information :' skip 2

select name,lcount 
from sys.user$
where name=:b0
/

tti off
tti Left 'Profile Information :' skip 2

select profile,resource_name,resource_type,limit
from dba_profiles
where profile in (select profile from dba_users where username=:b0)
order by 2
/

spool off
