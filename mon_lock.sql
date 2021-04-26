set pages 9999 
set verify off
col Instance			heading 'Environment Info' 		format a100
col sid  				heading	'Sid'					format 999999
col serial#  			heading	'Serial#'				format 999999
col username 			heading	'Username'				format a15
col program  			heading	'Program'				format a30
col event    			heading	'Event'					format a50
col status				heading	'Status'		
col logon_time			heading	'Logon Time'		
col lmode 				heading 'Lock Mode'				format a15
col request 			heading	'Request'				format a15
col tab 				heading	'Table'					format a40 
col terminal 			heading	'Terminal'				format a10 
col Kill 				heading	'Sid-Ser#'				format a10 

col spoolfile			heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_lock_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select  nvl(S.USERNAME,'Internal') username,
        nvl(S.TERMINAL,'None') terminal,
        L.SID||','||S.SERIAL# Kill,
        U1.NAME||'.'||substr(T1.NAME,1,20) tab,
        decode(L.LMODE,1,'No Lock',
                2,'Row Share',
                3,'Row Exclusive',
                4,'Share',
                5,'Share Row Exclusive',
                6,'Exclusive',null) lmode,
        decode(L.REQUEST,1,'No Lock',
                2,'Row Share',
                3,'Row Exclusive',
                4,'Share',
                5,'Share Row Exclusive',
                6,'Exclusive',null) request
from    V$LOCK L,
        V$SESSION S,
        SYS.USER$ U1,
        SYS.OBJ$ T1
where   L.SID = S.SID
	and     T1.OBJ# = decode(L.ID2,0,L.ID1,L.ID2)
	and     U1.USER# = T1.OWNER#
	and     S.TYPE != 'BACKGROUND'
order by 1,2,5
/

spool off
