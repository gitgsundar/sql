-- 	File 		:	GET_ADDM_INFO.SQL
--	Description	:	Provides details of any Database ADDM (Automatic Database Diagnostic Monitor) Information
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading "Environment Info"		format a100
col sql_id					heading 'SQL Id'				for a13
col wait_class_id			heading 'Wait ID'
col wait_class				heading 'Wait Class Name'		for a30
col event_name				heading 'Event Name'			for a50
col user_name				heading 'Username'				for a15
col cnt						heading 'Count'					for 999999999999
col intervaldate			heading 'Date'					for a15
col minid					heading 'Begin SnapID'			
col maxid					heading 'End SnapID'

tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile				heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile

select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_addm_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept ldays number Prompt 'How long (days) you want ADDM Analysis Activity for : '

tti Left 'ADDM Repository Info :' skip 2
tti off

SELECT to_char(trunc(begin_interval_time),'DD-Mon-YYYY') intervaldate,MIN (snap_id) minid, MAX (snap_id) maxid
FROM dba_hist_snapshot
WHERE TRUNC (begin_interval_time) >= TRUNC (SYSDATE-&ldays)
group by to_char(trunc(begin_interval_time),'DD-Mon-YYYY')
order by 1
/

Accept lbsnap number Prompt 'Enter Begin Snap ID : '
Accept lesnap number Prompt 'Enter End Snap ID : '

tti Left 'ADDM Report :' skip 2
tti off
spool off

set termout off lines 32000
spool &spoolfile..html

declare
	ldbid		number;
	linst_id	number;
begin
	select dbid, inst_id into ldbid,linst_id from gv$database;
	for i in (SELECT output FROM TABLE (DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(ldbid,linst_id, &lbsnap, &lesnap, 8 ))) loop
		dbms_output.put_line(i.output);
	end loop;
end;
/
spool off

set termout on