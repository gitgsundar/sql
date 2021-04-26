-- 	File 		:	GET_TABLE_INFO.SQL
--	Description	:	Provides Details of Oracle Table
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 500 
col Instance			heading 'Environment Info'	format a100
col bytes			heading	'Bytes'			format 99,999,999,999
col bytes_MB			heading	'Size (Mb)'		format 99,999,999,999
col table_name 			heading	'Table Name'		format a30
col segment_name 		heading	'Table Name'		format a30
col lob_segment_name 		heading	'Lob Segment Name'	format a30
col extents			heading 'Ext #'			format 999,999				
col chunk			heading	'Chunk'			format 99999999
col pctversion			heading	'Versions'		format 99
col in_row			heading	'InRow'
col retention			heading	'Retention'		format 9999999
col iot_type			heading	'IO'			format a2
col temporary			heading	'GTT'			format a2
col tablespace_name 		heading	'Tablespace Name'	format a15
col partition_position		heading 'Pos'			format 999
col high_value			heading 'High Value'		format a85 
col num_rows			heading	'Row Cnt'		format 99,999,999,999
col Blocks			heading 'Blocks Cnt'		format 99,999,999,999
col last_analyzed		heading	'Date Analyzed'		format a20
col max_extents			heading	'Max Ext'		format a10
col owner 			heading	'Owner'			format a15
col index_name 			heading	'Index Name'		format a30
col uniqueness			heading	'Uniqueness'
col partition_name		heading 'Part Name'		format a20
col index_type 			heading	'Index Type'		format a30
col degree 			heading	'Deg'			format a5
col column_name 		heading	'Column Name'		format a30
col column_position		heading 'Pos'			format 99
col partitioned			heading	'Partition'				
col parent_table		heading	'Parent Table'		format a30
col child_table 		heading	'Child Table'		format a30
col child_constraint 		heading 'Child Constraint'	format a30
col delete_rule			heading	'Delete Rule'		format a12
col parent_key 			heading	'Parent Key'		format a25
col referenced_key 		heading	'Referential Key'	format a25
col clustering_factor		heading 'Clstfct'		format 999999999
col blevel			heading	'Blvl'			format 9999
col locality			heading 'Locality'		format a8
col Alignment			heading	'Prefixing'			
col status			Heading	'Status'		format a8
col partitioning_type 		Heading 'Part Type'		format a10
col partition_count		heading  'PCnt'
col subpartitioning_type 	Heading 'SubPart Type'		format a15
col position			heading  'Pos'			format 999
col chain_cnt			heading	'Chain'		
col avg_row_len			heading	'AvgRow'
col buckets			heading	'Buckets'
col constraint_name		heading	'Constraint Name'	format a30
col r_constraint_name 		heading	'Ref Constraint Name'	format a30
col constraint_type		heading	'Type'			format a4
col grantee			heading	'Grantee'		format a20
col grantor			heading	'Grantor'		format a20
col privilege			heading	'Privilege'				
col grantable			heading	'Grantable'		format a9
col trigger_name		heading 'Name'			format a30
col trigger_type		heading 'Type'			format a20
col triggering_event		heading	'Event'			format a20
col object_name			heading 'Object Name'		format a30
col object_type			heading 'Object Type' 		format a20
col referenced_owner 		heading	'Owner'			format a15
col referenced_name		heading 'Table Name'		format a25
col created			heading 'Created'
col last_ddl_time		heading 'Last DDL Time'
col visibility			heading 'Visible'
col compression 		heading 'Compression'		format a15
col compress_for		heading 'Compress Type'		format a15
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_table_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ltable_name char Prompt 'Enter the Table Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltable_name');

tti off
tti Left 'Table Owner Information :' skip 2

select owner,table_name 
from dba_tables
where table_name=:b0
/

Accept lowner char Prompt 'Enter the Table Owner : '
variable b1 varchar2(50);
exec 	:b1 := upper('&lowner');

tti off
tti Left 'Table Information :' skip 2

select owner, object_name table_name, created, last_ddl_time
from dba_objects
where object_name=:b0
  and owner=:b1
  and object_type='TABLE'
/

select owner,table_name,nvl(tablespace_name,'TEMP') tablespace_name,num_rows,blocks,ltrim(rtrim(degree)) degree,
		 decode(max_extents,2147483645,'Unlimited',max_extents) max_extents,avg_row_len, 
		 NVL(last_analyzed,to_date('01-01-1900','DD-MM-YYYY')) last_analyzed, nvl(iot_type,'N') iot_type,nvl(temporary,'N') temporary,
		 compression,compress_for,cache,inmemory, inmemory_compression
from dba_tables
where table_name=:b0
  and owner=:b1
/

tti off
tti Left 'Table Histogram Information :' skip 2

select column_name, count(*) buckets
from dba_histograms
where table_name=:b0
  and owner=:b1
  and endpoint_number not in (0,1)
group by column_name  
/


