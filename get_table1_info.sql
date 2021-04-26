-- 	File 		:	GET_TABLE1_INFO.SQL
--	Description	:	Provides Details Row Spread.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300 escape on 
set escape ~
col Instance			heading 'Environment Info'	format a100
col bytes				heading	'Bytes'				format 99999999999
col table_name 			heading	'Table Name'		format a30
col segment_name 		heading	'Table Name'		format a30
col lob_segment_name 	heading	'Lob Segment Name'	format a30
col chunk				heading	'Chunk'				format 99999999
col pctversion			heading	'Versions'			format 99
col in_row				heading	'InRow'
col retention			heading	'Retention'			format 9999999
col iot_type			heading	'IO'				format a2
col temporary			heading	'GTT'				format a3
col tablespace_name 	heading	'Tablespace Name'	format a15
col partition_position	heading 'Pos'				format 999
col high_value			heading 'High Value'		format a85 
col num_rows			heading	'Row Cnt'			format 99,999,999,999
col Blocks				heading 'Blocks Cnt'		format 99,999,999,999
col last_analyzed		heading	'Date Analyzed'
col max_extents			heading	'Max Ext'			format a10
col owner 				heading	'Owner'				format a15
col index_name 			heading	'Index Name'		format a28
col uniqueness			heading	'Uniqueness'
col partition_name		heading 'Part Name'			format a20
col index_type 			heading	'Index Type'		format a30
col degree 				heading	'Deg'				format a5
col column_name 		heading	'Column Name'		format a30
col column_position		heading 'Pos'				format 99
col partitioned			heading	'Partition'				
col parent_table		heading	'Parent Table'		format a30
col child_table 		heading	'Child Table'		format a30
col child_constraint 	heading 'Child Constraint'	format
col delete_rule			heading	'Delete Rule'		format a12
col parent_key 			heading	'Parent Key'		format a25
col referenced_key 		heading	'Referential Key'	format a25
col clustering_factor	heading 'Clstfct'			format 999999999
col blevel				heading	'Blvl'				format 9999
col locality			heading 'Locality'			format a8
col Alignment			heading	'Prefixing'			
col status				Heading	'Status'			format a8
col partitioning_type 	Heading 'Part Type'			format a10
col partition_count		heading  'PCnt'
col subpartitioning_type Heading 'SubPart Type'		format a15
col position			heading  'Pos'				format 999
col chain_cnt			heading	'Chain'		
col avg_row_len			heading	'AvgRow'
col buckets				heading	'Buckets'
col constraint_name		heading	'Constraint Name'
col r_constraint_name 	heading	'Ref Constraint Name'
col constraint_type		heading	'Type'				format a4
col grantee				heading	'Grantee'			format a20
col grantor				heading	'Grantor'			format a20
col privilege			heading	'Privilege'				
col grantable			heading	'Grantable'			format a9
col trigger_name		heading 'Name'				format a30
col trigger_type		heading 'Type'				format a20
col triggering_event	heading	'Event'				format a15
col object_name			heading 'Object Name'		format a30
col object_type			heading 'Object Type' 		format a20
col referenced_owner 	heading	'Owner'				format a15
col referenced_name		heading 'Table Name'		format a25
col created				heading 'Created'
col last_ddl_time		heading 'Last DDL Time'
col visibility			heading 'Visible'
col compression 		heading 'Compression'
col compress_for		heading 'Compress Type'
col file#				heading 'File #'
col block#				heading 'Block #'
col num_rows			heading 'Rows'
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_table1_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
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

set escape on 

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
		 compression,compress_for
from dba_tables
where table_name=:b0
  and owner=:b1
/

tti off
tti Left 'Table Bytes Information :' skip 2

select owner,segment_name,partition_name,bytes
from dba_segments
where segment_name=:b0
  and owner=:b1
order by 4  
/


tti off
tti Left 'Row Spread Information :' skip 2

select
	dbms_rowid.rowid_relative_fno(rowid) File#,
	dbms_rowid.rowid_block_number(rowid) Block#,
	count(1) num_rows
from &&ltable_name
group by
	dbms_rowid.rowid_relative_fno(rowid),
	dbms_rowid.rowid_block_number(rowid)
order by 1,2
/

declare
	v_unformatted_blocks number;
	v_unformatted_bytes  number;
	v_fs1_blocks 		 number;
	v_fs1_bytes 		 number;
	v_fs2_blocks		 number;
	v_fs2_bytes 		 number;
	v_fs3_blocks		 number;
	v_fs3_bytes			 number;
	v_fs4_blocks		 number;
	v_fs4_bytes			 number;
	v_full_blocks		 number;
	v_full_bytes		 number;
begin
	dbms_output.put_line('');
	dbms_output.put_line('Table Block Used Space Information ');
	dbms_output.put_line('');
	dbms_space.space_usage (upper('&lowner'),upper('&ltable_name'),	'TABLE',
	v_unformatted_blocks,
	v_unformatted_bytes,
	v_fs1_blocks,
	v_fs1_bytes,
	v_fs2_blocks,
	v_fs2_bytes,
	v_fs3_blocks,
	v_fs3_bytes,
	v_fs4_blocks,
	v_fs4_bytes,
	v_full_blocks,
	v_full_bytes);

	dbms_output.put_line('Unformatted Blocks              = '||v_unformatted_blocks);
	dbms_output.put_line('Blocks with 00-25% free space   = '||v_fs1_blocks);
	dbms_output.put_line('Blocks with 26-50% free space   = '||v_fs2_blocks);
	dbms_output.put_line('Blocks with 51-75% free space   = '||v_fs3_blocks);
	dbms_output.put_line('Blocks with 76-100% free space  = '||v_fs4_blocks);
	dbms_output.put_line('Full Blocks                     = '||v_full_blocks);

	dbms_output.put_line('');
	dbms_output.put_line('Table Block Un-Used Space Information');
	dbms_output.put_line('');
	dbms_space.unused_space(upper('&lowner'),upper('&ltable_name'),	'TABLE',
	v_unformatted_blocks,
	v_unformatted_bytes,
	v_fs1_blocks,
	v_fs1_bytes,
	v_fs2_blocks,
	v_fs3_blocks,
	v_full_blocks);

	dbms_output.put_line('Total Blocks              = '||v_unformatted_blocks);
	dbms_output.put_line('Total Bytes               = '||v_unformatted_bytes);
	dbms_output.put_line('Total Unused Blocks       = '||v_fs1_blocks);
	dbms_output.put_line('Total Unused Bytes        = '||v_fs1_bytes);
	dbms_output.put_line('Last Used Extent Fileid   = '||v_fs2_blocks);
	dbms_output.put_line('Last Used Extent Blockid  = '||v_fs3_blocks);
	dbms_output.put_line('Last Used Block           = '||v_fs4_blocks);

end;
/

tti off
spool off