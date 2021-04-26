-- 	File 		:	GET_ASH_ELASQL_INFO.SQL
--	Description	:	Provides details of Elapsed Time of SQL's from ASH.
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col mx						heading 'Max ELA'				for 999,999
col mn						heading 'Min ELA'				for 999,999
col av						heading 'Avg ELA'				for 999,999.99
col	cnt						heading 'Count'					for 999,999
col SQL_EXEC_START 			heading 'SQL Date/Time'			for a20
col SQL_PLAN_HASH_VALUE		heading	'Plan Hash'				for 999999999999999
col type 					heading 'SQL Type'				for a15
col cpu						heading 'CPU Wait#'				for 999999999999
col IO						heading 'IO Wait#'				for 999999999999
col total					heading 'Total Wait#'			for 999999999999
col program 	 			heading 'Program'				for a30
col client_id				heading 'Client Info'			for a20
col machine 				heading 'Machine'			    for a15

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile 				new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ash_elasql_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/
tti Left 'Top SQLIDs executed more than 10 Times :' skip 2
tti off

select 
	sql_id, 
	count(*) cnt, 
	max(tm) mx, 
	avg(tm) av, 
	min(tm) min 
from ( 
select 
	 sql_id, 
	 sql_exec_id, 
	 max(tm) tm 
from ( select 
		   sql_id, 
		   sql_exec_id, 
		   ((cast(sample_time  as date)) - 
		   (cast(sql_exec_start as date))) * (3600*24) tm 
		from 
		   dba_hist_active_sess_history 
		where sql_exec_id is not null 
 ) 
group by sql_id,sql_exec_id 
) 
group by sql_id 
having count(*) > 10 
order by mx,av 
/ 

Accept lsql_id char Prompt 'Enter Sql ID > : '
variable b0 varchar2(50);
exec 	:b0 := '&lsql_id';

tti Left 'Top SQL with Hash Information :' skip 2
tti off

select * from (
	select
		 ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE Plan_hash, aud.name type,SQL_EXEC_START,
		 program, client_id, machine,
		 sum(decode(ash.session_state,'ON CPU',1,0))     "CPU",
		 sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    "IO" ,
		 sum(decode(ash.session_state,'ON CPU',1,1))     "TOTAL"
	from dba_hist_active_sess_history ash,
		 audit_actions aud
	where sql_id = :b0
	   and ash.sql_opcode=aud.action
	group by sql_id, SQL_PLAN_HASH_VALUE , aud.name, SQL_EXEC_START, program, client_id, machine
	order by sum(decode(session_state,'ON CPU',1,1))   desc) 
where  rownum < 10
/

spool off