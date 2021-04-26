-- 	File 		:	GET_DB_SERVICE_INFO.SQL
--	Description	:	Provides details of the Oracle Database Services
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance			heading 'Environment Info'	format a100
col inst_id				heading 'Inst'				format 9999
col instance_name		heading 'Inst Name'			format a15
col service_id			heading	'Id'				format 999
col name 				heading	'Service Name'		format a20
col network_name		heading	'Network Name'		format a20
col creation_date		heading	'Creation Date'		format a20
col blocked				heading 'Blk'				format a3
col username			heading 'Username'			format a15
col program				heading 'Program'			format a35
col machine				heading 'Machine'			format a30
col service_name 		heading	'Service Name'		format a30
col sid					heading 'Sid,Serial#'		format a15
col failover_method		heading 'Failover Method'	format a15
col failover_type		heading 'Failover Type'		format a15
col failover_retries	heading 'Retries'			format 9999
col goal				heading 'Goal'				format a12
col clb_goal			heading 'CGoal'
col spoolfile			heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_db_service_info'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'DB Service Information :' skip 2

select service_id,name,network_name,failover_method, failover_type, failover_retries,goal, clb_goal,creation_date 
from dba_services
where network_name is not null
order by service_id
/

tti off
tti Left 'DB Active Service Information :' skip 2

select service_id,name,network_name,creation_date,blocked
from gv$active_services
where network_name is not null
order by service_id
/

tti off
tti Left 'User Service Information :' skip 2

select username, sid||','||serial# sid, program, machine, service_name,failover_method, failover_type 
from gv$session
where service_name not like 'SYS%'
order by 5,1
/

select i.inst_id, i.instance_name, service_name, count(*) 
from gv$session s, gv$instance i
where service_name not like 'SYS%' and
    s.inst_id = i.inst_id
group by i.inst_id, i.instance_name,service_name
order by 1,2
/

spool off