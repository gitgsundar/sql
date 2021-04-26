-- 	File 		:	GET_BCT_INFO.SQL
--	Description	:	Provides details of any Database Files not using BCT (Block Change Tracking)
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance				heading 'Environment Info' 	format a100
col datafile_blocks 		heading 'Blocks of File'	format 99,999,999,999,999
col blocks_read 			heading 'Blocks Read'		format 99,999,999,999,999
col backup_read 			heading 'Backup Blocks' 	format 99,999,999,999,999
col file#  					heading 'File No'			format 99999
col Status					heading 'Status'			format a10
col filename				heading 'File Name'			format a100
col bytes					heading 'Bytes'				format 999,999,999,999
col used_change_tracking	heading 'Status'			format a7
col Count					heading	'Count'				format 99999
col blocks_read				heading 'Blocks Read'		format 999,999,999,999
col total_blocks			heading 'Total Blocks'		format 999,999,999,999
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_bct_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Block Change Tracking(BCT) Information :' skip 2
tti off

select *
from v$block_change_tracking
/

tti Left 'Is Block Change Tracking(BCT) Used Information :' skip 2
tti off

select   used_change_tracking, count(*) Count, sum(blocks_read) Blocks_read, sum(datafile_blocks) Total_blocks, 
         trunc(sum(blocks_read)/sum(datafile_blocks)*100) "% Read"
from     v$backup_datafile 
where    trunc(completion_time) >= trunc(sysdate-1) and file# > 0
group by used_change_tracking
/

tti off
tti Left 'Files Not using BCT Information :' skip 2

select file#, used_change_tracking
from v$backup_datafile
where used_change_tracking != 'YES'
and   file# > 0
/

select file#, completion_time, incremental_level, blocks, blocks_read, datafile_blocks, trunc(blocks_read/datafile_blocks*100) "% Read"
from v$backup_datafile
where used_change_tracking != 'YES' and file# > 0 and
      trunc(completion_time) >= trunc(sysdate-1)
order by file#, completion_time
/

tti off
tti Left 'File Information :' skip 2

select file#,
		avg(datafile_blocks) datafile_blocks,
		avg(blocks_read)     blocks_read,
		avg(blocks_read/datafile_blocks) * 100 backup_read
from v$backup_datafile
where incremental_level > 0
	and used_change_tracking = 'YES'
group by file#
order by file#
/

-- http://arup.blogspot.com/2008/09/magic-of-block-change-tracking.html

tti off
tti Left 'Blocks Changed Detailed Information :' skip 2

select vertime, csno, fno, bno, bct 
from sys.x$krcbit
where vertime >= (select curr_vertime from x$krcfde
                  where csno=x$krcbit.csno and fno=x$krcbit.fno)
order by fno, bno;

tti off
tti Left 'Block Change Tracking Command Information :' skip 2
select 'Enable BCT - alter database enable block change tracking;' Info 
from dual
union
select 'Disable BCT   - alter database disable block change tracking;' Info
from dual
union
select 'Enable BCT using File - alter database enable block change tracking using file <FULL-PATH-OF-FILE>;' Info
from dual
/

tti off
spool off