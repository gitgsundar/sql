-- 	File 		:	GET_HIST_PARAMETER_INFO.SQL
--	Description	:	Provides details of Historical Database File IO Stats
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"	format a100
col date_time					heading "Date Time"			format a30
col snap_id						heading "Snap ID"			format 9999999
col parameter_name				heading "Parameter Name"	format a50
col old_value					heading "Old Value"			format a50
col new_value					heading "New Value"			format a50
col spoolfile					heading 'Spool File Name'	format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_parameter_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

tti Left 'Parameter Information :' skip 2

select to_char(s.begin_interval_time, 'DD-Mon-YYYY HH24:MI:SS') date_time,
	p.snap_id,
	p.name,
	p.old_value,
	p.new_value
from (select dbid, instance_number,
			snap_id, parameter_name name,
			lag(trim(lower(value)))	over (partition by dbid,instance_number,parameter_name	order by snap_id) old_value,
			trim(lower(value)) new_value
		from dba_hist_parameter) p,
	dba_hist_snapshot s
where s.begin_interval_time between trunc(sysdate - &ldays) and sysdate
	and p.instance_number = s.instance_number
	and p.snap_id = s.snap_id
	and p.old_value <> p.new_value
order by s.begin_interval_time
/

tti off
spool off