-- 	File 		:	GET_RAC_INTERCONNECT_INFO.SQL
--	Description	:	Provides details of Oracle RAC Interconnect Information
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col name					heading 'Name'					for a10
col ip_address				heading 'IP Address'
col con_id					heading 'Cont_ID'				
col event_name				heading 'Event Name'			for a50
col user_name				heading 'Username'				for a15
col cnt						heading 'Count'					for 999999999999
col session_id				heading 'Sess Id'
col session_serial#			heading 'Serial#'
col blocking_session		heading 'Blocking Ses'
col module					heading 'Module'				for a50
col machine					heading 'Machine'				for a15
col sql_opname				heading 'Sql-Op'				for a15
col program					heading 'Program'				for a40
col sec						heading 'Wait(s)'
col sql_exec_start			heading 'Time of Exec'
col inst_id					heading 'Inst'					for 99999
col total_size				heading	'ASH-Size(Mb)'				format 999,999,999
col awr_flush_emergency_count	heading 'Flush Count'		format 999,999,999
col spoolfile				heading 'Spool File Name'		format a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_rac_interconnect_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/
tti off
tti Left 'RAC Interconnect Info :' skip 2

SELECT * 
FROM gv$cluster_interconnects 
ORDER BY inst_id,name
/

SELECT * 
FROM gv$configured_interconnects 
ORDER BY inst_id,name
/

tti off
tti Left 'Top Waits :' skip 2

tti off
tti Left 'RAC Interconnect Command Information :' skip 2
select 'Put Information here' Info
from dual
/
spool off