tti off
tti Left 'Table Bytes Information :' skip 2

select owner,segment_name,partition_name,extents,bytes/1048576 bytes_MB
from dba_segments
where segment_name=:b0
  and owner=:b1
order by 4  
/

tti off
tti Left 'Table + Its Indices Bytes Information :' skip 2


select owner, round(sum(bytes_MB),0) bytes_MB 
from (
select owner,segment_name,sum(bytes)/1048576 bytes_MB
from dba_segments
where (segment_name=:b0 and owner=:b1)
  OR (segment_name in (select index_name from dba_indexes where table_name=:b0 and owner=:b1))
group by owner,segment_name )
group by owner
/

tti off
tti Left 'Table Partition Information :' skip 2

select partition_name, high_value,tablespace_name,partition_position,num_rows,avg_row_len,blocks,chain_cnt,last_analyzed,compression,compress_for
from dba_tab_partitions
where table_name=:b0
  and table_owner=:b1
order by partition_position
/

tti off
tti Left 'Table Partition Column Information :' skip 2
select name table_name, column_name, column_position position,partitioning_type
from dba_part_key_columns k, dba_part_tables t
where k.name=:b0
  and k.owner=:b1
  and k.name=t.table_name 
  and k.owner=t.owner
order by column_position
/

tti off
tti Left 'Table Sub-Partition Column Information :' skip 2
select name table_name, column_name, column_position position, subpartitioning_type
from dba_subpart_key_columns k,dba_part_tables t
where k.name=:b0
  and k.owner=:b1
  and k.name=t.table_name
  and k.owner=t.owner
order by column_position
/

tti off
tti Left 'Table Index Information :' skip 2

select i.owner,i.index_name,i.uniqueness,nvl(pi.partition_name,'GLOBAL INDEX') partition_name, pi.partition_position,i.index_type, nvl(pi.tablespace_name,i.tablespace_name) tablespace_name,decode(pi.status,null,i.status,pi.status) status,
		decode(i.degree,'DEFAULT','1',i.degree) degree,i.blevel,i.partitioned,i.clustering_factor,i.last_analyzed,i.visibility,i.buffer_pool,i.flash_cache
from   dba_ind_partitions pi, dba_indexes i
where  i.index_name=pi.index_name(+)
	and i.table_name=:b0
--  and pi.index_owner=upper('&lowner')
  and i.owner=:b1
order by 1,2,pi.partition_position
/

tti off
tti Left 'Table Index Partition Information :' skip 2

select distinct i.index_name,nvl(pi.locality,'GLOBAL') locality,pi.alignment,pi.partitioning_type,pi.partition_count
from dba_part_indexes pi, dba_indexes i
where pi.owner=:b1
 and i.table_name=:b0
 and i.owner=:b1
 and i.index_name=pi.index_name(+) 
/

tti off
tti Left 'Table Index Column Information :' skip 2

select distinct index_name,column_name,column_position
from dba_ind_columns
where table_name=:b0
  and index_owner=:b1
order by index_name,column_position
/

tti off
tti Left 'Table Constraint Information :' skip 2
select owner, constraint_name,decode(constraint_type,'R',r_constraint_name,NULL) r_constraint_name,constraint_type,status, delete_rule
from dba_constraints
where table_name=:b0
  and owner=:b1
/

tti off
tti Left 'Table Referential Key Information for Primary:' skip 2

select parent_table, parent_key, child_table, child_constraint,referenced_key
from (select table_name parent_table, constraint_name parent_key  
		from dba_constraints
      where constraint_type = 'P' 
  		and owner=:b1      
      and table_name=:b0) p,
     (select table_name child_table,r_constraint_name referenced_key, constraint_name child_constraint 
     	from dba_constraints
      where constraint_type = 'R'
        and owner=:b1) c
where p.parent_key = c.referenced_key
order by parent_table
/

tti off
tti Left 'Table Lob Information :' skip 2

select column_name,segment_name lob_segment_name,tablespace_name,index_name,chunk,pctversion,retention,in_row
from dba_lobs 
where table_name=:b0
  and owner=:b1
/

tti off
tti Left 'Privilege Information :' skip 2

select grantee,owner,grantor,privilege,grantable
from dba_tab_privs 
where table_name=:b0
  and owner=:b1
/

tti off
tti Left 'Table Column Histogram Information :' skip 2

select owner,table_name,column_name,count(*) buckets
from dba_tab_histograms
where table_name=:b0
  and owner=:b1
group by owner,table_name,column_name
order by buckets
/

tti off
tti Left 'Trigger Information :' skip 2

select trigger_name, trigger_type, triggering_event,column_name,status
from dba_triggers
where table_name=:b0
  and table_owner=:b1
/

tti off
tti Left 'Object References Information :' skip 2

select owner,object_name,object_type,created,status
from dba_objects 
where object_name in 
		( select name
        from dba_dependencies
        where referenced_name=:b0
          and referenced_owner=:b1)
/

tti off
spool off