set pages 9999 long 99999 verify off
col Instance				heading "Environment Info"	format a100
col date_time				heading "Date Time"			format a30
col parameter_name			heading "Parameter Name"	format a50
col b_value					heading "Begin Value"		format a50
col e_value					heading "End Value"			format a50
col spoolfile				heading 'Spool File Name'	format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'get_hist_parameter_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept ldays number Prompt 'How many Days of Historical Information: '
Accept lparameter_name char Prompt 'Enter Parameter Name: '

tti Left 'Parameter Information :' skip 2

prompt

WITH param_change AS (
select
        sn.begin_interval_time                                                  begin_interval_time,
        sn.end_interval_time                                                    end_interval_time,
        p.parameter_name                                                        parameter_name,
        p.value                                                                 e_value,
        lag(p.value, 1) over (partition by parameter_name order by p.snap_id)   b_value
from dba_hist_parameter p,
dba_hist_snapshot sn
where
        trunc(sn.begin_interval_time)  >=trunc(sysdate-&ldays)
        and p.snap_id                   = sn.snap_id
        and p.dbid                      = sn.dbid
        and p.instance_number           = sn.instance_number
        and p.dbid                      = (select dbid from v$database)
        and p.instance_number           = (select instance_number from v$instance)
		and p.parameter_name  like '%&lparameter_name%'
)
select
to_char(p.BEGIN_INTERVAL_TIME,'MM:DD:YYYY hh24:mi')||'--'|| to_char(p.END_INTERVAL_TIME,'hh24:mi') date_time,
p.parameter_name,
p.b_value,
p.e_value
from param_change p
where
        b_value <> e_value
        and parameter_name not like q'[\_\_%]' escape '\'
order by to_char(p.BEGIN_INTERVAL_TIME,'mm/dd/yy_hh24_mi')|| to_char(p.END_INTERVAL_TIME,'_hh24_mi')
/

tti off
spool off
