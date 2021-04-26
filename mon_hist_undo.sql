set pages 9999 
set verify off
col Instance				heading 	'Environment Info' 			format a100
col sid      				heading		"Sid"						format 99999
col serial#  				heading		"Serial#"					format 999999
col tablespace_name			heading 	'Tablespace Name'			format a30
col alloted_bytes 			heading 	'Alloted Bytes'				format 99,999,999,999,999
col free_bytes 				heading 	'Free Bytes'				format 99,999,999,999,999
col bytes           		heading		'Bytes (Mbytes)'			format 99,999,999,999,999
col segment_name    		heading		'Segment Name'				format a30
col segment_type    		heading		'Type'						format a10
col Sql		  				heading 	"Sql Statement" 			format a110
col sql_id					heading 	"Sql ID"					format a20
col owner           		heading		'Owner'						format a10
col file_name       		heading		'File Name'					format a50
col program  				heading		"Program"					format a40
col username		  		heading		"Username"					format a15
col status					heading		"Status"					format a9
col active_transaction		heading		"Active Txn Cnt"			format 9,999
col percent_free  			heading 	'Free %'					format 99.99
col UNDOBLKS				heading  	"Undo|Used (Mb)"
col TXNCOUNT				heading		"Txn Cnt"
col MAXCONCURRENCY			heading		"Max Concur|Txn"
col MAXQUERYID				heading		"Sql-ID"
col UNXPSTEALCNT  			heading 	"# Unexpired|Stolen"
col EXPSTEALCNT   			heading 	"# Expired|Reused"
col SSOLDERRCNT   			heading 	"ORA-1555|Error"
col NOSPACEERRCNT 			heading 	"Space|Error"
col MAXQUERYLEN   			heading 	"Max Query|Length(sec)"
col TUNED_UNDORETENTION		heading 	"Tuned Undo"
col start_date				heading		"Start Date"
col usn						heading 	"Undo#"							
col STATE					heading 	"State of Txn"				format a16
col UNDOBLOCKSDONE			heading 	"Reco Done"
col UNDOBLOCKSTOTAL			heading 	"Tot Reco"
col CPUTIME					heading 	"Reco Complete (sec)"

tti Left 'Instance Information :' skip 2

col spoolfile			heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_hist_undo_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
tti off

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lstart date format 'mmddyyyy:HH24MISS' Prompt 'Enter the Start Date (MMDDYYYY:HH24MISS) for Checking UNDO Stats: '
Accept lend	  date format 'mmddyyyy:HH24MISS' Prompt 'Enter the End Date (MMDDYYYY:HH24MISS) for Checking UNDO Stats: '   

tti Left 'Historical Undo Information :' skip 2
tti off

select trunc(begin_time,'MI') Start_date, MAXQUERYSQLID, round((UNDOBLKS*8192)/1048576) UNDOBLKS,TXNCOUNT,MAXCONCURRENCY, TUNED_UNDORETENTION,
      SSOLDERRCNT, MAXQUERYLEN ,	UNXPSTEALCNT, EXPSTEALCNT , NOSPACEERRCNT
from dba_hist_undostat
where begin_time between to_date('&lstart','MMDDYYYY:HH24MISS') and to_date('&lend','MMDDYYYY:HH24MISS') 
--	and (SSOLDERRCNT > 0 or NOSPACEERRCNT > 0)
order by begin_time;

tti Left 'Query Length Information :' skip 2
tti off
select begin_time, MAXQUERYLEN
from dba_hist_undostat
where MAXQUERYLEN in (
	select MAX(MAXQUERYLEN) MAXQUERYLEN
	from dba_hist_undostat
	where begin_time between to_date('&lstart','MMDDYYYY:HH24MISS') and to_date('&lend','MMDDYYYY:HH24MISS'))
/

tti off

spool off