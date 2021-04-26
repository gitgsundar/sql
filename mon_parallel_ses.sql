set pages 9999 lines 200 verify off
col Instance			heading "Environment Info"	format a100
col username 			heading "Username"			format a12
col "QC SID" 			heading "QC SID"			format A6
col "SID" 				heading "SID"				format A6
col "QC/Slave" 			heading "QC|Slave"			format A8
col "Req. DOP" 			heading "Req DOP"			for 9999
col "Actual DOP" 		heading "Actual DOP"		for 9999
col "Slaveset" 			heading "Slaveset"			for A8
col "Slave INST" 		heading "Slave INST"		for A9
col "QC INST" 			heading "QC INST"			for A6
col wait_event 			heading "Wait Event"		format a30 
col spoolfile			heading 'Spool File Name'	format a100
col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/
set termout on
col spoolfile new_val spoolfile
select '/Users/gsundaresan/Documents/Gan/Sql_spool/'||'&instance'||'mon_parallel_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name Instance from v$instance
/
select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "DB Startup Time" from v$instance
/

tti off
tti Left 'Parallel Session Information :' skip 2
select
	decode(px.qcinst_id,NULL,username,' - '||lower(substr(pp.SERVER_NAME,length(pp.SERVER_NAME)-4,4) ) )"Username",
	decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
	to_char( px.server_set) "SlaveSet",
	to_char(s.sid) "SID",
	to_char(px.inst_id) "Slave INST",
	decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,     
	case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
	decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
	to_char(px.qcinst_id) "QC INST",
	px.req_degree "Req. DOP",
	px.degree "Actual DOP"
from gv$px_session px,
	gv$session s ,
	gv$px_process pp,
	gv$session_wait sw
where px.sid=s.sid (+)
	and px.serial#=s.serial#(+)
	and px.inst_id = s.inst_id(+)
	and px.sid = pp.sid (+)
	and px.serial#=pp.serial#(+)
	and sw.sid = s.sid  
	and sw.inst_id = s.inst_id   
order by
  decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP), 
  px.SERVER_SET, 
  px.INST_ID
/ 

tti off
spool off