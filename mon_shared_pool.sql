-- 	File 		:	MON_SHARED_POOL.SQL
--	Description	:	Monitor Shared Pools
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance			heading 'Environment Info' 			format a100
col kghlurcr 			heading "Recurrent|Chunks"
col kghlutrn 			heading "Transient|Chunks"
col kghlufsh 			heading "Flushed|Chunks"
col kghluops 			heading "Pins and|Releases"
col kghlunfu 			heading "ORA-4031|Errors"
col kghlunfs 			heading "Last Error|Size"
col kghlushrpool 		heading "Subpool" 
col stmt			heading "SQL Statement"				format a90 wrap
col sql_id			heading "Sql-ID"
col count			heading "Count"
col open			heading "Open"						format 9999
col exec			heading "Executions"				format 99,999,999
col component			Heading "Component" 				format a30
col user_size			Heading "User|Size(Mb)"
col current_size		Heading "Current|Size(Mb)"
col min_size			Heading "Min|Size(Mb)"
col user_specified		Heading "User|Specified Size(Mb)"
col parameter			Heading "Parameter" 				format a25
col request_failures	Heading "Failures|ORA-4031"			format 9,999,999
col last_failure_size	Heading	"Failure Size"				format 9,999,999
col free_space			Heading "Total Space"				format 999,999,999,999
col avg_free_size		Heading "Avg Space"					format 99,999,999
col max_free_size		Heading "Max Free Space"			format 99,999,999
col max_miss_size		Heading "Max Miss Space"			format 99,999,999
col oper_type			Heading "Operation"
col oper_mode			heading "Op Mode"
col initial_size		heading "Init Size"
col target_size			heading "Target Size"
col final_size 			heading "Final Size"
col status			heading "Status"					format a10
col start_time			heading "Start Time"
col end_time			heading "End Time"
col resizeable 			heading "Auto"						format a4
col Name			heading "Pool Names"				format a32
col bytes			heading "Bytes"						format 999,999,999,999
col spoolfile			heading 'Spool File Name'			format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
col spoolfile		heading 'Spool File Name'			format a150
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_shared_pool_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select kghlushrpool,kghlurcr,kghlutrn,kghlufsh,kghluops,kghlunfu,kghlunfs
from sys.x$kghlu
where inst_id = userenv('Instance')
/

Accept lsize char Prompt 'Enter value for Sharable Memory Size(Mbytes) : '

tti off
tti Left 'SQL Information having Memory Size Specified:' skip 2

SELECT sql_text "Stmt", sql_id, count(*) count,sum(sharable_mem) "Mem",sum(users_opening) "Open",sum(executions)  "Exec"
FROM v$sql
GROUP BY sql_text,sql_id
HAVING sum(sharable_mem)/1024/1024 > &lsize
ORDER BY sum(sharable_mem)
/

tti off
tti Left 'SGA Resize Operation Information:' skip 2

select component,oper_type,oper_mode, parameter,
       initial_size/1024/1024 initial_size,
       target_size/1024/1024  target_size,
       final_size/1024/1024   final_size,
       status, start_time,end_time
from v$memory_resize_ops 
order by start_time desc
/

tti off
tti Left 'More Information:' skip 2

select component,user_specified_size/1024/1024 user_size,
	   current_size/1024/1024 current_size, 
       min_size/1024/1024 min_size,
       user_specified_size/1024/1024 user_specified
from v$memory_dynamic_components
order by 1
/

tti off
tti Left 'SGA Information:' skip 2

select * from v$sgainfo order by 3
/

tti off
tti Left 'Any 4031 Errors Information :' skip 2

select free_space, avg_free_size, max_free_size, max_miss_size,request_failures, last_failure_size
from v$shared_pool_reserved
/

spool off