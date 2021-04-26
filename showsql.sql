set pages 9999 verify off lines 300
set echo off
col Instance		heading "Environment Info"		for a100
col host			heading 'Host'					for a30
col username		heading 'Username'				for a30
col sid				heading 'Sid'					for 9999999
col serial#			heading 'Serial#'				for 9999999
col sql_text 		heading 'Sql Text'				for a90 word_wrapped
col module 			heading 'Module'				for a50 word_wrapped
col action 			heading 'Action'				for a30 word_wrapped
col client_info 	heading 'Client Info'			for a30 word_wrapped
col spoolfile		heading 'Spool File Name'		format a50
tti off

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile		heading 'Spool File Name'		format a100
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'showsql_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/


tti off
tti Left 'User Session Info :' skip 2

select username||' -> ('||sid||','||serial#||') ' username,
       module,
       action,
       client_info
from v$session
where module||action||client_info is not null
and type ='USER'
/

tti off
tti Left 'Active User Session Details Info:' skip 2

declare
    x number;
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,'DD-Mon-YYYY HH24:MI:SS') logon_time,
             to_char(sysdate,'DD-Mon-YYYY HH24:MI:SS') current_time,
             sql_address, LAST_CALL_ET
        from v$session
       where status = 'ACTIVE'
         and rawtohex(sql_address) <> '00'
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 4)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '-----------------------------------------' );
                dbms_output.put_line( 'Username   : '|| x.username );
                dbms_output.put_line( 'Login Info : '|| x.logon_time || ' ' || x.current_time||' Last ET = ' || x.LAST_CALL_ET);
                dbms_output.put_line( 'Sql Stmt   : '|| substr(y.sql_text, 1, 250));
                dbms_output.put_line('');
            end if;
        end loop;
    end loop;
end;
/

tti off

spool off