tti off
col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/gg_schemacheck_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

set null "NULL VALUE"
set feedback off
set heading off
set linesize 132 
set pagesize 9999
set echo off
set verify off

col table_name for a30
col column_name for a30
col data_type for a15
col object_type for a20
col constraint_type_desc for a30

ACCEPT schema_name char prompt 'Enter the Schema Name > '
variable b0 varchar2(50)
exec :b0 := upper('&schema_name');

SET Heading off
SELECT '------ System Info for: '||:b0 
FROM dual;
set heading on
select to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS') "DateTime: " from dual
/
select banner from v$version
/
SET Heading off
SELECT '------ Database Level Supplemental Log Check - 9i and 10g: ' 
FROM dual;
SET Heading on
SELECT SUPPLEMENTAL_LOG_DATA_MIN MIN, SUPPLEMENTAL_LOG_DATA_PK PK, SUPPLEMENTAL_LOG_DATA_UI UI 
  FROM V$DATABASE
/  

select name, log_mode "LogMode", 
supplemental_log_data_min "SupLog: Min", supplemental_log_data_pk "PK",
supplemental_log_data_ui "UI", force_logging "Forced",
supplemental_log_data_fk "FK", supplemental_log_data_all "All",
to_char(created, 'MM-DD-YYYY HH24:MI:SS') "Created"
from v$database
/

select  
platform_name
from v$database
/
set heading off
SELECT '------ Objects stored in Tablespaces with Compression are not supported in the current release of OGG ' 
FROM dual;
SET Heading on
select
	TABLESPACE_NAME,
	DEF_TAB_COMPRESSION
from DBA_TABLESPACES
where 
DEF_TAB_COMPRESSION <> 'DISABLED';

set heading off
SELECT '------ Distinct Object Types and their Count in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT object_type, count(*) total
FROM all_objects
WHERE OWNER = :b0
GROUP BY object_type
/


SET Heading off
SELECT '------ Distinct Column Data Types and their Count in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT data_type, count(*) total
FROM all_tab_columns
WHERE OWNER = :b0 
GROUP BY data_type
/


SET Heading off
SELECT '------ Tables With No Primary Key or Unique Index in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT distinct(table_name)
  FROM all_tables
 WHERE owner = :b0 
MINUS
(SELECT obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name = :b0 
   AND cdef.type# = 2 
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT idx.table_name
  FROM all_indexes idx
 WHERE idx.owner = :b0 
   AND idx.uniqueness = 'UNIQUE')
/

SET Heading off
SELECT '------ Tables with no PK or UI and rowsize > 1M in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT distinct(table_name)
  FROM all_tab_columns
 WHERE owner = :b0
 group by table_name
 HAVING sum(data_length) > 1000000
MINUS
(SELECT obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name = :b0 
   AND cdef.type# = 2 
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT idx.table_name
  FROM all_indexes idx
 WHERE idx.owner = :b0 
   AND idx.uniqueness = 'UNIQUE')
/

set heading off
SELECT '------ Tables with NOLOGGING setting ' FROM dual;
SELECT '------ This may cause problems with missing data down stream. Schema: ' ||:b0 FROM dual;
set heading on
select owner, table_name, ' ' "PARTITION_NAME", ' ' "PARTITIONING_TYPE", logging from DBA_TABLES
where logging <> 'YES' and OWNER = :b0
union
select owner, table_name, ' ', partitioning_type, DEF_LOGGING "LOGGING" from DBA_part_tables
where DEF_LOGGING != 'YES' and owner = :b0
union
select table_owner, table_name, PARTITION_NAME, ' ', logging from DBA_TAB_PARTITIONS
where logging <> 'YES' and table_owner = :b0
union
select table_owner, table_name, PARTITION_NAME, ' ', logging from DBA_TAB_SUBPARTITIONS
where logging <> 'YES' and table_owner <> :b0
;


set heading off
SELECT '------ Tables with Deferred constraints.Deferred constraints may cause TRANDATA to chose an incorrect Key ' FROM dual;
SELECT '------ Tables with Deferred constraints should be added using KEYCOLS in the trandata statement. Schema: ' ||:b0 FROM dual;
set heading on
SELECT c.TABLE_NAME,
  c.CONSTRAINT_NAME,
  c.CONSTRAINT_TYPE,
  c.DEFERRABLE,
  c.DEFERRED,
  c.VALIDATED,
  c.STATUS,
  i.INDEX_TYPE,
  c.INDEX_NAME,
  c.INDEX_OWNER
