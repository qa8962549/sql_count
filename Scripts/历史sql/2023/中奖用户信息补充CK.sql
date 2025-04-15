-- 7月-8月登录天数
select a.distinct_id,count(distinct date)
from ods_rawd_events_d_di a
where a.`date` >='2023-07-01'
and a.`date` <'2023-09-01'
and LENGTH(a.distinct_id)<=9
group by distinct_id

-- 