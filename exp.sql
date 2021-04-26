set pages 9999 
set verify off
/****************************************
*	Run Explain Plan using the below
*    explain plan for "<Give the sql>"
*****************************************/

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

delete plan_table
/

select " Run explain plan for <SQL STATEMENT> " 
from dual
/

select * from table(dbms_xplan.display)
/



