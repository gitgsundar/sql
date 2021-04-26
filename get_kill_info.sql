-- 	File 		:	GET_KILL_INFO.SQL
--	Description	:	Provides Sql for Killing session based on User.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col inst_id	 		format 99999			heading "Inst ID"
col sid      		format 99999			heading "Sid"
col serial#  		format 999999			heading "Serial#"
col username 		format a15       		heading "User"
col program  		format a30				heading "Program"
col event    		format a50				heading "Event"
col osuser	 		format a10				heading "OSUser"
col kill			format a50				heading "Kill Info"
col machine	 		format a25				heading "Machine"
col logon_time	 	format a21				heading "Logon Time"
col status	 		format a10				heading "Staus"
col program	 		format a30				heading "Program"

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  sys.v_$instance
/
set termout on

col spoolfile		heading 'Spool File Name'			format a150
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_kill_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lusername char Prompt 'Enter the Username : '

tti off
tti Left 'SQL Statement for Killing Session Info :' skip 2

select username, status, program, osuser, machine, logon_time,'alter system kill session '''||sid||','||serial#||''';' kill
from gv$session 
where username like upper(NVL('&lusername','%%')) 
/

tti off
spool off