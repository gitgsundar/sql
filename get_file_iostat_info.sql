set pages 9999 verify off
col Instance					heading 'Environment Info' 				format a100
col tablespace_name				heading 'Tablespace Name'				format a23
col access_method 				heading 'Method Used'					format a12
col asynch_io					heading 'Async IO'						format a10
col file_type 					heading "File Type"						format a15 
col free_bytes 					heading 'Free Bytes'					format 99,999,999,999,999
col file_name 					heading 'File Name' 					format a60
col file_id			  			heading 'File Id'						format 99999
col	small_read_servicetime 		heading 'Single Blk Read|Svc Time ms'	format 999,999,999,999
col	small_write_servicetime 	heading 'Single Blk Write|Svc Time ms'	format 999,999,999,999
col	large_read_servicetime 		heading 'Multi Blk Read|Svc Time ms'	format 999,999,999,999
col	large_write_servicetime 	heading 'Multi Blk Write|Svc Time ms'	format 999,999,999,999
col retries_on_error			heading 'Retries'						format 999,999,999
col filetype_name 				heading "File Type"						format a30 
col reads 						heading "Reads"                         format 999,999,999,999 
col writes 						heading "Writes"						format 999,999,999,999 
col read_time_sec 				heading "Read Time|sec"					format 999,999,999,999 
col write_time_sec 				heading "Write Time|sec"				format 999,999,999,999 
col avg_sync_read_ms 			heading "Avg Sync|Read ms"				format 999.99 
col total_io_seconds 			heading "Total IO|sec"					format 999,999,999,999 

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
tti Left 'Filestat IO Information :' skip 2

select tablespace_name,filetype_name file_type,asynch_io, access_method,
	nvl(case when small_read_reqs > 1 then (small_read_servicetime/small_read_reqs) end, 0) small_read_servicetime,
	nvl(case when small_write_reqs > 1 then (small_write_servicetime/small_write_reqs) end, 0) small_write_servicetime,
	nvl(case when large_read_reqs > 1 then (large_read_servicetime/large_read_reqs) end,0) large_read_servicetime,
	nvl(case when large_write_reqs > 1 then (large_write_servicetime/large_write_reqs) end,0) large_write_servicetime,
	retries_on_error
from  dba_data_files f,v$iostat_file i
where  f.file_id=i.file_no
order by 1
/

tti off
tti Left 'Summary Information :' skip 2

WITH iostat_file AS 
  (SELECT filetype_name,SUM(large_read_reqs) large_read_reqs,
          SUM(large_read_servicetime) large_read_servicetime,
          SUM(large_write_reqs) large_write_reqs,
          SUM(large_write_servicetime) large_write_servicetime,
          SUM(small_read_reqs) small_read_reqs,
          SUM(small_read_servicetime) small_read_servicetime,
          SUM(small_sync_read_latency) small_sync_read_latency,
          SUM(small_sync_read_reqs) small_sync_read_reqs,
          SUM(small_write_reqs) small_write_reqs,
          SUM(small_write_servicetime) small_write_servicetime
     FROM sys.v_$iostat_file
    GROUP BY filetype_name)
SELECT filetype_name, small_read_reqs + large_read_reqs reads,
       large_write_reqs + small_write_reqs writes,
       ROUND((small_read_servicetime + large_read_servicetime)/1000) 
          read_time_sec,
       ROUND((small_write_servicetime + large_write_servicetime)/1000) 
          write_time_sec,
       CASE WHEN small_sync_read_reqs > 0 THEN 
          ROUND(small_sync_read_latency / small_sync_read_reqs, 2) 
       END avg_sync_read_ms,
       ROUND((  small_read_servicetime+large_read_servicetime
              + small_write_servicetime + large_write_servicetime)
             / 1000, 2)  total_io_seconds
  FROM iostat_file
ORDER BY 7 DESC
/

tti off
spool off