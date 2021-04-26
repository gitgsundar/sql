set pages 9999 lines 200 verify off
col sid      					heading "Sid"				format 99999		
col serial#  					heading "Serial#"			format 999999
col username 			       	heading "User"				format a15
col program  					heading "Program"			format a30
col event    					heading "Event"				format a50
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
col loads						heading "Loads(#)"			format 9999999999
col sofar						heading "So Far"			format 9999999
col totalwork					heading "Total Work"		format 9999999
col message						heading "Summary Message"	format a100
col units						heading "Objects"			format a30
col time_remaining				heading "Remaining (S)"		format 9999999
col elapsed_seconds				heading "Elapsed (S)"		format 9999999
col start_time					heading "Start Time"
col last_update_time			heading "Last Update Time"
col action						heading "Action"
col idle						heading "Idle"				format a10
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/watch_stats_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lsid prompt 'Enter SID to gather stats: ' 

create global temporary table sess_stats(name varchar2(64), value number, diff number)
/

merge into sess_stats
using
(
	select a.name, b.value
	from v$statname a, v$sesstat b
	where a.statistic# = b.statistic#
	and b.sid = &lsid
) curr_stats
on (sess_stats.name = curr_stats.name)
when matched then
	update set diff = curr_stats.value - sess_stats.value,
				 value = curr_stats.value
when not matched then
	insert ( name, value, diff ) values
	( curr_stats.name, curr_stats.value, null )
/

select * from sess_stats where diff > 0 order by 1
/

drop table sess_stats
/