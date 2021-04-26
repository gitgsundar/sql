ORA-24247 Trying To Send Email Using UTL_SMTP from 11gR1 (11.1.0.6) or higher [ID 557070.1]

connect / as sysdba

set serveroutput on

show user;
	lprincipal varchar2,
	lisgrant   boolean,
	lacl       varchar2		default 'manage_acl_prc.XML',
	lcomment   varchar2		default 'ACL used for eMail Server to CONNECT',
	lprivilege varchar2		default 'CONNECT',
	lserver    varchar2		default 'MAIL.FMR.COM',
	lport      number			default 25)


	lacl       varchar2,
	lcomment   varchar2,
	lprivilege varchar2,
	lserver    varchar2,
	lport      number)


create or replace procedure manage_acl_prc(
	lprincipal varchar2,
	lisgrant   boolean,
	lacl       varchar2		default 'manage_acl_prc.xml',
	lcomment   varchar2		default 'ACL used for eMail Server to CONNECT',
	lprivilege varchar2		default 'connect',
	lserver    varchar2		default 'mailhost.fmr.com',
	lport      number			default 25)
is
begin  
  begin
    DBMS_NETWORK_ACL_ADMIN.DROP_ACL(lacl);
     dbms_output.put_line('ACL dropped.....'); 
  exception
    when others then
      dbms_output.put_line('Error dropping ACL: '||lacl);
      dbms_output.put_line(sqlerrm);
  end;
  begin
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(lacl,lcomment,lprincipal,lisgrant,lprivilege);
    dbms_output.put_line('ACL created.....'); 
  exception
    when others then
      dbms_output.put_line('Error creating ACL: '||lacl);
      dbms_output.put_line(sqlerrm);
  end;  
  begin
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(lacl,lserver,lport);
    dbms_output.put_line('ACL assigned.....');         
  exception
    when others then
      dbms_output.put_line('Error assigning ACL: '||lacl);
      dbms_output.put_line(sqlerrm);
  end;   
  commit;
  dbms_output.put_line('ACL commited.....'); 
end manage_acl_prc;
/
show errors


exec dbms_network_acl_admin.ADD_PRIVILEGE('manage_acl_prc.xml','REPADMIN',TRUE,'connect');




create or replace procedure manage_acl_prc(
	lprincipal varchar2,
	lisgrant   boolean,
	lacl       varchar2		default 'manage_acl_prc.xml',
	lcomment   varchar2		default 'ACL used for eMail Server to CONNECT',
	lprivilege varchar2		default 'connect',
	lserver    varchar2		default 'mail.fmr.com',
	lport      number			default 25)
is
	lcount		number;
begin  
	select count(*) into lcount from dba_network_acls where instr(acl,'manage_acl_prc.xml') > 0;
	if lcount > 0 then
		dbms_network_acl_admin.ADD_PRIVILEGE(lacl,lprincipal,lisgrant,'connect');	
		dbms_output.put_line('Existing ACL has new privilege assigned.....'); 
	else
		begin
			DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(lacl,lcomment,lprincipal,lisgrant,lprivilege);
			dbms_output.put_line('ACL created.....'); 
		exception
			when others then
			dbms_output.put_line('Error creating ACL: '||lacl);
			dbms_output.put_line(sqlerrm);
		end;  
		begin
			DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(lacl,lserver,lport);
			dbms_output.put_line('ACL assigned.....');         
		exception
			when others then
			dbms_output.put_line('Error assigning ACL: '||lacl);
			dbms_output.put_line(sqlerrm);
		end;   
	end if;
	commit;
	dbms_output.put_line('ACL commited.....'); 
end manage_acl_prc;
/



BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL (
               acl         => 'manage_acl_prc.xml' );
  COMMIT;
END;
/