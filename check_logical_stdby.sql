-- 	File 		:	CHECK_LOGICAL_STDBY.SQL
--	Description	:	Provides details of the Oracle DataGuard Config. 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 	format a100
col	dest_id						heading 'Dest ID'			format 99999
col guard_status				heading 'Database Guard'	format a70
col owner						heading 'Owner'				format a30
col table_name					heading 'Table Name'		format a30
col database					heading 'DB Name'			format a10
col connect_identifier			heading 'Connect String'	format a50
col dataguard_role				heading 'DB Role'			format a20
col version						heading 'Version'			format a10
col enabled						heading 'Enabled'			format a7
col redo_source					heading 'Redo Source'		format a15
col parent_dbun					heading 'Parent'			format a10
col dest_role					heading 'Role'				format a20
col	con_id						heading 'Con ID'			format 99999
col facility					heading 'Process'			format a30
col severity					heading 'Severity'			format a13
col message						heading 'Message'			format a80
col timestamp					heading 'Time'				format a20
col current_scn					heading 'Current SCN#'		format 999,999,999,999,999,999
col applied_scn					heading 'Applied SCN#'		format 999,999,999,999,999,999
col protection_mode				heading	'Protection Mode'	format a20
col protection_level			heading	'Protection Level'	format a20
col Database_Role				heading	'DB Role'			format a20
col switchover_status			heading 'Switchover Stat'	format a20
col info						heading 'More Information'	format a100

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile					heading 'Spool File Name'	format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'check_logical_stdby_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Un-Supported Internal Schema by Logical Standby Info :' skip 2

select owner 
from dba_logstdby_skip
where statement_opt = 'INTERNAL SCHEMA' 
order by owner
/

tti off
tti Left 'Un-Supported Tables NOT beloging to Internal Schema by Logical Standby Info:' skip 2

select distinct owner, table_name 
from dba_logstdby_unsupported
order by owner, table_name
/

select owner, table_name 
from logstdby_unsupported_tables
/

tti off
tti Left 'Tables SQL-Apply may not be able to uniquely identify Info:' skip 2
select owner, table_name 
from dba_logstdby_not_unique
where (owner, table_name) not in (select distinct owner, table_name from dba_logstdby_unsupported) 
	and bad_column = 'Y'
/

tti off
tti Left 'Logical Guard Status Info :' skip 2

select decode(guard_status,'NONE','Users are free to Modify Any Object',
                           'STANDBY','Users cannot Modify Replicated Objects',
                           'ANY','No Restrictions. Users can Modify Any Object') guard_status
from v$database
/

tti off
tti Left 'More Info :' skip 2

select 'http://www.datadisk.co.uk/html_docs/oracle_dg/logical_setup.htm' Info
from dual
/

tti off
spool off