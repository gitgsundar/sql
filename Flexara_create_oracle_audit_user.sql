
/* Usage notes:
   - Script needs to be run as the Oracle SYS user as SYSDBA. SYSTEM does not have all required privileges
   - When running in SQL*Plus, use SET SERVEROUTPUT ON SIZE 50000 FORMAT WRAPPED to see diagnostics
   - Change username and password from defaults below
	- parameters 'local' or 'remote' depending on agent or beacon doing the inventory respectively
 */

PROMPT Creating Oracle audit user for FNMP

declare
   -- change username and password here
   var_oracle_username_local   CONSTANT VARCHAR2(30) := 'ops$fnmpaudit';
   var_oracle_username_remote   CONSTANT VARCHAR2(30) := 'fnmpaudit';
   var_oracle_password   CONSTANT VARCHAR2(30) := 'fnmpauditpswd';
   var_oracle_acl_file   VARCHAR2(34) := '';
   var_script_mode VARCHAR2(20) := '&1';
   var_oracle_username VARCHAR2(30):= '';
   
   /* Fine-grained access control to network services in Oracle 11g and later.
      To run an Oracle inventory, it is necessary and sufficient that the user
      specified by var_oracle_username above be granted the 'resolve' privilege
      in ACLs applicable to both of the following targets:
        - the host name 'localhost', and
        - the IP address returned by UTL_INADDR.GET_HOST_ADDRESS (eg. 192.168.42.53)

      This script will grant the user the required access either by creating a new ACL
      or by adding the user to an existing ACL, or both, depending on the value of
      var_oracle_host_list set below. The script will never unassign an existing ACL.

      If var_oracle_host_list is empty (default), the script will create/update ACLs for:
        - 'localhost'
        - The local server's subnet, eg. '192.168.42.*'

      If var_oracle_host_list is '*', the script will create/update the ACL assigned to '*'.

      If var_oracle_host_list is some other value, it should be in the form of an IP address
      possibly including wildcards, eg.:
        - 10.*
        - 192.168.*
        - 172.16.32.*
        - 8.8.8.8
      Since this ACL will have no effect unless it covers the current machine's IP address
      (as returned by UTL_INADDR.GET_HOST_ADDRESS), the script will use this as a template
      and replace the leading digits in this value with the leading digits of the current IP.
      For example, if var_oracle_host_list is '10.*' and the machine's current IP address
      is 192.168.42.53, the script will create/update ACLs for:
        - 'localhost'
        - '192.*'
      */
   var_oracle_host_list   CONSTANT VARCHAR2(100) := '';

   type table_varchar is table of varchar2(100);
   var_table_varchar  table_varchar;

   -- Create a custom exception type for error -1031 (insufficient privileges)   
   insufficient_privileges_ex EXCEPTION;
   PRAGMA EXCEPTION_INIT(insufficient_privileges_ex, -1031);

   -- Major version of Oracle
   version INTEGER ; 
   
