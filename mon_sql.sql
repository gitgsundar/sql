col Instance	heading 'Environment Info'  format a100
col stmtid      heading 'Stmt Id'           format 9999999999
col dr          heading 'Physical IOs'      format 999,999,999
col bg          heading 'Logical IOs'       format 999,999,999
col sr          heading 'Sorts'             format 999,999
col exe         heading 'Executions'        format 999,999,999
col rp          heading 'Rows'              format 9,999,999,999
col rpr         heading 'LIOs|per Row'      format 999,999,999
col rpe         heading 'LIOs|per Run'      format 999,999,999
col Sql_text  	heading "Sql Statement" 	format a100
col cpu_time	heading "CPU(s)"			format 999999


set termout   on
set pagesize  30
set linesize  120
set pages 9999 
set verify off

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept num_rows prompt 'How many rows you need (10,20,30): ' 

set pause     on
set pause     'More: '

select  hash_value 				stmtid
       ,sum(disk_reads) 		dr
       ,sum(buffer_gets) 		bg
       ,sum(rows_processed) 	rp
       ,sum(buffer_gets)/greatest(sum(rows_processed),1) rpr
       ,sum(executions) 		exe
       ,sum(buffer_gets)/greatest(sum(executions),1) rpe
       ,sum(round(cpu_time/1000000,2)) cpu_time
 from v$sql
where command_type in ( 2,3,6,7 )
and rownum < &num_rows + 1
group by hash_value
order by 8 desc
/
set pause off

Accept stmt_ident prompt 'SQL Statement Hash Value from above: ' 

select sql_text
from v$sqltext
where hash_value = &stmt_ident
order by piece
/