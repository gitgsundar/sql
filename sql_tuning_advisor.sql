/****************************************
*	Grants to fwpdba
*****************************************/

grant advisor to fwpdba;
grant select_catalog_role to  fwpdba;
grant execute on dbms_sqltune to fwpdba;

/****************************************
*	Create Tuning Task
*****************************************/

declare
  task_name varchar2(30);
begin
  task_name := dbms_sqltune.create_tuning_task(
                           sql_id	 	=> 'cfbz61yckkysc',
                           scope 		=> 'comprehensive',
                           time_limit 	=> 300,
                           task_name 	=> 'EMPI_sql_tuning_task',
                           description => 'Sql Tuning Task for EMPI Extract Query');
end;
/


/****************************************
*	Execute Tuning Task
*****************************************/

exec dbms_sqltune.execute_tuning_task (task_name => 'EMPI_sql_tuning_task');


/****************************************
*	Check Tuning Task
*****************************************/

select status,recommendation_count,error_message from dba_advisor_log where task_name='EMPI_sql_tuning_task';


/****************************************
*	View Recommendations of Tuning Task
*****************************************/
set long 65536
set longchunksize 65536
set linesize 300
select dbms_sqltune.report_tuning_task('EMPI_sql_tuning_task') from dual;


/****************************************
*	Drop Tuning Task
*****************************************/

exec dbms_sqltune.drop_tuning_task (task_name => 'EMPI_sql_tuning_task');

-------------------------------------------------------------------------------------------------------------------------

/****************************************
*	Check for all the plans in AWR
*****************************************/

- Run mon_awr_plan_change

- Once Plan found in AWR, you can load the same into the SMB using following.

-- Create SQLSET 

-- exec DBMS_SQLTUNE.CREATE_SQLSET('<SqlID_STS_AWR');

Eg : exec DBMS_SQLTUNE.CREATE_SQLSET('gw0vhktact87g_STS_AWR');


-- Load SQLSET with the proper Sql ID Information from the AWR Snaps

-- DECLARE
--	baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR; 
-- BEGIN
--	OPEN baseline_ref_cursor FOR 
--	select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(<bgnsnapid>, <endsnapid>, 
--	'sql_id='||CHR(39)||'<SQLID>'||CHR(39)||' and plan_hash_value=<plan_hash_value>',NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p; 
--	DBMS_SQLTUNE.LOAD_SQLSET('<Sqlid_STS_AWR>', baseline_ref_cursor); 
-- END;
-- /

Eg:

DECLARE
	baseline_ref_cursor DBMS_SQLTUNE.SQLSET_CURSOR; 
BEGIN
	OPEN baseline_ref_cursor FOR 
	select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(31645,31647, 
	'sql_id='||CHR(39)||'gw0vhktact87g'||CHR(39)||' and plan_hash_value=1224177062',NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p; 
	DBMS_SQLTUNE.LOAD_SQLSET('gw0vhktact87g_STS_AWR', baseline_ref_cursor); 
END;
/

-- Verify the sqlset

select * from dba_sqlset where name='gw0vhktact87g_STS_AWR';

-- Verify the statement in sqlset.

select * from dba_sqlset_statements where sqlset_name='gw0vhktact87g_STS_AWR';

-- Verify the sqlplan of the statement is sqlset.

SELECT * FROM table (DBMS_XPLAN.DISPLAY_SQLSET('gw0vhktact87g_STS_AWR','gw0vhktact87g'));

-- Verify Plan Baseline to check for no. of plans before

select count(*) from dba_sql_plan_baselines;

-- Load SMB using the package

-- DECLARE
-- my_integer pls_integer; 
-- BEGIN
-- 	my_integer := dbms_spm.load_plans_from_sqlset ( 
-- 	sqlset_name => '<SqlID>_STS_AWR', 
-- 	sqlset_owner => 'FWPDBA', 
-- 	basic_filter => 'sql_id = ''<SqlID>''',
-- 	fixed => 'NO', enabled => 'YES'); 
-- 	DBMS_OUTPUT.PUT_line(my_integer); 
-- END; 
-- /

Eg:

DECLARE
my_integer pls_integer; 
BEGIN
	my_integer := dbms_spm.load_plans_from_sqlset ( 
	sqlset_name => 'gw0vhktact87g_STS_AWR', 
	sqlset_owner => 'A253623', 
	basic_filter => 'sql_id = ''gw0vhktact87g''',
	fixed => 'NO', enabled => 'YES'); 
	DBMS_OUTPUT.PUT_line(my_integer); 
END; 
/

-- Verify Plan Baseline to check for no. of plans after

select count(*) from dba_sql_plan_baselines;

-- Get sql_handle, plan_name, etc for the plan

select sql_handle,plan_name,creator,fixed,accepted,enabled
From dba_sql_plan_baselines 
where creator='<FWPDBA>' 
	and trunc(created)=trunc(sysdate)
/

-- Fix the plan if there is a new better plan available.

var cnt varchar2(30);
exec :cnt:=dbms_spm.alter_sql_plan_baseline(sql_handle=>'<sql_handle>',plan_name=>'<plan_name>',attribute_name=>'FIXED',attribute_value=>'YES');
