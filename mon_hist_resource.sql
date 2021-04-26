set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"	format a100
col date_time					heading "Date Time"			format a30
col Resource_name				heading 'Resource Name'		format a30
col min_value			        heading	'Min Value'	    	format 999999
col max_value			        heading	'Max Value'			format 999999
col trend_value			        heading	'Trending Value'	format 999999

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_hist_resource_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '
Accept lresource_name char Prompt 'Enter the Resource Name : '


tti Left 'Resource Information :' skip 2

select
     trunc(sn.begin_interval_time) date_time,
     r.resource_name               resource_name,
     min(r.current_utilization)    min_value,     
     max(r.max_utilization)        max_value
from  dba_hist_resource_limit r,
      dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >= trunc(sysdate-&ldays)
        and r.snap_id                   = sn.snap_id
        and r.dbid                      = sn.dbid
        and r.instance_number           = sn.instance_number
        and r.dbid                      = (select dbid from v$database)
        and r.instance_number           = (select instance_number from v$instance)
        and r.resource_name  like       '%&lresource_name%'
group by trunc(begin_interval_time),resource_name
order by 1
/


Accept ldays number Prompt 'How many Days of Historical Information: '

tti Left 'Resource Trending Information :' skip 2

select
     sn.begin_interval_time		   date_time,
     r.resource_name               resource_name,
     r.current_utilization    	   trend_value     
from  dba_hist_resource_limit r,
      dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >= trunc(sysdate-&ldays)
        and r.snap_id                   = sn.snap_id
        and r.dbid                      = sn.dbid
        and r.instance_number           = sn.instance_number
        and r.dbid                      = (select dbid from v$database)
        and r.instance_number           = (select instance_number from v$instance)
        and r.resource_name  like       '%&lresource_name%'
order by 1
/

tti off
spool off