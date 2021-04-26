-- 	File 		:	GET_SOURCE_CODE_INFO.SQL
--	Description	:	Extract Source Code of the Object.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off long 999999
col Instance	 	heading 'Environment Info'  format a100
col owner			heading 'Owner'				format a15
col text 			heading 'Pl/SqlSource Code'	format a150
col spoolfile		heading 'Spool File Name'	format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_source_code_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lcode_name char Prompt 'Enter the PLSQL Code Name : '

variable b0 varchar2(50);
exec 	:b0 := upper('&lcode_name');


tti off
tti Left 'PL/SQL Soucre Code Information :' skip 2

select text 
from dba_source
where name = ltrim(rtrim((:b0))) 
/

tti off
spool off