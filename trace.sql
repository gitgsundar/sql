CREATE OR REPLACE TRIGGER logon_trig_trace_EHUB_EMPI
AFTER LOGON ON DATABASE
DECLARE
	err_num 	NUMBER;
	err_msg 	VARCHAR2(200);
BEGIN
	for i in (SELECT sid,serial#  FROM v$session s
					WHERE s.audsid = userenv('SESSIONID')
						AND USERNAME in ('EHUB_EMPI')) loop
		sys.dbms_system.set_identifier('EHUB_EMPI_TRACE_');
		sys.dbms_system.set_sql_trace_in_session(i.sid,i.serial#,TRUE);
		sys.dbms_system.set_ev(i.sid,i.serial#,10046,12,'');
	end loop;			
EXCEPTION
	WHEN OTHERS THEN
		err_num := SQLCODE;
		err_msg := SUBSTR(SQLERRM, 1, 200);
		dbms_output.put_line(err_num ||': '||err_msg);
END;
/


CREATE OR REPLACE TRIGGER SYS.set_trace_spider_read
AFTER LOGON ON PLUGGABLE DATABASE
WHEN (USER like  'SPIDER_READ')
DECLARE
	lcommand varchar(200);
BEGIN
	EXECUTE IMMEDIATE 'ALTER SESSION SET tracefile_identifier = SPIDER_READ_TRACE_';
	EXECUTE IMMEDIATE 'alter session set statistics_level=ALL'; 
	EXECUTE IMMEDIATE 'alter session set max_dump_file_size=UNLIMITED';
	EXECUTE IMMEDIATE 'alter session set events ''10046 trace name context forever, level 12''';
END set_trace_spider_read;
/

CREATE OR REPLACE TRIGGER logon_trig_trace_SPIDER
AFTER LOGON ON PLUGGABLE DATABASE
BEGIN
	for i in (SELECT sid,serial#  FROM v$session s
					WHERE s.audsid = userenv('SESSIONID')
						AND USERNAME in ('EHUB_EMPI')) loop
		EXECUTE IMMEDIATE 'ALTER SESSION SET tracefile_identifier = SPIDER_TRACE_'
		sys.dbms_system.set_sql_trace_in_session(i.sid,i.serial#,TRUE);
		sys.dbms_system.set_ev(i.sid,i.serial#,10046,12,'');
	end loop;			
END logon_trig_trace_SPIDER;
/
