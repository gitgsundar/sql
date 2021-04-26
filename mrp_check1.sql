REM $Header: MRPCHECK.sql 115.1 2004/06/10 $
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     MRPCHECK.sql                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This  script  can  be run to                                      |
REM |     gather information about an application for diagnostic            |
REM |     purposes.                                                         |
REM |                                                                       |
REM | NOTES                                                                 |
REM |     The script takes application id(s) as inputs  and then            |
REM |     generates a report for those applications.                        |
REM |                                                                       |
REM | HISTORY                                                               |
REM |                                                                       |
REM |     04-APR-2004              DTMILLER              CREATED            |
REM |     10-JUN-2004              COZIER                UPDATED            |
REM |                                                                       |
REM |                                                                       |
REM +=======================================================================+

clear buffer;
set heading on
set verify off
set feed off
set linesize 80
set pagesize 5000
set underline '='
set serveroutput on size 1000000

spool mrpcheck.txt

col app_name         format a50  heading 'Application Name' ;
col app_s_name       format a8   heading 'Short|Name' ;
col inst_status      format a10  heading 'Installed?' ;
col app_id           format 9990 heading 'Appl Id' ;
col dtime            format a25  heading 'Script run at Date/Time' ;
col db               format a9   heading 'DB Name';
col created          format a9   heading 'Created';
col ver              format a64  heading 'Oracle RDBMS/Tools Version(s)';
col parameter        format a30  heading 'NLS Parameter Name';
col param_value      format a45  heading 'Currently Set Value';
col owner            format a5   heading 'Owner';
col table_owner      format a5   heading 'Table|Owner';
col table_name       format a30  heading 'Table Name';
col trigger_name     format a30  heading 'Trigger Name';
col trigger_type     format a16  heading 'Trigger Type';
col triggering_event format a26  heading 'Triggering Event';
col status           format a8   heading 'Status';
col index_name       format a30  heading 'Index Name';
col index_type       format a12  heading 'Index Type';
col pparameter       format a39  heading 'Parameter Name';
col pvalues          format a39  heading 'Parameter Value';
col M2A              format a30  heading 'M2A Dblink'
col A2M              format a30  heading 'A2M Dblink'
col plan_id          format 9999 heading 'Plan ID'
col plan_name        format a20  heading 'Plan Name'
col free_flag        format 999  heading 'Free Flag'
col partition_number format 9999 heading 'Plan Prtn Num'
col instance_id      format 9999 heading 'Instance ID'

variable        l_application_id        number;

prompt
prompt Application Installation Details :

select fav.application_name       app_name, 
       fav.application_short_name app_s_name, 
       decode(fpi.status, 'I', 'Yes', 
                          'S', 'Shared', 
                          'N', 'No', fpi.status) inst_status, 
       fav.application_id app_id
from   fnd_application_vl        fav, 
       fnd_product_installations fpi
where  fav.application_id = fpi.application_id
order  by 3;

prompt ***************** Oracle Application Diagnostics Report *****************
prompt
--prompt Diagnostic report generated for Customer ~2.
prompt
prompt *************************************************************************

select to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') dtime from dual;

prompt
prompt 1. Database Name and Created Date :
prompt ===================================

select name db, 
       created 
from   V$DATABASE;

prompt
prompt 2. Oracle Version(s) : 
prompt ======================

select banner ver 
from   V$VERSION;

prompt
prompt 3. NLS Parameter Settings :
prompt ===========================

select parameter, 
       value param_value 
from   nls_session_parameters;

set linesize 120

prompt
prompt 4. Profile Option Values :
prompt ==========================


