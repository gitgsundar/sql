-- 	File 		:	GET_HIST_OBJECTGROWTH_INFO.SQL
--	Description	:	Provides details of Historical Database File IO Stats
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col begin_interval_time			heading "Time"						format a30
col owner						heading "Owner"						format a15
col object_name	  				heading "Object Name"				format a30
col block_increase 				heading "Blocks Changes"			format 9999999999
col space_used					heading "Space Changes(bytes)"		format 99999999999999
col spoolfile					heading 'Spool File Name'			format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_object_growth_info_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

Accept lobject char Prompt 'Enter Object_Name: '

tti off
tti Left 'Execution Details :' skip 2

select
  o.owner,
  o.object_name,
  h.begin_interval_time,
  sum(s.db_block_changes_delta) block_increase,
  sum(s.space_used_delta) space_used
from
  dba_hist_seg_stat s,
  dba_hist_snapshot h,
  dba_objects o
where s.snap_id = h.snap_id
and o.object_id = s.obj#
and o.owner not in ('SYS','SYSTEM')
and begin_interval_time > trunc(sysdate-&ldays)
and o.object_name=upper('&lobject')
group by o.owner, o.object_name,h.begin_interval_time
order by 1
/

tti off

spool off