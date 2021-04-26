set lines 350
rem Sessions waiting
rem for Event other than 'SQL*Net message from client', 'pipe get' and Background processes.
column sid format 99999
column state format a10 trunc
column username format a10
column osuser format a10
column action format a15
COLUMN module format a30
column wait_time heading 'Sec.|Wtd' format 99999
column wis heading 'Sec.|Wtng' format 999
column  SEQ# format 99999 
col event for a35
col  P1_P2_P3_TEXT for a40
set time on timing on

tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_ses_wait_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

ttitle	left _date -
        center 'XXXX ' -
        right 'Page: ' format 999 sql.pno skip1 -
        center 'Concurrent Manager Report for database :('_instx')' skip1 -
        center 'Jobs Currently waiting and event waiting for' skip2
spool waits
select w.sid, to_char(p.spid,'99999') PID, s.serial#,
       substr(w.event, 1, 28) event, substr(s.username,1,10) username,
       substr(s.osuser, 1,10) osuser,substr(s.ACTION ,1,10) action,a.module,
       w.state, w.SEQ#,
       w.wait_time, w.seconds_in_wait wis,
       substr(w.p1text||' '||to_char(w.P1)||'-'||
              w.p2text||' '||to_char(w.P2)||'-'||
              w.p3text||' '||to_char(w.P3), 1, 45) P1_P2_P3_TEXT,
s.sql_hash_value
from v$session_wait w, v$session s, v$process p,v$sqlarea a
where s.sid=w.sid
  and p.addr  = s.paddr
  and w.event not in ('SQL*Net message from client', 'pipe get')
  and s.username is not null
  and s.module = a.module 
  order by 4
/

spool off