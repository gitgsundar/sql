set pages 9999 
set verify off
col bytes           	format 999999999999999
col object_name    		format a30
col object_type    		format a10
col segment_name    	format a30
col segment_type    	format a10
col owner           	format a15
col tablespace_name 	format a20
col file_name       	format a50
col bytes_Mb	   		format 9999999
col free_bytes      	format 9999999
col num_rows			format 9999999999

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept obj CHAR Prompt 'Enter the Object Name : '
select owner,object_name,object_type,temporary, created Created_Date
from dba_objects where object_name=upper('&obj')
order by 4
/

select owner,segment_name,segment_type,tablespace_name,bytes/1048576 bytes_Mb,b.num_rows,b.last_analyzed
from dba_segments a, (select num_rows, last_analyzed, sample_size from dba_tables where table_name=upper('&obj') ) b
where segment_name=upper('&obj')
union
select owner,segment_name,segment_type,tablespace_name,bytes/1048576 bytes_Mb,b.num_rows,b.last_analyzed
from dba_segments a, (select num_rows, last_analyzed, sample_size from dba_indexes where table_name=upper('&obj') ) b
where segment_name in (select index_name from dba_indexes where table_name=upper('&obj'))
/