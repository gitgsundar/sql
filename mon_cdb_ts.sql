-- 	File 		:	MON_CDB_TS.SQL
--	Description	:	Monitor Tablespaces of Container Database..
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance					heading 'Environment Info' 	format a100
col Instance_name 		heading 'Instance' 					format a10
col con_name					heading	'Container Name'		format a15
col host_name					heading 'Host'							format a30
col tablespace_name		heading 'Tablespace Name'		format a30
col block_size				heading 'Blk Size' 					format 99999999
col alloted_bytes 		heading 'Alloted Bytes'			format 99,999,999,999,999
col free_bytes 				heading 'Free Bytes'				format 99,999,999,999,999
col DBSpace_in_MB 		heading 'Alloted(Mbytes)' 	format 99,999,999,999,999
col DBFree_in_MB 			heading 'Free(Mbytes)' 			format 99,999,999,999,999
col DBSpace_in_GB 		heading 'Alloted(Gbytes)' 	format 99,999,999,999,999
col DBFree_in_GB 			heading 'Free(Gbytes)' 			format 99,999,999,999,999
col percent_free  		heading 'Free %'						format 999.99
col contents					heading 'Contents'					format a9
col extent_management	heading 'Ext Mgt'						format a10
col segment_space_management	heading 'Seg Mgt'		format a10
col status						heading 'Status'						format a7
col logging						heading 'Log Mode'					format a9
col bigfile						heading 'BigFile'						format a8
col def_tab_compression		heading 'Compress'			format a10
col compress_for			heading	'Compression Type'	format a16	
tti off

col spoolfile					heading 'Spool File Name'		format a150
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_cdb_ts_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select instance_name, host_name, to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from gv$instance
/

tti Left 'Tablespace Information :' skip 2
break on con_name

select c.name con_name, tablespace_name,t.block_size,contents,t.logging,extent_management,segment_space_management,t.status,bigfile, def_tab_compression,compress_for 
from cdb_tablespaces t, v$containers c
where t.con_id = c.con_id
order by 1,2
/

tti off
tti Left 'Tablespace Sizing Information :' skip 2

select a.name con_name, a.tablespace_name, alloted_bytes/1048576 DBSpace_in_MB, nvl(free_bytes/1048576,0) DBFree_in_MB, 
          nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select c.name, tablespace_name, sum(bytes) alloted_bytes from cdb_data_files f, v$containers c where f.con_id = c.con_id group by name, tablespace_name
                          union
      select c.name, tablespace_name, sum(bytes) alloted_bytes from cdb_temp_files tf, v$containers c where tf.con_id = c.con_id  group by name, tablespace_name) a,
		 (select c.name, tablespace_name, sum(bytes) free_bytes from cdb_free_space fs, v$containers c where fs.con_id = c.con_id 
  				and tablespace_name not in (select distinct tablespace_name from cdb_rollback_segs where tablespace_name not in ('SYSTEM')) 
  				group by name, tablespace_name
   			union
 			select c.name, tablespace_name, free_space free_bytes from cdb_temp_free_space tfs, v$containers c where tfs.con_id = c.con_id) b
where a.tablespace_name = b.tablespace_name (+)
  and a.name = b.name
order by 1,2
/

tti off
tti Left 'Database Size Information :' skip 2

select (d.bytes + t.bytes + l.bytes)/1024/1024/1024 DBSpace_in_GB, (f.bytes + tf.bytes)/1024/1024/1024 DBFree_in_GB
from  (select sum(bytes) bytes from cdb_data_files) d,
		(select nvl(sum(bytes),0) bytes from cdb_temp_files) t,
		(select sum(bytes*members) bytes from v$log) l,
      (select sum(bytes) bytes from cdb_free_space) f,
      (select sum(free_space) bytes from cdb_temp_free_space) tf
/

tti off
clear break
spool off
