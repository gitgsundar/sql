set pages 9999 verify off lines 300
col	hostname		heading "Hostname"				for a50
col Instance		heading "Environment Info"		for a100

col instance new_value instance
set termout off
select  instance_name || '_' instance from  v$instance
/

set termout on
col spoolfile new_val spoolfile
select 'C:\Ganesh\Work\SQL-SPOOL\'||'&instance'||'flexera_data_masking_info_'||to_char(sysdate,'yyyymmdd') spoolfile from dual
/
spool &spoolfile

select sysdate ||'    '|| upper(instance_name)||' running on Server - '|| host_name ||' as '|| instance_role Instance from v$instance
/

select
DECODE((select COUNT(*) from DBA_TABLES where TABLE_NAME = 'MGMT_ADMIN_LICENSES'),
0, 'SYSMAN',(select owner from DBA_TABLES where TABLE_NAME='MGMT_ADMIN_LICENSES')) as "owner"
from DUAL
/

select 'Data Masking Pack' as "Option", PACK_ACCESS_GRANTED as "Installed", PACK_ACCESS_AGREED as "Used" from (
select distinct a.PACK_DISPLAY_LABEL as "Label",
decode(b.pack_name, null, 0,1) as PACK_ACCESS_GRANTED,
PACK_ACCESS_AGREED
from sysman.MGMT_LICENSE_DEFINITIONS a,
sysman.MGMT_ADMIN_LICENSES b,
(select count(*) as PACK_ACCESS_AGREED from sysman.MGMT_LICENSES where upper(I_AGREE)='YES') c
where a.PACK_LABEL = B.PACK_NAME )
where "Label" = 'Data Masking Pack'
/

WITH OPTION_DATA as (
SELECT 'Data Masking Pack' as OPTION_NAME, DECODE(CURRENTLY_USED,'TRUE',1,0) as USED
FROM DBA_FEATURE_USAGE_STATISTICS
WHERE NAME IN ('Data Masking Pack (GC)') )
SELECT OPTION_NAME as "Option", COALESCE(SUM(USED),0) as "Installed", COALESCE(SUM(USED),0) as "Used" FROM OPTION_DATA
/

SELECT 'Data Masking Pack' as "Option", PACK_ACCESS_GRANTED as "Installed", PACK_ACCESS_AGREED as "Used", PACK_HOST_NAME as "HostName", PACK_INSTANCE_NAME as "InstanceName" from (
SELECT
DECODE(LT.PACK_NAME , NULL, 0, 1) AS PACK_ACCESS_GRANTED,
DECODE(LC.TARGET_GUID, NULL, 0, 1) AS PACK_ACCESS_AGREED,
CASE
WHEN INSTR(DB.HOST, '.') > 0 THEN DB.HOST
ELSE DB.HOST_NAME
END as PACK_HOST_NAME,
DB.INSTANCE_NAME as PACK_INSTANCE_NAME
FROM sysman.MGMT_TARGETS TG
INNER JOIN sysman.MGMT_LICENSE_DEFINITIONS LD ON TG.TARGET_TYPE = LD.TARGET_TYPE
INNER JOIN sysman.MGMT$DB_DBNINSTANCEINFO DB on DB.TARGET_GUID = TG.TARGET_GUID
LEFT OUTER JOIN sysman.MGMT_LICENSED_TARGETS LT ON TG.TARGET_GUID = LT.TARGET_GUID AND LD.PACK_LABEL = LT.PACK_NAME
LEFT OUTER JOIN sysman.MGMT_LICENSE_CONFIRMATION LC ON TG.TARGET_GUID = LC.TARGET_GUID
WHERE LD.PACK_DISPLAY_LABEL IN ('Data Masking Pack', 'Oracle Data Masking and Subsetting Pack')
)
/

WITH OPTION_DATA AS
(
SELECT
reg.feature_name,
tgts.TARGET_GUID,
DECODE(SUM(stat.isused), 0, 0, 1) as CURRENTLY_USED
FROM
sysman.MGMT_FU_REGISTRATIONS reg,
sysman.MGMT_FU_STATISTICS stat,
sysman.MGMT_TARGETS tgts
WHERE
(stat.isused = 1 or stat.detected_samples > 0)
AND stat.target_guid = tgts.target_guid
AND reg.feature_id = stat.feature_id
AND reg.collection_mode = 2
AND reg.feature_name = 'Oracle Data Masking and Subsetting Pack'
GROUP BY
reg.feature_name,
tgts.TARGET_GUID
)
SELECT
'Data Masking Pack' as "Option",
1 AS "Installed",
COALESCE(CURRENTLY_USED, 0) AS "Used",
CASE
WHEN INSTR(db.HOST, '.') > 0 THEN db.HOST
ELSE db.HOST_NAME
END as "HostName",
db.INSTANCE_NAME as "InstanceName"
FROM
OPTION_DATA d
INNER JOIN sysman.MGMT$DB_DBNINSTANCEINFO db
ON db.TARGET_GUID = d.TARGET_GUID
/

WITH OPTION_DATA AS
(
SELECT
reg.feature_name,
tgts.TARGET_GUID,
DECODE(SUM(f_stats.isused), 0, 0, 1) as CURRENTLY_USED
FROM
sysman.MGMT_FU_REGISTRATIONS reg,
sysman.MGMT_FU_STATISTICS stat,
sysman.MGMT_TARGETS tgts,
sysman.MGMT_FU_STATISTICS f_stats,
sysman.MGMT_FU_REGISTRATIONS freg,
sysman.MGMT_FU_LICENSE_MAP lmap
WHERE
(f_stats.isused = 1 or f_stats.detected_samples > 0)
AND stat.target_guid = tgts.target_guid
AND reg.feature_id = stat.feature_id
AND reg.collection_mode = 2
AND lmap.pack_id = reg.feature_id
AND lmap.feature_id = freg.feature_id
AND freg.feature_id = f_stats.feature_id
AND f_stats.target_guid = tgts.target_guid
AND reg.feature_name = 'Oracle Data Masking and Subsetting Pack'
GROUP BY
reg.feature_name,
tgts.TARGET_GUID
)
SELECT
'Data Masking Pack' as "Option",
1 AS "Installed",
COALESCE(CURRENTLY_USED, 0) AS "Used",
CASE
WHEN INSTR(db.HOST, '.') > 0 THEN db.HOST
ELSE db.HOST_NAME
END as "HostName",
db.INSTANCE_NAME as "InstanceName"
FROM
OPTION_DATA d
INNER JOIN sysman.MGMT$DB_DBNINSTANCEINFO db
ON db.TARGET_GUID = d.TARGET_GUID
/
spool off