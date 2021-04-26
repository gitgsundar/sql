-- 	File 		:	MON_CDB_DBFILES.SQL
--	Description	:	Monitor Database..
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off
col Instance							heading 'Environment Info' 		format a100
col con_name							heading	'Container Name'			format a15
col tablespace_name				heading 'Tablespace Name'			format a30
col alloted_bytes 				heading 'Alloted Bytes'				format 99,999,999,999,999
col free_bytes 						heading 'Free Bytes'					format 99,999,999,999,999
col file_name 						heading 'File Name' 					format a100
col file_id			  				heading 'File Id'							format 99999
col Bytes_available_4_shrink	heading 'Bytes Available to Shrink'	format 99,999,999,999,999
col bytes 								heading 'Bytes'								format 99,999,999,999,999
col blocks								heading 'Blocks'							format 99,999,999
col contents							heading 'Contents'						format a9
col autoextensible				heading 'Auto'								format a4
col increment_by					heading 'Inc(Blks)'						format 999,999,999
col extent_management			heading 'Ext Mgt'							format a10
col segment_space_management	heading 'Seg Mgt'					format a10
col status								heading 'Status'							format a10
col logging								heading 'Log Mode'						format a9

col spoolfile					heading 'Spool File Name'					format a150
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\mon_cdb_dbfiles_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile
tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Tablespace Information :' skip 2
break on con_name

select c.name con_name,tablespace_name,contents,logging,extent_management,segment_space_management,status 
from cdb_tablespaces t, v$containers c
where t.con_id = c.con_id
order by 1
/

tti off
tti Left 'Tablespace Sizing Information :' skip 2


select a.name con_name, a.tablespace_name, alloted_bytes/1048576 DBSpace_in_MB, nvl(free_bytes/1048576,0) DBFree_in_MB, 
          nvl(round((100*free_bytes)/alloted_bytes,2),0) Percent_free
from (select c.name, tablespace_name, sum(bytes) alloted_bytes from cdb_data_files f, v$containers c where f.con_id = c.con_id group by name, tablespace_name
                          union
      select c.name, tablespace_name, sum(bytes) alloted_bytes from cdb_temp_files tf, v$containers c where tf.con_id = c.con_id  group by name, tablespace_name) a,
		 (select c.name, tablespace_name, sum(bytes) free_bytes from cdb_free_space fs, v$containers c where fs.con_id = c.con_id 
  				and tablespace_name not in (select distinct tablespace_name from cdb_rollback_segs where tablespace_name not in ('SYSTEM')) 
  				group by name, tablespace_name
   			union
 			select c.name, tablespace_name, free_space free_bytes from cdb_temp_free_space tfs, v$containers c where tfs.con_id = c.con_id) b
where a.tablespace_name = b.tablespace_name (+)
  and a.name = b.name
order by 1,2
/

tti off
tti Left 'Tablespace - Datafiles Information :' skip 2
break on tablespace_name

select a.name con_name, a.tablespace_name,file_name,autoextensible, increment_by , status 
from (select c.name, tablespace_name, file_name,autoextensible,increment_by, status from cdb_data_files f, v$containers c where f.con_id = c.con_id
                          union
      select c.name, tablespace_name, file_name,autoextensible,increment_by, status from cdb_temp_files tf, v$containers c where tf.con_id = c.con_id) a
order by 1,2,3
/

clear break

Accept ltablespace char Prompt 'Enter Tablespace Name : '
variable b0 varchar2(50);
exec 	:b0 := upper('&ltablespace');

Accept lcontainer char Prompt 'Enter Container Name : '
variable b1 varchar2(50);
exec 	:b1 := upper('&lcontainer');

tti off
tti Left 'Datafile Sizing Information :' skip 2

select file_id,substr(file_name,1,100) file_name, bytes,blocks,status,autoextensible,increment_by
from cdb_data_files
where upper(tablespace_name)=:b0
 and  con_id in (select con_id from v$containers where name=:b1)
	union
select file_id,substr(file_name,1,100) file_name, bytes,blocks,status,autoextensible,increment_by
from cdb_temp_files
where upper(tablespace_name)=:b0
 and  con_id in (select con_id from v$containers where name=:b1)
/

tti off
tti Left 'Datafile Free Space Information :' skip 2

select fs.file_id,substr(file_name,1,100) file_name, sum(fs.bytes) Free_bytes
from cdb_free_space fs, cdb_data_files df
where upper(fs.tablespace_name)=:b0
	and   upper(df.tablespace_name)=:b0
	and   df.file_id=fs.file_id
	and fs.con_id in (select con_id from v$containers where name=:b1)
	and df.con_id in (select con_id from v$containers where name=:b1)
group by fs.file_id,substr(file_name,1,100)
order by fs.file_id
/

tti off
tti Left 'Datafile Shrink Free Space Information :' skip 2

select fs.file_id,substr(file_name,1,100) file_name, fs.bytes Bytes_available_4_shrink
from cdb_free_space fs, cdb_data_files df
where upper(fs.tablespace_name)=:b0
	and   upper(df.tablespace_name)=:b0
	and   df.file_id=fs.file_id
	and   fs.block_id in (select max(block_id) from cdb_free_space where file_id=fs.file_id and con_id in (select con_id from v$containers where name=:b1))
	and fs.con_id in (select con_id from v$containers where name=:b1)
	and df.con_id in (select con_id from v$containers where name=:b1)	
order by fs.file_id
/

tti off
clear breaks
spool off