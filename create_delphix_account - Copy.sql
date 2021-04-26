create user c##delphix_db identified by "Jul#3thr";
grant create session to c##delphix_db;
alter user c##delphix_db set container_data=all container=current;
alter user c##delphix_db profile C##SRV_ACC_EXCPTN_PLT_PROFILE;
grant select any dictionary to c##delphix_db;
create or replace view v_x$kccfe as select * from x$kccfe;
grant select on v_x$kccfe to c##delphix_db;
create synonym c##delphix_db.x$kccfe for v_x$kccfe;


create user delphix_db identified by "Jul#3thr";
grant create session to delphix_db;
grant select any dictionary to delphix_db;
alter user delphix_db profile C##SRV_ACC_EXCPTN_PLT_PROFILE;
create or replace view v_x$kccfe as select * from x$kccfe;
grant select on v_x$kccfe to delphix_db;
create synonym delphix_db.x$kccfe for v_x$kccfe;


-----------------------

SQL> /

INSTANCE_NUMBER INSTANCE_NAME    HOST_NAME                                                        VERSION
--------------- ---------------- ---------------------------------------------------------------- -----------------
STARTUP_T STATUS       PAR    THREAD# ARCHIVE LOG_SWITCH_WAIT LOGINS     SHU DATABASE_STATUS   INSTANCE_ROLE
--------- ------------ --- ---------- ------- --------------- ---------- --- ----------------- ------------------
ACTIVE_ST BLO     CON_ID INSTANCE_MO EDITION
--------- --- ---------- ----------- -------
FAMILY
--------------------------------------------------------------------------------
              1 vbsailpp         va10px0107.wellpoint.com                                         12.1.0.2.0
03-DEC-17 OPEN         NO           1 STARTED                 ALLOWED    NO  ACTIVE            PRIMARY_INSTANCE
NORMAL    NO           0 REGULAR     EE



SQL> create user c##delphix_db identified by "<PASSWORD>";
grant create session to c##delphix_db;
alter user c##delphix_db set container_data=all container=current;
alter user c##delphix_db profile C##SRV_ACC_EXCPTN_PLT_PROFILE;
grant select any dictionary to c##delphix_db;
create or replace view v_x$kccfe as select * from x$kccfe;
grant select on v_x$kccfe to c##delphix_db;
create synonym c##delphix_db.x$kccfe for v_x$kccfe;
User created.

SQL>
Grant succeeded.

SQL>
User altered.

SQL>
User altered.

SQL>
Grant succeeded.

SQL>
View created.

SQL>
Grant succeeded.

SQL>

Synonym created.

SQL>


------------------------------
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 SAILPTP                        READ WRITE NO
SQL> alter session set container=sailptp;

Session altered.

SQL> create user delphix_db identified by "<PASSWORD>";
grant create session to delphix_db;
grant select any dictionary to delphix_db;
alter user delphix_db profile C##SRV_ACC_EXCPTN_PLT_PROFILE;
create or replace view v_x$kccfe as select * from x$kccfe;
grant select on v_x$kccfe to delphix_db;
create synonym delphix_db.x$kccfe for v_x$kccfe;
User created.

SQL>
Grant succeeded.

SQL>
Grant succeeded.

SQL>
User altered.

SQL>
View created.

SQL>
Grant succeeded.

SQL>

Synonym created.

SQL>
