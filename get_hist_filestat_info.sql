-- 	File 		:	GET_HIST_FILESTAT_INFO.SQL
--	Description	:	Provides details of Historical Database File IO Stats
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 				format a100
col tsname						heading 'Tablespace Name'				format a23
col date_time 					heading "Date Time"	
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
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_filestat_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select tablespace_name
from dba_tablespaces
order by 1
/

Accept ltablespace_name char Prompt 'Enter Tablespace Name: '

Accept ldays number Prompt 'How many Days of Historical Information: '

tti off
tti Left 'Filestat Information :' skip 2

select to_char(s.begin_interval_time, 'DD-Mon-YYYY HH24:MI:SS') date_time, tsname, 
	   ROUND(SUM(phyrds) / 1000) phyrds_1000,
	   ROUND(SUM(phyblkrd) / SUM(phyrds), 2) avg_blk_reads,
	   ROUND((SUM(readtim) + SUM(writetim)) / 100 / 3600, 2) iotime_hrs,
	   ROUND(SUM(phyrds + phywrts) * 100 / SUM(SUM(phyrds + phywrts)) OVER (), 2) pct_io, 
	   ROUND(SUM(phywrts) / 1000) phywrts_1000,
	   ROUND(SUM(singleblkrdtim) * 10 / SUM(singleblkrds), 2) single_rd_avg_time
from 
	(SELECT snap_id, instance_number, tsname, phyrds, phywrts, phyblkrd, phyblkwrt, singleblkrds, readtim, writetim, singleblkrdtim
	   FROM dba_hist_filestatxs, dba_temp_files
	   WHERE file# = file_id
	     and tsname = upper('&ltablespace_name')
	  UNION
	 SELECT snap_id, instance_number, tsname, phyrds, phywrts, phyblkrd, phyblkwrt, singleblkrds, readtim, writetim, singleblkrdtim
	   FROM dba_hist_filestatxs, dba_data_files
	   WHERE file# = file_id
	     and tsname = upper('&ltablespace_name')) f,
	dba_hist_snapshot s
where s.begin_interval_time between trunc(sysdate - &ldays) and sysdate
	and f.instance_number = s.instance_number
	and f.snap_id = s.snap_id
group by to_char(s.begin_interval_time, 'DD-Mon-YYYY HH24:MI:SS'), tsname
order by date_time, tsname
/

tti off
spool off