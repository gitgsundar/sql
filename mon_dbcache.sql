-- 	File 		:	MON_DBCACHE.SQL
--	Description	:	Monitors Database Cache Details of the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance				heading 'Environment Info' 				format a100
column 	block_size_kb		heading "Block|Size K"				 	format 99 
column 	free_waits		 	heading "Free Buff|Wait"				format 999,999,999 
column 	write_waits			heading "Write Buff|Wait"				format 999,999,999

COLUMN size_for_estimate    heading 'Cache Size (MB)'      			FORMAT 999,999,999,999 
COLUMN buffers_for_estimate heading 'Buffers'					    FORMAT 999,999,999,999 
COLUMN estd_physical_read_factor  heading 'Estd Phys|Read Factor'	FORMAT 999.90  
COLUMN estd_physical_reads  heading 'Estd Phys|Reads'			    FORMAT 999,999,999,999 
COLUMN number_of_blocks 	heading "# Cached Blocks"				FORMAT 999,999,999,999
column owner 				heading "Owner"							format a20
column object_name 			heading "Object Name"					format a30
column objecT_type			heading "Object Type"					format a15
column buffer_busy_count 	heading "Count"							format 999,999,999
column current_size 		heading "Value"							format 999,999,999,999,999
column buffer_pool		 	heading "Cache"							format a10
column MBytes				heading "M-Bytes"						format 999,999,999,999,999
column spoolfile			heading 'Spool File Name'				format a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_dbcache_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Cache Advice Information:' skip 2

SELECT size_for_estimate, buffers_for_estimate, estd_physical_read_factor,
       estd_physical_reads
FROM V$DB_CACHE_ADVICE
WHERE name = 'DEFAULT'
   AND block_size = (SELECT value FROM V$PARAMETER WHERE name = 'db_block_size')
   AND advice_status = 'ON'
/   

tti off
tti Left 'Memory Components Information:' skip 2

select component, current_size
from v$memory_dynamic_components
where current_size > 0
order by 2
/

tti off
tti Left 'Objects in Cache Information:' skip 2

SELECT o.owner, o.object_name,o.objecT_type, s.buffer_pool,COUNT(*) number_of_blocks, count(*)*8192/1048576 MBytes
FROM DBA_OBJECTS o, V$BH bh, dba_segments s
WHERE o.data_object_id = bh.OBJD
   and o.object_name = s.segment_name
   AND o.owner NOT IN ('SYS','SYSTEM','XDB')
--   and s.buffer_pool='KEEP'
GROUP BY o.owner,o.object_Name,o.objecT_type,s.buffer_pool
ORDER BY s.buffer_pool,COUNT(*)
/   


spool off