set pages 9999 
set verify off
col Instance				heading 	'Environment Info' 			format a100

tti Left 'Instance Information :' skip 2

col spoolfile			heading 'Spool File Name'			format a50
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/mon_undo_txn_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
tti off

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti Left 'Active Undo Information :' skip 2

Select b.segment_name as "UNDO Name", 
       sum(c.used_ublk) as "Total Blocks"
From dba_rollback_segs b, v$transaction c
Where b.segment_id = c.xidusn
Group by segment_name;

tti off

tti Left 'Active Segments in UNDO Information :' skip 2

Select   substr(a.os_user_name,1,8)    "OS User",
         substr(a.oracle_username,1,8) "DB User",
         substr(b.owner,1,8)           "Schema",
         substr(b.object_name,1,25)    "Object Name",
         substr(b.object_type,1,10)    "Type",
         c.segment_name                "Undo Name",
         substr(d.used_urec,1,12)      "# of Records"
From v$locked_object   a,
     dba_objects       b,
     dba_rollback_segs c,
     v$transaction     d,
     v$session         e
Where a.object_id = b.object_id
  And a.xidusn    = c.segment_id
  And a.xidusn    = d.xidusn
  And a.xidslot   = d.xidslot
  And d.addr      = e.taddr
order by 3
/

tti off

spool off