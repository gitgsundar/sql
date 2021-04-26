-- 	File 		:	GET_INVALID_INFO.SQL
--	Description	:	Provides details of Invalid Objects in the DB
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance			heading "Environment Info"	format a100
col owner				heading "Username" 			format a20
col object_name			heading "Name"				format a30
col objecT_type 		heading "Type"				format a30
col	cnt					heading "Count"				format 9,999
col created				heading "Created Date"		
col last_ddl_time		heading "Last Touched Date"	
col spoolfile			heading 'Spool File Name'	format a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_invalid_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'INVALID Objects Summary :' skip 2
compute sum label 'Invalid Total' of cnt on report
break on report

select owner,count(*) cnt
from dba_objects
where owner not in ('SYS','SYSTEM','PUBLIC')
 and status='INVALID'
group by owner
order by 2
/

tti off
tti Left 'INVALID Object Detail Information :' skip 2

Accept lfeedback  char Prompt 'Want Full List of Objects? (Y/N): '
set feedback off

declare
begin
	if upper('&lfeedback')='Y' then
		dbms_output.put_line('');
	    dbms_output.put_line(rpad('Owner',15,' ')||rpad('Object Name',30,' ')||rpad('Object Type',20,' ')||rpad('Created Date',22,' ')||rpad('Last Touched Date',20,' '));
		dbms_output.put_line('------------------------------------------------------------------------------------------------------------');
		for i in (select rpad(Owner,15,' ')||rpad(object_name,30,' ')||rpad(object_type,20,' ')||rpad(created,22,' ')||rpad(last_ddl_time,20,' ') info from dba_objects where owner not in ('SYS','SYSTEM','PUBLIC') and status='INVALID' order by owner,object_type,object_name ) loop		    
			dbms_output.put_line(i.info);
	    end loop;
		dbms_output.put_line('');
	end if;
end;
/

set feedback on
tti off
clear breaks
spool off