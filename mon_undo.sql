-- 	File 		:	MON_UNDO.SQL
--	Description	:	Monitor Database UNDO Activity
--	Info		:	Update Spool information as required to get the spool output.


set pages 9999 
set verify off
col Instance				heading 	'Environment Info' 				format a100
col sid      				heading		"Sid"							format 99999
col serial#  				heading		"Serial#"						format 999999
col tablespace_name			heading 	'Tablespace Name'				format a30
col alloted_bytes 			heading 	'Alloted (MBytes)'				format 99,999,999,999,999
col free_bytes 				heading 	'Free (MBytes)'					format 99,999,999,999,999
col bytes           		heading		'Size (Mbytes)'					format 99,999,999,999,999
col segment_name    		heading		'Segment Name'					format a30
col segment_type    		heading		'Type'							format a10
col Sql		  				heading 	"Sql Statement" 				format a150
col sql_id					heading 	"Sql ID"						format a15
col owner           		heading		'Owner'							format a10
col file_name       		heading		'File Name'						format a50
col program  				heading		"Program"						format a40
col username		  		heading		"Username"						format a15
col status					heading		"Status"						format a9
col active_transaction		heading		"Active Txn Cnt"				format 9,999
col logon_time				heading 	"Logon Time"					format a20
col percent_free  			heading 	'Free %'						format 99.99
col XIDUSN					heading 	"Undo Segment"					format 9999
col used_ublk				heading 	"# Used UBlks"					format 999,999,999
col used_urec				heading		"# Used URecs"					format 999,999,999
col UNDOBLKS				heading  	"Undo Blks"
col TXNCOUNT				heading		"Txn Cnt"
col MAXCONCURRENCY			heading		"Max Concur|Txn"
col UNXPSTEALCNT  			heading 	"# Unexpired|Stolen"
col EXPSTEALCNT   			heading 	"# Expired|Reused"
col SSOLDERRCNT   			heading 	"ORA-1555|Error"
col NOSPACEERRCNT 			heading 	"Space|Error"
col MAXQUERYLEN   			heading 	"Max Query|Length(sec)"
col TUNED_UNDORETENTION		heading 	"Tuned Undo"
col start_date				heading		"Start Date"
col usn						heading 	"Undo#"							
col STATE					heading 	"State of Txn"					format a16
col UNDOBLOCKSDONE			heading 	"Reco Done"
col UNDOBLOCKSTOTAL			heading 	"Tot Reco"
col CPUTIME					heading 	"Reco Complete (sec)"

tti Left 'Instance Information :' skip 2

col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_undo_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
tti off

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Undo Information :' skip 2

show parameter undo_

tti off

select distinct tablespace_name from dba_rollback_segs where segment_name!='SYSTEM';

tti off

select file_name,bytes/1048576 bytes from dba_data_files
where tablespace_name in 
 (select distinct tablespace_name from dba_rollback_segs where segment_name not in ('SYSTEM'))
order by 2
/

select a.tablespace_name, alloted_bytes/1048576 alloted_bytes, nvl(free_bytes/1048576,0) free_bytes, nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select tablespace_name, sum(bytes) alloted_bytes from dba_data_files group by tablespace_name
                          union
      select tablespace_name, sum(bytes) alloted_bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes) free_bytes from dba_free_space group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
      and a.tablespace_name in (select distinct tablespace_name from dba_rollback_segs where segment_name not in ('SYSTEM'))
order by 1
/

tti Left 'Undo Extents Information :' skip 2

select status Status,sum(bytes)/1048576 Bytes, count(*) 
from dba_undo_extents 
group by status
/

tti off
tti Left 'Active Transaction Information (USED_UREC, USED_UBLK start to decrease when Transactions are Rolling Back):' skip 2

select count(*) Active_Transaction 
From gv$rollstat where xacts > 0
/
tti off

select s.inst_id,sid,serial#,logon_time,program,username,s.status, xidusn, used_urec, used_ublk 
from gv$session s, gv$transaction t
where s.saddr=t.ses_addr
/

select sid, a.sql_id sql_id, a.sql_text Sql
from gv$sqlarea a, gv$session s
where a.address = s.sql_address 
  and s.saddr in (select ses_addr from gv$transaction)
/  

tti Left 'Undo Space needed to handle Peak Undo Activity :' skip 2

SELECT (UR * (UPS * DBS))/1048576 AS "Bytes" 
FROM (select max(tuned_undoretention) AS UR from v$undostat),
 (SELECT undoblks/((end_time-begin_time)*86400) AS UPS FROM v$undostat WHERE undoblks = (SELECT MAX(undoblks) FROM v$undostat)),
 (SELECT block_size AS DBS FROM dba_tablespaces WHERE tablespace_name = (SELECT UPPER(value) FROM v$parameter WHERE name = 'undo_tablespace'));

tti off

tti Left 'Space and Snapshot Too Old Errors Information :' skip 2

select to_char(begin_time,'YYYY-MM-DD HH24:MI:SS') "Begin",
	to_char(end_time,'YYYY-MM-DD HH24:MI:SS') "End ",
	undoblks,
	maxquerylen,
	unxpstealcnt,expstealcnt,tuned_undoretention,
	SSOLDERRCNT,
	NOSPACEERRCNT
from V$UNDOSTAT
where SSOLDERRCNT > 0 or NOSPACEERRCNT > 0
/
tti off

tti Left 'Progress of Transactions that Oracle is Recovering Information :' skip 2

select inst_id,USN,STATE,UNDOBLOCKSDONE,UNDOBLOCKSTOTAL,CPUTIME
from gv$fast_start_transactions
order by state
/
tti off

tti Left 'TEMP Undo Usage :' skip 2

select *
from gv$tempundostat
order by 1
/
tti off

spool off


