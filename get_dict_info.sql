-- 	File 		:	GET_DICT_INFO.SQL
--	Description	:	Provides Dictionary information of an object.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance		heading	'Environment Info'	format a100
col table_name 		heading	'Table Name'		format a30
col comments		heading	'Description'		format a70
col spoolfile		heading 'Spool File Name'	format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_dict_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ltable_name char Prompt 'Enter the Table Name > : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltable_name');


tti off
tti Left 'Table Information :' skip 2

select *
from dictionary
where table_name = :b0
order by 1	
/

tti off
spool off