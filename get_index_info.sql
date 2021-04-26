-- 	File 		:	GET_INDEX_INFO.SQL
--	Description	:	Provides Detail information of Index.
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 verify off lines 200 escape on 
set escape !
col Instance				heading 'Environment Info'		format a100
col table_name 				heading	'Table Name'			format a19
col index_name 				heading	'Index Name'			format a19
col index_type 				heading	'Index Type'			format a30
col uniqueness				heading 'U'						format a3
col blevel 					heading 'Lvl'					format 0   
col degree					heading 'Parallel'				format a10
col leaf_blocks 			heading 'Leaf|Blks'				format 999,999,999 
col num_rows 				heading 'Index-Row|Cnt'			format 999,999,999,999 
col distinct_keys 			heading 'Distinct|KEYS'			format 999,999,999,999 
col avg_leaf_blocks_per_key heading 'Leaf-Blks|/KEY'		format 999,999,999,999
col avg_data_blocks_per_key heading 'Data-Blks|/KEY'		format 999,999,999,999
col clustering_factor 		heading 'Clst|Fac'				format 999,999,999,999 
col Visibility				heading 'Visibility'			format a10
col Bytes					heading 'Bytes (M)'				format 999,999,999
col spoolfile				heading 'Spool File Name'		format a100

tti off


col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'get_index_info_'||to_char(sysdate,'yyyymmdd-hh24miss') spoolfile from dual
/
spool &spoolfile

tti off
select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

Accept lindex_name char Prompt 'Enter the Index Name : '

select index_name,owner,table_name,tablespace_name,
       decode( uniqueness, 'UNIQUE', 'U', null ) uniqueness,
       compression,
       blevel, leaf_blocks,
       num_rows,
       distinct_keys,
       degree,
       avg_leaf_blocks_per_key, avg_data_blocks_per_key,
       clustering_factor,
       buffer_pool,
       last_analyzed
from sys.dba_indexes
where index_name=upper('&lindex_name')
/


tti off
spool off