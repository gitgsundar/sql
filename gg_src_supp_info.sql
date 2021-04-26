set pages 9999 lines 200 verify off
col Instance		heading "Environment Info"	format a100

col log_group_name 	heading 'Group Name' 		format a20
col table_name 		heading 'Table' 			format a30
col always 			heading 'Type' 				format a30
col owner 			heading 'Owner'				format a20
col column_name		heading 'Column Name'		format a30
col position		heading 'Position'			format 999,999,999
col logging_property heading 'Status'			format a6
col supplemental_log_data_min heading 'Sup Log'	format a7
col force_logging	heading 'DB Log'			format a6
col spoolfile		heading 'Spool File Name'	format a50
col Info            heading 'Run below Command to manipulate Supplemental Logging'  for a180


col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/gg_src_supp_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti off
tti Left 'Supplemental Log Info :' skip 2

select supplemental_log_data_min, force_logging 
from v$database
/

tti off
tti Left 'Supplemental Log Group Info :' skip 2

select log_group_name, table_name, decode(always,'ALWAYS', 'Unconditional',NULL, 'Conditional') ALWAYS
from dba_log_groups
order by 2,1
/

tti off
tti Left 'Column Level Info :' skip 2

Accept ltable_name  char Prompt 'Enter Table Name for Log Group Columns?: '

select * 
from dba_log_group_columns 
where table_name=upper('&ltable_name')
order by position
/

tti off
tti Left 'Supplemental/Force Logging Command Information :' skip 2

select 'Enable Supplemental Logging     -> alter database add supplemental log data;' Info 
from dual
union
select 'Drop Supplemental Logging       -> alter database drop supplemental log data;' Info
from dual
union
select 'Enable Force Logging            -> alter database force logging;' Info
from dual
union
select 'Disable Force Logging           -> alter database nologging;' Info
from dual
union
select 'Add Supplemental Log for a Table Column -> alter table <OWNER>.<TABLE> add supplemental log group <GROUP>(<COLS>) always;' Info
from dual
union
select 'Drop Supplemental Log for Table -> alter table <OWNER>.<TABLE> drop supplemental log group <GROUP>;' Info
from dual
union
select 'Add Supplemental Log for all Columns of a Table -> alter table <OWNER>.<TABLE> add supplemental log data (all) columns;' Info
from dual
/

spool off