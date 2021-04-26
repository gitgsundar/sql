set pages 9999 
set verify off

col Instance						heading 	'Environment Info' 			format a100
col tablespace_name					heading 	'Tablespace Name'				format a30
col alloted_bytes 					heading 	'Alloted Bytes'				format 99,999,999,999,999
col free_bytes 						heading 	'Free Bytes'					format 99,999,999,999,999
col DBSpace_in_GB 					heading 	'DB Space(Gbytes)' 			format 99,999,999,999,999
col percent_free  					heading 	'Free %'							format 99.99
col bytes           				heading	'Datafile Size (Mbytes)'	format 99,999,999,999,999
col segment_bytes   				heading	'Segment Size (Mbytes)'		format 99,999,999,999,999
col segment_name    				heading	'Segment Name'					format a30
col partition_name   				heading	'Partition Name'				format a30
col segment_type    				heading	'Type'							format a20
col extents    						heading	'Extent Cnt'					format 999,999
col owner           				heading	'Owner'							format a20
col file_name       				heading	'File Name'						format a50
col contents						heading 'Contents'						format a9
col extent_management				heading 'Ext Mgt'							format a10
col segment_space_management		heading 'Seg Mgt'							format a10
col status							heading 'Status'							format a7
col logging							heading 'Log Mode'						format a9


col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_ts_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select tablespace_name,contents,logging,extent_management,segment_space_management,status 
from dba_tablespaces
order by 1
/

Accept lts CHAR Prompt 'Enter the Tablespace Name : '
Accept lsize number Prompt 'Enter Size Limit in MBytes : '


select owner,segment_name,partition_name,segment_type,bytes/1048576 segment_bytes,extents
from dba_segments where tablespace_name=upper('&lts')
and bytes/1048576 > &lsize
order by 5,2
/

select file_name,bytes/1048576 bytes from dba_data_files
where tablespace_name=upper('&lts')
order by 2
/

select a.tablespace_name, alloted_bytes, nvl(free_bytes,0) free_bytes, nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select tablespace_name, sum(bytes) alloted_bytes from dba_data_files group by tablespace_name
                          union
      select tablespace_name, sum(bytes) alloted_bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes) free_bytes from dba_free_space group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
      and a.tablespace_name=upper('&lts')
order by 1
/

spool off

