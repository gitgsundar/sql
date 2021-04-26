set pages 9999 
set verify off
col Instance			heading 'Environment Info' 			format a100
col file_type			heading 'File Type'				format a20
col name			heading 'FRA Name'				format a20
col percent_free  		heading 'Free %'				format 999.99
col total_size			heading 'Total Mbytes'				format 999,999,999,999
col Used			heading 'Used Mbytes'				format 999,999,999,999
col reclaimable			heading 'Reclaimable'				format 999,999,999,999
col number 			heading 'Files#'

tti off

col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_fra_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'FlashSpace Information :' skip 2

select (case when percent_used > 100 then 0 else (100-percent_used) end) percent_free
from (select (sum(percent_space_used)-sum(percent_space_reclaimable)) percent_used  from v$flash_recovery_area_usage)
/

tti off
tti Left 'FileTypes Information :' skip 2	

Select file_type, percent_space_used as used,percent_space_reclaimable as reclaimable, number_of_files as "number" 
from v$flash_recovery_area_usage
/

tti off
tti Left 'Space Usage Information :' skip 2	

select name, space_limit/1048576 as Total_size ,space_used/1048576 as Used, SPACE_RECLAIMABLE/1048576 as reclaimable ,NUMBER_OF_FILES as "number" 
from  V$RECOVERY_FILE_DEST
/
   
tti off
spool off