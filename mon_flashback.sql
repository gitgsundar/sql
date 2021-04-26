set pages 9999 verify off lines 300
set echo off
col Instance					heading "Environment Info"			for a100
col name							heading 'Parameter Name'			for a50
col value						heading 'Value'						for a30
col flashback_on				heading 'Flashback Status'			for a20
tti off

col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_flashback_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'RestorePoint Info :' skip 2

select NAME,SCN,TIME from v$restore_point; 

tti off

tti Left 'Flashback Status :' skip 2

select * From v$flashback_database_stat
/
select * From v$flashback_database_log
/
select * from v$session_longops where opname like 'Flashback%'
/

tti off

spool off