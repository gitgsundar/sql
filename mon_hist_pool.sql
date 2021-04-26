set pages 9999 long 99999 verify off
col Instance			heading "Environment Info"	format a100
col date_time			heading "Date Time"			format a30
col pool				heading 'Pool Name'			format a30
col Name				heading "Pool Names"				format a32
col bytes				heading	'Value'				format 99,999,999,999

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_hist_pool_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lbytes number Prompt 'What Byte Size you are looking for (Mbytes): '
select *
from v$sgastat
where bytes/1024/1024 > &lbytes
order by 3
/


Accept ldays number Prompt 'How many Days of Historical Information: '
Accept lpool_name char Prompt 'Enter the Pool Name : '

tti Left 'SGA Pool Information :' skip 2

select
     trunc(sn.begin_interval_time) date_time,
	 s.name                        name,
     s.pool                        pool,     
     min(bytes)					   min_bytes,
     max(bytes)					   max_bytes
from  dba_hist_sgastat s,
      dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >= trunc(sysdate-&ldays)
        and s.snap_id                   = sn.snap_id
        and s.dbid                      = sn.dbid
        and s.instance_number           = sn.instance_number
        and s.dbid                      = (select dbid from v$database)
        and s.instance_number           = (select instance_number from v$instance)
        and upper(s.name)	like upper('%&lpool_name%')
group by trunc(begin_interval_time),pool,name
order by 1
/

tti off
spool off
