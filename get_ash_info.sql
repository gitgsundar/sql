-- 	File 		:	GET_ASH_INFO.SQL
--	Description	:	Provides details of Database ASH (Active Session History) Information
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
col module					heading 'Module'				for a50
col machine					heading 'Machine'				for a15
col sql_opname				heading 'Sql-Op'				for a15
col program					heading 'Program'				for a40
col sec						heading 'Wait(s)'
col sql_exec_start			heading 'Time of Exec'
col inst_id					heading 'Inst'					for 99999
col total_size				heading	'ASH-Size(Mb)'				format 999,999,999
col awr_flush_emergency_count	heading 'Flush Count'		format 999,999,999
col spoolfile				heading 'Spool File Name'		format a100

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_ash_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Ash Info :' skip 2
select
	inst_id
	,total_size
	,awr_flush_emergency_count
from gv$ash_info
/


tti off
tti Left 'Top Waits :' skip 2

select   d.wait_class_id                as Wait_Class_ID
        ,d.wait_class                   as Wait_Class
        ,count(*)                       as Cnt
from     v$active_session_history d
group by d.wait_class_id, d.wait_class
order by 3 desc
/

tti off
tti Left 'Events per WaitClass :' skip 2

select   d.wait_class_id                as Wait_Class_id
        ,d.wait_class                   as Wait_Class
        ,e.Name                         as Event_Name
        ,count(*)                       as Cnt
from     v$active_session_history   d
        ,v$Event_Name                   e
where   d.Event_ID         = e.Event_ID
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
from     v$active_session_history   	d
        ,v$Event_Name                   e
        ,all_users                      u
where   d.Event_ID         	= e.Event_ID
	and d.User_id          	= u.User_ID
	and u.Username         !=    'SYS'
	and e.Name not         like  'SQL*Net%'	
group by u.Username
        ,d.wait_class_id
        ,d.wait_class
        ,e.Name
order by 5 desc,4 
/

Accept lwait_id number Prompt 'Enter the Wait Class ID for ASH Analysis Activity Details > '
variable b0 number;
exec 	:b0 := &lwait_id;

tti off
tti Left 'Session Details for Wait Class ID :' skip 2

select  session_id, session_serial#, blocking_session,sql_id,sql_exec_start, sql_opname,module, machine, program, count(*)*10 sec
from     v$active_session_history   d
		  ,all_users                      u
where   d.wait_class_id    	= :b0
	and d.User_id          	= u.User_ID
	and u.Username         !=    'SYS'
	and blocking_session is not null
group by session_id, session_serial#, blocking_session,sql_id,sql_exec_start,sql_opname,module, machine, program
order by sec
/


tti off
tti Left 'AWR Command Information :' skip 2
select 'To Generate ASH Report Info - Run $OH/rdbms/admin/ashrpt.sql' Info
from dual
/
spool off