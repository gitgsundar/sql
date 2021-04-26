set pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col action_time					heading "Date" 				format a30
col action						heading "Action"			format a15
col namespace					heading "Name Space"		format a15
col version						heading "Version"			format a15
col id							heading "Id"		
col bundle_series				heading "Bundle"			format a20
col comments					heading "Comments"			format a40	

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_id char Prompt 'Enter the Sql ID: '

select sql_id, child_number, plan_hash_value plan_hash, executions,
	(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) Elapsed_time,
	disk_reads/decode(nvl(executions,0),0,1,executions) Disk_reads,
	buffer_gets/decode(nvl(executions,0),0,1,executions) Buffer_gets,
	(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) cpu_time
	,sql_text
	,address,child_address
from v$sql s
where sql_id = '&lsql_id'
order by 1, 2, 3
/

select 'exec dbms_shared_pool.purge('''||address||','||hash_value||''',''C'',1);'
from v$sqlarea 
where sql_id='&lsql_id'
/

