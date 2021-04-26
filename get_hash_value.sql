set pages 9999 verify off
col sid      format 99999
col serial#  format 999999
col username format a15
col program  format a35
col event    format a50

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/

var lsid number;
begin
	:lsid := &1;
end;
/

-- Accept lsid number Prompt 'Enter the Session Id : '

select sid,serial#,username,logon_time,status,program from v$session 
where type='USER' and 
sid = :lsid
order by logon_time
/

select s.sid,s.serial#,s.status,s.logon_time, p.spid Shadow_process, s.process Client_process,s.username,s.program 
from v$session s, v$process p
where s.paddr = p.addr and
		s.sid   = :lsid;

select sql_text Sql,plan_hash_value,executions 
from v$sqlarea where address in 
	(select sql_address from v$session where sid=:lsid);

