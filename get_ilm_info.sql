-- 	File 		:	GET_ILM_INFO.SQL
--	Description	:	Provides details of the ILM - Information LifeCycle Management using ADO (Automatic Data Optimization)
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance									heading 'Environment Info' 	format a100
col name											heading 'Name'							format a30
col value											heading 'Value'							format 99999
col con_id										heading 'ConID'							format 99999
col object_name								heading 'Object'						format a30
col subobject_name						heading 'Sub Object'				format a30
col track_time								heading 'Track Time'				format a30
col n_segment_write						heading '# Seg Write'				format 999,999,999,999
col n_full_scan								heading '# Full Scan'				format 999,999,999,999
col n_lookup_scan							heading '# Lkp Scan'				format 999,999,999,999
col policy_name								heading 'Policy Name'				format a20
col policy_type								heading 'Policy Type'
col tablespace								heading 'Tablespace'				format a15
col enabled										heading 'Enabled'
col Info                      heading 'Run below Command to manipulate Heat Map Settings'  for a80
col Cust_Info                 heading 'Use below Packages to manage ILM Parameters'  for a80

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ilm_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Database ILM Properties :' skip 2

select name,value 
from dba_ilmparameters
order by 1
/

select 'Execute DBMS_ILM_ADMIN/DBMS_ILM Package for Advanced Customizing Automatic Data Optimization (ADO) Policy Parameters' Cust_Info 
from dual
/

tti off
tti Left 'Database Heat Map Information :' skip 2

show parameter heat_map

select con_id, track_time, object_name, subobject_name, n_segment_write, n_full_scan, n_lookup_scan
from v$heat_map_segment
/

tti off
tti Left 'Database ILM Policies Information :' skip 2

select policy_name, policy_type, tablespace, enabled
from dba_ilmpolicies
order by 1
/

tti off
tti Left 'Heat Map Command Information :' skip 2
select 'Enable Heat Map  - alter system heat_map=on;' Info 
from dual
union
select 'Disable Heat Map - alter system heat_map=off;' Info 
from dual
union
select 'Track Data Access - DBMS_HEAT_MAP' Info
from dual
/

tti off
spool off