set pages 9999 lines 300 verify off
col Parameter_name			heading 'Parameter Name'		for a35
col Parameter_value			heading 'Value'					for 99999
col Instance					heading 'Environment Info'		for a100
tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_spm_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

select parameter_name, parameter_value from dba_sql_management_config;

-- BEGIN
--  DBMS_SPM.CONFIGURE('space_budget_percent',30);
--END;
--/


--BEGIN
--  DBMS_SPM.CONFIGURE('plan_retention_weeks',105);
--END;
--/

spool off