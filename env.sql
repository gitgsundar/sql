column Prompt new_value Prompt
set termout off
select  user || ' @ ' || instance_name || ':' || 'SQL>'  Prompt
from  v$instance
/
set sqlprompt '&Prompt'
set termout on
set timing on define "~"
set serverout on size 1000000 format wrapped pages 9999 lines 200 trimspool on

