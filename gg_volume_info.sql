set pages 9999 lines 200 verify off
col Instance		heading "Environment Info"	format a100
col sourcetime		heading "Date-Time"		
col mindate			heading "Min Historical Date"
col maxdate			heading "Max Historical Date"
col capture_date	heading "Captured Date"
col from_table		heading "Table_name"		format a45
col inserts			heading "Inserts"			format 999,999,999
col updates			heading "Updates"			format 999,999,999
col deletes			heading "Deletes"			format 999,999,999
col discards		heading "Discards"			format 999,999,999
col truncates		heading "Truncates"			format 999,999,999
col Total			heading "Txn Total"			format 999,999,999
col spoolfile		heading 'Spool File Name'	format a50

col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/gg_volume_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays  number Prompt 'Enter Historical days you want to look for?: '
Accept ltotal number Prompt 'What Total Transactions Volume you are lookging for?: '

tti off
tti Left 'Min/Max Volume Info :' skip 2

select min(capture_date) Mindate
from ggadmin.gg_volume_info
/
select max(capture_date) Maxdate
from ggadmin.gg_volume_info
/

tti off
tti Left 'Detailed Info :' skip 2

select capture_date capture_date,from_table,inserts,updates,deletes,discards,truncates,total 
from ggadmin.gg_volume_info 
where capture_date > trunc(sysdate)-&ldays
   and total > &ltotal
order by 2,1
/

tti off

spool off