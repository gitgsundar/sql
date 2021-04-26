set pages 9999 verify off lines 300 escape on 
set escape !
col Instance			heading 'Environment Info'		format a100
col table_name 			heading	'Table Name'			format a30
col last_analyzed		heading	'Date Analyzed'
col owner 				heading	'Owner'					format a15
col Info				heading 'If LAST_ANALYZED is NULL OR not Current, Execute below script' for a80
col spoolfile			heading 'Spool File Name'		format a50

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_fixed_stat_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Fixed Stats Information :' skip 2

select OWNER, TABLE_NAME, LAST_ANALYZED 
from dba_tab_statistics 
where table_name='X$KGLDP'
/

tti off
tti Left 'Fixed Stats Script Information :' skip 2

select 'To Gather Fixed Object Stats -> exec dbms_stats.gather_fixed_objects_stats;' Info
from dual
union
select 'To Gather Dictionary Stats   -> exec dbms_stats.gather_dictionary_stats;' Info
from dual
/

tti off
spool off