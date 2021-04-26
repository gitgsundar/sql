set pages 9999 lines 200 verify off
col Instance		heading "Environment Info"		format a100
col sourcetime		heading "Date-Time"		
col mindate			heading "Min Historical Date"
col maxdate			heading "Max Historical Date"
col capgroup		heading "Capture"				format a8
col caplag			heading "Cap-Lag|Minutes"		format 999999999
col pmpgroup		heading "Pump"					format a8
col pmplag			heading "Pmp-Lag|Minutes"		format 999999999
col delgroup		heading "Replicat"				format a8
col dellag			heading "Rep-Lag|Minutes"		format 999999999
col totallag		heading "Tot-Lag|Minutes"		format 999999999
col spoolfile		heading 'Spool File Name'		format a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'gg_lag_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Instance Startup Time" from v$instance
/

Accept ldays number Prompt 'Enter Historical days you want to look for?: '
Accept llag  number Prompt 'What Lag value in Minutes you are looking for?: '

select min(sourcetime) Mindate
from ggadmin.gg_heartbeat
/

select max(sourcetime) Maxdate
from ggadmin.gg_heartbeat
/

tti off
tti Left 'Extract/Pump/Replicat Info :' skip 2
select distinct capgroup, pmpgroup, delgroup
from ggadmin.gg_heartbeat
order by 1
/

tti off
tti Left 'Historical Info :' skip 2

select sourcetime,capgroup,caplag,pmpgroup,pmplag,delgroup,dellag,totallag
from (
   select sourcetime,capgroup,caplag,pmpgroup,pmplag,delgroup,dellag,totallag,
           row_number() over (partition by delgroup order by totallag desc) as row_num
   from ggadmin.gg_heartbeat
   where sourcetime > trunc(sysdate)-&ldays and 
         totallag > &llag
   order by delgroup)
where row_num=1
order by sourcetime,delgroup;

tti off

spool off