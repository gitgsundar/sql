set pages 9999 verify off
col Instance					heading 'Environment Info' 				format a100
col tablespace_name				heading 'Tablespace Name'				format a23
col file_name					heading 'File Name'						format a65
col phyrds_1000 				heading "Reads|\1000"					format 99,999,999 
col avg_blk_reads 				heading "Avg Blks|Per Read" 			format 99,999.99 	
col iotime_hrs 					heading "IO Time|(hrs)"					format 9,999,999 
col pct_io 						heading "Pct|IO Time"					format 99,999.99 
col phywrts_1000 				heading "Writes|\1000"					format 99,999,999 
col writetime_sec 				heading "Write Time|(s)"				format 99,999,999 
col singleblkrds_1000 			heading "Single blk|Reads\1000"			format 99,999,999 
col single_rd_avg_time 			heading "Single Blk|Rd Avg (ms)"		format 99,999.99 
col avg_read_time_ms 			heading "Avg Rd|(ms)"					format 99,999.99
col avg_write_Time_ms 			heading "Avg Wrt|(ms)"					format 99,999.99
col physical_reads 				heading "Phys|Reads"					format 99,999,999
col physical_writes 			heading "Phys|Writes"					format 99,999,999
col pct_ior 					heading "Pct|IO"						format 99,999.99
col blks_per_read 				heading "Blks|\Rd"						format 99,999.99
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_file_iostat_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

show parameter filesystemio_options

show parameter disk_asynch_io

tti off
tti Left 'Filestat Information by Tablespace:' skip 2

with filestat as 
    (SELECT tablespace_name, phyrds, phywrts, phyblkrd, phyblkwrt, singleblkrds, readtim, writetim, singleblkrdtim
       FROM v$tempstat, dba_temp_files
       WHERE file# = file_id
      UNION
     SELECT tablespace_name, phyrds, phywrts, phyblkrd, phyblkwrt, singleblkrds, readtim, writetim, singleblkrdtim
       FROM v$filestat, dba_data_files
       WHERE file# = file_id)
SELECT tablespace_name, ROUND(SUM(phyrds) / 1000) phyrds_1000,
       ROUND(SUM(phyblkrd) / SUM(phyrds), 2) avg_blk_reads,
       ROUND((SUM(readtim) + SUM(writetim)) / 100 / 3600, 2) iotime_hrs,
       ROUND(SUM(phyrds + phywrts) * 100 / SUM(SUM(phyrds + phywrts)) OVER (), 2) pct_io, 
       ROUND(SUM(phywrts) / 1000) phywrts_1000,
       ROUND(SUM(singleblkrdtim) * 10 / SUM(singleblkrds), 2) single_rd_avg_time
 FROM filestat 
GROUP BY tablespace_name
ORDER BY (SUM(readtim) + SUM(writetim)) DESC;

tti off
tti Left 'Filestat Information by Datafiles :' skip 2

SELECT tablespace_name, file_name,
       ROUND(AVG(average_read_time) * 10, 2) 	avg_read_time_ms,
       ROUND(AVG(average_write_time) * 10, 2)	 avg_write_time_ms,
       SUM(physical_reads) 				physical_reads, 
       SUM(physical_writes) 			physical_writes,
       ROUND((SUM(physical_reads) + SUM(physical_writes)) * 100 / SUM(SUM(physical_reads) + SUM(physical_writes)) OVER (), 2) pct_ior,
       CASE
          WHEN SUM(physical_reads) > 0 THEN
             ROUND(SUM(physical_block_reads) / SUM(physical_reads), 2)
       END  blks_per_read
FROM v$filemetric m, dba_data_files f
WHERE m.file_id = f.file_id
GROUP BY tablespace_name, file_name, end_time
ORDER BY 7 DESC;


tti off
spool off