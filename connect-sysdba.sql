conn fwpdba/Id0nt_n0@"&dbname" as sysdba
column Prompt new_value Prompt
column Client_info	heading "Client Info" 	format a100

select  host_name||'-'|| user || ' @ ' || instance_name || ':' || 'SQL>'  Prompt
from  v$instance
/
set sqlprompt '&Prompt'

set termout on long 9999
set timing on 
set serverout on size 1000000 format wrapped pages 9999 lines 300 trimspool on
alter session set nls_date_format='dd-Mon-yyyy hh24:mi:ss';
select * From v$version;
set termout on
set tab off


SELECT
	'Sid -> '|| SYS_CONTEXT ('USERENV', 'SID')||'; Username -> '|| SYS_CONTEXT ('USERENV', 'OS_USER')||'; Client Machine -> ' || SYS_CONTEXT ('USERENV', 'HOST')||'; IP -> '||SYS_CONTEXT ('USERENV', 'IP_ADDRESS') Client_Info
from dual
/
