-- 	File 		:	GET_FEATURE_INFO.SQL
--	Description	:	Provides details of Database Features Used.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 500
set echo off
col Instance		heading "Environment Info"		for a100
col name			heading 'Feature Name'			for a60
col description	    heading 'Description'			for a100
col last_usage_date	heading 'Last Used'				for a20
col version			heading 'Version'				for a15
col spoolfile		heading 'Spool File Name'		for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_feature_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'DB Features Used Info :' skip 2

select name,description,version,last_usage_date
from dba_feature_usage_statistics
where detected_usages > 0
order by last_usage_date
/

tti off

Accept lfeedback  char Prompt 'Need Complete Report of DB Features? (Y/N): '

tti Left 'Need Complete Report of DB Features :' skip 2

declare
begin
	if upper('&lfeedback')='Y' then
		for i in (select * From table(dbms_feature_usage_report.display_text)) loop
		    dbms_output.put_line(i.output);
	    end loop;
	end if;
end;
/

tti off
spool off