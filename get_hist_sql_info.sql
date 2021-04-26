-- 	File 		:	GET_HIST_SQL_INFO.SQL
--	Description	:	Provides Historical Execution Details of SQLID
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"			format a100
col Sql		  					heading "Sql Statement" 			format a60
col Sql_ID						heading "Sql ID"					format a13
col Plan_Hash_Value				heading "Plan Hash Value"			format 999999999999
col timestamp					heading "Exe Plan First Produced"	format a30
col plan_table_output			heading "Execution Plan"
col snap_id						heading "Snap ID"					format 9999999
col begin_interval_time			heading "Time"						format a30
col plan_hash_value				heading "Plan Hash"					format 9999999999999
col profile 	  				heading "Profile"					format a30
col executions_total			heading "Exe #"						format 9999999999
col buffer_gets_total			heading "Buffer(LIO)"				format 9999999999
col cpu_time_total				heading "CPU"						format 99999.99
col ela_time_total				heading "Ela"						format 99999.99
col disk_reads_total			heading "Disk(PIO)"					format 9999999999
col iowait_total				heading "IO-Wait"					format 99999.99
col rows_processed_total		heading "Rows"						format 99999999999999
col spoolfile					heading 'Spool File Name'			format a200

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_sql_info_'||to_char(sysdate,'yyyymmdd_hhmiss') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

Accept lsql_id char Prompt 'Enter the Sql ID: '

tti off
tti Left 'Execution Details :' skip 2

select
  s.snap_id,
  h.begin_interval_time,
  s.sql_id,
  plan_hash_value,
  nvl(sql_profile,'No Profile') profile,
  sum(executions_total)	executions_total,
  sum(cpu_time_total*power(10,-6))/nullif(sum(executions_total),0) "cpu_time_total",
  sum(elapsed_time_total*power(10,-6))/nullif(sum(executions_total),0) "ela_time_total",
  sum(iowait_total*power(10,-6))/nullif(sum(executions_total),0) "iowait_total",
  sum(buffer_gets_total)/nullif(sum(executions_total),0) buffer_gets_total,
  sum(disk_reads_total)/nullif(sum(executions_total),0) "disk_reads_total",
  sum(rows_processed_total) rows_processed_total
from
  dba_hist_sqlstat s,
  dba_hist_snapshot h
where s.sql_id='&lsql_id'
and s.snap_id=h.snap_id
and begin_interval_time > sysdate-&ldays
group by s.snap_id,s.sql_id, plan_hash_value,nvl(sql_profile,'No Profile'),h.begin_interval_time
order by 1
/

tti off
tti Left 'SQL Details :' skip 2

select sql_text Sql 
from dba_hist_sqltext 
where sql_id='&lsql_id'
/

tti off
tti Left 'Plan Info :' skip 2

select distinct sql_id Sql_ID, PLAN_HASH_VALUE Plan_Hash_Value, timestamp
from DBA_HIST_SQL_PLAN 
where sql_id= '&lsql_id'
order by timestamp
/

Accept lfeedback  char Prompt 'Want Historical Plan Info? (Y/N): '

tti off
tti Left 'Plan Info Details :' skip 2

declare
begin
	if upper('&lfeedback')='Y' then
		for i in (SELECT tf.* FROM DBA_HIST_SQLTEXT ht, table(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf WHERE ht.sql_id='&lsql_id') loop
		    dbms_output.put_line(i.plan_table_output);
	    end loop;
	end if;
end;
/



-- SELECT tf.* FROM DBA_HIST_SQLTEXT ht, table(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf WHERE ht.sql_id='&lsql_id'
-- /

tti off

-- select name,value_string from dba_hist_sqlbind where sql_id='&lsql_id'
-- /

spool off