FROM dba_constraints c,
  dba_indexes i
WHERE
    i.TABLE_NAME   = c.TABLE_NAME
AND i.OWNER        = c.OWNER
AND c.owner = :b0
AND  c.DEFERRED = 'DEFERRED';

set heading off
SELECT '------ Tables Defined with Rowsize > 2M in the Schema: '||:b0
FROM dual;
SET Heading on
SELECT table_name, sum(data_length) row_length_over_2M
FROM all_tab_columns
WHERE OWNER = :b0 
GROUP BY table_name
HAVING sum(data_length) > 2000000
/

SET Heading off
SELECT '------ Tables that will Fail Add Trandata (Only an issue for Oracle versions below Oracle 10G) in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT distinct(table_name)
FROM dba_tab_columns
WHERE owner = :b0 
AND column_id > 32
AND table_name in
(SELECT distinct(table_name)
  FROM all_tables
 WHERE owner = :b0 
MINUS
(SELECT obj1.name
  FROM SYS.user$ user1,
       SYS.user$ user2,
       SYS.cdef$ cdef,
       SYS.con$ con1,
       SYS.con$ con2,
       SYS.obj$ obj1,
       SYS.obj$ obj2
 WHERE user1.name = :b0 
   AND cdef.type# = 2
   AND con2.owner# = user2.user#(+)
   AND cdef.robj# = obj2.obj#(+)
   AND cdef.rcon# = con2.con#(+)
   AND obj1.owner# = user1.user#
   AND cdef.con# = con1.con#
   AND cdef.obj# = obj1.obj#
UNION
SELECT idx.table_name
  FROM all_indexes idx
 WHERE idx.owner = :b0 
   AND idx.uniqueness = 'UNIQUE'))
/

SET Heading off
SELECT '------ Tables With CLOB, BLOB, LONG, NCLOB or LONG RAW Columns in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM all_tab_columns
WHERE OWNER = :b0 
AND data_type in ('CLOB', 'BLOB', 'LONG', 'LONG RAW', 'NCLOB')
/

SET Heading off
SELECT '------ Tables With Columns of UNSUPPORTED Datatypes in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM all_tab_columns
WHERE OWNER = :b0 
AND (data_type in ('ORDDICOM', 'BFILE', 'TIMEZONE_REGION', 'BINARY_INTEGER', 'PLS_INTEGER', 'UROWID', 'URITYPE', 'MLSLABEL', 'TIMEZONE_ABBR', 'ANYDATA', 'ANYDATASET', 'ANYTYPE')
or data_type like 'INTERVAL%')
/

SET Heading off
SELECT '----- Tables with Compressed data is not supported - in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, COMPRESSION
FROM all_all_tables
WHERE OWNER = :b0
AND (COMPRESSION = 'ENABLED');
 
SELECT TABLE_NAME, COMPRESSION
FROM ALL_TAB_PARTITIONS
WHERE TABLE_OWNER = :b0
AND (COMPRESSION = 'ENABLED');

SET Heading off
SELECT '----- Cluster (DML and DDL supported for 9i or later) or Object Tables (DML supported for 10G or later, no DDL) - in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, CLUSTER_NAME, TABLE_TYPE 
FROM all_all_tables
WHERE OWNER = :b0 
AND (cluster_name is NOT NULL or TABLE_TYPE is NOT NULL)
/

SET Heading off
SELECT '------ IOT (Fully support for Oracle 10GR2 (with or without overflows) using GGS 10.4 and higher) - in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, IOT_TYPE, TABLE_TYPE 
FROM all_all_tables
WHERE OWNER = :b0 
AND (IOT_TYPE is not null or TABLE_TYPE is NOT NULL)
/

SET Heading off
SELECT '------ Tables with Domain or Context Indexes - in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT TABLE_NAME, index_name, index_type 
FROM dba_indexes WHERE OWNER = :b0
and index_type = 'DOMAIN'
/

SET Heading off
SELECT '------ Types of Constraints on the Tables in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT DECODE(constraint_type,'P','PRIMARY KEY','U','UNIQUE', 'C', 'CHECK', 'R', 
'REFERENTIAL') constraint_type_desc, count(*) total
FROM all_constraints
WHERE OWNER = :b0 
GROUP BY constraint_type
/

SET Heading off
SELECT '------ Cascading Deletes on the Tables in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT table_name, constraint_name
FROM all_constraints
WHERE OWNER = :b0 and constraint_type = 'R' and delete_rule = 'CASCADE'
/

