set pages 9999 
set verify off
col Instance				heading 'Environment Info' 				format a100
column 	block_size_kb		heading "Block|Size K"				 	format 99 
column 	free_waits		 	heading "Free Buff|Wait"				format 999,999,999 
column 	write_waits			heading "Write Buff|Wait"				format 999,999,999
column 	busy_waits		 	heading "Buff Busy|Wait"				format 999,999,999 
column 	db_change 			heading "DB Block|Chg /1000"			format 999,999,999 
column 	db_gets 			heading "DB Block|Gets /1000"			format 999,999,999 
column 	con_gets 			heading "Consistent|gets /1000"			format 999,999,999 
column 	phys_rds 			heading "Physical|Reads /1000"			format 999,999,999 
column 	current_size 		heading "Current|MB"					format 999,999 
column 	prev_size 			heading "Prev|MB"						format 999,999 
column 	category 			heading "Category"						format a12 
column 	db_block 			heading "DB Block|Gets"					format 999,999,999,999 
column 	consistent 			heading "Consistent|Gets"				format 999,999,999,999 
column 	physical 			heading "Physical|Gets"					format 999,999,999,999 
column  hit_rate 			heading "Hit|Rate"						format 99.99 
column 	class 				heading "Buffer Type"					format a30
column 	count 				heading "Counts"						format 9,999,999
column 	time				heading "Time"							format 999,999,999
column 	pct 				heading "Percent"						format 999.99
column 	owner 				heading "Owner"							format a20
column 	object_name 		heading "Object Name"					format a30
column 	buffer_busy_count 	heading "Count"							format 999,999,999
column	spoolfile			heading 'Spool File Name'				format a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_buffers_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Buffer Pools I/O Information:' skip 2

SELECT b.name, b.block_size / 1024 block_size_kb, 
       current_size, prev_size,
       ROUND(db_block_gets / 1000) db_gets,
       ROUND(consistent_gets / 1000) con_gets,
       ROUND(physical_reads / 1000) phys_rds
FROM v$buffer_pool_statistics s, v$buffer_pool b
WHERE (b.name = s.name AND b.block_size = s.block_size)
/   

tti off
tti Left 'Buffer Pools Waits Information:' skip 2


SELECT b.name, b.block_size / 1024 block_size_kb, 
       current_size, prev_size,
       ROUND(free_buffer_wait / 1000) free_waits,
       ROUND(write_complete_wait / 1000) write_waits,
       ROUND(buffer_busy_wait / 1000) busy_waits
FROM v$buffer_pool_statistics s, v$buffer_pool b
WHERE (b.name = s.name AND b.block_size = s.block_size)
/   

tti off
tti Left 'Hit Ratio Information:' skip 2

WITH sysstats AS
    (SELECT CASE WHEN name LIKE '%direct' THEN 'Direct'
                 WHEN name LIKE '%cache' THEN 'Cache'
                  ELSE 'All' END AS category,
            CASE WHEN name LIKE 'consistent%' THEN 'Consistent'
                 WHEN name LIKE 'db block%' THEN 'db block'
                 ELSE 'physical' END AS TYPE, VALUE
       FROM v$sysstat
      WHERE name IN ('consistent gets','consistent gets direct',
                     'consistent gets from cache','db block gets',
                     'db block gets direct', 'db block gets from cache',
                     'physical reads', 'physical reads cache',
                     'physical reads direct'))
SELECT category, db_block, consistent, physical,
       ROUND(DECODE(category,'Direct', NULL,
                ((db_block + consistent) - physical)* 100
                    / (db_block + consistent)), 2) AS hit_rate
FROM (SELECT category, SUM(DECODE(TYPE, 'db block', VALUE)) db_block,
             SUM(DECODE(TYPE, 'Consistent', VALUE)) consistent,
             SUM(DECODE(TYPE, 'physical', VALUE)) physical
      FROM sysstats
      GROUP BY category)
ORDER BY category DESC
/

tti off
tti Left 'Buffer Busy Waits by Type Information:' skip 2

SELECT class, COUNT, time, 
       ROUND(time * 100 / SUM(time) OVER (), 2) pct
FROM v$waitstat
ORDER BY time DESC
/

tti off
tti Left 'Buffer Busy Waits by Segment Information:' skip 2

SELECT owner, object_name, SUM(VALUE) buffer_busy_count ,
        round(sum(value) * 100/sum(sum(value)) over(),2) pct       
FROM v$segment_statistics
WHERE statistic_name IN ('gc buffer busy', 'buffer busy waits') 
	  AND VALUE > 0
	  and owner not in ('SYS')
HAVING SUM(VALUE) > 1000
GROUP BY owner, object_name
ORDER BY SUM(VALUE) DESC
/

spool off