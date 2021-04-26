col Instance			heading  "Environment Info"	format a100
col Event				heading 	"Latch Event"			format a50
col wait_class			heading	"Wait Class"			format a20
col seconds_in_wait	heading	"Time Waited (sec)"	format 999999999
col sleeps				heading	"Sleeps"					format 999999999
col time_waited_micro heading	"Time Waited (msec)"	format 999999999999
col pct_db_time		heading	"% DB Time "			format 999999999


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

tti off

tti Left 'Latch Usage Information :' skip 1

SELECT EVENT, SUM(P3) SLEEPS, SUM(SECONDS_IN_WAIT) SECONDS_IN_WAIT
FROM V$SESSION_WAIT
WHERE EVENT LIKE 'latch%'
GROUP BY EVENT;

tti Left 'Latch Usage Based on DB Time Information :' skip 1

SELECT EVENT, WAIT_CLASS,TIME_WAITED_MICRO, ROUND(TIME_WAITED_MICRO*100/S.DBTIME,1) PCT_DB_TIME 
FROM V$SYSTEM_EVENT, (SELECT VALUE DBTIME FROM V$SYS_TIME_MODEL WHERE STAT_NAME = 'DB time') S
WHERE EVENT LIKE 'latch%'
ORDER BY PCT_DB_TIME ASC;

tti off

