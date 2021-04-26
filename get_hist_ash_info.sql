-- 	File 		:	GET_HIST_ASH_INFO.SQL
--	Description	:	Provides Historical Database ASH (Active Session History) Information
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col wait_class_id			heading 'Wait ID'
col wait_class				heading 'Wait Class Name'		for a30
col event_name				heading 'Event Name'			for a50
col user_name				heading 'Username'				for a15
col cnt						heading 'Count'					for 999999999999
col session_id				heading 'Sess Id'
col session_serial#			heading 'Serial#'
col blocking_session		heading 'Blocking Ses'
col time_waited				heading '
col module					heading 'Module'				for a50
col machine					heading 'Machine'				for a15
col sql_opname				heading 'Sql-Op'				for a15
col program					heading 'Program'				for a40
col sec						heading 'Wait(s)'
col sql_exec_start			heading 'Time of Exec'
col spoolfile				heading 'Spool File Name'		format a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_hist_ash_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lbdate date format 'mmddyyyy:hh24miss' Prompt 'Enter the Begin Date (MMDDYYYY:HH24MISS) for ASH Analysis Activity : '
Accept ledate date format 'mmddyyyy:hh24miss' Prompt 'Enter the End Date (MMDDYYYY:HH24MISS) for ASH Analysis Activity : '

tti Left 'Top Waits :' skip 2

select   d.wait_class_id                as Wait_Class_ID
        ,d.wait_class                   as Wait_Class
        ,count(*)                       as Cnt
from     dba_hist_active_sess_history   d,
		dba_hist_snapshot s
where   d.instance_number   = (select instance_number from v$instance)
	and d.dbid     		    = (select dbid from v$database)
	and	d.snap_id 			= s.snap_id
	and (s.begin_interval_time > to_date('&lbdate','MMDDYYYY:HH24MISS')  and 
		 s.begin_interval_time < to_date('&ledate','MMDDYYYY:HH24MISS'))
group by d.wait_class_id, d.wait_class
order by 3 desc
/

tti off
tti Left 'Events per WaitClass :' skip 2

select   d.wait_class_id                as Wait_Class_id
        ,d.wait_class                   as Wait_Class
        ,e.Name                         as Event_Name
        ,count(*)                       as Cnt
from     dba_hist_active_sess_history   d
        ,v$Event_Name                   e
        ,dba_hist_snapshot s
where   d.instance_number   = (select instance_number from v$instance)
	and d.dbid     		    = (select dbid from v$database)
	and	d.snap_id 			= s.snap_id
	and (s.begin_interval_time > to_date('&lbdate','MMDDYYYY:HH24MISS')  and 
		 s.begin_interval_time < to_date('&ledate','MMDDYYYY:HH24MISS'))
	and  d.Event_ID         = e.Event_ID
group by d.wait_class_id
        ,d.wait_class
        ,e.Name
order by 4 desc
/

tti off
tti Left 'User per Event :' skip 2

select   d.wait_class_id                as Wait_Class_ID
        ,d.wait_class                   as Wait_Class
        ,u.Username                     as User_Name
        ,e.Name                         as Event_Name
        ,count(*)                       as Cnt
from     dba_hist_active_sess_history   d
        ,v$Event_Name                   e
        ,all_users                      u
		,dba_hist_snapshot 				s
where   d.instance_number   = (select instance_number from v$instance)
	and d.dbid     		    = (select dbid from v$database)
	and	d.snap_id 			= s.snap_id
	and (s.begin_interval_time > to_date('&lbdate','MMDDYYYY:HH24MISS')  and 
		 s.begin_interval_time < to_date('&ledate','MMDDYYYY:HH24MISS'))
	and d.Event_ID         	= e.Event_ID
	and d.User_id          	= u.User_ID
	and u.Username         !=    'SYS'
	and e.Name not         like  'SQL*Net%'	
group by u.Username
        ,d.wait_class_id
        ,d.wait_class
        ,e.Name
order by 5 desc,4 
/


Accept lwait_id number Prompt 'Enter the Wait Class ID for ASH Analysis Activity Details: '

tti off
tti Left 'Session Details for Wait Class ID :' skip 2

select  session_id, session_serial#, blocking_session,sql_id,sql_exec_start, sql_opname,module, machine, program, count(*)*10 sec
from     dba_hist_active_sess_history   d
		  ,all_users                      u
		,dba_hist_snapshot 				s
where   d.instance_number   = (select instance_number from v$instance)
	and d.dbid     		    = (select dbid from v$database)
	and	d.snap_id 			= s.snap_id
	and (s.begin_interval_time > to_date('&lbdate','MMDDYYYY:HH24MISS')  and 
		 s.begin_interval_time < to_date('&ledate','MMDDYYYY:HH24MISS'))
	and d.wait_class_id    	= &lwait_id
	and d.User_id          	= u.User_ID
	and u.Username         !=    'SYS'
group by session_id, session_serial#, blocking_session,sql_id,sql_exec_start,sql_opname,module, machine, program
order by sec
/


spool off