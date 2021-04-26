-- 	File 		:	GET_SCHEMA_INFO.SQL
--	Description	:	Provides details of Oracle Schema.
--	Info		:	Update Spool information as required to get the spool output.

col Instance			heading 'Environment Info'		format a100
col table_name 			heading	'Table Name'			format a30
col tablespace_name 	heading	'Tablespace Name'		format a25
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
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_schema_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

tti Left 'Schema Information :' skip 2

select owner,count(*) Count
from dba_objects
where owner not in ('SYS','SYSTEM')
group by owner
order by 1
/

Accept lowner char Prompt 'Enter the Owner : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lowner');


tti off
tti Left 'Schema Objects Information :' skip 2

select object_type,count(*)
from dba_objects
where owner=:b0
group by object_type
order by 2
/

tti off
tti Left 'Schema Table Information :' skip 2

select table_name,tablespace_name,num_rows,blocks,degree,
		 decode(max_extents,2147483645,'Unlimited',max_extents) max_extents, 
		 last_analyzed 
from dba_tables
where owner=:b0
order by num_rows
/

tti off
tti Left 'Schema Index Information :' skip 2

select i.owner,i.index_name,i.table_name,pi.partition_name partition_name, i.index_type, nvl(pi.tablespace_name,i.tablespace_name) tablespace_name,decode(pi.status,null,i.status,pi.status) status,
		decode(i.degree,'DEFAULT','1',i.degree) degree,i.partitioned,i.clustering_factor,i.last_analyzed
from   dba_ind_partitions pi, dba_indexes i
where  i.index_name=pi.index_name(+)
	and i.owner=:b0
order by 1,2
/

tti off
tti Left 'Schema Object Status Information :' skip 2

select object_name,object_type,status
from dba_objects
where owner=:b0
order by 2,1
/

tti off
tti Left 'Schema Object Size Information :' skip 2

select tablespace_name,segment_name,segment_type,bytes,blocks
from dba_segments
where owner=:b0
order by 4
/

tti off
tti Left 'Schema Triggers Information :' skip 2

select table_name, trigger_name, trigger_type,triggering_event,status
from dba_triggers
where owner=:b0
order by 1,2
/

tti off
tti Left 'Schema DBMS_JOB Information :' skip 2

select job,substr(what,1,50) what, last_date, next_date, interval
from dba_jobs
where schema_user=:b0
order by 1
/
tti off
spool off