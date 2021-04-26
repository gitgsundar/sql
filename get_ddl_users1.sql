-- 	File 		:	GET_DDL_USERS1.SQL
--	Description	:	Extracts DDL for DB Users in the Database of Specifiy Types to DATA_DUMP_DIR.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off
col Name 			heading "Parameter Name" 		format a40
col value		 	heading "Current Value" 		format a30
col sql_text   	    heading "User DDL Description" 	format a2000
col spoolfile		heading 'Spool File Name'		format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_users1_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/
declare
    lsql1  		varchar2(2000);
    sql_file 	utl_file.file_type;

begin
	select instance_name into lsql1 from v$instance;

	sql_file := utl_file.fopen('DATA_PUMP_DIR', 'user_recreate_'||lsql1||'.sql', 'w');

	DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

	for i in (select username from dba_users where regexp_like(username,'A[0-9]{6}')) 
	loop
		select dbms_metadata.get_ddl( 'USER',i.username ) into lsql1 from dual;
		utl_file.put_line(sql_file,lsql1);
	end loop;

	for i in (select distinct grantee from dba_sys_privs where regexp_like(grantee,'A[0-9]{6}')) 
	loop
		select dbms_metadata.get_granted_ddl( 'SYSTEM_GRANT', i.grantee ) into lsql1 from dual;
		utl_file.put_line(sql_file,lsql1);
	end loop;

	for i in (select distinct grantee from dba_role_privs where regexp_like(grantee,'A[0-9]{6}')) 
	loop
		select dbms_metadata.get_granted_ddl( 'ROLE_GRANT', i.grantee ) into lsql1 from dual;
		utl_file.put_line(sql_file,lsql1);
	end loop;

	for i in (select distinct grantee from dba_tab_privs where regexp_like(grantee,'A[0-9]{6}')) 
	loop
		select dbms_metadata.get_granted_ddl( 'OBJECT_GRANT', i.grantee ) into lsql1 from dual;
		utl_file.put_line(sql_file,lsql1);
	end loop;

	utl_file.fclose(sql_file);
end;
/

tti off

spool off