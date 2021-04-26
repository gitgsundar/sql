-- 	File 		:	GET_AUDIT_INFO.SQL
--	Description	:	Provides details of Database Auditing.
--	Info			:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 300
set echo off
col Instance			heading "Environment Info"		for a100
col parameter_name	heading 'Parameter Name'		for a50
col parameter_value	heading 'Value'					for a30
col audit_trail		heading 'Audit Trail'			for a30
col segment_name		heading 'Table Name'				for a30
col tablespace_name	heading 'Tablespace Name'		for a30
col bytes				heading 'Size'						for 999,999,999,999
col job_status			heading 'Job|Status'				for a15
col job_name			heading 'Job Name'				for a30
col job_frequency		heading 'Frequency' 				for a30
col cleanup_time		heading 'Cleanup Time'			for a40
col delete_count		heading 'Count#'					for 9999999999
col last_archive_ts	heading 'Last Archive Time'
col rac_instance		heading 'Instance'				for 999
col param_name			heading 'Parameter Name'		for a30
col param_value		heading 'Parameter Value'		for a50
col user_name 			heading 'Username'				for a30
col audit_option    	heading 'Audited Statement'	for a50
col privilege    		heading 'Audited Privilege'	for a50
col spoolfile			heading 'Spool File Name'		for a100
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_audit_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Audit Parameters :' skip 2

select name param_name, value param_value
from v$parameter 
where name like '%audit%'
order by 1
/

tti off
tti Left 'AUD$ Table Info :' skip 2

select segment_name, tablespace_name, bytes 
from dba_segments 
where segment_name='AUD$'
/

tti off
tti Left 'Statements Audited :' skip 2

select Nvl(USER_NAME,'DB') user_name,AUDIT_OPTION 
from DBA_STMT_AUDIT_OPTS
order by 1,2
/

tti off
tti Left 'Privileges Audited :' skip 2

select Nvl(USER_NAME,'DB') user_name, Privilege
from DBA_PRIV_AUDIT_OPTS
order by 1,2
/

tti off
tti Left 'Audit Management Parameters :' skip 2

select *
from dba_audit_mgmt_config_params
/

tti off
tti Left 'Audit Happening with Trails in DB:' skip 2

select count(*) from sys.aud$
/

select count(*)
from dba_audit_trail
/

tti off
tti Left 'Audit Happening with Trails in XML:' skip 2

select count(*) 
from v$xml_audit_trail
/

tti off

tti Left 'Audit Management Cleanup Job :' skip 2

select * 
from dba_audit_mgmt_cleanup_jobs
/

tti off

---
--- Audit Job Setup
---

--	BEGIN
--		DBMS_AUDIT_MGMT.CREATE_PURGE_JOB(
--	  		audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
--	  		audit_trail_purge_interval => 64 /* hours */,  
--	  		audit_trail_purge_name => 'CLEANUP',
--	  		use_last_arch_timestamp => TRUE);
--	END;
--	/
---

---
--- Setup LAST_ARCHIVE_TIME
---

--	BEGIN
--		DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(
--		   audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
--		   last_archive_time => sysdate-15);
--	END;
--	/
---


---
--- Grid Job Setup (Takes care of RAC Instances)
---
--declare
--	lcount	number;
--begin
--	select count(*) into lcount from gv$instance;
--	
--	if lcount > 1 then
--		for i in (select inst_id from gv$instance order by 1) loop
--			DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
--				last_archive_time => sysdate-15,	rac_instance_number => i.inst_id);
--
--			DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
--				last_archive_time => sysdate-15, rac_instance_number => i.inst_id);
--		end loop;
--	else
--		DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,
--			last_archive_time => sysdate-15);
--
--		DBMS_AUDIT_MGMT.SET_LAST_ARCHIVE_TIMESTAMP(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,
--			last_archive_time => sysdate-15);
--	end if;	
--	DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_OS,use_last_arch_timestamp => TRUE);
--
--	DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_XML,use_last_arch_timestamp => TRUE);
--

--end;
--/


tti Left 'Audit Management Cleanup Job Run Information:' skip 2

select * 
from dba_audit_mgmt_clean_events
/

tti off

tti Left 'Audit Management Last Archive Time:' skip 2
select * 
from dba_audit_mgmt_last_arch_ts
/

spool off