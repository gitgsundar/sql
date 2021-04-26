-- 	File 		:	GET_SPD_INFO.SQL
--	Description	:	Provides details of SPD - SQL Plan Directives information
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 
set verify off
col Instance				heading 'Environment Info' 	format a100
col state			 		heading 'SPD State'			format a15
col cnt			 			heading '#SPD'				format 99,999,999
col dir_id	 				heading 'Directive ID' 		format 99999999999999999999999999999
col retention				heading 'SPD Retention'		format a15
col owner  					heading 'Owner'				format a20
col object_name				heading 'Object Name'		format a30
col col_name				heading 'Column Name'		format a15
col object_type				heading 'Obj Type'			format a10
col type					heading 'SPD Type'			format a16
col reason					heading 'Reason (Weeks)'	format a30
col info					heading 'SPD Command Info'	format a90
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_spd_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'SQL Plan Directive Information :' skip 2
tti off

show parameter adaptive

select state, count(*) cnt
from   dba_sql_plan_directives
group by state
order by state
/

select dbms_spd.get_prefs('SPD_RETENTION_WEEKS') retention
from dual
/

tti off
tti Left 'Owners having SPD Information :' skip 2


select owner, count(distinct directive_id) cnt
from dba_sql_plan_dir_objects
group by owner
order by owner
/

Accept lowner char Prompt 'Enter the Owner to check SPDs : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lowner');

tti off
tti Left 'Visible SPD Information :' skip 2
tti off

select to_char(d.directive_id) dir_id, o.owner, o.object_name, 
       o.subobject_name col_name, o.object_type, d.type, d.state, d.reason
from   dba_sql_plan_directives d, dba_sql_plan_dir_objects o
where  d.directive_id=o.directive_id
and    o.owner = :b0
order by d.state
/

tti off
tti Left 'SPD Command Information :' skip 2
select 'Manually Persist SPD -> exec dbms_spd.flush_sql_plan_directive;' Info 
from dual
union
select 'Drop SPD             -> exec dbms_spd.drop_sql_plan_directive(<DIRECTIVE_ID>);' Info 
from dual
/

tti off
spool off