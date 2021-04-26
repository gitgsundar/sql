set pages 9999 
set verify off
col Instance		heading 'Environment Info' 		format a100
col sid  			heading	'Sid'					format 999999
col serial#  		heading	'Serial#'				format 999999
col username 		heading	'Username'				format a15
col program  		heading	'Program'				format a30
col event    		heading	'Event'					format a50
col status			heading	'Status'		
col logon_time		heading	'Logon Time'		

col spoolfile		heading 'Spool File Name'		format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_libcache_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti Left 'Library Cache Pin Wait' skip 2

select sid, event, p1raw 
from v$session_wait 
where event = 'library cache pin'
/

select s.sid, kglpnmod "Mode", kglpnreq "Req"
from x$kglpn p, v$session s
where p.kglpnuse=s.saddr
and kglpnhdl in (select p1raw from v$session_wait where event ='library cache pin')
/

tti off
tti Left 'Library Cache Lock Information :' skip 2

SELECT s.sid, 
  waiter.p1raw w_p1r, 
  waiter.p2raw w_p2r, 
  holder.event h_wait, 
  holder.p1raw h_p1r, 
  holder.p2raw h_p2r, 
  count(s.sid) users_blocked, 
  sql.hash_value 
FROM  v$sql sql, v$session s,  x$kgllk l,  v$session_wait waiter,  v$session_wait holder 
WHERE  s.sql_hash_value = sql.hash_value and 
       l.KGLLKADR       = waiter.p2raw and 
       s.saddr          = l.kgllkuse and 
       waiter.event like 'library cache lock' and 
       holder.sid       = s.sid 
GROUP BY   s.sid, waiter.p1raw ,  waiter.p2raw ,  holder.event ,  holder.p1raw ,  holder.p2raw ,  sql.hash_value
/

tti off
tti Left 'Library Cache Pin Information :' skip 2

SELECT s.sid, 
  waiter.p1raw w_p1r, 
  holder.event h_wait, 
  holder.p1raw h_p1r, 
  holder.p2raw h_p2r, 
  holder.p3raw h_p2r, 
  count(s.sid) users_blocked, 
  sql.hash_value 
FROM   v$sql sql,   v$session s,   x$kglpn p,   v$session_wait waiter,   v$session_wait holder 
WHERE   s.sql_hash_value = sql.hash_value and 
        p.kglpnhdl       = waiter.p1raw and 
        s.saddr          = p.kglpnuse and 
        waiter.event like 'library cache pin' and 
        holder.sid       = s.sid 
GROUP BY   s.sid,   waiter.p1raw ,   holder.event ,   holder.p1raw ,   holder.p2raw ,   holder.p3raw ,   sql.hash_value
/

spool off