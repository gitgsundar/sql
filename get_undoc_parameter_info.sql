-- 	File 		:	GET_UNDOC_PARAMETER_INFO.SQL
--	Description	:	Provides Details of Undocumented Oracle Parameter.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
set echo off
col ksppinm 	heading "Parameter Name" 		format a40
col ksppdesc	heading "Description" 			format a70
col ksppstvl 	heading "Current VAL" 			format a15
col ksppstdvl 	heading "Default VAL" 			format a15

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile	heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_undoc_parameter_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti Left 'Parameter Information :' skip 2

select ksppinm,ksppstvl,ksppstdvl,ksppdesc 
from x$ksppi i ,x$ksppcv v
where i.indx=v.indx and 
ksppinm like '%&parameter_name%'
order by 1
/  
 
spool off 