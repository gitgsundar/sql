EXECUTE sys.DBMS_LOGMNR_D.BUILD(DICTIONARY_FILENAME => 'orcldict.ora',DICTIONARY_LOCATION => '/u01/app/oracle/admin/wmsprd01/utltmp');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.dbms_logmnr.NEW,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260434.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260435.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260436.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260437.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260438.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260439.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260440.log');
EXECUTE sys.DBMS_LOGMNR.ADD_LOGFILE(OPTIONS => sys.DBMS_LOGMNR.ADDFILE,LOGFILENAME => '/u01/app/oracle/admin/wmsprd01/arch/wmsprd01_1_260441.log');
EXECUTE sys.DBMS_LOGMNR.START_LOGMNR(DICTFILENAME => '/u01/app/oracle/admin/wmsprd01/utltmp/orcldict.ora',STARTTIME => to_date('18-SEP-2007:13:59:00', 'DD-MON-YY:HH24:MI:SS'),ENDTIME => to_date('18-SEP-2007:15:31:00', 'DD-MON-YY:HH24:MI:SS')); 
SELECT username,timestamp,sql_redo, sql_undo, seg_owner, seg_name, seg_type, seg_type_name, status,rollback ,session_info FROM v$logmnr_contents 
--where to_date(timestamp,'DD-MON-YYYY HH24:MI:SS') > to_date('18-SEP-2007 14:00:00','DD-MON-YYYY HH24:MI:SS')
/
--select * from v$logmnr_contents where seg_name='MTL_ITEM_SUB_INVENTORIES'
--/
select * from v$logmnr_contents
/

