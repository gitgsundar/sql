set pages 9999 lines 200 verify off
col owner				heading "Owner"   		format a15
col table_name			heading "Table Name"	format a30
col column_name			heading "Lob Column"	format a30
col segment_name		heading "Lob Segment"	format a20
col tablespace_name		heading "Tablespace"	format a20
col index_name			heading "Lob Index"		format a40
col chunk				heading "Chunk"			format 99999
col pctversion			heading "Versions"		format 99999

tti off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Lob Information :' skip 2
tti off

select owner,table_name,column_name,segment_name,tablespace_name,index_name,chunk,pctversion 
from dba_lobs 
where table_name like '%IMAGE%'
/

col image_size format 99999999999999

select sum(dbms_lob.getlength (z_im_image)) image_size from capadmin.s_image_image;  


set serveroutput on

declare
	TOTAL_BLOCKS 				number;
	TOTAL_BYTES 				number;
	UNUSED_BLOCKS 				number;
	UNUSED_BYTES 				number;
	LAST_USED_EXTENT_FILE_ID 	number;
	LAST_USED_EXTENT_BLOCK_ID 	number;
	LAST_USED_BLOCK 			number;

begin

dbms_space.unused_space('CAPADMIN','Z_IMAGE_LOB_SEG','LOB',
TOTAL_BLOCKS, TOTAL_BYTES, UNUSED_BLOCKS, UNUSED_BYTES,
LAST_USED_EXTENT_FILE_ID, LAST_USED_EXTENT_BLOCK_ID,
LAST_USED_BLOCK);

dbms_output.put_line('SEGMENT_NAME = Z_IMAGE_LOB_SEG');
dbms_output.put_line('-----------------------------------');
dbms_output.put_line('TOTAL_BLOCKS = '||TOTAL_BLOCKS);
dbms_output.put_line('TOTAL_BYTES = '||TOTAL_BYTES);
dbms_output.put_line('UNUSED_BLOCKS = '||UNUSED_BLOCKS);
dbms_output.put_line('UNUSED BYTES = '||UNUSED_BYTES);
dbms_output.put_line('LAST_USED_EXTENT_FILE_ID = '||LAST_USED_EXTENT_FILE_ID);
dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||LAST_USED_EXTENT_BLOCK_ID);
dbms_output.put_line('LAST_USED_BLOCK = '||LAST_USED_BLOCK);

end;
/ 
tti off
