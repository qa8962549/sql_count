-- 未活跃用户APP/mini
SELECT 
case when a.level_id = 1 then '普卡会员' else '等级会员' end lid,
ifnull(count(distinct case when a.is_vehicle=1 then distinct_id end),0) `车主`,
ifnull(count(distinct case when a.is_vehicle=0 then distinct_id end),0) `粉丝`
from
(-- App用户的最近访问时间
	select distinct_id,
	m.level_id,
	m.is_vehicle,
	max(a.time) mt
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
	where 1=1
	and (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	and distinct_id not like '%#%'
	and length(distinct_id)<9
	group by distinct_id,level_id,is_vehicle
	having mt <toDate('2023-01-01')+ interval '-30 day'-- 沉睡用户：截止目前超过30天未活跃,但在60天内活跃
	and mt >=toDate('2023-01-01')+ interval '-60 day'  -- 
)a
group by lid
order by lid


-- 未活跃用户Mini track
SELECT 
case when a.level_id = 1 then '普卡会员' else '等级会员' end lid,
count(distinct case when a.is_vehicle=1 then a.cust_id end) `车主`,
count(distinct case when a.is_vehicle=0 then a.cust_id end) `粉丝`
from
(
	select m.cust_id,
	m.level_id,
	m.is_vehicle,
	max(DATE_FORMAT(t.date,'%Y-%m-%d')) mt
	from track.track t 
	join member.tc_member_info m on CAST(m.user_id AS varchar)=t.usertag
	where t.date>m.create_time 
	group by 1
	having mt<'2022-01-01'::date - interval '30 day'-- 沉睡用户：截止目前超过30天未活跃
	and  mt>='2022-01-01'::date - interval '60 day'
)a
group by lid
order by lid

------------------------------------------ --------------------------------------------
-- App各等级会员月平均活跃天数
SELECT 
date_trunc('month',a.date) t,
count( case when a.level_id=1 then distinct_id end)/count(distinct case when a.level_id=1 then distinct_id end) `普卡会员`,
count( case when a.level_id=2 then distinct_id end)/count(distinct case when a.level_id=2 then distinct_id end) `银卡会员`,
count( case when a.level_id=3 then distinct_id end)/count(distinct case when a.level_id=3 then distinct_id end) `金卡会员`,
count( case when a.level_id=4 then distinct_id end)/count(distinct case when a.level_id=4 then distinct_id end) `黑卡会员`
from
(-- App访问时间
	select distinct distinct_id,
	m.level_id,
	m.is_vehicle,
	date
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
	where (($lib in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and date >= '2023-07-01' -- App开始使用
	and date < '2024-01-01'
	and distinct_id not like '%#%'
	and length(distinct_id)<9
)a
group by t
order by t

-- 未活跃用户Mini event
SELECT 
date_trunc('month',a.date) t,
count( case when a.level_id=1 then distinct_id end)/count(distinct case when a.level_id=1 then distinct_id end) `普卡会员`,
count( case when a.level_id=2 then distinct_id end)/count(distinct case when a.level_id=2 then distinct_id end) `银卡会员`,
count( case when a.level_id=3 then distinct_id end)/count(distinct case when a.level_id=3 then distinct_id end) `金卡会员`,
count( case when a.level_id=4 then distinct_id end)/count(distinct case when a.level_id=4 then distinct_id end) `黑卡会员`
from
(-- App访问时间
	select distinct distinct_id,
	m.level_id,
	m.is_vehicle,
	date
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
	where 1=1
	and ($lib='MiniProgram' or channel='Mini') -- Mini
	and a.`time` >= '2023-12-01' 
	and a.`time` < '2023-12-18'
	and distinct_id not like '%#%'
	and length(distinct_id)<9
)a
group by t
order by t

-- 未活跃用户Mini track
SELECT 
DATE_FORMAT(a.t,'%Y-%m') tt,
count( case when a.level_id=1 then a.id end)/count(distinct case when a.level_id=1 then a.id end) `普卡会员`,
count( case when a.level_id=2 then a.id end)/count(distinct case when a.level_id=2 then a.id end) `银卡会员`,
count( case when a.level_id=3 then a.id end)/count(distinct case when a.level_id=3 then a.id end) `金卡会员`,
count( case when a.level_id=4 then a.id end)/count(distinct case when a.level_id=4 then a.id end) `黑卡会员`
from
(
	select distinct m.id,
	m.level_id,
	m.is_vehicle,
	DATE_FORMAT(t.date,'%Y-%m-%d') t
	from track.track t 
	join member.tc_member_info m on CAST(m.user_id AS varchar)=t.usertag
	where t.date>m.create_time 
	and t.date >= '2022-01-01' 
	and t.date <'2023-12-01'
)a
group by tt
order by tt

