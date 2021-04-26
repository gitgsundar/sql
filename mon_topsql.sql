-- 	File 		:	MON_TOPSQL.SQL
--	Description	:	Monitor Top SQL's
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance		heading 'Environment Info' 	format a100
col sql				heading 'Sql Text'									format a100
col buffer_gets		heading 'Buffer Gets'								format 999,999,999,999
col executions		heading 'Executions'								format 999,999,999,999
col address			heading 'Address'				
col hash_value		heading 'Hash Value'				
col disk_reads		heading 'Disk Reads'								format 999,999,999,999
col parse_calls		heading 'Parses'									format 999,999,999,999
col version_count	heading 'Versions'
col rows_processed 	heading	'Rows'										format 999,999,999
col sql_id 			heading 'Sql ID'									format a20
col cpu_sql			heading 'Sql Text with CPU Time > 10 sec'			format a100
col buf_sql			heading 'Sql Text with Buffer Gets > 10000'			format a100
col io_sql			heading 'Sql Text with Disk Reads > 10000'			format a100
col exec_sql		heading 'Sql Text with Executions > 100'			format a100
col parse_sql		heading 'Sql Text with Parse Calls > 1000'			format a100
col mem_sql			heading 'Sql Text using Shared Memory > 1M'			format a100
col ver_sql			heading 'Sql Text with same Version > 20'			format a100
col spoolfile		heading 'Spool File Name'							format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
col spoolfile		heading 'Spool File Name'							format a100
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_topsql_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

SELECT * FROM
(SELECT substr(sql_text,1,100) cpu_sql,sql_id,round(cpu_time/1000000) cpu_time, executions,  hash_value,address
 FROM V$SQLAREA
 WHERE round(cpu_time/1000000,2) > 0.5
 ORDER BY cpu_time DESC)
WHERE rownum <= 10
/

SELECT * FROM
(SELECT substr(sql_text,1,100) buf_sql,sql_id, buffer_gets, executions, buffer_gets/executions "Gets/Exec",hash_value,address
 FROM V$SQLAREA
 WHERE buffer_gets > 10000
 ORDER BY buffer_gets DESC)
WHERE rownum <= 20
/

SELECT * FROM
(SELECT substr(sql_text,1,100) io_sql,sql_id, disk_reads, executions, disk_reads/executions "Reads/Exec",hash_value,address
 FROM V$SQLAREA
 WHERE disk_reads > 1000
 ORDER BY disk_reads DESC)
WHERE rownum <= 10
/

SELECT * FROM
(SELECT substr(sql_text,1,100) exec_sql,sql_id, executions, rows_processed, rows_processed/executions "Rows/Exec",hash_value,address
 FROM V$SQLAREA
 WHERE executions > 100
 ORDER BY executions DESC)
WHERE rownum <= 10
/

SELECT * FROM
(SELECT substr(sql_text,1,100) parse_sql,sql_id, parse_calls, executions, hash_value,address
 FROM V$SQLAREA
 WHERE parse_calls > 1000
 ORDER BY parse_calls DESC)
WHERE rownum <= 10
/

SELECT * FROM 
(SELECT substr(sql_text,1,100) mem_sql, sql_id, sharable_mem, executions, hash_value,address
   FROM V$SQLAREA
  WHERE sharable_mem > 1048576
 ORDER BY sharable_mem DESC)
WHERE rownum <= 10
/

SELECT * FROM 
(SELECT substr(sql_text,1,100) ver_sql,sql_id, version_count, executions, hash_value,address
 FROM V$SQLAREA
 WHERE version_count > 20
 ORDER BY version_count DESC)
WHERE rownum <= 10
/

tti off
spool off