SET Heading off
SELECT '------ Tables Defined with Triggers in the Schema: '||:b0 
FROM dual;
SET Heading on
SELECT table_name, COUNT(*) trigger_count
FROM all_triggers
WHERE OWNER = :b0 
GROUP BY table_name
/
SET Heading off
SELECT '------ Performance issues - Reverse Key Indexes Defined in the Schema: '||:b0
FROM dual;
col Owner format a10
col TABLE_OWNER format a10
col INDEX_TYPE format a12
SET Heading on

select 
	OWNER,      
	INDEX_NAME,
	INDEX_TYPE, 
	TABLE_OWNER,
	TABLE_NAME, 
	TABLE_TYPE, 
	UNIQUENESS,
	CLUSTERING_FACTOR,
	NUM_ROWS,
	LAST_ANALYZED,
	BUFFER_POOL
from dba_indexes
where index_type = 'NORMAL/REV'
      And OWNER = :b0
/

SET Heading off
SELECT '------ Sequence numbers: '||:b0
FROM dual;

COLUMN SEQUENCE_OWNER FORMAT a15
COLUMN SEQUENCE_NAME FORMAT a30
COLUMN INCR FORMAT 999
COLUMN CYCLE FORMAT A5
COLUMN ORDER FORMAT A5
SET Heading on
SELECT SEQUENCE_OWNER,
 	 SEQUENCE_NAME,
 	 MIN_VALUE,
 	 MAX_VALUE,
 	 INCREMENT_BY INCR,
 	 CYCLE_FLAG CYCLE,
 	 ORDER_FLAG "ORDER",
 	 CACHE_SIZE,
 	 LAST_NUMBER
  FROM DBA_SEQUENCES
 WHERE SEQUENCE_OWNER=UPPER(:b0)
 /
set linesize 132

col "Avg Log Size" format 999,999,999
select sum (BLOCKS) * max(BLOCK_SIZE)/ count(*)"Avg Log Size" From gV$ARCHIVED_LOG;

Prompt Table: Frequency of Log Switches by hour and day
SELECT SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),1,5) DAY, 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'00',1,0)),'99') "00", 
	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'01',1,0)),'99') "01", 
 	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'02',1,0)),'99') "02", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'03',1,0)),'99') "03", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'04',1,0)),'99') "04", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'05',1,0)),'99') "05", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'06',1,0)),'99') "06", 
  	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'07',1,0)),'99') "07", 
	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'08',1,0)),'99') "08", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'09',1,0)),'99') "09", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'10',1,0)),'99') "10", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'11',1,0)),'99') "11", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'12',1,0)),'99') "12", 
  	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'13',1,0)),'99') "13", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'14',1,0)),'99') "14", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'15',1,0)),'99') "15", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'16',1,0)),'99') "16", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'17',1,0)),'99') "17", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'18',1,0)),'99') "18", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'19',1,0)),'99') "19", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'20',1,0)),'99') "20", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'21',1,0)),'99') "21", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'22',1,0)),'99') "22", 
   	 TO_CHAR(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),10,2),'23',1,0)),'99') "23" 
FROM 	 V$LOG_HISTORY 
GROUP  BY SUBSTR(TO_CHAR(FIRST_TIME, 'MM-DD-YY HH24:MI:SS'),1,5) 
order by 1;
SET Heading off
SELECT '------ Summary of log volume processed by day for last 7 days: '
FROM dual;
SET Heading on
select to_char(first_time, 'mm/dd') ArchiveDate,
       sum(BLOCKS*BLOCK_SIZE/1024/1024) LOGMB
from v$archived_log
where first_time > sysdate - 7
group by to_char(first_time, 'mm/dd')
order by to_char(first_time, 'mm/dd');
/
SET Heading off
SELECT '------ Summary of log volume processed per hour for last 7 days: ' 
FROM dual;
SET Heading on
select to_char(first_time, 'MM-DD-YYYY') ArchiveDate, 
       to_char(first_time, 'HH24') ArchiveHour,
       sum(BLOCKS*BLOCK_SIZE/1024/1024) LogMB
from v$archived_log
where first_time > sysdate - 7
group by to_char(first_time, 'MM-DD-YYYY'), to_char(first_time, 'HH24')
order by to_char(first_time, 'MM-DD-YYYY'), to_char(first_time, 'HH24');
/     

set heading off

spool off
undefine b0
-- exit

