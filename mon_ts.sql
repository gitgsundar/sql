-- 	File 		:	MON_TS.SQL
--	Description	:	Monitor Tablespaces of Database..
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance							heading 'Environment Info' 				format a100
col Instance_name 				heading 'Instance' 								format a10
col host_name							heading 'Host'										format a30
col tablespace_name				heading 'Tablespace Name'					format a30
col block_size						heading 'Blk Size' 								format 99999999
col alloted_bytes 				heading 'Alloted Bytes'						format 99,999,999,999,999
col free_bytes 						heading 'Free Bytes'							format 99,999,999,999,999
col DBSpace_in_MB 				heading 'Alloted(Mbytes)' 				format 99,999,999,999,999
col DBFree_in_MB 					heading 'Free(Mbytes)' 						format 99,999,999,999,999
col DBSpace_in_GB 				heading 'Alloted(Gbytes)' 				format 99,999,999,999,999
col DBFree_in_GB 					heading 'Free(Gbytes)' 						format 99,999,999,999,999
col percent_free  				heading 'Free %'									format 999.99
col contents							heading 'Contents'								format a9
col extent_management			heading 'Ext Mgt'									format a10
col segment_space_management	heading 'Seg Mgt'							format a10
col status								heading 'Status'									format a7
col logging								heading 'Log Mode'								format a9
col bigfile								heading 'BigFile'									format a8
col def_tab_compression		heading 'Tab Compression'					format a15
col compress_for					heading	'Tab Compression Type'		format a16
col def_index_compression	heading 'Index Compression'				format a15
col index_compress_for		heading 'Ind Compression Type'		format a16
tti off

col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_ts_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select instance_name, host_name, to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from gv$instance
/

tti Left 'Tablespace Information :' skip 2

select tablespace_name,block_size,contents,logging,extent_management,segment_space_management,status,bigfile, def_tab_compression,compress_for 
from dba_tablespaces
order by 1
/

tti off
tti Left 'Tablespace Sizing Information :' skip 2

select a.tablespace_name, alloted_bytes/1048576 DBSpace_in_MB, nvl(free_bytes/1048576,0) DBFree_in_MB, 
          nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select tablespace_name, sum(bytes) alloted_bytes from dba_data_files group by tablespace_name
                          union
      select tablespace_name, sum(bytes) alloted_bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes) free_bytes from dba_free_space 
  where tablespace_name not in (select distinct tablespace_name from dba_rollback_segs where tablespace_name not in ('SYSTEM')) 
--  and
--        tablespace_name not in (select tablespace_name from dba_tablespaces where contents in ('UNDO','TEMPORARY'))
  group by tablespace_name
   			union
 select tablespace_name, free_space free_bytes from dba_temp_free_space) b
where a.tablespace_name = b.tablespace_name (+)
order by 1
/

tti off
tti Left 'Database Size Information :' skip 2

select (d.bytes + t.bytes + l.bytes)/1024/1024/1024 DBSpace_in_GB, (f.bytes + tf.bytes)/1024/1024/1024 DBFree_in_GB
from  (select sum(bytes) bytes from dba_data_files) d,
		(select nvl(sum(bytes),0) bytes from dba_temp_files) t,
		(select sum(bytes*members) bytes from v$log) l,
      (select sum(bytes) bytes from dba_free_space) f,
      (select sum(free_space) bytes from dba_temp_free_space) tf
/

tti off
spool off
