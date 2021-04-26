-- 	File 		:	GET_SQLPROFILE_INFO.SQL
--	Description	:	Provides Details of SQL Profiles based on SQLID.
--	Info		:	Update Spool information as required to get the spool output.

set long 99999 pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col	sid							heading "Sid"
col serial#						heading "Serial#"
col username 					heading "Username"
col sql_text					heading "Sql Statement" 	format a1000
col hash_value				    heading "Hash Value"		format 99999999999
col plan_hash_value				heading "Plan Hash Value"	format 99999999999
col sql_profile					heading "Sql Profile"		format a30
col sql_id						heading "Sql ID"			format a15
col logon_time					heading "Logon Time-Stamp"
col status						heading "Status"			format a15
col executions  				heading "Exe(#)" 			format 9999999999
col buffer_gets  				heading "Avg LI/O(#)" 		format 9999999999
col disk_reads  				heading "Avg PI/O(#)" 		format 999999
col sorts						heading "Sorts"				format 999999
col parse_calls					heading "Parse(#)" 			format 999999
col Invalidations  				heading "Invalid(#)" 		format 999999
col version_count				heading "Child Cursors"		format 999999
col cpu_time					heading "Avg CPU Time(s)"	format 999999
col elapsed_time				heading "Elapsed(s)"		format 999999
col rows_processed				heading "Rows(#)"			format 999999
col loads						heading "Loads(#)"			format 999999
col name						heading "Bind Variable"		format a30
col value_string				heading "Bind Value"		format a50
col child_number				heading "Child#"

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_sqlprofile_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_id char Prompt 'Enter Sql ID : '

select name, signature,created, description, status, force_matching
from dba_sql_profiles
where sql_id = '&lsql_id'
order by 1, 2, 3
/

tti off
tti Left 'Session Information :' skip 2

select sid,serial#,username,logon_time,status,sql_id
from v$session
where sql_address in (select address 
							from v$sql s
							where s.sql_id  = '&lsql_id')
/

tti off
tti Left 'SQL Bind Information :' skip 2

select s.sql_id
	, c.bind_vars
	, b.datatype
	, b.value
from v$sql s, v$sql_bind_data b, v$sql_cursor c
where s.sql_id  = '&lsql_id'
  and s.address = c.parent_handle
  and c.curno   = b.cursor_num
/

select name, value_string
from v$sql_bind_capture
where sql_id = '&lsql_id'
/

tti off
tti Left 'SQL Execution Plan Information :' skip 2

select t.* 
from v$sql s, table(dbms_xplan.display_cursor(s.sql_id,s.child_number)) t
where s.sql_id = '&lsql_id'  
/

-- select name,value_string from dba_hist_sqlbind where sql_id='&lsql_id'

Accept lfeedback  char Prompt 'Want Outline Report of HINTS Used? (Y/N): '

declare
begin
	if upper('&lfeedback')='Y' then
		for i in (select * from table(dbms_xplan.display_cursor (sql_id=>'&lsql_id',cursor_child_no => 0, format=>'+outline'))) loop
		    dbms_output.put_line(i.plan_table_output);
	    end loop;
	end if;
end;
/

spool off