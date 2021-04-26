set pages 9999 verify off
col Instance						heading "Environment Info"	format a100
col owner							heading "Owner"				format a15
col type								heading "Type"					format a15
col original_name					heading "Original Name"		format a30
col operation						heading "Opr"					format a9
col can_undrop						heading "Can|Undrop"			format a6
col can_purge						heading "Can|Purge"			format a6
col droptime						heading "Drop Time"


tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_recyclebin_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Recyclebin Information :' skip 2

select owner,original_name,type,operation,droptime,can_undrop,can_purge,space
from dba_recyclebin
order by owner,type,original_name
/

tti off
spool off