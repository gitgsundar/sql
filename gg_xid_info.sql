set pages 9999 lines 200 verify off
col sid      					heading "Sid"					format 99999
col serial#  format 999999		heading "Serial#"
col username format a15      	heading "User"
col program  format a30			heading "Program"
col event    format a50			heading "Event"
col Instance					heading "Environment Info"		format a100
col Sql		  					heading "Sql Statement" 		format a110
col hash_value				    heading "Hash Value"			format 999999999999
col plan_hash_value				heading "Plan Hash Value"		format 999999999999
col sql_id						heading "Sql ID"				format a20
col executions  				heading "Exe(#)" 				format 9999999999
col log_io		  				heading "Log IO" 				format 9999999999
col start_date					heading "Txn Start Time"
col phy_io		  				heading "Phy IO" 				format 9999999999
col cr_gets						heading "Con Gets" 				format 9999999999
col cr_chage	  				heading "Con Chg" 				format 9999999999
col cpu_time					heading "CPU(s)"				format 9999999999
col ela_time					heading "Ela(s)"				format 9999999999
col rows_processed				heading "Rows(#)"				format 9999999999
col shadow_process				heading "Server Proc"			format 999999999
col status						heading "Status"				format a10
col module						heading "Module"
col client_process				heading "Client Proc" 			format 999999999
col logon_time					heading "Logon Time"			format a25
col client						heading "Client Info"			format a30
col loads						heading "Loads(#)"				format 9999999999
col sofar						heading "So Far"				format 9999999
col totalwork					heading "Total Work"			format 9999999
col message						heading "Summary Message"		format a100
col units						heading "Objects"				format a30
col time_remaining				heading "Remaining (S)"			format 9999999
col elapsed_seconds				heading "Elapsed (S)"			format 9999999
col start_time					heading "Start Time"
col last_update_time			heading "Last Update Time"
col action						heading "Action"
col idle						heading "Idle"					format a10
col spoolfile					heading 'Spool File Name'		format a50


col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/gg_xid_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lxid char Prompt 'Enter XID of Long Running Txn: '

tti off
tti Left 'XID User Information :' skip 2

select sid,serial#,username,status,logon_time,program,
	floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'|| mod(mod(last_call_et,3600),60) "IDLE"
from v$session 
where taddr in (select addr from v$transaction
               where xidusn||'.'||xidslot||'.'||xidsqn='&lxid')
/                      

tti off
tti Left 'XID Transaction Information :' skip 2

select start_date, log_io, phy_io, cr_get, cr_change
from v$transaction
where xidusn||'.'||xidslot||'.'||xidsqn='&lxid'
/

tti off
spool off