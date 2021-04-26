-- 	File 		:	GET_ASM_DISK1_INFO.SQL
--	Description	:	Provides details of ASM Disk Operations Information.
--	Info		:	Update Spool information as required to get the spool output.
--				:	Must to run against ASM Instance.

set pages 9999 
set verify off
col Instance				heading 'Environment Info' 				format a100
col Disk_Group				heading 'Disk Group Name'				format a30
col Disk_Name				heading 'ASM Disk'						format a20
col Imbalance               Heading "Percent|Imbalance" 			format 99.9 
col Varience 				Heading "Percent|Disk Size|Varience"	format 99.9 
col MinFree 				Heading "Minimum|Percent|Free"			format 99.9 
col DiskCnt 				Heading "Disk|Count"					format 9999 
col Type  					Heading "Diskgroup|Redundancy"			format a10 
col path				    heading 'Disk Path'						format a30
col alloted_bytes 			heading 'Alloted Bytes'					format 99,999,999,999,999
col free_bytes 				heading 'Free Bytes'					format 99,999,999,999,999
col DBSpace_in_MB 			heading 'DB Space(Mbytes)' 				format 99,999,999,999,999
col percent_free  			heading 'Free %'						format 999.99
col contents				heading 'Contents'						format a9
col extent_management		heading 'Ext Mgt'						format a10
col type					heading 'File Type'						format a20
col file_count				heading 'Count'							format 9999
col state					heading 'State'							format a10
col logging					heading 'Log Mode'						format a9
col spoolfile				heading 'Spool File Name'				format a100

tti off

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\get_asm_disk1_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'DiskGroup Space Information :' skip 2

/*
 * The imbalance measures the difference in space allocated to the fullest and
 * emptiest disks in the disk group. Comparision is in percent full since ASM
 * tries to keep all disks equally full as a percent of their size. The
 * imbalance is relative to the space allocated not the space available. An
 * imbalance of a couple percent is reasonable

 * Percent disk size varience gives the percentage difference in size between
 * the largest and smallest disks in the disk group. This will be zero if
 * best practices have been followed and all disks are the same size. Small
 * differences in size are acceptible. Large differences can result in some
 * disks getting much more I/O than others. With normal or high redundancy
 * diskgroups a large size varience can make it impossible to reduce the
 * percent imbalance to a small value.

 * Minimum percent free gives the amount of free disk space on the fullest
 * disk as a percent of the disk size. If the imbalance is zero then this
 * represents the total freespace. Since all allocations are done evenly
 * across all disks, the minimum free space limits how much space can be
 * used. If one disk has only one percent free, then only one percent of the
 * space in the diskgroup is really available for allocation, even if the
 * rest of the disks are only half full.

 * The number of disks in the disk group gives a sense of how widely the
 * files can be spread.

 * External redundancy diskgroups can always be rebalanced to have a small
 * percent imbalance. However the failure group configuration of a normal or
 * high redundancy diskgroup may make it impossible to make the diskgroup well
 * balanced.
 */


select
/*    Name of the diskgroup */
    g.name
    "Diskgroup",
/*    Percent diskgroup allocation is imbalanced  */
    100*(max((d.total_mb-d.free_mb)/d.total_mb)-min((d.total_mb-d.free_mb)/d.total_mb))/max((d.total_mb-d.free_mb)/d.total_mb)
    "Imbalance",
/*    Percent difference between largest and smallest disk */
    100*(max(d.total_mb)-min(d.total_mb))/max(d.total_mb)
    "Varience",
/*   The disk with the least free space as a percent of total space */
    100*(min(d.free_mb/d.total_mb))
    "MinFree",
/*   Number of disks in the diskgroup */
    count(*)
    "DiskCnt",
/*   Diskgroup redundancy */
    g.type
    "Type"
from
	v$asm_disk_stat d,
	v$asm_diskgroup_stat g
where
    d.group_number = g.group_number and
    d.group_number <> 0 and
    d.state = 'NORMAL' and
    d.mount_status = 'CACHED'
group by
    g.name ,
    g.type
;

tti off
tti Left 'DiskGroup Space Information :' skip 2

SELECT dg.NAME,  d.operation, d.state, d.POWER, d.actual, est_work , d.sofar*100/d.est_work pct_done, d.est_rate, d.est_minutes
FROM gv$asm_diskgroup dg, gv$asm_operation d
where d.group_number = dg.group_number
/

tti off
spool off