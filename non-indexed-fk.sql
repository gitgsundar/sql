col table_name 		format a30
col constraint_name 	format a30
col columns				format a30


select owner,table_name, constraint_name,
	cname1 || nvl2(cname2,','||cname2,null) || nvl2(cname3,','||cname3,null) 
 				|| nvl2(cname4,','||cname4,null) || nvl2(cname5,','||cname5,null) 
 				|| nvl2(cname6,','||cname6,null) || nvl2(cname7,','||cname7,null) 
 				|| nvl2(cname8,','||cname8,null) columns
from (select
			b.owner,
			b.table_name,
			b.constraint_name,
			max(decode( position, 1, column_name, null )) cname1,
			max(decode( position, 2, column_name, null )) cname2,
			max(decode( position, 3, column_name, null )) cname3,
			max(decode( position, 4, column_name, null )) cname4,
			max(decode( position, 5, column_name, null )) cname5,
			max(decode( position, 6, column_name, null )) cname6,
			max(decode( position, 7, column_name, null )) cname7,
			max(decode( position, 8, column_name, null )) cname8,
			count(*) col_cnt
		from (select substr(table_name,1,30) table_name,
					 substr(constraint_name,1,30) constraint_name,
					 substr(column_name,1,30) column_name,
					 position
				 from dba_cons_columns ) a,
				dba_constraints b
		where a.constraint_name = b.constraint_name
		  and b.constraint_type = 'R'
		group by b.owner,b.table_name, b.constraint_name
		) cons
 where col_cnt > ALL
 ( select count(*)
	 from dba_ind_columns i
	 where i.table_name = cons.table_name
		 and i.column_name in (cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8 )
		 and i.column_position <= cons.col_cnt
	 group by i.index_name
 )
order by 1,2 
/


col table_name 		format a30 heading 'Table Name'
col constraint_name 	format a30 heading 'Constraint Name'
col column_name		format a30 heading 'Column Name'
col owner				format a15 heading 'Owner'
col r_owner				format a15 heading 'R-Owner'
col r_constraint_name format a30 heading 'R-Constraint Name'


SELECT con.owner
      ,con.table_name
      ,col.column_name
      ,con.constraint_name
      ,con.r_owner
      ,con.r_constraint_name
      ,rfc.owner
      ,rfc.table_name
FROM   dba_cons_columns col
      ,dba_constraints  con
      ,dba_constraints  rfc
WHERE  con.constraint_type = 'R'
AND    con.owner not in ('SYS','SYSTEM')
AND    col.owner(+) = nvl(con.r_owner, con.owner)
AND    col.constraint_name(+) = nvl(con.r_constraint_name, con.constraint_name)
AND    rfc.owner = con.r_owner
AND    rfc.constraint_name = con.r_constraint_name
AND    NOT EXISTS
       (SELECT NULL
       FROM    dba_ind_columns ind
       WHERE   ind.table_owner = con.owner
       AND     ind.table_name  = con.table_name
       AND     ind.column_name = col.column_name)
ORDER BY 1, 2
/