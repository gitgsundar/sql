conn sys/N0change@"&dbname" as sysdba
column Prompt new_value Prompt
column plan_plus_exp format a80
set termout off
select  host_name||'-'|| user || ' @ ' || instance_name || ':' || 'SQL>'  Prompt
from  sys.v$instance
/
set sqlprompt '&Prompt'
set termout on long 9999
set timing on 
set serverout on size 1000000 format wrapped pages 9999 lines 300 trimspool on
set termout on
set tab off