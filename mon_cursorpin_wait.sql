set pages 9999 
set verify off
col Instance						heading 'Environment Info' 			format a100
col sid  				heading	'Sid'						format 999999
col serial#  			heading	'Serial#'				format 999999
col username 			heading	'Username'				format a15
col program  			heading	'Program'				format a30
col event    			heading	'Event'					format a50
col status				heading	'Status'		
col logon_time			heading	'Logon Time'		

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti Left 'Cursor: Pin S Wait on X :' skip 2

REM cursor: pin S wait on X.
REM A session waits on this event when requesting a mutex for sharable operations
REM related to pins (such as executing a cursor), but the mutex cannot be granted because
REM it is being held exclusively by another session (which is most likely parsing the cursor).
REM The column P2RAW in v$session gives the blocking session for wait event  cursor: pin S wait on X. 


SELECT p2raw,to_number(substr(to_char(rawtohex(p2raw)), 1, 8), 'XXXXXXXX') sid
FROM v$session
WHERE event = 'cursor: pin S wait on X'
/

select sid,serial#,username,program,status,logon_time,blocking_session,blocking_session_status,sql_id,action,event
from v$session 
where SID in (SELECT to_number(substr(to_char(rawtohex(p2raw)),1,8),'XXXXXXXX') 
					FROM v$session
					WHERE event = 'cursor: pin S wait on X')
/