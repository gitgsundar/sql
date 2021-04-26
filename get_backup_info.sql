-- 	File 		:	GET_BACKUP_INFO.SQL
--	Description	:	Provides RMAN Backup Details. 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200
col Instance			heading 'Environment Info'	format a100
col name				heading	'Configuration'		format a30
col value				heading	'Value'				format a100
col start_time 			heading	'Start Time'		format a30
col end_time			heading	'End Time'			format a30
col elapsed_seconds 	heading	'Ela Time (min)'	format 99,999.99
col status				Heading	'Status'			format a25
col input_type			heading	'Backup Type'		format a15
col bytes_read			heading 'Bytes_Read'		format a10
col bytes_written		heading 'Bytes_Written'		format a15
col Backup_type			heading	'Backup Type'		format a15
col Completed_time		heading 'Completed Time'	format a30
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_backup_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

tti Left 'RMAN Configuration Information :' skip 2

select name,value 
from v$rman_configuration
/

tti off

tti Left 'Latest Backup Information :' skip 2

select decode(backup_type,'D','Full_backup','L','Archived_logs','I','Incremental') as Backup_type, 
	max(completion_time) as Completed_time 
from gv$backup_set
where (backup_type in ('D','I') and CONTROLFILE_INCLUDED='YES' and incremental_level is not null)
	or (backup_type='L'and CONTROLFILE_INCLUDED='NO' and incremental_level is null)
group by backup_type
/

tti off

tti Left 'Backup Information :' skip 2

Accept ldays number Prompt 'Enter Number of Days of Historical Data to be pulled for DB Backup : '

select start_time, end_time,input_type,status,input_bytes_display Bytes_read, output_bytes_display Bytes_written,round(elapsed_seconds/60,2) elapsed_seconds
from v$rman_backup_job_details
where trunc(start_time) > trunc(sysdate-&ldays)
  and input_type like 'D%'
order by input_type desc, start_time desc
/


Accept ldays number Prompt 'Enter Number of Days of Historical Data to be pulled for Archive Backup : '

select start_time, end_time,input_type,status,input_bytes_display Bytes_read, output_bytes_display Bytes_written,round(elapsed_seconds/60,2) elapsed_seconds
from v$rman_backup_job_details
where trunc(start_time) > trunc(sysdate-&ldays)
  and input_type like 'A%'
order by input_type desc, start_time desc
/

tti off

spool off