declare
  l_user_id                         varchar2(255);
  l_user_name                       varchar2(255);
  l_resp_id                         varchar2(255);
  l_resp_name                       varchar2(255);
  l_appl_id                         number := -1;
  l_pov                             varchar2(60);
  l_lvl                             varchar2(10);

  cursor profile_options
  is
  select fpo.application_id,  
         fpo.profile_option_id poi, 
         substr(fpo.user_profile_option_name, 1, 60) upon
  from   fnd_profile_options_vl fpo
  where  fpo.application_id in (704)
  and    fpo.start_date_active <= sysdate
  and    (nvl(fpo.end_date_active,sysdate) >= sysdate)
  order  by fpo.application_id, fpo.user_profile_option_name;

  cursor profile_values(c_appl_id  number, c_po_id  number)
  is
  select substr(fpov.profile_option_value, 1, 52) pov, 
         decode(fpov.level_id, 10001, 'Site', 10002, 'Appl', 10003, 'Resp', 10004, 'User', 'None') lvl
  from   fnd_profile_option_values fpov
  where  fpov.application_id    in (704)
  and    fpov.profile_option_id = c_po_id
  and    ((fpov.level_id = 10001 and fpov.level_value = 0)
   or    (fpov.level_id = 10002 and fpov.level_value = c_appl_id)
   or    (fpov.level_id = 10003 and fpov.level_value_application_id = c_appl_id 
  and    fpov.level_value = to_number(l_resp_id)) 
   or    (fpov.level_id = 10004 and fpov.level_value = to_number(l_user_id)))
  order  by fpov.level_id desc ;

  cursor appl_name(c_appl_id  number)
  is
  select substr(application_name, 1, 60) application_name
  from   fnd_application_vl
  where  application_id = c_appl_id;

begin
  -- Get the User Id/Name, Responsibility Id/Name.
  --
  fnd_profile.get('USER_ID', l_user_id);
  fnd_profile.get('USER_NAME', l_user_name);
  fnd_profile.get('RESP_ID', l_resp_id);
  fnd_profile.get('RESP_NAME', l_resp_name);

  dbms_output.put_line('Logged in as user '||l_user_name||'(Id : '||l_user_id||') with responsibility '||l_resp_name||'(Id : '||l_resp_id||')');

  for rec1 in profile_options loop
    -- if application has changed then change the header.
    if rec1.application_id != l_appl_id then
      for rec2 in appl_name(rec1.application_id) loop
        dbms_output.put_line(chr(10)||'=====================================================================================================');
        dbms_output.put_line('Profile Option Values listing for Application : '||rec2.application_name);
        dbms_output.put_line('=====================================================================================================');
        dbms_output.put_line(chr(10)||'User Profile Option Name                            Profile Option Value                                 Set At');
        dbms_output.put_line('============================================================ ==================================================== ======');
      end loop;

      l_appl_id := rec1.application_id;
    end if;

    open profile_values(rec1.application_id, rec1.poi);

    fetch profile_values into l_pov, l_lvl;

    if profile_values%notfound then
      l_pov := '** Not Set At Any Level **';
      l_lvl := '----';
    end if;

    close profile_values;

    dbms_output.put_line(rpad(rec1.upon, 60)||' '||rpad(l_pov, 52)||' '||rpad(l_lvl, 6));

  end loop;

end;
/


prompt
prompt 5. Patchset and Family Pack level :
prompt ===================================

declare
  num_rows number;

      cursor familypatch is
        select fav.application_short_name app_s_name,
               decode(fpi.status, 'I', 'Installed','S', 'Shared','N', 'No', fpi.status) inst_status,
               fpi.product_version,
               nvl(fpi.patch_level, 'Not Available') patchset 
        from   fnd_application_vl fav, fnd_product_installations fpi 
        where fav.application_id = fpi.application_id and 
        fpi.APPLICATION_ID in (704) order by 1 desc;


FUNCTION Get_Family_Pack_Level (p_app_s_name          VARCHAR2,
                                p_product_patch_level VARCHAR2
      ) RETURN VARCHAR2 IS
      v_prefix                 NUMBER;

    BEGIN

      IF (p_app_s_name = 'MSC' or p_app_s_name = 'MSO') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
         end if;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            if (v_prefix = 68) THEN
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1)||'1';
            ELSE
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1);
            end if;
         ELSE
            RETURN '-';
         END IF;
      ELSIF (p_app_s_name = 'MSD') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
         end if;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) = 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            RETURN '11i.SCP_PF_'||CHR(v_prefix+2);
         END IF;

         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 67 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            if (v_prefix = 68) THEN
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1)||'1';
            ELSE
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1);
            end if;
         ELSE 
            RETURN '-';
         END IF;
      ELSIF  (p_app_s_name = 'MRP') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
         end if;

         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            RETURN '11i.DMF_PF.'||CHR(v_prefix+1);
         ELSE
            RETURN '-';
         END IF;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'Not Available';
   END Get_Family_Pack_Level;

   begin
   dbms_output.put_line(rpad('Apps Short Name ',16)||rpad('Install Status ',15)||rpad('Version ',8)||rpad('Patchset Level ',15)||rpad('Family Pack Level',17));
   dbms_output.put_line(rpad('--------------- ',16)||rpad('-------------- ',15)||rpad('------- ',8)||rpad('-------------- ',15)||rpad('-----------------',17));

   for familypatch_rec in familypatch loop
      dbms_output.put_line(rpad(familypatch_rec.app_s_name,16)||rpad(familypatch_rec.inst_status,15)||rpad(familypatch_rec.product_version,8)||rpad(familypatch_rec.patchset,15)||rpad(Get_Family_Pack_Level(familypatch_rec.app_s_name,familypatch_rec.patchset), 17));
   end loop;
