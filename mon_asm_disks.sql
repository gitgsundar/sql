set pages 9999 
set verify off
col Instance				heading 'Environment Info' 	format a100
col Disk_Group				heading 'Group Name'		format a30
col Disk_Name				heading 'ASM Disk'			format a20
col path				    heading 'Disk Path'			format a30
col alloted_bytes 			heading 'Alloted Bytes'		format 99,999,999,999,999
col free_bytes 				heading 'Free Bytes'		format 99,999,999,999,999
col DBSpace_in_MB 			heading 'DB Space(Mbytes)' 	format 99,999,999,999,999
col percent_free  			heading 'Free %'			format 999.99
col contents				heading 'Contents'			format a9
col extent_management		heading 'Ext Mgt'			format a10
col type					heading 'File Type'			format a20
col file_count				heading 'Count'				format 9999
col state					heading 'State'				format a10
col logging					heading 'Log Mode'			format a9
tti off

col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_asm_disks_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'DiskGroup Space Information :' skip 2

select group_number,name Disk_Group, state, type, voting_files, total_mb alloted_bytes, free_mb free_bytes, nvl(round((100*free_mb)/total_mb,2),0) percent_free 
from v$asm_diskgroup
order by 1
/

tti off
tti Left 'File Information :' skip 2

select type,count(*) file_count
from v$asm_file 
group by type
order by 1
/

tti off
spool off