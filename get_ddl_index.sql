-- 	File 		:	GET_DDL_INDEX.SQL
--	Description	:	Extracts DDL for Index of a Table
--	Info		:	Update Spool information as required to get the spool output.

set serverout on pages 9999 verify off lines 200 long 99999
set echo off
col table_name		heading "Table Name"				format a30
col owner 			heading "Owner"						format a30
col sql_text   	    heading "Index DDL Description" 	format a2000
col spoolfile		heading 'Spool File Name'			format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ddl_table_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ltable_name char Prompt 'Enter the Table Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltable_name');

tti off
tti Left 'Table Owner Information :' skip 2

select owner,table_name 
from dba_tables
where table_name=:b0
/

Accept lowner char Prompt 'Enter the Table Owner : '
variable b1 varchar2(50);
exec 	:b1 := upper('&lowner');

select index_name 
from dba_indexes 
where table_name = :b0 
	and table_owner = :b1
union
select 'ALL'
from 
dual
/

Accept lindex_name char Prompt 'Enter the Index Name : '

tti Left 'Index DDL Information :' skip 2

exec DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);

declare
	lsql_text	varchar2(30000);
begin
	if upper('&lindex_name')='ALL' then
		for i in (select index_name from dba_indexes where table_name=upper('&ltable_name') and owner=upper('&lowner')) loop
			dbms_output.put_line('  DROP INDEX &lowner.'||upper(i.index_name)||';');
			select dbms_metadata.get_ddl(object_type=>'INDEX',name=>i.index_name,schema=>upper('&lowner')) into  lsql_text from dual;
			dbms_output.put_line(lsql_text);
			dbms_output.new_line;
		end loop;
	else
		dbms_output.put_line('  DROP INDEX &lowner.&lindex_name;');
		select dbms_metadata.get_ddl(object_type=>'INDEX',name=>upper('&lindex_name'),schema=>upper('&lowner')) into lsql_text from dual;
		dbms_output.put_line(lsql_text);
	end if;
end;
/

spool off
