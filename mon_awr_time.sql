clear columns
set pages 9999 lines 300 verify off
col snap_interval				heading	'Snap Interaval(Hour)'	format a30
col retention					heading	'Retention(Days)'		format a30
col topnsql						heading 'TopNSql(#)'			format 999,999,999,999,999
col most_recent_purge_time		heading	'Last Purge'			format a30
col date_time 					heading 'Date time' 			for a25
col stat_name 					heading 'Statistics Name' 		for a25
col time 						heading 'Time (s)' 				for 99,999,999,999

tti off
col spoolfile					heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_awr_time_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

prompt 'Enter the date in DD-Mon-YYYY Format and Stats you want to trend (DB time, DB CPU, sql execute elapsed time, PL/SQL execution elapsed time, parse time elapsed, background elapsed time)'

WITH systimemodel AS (
 select
    sn.begin_interval_time                              begin_interval_time,
    sn.end_interval_time                                end_interval_time,
    st.stat_name                                        stat_name,
    st.value                                            e_value,
    lag(st.value,1) over (order by st.snap_id)          b_value
    from DBA_HIST_SYS_TIME_MODEL st,
    dba_hist_snapshot sn
    where
       trunc(sn.begin_interval_time)  >= '&Date'
        and st.snap_id                = sn.snap_id
        and st.dbid                   = sn.dbid
        and st.instance_number        = sn.instance_number
        and st.dbid                   = (select dbid from v$database)
        and st.instance_number        = (select instance_number from v$instance)
		  and st.stat_name              like  '%&stat_name%'
)
select to_char(BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24_mi')|| to_char(END_INTERVAL_TIME,'_hh24_mi') date_time,
stat_name,
round((e_value-nvl(b_value,0))/1000000) time
from systimemodel
where   (e_value-nvl(b_value,0)) > 0
        and nvl(b_value,0) > 0
/

spool off