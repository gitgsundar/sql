-- 	File 		:	GET_DDL_USER.SQL
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
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_user_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept luser char Prompt 'Enter the Userid : '

tti Left 'User DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

select dbms_metadata.get_ddl( 'USER',upper('&luser')) User_DDL from dual;

declare
	luser_ddl	varchar2(32000);
	no_grant	exception;
	pragma exception_init(no_grant, -31608);
begin
	begin
		select dbms_metadata.get_granted_ddl( 'ROLE_GRANT', upper('&luser')) User_DDL into luser_ddl from dual;
		dbms_output.put_line('Role Grants');
		dbms_output.put_line('');
		dbms_output.put_line(luser_ddl);
	exception
		when no_grant then
			dbms_output.put_line('No Roles Grants');
	end;
	begin
		select dbms_metadata.get_granted_ddl( 'OBJECT_GRANT', upper('&luser')) User_DDL into luser_ddl from dual;
		dbms_output.put_line('Object Grants');
		dbms_output.put_line('');
		dbms_output.put_line(luser_ddl);
	exception
		when no_grant then
			dbms_output.put_line('No Object Grants');
	end;
	begin
		select dbms_metadata.get_granted_ddl( 'SYSTEM_GRANT', upper('&luser')) User_DDL into luser_ddl from dual;
		dbms_output.put_line('System Grants');
		dbms_output.put_line('');
		dbms_output.put_line(luser_ddl);
	exception
		when no_grant then
			dbms_output.put_line('No System Grants');
	end;
	begin
		select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA',upper('&luser')) User_DDL into luser_ddl from dual;	
		dbms_output.put_line('Tablespace Quota Grants');
		dbms_output.put_line('');
		dbms_output.put_line(luser_ddl);
	exception
		when no_grant then
			dbms_output.put_line('No Tablespace Quota');
	end;		
end;
/

tti off

spool off