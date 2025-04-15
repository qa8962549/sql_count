-- 可以当做
CREATE VIEW ods_oper_crm.member_view AS
    SELECT id,member_name
    FROM ods_memb.ods_memb_tc_member_info_cur m
    where is_deleted=1
    
   select *
   from ods_oper_crm.member_view 
   
SHOW CREATE TABLE ods_oper_crm.member_view

SELECT name, database, engine
FROM system.tables
WHERE engine = 'View';

DROP VIEW IF EXISTS ods_oper_crm.member_view