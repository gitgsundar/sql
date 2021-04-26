-- 	File 		:	MON_ONE_SES.SQL
--	Description	:	Provides details of one Session based on SID. 
--	Info		:	Update Spool information as required to get the spool output.

col sid      					heading "Sid"				format 99999
col serial#  					heading "Serial#"			format 999999
col username        			heading "User"				format a15
col program  					heading "Program"			format a30
col event    					heading "Event"				format a55
col Instance					heading "Environment Info"	format a100
col Sql		  					heading "Sql Statement" 	format a110
col hash_value				    heading "Hash Value"		format 999999999999
col plan_hash_value				heading "Plan Hash Value"	format 999999999999
col sql_id						heading "Sql ID"			format a20
col executions  				heading "Exe(#)" 			format 9999999999
col buffer_gets  				heading "Buffers(#)" 		format 9999999999
col disk_reads  				heading "I/O(#)" 			format 9999999999
col parse_calls					heading "Parse(#)" 			format 9999999999
col Invalidations  				heading "Invalid(#)" 		format 9999999999
col cpu_time					heading "CPU(s)"			format 9999999999
col ela_time					heading "Ela(s)"			format 9999999999
col rows_processed				heading "Rows(#)"			format 9999999999
col shadow_process				heading "SProc"				format a10
col status						heading "Status"			format a10
col module						heading "Module"
col client_process				heading "CProc" 			format a10
col logon_time					heading "Logon Time"		format a25
col client						heading "Client Info"		format a15
col loads						heading "Loads(#)"			format 9999999999
col sofar						heading "So Far"			format 9999999
col seconds_in_wait				heading "Wait(s)"			format 9999999999
col totalwork					heading "Total Work"		format 9999999
col message						heading "Summary Message"	format a80
col units						heading "Objects"			format a15
col time_remaining				heading "Remaining (S)"		format 9999999
col elapsed_seconds				heading "Elapsed (S)"		format 9999999
col start_time					heading "Start Time"
col last_update_time			heading "Last Update Time"
col action						heading "Action"			format a30
col idle						heading "Idle"				format a10
col block_gets					heading "Blk Gets"			format 999,999,999,999
col consistent_gets				heading "Cons Gets"			format 999,999,999,999
col physical_reads				heading "I/O"				format 999,999,999,999
col block_changes				heading "Blk Chgs"			format 999,999,999,999
col consistent_changes			heading "Cons Chgs"			format 999,999,999,999
col optimized_physical_reads	heading "Opt I/O"			format 999,999,999,999
col used_ublk					heading "Undo Blks"			format 999,999,999,999
col used_urec					heading "Undo Recs"			format 999,999,999,999
col spoolfile					heading 'Spool File Name'	format a150
col p1text						heading "First-Wait Desc"	format a30
col p2text						heading "Second-Wait Desc"	format a30
col p3text 						heading "Third-Wait Desc"	format a30
col state						heading "Status"			format a20

col instance new_value instance
set termout off verify off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on

col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_one_ses_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from gv$instance
/

Accept lsid number Prompt 'Enter the Session Id : '

tti off
tti Left 'Session Information :' skip 2

select s.sid,s.serial#,s.username,s.logon_time,s.status,s.program, s.module ,si.block_changes,s.seconds_in_wait
from gv$session s, gv$sess_io si
where 	s.type	=	'USER' and
		s.sid	=	si.sid and
		s.sid 	= 	&lsid
order by logon_time
/

tti off
tti Left 'Session Shadow/Client Process Information :' skip 2

select s.sid,s.serial#,s.status,s.logon_time, p.spid shadow_process, s.process client_process,s.client_identifier Client,s.username,nvl(s.program,'None') program, s.action,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from gv$session s, gv$process p
where s.paddr = p.addr and
		s.sid   = &lsid
/

tti off
tti Left 'Session running SQL Information :' skip 2

select sql_text Sql,Sql_id, executions 
from gv$sqlarea 
where address in 
	(select sql_address from gv$session where sid=&lsid)
/	

tti off
tti Left 'Session using Resources to run SQL Information :' skip 2

select Sql_id, Plan_hash_value, buffer_gets,disk_reads,parse_calls,executions,invalidations,round(cpu_time/1000000) cpu_time, round(elapsed_time/1000000) ela_time,rows_processed,loads
from gv$sqlarea
where hash_value in (select hash_value from gv$sqlarea where address in 
	(select sql_address from gv$session where sid=&lsid)) 
/

select used_ublk,used_urec,log_io "Logical IO",phy_io "Phyical IO",cr_get "Consistent Gets",status 
from gv$transaction 
where addr in (select taddr from gv$session where sid=&lsid) 
/

tti off
tti Left 'Session waits Information :' skip 2

select event,total_waits "Total Waits" ,total_timeouts "Total Timeouts"
from gv$session_event 
where sid=&lsid 
order by 2 desc
/

select event,p1text||' -> '||p1 p1text,p2text||' -> '||p2 p2text,p3text||' -> '||p3 p3text,seconds_in_wait,state
from gv$session_wait 
where sid=&lsid
/

select event,p1text||' -> '||p1 p1text,p2text||' -> '||p2 p2text,p3text||' -> '||p3 p3text,wait_time
from gv$session_wait_history 
where sid=&lsid
/

tti off
tti Left 'Session I/O Information :' skip 2

select * from gv$sess_io where sid=&lsid
/

tti off
tti Left 'Session LongOPS for last 10min Information :' skip 2

select message,sofar,totalwork,units,start_time,last_update_time,time_remaining,elapsed_seconds 
from gv$session_longops 
where sid=&lsid and serial# in (select serial# from gv$session where sid=&lsid)
 and start_time > sysdate-1/24*1/6
order by start_time desc
/

spool off