-- conn antmsysdba/"Fam1ly#5"@"&dbname"
conn antmsysdba/"N0change!23"@"&dbname"
column Prompt new_value Prompt
column plan_plus_exp format a80
column Client_info	heading "Client Info" 	format a100
set termout off
select sys_context('userenv', 'server_host') ||'->' ||sys_context ('userenv', 'current_user') ||'@'|| sys_context ('userenv', 'cdb_name') || '-' ||sys_context ('userenv', 'con_name') Prompt
from dual
/
set sqlprompt '&Prompt:SQL>'
set termout on long 9999
set timing on trimspool on
set serverout on size 1000000 format wrapped pages 9999 lines 500 trimspool on
alter session set nls_date_format='dd-Mon-yyyy hh24:mi:ss';
select banner From v$version;
set termout on
set tab off

SELECT
	'Sid -> '|| SYS_CONTEXT ('USERENV', 'SID')||'; Username -> '|| SYS_CONTEXT ('USERENV', 'OS_USER')||'; Client Machine -> ' || SYS_CONTEXT ('USERENV', 'HOST')||'; IP -> '||SYS_CONTEXT ('USERENV', 'IP_ADDRESS') Client_Info
from dual
/


