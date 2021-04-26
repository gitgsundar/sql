col Instance			heading "Environment Info"		format a100
col sid      			heading	"Sid"					format 999999
col inst_id				heading "Instance"				
col serial#  			heading	"Serial#"				format 999999
col username 			heading	"Username"				format a15
col sql_id				heading "Sql ID"				format a15
col segtype				heading "Sort Type"				format a15
col extents				heading	"Extents"				format 999999999
col blocks				heading	"Blocks"				format 999999999
col osuser	 			heading	"OS User"				format a10
col tablespace			heading	"Tablespace"			format a40
col sql_text			heading	"Sql Text"				format a100			word wrap
col kbytes				heading	"KBytes"				format 99,999,999
col mbytes				heading	"MBytes"				format 99,999,999
col tablespace			heading	"Tablespace"			format a15
col current_users		heading	"Users#"				format 999
col total_extents		heading	"Total Extents"			format 9999999
col total_blocks		heading "Total Blocks"			format 9999999
col used_extents		heading "Used Extents"			format 9999999
col used_blocks			heading "Used Blocks"			format 9999999
col free_extents		heading	"Free Extents"			format 9999999
col free_blocks			heading	"Free Blocks"			format 9999999999
col max_sort_size		heading	"Max Sort Size"			format 9999999
col max_sort_blocks		heading	"Max Sort Blocks"		format 9999999999
col max_used_size		heading	"Max Used Size"			format 9999999
col max_used_blocks		heading	"Max Used Blocks"		format 9999999
col tablespace_name		heading "Tablespace"			format a20
col freed_extents 		heading "Freed Ext"				format 9999999


select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Temp Tablespace Information :' skip 1

select tablespace_name, sum(bytes)/1024/1024 mbytes
from dba_temp_files
group by tablespace_name
/

tti off
tti Left 'High Water Mark (MAX Used at one time) of Temp Tablespace :' skip 1

select inst_id, tablespace_name, sum(bytes_cached)/1024/1024 mbytes
from gv$temp_extent_pool
group by inst_id, tablespace_name
/

tti off
tti Left 'Sessions using Temp Information :' skip 1

SELECT a.username, a.sid, a.serial#, a.osuser, b.tablespace, (b.blocks*8192)/1048576 kbytes, c.sql_text,c.sql_id
FROM gv$session a, gv$sort_usage b, gv$sqlarea c
WHERE a.saddr = b.session_addr
	AND c.address= a.sql_address
	AND c.hash_value = a.sql_hash_value
ORDER BY b.tablespace, b.blocks
/

tti Left 'Temp Segment Usage Information :' skip 1

select username,sql_id,segtype,tablespace,extents,blocks
from gv$tempseg_usage
/

tti off

tti Left 'Current Sort Segment Information :' skip 1

select inst_id,tablespace_name,current_users,total_extents,total_blocks,used_extents,used_blocks,
		 free_extents, free_blocks, freed_extents,
		 max_sort_size, max_sort_blocks,max_used_size,max_used_blocks
from gv$sort_segment
/

tti off

