set long 99999 pages 9999 verify off
col Instance					heading "Environment Info"	format a100
col	sid							heading "Sid"
col serial#						heading "Serial#"
col username 					heading "Username"
col sql_text					heading "Sql Statement" 	format a1000
col hash_value				    heading "Hash Value"		format 99999999999
col plan_hash_value				heading "Plan Hash Value"	format 99999999999
col sql_id						heading "Sql ID"			format a15
col child_number				heading "Child#"
col access_predicates 			heading "Access Predicates"	format a70 word_wrapped
col filter_predicates 			heading "Filter Predicates"	format a70 word_wrapped

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_sqlinfo_dup_pred'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lsql_id char Prompt 'Enter Sql ID : '

break on sql_id skip 2 on plan_hash_value skip 1

with stmts as
(	select sql_id, plan_hash_value, child_number
	from
		(select sql_id, plan_hash_value, child_number, 
			count(child_number) over (partition by sql_id, plan_hash_value) ct_cno
		from v$sql 
		where sql_id like ('&lsql_id')
		)
	where ct_cno > 1
) 
,
	plan_steps as
	(select  sql_id, plan_hash_value, id, access_predicates, filter_predicates, count(id) ct_steps  
	from	v$sql_plan
	where 	(sql_id, plan_hash_value, child_number) IN (select * from stmts)
	group by sql_id, plan_hash_value, id, access_predicates, filter_predicates
	)
,
	dup_chk as
	(select sql_id, plan_hash_value, id, access_predicates, filter_predicates,
			count(id) over (partition by sql_id, plan_hash_value, id) ct_id
	from plan_steps
	)
select sql_id, plan_hash_value PHV, 
(select min(child_number) from v$sql_plan b 
 where b.sql_id = a.sql_id 
 and b.plan_hash_value = a.plan_hash_value 
 and nvl(b.access_predicates,'X') = nvl(a.access_predicates,'X')
 and nvl(b.filter_predicates,'X') = nvl(a.filter_predicates,'X')) child_no,
id, access_predicates, filter_predicates
from dup_chk a
where ct_id > 1
order by sql_id, plan_hash_value, id , child_no
/

spool off