begin

   execute immediate 'select cast(substr(version, 0, instr(version, ''.'') - 1) as int) from v$instance' into version;
   DBMS_OUTPUT.PUT_LINE('Found Oracle version ' || version);

   -- ************************************************************************************************************
   -- Create the Oracle user
   -- ************************************************************************************************************

   declare
      user_exists INTEGER ;
   
   begin

      IF version >= 12 THEN
         -- Allow users without "c##" prefix on Oracle 12c
         EXECUTE IMMEDIATE 'alter session set "_ORACLE_SCRIPT"=true';
      END IF;

      IF var_script_mode = 'local' THEN
          var_oracle_username := var_oracle_username_local;
      ELSE
        IF var_script_mode = 'remote' THEN
          var_oracle_username := var_oracle_username_remote;
        END IF;
      END IF;

      var_oracle_acl_file := var_oracle_username || '.xml';

      execute immediate 'select count(*) from dba_users where username = ''' || upper(var_oracle_username) || '''' into user_exists;

      -- Drop the user first if it exists
      if user_exists <> 0 then
         DBMS_OUTPUT.PUT_LINE('Drop user ' || var_oracle_username);

         execute immediate 'drop user ' || var_oracle_username;
      end if;

      DBMS_OUTPUT.PUT_LINE('Create user ' || var_oracle_username);


      IF var_script_mode = 'local' THEN
          execute immediate 'create user ' || var_oracle_username || '  IDENTIFIED EXTERNALLY';
      ELSE
        IF var_script_mode = 'remote' THEN
      execute immediate 'create user ' || var_oracle_username || ' identified by ' || var_oracle_password;
        END IF;
      END IF;

      execute immediate 'grant create session to ' || var_oracle_username;
	  
	IF version >= 12 THEN
		execute immediate 'alter user ' || var_oracle_username || ' set container_data = all';
	end if;
   end;

   -- ************************************************************************************************************
   -- Set up permissions for getting host name and ipaddress from UTL_INADDR (required for 11g and later)
   -- ************************************************************************************************************
   declare
      acl_count INTEGER ; 
      localhost CONSTANT VARCHAR2(10) := 'localhost';
      hostaddress VARCHAR2(20) ;
      domainlevel INTEGER := 3 ;
      var_oracle_host_target VARCHAR2(100) ;
      allowed VARCHAR2(8) ;
      allowed_host VARCHAR2(20) ;
      existing_acl VARCHAR2(200) ;
   begin

      DBMS_OUTPUT.PUT_LINE('Granting execute on UTL_INADDR');
      execute immediate 'grant execute ON utl_inaddr TO ' || var_oracle_username;

      IF version >= 11 THEN

          execute immediate 'select UTL_INADDR.GET_HOST_ADDRESS from DUAL' into hostaddress;
          DBMS_OUTPUT.PUT_LINE('Found host address ' || hostaddress);

          IF COALESCE(var_oracle_host_list, 'x') <> '*' THEN

              -- Create/update localhost ACL

              -- First check whether an existing ACL is already assigned
              -- If so, use it
              execute immediate 'select count(*), max(acl)
                   FROM dba_network_acls
                   WHERE host = ''' || localhost || ''''
                   into acl_count, existing_acl;

              IF acl_count <> 0 THEN

                  DBMS_OUTPUT.PUT_LINE('Adding resolve privilege for user ' || var_oracle_username || ' to existing ACL ' || existing_acl || ' for ' || localhost);

                  execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(''' || existing_acl || ''', ''' || upper(var_oracle_username) || ''', TRUE, ''resolve''); 
                         end;';

              ELSE

                  execute immediate 'select count(*), max(r.any_path)
                      FROM xdb.resource_view r
                      WHERE r.any_path LIKE ''%' || var_oracle_acl_file || ''''
                      into acl_count, existing_acl;

                  IF acl_count <> 0 THEN
                      DBMS_OUTPUT.PUT_LINE('Adding resolve privilege for user ' || var_oracle_username || ' to ACL ' || var_oracle_acl_file);

                      execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(''' || var_oracle_acl_file || ''', ''' || upper(var_oracle_username) || ''', TRUE, ''resolve''); 
                         end;';
                  ELSE
                      DBMS_OUTPUT.PUT_LINE('Creating ACL ' || var_oracle_acl_file || ' with resolve privilege for user ' || var_oracle_username);
                      execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(''' || var_oracle_acl_file || ''', ''Flexnet Audit Access'',''' ||  upper(var_oracle_username) || ''', TRUE, ''resolve'');
                         end;';
                  END IF;

                  DBMS_OUTPUT.PUT_LINE('Assigning ACL ' || var_oracle_acl_file || ' to ' || localhost);

                  execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(''' || var_oracle_acl_file || ''',''' || localhost || '''); 
                         end;';

              END IF;

              commit;

          END IF; -- var_oracle_host_list <> '*'

          -- Now the ACL for var_oracle_host_list

          IF var_oracle_host_list IS NOT NULL THEN
              execute immediate 'select DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(''' || var_oracle_host_list || ''') FROM DUAL'
                  into domainlevel;
          END IF; -- ELSE domainlevel remains at initial value of 3

          -- Get subnet of host
          execute immediate 'select COLUMN_VALUE FROM TABLE(
                  DBMS_NETWORK_ACL_UTILITY.DOMAINS(''' || hostaddress || '''))
                  WHERE DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(COLUMN_VALUE) = ' || domainlevel
              into var_oracle_host_target;

          -- First check whether an existing ACL is already assigned
          -- If so, use it

          execute immediate 'select count(*), max(acl)
              FROM dba_network_acls
              WHERE host = ''' || var_oracle_host_target || ''''
              into acl_count, existing_acl;

          IF acl_count <> 0 THEN

              DBMS_OUTPUT.PUT_LINE('Adding resolve privilege for user ' || var_oracle_username || ' to existing ACL ' || existing_acl || ' for ' || var_oracle_host_target);

              execute immediate 'begin 
                    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(''' || existing_acl || ''', ''' || upper(var_oracle_username) || ''', TRUE, ''resolve''); 
                    end;';

          ELSE

              execute immediate 'select count(*), max(r.any_path)
                  FROM xdb.resource_view r
                  WHERE r.any_path LIKE ''%' || var_oracle_acl_file || ''''
                  into acl_count, existing_acl;

              IF acl_count <> 0 THEN
                  DBMS_OUTPUT.PUT_LINE('Adding resolve privilege for user ' || var_oracle_username || ' to ACL ' || var_oracle_acl_file);

                  execute immediate 'begin 
                      DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(''' || var_oracle_acl_file || ''', ''' || upper(var_oracle_username) || ''', TRUE, ''resolve''); 
                      end;';
              ELSE
                  DBMS_OUTPUT.PUT_LINE('Creating ACL ' || var_oracle_acl_file || ' with resolve privilege for user ' || var_oracle_username);
                  execute immediate 'begin 
                      DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(''' || var_oracle_acl_file || ''', ''Flexnet Audit Access'',''' ||  upper(var_oracle_username) || ''', TRUE, ''resolve'');
                      end;';
              END IF;

              DBMS_OUTPUT.PUT_LINE('Assigning ACL ' || var_oracle_acl_file || ' to ' || var_oracle_host_target);

              execute immediate 'begin 
                    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(''' || var_oracle_acl_file || ''',''' || var_oracle_host_target || '''); 
                    end;';

          END IF;

          -- First, ensure the above ACL changes have been committed
          commit;

          -- Now, check the the user has the required privileges

          execute immediate 'select count(*)
                   FROM dba_network_acls
                   WHERE host IN (SELECT *
                       FROM TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS(''' || localhost || '''))
                   )' into acl_count;

          IF acl_count = 0 THEN
              DBMS_OUTPUT.PUT_LINE('Warning: No network ACL applies to ' || localhost);
          END IF;

          execute immediate 'select count(*)
                   FROM dba_network_acls
                   WHERE host IN (SELECT *
                       FROM TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS(''' || hostaddress || '''))
                   )' into acl_count;

          IF acl_count = 0 THEN
              DBMS_OUTPUT.PUT_LINE('Warning: No network ACL applies to ' || hostaddress);
          END IF;

          execute immediate 'select * from (
                   select DECODE(
                       DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(acl, ''' || upper(var_oracle_username) || ''', ''resolve''), 
                       1, ''GRANTED'', 0, ''DENIED'', NULL) privilege,
                       host
                   FROM dba_network_acls
                   WHERE host IN (SELECT *
                       FROM TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS(''' || localhost || ''')))
                   ORDER BY privilege DESC, DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) DESC
               ) res WHERE rownum = 1' into allowed, allowed_host;

          DBMS_OUTPUT.PUT_LINE('User is ' || allowed || ' resolve on ' || localhost || ' by ACL assigned to ' || allowed_host);

          execute immediate 'select * from (
                   select DECODE(
                       DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE(acl, ''' || upper(var_oracle_username) || ''', ''resolve''), 
                       1, ''GRANTED'', 0, ''DENIED'', NULL) privilege,
                       host
                   FROM dba_network_acls
                   WHERE host IN (SELECT *
                       FROM TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS(''' || hostaddress || ''')))
                   ORDER BY privilege DESC, DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) DESC
               ) res WHERE rownum = 1' into allowed, allowed_host;

          DBMS_OUTPUT.PUT_LINE('User is ' || allowed || ' resolve on ' || hostaddress || ' by ACL assigned to ' || allowed_host);

      END IF; -- version >= 11

      exception
      when others then DBMS_OUTPUT.PUT_LINE( SQLERRM );
   end;

  
   -- ************************************************************************************************************
   -- Grant select permissions for all required tables/views that are part of database introspection.
   -- ************************************************************************************************************
   var_table_varchar  := table_varchar(
									  'CONTENT.ODM_DOCUMENT'
									  ,'DMSYS.DM$OBJECT' 
									  ,'DMSYS.DM$MODEL' 
									  ,'DMSYS.DM$P_MODEL' 
									  ,'DVSYS.DBA_DV_REALM' 
									  ,'LBACSYS.LBAC$POLT' 
									  ,'MDSYS.ALL_SDO_GEOM_METADATA'
									  ,'MDSYS.SDO_GEOM_METADATA_TABLE'
									  ,'ODM.ODM_MINING_MODEL'
									  ,'ODM.ODM_RECORD'
									  ,'OLAPSYS.DBA$OLAP_CUBES' 
									  ,'SYS.DBA_ADVISOR_TASKS'
									  ,'SYS.DBA_AUDIT_TRAIL'
									  ,'SYS.DBA_AWS' 
									  ,'SYS.DBA_CPU_USAGE_STATISTICS'
									  ,'SYS.DBA_CUBES'
									  ,'SYS.DBA_ENCRYPTED_COLUMNS'
									  ,'SYS.DBA_FEATURE_USAGE_STATISTICS'
									  ,'SYS.DBA_FLASHBACK_ARCHIVE'
									  ,'SYS.DBA_FLASHBACK_ARCHIVE_TS'
									  ,'SYS.DBA_FLASHBACK_ARCHIVE_TABLES'
									  ,'SYS.DBA_INDEXES'
									  ,'SYS.DBA_LOB_PARTITIONS'
									  ,'SYS.DBA_LOB_SUBPARTITIONS'
									  ,'SYS.DBA_LOBS'
									  ,'SYS.DBA_MINING_MODELS'
									  ,'SYS.DBA_OBJECT_TABLES'
									  ,'SYS.DBA_OBJECTS'
									  ,'SYS.DBA_RECYCLEBIN'
									  ,'SYS.DBA_REGISTRY'
									  ,'SYS.DBA_SEGMENTS'
									  ,'SYS.DBA_SQL_PROFILES'
									  ,'SYS.DBA_SQLSET'
									  ,'SYS.DBA_SQLSET_REFERENCES'
									  ,'SYS.DBA_TAB_PARTITIONS'
									  ,'SYS.DBA_TAB_SUBPARTITIONS'
									  ,'SYS.DBA_TABLES'
									  ,'SYS.DBA_TABLESPACES'
									  ,'SYS.DBA_USERS'
									  ,'SYS.DUAL'
									  ,'SYS.GV$IM_SEGMENTS'
									  ,'SYS.GV_$INSTANCE'
									  ,'SYS.GV_$PARAMETER'
									  ,'SYS.MODEL$'
									  ,'SYS.REGISTRY$HISTORY'
									  ,'SYS.ROLE_SYS_PRIVS'
									  ,'SYS.USER_ROLE_PRIVS'
									  ,'SYS.USER_SYS_PRIVS'
									  ,'SYS.V_$ARCHIVE_DEST_STATUS'
									  ,'SYS.V_$BLOCK_CHANGE_TRACKING'
									  ,'SYS.V_$CONTAINERS'
									  ,'SYS.V_$DATABASE'
									  ,'SYS.V_$INSTANCE'
									  ,'SYS.V_$LICENSE'
									  ,'SYS.V_$OPTION'
									  ,'SYS.V_$PARAMETER'
									  ,'SYS.V_$SESSION'
									  ,'SYS.V_$VERSION'
                    ,'SYSMAN.MGMT$DB_DBNINSTANCEINFO'
									  ,'SYSMAN.MGMT$TARGET'
									  ,'SYSMAN.MGMT_FU_LICENSE_MAP'
									  ,'SYSMAN.MGMT_ADMIN_LICENSES'
									  ,'SYSMAN.MGMT_FU_REGISTRATIONS'
									  ,'SYSMAN.MGMT_FU_STATISTICS'
									  ,'SYSMAN.MGMT_INV_COMPONENT'
									  ,'SYSMAN.MGMT_INV_CONTAINER'
									  ,'SYSMAN.MGMT_LICENSE_CONFIRMATION'
									  ,'SYSMAN.MGMT_LICENSE_DEFINITIONS'
									  ,'SYSMAN.MGMT_LICENSED_TARGETS'
									  ,'SYSMAN.MGMT_LICENSES'
									  ,'SYSMAN.MGMT_TARGET_TYPES'
									  ,'SYSMAN.MGMT_TARGETS'
									  ,'SYSMAN.MGMT_VERSIONS'
									  -- List of tables for E-business Suite apps introspection. 
									  ,'APPLSYS.FND_APP_SERVERS'
									  ,'APPLSYS.FND_NODES'
									  ,'APPLSYS.FND_PRODUCT_INSTALLATIONS'
									  ,'APPLSYS.FND_APPLICATION_TL'
									  ,'APPLSYS.FND_USER'
									  ,'APPLSYS.FND_RESPONSIBILITY'
									  ,'APPS.AP_INVOICES_ALL'
									  ,'APPS.FND_USER_RESP_GROUPS'
									  ,'APPS.RA_CUSTOMER_TRX_ALL'
									  ,'APPS.RA_CUSTOMER_TRX_LINES_ALL'

									   );

   for elem in 1 .. var_table_varchar.count loop
      begin
        execute immediate 'grant select on ' || var_table_varchar(elem) || ' to ' || var_oracle_username;
        exception
        when insufficient_privileges_ex then
          DBMS_OUTPUT.PUT_LINE('Insufficient access to table: ' || var_table_varchar(elem));
          raise_application_error(-20000, 'Insufficient access to table: ' || var_table_varchar(elem)); 
        when others then 
         DBMS_OUTPUT.PUT_LINE('Unable to grant SELECT access to table: ' || var_table_varchar(elem) || '. Skipping...  Error=' || SQLERRM);
      end;
   end loop;
   
end;

/

show errors;
