clear columns
set pages 9999 verify off long 999999


col Instance	 heading 'Environment Info'   format a100
col granted_role heading 'View Name'          format a30
col owner	 heading 'Owner'	      format a15
col table_name	 heading 'View Definition'    format a100

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

Accept lviewname char Prompt 'Enter the Viewname : '
variable b0 varchar2(50);
exec 	:b0 := upper('&lviewname');

tti off
tti Left 'View Information :' skip 2

select view_name,owner,text from dba_views
where view_name = ltrim(rtrim(:b0)) 
order by 1
/

