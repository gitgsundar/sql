set pages 9999 verify off
col name					heading 'Name' 					format a50
col value 					heading 'Value' 				format 9999999999999999
col Unit					heading 'Measure' 				format a12
col target_mb				heading 'Target(MB)' 			format 99999999999
col cache_hit				heading 'Cache Hit%' 			format 99999999999
col alloc_cnt				heading 'Alloc(#)' 				format 99999999999
col spoolfile				heading 'Spool File Name'		format a100
col low_kb					heading 'Low_KB_Bkt'			format 999,999,999
col high_kb					heading 'High_KB_Bkt'			format 999,999,999
col optimal_executions		heading 'Opt Exec Count'		format 999,999,999
col onepass_executions		heading 'One-Pass Exec Count'	format 999,999,999
col multipasses_executions	heading 'Multi-Pass Exec Count'	format 999,999,999
col sid						heading 'Sid'					format 99999
col operation 				heading 'PGA Operation'			format a40
col esize					heading	'Est Size_KB'			format 999,999,999
col mem						heading	'Curr Size_KB'			format 999,999,999
col max_mem					heading	'Max Size_KB'			format 999,999,999
col pass					heading	'Passes'				format 999,999,999
col tsize					heading	'Temp Size_KB'			format 999,999,999
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_pga_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile
tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

show parameter pga

tti off
tti Left 'PGA Stat Information:' skip 2

select * from v$pgastat order by 1
/

tti off
tti Left 'PGA Target Advice Information:' skip 2

select round(pga_target_for_estimate/1024/1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit,
       estd_overalloc_count alloc_cnt
from v$pga_target_advice
/

tti off
tti Left 'PGA Performance Information:' skip 2

SELECT LOW_OPTIMAL_SIZE/1024 low_kb,(HIGH_OPTIMAL_SIZE+1)/1024 high_kb,
       optimal_executions, onepass_executions, multipasses_executions
FROM   v$sql_workarea_histogram
WHERE  total_executions != 0
/

tti off
tti Left 'PGA Active Work Areas Memory Usage(KB) Information:' skip 2

SELECT to_number(decode(SID, 65535, NULL, SID)) sid,
       operation_type OPERATION,trunc(EXPECTED_SIZE/1024) ESIZE,
       trunc(ACTUAL_MEM_USED/1024) MEM, trunc(MAX_MEM_USED/1024) "MAX MEM",
       NUMBER_PASSES PASS, trunc(TEMPSEG_SIZE/1024) TSIZE
FROM V$SQL_WORKAREA_ACTIVE
ORDER BY 1,2
/

tti off
spool off