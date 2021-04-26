set pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col owner						heading "Owner" 			format a15
col index_name					heading "Index"				format a35
col table_name	 				heading "Table"				format a35
col monitoring					heading "Monitored"			format a9
col used						heading "Used"				format a4
col start_monitoring			heading "Monitoring Start Date"		
col end_monitoring				heading "Monitoring End Date"	

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_index_usage_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Index Usage Information :' skip 2

select u.name owner, io.name index_name, t.name table_name,
   decode(bitand(i.flags, 65536), 0, 'NO', 'YES') monitoring,
   decode(bitand(ou.flags, 1), 0, 'NO', 'YES') used,
   ou.start_monitoring start_monitoring,
   ou.end_monitoring end_monitoring
from sys.user$ u, sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where i.obj#    = ou.obj#
	and io.obj# = ou.obj#
	and t.obj#  = i.bo#
	and u.user# = io.owner#
order by 1,6	
/

select * 
from v$object_usage
/

spool off