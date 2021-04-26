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

