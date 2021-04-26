-- 	File 		:	GET_PARAMETER_INFO.SQL
--	Description	:	Provides details of Initialization Parameter.
--	Info			:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Name 			heading "Parameter Name" 			format a50
col value		 	heading "Current Value" 			format a30
col description	heading "Parameter Description" 	format a70
col def				heading "Default"						format a9
col ses				heading "Ses"							format a5
col sys				heading "Sys"							format a9
col ins				heading "Inst"							format a5
col spec				heading "SPFile"						format a6
col comm		 		heading "Comments"					format a10
col spoolfile		heading 'Spool File Name'			format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_parameter_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Parameter Information :' skip 2

Accept lparameter_name char Prompt 'Enter Parameter Name : '

select name,value,description,nvl(isdefault,'NA') def,
	isses_modifiable ses,issys_modifiable sys,isinstance_modifiable ins,nvl(update_comment,'N/A') comm
from v$parameter
where name like '%&lparameter_name%'
order by 1
/  

tti off
tti Left 'SP Parameter Information :' skip 2

select name,value,isspecified spec,nvl(update_comment,'N/A') comm
from v$spparameter
where name like '%&lparameter_name%'
order by 1
/  

tti off
tti Left 'Deprecated Parameter Information :' skip 2

select name
from v$parameter
where isdeprecated='TRUE'
order by 1
/  

tti off

spool off
 