-- 	File 		:	GET_EXTENT_INFO.SQL
--	Description	:	Provides details of Extent Mapping 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300 
col Instance			heading 'Environment Info'	format a100
col owner	 			heading	'Owner'				format a30
col segment_name 		heading	'Segment Name'		format a30
col segment_type 		heading	'Segment Type'		format a30
col partition_name 		heading	'Partition Name'	format a30
col tablespace_name		heading 'Tablespace'		format a30
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ext_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lfile number Prompt 'Enter the Relative File No : '
Accept lblock number Prompt 'Enter the Block No : '

variable b0 number;
exec 	:b0 := &lfile;

variable b1 number;
exec 	:b1 := &lblock;

tti off
tti Left 'Segment Information :' skip 2

select owner, segment_name, segment_type, partition_name , tablespace_name
from dba_extents
where relative_fno= :b0 and 
	:b1 between block_id and (block_id+blocks-1)
/

tti off
spool off