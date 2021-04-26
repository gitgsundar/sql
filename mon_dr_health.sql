-- 	File 		:	MON_DR_HEALTH.SQL
--	Description	:	Provides details of the Oracle DR Standby Setup. 
--	Info		:	Update Spool information as required to get the spool output.

set pages 9999 lines 300 verify off
col Instance				heading 'Environment Info'			for a100
col host_name 				heading 'HostName'					for a20
col version 				heading 'Version'					for a12
col role 					heading 'DB Role'					for a18 
col force_logging 			heading 'Logging'					for a13 
col remote_archive  		heading 'Remote Logging'			for a14
col dataguard_broker 		heading 'DG Broker'					for a16
col destination 			heading 'Destination'				for A60 wrap
col process 				heading 'Process'					for a7 
col archiver 				heading 'Archiver'					for a8 
col ID 						heading 'ID'						for 99 
col thread#					heading 'Th #'						for 999
col message 				heading 'Message'					for a80 
col status					heading 'Status'					for a12
col pprocess				heading 'Pri Process'				for a10
col sprocess				heading 'Stdby Process'				for a12
col pid						heading 'Pri OS|Pid'				for 9999999
col client_pid				heading 'Stdby OS|Pid'				for a10
col sequence#				heading 'Log Seq#'
col type					heading 'Type'						for a30
col item					heading 'Reco Info'					for a30
col timestamp				heading 'Time'
col units					heading 'Units'						for a20
col	tl						heading	'Transport Lag'				for a15
col al						heading	'Apply Lag'					for a15
col tl_date					heading	'TL Date'					for a20
col al_date					heading 'AL Date'					for a20
col st_time					heading 'Est Startup Time'			for a20

tti off
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on

col spoolfile				heading 'Spool File Name'			format a100
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'mon_dr_health_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Archiver Status :' skip 2

select instance_name,host_name,version,archiver,log_switch_wait 
from v$instance
/

tti off
tti Left 'DG Setup Information :' skip 2

select name,platform_id,database_role role,log_mode,flashback_on flashback,protection_mode,protection_level  
from v$database
/

tti off
tti Left 'Logging Information :' skip 2

select force_logging,remote_archive,supplemental_log_data_pk,supplemental_log_data_ui,switchover_status,dataguard_broker 
from v$database
/

tti off
tti Left 'Archive Destination Information :' skip 2

select dest_id "ID",destination,status,target, archiver,schedule,process,mountid  
from v$archive_dest
where destination is not null
/

select dest_id,status,error 
from v$archive_dest
where status='VALID'
/ 

tti off
tti Left 'DG Status :' skip 2

select message, timestamp 
from v$dataguard_status 
where severity in ('Error','Fatal') 
order by timestamp
/

tti off
tti Left 'Log Received-Apply Info:' skip 2

select al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied"
from (select thread# thrd, max(sequence#) almax
  	   from v$archived_log
  	   where resetlogs_change#=(select resetlogs_change# from v$database)
  	   group by thread#) al,
  	  (select thread# thrd, max(sequence#) lhmax
  	   from v$log_history
  	   where resetlogs_change#=(select resetlogs_change# from v$database)
  	   group by thread#) lh
where al.thrd = lh.thrd
/

--  select * from v$archive_gap --- This Query gives ORA-1220 OR runs PRETTY SLOW!!

tti off
tti Left 'Archive Gap Info:' skip 2

select USERENV('Instance'), high.thread#, low.lsq, high.hsq
 from
  (select a.thread#, rcvsq, min(a.sequence#)-1 hsq
   from v$archived_log a,
        (select lh.thread#, lh.resetlogs_change#, max(lh.sequence#) rcvsq
           from v$log_history lh, v$database_incarnation di
          where lh.resetlogs_time = di.resetlogs_time
            and lh.resetlogs_change# = di.resetlogs_change#
            and di.status = 'CURRENT'
            and lh.thread# is not null
            and lh.resetlogs_change# is not null
            and lh.resetlogs_time is not null
         group by lh.thread#, lh.resetlogs_change#
        ) b
   where a.thread# = b.thread#
     and a.resetlogs_change# = b.resetlogs_change#
     and a.sequence# > rcvsq
   group by a.thread#, rcvsq) high,
 (select srl_lsq.thread#, nvl(lh_lsq.lsq, srl_lsq.lsq) lsq
   from
     (select thread#, min(sequence#)+1 lsq
      from
        v$log_history lh, x$kccfe fe, v$database_incarnation di
      where to_number(fe.fecps) <= lh.next_change#
        and to_number(fe.fecps) >= lh.first_change#
        and fe.fedup!=0 and bitand(fe.festa, 12) = 12
        and di.resetlogs_time = lh.resetlogs_time
        and lh.resetlogs_change# = di.resetlogs_change#
        and di.status = 'CURRENT'
      group by thread#) lh_lsq,
     (select thread#, max(sequence#)+1 lsq
      from
        v$log_history
      where (select min( to_number(fe.fecps))
             from x$kccfe fe
             where fe.fedup!=0 and bitand(fe.festa, 12) = 12)
      >= next_change#
      group by thread#) srl_lsq
   where srl_lsq.thread# = lh_lsq.thread#(+)
  ) low
 where low.thread# = high.thread#
 and lsq < = hsq
 and hsq > rcvsq
/ 

tti off
tti Left 'Standby Processes Info:' skip 2

SELECT inst_id ID, thread#, process pproces, pid, status, client_process sprocess, client_pid, sequence#, blocks
FROM gv$managed_standby 
ORDER BY thread#, pid
/

tti off
tti Left 'Recovery Progress Info:' skip 2

select type,item,units,sofar,timestamp
from v$recovery_progress
/

tti off
tti Left 'DG Lag/Apply Info:' skip 2


select
	max(decode(name,'transport lag',value,null)) tl,
	max(decode(name,'apply lag',value,null)) al,
	max(decode(name,'transport lag',datum_time,null)) tl_date,
	max(decode(name,'apply lag',datum_time,null)) al_date,
	max(decode(name,'estimated startup time',value,null)) st_time	
from gv$dataguard_stats
/

spool off