set echo off
column operation   format a16
column options     format a15
column object_name format a20
column id          format 99
column query       heading "Query Plan" format a80

select lpad(' ',2*(level-1))||operation||' '||options||' '
       ||object_name||' '
       ||decode(object_node,'','','['||object_node||'] ')
       ||decode(optimizer,'','','['||optimizer||'] ')
       ||decode(id,0,'Cost = '||position) query
from   plan_table
start with id = 0
connect by prior id = parent_id;
set echo on