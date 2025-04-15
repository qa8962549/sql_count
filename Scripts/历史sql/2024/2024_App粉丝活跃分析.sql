-- 新增用户 App粉丝注册数
select 
date_trunc('month',min_app_time) t,
count(distinct_id) `App粉丝注册数`
from ads_crm.ads_crm_events_member_d m 
where 1=1
and is_owner <>1 -- 筛选当下身份为粉丝
and min_app_time is not null -- 筛选APP用户
and min_app_time<'2024-01-01'
group by t
order by t 


--App粉丝DAU均值
select date_trunc('month',x.t) t,
floor(AVG(x.DAU),0) `App粉丝DAU均值`
from 
	(
	-- 日活
	select 
	date_trunc('day',m.date) t,
	count(distinct m.distinct_id) DAU
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	and m.date <'2024-01-01'
	group by t
)x
group by t
order by t 

-- App粉丝MAU
	select 
	date_trunc('month',m.date) t,
	count(distinct m.distinct_id) DAU
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	and m.date <'2024-01-01'
	group by t
	order by t 
	
--App粉丝当月人均活跃天数
select date_trunc('month',x.t) t,
floor(AVG(x.DAU),1) `App粉丝当月人均活跃天数`
from 
	(
	-- 日活
	select 
	date_trunc('month',m.date) t,
	distinct_id id,
	count(distinct m.date) DAU
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	and m.date <'2024-01-01'
	group by t,id
	order by t
)x
group by t
order by t 

--App粉丝次月留存率
select 
date_trunc('month',m.date) t,
count(distinct m.distinct_id) ,
count(distinct x.distinct_id) ,
floor(count(distinct x.distinct_id)/count(distinct m.distinct_id),3) `App粉丝次月留存率`
from ads_crm.ads_crm_events_active_d m
join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
left join (
-- 次月活跃用户
	select 
	distinct m.distinct_id,m.date
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	)x on m.distinct_id =x.distinct_id and date_trunc('month',x.date)=date_trunc('month',m.date) +interval'1 month'
where 1=1
and m2.is_owner <>1 -- 筛选当下身份为粉丝
and m.channel='App' -- 筛选APP用户 
group by t
order by t 

-- 次月留存率 单月计算
select 
date_trunc('month',m.date) t,
count(distinct m.distinct_id) ,
count(distinct x.distinct_id) ,
floor(count(distinct x.distinct_id)/count(distinct m.distinct_id),2) `App粉丝次月留存率`
from ads_crm.ads_crm_events_active_d m
join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
left join (
-- 次月活跃用户
	select 
	distinct m.distinct_id
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	and m.date >='2022-05-01' 
	and m.date <'2022-06-01' 
	)x on m.distinct_id =x.distinct_id
where 1=1
and m2.is_owner <>1 -- 筛选当下身份为粉丝
and m.channel='App' -- 筛选APP用户
and m.date >='2022-04-01' 
and m.date <'2022-05-01' 
group by t
order by t 

-- 累计活跃了N个月的人数
select x.t t,
count(distinct x.distinct_id) num 
from 
(
-- 每个用户活跃月份累计数
	select 
	m.distinct_id,
	count(distinct date_trunc('month',m.date)) t
	from ads_crm.ads_crm_events_active_d m
	join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
	where 1=1
	and m2.is_owner <>1 -- 筛选当下身份为粉丝
	and m.channel='App' -- 筛选APP用户
	and m.date <'2024-01-01'
	and m.date >='2023-01-01'
	group by distinct_id
	order by t desc 
)x
group by t 
order by t 