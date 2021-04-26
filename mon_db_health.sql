-- 	File 		:	MON_DB_HEALTH.SQL
--	Description	:	Monitor Database Health.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading 'Environment Info'			for a100
col host_name 				heading 'HostName'					for a30
col instance_name			heading 'Instance Name'				for a15
col DBTime					heading 'DBTime|(Load)'				for	9999.99
col sql_id					heading 'Sql ID'					for a15
col Inst_id					heading 'Inst'						for 9999
col DateTime				heading 'Date-Time'
col begin_time				heading 'Begin Time'
col end_time				heading 'End Time'
col version 				heading 'Version'					for a12
col role 					heading 'DB Role'					for a18 

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile				heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_db_health_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Current DB Load :' skip 2

select host_name, instance_name, t.DBTime*0.01 DBTime
from gv$instance i,
	(select inst_id, count(*) DBTime  
	from gv$active_session_history
	where sample_time > sysdate - 1/24/60
		and session_type <> 'BACKGROUND'
	group by inst_id) t
where i.inst_id = t.inst_id
/

tti off
tti Left 'Top SQLs by Loads :' skip 2

select inst_id, sql_id, count(*) DBTime, round(count(*)*100/sum(count(*)) over (), 2) pctload
from gv$active_session_history
where sample_time > sysdate - 1/24/60
and session_type <> 'BACKGROUND'
group by inst_id, sql_id
order by count(*) desc;	  


tti off
tti Left 'SQL Service Response Time Information :' skip 2

select to_char(begin_time) DateTime, round( value * 10, 2) "Response Time (ms)"
from v$sysmetric
where metric_name='SQL Service Response Time'
/

tti off
tti Left 'DB Throughput Information :' skip 2

select a.begin_time, a.end_time, round(((a.value + b.value)/131072),2) "GB per sec"
from v$sysmetric a, v$sysmetric b
where a.metric_name = 'Logical Reads Per Sec'
and b.metric_name = 'Physical Reads Direct Per Sec'
and a.begin_time = b.begin_time
/

tti off
spool off