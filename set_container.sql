-- 	File 		:	SET_CONTAINER.SQL
--	Description	:	Set the Session to the right PDB Container.
--	Info		:	Update Spool information as required to get the spool output.

set serverout on pages 9999 verify off lines 200 long 99999
set echo off

col Instance			heading 'Environment Info'		format a100
col table_name 			heading	'Table Name'			format a30
col tablespace_name 	heading	'Tablespace Name'		format a15
col partition_name 		heading	'Partition Name'		format a15
col num_rows			heading	'Row Cnt'				format 99,999,999,999
col Blocks				heading 'Blocks Cnt'			format 99,999,999,999
col last_analyzed		heading	'Date Analyzed'
col max_extents			heading	'Max Ext'				format a10
col owner 				heading	'Owner'					format a30
col index_name 			heading	'Index Name'			format a30
col index_type 			heading	'Index Type'			format a25
col degree 				heading	'Deg'					format a10
col blevel				heading 'Depth'					format 99
col column_name 		heading	'Column Name'			format a30
col parent_table		heading	'Parent Table'			format a20
col child_table 		heading	'Child Table'			format a20
col parent_key 			heading	'Parent Key'			format a25
col referenced_key 		heading	'Referential Key'		format a25
col object_name			heading 'Object Name'			format a30
col object_type			heading	'Object Type'			format a20
col job					heading 'Job'					format 9999
col what				heading 'Script'				format a35
col last_date			heading	'Last Run Time'		
col next_date			heading	'Next Run Time'
col interval			heading 'Interval'				format a40
col clustering_factor	heading 'Clstfct'				format 999999999
col status				Heading	'Status'				format a8
col partitioned			heading	'Partition'				
col Segment_name		heading	'Segment Name'			format a30
col Segment_type		heading	'Type'					format a30
col bytes				heading 'Bytes'					format 999999999999999
col trigger_name		heading 'Trigger Name'			format a30
col trigger_type		heading 'Trigger Type'			format a30
col triggering_event	heading 'Triggering Event'		format a20
col spoolfile			heading 'Spool File Name'		format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile			heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'set_container_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

tti Left 'Container Information :' skip 2

select name, open_mode,total_size/1048576 size_MB
from v$containers
/

Accept lcontainer char Prompt 'Enter the Container (Use CDB$ROOT for Root Container) : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lcontainer');

alter session set container=&lcontainer
/

spool off