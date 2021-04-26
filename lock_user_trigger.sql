-- sho parameter service
-- exec dbms_service.create_service('feoxggridprd01','feoxggridprd01');
-- exec dbms_service.start_service('feoxggridprd01');
-- sho parameter service

create or replace trigger deny_fwpdba_trg
after logon 
on database
begin
	for i in (select 'a253623' username from dual) loop
		if upper(i.username) != upper(sys_context('USERENV','OS_USER')) 
			and upper(sys_context('USERENV','SESSION_USER'))='FWPDBA' then
			raise_application_error( -20001, 'ACCESS DENIED' );
		end if;
	end loop;
exception
	when others then
		raise_application_error( -20001, 'ACCESS DENIED' );
end deny_fwpdba_trg;
/


This will not work as fwpdba is a dba/sysdba account.

DBA/SYSDBA has 'Administer Database Trigger' privilege