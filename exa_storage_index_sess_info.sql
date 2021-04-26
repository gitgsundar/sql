-- 	File 			:	EXA_STORAGE_INDEX_SES.SQL
--		Description	:	Provides Exadata Storage Index Usage for the session.
--		Info			:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance					heading 	'Environment Info'	format a100
col sql_id						heading 	'Sql ID'					format a15
col elapsed_time				heading "Elapsed(s)"				format 999999
col buffer_gets  				heading "Avg LI/O(#)" 			format 9999999999
col disk_reads  				heading "Avg PI/O(#)" 			format 999999
col cpu_time					heading "Avg CPU Time(s)"		format 999999
col executions  				heading "Exe(#)" 					format 9999999999
col rows_processed			heading "Rows(#)"					format 99999999999999999999
col stat_name					heading "Stat Name"				format a30
col value						heading "Value"					format 99999999999.99
col spoolfile					heading 	'Spool File Name'		format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'exa_storage_index_ses_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lsid char Prompt 'Enter the Oracle Session ID (sid) : '
variable b0 number;
exec 	:b0 := &lsid;

tti off
tti Left 'SQL Execution Details Information :' skip 2

select sql_id, child_number, plan_hash_value, last_active_time,executions,
	(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) Elapsed_time,
	disk_reads/decode(nvl(executions,0),0,1,executions) Disk_reads,
	buffer_gets/decode(nvl(executions,0),0,1,executions) Buffer_gets,
	(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) cpu_time
	,sql_text,sql_plan_baseline, rows_processed
from v$sql s
where sql_id = ':b0'
order by 1, 2, 3
/

tti off
tti Left 'Storage Index Stats Info :' skip 2

select decode(name, 'cell physical IO bytes saved by storage index', 'SI Savings',
	'cell physical IO interconnect bytes returned by smart scan', 'Smart Scan') as stat_name,
	value/1024/1024 as value
from v$sesstat s, v$statname n
where s.statistic# = n.statistic#
	and sid = :b0
	and n.name in ('cell physical IO bytes saved by storage index',
	'cell physical IO interconnect bytes returned by smart scan');

tti off
spool off