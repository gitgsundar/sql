-- Create Flexera AWS User
CREATE USER FNMOAUDIT
  IDENTIFIED BY fnmoauditpswd#1
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  PROFILE SRV_ACC_EXCPTN_PLT_PROFILE
  ACCOUNT UNLOCK;

-- Create Flexera AWS User Role 
CREATE ROLE "FNMOAUDIT_ROLE";

-- Grant Roles to Flexera 
  GRANT FNMOAUDIT_ROLE TO FNMOAUDIT; 
  GRANT CONNECT TO FNMOAUDIT;

-- Grant Privielges to Role
/*
Below Accounts are not created in RDS
grant select on 'CONTENT.ODM_DOCUMENT' to FNMOAUDIT_ROLE;
grant select on 'DMSYS.DM$OBJECT'  to FNMOAUDIT_ROLE;
grant select on 'DMSYS.DM$MODEL'  to FNMOAUDIT_ROLE;
grant select on 'DMSYS.DM$P_MODEL'  to FNMOAUDIT_ROLE;
grant select on 'DVSYS.DBA_DV_REALM'  to FNMOAUDIT_ROLE;
grant select on 'LBACSYS.LBAC$POLT'  to FNMOAUDIT_ROLE;
grant select on 'MDSYS.ALL_SDO_GEOM_METADATA' to FNMOAUDIT_ROLE;
grant select on 'MDSYS.SDO_GEOM_METADATA_TABLE' to FNMOAUDIT_ROLE;
grant select on 'ODM.ODM_MINING_MODEL' to FNMOAUDIT_ROLE;
grant select on 'ODM.ODM_RECORD' to FNMOAUDIT_ROLE;
grant select on 'OLAPSYS.DBA$OLAP_CUBES'  to FNMOAUDIT_ROLE;
*/

/*
SYS Privs are granted below using RDSADMIN.RDSADMIN_UTIL Package down below
grant select on 'SYS.DBA_ADVISOR_TASKS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_AUDIT_TRAIL' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_AWS'  to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_CPU_USAGE_STATISTICS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_CUBES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_ENCRYPTED_COLUMNS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_FEATURE_USAGE_STATISTICS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_FLASHBACK_ARCHIVE' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_FLASHBACK_ARCHIVE_TS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_FLASHBACK_ARCHIVE_TABLES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_INDEXES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_LOB_PARTITIONS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_LOB_SUBPARTITIONS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_LOBS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_MINING_MODELS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_OBJECT_TABLES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_OBJECTS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_RECYCLEBIN' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_REGISTRY' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_SEGMENTS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_SQL_PROFILES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_SQLSET' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_SQLSET_REFERENCES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_TAB_PARTITIONS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_TAB_SUBPARTITIONS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_TABLES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_TABLESPACES' to FNMOAUDIT_ROLE;
grant select on 'SYS.DBA_USERS' to FNMOAUDIT_ROLE;
grant select on 'SYS.DUAL' to FNMOAUDIT_ROLE;
grant select on 'SYS.GV$IM_SEGMENTS' to FNMOAUDIT_ROLE;
grant select on 'SYS.GV_$INSTANCE' to FNMOAUDIT_ROLE;
grant select on 'SYS.GV_$PARAMETER' to FNMOAUDIT_ROLE;
grant select on 'SYS.MODEL$' to FNMOAUDIT_ROLE;
grant select on 'SYS.REGISTRY$HISTORY' to FNMOAUDIT_ROLE;
grant select on 'SYS.ROLE_SYS_PRIVS' to FNMOAUDIT_ROLE;
grant select on 'SYS.USER_ROLE_PRIVS' to FNMOAUDIT_ROLE;
grant select on 'SYS.USER_SYS_PRIVS' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$ARCHIVE_DEST_STATUS' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$BLOCK_CHANGE_TRACKING' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$CONTAINERS' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$DATABASE' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$INSTANCE' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$LICENSE' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$OPTION' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$PARAMETER' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$SESSION' to FNMOAUDIT_ROLE;
grant select on 'SYS.V_$VERSION' to FNMOAUDIT_ROLE;
*/

/*
SYSMAN Users are not created in RDS
grant select on 'SYSMAN.MGMT$DB_DBNINSTANCEINFO' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT$TARGET' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_FU_LICENSE_MAP' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_ADMIN_LICENSES' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_FU_REGISTRATIONS' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_FU_STATISTICS' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_INV_COMPONENT' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_INV_CONTAINER' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_LICENSE_CONFIRMATION' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_LICENSE_DEFINITIONS' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_LICENSED_TARGETS' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_LICENSES' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_TARGET_TYPES' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_TARGETS' to FNMOAUDIT_ROLE;
grant select on 'SYSMAN.MGMT_VERSIONS' to FNMOAUDIT_ROLE;
*/

/* 
Oracle Apps Users are not created in RDS
grant select on 'APPLSYS.FND_APP_SERVERS' to FNMOAUDIT_ROLE;
grant select on 'APPLSYS.FND_NODES' to FNMOAUDIT_ROLE;
grant select on 'APPLSYS.FND_PRODUCT_INSTALLATIONS' to FNMOAUDIT_ROLE;
grant select on 'APPLSYS.FND_APPLICATION_TL' to FNMOAUDIT_ROLE;
grant select on 'APPLSYS.FND_USER' to FNMOAUDIT_ROLE;
grant select on 'APPLSYS.FND_RESPONSIBILITY' to FNMOAUDIT_ROLE;
grant select on 'APPS.AP_INVOICES_ALL' to FNMOAUDIT_ROLE;
grant select on 'APPS.FND_USER_RESP_GROUPS' to FNMOAUDIT_ROLE;
grant select on 'APPS.RA_CUSTOMER_TRX_ALL' to FNMOAUDIT_ROLE;
grant select on 'APPS.RA_CUSTOMER_TRX_LINES_ALL' to FNMOAUDIT_ROLE;
*/

begin rdsadmin.rdsadmin_util.grant_sys_object('UTL_INADDR','FNMOAUDIT_ROLE','EXECUTE'); end;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_AUDIT_TRAIL','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_AWS' ,'FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_CPU_USAGE_STATISTICS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_CUBES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_ENCRYPTED_COLUMNS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_FEATURE_USAGE_STATISTICS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_FLASHBACK_ARCHIVE','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_FLASHBACK_ARCHIVE_TS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_FLASHBACK_ARCHIVE_TABLES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_INDEXES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_LOB_PARTITIONS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_LOB_SUBPARTITIONS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_LOBS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_MINING_MODELS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_OBJECT_TABLES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_OBJECTS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_RECYCLEBIN','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_REGISTRY','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_SEGMENTS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_SQL_PROFILES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_SQLSET','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_SQLSET_REFERENCES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_TAB_PARTITIONS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_TAB_SUBPARTITIONS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_TABLESPACES','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DBA_USERS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('DUAL','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('GV$IM_SEGMENTS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('GV_$INSTANCE','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('GV_$PARAMETER','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('MODEL$','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('REGISTRY$HISTORY','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('ROLE_SYS_PRIVS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('USER_ROLE_PRIVS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('USER_SYS_PRIVS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$ARCHIVE_DEST_STATUS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$BLOCK_CHANGE_TRACKING','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$CONTAINERS','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$DATABASE','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$INSTANCE','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$LICENSE','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$OPTION','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$PARAMETER','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$SESSION','FNMOAUDIT_ROLE','SELECT'); END;
/
begin rdsadmin.rdsadmin_util.grant_sys_object('V_$VERSION','FNMOAUDIT_ROLE','SELECT'); END;
/