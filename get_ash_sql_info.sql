-- 	File 		:	GET_ASH_SQL_INFO.SQL
--	Description	:	Provides Top SQL's from ASH for a SQLID.
--	Info		:	Update Spool information as required to get the spool output.


set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col sql_opname				heading 'SQL Operation'			for a30
col sample_time				heading 'Date-Time'
col time_waited				heading 'Time'					for 99999999999
col wait_class				heading 'Wait Class Name'		for a30
col event_name				heading 'Event Name'			for a50
col user_name				heading 'Username'				for a15
col cnt						heading 'Count'					for 999999999999

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_ash_sql_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lbdate date format 'mmddyyyy:hh24miss' Prompt 'Enter the Begin Date (MMDDYYYY:HH24MISS) for ASH Analysis Activity : '
Accept ledate date format 'mmddyyyy:hh24miss' Prompt 'Enter the End Date (MMDDYYYY:HH24MISS) for ASH Analysis Activity : '
Accept lsid number Prompt 'Enter SID for that period :'

tti Left 'Top SQL Waits :' skip 2
tti off

select  sql_id,sql_opname, sample_time,time_waited
from     dba_hist_active_sess_history   d,
		dba_hist_snapshot s
where   d.instance_number   = (select instance_number from v$instance)
	and d.dbid     		    = (select dbid from v$database)
	and	d.snap_id 			= s.snap_id
	and (s.begin_interval_time > to_date('&lbdate','MMDDYYYY:HH24MISS')  and 
		 s.begin_interval_time < to_date('&ledate','MMDDYYYY:HH24MISS'))
    and d.session_id        = &lsid
/

spool off