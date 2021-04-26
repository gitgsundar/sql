-- sho parameter service
-- exec dbms_service.create_service('feoxggridprd01','feoxggridprd01');
-- exec dbms_service.start_service('feoxggridprd01');
-- sho parameter service
======================================================================================================================
-- Updated the Trigger to Start Services only on Role change.
create or replace trigger manage_service_trg
after startup on database
declare
	v_db_role 	v$database.database_role%type;
begin
	select database_role into v_db_role from v$database;
	for i in (select name from dba_services where upper(name) like upper('eps%prd01')) loop
		if upper(v_db_role) = upper('primary') then
			dbms_service.start_service(i.name,null);
		else
			dbms_service.stop_service(i.name,null);
		end if;
	end loop;
exception
	when others then
		raise;
end manage_service_trg;
/
======================================================================================================================
create or replace trigger manage_service_trg
after startup on database
declare
	v_db_role 	v$database.database_role%type;
	v_host_name v$instance.host_name%type;
begin
	select database_role into v_db_role from v$database;
	select host_name into v_host_name from v$instance;
	for i in (select name from dba_services where upper(name) like upper('feo%prd01')) loop
		if upper(v_db_role) = upper('primary') then
			dbms_service.start_service(i.name,null);
		else
			dbms_service.stop_service(i.name,null);
		end if;
	end loop;
	for i in (select name from dba_services where upper(name) like upper('feo%pcov01')) loop
		if upper(v_db_role) = upper('primary') and upper(v_host_name) like upper('%cov%') then
			dbms_service.start_service(i.name,null);
		else
			dbms_service.stop_service(i.name,null);
		end if;
	end loop;
	for i in (select name from dba_services where upper(name) like upper('feo%pwlk01')) loop
		if upper(v_db_role) = upper('primary') and upper(v_host_name) like upper('%wlk%') then
			dbms_service.start_service(i.name,null);
		else
			dbms_service.stop_service(i.name,null);
		end if;
	end loop;
exception
	when others then
		raise;
end manage_service_trg;
/
======================================================================================================================

-- Database Trigger for Starting Services in Non-Prod

create or replace trigger manage_service_trg
after startup on database
begin
	for i in (select name from dba_services where upper(name) like upper('eps%')) loop
		dbms_service.start_service(i.name,null);
	end loop;
exception
	when others then
		raise;
end manage_service_trg;
/
