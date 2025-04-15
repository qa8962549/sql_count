-- 2021年11月20日~2022年5月19日公众号取关人群数量
SELECT 
count(DISTINCT eco.id)
from volvo_wechat_live.es_car_owners eco 
where eco.subscribe_status =0 -- 取关
and eco.unsubscribe_time >='2021-11-20'
and eco.unsubscribe_time <='2022-5-19 23:59:59'
order by eco.unsubscribe_time desc 

-- 根据注册时间（YYYY-MM）进行汇总
SELECT 
DATE_FORMAT(IFNULL(eco.subscribe_time,eco.create_time),'%Y-%m') 注册时间,
count(DISTINCT eco.id) 人数
from volvo_wechat_live.es_car_owners eco 
where eco.subscribe_status =0 -- 取关
and eco.unsubscribe_time >='2021-11-20'
and eco.unsubscribe_time <='2022-5-19 23:59:59'
group by 1
order by 注册时间 desc 
 
-- 根据取关时间（YYYY-MM）进行汇总
SELECT 
DATE_FORMAT(eco.unsubscribe_time,'%Y-%m') 取关时间,
count(DISTINCT eco.id) 人数
from volvo_wechat_live.es_car_owners eco 
where eco.subscribe_status =0 -- 取关
and eco.unsubscribe_time >='2021-11-20'
and eco.unsubscribe_time <='2022-5-19 23:59:59'
group by 1
order by 取关时间 desc 

-- 根据根据留存时间（按天）进行汇总
SELECT 
TO_DAYS(eco.unsubscribe_time) - TO_DAYS(IFNULL(eco.subscribe_time,eco.create_time)) 关注天数,
count(DISTINCT eco.id) 人数
from volvo_wechat_live.es_car_owners eco 
where eco.subscribe_status =0 -- 取关
and eco.unsubscribe_time >='2021-11-20'
and eco.unsubscribe_time <='2022-5-19 23:59:59'
group by 1
order by 关注天数
