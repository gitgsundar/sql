-- 	File 		:	GET_ERROR_INFO.SQL
--	Description	:	Provides details of Compliation Error on an Object.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance		heading "Environment Info"		for a100
col Owner			heading 'Owner'					for a15
col name			heading 'Code Name'				for a30
col code			heading 'Source Code'			for a75
col text			heading 'Error Text'			for a50
col line		    heading 'Line#'					for 999999
col spoolfile		heading 'Spool File Name'		for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_error_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Code that has Compile Errors :' skip 2

select distinct owner, name
from dba_errors
order by 1
/

tti off
tti Left 'Detail Error Info :' skip 2

Accept lowner char Prompt 'Enter Owner Name > : '
Accept lcode char Prompt 'Enter Code-Script Name > : '

variable b0 varchar2(50);
exec 	:b0 := upper('&lowner');

variable b1 varchar2(50);
exec 	:b1 := upper('&lcode');

select e.text text, e.line,s.text code
from dba_errors e, dba_source s
where e.owner = :b0
  and e.name  = :b1
  and e.owner = s.owner
  and e.name  = s.name
  and e.line  = s.line
order by line
/

tti off

spool off