-- 	File 		:	GET_IM_INFO.SQL
--	Description	:	Provides Details of a In-Memory Configuration.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance			heading 'Environment Info' 			format a100
col inst_id 			heading "Inst"
col con_id	 		heading "Cnt"
col pool		 	heading "Pool Name" 				format a20
col populate_status		heading "Status"				format a25
col alloc_bytes			heading "Allocated"				format 999,999,999,999
col used_bytes			heading "Used"					format 999,999,999,999
col owner 			heading "Owner"					format a20
col datablocks			heading "Blks"					format 999999999999
col blocksinmem			heading "Mem Blks"				format 999999999999
col segment_name		heading "Segment Name"				format a25
col populate_status		heading "Populate Status"			format a15
col bytes			heading "Orignal Size"				format 999,999,999,999
col inmemory_size		heading "InMemory Size"				format 999,999,999,999
col comp_ratio			heading "Ratio"					format 9999999
col info			heading "Information"				format a150
col spoolfile			heading 'Spool File Name'			format a200

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_im_info_'||to_char(sysdate,'yyyymmdd:hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'IM Information:' skip 2

select *
from gv$inmemory_area
order by pool,con_id
/

tti off
tti Left 'IM Segments Information:' skip 2
select inst_id,owner, segment_name, populate_status,bytes, inmemory_size, bytes/inmemory_size comp_ratio
from gv$im_segments
order by owner
/

Accept ltable_name char Prompt 'Enter the Table Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltable_name');

tti off
tti Left 'IM Segments Detail Information:' skip 2
select m.inst_id,m.blocksinmem,m.datablocks, bytes, createtime, populate_status
from gv$im_segments_detail m, dba_objects o
where m.dataobj = o.object_id
  and o.object_name=:b0
/

tti off
tti Left 'In-Memory Command Information :' skip 2

select 'Increase In-Memory Size - alter system set inmemory_size=128M;' Info 
from dual
union
select 'Reduction in Size will not take affect until next DB bounce.' Info
from dual
union
select 'In-Memory is not controlled by Oracle AMM(Automatic Memory Management).' Info
from dual
union
select 'Only INMEMORY attribute are populated to IM Column Store, made up of multiple In-Memory Compression Units (IMCU).' Info
from dual
/

spool off