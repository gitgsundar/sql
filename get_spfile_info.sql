-- 	File 		:	GET_SPFILE_INFO.SQL
--	Description	:	Provides details of SPFILE.
--	Info			:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 350
set echo off
col sid				heading "Sid"							format a10
col Name 			heading "Parameter Name" 			format a50
col value		 	heading "Current Value" 			format a80
col display_value	heading "Display Value"				format a80
col description	heading "Parameter Description" 	format a70
col def				heading "Default"						format a9
col ses				heading "Ses"							format a5
col sys				heading "Sys"							format a9
col ins				heading "Inst"							format a5
col spec				heading "SPFile"						format a6
col comm		 		heading "Comments"					format a50
col spoolfile		heading 'Spool File Name'			format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_spfile_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'SP file Information :' skip 2

select value 
from v$parameter 
where name='spfile'
/

tti off
tti Left 'Contents of SP File :' skip 2

select distinct sid,name,value,display_value
from v$spparameter
where isspecified='TRUE'
order by 1
/  

tti off

spool off
 