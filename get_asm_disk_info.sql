-- 	File 			:	GET_ASM_DISK_INFO.SQL
--		Description	:	Provides details of ASM Disk Information.
--		Info			:	Update Spool information as required to get the spool output.
--						:	Must to run against ASM Instance.

set pages 9999 
set verify off
col Instance				heading 'Environment Info' 	format a100
col Disk_Group				heading 'Group Name'				format a15
col Disk_Name				heading 'ASM Disk'				format a20
col path				   	heading 'Disk Path'				format a30
col Allocation_unit_size	heading 'Allocation|Unit Size' format 999,999,999
col sector_size			heading 'Sector|Size'			format 99,999
col block_size				heading 'Block|Size'				format 99,999
col alloted_bytes 		heading 'Alloted Size(MB)'			format 99,999,999,999,999
col used_bytes 			heading 'Used Size(MB)'				format 99,999,999,999,999
col free_bytes 			heading 'Free Size(MB)'				format 99,999,999,999,999
col DBSpace_in_MB 		heading 'DB Space(Mbytes)' 	format 99,999,999,999,999
col percent_free  		heading 'Free %'					format 999.99
col contents				heading 'Contents'				format a9
col extent_management	heading 'Ext Mgt'					format a10
col type						heading 'File Type'				format a20
col file_count				heading 'Count'					format 9999
col state					heading 'State'					format a10
col logging					heading 'Log Mode'				format a9
col name 					heading "Diskgroup|Name"		format a30 
col total_gb 				heading "Size|GB"					format 9,999 
col active_disks 			heading "Active|Disks"			format 99 
col reads1k 				heading "Reads|/1000"			format 9,999,999 
col writes1k 				heading "Writes|/1000"			format 9,999,999 
col read_time 				heading "Read Time|Secs"		format 999,999 
col write_time 			heading "Write Time|Secs"		format 999,999 
col avg_read_ms 			heading "Avg Read|ms"			format 999.99 

tti off

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\get_asm_diskinfo_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'DiskGroup Space Information :' skip 2

break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb free_mb used_mb on report

select name Disk_Group, 
		sector_size, 
		block_size,
		allocation_unit_size,
		state, 
		type, voting_files, total_mb alloted_bytes,
		(total_mb - free_mb) used_bytes,
		free_mb free_bytes, 
		nvl(round((100*free_mb)/total_mb,2),0) percent_free 
from v$asm_diskgroup
order by 1
/

clear breaks computes

tti off
tti Left 'File Information :' skip 2

select type,count(*) file_count
from gv$asm_file 
group by type
order by 1
/

tti off
tti Left 'Disk I/O Throughput and Servicetime Information :' skip 2

SELECT name, ROUND(total_mb / 1024) total_gb, active_disks,
       reads / 1000 reads1k, writes / 1000 writes1k,
       ROUND(read_time) read_time, ROUND(write_time) write_time,
       ROUND(read_time * 1000 / reads, 2) avg_read_ms
FROM     v$asm_diskgroup_stat dg
     JOIN
         (SELECT group_number, COUNT(DISTINCT disk_number) active_disks,
                 SUM(reads) reads, SUM(writes) writes,
                 SUM(read_time) read_time, SUM(write_time) write_time
          FROM gv$asm_disk_stat
          WHERE mount_status = 'CACHED'
          GROUP BY group_number) ds
     ON (ds.group_number = dg.group_number)
ORDER BY dg.group_number
/

tti off
spool off