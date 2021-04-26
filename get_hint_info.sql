-- 	File 		:	GET_HINT_INFO.SQL
--	Description	:	Provides details of Database Hints Available.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 200 verify off
col Instance				heading "Environment Info"	for a100
col Name		  			heading "Name" 				for a40
col sql_feature				heading "SQL Feature"		for a30
col class					heading "Class"				for a30
col inverse					heading "Inverse"			for a30
col	target_level			heading 'Target Level'
col property				heading 'Property'
col spoolfile				heading 'Spool File Name'	for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hint_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select name,sql_feature,class,inverse,target_level,property
from v$sql_hint
/
spool off