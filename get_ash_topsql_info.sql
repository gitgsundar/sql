-- 	File 		:	GET_ASH_TOPSQL_INFO.SQL
--	Description	:	Provides details of Top10 SQLID's from ASH.
--	Info		:	Update Spool information as required to get the spool output.

clear columns
set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col Plan_hash				heading	'Plan Hash'				for 999999999999999
col type 					heading 'SQL Type'				for a15
col cpu						heading 'CPU Wait#'				for 999999999999
col IO						heading 'IO Wait#'				for 999999999999
col total					heading 'Total Wait#'			for 999999999999
col program 	 			heading 'Program'				for a30
col client_id				heading 'Client Info'			for a20
col machine 				heading 'Machine'			    for a15

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile 				new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ash_topsql_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Most Active SQL in the past Minute Info :' skip 2

select sql_id, count(*), round(count(*)/sum(count(*)) over (), 2) pctload 
from v$active_session_history
where sample_time > sysdate-1/24 
	and session_type <> 'BACKGROUND' 
group by sql_id 
order by count(*) desc;
/

tti off
tti Left 'Top 10 SqlIDs :' skip 2

select * from ( 
select 
	ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE Plan_hash, aud.name type, 
	sum(decode(ash.session_state,'ON CPU',1,0))     "CPU", 
	sum(decode(ash.session_state,'WAITING',1,0))    - 
	sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    "WAIT" , 
	sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    "IO" , 
	sum(decode(ash.session_state,'ON CPU',1,1))     "TOTAL" 
from v$active_session_history ash, 
  audit_actions aud 
where SQL_ID is not NULL 
and ash.sql_opcode=aud.action 
group by sql_id, SQL_PLAN_HASH_VALUE ,aud.name 
order by sum(decode(session_state,'ON CPU',1,1))   desc 
) 
where  rownum < 10 
/ 

spool off