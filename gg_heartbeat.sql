---
---	Source Heartbeat Table
---

drop table ggadmin.ggs_heartbeat
/
create table ggadmin.ggs_heartbeat
( 	id 						number ,
	extract_name 			varchar2(8),
	source_commit 			timestamp,
	target_commit 			timestamp,
	captime 					timestamp,
	capgroup 				varchar2(8),
	caplag 					number,
	pmptime 					timestamp,
	pmpgroup 				varchar2(8),
	pmplag 					number,
	deltime 					timestamp,
	delgroup 				varchar2(8),
	dellag 					number,
	totallag 				number,
	lag_hh_mi_ss 			varchar2(15),
	lag_as_of_hh_mi_ss	varchar2(15),
	thread 					number,
	status 					varchar2(10),
	current_seqno 			number,
	current_rba 			number,
	start_time 				date,
	report_time 			date,
	recovery_seqno 		number,
	recovery_rba 			number,
	recovery_timestamp 	timestamp,
	update_timestamp 		timestamp,
constraint ggs_heartbeat_u1 primary key (extract_name, thread) enable
)
/

---
---	Target Heartbeat Table
---

drop sequence ggadmin.seq_ggs_heartbeat_id
/
create sequence ggadmin.seq_ggs_heartbeat_id increment by 1 start with 1 order
/
drop table ggadmin.ggs_heartbeat
/
create table ggadmin.ggs_heartbeat
( 	id 						number not null enable,
	extract_name			varchar2(8),
	source_commit 			timestamp,
	target_commit 			timestamp,
	captime 					timestamp,
	capgroup 				varchar2(8),
	caplag 					number,
	pmptime 					timestamp,
	pmpgroup 				varchar2(8),
	pmplag 					number,
	deltime 					timestamp,
	delgroup 				varchar2(8),
	dellag 					number,
	totallag 				number,
	lag_hh_mi_ss 			varchar2(15),
	lag_as_of_hh_mi_ss 	varchar2(15),
	thread 					number,
	status 					varchar2(10),
	current_seqno 			number,
	current_rba 			number,
	start_time 				date,
	report_time 			date,
	recovery_seqno 		number,
	recovery_rba 			number,
	recovery_timestamp 	timestamp,
	update_timestamp 		timestamp,
constraint ggs_heartbeat_u1 primary key (delgroup) enable
)
/

create or replace trigger ggadmin.ggs_heartbeat_trig
before insert or update on ggadmin.ggs_heartbeat
for each row
begin
	select seq_ggs_heartbeat_id.nextval
	into :new.id
	from dual;
	
	select systimestamp
	into :new.target_commit
	from dual;
	
	select trunc(to_number(substr((:new.captime - :new.source_commit ),1, instr(:new.captime - :new.source_commit,' ')))) * 86400
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+1,2)) * 3600 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+4,2) ) * 60 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+7,2)) 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+10,6)) / 1000000
	into :new.caplag
	from dual;
	
	select trunc(to_number(substr((:new.pmptime - :new.captime),1, instr(:new.pmptime - :new.captime,' ')))) * 86400
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+1,2)) * 3600 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+4,2) ) * 60 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+7,2)) 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+10,6)) / 1000000
	into :new.pmplag
	from dual;
	
	select trunc(to_number(substr((:new.deltime - :new.pmptime),1, instr(:new.deltime - :new.pmptime,' ')))) * 86400
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+1,2)) * 3600 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+4,2) ) * 60 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+7,2)) 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+10,6)) / 1000000
	into :new.dellag
	from dual;
	
	select trunc(to_number(substr((:new.target_commit - :new.source_commit),1, instr(:new.target_commit - :new.source_commit,' ')))) * 86400
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+1,2)) * 3600 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+4,2) ) * 60 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+7,2)) 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+10,6)) / 1000000
	into :new.totallag
	from dual;
	
end;
/

alter trigger ggadmin.ggs_heartbeat_trig enable
/

--
-- This is for the History heartbeat table
--

drop sequence ggadmin.seq_ggs_heartbeat_hist 
/
create sequence ggadmin.seq_ggs_heartbeat_hist increment by 1 start with 1 order
/
drop table ggadmin.ggs_heartbeat_history
/
create table ggadmin.ggs_heartbeat_history
( 	id 						number not null enable,
	extract_name 			varchar2(8),
	source_commit 			timestamp,
	target_commit 			timestamp,
	captime 					timestamp,
	capgroup 				varchar2(8),
	caplag 					number,
	pmptime 					timestamp,
	pmpgroup 				varchar2(8),
	pmplag 					number,
	deltime 					timestamp,
	delgroup 				varchar2(8),
	dellag 					number,
	totallag 				number,
	lag_hh_mi_ss 			varchar2(15),
	lag_as_of_hh_mi_ss	varchar2(15),
	thread 					number,
	status 					varchar2(10),
	current_seqno 			number,
	current_rba 			number,
	start_time 				date,
	report_time 			date,
	recovery_seqno 		number,
	recovery_rba 			number,
	recovery_timestamp 	timestamp,
	update_timestamp 		timestamp,
constraint ggs_heartbeat_hist_u1 primary key (id) enable
)
/

create or replace trigger ggadmin.ggs_heartbeat_trig_hist
before insert or update on ggadmin.ggs_heartbeat_history
for each row
begin
	select seq_ggs_heartbeat_hist.nextval
	into :new.id
	from dual;
	
	select systimestamp
	into :new.target_commit
	from dual;
	
	select trunc(to_number(substr((:new.captime - :new.source_commit ),1, instr(:new.captime - :new.source_commit,' ')))) * 86400
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+1,2)) * 3600 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+4,2) ) * 60 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+7,2)) 
	+ to_number(substr((:new.captime - :new.source_commit), instr((:new.captime - :new.source_commit),' ')+10,6)) / 1000000
	into :new.caplag
	from dual;
	
	select trunc(to_number(substr((:new.pmptime - :new.captime),1, instr(:new.pmptime - :new.captime,' ')))) * 86400
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+1,2)) * 3600 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+4,2) ) * 60 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+7,2)) 
	+ to_number(substr((:new.pmptime - :new.captime), instr((:new.pmptime - :new.captime),' ')+10,6)) / 1000000
	into :new.pmplag
	from dual;
	
	select trunc(to_number(substr((:new.deltime - :new.pmptime),1, instr(:new.deltime - :new.pmptime,' ')))) * 86400
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+1,2)) * 3600 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+4,2) ) * 60 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+7,2)) 
	+ to_number(substr((:new.deltime - :new.pmptime), instr((:new.deltime - :new.pmptime),' ')+10,6)) / 1000000
	into :new.dellag
	from dual;
	
	select trunc(to_number(substr((:new.target_commit - :new.source_commit),1, instr(:new.target_commit - :new.source_commit,' ')))) * 86400
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+1,2)) * 3600 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+4,2) ) * 60 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+7,2)) 
	+ to_number(substr((:new.target_commit - :new.source_commit), instr((:new.target_commit - :new.source_commit),' ')+10,6)) / 1000000
	into :new.totallag
	from dual;
end;
/

alter trigger ggadmin.ggs_heartbeat_trig_hist enable
/
