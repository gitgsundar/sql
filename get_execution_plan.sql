set pagesize 600
set tab off 
set linesize 140
set echo off
set long 4000
col TQID format A4
col "SLAVE SQL" format A95 WORD_WRAP
col address format A12
col sql_hash format A15
col exec format 9999
col sql_text format A75 WORD_WRAP
repfooter off;
set timing off veri off space 1 flush on pause off termout on numwidth 10;

alter session set "_complex_view_merging"=false;

select hash_value||decode(child_number, 0, '', '/'||child_number) sql_hash, 
          sql_text
from v$sql
where child_number= 0 and hash_value= &hashvalue;

select '| Operation | Name | Starts | E-Rows | A-Rows | Buffers | Reads | Writes | E-Time |' as "Plan Table" from dual
union all /* QWEKLOIPYRTJHH7 */ 
select '------------------------------------------------------------------------------------------------------------------------'
from dual 
union all 
select rpad('| '||substr(lpad(' ',1*(depth))||operation|| decode(options, null,'',' '||options), 1, 33), 34, ' ')||'|'|| 
          rpad(substr(object_name||' ',1, 19), 20, ' ')||'|'|| 
          lpad(decode(starts,null,' ', 
                         decode(sign(starts-1000), -1, starts||' ', 
                         decode(sign(starts-1000000), -1, round(starts/1000)||'K',
                         decode(sign(starts-1000000000), -1, round(starts/1000000)||'M', 
                                           round(starts/1000000000)||'G')))), 8, ' ') || '|' ||
          lpad(decode(cardinality,null,' ',
                         decode(sign(cardinality-1000), -1, cardinality||' ',
                         decode(sign(cardinality-1000000), -1, round(cardinality/1000)||'K',
                         decode(sign(cardinality-1000000000), -1, round(cardinality/1000000)||'M', 
                                            round(cardinality/1000000000)||'G')))), 8, ' ') || '|' ||
          lpad(decode(outrows,null,' ', 
                         decode(sign(outrows-1000), -1, outrows||' ',
                         decode(sign(outrows-1000000), -1, round(outrows/1000)||'K',
                         decode(sign(outrows-1000000000), -1, round(outrows/1000000)||'M', 
                                            round(outrows/1000000000)||'G')))), 8, ' ') || '|' || 
          lpad(decode(crgets,null,' ', 
                         decode(sign(crgets-10000000), -1, crgets||' ', 
                         decode(sign(crgets-1000000000), -1, round(crgets/1000000)||'M',
                                            round(crgets/1000000000)||'G'))), 9, ' ') || '|' || 
          lpad(decode(reads,null,' ', 
                         decode(sign(reads-10000000), -1, reads||' ',
                         decode(sign(reads-1000000000), -1, round(reads/1000000)||'M',
                                            round(reads/1000000000)||'G'))), 8, ' ') || '|' || 
          lpad(decode(writes,null,' ', 
                         decode(sign(writes-10000000), -1, writes||' ', 
                         decode(sign(writes-1000000000), -1, round(writes/1000000)||'M', 
                                            round(writes/1000000000)||'G'))), 8, ' ') || '|' || 
          lpad(decode(etime,null,' ', 
                         decode(sign(etime-10000000), -1, etime||' ', 
                         decode(sign(etime-1000000000), -1, round(etime/1000000)||'M', 
                                            round(etime/1000000000)||'G'))), 8, ' ') || '|' as "Explain plan" 
from 
       (select /*+ no_merge */ 
                  p.HASH_VALUE, p.ID, p.DEPTH, p.POSITION, p.OPERATION, 
                  p.OPTIONS, p.COST COST, p.CARDINALITY CARDINALITY, 
                  p.BYTES BYTES, p.OBJECT_NODE, p.OBJECT_OWNER, 
                  p.OBJECT_NAME, p.OTHER_TAG, p.PARTITION_START,
                  p.PARTITION_STOP, p.DISTRIBUTION, pa.starts, 
                  pa.OUTPUT_ROWS outrows, pa.CR_BUFFER_GETS crgets, 
                  pa.DISK_READS reads, pa.DISK_WRITES writes, 
                  pa.ELAPSED_TIME etime 
        from v$sql_plan_statistics_all pa, 
               V$sql_plan p 
        where p.hash_value = &hashvalue 
           and p.CHILD_NUMBER= 0 
           and p.hash_value = pa.hash_value(+)
           and pa.child_number(+) = 0 ) 
union all 
        select '------------------------------------------------------------------------------------------------------------------------' from dual; 
REM 
REM Print slave sql 
REM 
select /* QWEKLOIPYRTJHH7 */ 
           decode(object_node,null,'', substr(object_node,length(object_node)-3,1) || ',' || 
           substr(object_node,length(object_node)-1,2)) TQID, 
           other "SLAVE SQL" 
from v$sql_plan vp 
where other is not NULL 
    and hash_value = &hash_value 
    and CHILD_NUMBER= 0;