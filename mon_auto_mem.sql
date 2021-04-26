col Instance	heading  "Environment Info"	format a100
col component 	heading	"Component"				format a40
col oper_type 	heading	"Operation"				format a20
col Initial		heading	"Initial Size"			format 9,999,999
col Final		heading	"Final Size"			format 9,999,999
col start_time	heading 	"Start Time"			format a22
col end_time	heading 	"End Time"				format a22

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/
tti off

tti Left 'SGA Information :' skip 1

compute sum of bytes on pool
break on pool skip 1

select pool, name, bytes
from v$sgastat
order by pool, name
/

clear break compute

tti off

tti Left 'SGA Components Allocation Information :' skip 1

select START_TIME, component, oper_type, oper_mode, initial_size/1024/1024 "INITIAL", FINAL_SIZE/1024/1024 "FINAL", END_TIME
from v$sga_resize_ops
where component in ('DEFAULT buffer cache', 'shared pool') and status = 'COMPLETE'
order by start_time, component;

tti off
