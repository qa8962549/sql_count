-- 每月小程序新用户  member表是app和小程序所用用户的集合
select
date_format(tmi.create_time,'%Y-%m')
,count(distinct cust_id)
from "member".tc_member_info tmi 
where tmi.create_time >='2023-12-01'
and tmi.create_time <'2024-01-01'
and tmi.is_deleted = 0 
and tmi.member_status <> '60341003'
group by 1
order by 1

-- 小程序新用户 总
select
count(distinct cust_id)
from "member".tc_member_info tmi 
where tmi.create_time >='2023-01-01'
and tmi.create_time <'2023-12-01'
and tmi.is_deleted = 0 and tmi.member_status <> '60341003'


