

declare
   -- change username and password here
   var_oracle_username   CONSTANT VARCHAR2(30) := 'fnmoaudit';
   var_oracle_password   CONSTANT VARCHAR2(30) := 'fnmoauditpswd';
   var_oracle_acl_file   CONSTANT VARCHAR2(34) := var_oracle_username || '.xml';
   var_oracle_tablespace_name VARCHAR2(30);
   
   /* Specify the list of servers that can be resolved, granted by this ACL.
      To run an Oracle inventory, it is only necessary that the user is able to resolve the name of the server it is running on (localhost).
      As a result, it is recommended that the name of the local server only is specified each time this script is run on a server, rather than using wildcards to match all servers.
	  If this is not possible, then wildcards can be used, ie '*', '*.company.com' or '192.168.*'.
      It is important to note that granting the ACL to the user above will replace any existing ACL on network server access for the host(s) specified here.
      */
   var_oracle_host_list   CONSTANT VARCHAR2(100) := '';

   type table_varchar is table of varchar2(100);
   var_table_varchar  table_varchar;

   -- Create a custom exception type for error -1031 (insufficient priveleges)   
   insufficient_privileges_ex EXCEPTION;
   PRAGMA EXCEPTION_INIT(insufficient_privileges_ex, -1031);
   
begin

   -- ************************************************************************************************************
   -- Create the Oracle user
   -- ************************************************************************************************************
 
   -- Uncomment this block to always drop the user first if it exists
   /*
   begin
     execute immediate 'drop user ' || var_oracle_username;
   exception
   when others then DBMS_OUTPUT.PUT_LINE('unable to drop user');
   end;
   */
   select tablespace_name into var_oracle_tablespace_name from dba_tablespaces where tablespace_name IN ('USERS','TOOLS','SYSAUX') and rownum=1 order by 1 desc;

   execute immediate 'create user ' || var_oracle_username || ' identified by ' || var_oracle_password || ' default tablespace '|| var_oracle_tablespace_name ;
   execute immediate 'grant create session to ' || var_oracle_username;


   -- ************************************************************************************************************
   -- Set up permissions for getting host name and ipaddress from UTL_INADDR (required for 11g and later)
   -- ************************************************************************************************************
   declare
	  acl_count INTEGER ; 
   begin

      DBMS_OUTPUT.PUT_LINE('Granting execute on UTL_INADDR');
      execute immediate 'grant execute ON utl_inaddr TO ' || var_oracle_username;

	  -- Remove any existing ACL record
      execute immediate 'SELECT count(*) FROM dba_network_acls WHERE acl LIKE ''%' || var_oracle_acl_file || '''' into acl_count;
      IF acl_count > 0 THEN
         execute immediate 'begin 
                              DBMS_NETWORK_ACL_ADMIN.DROP_ACL(''' || var_oracle_acl_file || ''');
  	                        end;';
      END IF;

      -- Create/replace the Access Control List record to allow the fnmoaudit user to access the
      -- host name and address from UTL_INADDR (required for 11g and later)
      DBMS_OUTPUT.PUT_LINE('Creating ACL');
      execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(''' || var_oracle_acl_file || ''', ''Flexnet Audit  Access'',''' ||  upper(var_oracle_username) || ''', TRUE, ''connect'');
                         end;';

      DBMS_OUTPUT.PUT_LINE('Assigning ACL');
      execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(''' || var_oracle_acl_file || ''',''' || var_oracle_host_list || '''); 
                         end;';

      DBMS_OUTPUT.PUT_LINE('Adding privelege');
      execute immediate 'begin 
                           DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(''' || var_oracle_acl_file || ''', ''' || upper(var_oracle_username) || ''', TRUE, ''resolve''); 
                         end;';
      exception
      when others then DBMS_OUTPUT.PUT_LINE( SQLERRM );
   end;

  
   -- ************************************************************************************************************
   -- Grant select permissions for all required tables/views that are part of database introspection.
   -- ************************************************************************************************************
   var_table_varchar  := table_varchar(
									   'SYS.DBA_USERS'
									  ,'SYS.V_$PARAMETER'
									  ,'SYS.V_$INSTANCE' 
									  ,'SYS.V_$DATABASE' 
									  ,'SYS.V_$OPTION'
									  ,'SYS.DBA_FEATURE_USAGE_STATISTICS'
									  ,'SYS.DBA_ENCRYPTED_COLUMNS' 
									  ,'SYS.DBA_TABLESPACES'
									  ,'SYS.V_$SESSION_CONNECT_INFO' 
									  ,'ODM.ODM_MINING_MODEL'
									  ,'ODM.ODM_RECORD' 
									  ,'DMSYS.DM$OBJECT' 
									  ,'DMSYS.DM$MODEL' 
									  ,'DMSYS.DM$P_MODEL' 
									  ,'DVSYS.DBA_DV_REALM' 
									  ,'LBACSYS.LBAC$POLT' 
									  ,'OLAPSYS.DBA$OLAP_CUBES' 
									  ,'SYS.DBA_AWS' 
									  ,'SYS.DBA_SEGMENTS' 
									  ,'SYS.GV_$INSTANCE' 
									  ,'SYS.GV_$PARAMETER' 
									  ,'MDSYS.ALL_SDO_GEOM_METADATA' 
									  ,'SYS.V_$SESSION' 
									  ,'SYSMAN.MGMT_LICENSE_DEFINITIONS' 
									  ,'SYSMAN.MGMT_ADMIN_LICENSES' 
									  ,'SYSMAN.MGMT_LICENSES'
									  ,'SYS.DUAL'
									  ,'SYSMAN.MGMT_LICENSE_CONFIRMATION' 
									  ,'SYSMAN.MGMT_TARGETS' 
									  ,'SYS.DBA_REGISTRY' 
									  ,'SYS.V_$LICENSE' 
									  ,'SYS.DBA_TABLES' 
									  ,'CONTENT.ODM_DOCUMENT' 
									  ,'SYS.V_$VERSION' 
									  ,'SYS.USER_ROLE_PRIVS'
									  ,'SYS.USER_SYS_PRIVS'
									  ,'SYS.ROLE_SYS_PRIVS' 
									  ,'MDSYS.SDO_GEOM_METADATA_TABLE'
									  ,'SYS.DBA_INDEXES'
									  ,'SYS.DBA_LOBS'
									  ,'SYS.DBA_OBJECTS'
									  ,'SYS.DBA_RECYCLEBIN'
									  ,'SYS.DBA_MINING_MODELS'
									  ,'SYS.REGISTRY$HISTORY'
									  ,'SYS.DBA_TAB_PARTITIONS'
									  ,'SYS.DBA_TAB_SUBPARTITIONS'
									  ,'SYS.DBA_LOB_PARTITIONS'
									  ,'SYS.DBA_LOB_SUBPARTITIONS'
									  ,'SYS.V_$ARCHIVE_DEST_STATUS'
									  ,'SYS.DBA_SQL_PROFILES'
									  -- List of tables for E-business Suite apps introspection. 
									  ,'applsys.fnd_app_servers' 
									  ,'applsys.fnd_nodes'
									  ,'applsys.fnd_product_installations' 
									  ,'applsys.fnd_application_tl' 
									  ,'applsys.fnd_user' 
									  ,'applsys.fnd_responsibility' 
									  ,'apps.fnd_user_resp_groups' 
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
