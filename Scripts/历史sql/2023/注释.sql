select *
from `order`.tt_order
limit 10

select *
from member.tt_member_get_record
limit 10

-- 拉取注释

select 
-- 这里是表描述,原本新建数据库的时候没有添加表描述,查询出来会为空,注释掉就好,有表描述的放开这条注释
-- cast(obj_description(relfilenode,'pg_class') as varchar) AS "表名描述",
a.attname AS "列名",
concat_ws('',t.typname,SUBSTRING(format_type(a.atttypid,a.atttypmod) from '\(.*\)')) as "字段类型",
d.description AS "备注"
from pg_class c, pg_attribute a , pg_type t, pg_description d 
--cyx_appointment.tt_appointment 
-- 这里是你的表名
where  c.relname = 'tt_appointment'
and a.attnum>0 
and a.attrelid = c.oid 
and a.atttypid = t.oid 
and  d.objoid=a.attrelid
and d.objsubid=a.attnum
ORDER BY c.relname DESC,a.attnum asc

select *
from pg_class c, pg_attribute a , pg_type t, pg_description d 
