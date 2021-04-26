-- 	File 		:	GET_ACL_INFO.SQL
--	Description	:	Provides details of any Database ACL's (Access Control List)
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance		heading "Environment Info"		for a100
col host			heading 'Host'					for a30
col acl				heading 'ACL Definition'		for a50
col any_path		heading 'ACL Definition'		for a50
col principal		heading 'Grantee'				for a20
col start_date		heading 'Start Date'			for a20
col end_date		heading 'End Date'				for a20
col is_grant		heading 'Grant'					for a10
col spoolfile		heading 'Spool File Name'		for a50
col resid			heading 'Resoure ID'		
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile		heading 'Spool File Name'		format a100
col spoolfile 		new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_acl_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'ACL Info :' skip 2

SELECT host, acl, lower_port lport, upper_port uport
FROM DBA_NETWORK_ACLS 
/

tti off
tti Left 'Statements Audited :' skip 2

SELECT acl,principal, decode(u.type#,0,'*',1,' ') "R",privilege,is_grant
FROM dba_network_acl_privileges p, sys.user$ u
where u.name=p.principal
/

tti off
tti Left 'Resource View for ACL :' skip 2

SELECT *
FROM xdb.resource_view 
where any_path in (select acl from dba_network_acls)
/
spool off