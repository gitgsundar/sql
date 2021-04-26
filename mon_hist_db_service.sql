set pages 9999 
set verify off
col Instance				heading 'Environment Info' 			format a100
col snap_id					heading 'Snap ID'					format 9999999999999
col service_name			heading 'Service Name'				format a30
col service_name_hash		heading 'Service Hash'				format 9999999999999
col stat_name				heading 'Stat Name'					format a30
col spoolfile				heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile

tti Left 'Instance Information :' skip 2

select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_hist_db_service_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti off
tti Left 'DB Active Service Information :' skip 2

select service_id,name,network_name,creation_date,blocked
from gv$active_services
where network_name is not null
order by service_id
/

tti off

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '
Accept lservice_name char Prompt 'Enter DB Service Name : '

tti Left 'Historical DB Service Information :' skip 2

select
	 s.snap_id						 snap_id,
     trunc(sn.begin_interval_time)   date_time,
     s.service_name                  service_name,
     s.service_name_hash			 service_name_hash,
     stat_name			             stat_name,
     value							 value
from  dba_hist_service_stat s,
           dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >= trunc(sysdate-&ldays)
        and s.snap_id                   = sn.snap_id
        and s.dbid                      = sn.dbid
        and s.instance_number           = sn.instance_number
        and s.dbid                      = (select dbid from v$database)
        and s.instance_number           = (select instance_number from v$instance)
        and s.service_name  like       '%&lservice_name%'
        and stat_name                   = 'logons cumulative'
-- group by trunc(begin_interval_time),service_name,stat_name,value
order by 1,2
/

tti Left 'Session for Specific Service Hash Information :' skip 2

Accept lservice_name_hash 	number Prompt 'Enter Service Name Hash: '
Accept lsnap_id 			number Prompt 'Enter Snap ID : '


select  *
from    dba_hist_active_sess_history   d
where   d.snap_id      	= &lsnap_id
   and 	d.dbid            = (select dbid from v$database)
   and 	d.instance_number = (select instance_number from v$instance)
   and  d.service_hash 	= &lservice_name_hash
/

tti off

spool off