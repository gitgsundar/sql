set pages 9999 long 99999 verify off
col Instance					heading "Environment Info"	format a100
col date_time					heading "Date Time"			format a30
col stat_id						heading "Stat Id"			format 999999999999999
col stat_name					heading 'Stat Name'			format a70
col max_value				    heading	'Max Value'			format 999,999,999,999,999,999
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_hist_sysstat'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '

Accept lstat_name char Prompt 'Enter the Stat Name : '

select stat_id, name stat_name 
from v$statname
where name like '%&lstat_name%'
order by 2
/

Accept lstat_id char Prompt 'Enter StatID from the above list: '

tti Left 'Resource Information :' skip 2

select
     trunc(sn.begin_interval_time) date_time,
     s.stat_name                   stat_name,
     max(value)        		   max_value
from  dba_hist_sysstat s,
      dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >= trunc(sysdate-&ldays)
        and s.snap_id                   = sn.snap_id
        and s.dbid                      = sn.dbid
        and s.instance_number           = sn.instance_number
        and s.dbid                      = (select dbid from v$database)
        and s.instance_number           = (select instance_number from v$instance)
        and s.stat_id                   = &lstat_id
group by trunc(begin_interval_time),stat_name
order by 1
/

tti off
