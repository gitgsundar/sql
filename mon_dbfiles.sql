-- 	File 		:	MON_DBFILES.SQL
--	Description	:	Monitor Database..
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance					heading 'Environment Info' 			format a100
col tablespace_name				heading 'Tablespace Name'			format a30
col alloted_bytes 				heading 'Alloted Bytes'				format 99,999,999,999,999
col free_bytes 					heading 'Free Bytes'				format 99,999,999,999,999
col file_name 					heading 'File Name' 				format a100
col file_id			  			heading 'File Id'					format 99999
col Bytes_available_4_shrink	heading 'Bytes Available to Shrink'	format 99,999,999,999,999
col bytes 						heading 'Bytes'						format 99,999,999,999,999
col blocks						heading 'Blocks'					format 99,999,999
col contents					heading 'Contents'					format a9
col autoextensible				heading 'Auto'						format a4
col increment_by				heading 'Inc(Blks)'					format 999,999,999
col extent_management			heading 'Ext Mgt'					format a10
col segment_space_management	heading 'Seg Mgt'					format a10
col status						heading 'Status'					format a10
col logging						heading 'Log Mode'					format a9

col spoolfile					heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_dbfiles_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile
tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Tablespace Information :' skip 2

select tablespace_name,contents,logging,extent_management,segment_space_management,status 
from dba_tablespaces
order by 1
/

tti off
tti Left 'Tablespace Sizing Information :' skip 2

select a.tablespace_name, alloted_bytes, nvl(free_bytes,0) free_bytes, nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select tablespace_name, sum(bytes) alloted_bytes from dba_data_files group by tablespace_name
                          union
      select tablespace_name, sum(bytes) alloted_bytes from dba_temp_files group by tablespace_name) a,
(select tablespace_name, sum(bytes) free_bytes from dba_free_space group by tablespace_name) b
where a.tablespace_name = b.tablespace_name (+)
order by 1
/

tti off
tti Left 'Tablespace - Datafiles Information :' skip 2
break on tablespace_name

select a.tablespace_name,file_name,autoextensible, increment_by , status 
from (select tablespace_name, file_name,autoextensible,increment_by, status from dba_data_files
                          union
      select tablespace_name, file_name,autoextensible,increment_by, status from dba_temp_files) a
order by 1
/

clear break

Accept ltablespace char Prompt 'Enter the Tablespace Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltablespace');

tti off
tti Left 'Datafile Sizing Information :' skip 2

select file_id,substr(file_name,1,100) file_name, bytes,blocks,status,autoextensible,increment_by
from dba_data_files
where upper(tablespace_name)=:b0
union
select file_id,substr(file_name,1,100) file_name, bytes,blocks,status,autoextensible,increment_by
from dba_temp_files
where upper(tablespace_name)=:b0
/

tti off
tti Left 'Datafile Free Space Information :' skip 2


select fs.file_id,substr(file_name,1,100) file_name, sum(fs.bytes) Free_bytes
from dba_free_space fs, dba_data_files df
where upper(fs.tablespace_name)=:b0
and   upper(df.tablespace_name)=:b0
and   df.file_id=fs.file_id
group by fs.file_id,substr(file_name,1,100)
order by fs.file_id
/

tti off
tti Left 'Datafile Shrink Free Space Information :' skip 2

select fs.file_id,substr(file_name,1,100) file_name, fs.bytes Bytes_available_4_shrink
from dba_free_space fs, dba_data_files df
where upper(fs.tablespace_name)=:b0
and   upper(df.tablespace_name)=:b0
and   df.file_id=fs.file_id
and   fs.block_id in (select max(block_id) from dba_free_space where file_id=fs.file_id)
-- group by fs.file_id,substr(file_name,1,100)
order by fs.file_id
/

tti off
spool off