end;
/

prompt
prompt 6. Database Triggers :
prompt ======================

select atrg.table_owner, 
       atrg.table_name, 
       atrg.trigger_name, 
       atrg.trigger_type, 
       atrg.triggering_event, 
       atrg.status
from   all_triggers    atrg, 
       fnd_application fa
where  fa.application_id in (704)
and    atrg.table_owner  = fa.application_short_name
order  by atrg.table_owner, atrg.table_name, atrg.trigger_type;


prompt
prompt 7. Table Indexes :
prompt ==================

select aind.table_owner, 
       aind.table_name, 
       aind.index_name, 
       aind.index_type, 
       aind.status 
from  all_indexes     aind, 
      fnd_application fa
where fa.application_id in (704)
and   aind.table_owner = fa.application_short_name 
order by aind.table_owner, aind.table_name, aind.index_name;



set linesize 120

prompt
prompt 8. Package Versions :
prompt =====================

declare
  type PkgCurType IS REF CURSOR;
  l_pkg_cursor    PkgCurType;
  l_query         varchar2(10000);
  l_where         varchar2(2000);
  l_name          varchar2(30);
  l_type          varchar2(4);
  l_file_name     varchar2(20);
  l_version       varchar2(15);
  l_status        varchar2(7);


  cursor pkg_prefix
  is
  select distinct substr(o.name, 1, decode(instr(o.name, '_'),0,length(o.name),instr(o.name, '_')))||'%' prefix
  from   sys.obj$ o, sys.tab$ t, sys.user$ u 
  where  u.name in
        (select fa.application_short_name
         from   fnd_application fa
         where  fa.application_id in (704))
  and    o.owner# = u.user#
  and    t.obj#   = o.obj#;


begin

  l_query := 'select 
                o.name
              , ltrim(rtrim(substr(substr(s.source, instr(s.source,''Header: '')), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 1), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2) - instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 1) ))) file_name
              , ltrim(rtrim(substr(substr(s.source, instr(s.source,''Header: '')), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 3) - instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2) ))) file_version
              , decode(o.type#, 9, ''SPEC'', 11, ''BODY'', o.type#) type
              , decode(o.status, 0, ''N/A'', 1, ''VALID'', ''INVALID'') status
              from  sys.source$ s, sys.obj$ o, sys.user$ u
              where u.name   = ''APPS''
              and   o.owner# = u.user#
              and   s.obj#   = o.obj#
              and   s.line between 2 and 5
              and   s.source like ''%Header: %''';


  for pkg_prefix_rec in pkg_prefix loop
    if l_where is null then
      l_where := 'and ( o.name like '''||pkg_prefix_rec.prefix||'''';
    else
      l_where := l_where||' or  o.name like '''||pkg_prefix_rec.prefix||'''';
    end if;
  end loop;

  if l_where is not null then
    l_where := l_where||')';
    l_query := l_query||l_where;
  end if;


  l_query := l_query||' order by 1, 4';


  dbms_output.put_line('Name                           File Name            Version         Type Status ');
  dbms_output.put_line('============================== ==================== =============== ==== =======');
  open l_pkg_cursor for l_query;

  loop

    fetch l_pkg_cursor into l_name, l_file_name, l_version, l_type, l_status;
    exit when l_pkg_cursor%notfound;
    dbms_output.put_line(rpad(l_name, 30)||' '||rpad(l_file_name, 20)||' '||rpad(l_version, 15)||' '||rpad(l_type, 4)||' '||rpad(l_status, 7));

  end loop;

end;
/



prompt
prompt 9. v$parameter values :
prompt =======================

select  name  pparameter, 
        value pvalues 
from    v$parameter;


spool off


set head off
set lines 120
