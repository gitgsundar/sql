set pages 9999 verify off lines 300 escape on 
set escape !
col Instance			heading 'Environment Info'		format a100
col bytes				heading	'Bytes'					format 99999999999
col table_name 			heading	'Table Name'			format a30
col subpartition_name	heading 'SubPartition'			format a30
col stats_update_time	heading 'Stats Time'
col empty_blocks		heading	'Empty Blocks'			format 99999999999
col sample_size 		heading 'Sample Size'			format 9999999999999
col segment_name 		heading	'Table Name'			format a30
col lob_segment_name	heading	'Lob Segment Name'		format a30
col chunk				heading	'Chunk'					format 99999999
col pctversion			heading	'Versions'				format 99
col in_row				heading	'InRow'
col retention			heading	'Retention'				format 9999999
col iot_type			heading	'Idx-Org'				format a7
col tablespace_name 	heading	'Tablespace Name'		format a15
col partition_position	heading 'Pos'					format 999
col high_value			heading 'High Value'			format a85 
col num_rows			heading	'Row Cnt'				format 99,999,999,999
col Blocks				heading 'Blocks Cnt'			format 99,999,999,999
col last_analyzed		heading	'Date Analyzed'
col max_extents			heading	'Max Ext'				format a10
col owner 				heading	'Owner'					format a15
col index_name 			heading	'Index Name'			format a28
col uniqueness			heading	'Uniqueness'
col partition_name		heading 'Part Name'				format a20
col index_type 			heading	'Index Type'			format a30
col degree 				heading	'Deg'					format a5
col column_name 		heading	'Column Name'			format a30
col column_position		heading 'Pos'					format 99
col partitioned			heading	'Partition'				
col parent_table		heading	'Parent Table'			format a30
col child_table 		heading	'Child Table'			format a30
col child_constraint 	heading 'Child Constraint'		format
col delete_rule			heading	'Delete Rule'			format a12
col parent_key 			heading	'Parent Key'			format a25
col referenced_key 		heading	'Referential Key'		format a25
col clustering_factor	heading 'Clstfct'				format 999999999
col blevel				heading	'Blvl'					format 9999
col locality			heading 'Locality'				format a8
col Alignment			heading	'Prefixing'			
col status				Heading	'Status'				format a8
col partitioning_type	Heading 'Part Type'				format a10
col partition_count		heading 'PCnt'
col subpartitioning_type Heading 'SubPart Type'			format a15
col position			heading 'Pos'					format 999
col chain_cnt			heading	'Chain'		
col avg_row_len			heading	'Avg Rowlen'
col buckets				heading	'Buckets'
col constraint_name		heading	'Constraint Name'
col r_constraint_name 	heading	'Ref Constraint Name'
col constraint_type		heading	'Type'					format a4
col grantee				heading	'Grantee'				format a20
col grantor				heading	'Grantor'				format a20
col privilege			heading	'Privilege'				
col grantable			heading	'Grantable'				format a9
col trigger_name		heading 'Name'					format a30
col trigger_type		heading 'Type'					format a20
col triggering_event	heading	'Event'					format a15
col object_name			heading 'Object Name'			format a30
col object_type			heading 'Object Type' 			format a20
col referenced_owner 	heading	'Owner'					format a15
col referenced_name		heading 'Table Name'			format a25
col created				heading 'Created'	
tti off


col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on
col spoolfile			heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_index_stats_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ltable_name char Prompt 'Enter the Table Name : '

tti off
tti Left 'Table Owner Information :' skip 2

select owner,table_name 
from dba_tables
where table_name=upper('&ltable_name')
/

set escape on 

Accept lowner char Prompt 'Enter the Table Owner : '


tti off
tti Left 'Table Indices Information :' skip 2

select index_name,visibility
from dba_indexes
where table_name=upper('&ltable_name')
order by 1
/

set escape on 

Accept lindex_name char Prompt 'Enter the Index Name : '

tti off
tti Left 'Index Pending Stats Information :' skip 2

select index_name,partition_name,blevel,leaf_blocks,clustering_factor,num_rows,distinct_keys,sample_size,last_analyzed
from dba_ind_pending_stats
where table_name=upper('&ltable_name')
  and table_owner=upper('&lowner')
  and index_name=upper('&lindex_name')
order by last_analyzed
/

tti off
tti Left 'Index Stale Stats Information :' skip 2

select index_name, partition_name,blevel,leaf_blocks,clustering_factor,num_rows,sample_size,last_analyzed,user_stats,stale_stats
from dba_ind_statistics
where table_name=upper('&ltable_name')
  and table_owner=upper('&lowner')
  and index_name=upper('&lindex_name')
  and stale_stats='YES'
order by last_analyzed
/

tti off
spool off