--App签到 日 -- 小程序无法签到，因此不用特意筛选app用户
select 	
date(a.create_time) dt,
COUNT(distinct case when b.is_vehicle =1 then a.member_id else null end) `车主`,
COUNT(distinct case when b.is_vehicle=0 then a.member_id else null end) `粉丝`
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
WHERE 1=1
and a.create_time >= '2024-11-25' 
and a.create_time < today()
and a.is_deleted = '0'
group by 1 
order by 1 
--settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

--App签到 周
select 	
--date(a.create_time) dt,
COUNT(distinct case when b.is_vehicle=1 then a.member_id else null end) `车主人数`,
COUNT(case when b.is_vehicle=1 then a.member_id else null end) `车主次数`,
COUNT(distinct case when b.is_vehicle=0 then a.member_id else null end) `粉丝人数`,
COUNT(case when b.is_vehicle=0 then a.member_id else null end) `粉丝次数`
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
WHERE 1=1
and a.create_time >= '2025-01-20' 
and a.create_time < '2025-01-27' 
and a.is_deleted = '0'
--group by 1 
--order by 1 
--settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

--App签到 月
select 	
month(a.create_time) dt,
COUNT(distinct case when b.is_vehicle=1 then a.member_id else null end) `车主人数`,
COUNT(case when b.is_vehicle=1 then a.member_id else null end) `车主次数`,
COUNT(distinct case when b.is_vehicle=0 then a.member_id else null end) `粉丝人数`,
COUNT(case when b.is_vehicle=0 then a.member_id else null end) `粉丝次数`
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
WHERE 1=1
and a.create_time >= '2024-01-01' 
and a.create_time <'2025-01-01' 
and a.is_deleted = '0'
group by 1 
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0



-- 签到抽奖机会
	select 	
	toDate(a.create_time) t,
	COUNT(distinct case when b.is_vehicle=1 and activity_code='sign-in-7' then member_id else null end) `获得7天抽奖机会车主`,
	COUNT(distinct case when b.is_vehicle=0 and activity_code='sign-in-7' then member_id else null end) `获得7天抽奖机会粉丝`,
	COUNT(distinct case when b.is_vehicle=1 and activity_code='sign-in-30' then member_id else null end) `获得30天抽奖机会车主`,
	COUNT(distinct case when b.is_vehicle=0 and activity_code='sign-in-30' then member_id else null end) `获得30天抽奖机会粉丝`
	from ods_voam.ods_voam_lottery_chance_d a 
	left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
	where activity_code in ('sign-in-7','sign-in-30')
	and a.create_time>='2024-12-17'
	and a.create_time< today()
	and a.is_deleted=0
	group by 1 
	order by 1
	
	
	
--已使用7天/30天抽奖机会车主/粉丝
select 
toDate(a.create_time) t,
COUNT(distinct case when b.is_vehicle=1 and lottery_code='sign-in-7' then a.member_id else null end) `已使用7天抽奖机会车主`,
COUNT(distinct case when b.is_vehicle=0 and lottery_code='sign-in-7' then a.member_id else null end) `已使用7天抽奖机会粉丝`,
COUNT(distinct case when b.is_vehicle=1 and lottery_code='sign-in-30' then a.member_id else null end) `已使用30天抽奖机会车主`,
COUNT(distinct case when b.is_vehicle=0 and lottery_code='sign-in-30' then a.member_id else null end) `已使用30天抽奖机会粉丝`
from ods_voam.ods_voam_lottery_draw_log_d a
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
where 1=1
and a.create_time>='2024-12-17'
and a.create_time< today()
and lottery_code in ('sign-in-7','sign-in-30')-- 连续签到7天奖池  sign-in-7-1  连续签到30天奖池  sign-in-30-1
group by 1 
order by 1 


--流失人数 车主粉丝 定义：指上个月（M-1）至少完成过一次签到，但在本月（M）未进行任何签到的用户数量。仅统计曾有签到行为的用户，不包括从未签到的用户。
select 
COUNT(distinct case when b.is_vehicle=1 then a.member_id else null end) `车主人数`,
COUNT(distinct case when b.is_vehicle=0 then a.member_id else null end) `粉丝人数`
FROM (--上月签到用户id
	select distinct member_id member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= toDate('2024-12-01') - INTERVAL '1 month'
	and a.create_time <toDate('2025-01-01') - INTERVAL '1 month'
	and a.is_deleted = '0'
	)a
left join (
--	本月签到用户id
	select distinct member_id member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2024-12-01' 
	and a.create_time <'2025-01-01' 
	and a.is_deleted = '0'
	)a2 on a2.member_id=a.member_id
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
WHERE 1=1
--and a2.member_id is null -- 本月未签到用户
and length(a2.member_id)<1
--settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

--新增人数 定义：指上个月（M-1）未进行任何签到（签到次数为0），但本月（M）完成过至少一次签到的用户数量。
select 
COUNT(distinct case when b.is_vehicle=1 then a.member_id else null end) `车主人数`,
COUNT(distinct case when b.is_vehicle=0 then a.member_id else null end) `粉丝人数`
FROM (
--	本月签到用户id
	select distinct member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2024-12-01' 
	and a.create_time <'2025-01-01' 
	and a.is_deleted = '0'
	)a
left join (
--上月签到用户id
	select distinct member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= toDate('2024-12-01') - INTERVAL '1 month'
	and a.create_time <toDate('2025-01-01') - INTERVAL '1 month'
	and a.is_deleted = '0'
	)a2 on a2.member_id=a.member_id
left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
WHERE 1=1
and a2.member_id is null -- 筛选上月未签到用户
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0




--2024年签到过车主用户
	select b.member_name `用户昵称`,
	a.member_id `用户ID`,
	count(distinct toDate(a.create_time)) `2024年累计签到天数`
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
	WHERE 1=1
	and a.create_time >= '2024-01-01'
	and a.create_time <'2025-02-01'
	and a.is_deleted = '0'
	AND b.is_vehicle=1 -- 车主
	group by 1,2
	order by 3 desc 
	
--2025年签到过车主用户
	select b.member_name `用户昵称`,
	a.member_id `用户ID`,
	count(distinct toDate(a.create_time)) `2025年累计签到天数`
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	left join ods_memb.ods_memb_tc_member_info_cur b on a.member_id= b.id::String
	WHERE 1=1
	and a.create_time >= '2025-02-01'
	and a.create_time <'2025-01-08'
	and a.is_deleted = '0'
	AND b.is_vehicle=1
	group by 1,2
	order by 3 desc 

--# %%-------------------------------------【sheet12】签到数据----------------------------------------
	
--#累计连续签到
SELECT '01 累计',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	GROUP by 1) c
group by 1
UNION all 
SELECT '02 7天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 7   -- 连续7天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '03 14天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 14   -- 连续14天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '04 21天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 21   -- 连续21天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '05 30天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 30   -- 连续30天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '06 50天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 50   -- 连续50天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '07 100天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 100   -- 连续100天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '08 200天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 200   -- 连续200天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '09 300天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 300   -- 连续300天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '10 400天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 400   -- 连续400天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '11 500天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 500   -- 连续500天以上
	GROUP by 1) c
group by 1
UNION all 
SELECT '12 600天以上',
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days)
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0
	and a.sign_in_days >= 600   -- 连续600天以上
	GROUP by 1) c
group by 1
order by 1 





#满签人数

-- 满签90
select '9'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>= 0.9*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all
-- 满签80
select '8'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.8*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a 
union all 
-- 满签70
select '7'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.7*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all 
-- 满签60
select '6'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.6*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all 
-- 满签50
select '5'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.5*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all 
-- 满签40
select '4'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.4*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all
-- 满签30
select '3'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.3*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all 
-- 满签20
select '2'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.2*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
union all 
-- 满签10
select '1'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mms.tt_sign_in_record i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_deleted=0 and i.create_time >='2023-01-12' and i.create_time <= date(now())
) a GROUP BY 1,2 
HAVING count(1)>=0.1*DATEDIFF(date(now()),'2023-01-12')+1
order by 2 desc 
) a  
order by 1 desc 




SELECT 
	c.月份,
	count(c.member_id) 总计,
	COUNT(case when c.is_vehicle=1 then 1 else null end) 车主,
	COUNT(case when c.is_vehicle=0 then 1 else null end) 粉丝
from (
	SELECT  DATE_FORMAT(d.create_time,'%Y-%m')月份,  d.member_id,d.is_vehicle,d.连续签到,COUNT(*) 
	from (
		SELECT c.*,c.date_ - c.qd_rank 连续签到
		FROM(
				select a.member_id,
				b.IS_VEHICLE,
				a.create_time,
				ROW_NUMBER() over(PARTITION by a.member_id ORDER by a.create_time) qd_rank,
				DATE(a.create_time)-'1999-01-01' date_
				FROM mms.tt_sign_in_record a  -- 签到表
				left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
				WHERE a.create_time BETWEEN '2023-01-12' and date(now())  -- 每月的时间
				and a.is_deleted = 0) c )d 
group by 1,2,3,4
HAVING count(*) >=7) c  -- 更改时间
group by 1
order by 1



#连续签到天数
sql6 = f"""select m.max_sign_day,
count(DISTINCT m.member_id) 总用户数,
count(case when m.is_vehicle=1 then 1 else null end) 车主,
count(case when m.is_vehicle=0 then 1 else null end) 粉丝
from (
select a.member_id , b.IS_VEHICLE, max(a.sign_in_days) max_sign_day
FROM mms.tt_sign_in_record a  -- 签到表
left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
WHERE a.create_time between '2023-01-12' and date(now())
and a.is_deleted = 0
GROUP by 1) m 
group by 1
order by 1 """
df6_lianxvqiandaotianshu = sql_to_df(sql6)


#累计签到天数
sql7 = f"""select c.day_, count(DISTINCT c.member_id) 总,
		count(DISTINCT c.车主) 车主数,
		count(DISTINCT c.粉丝) 粉丝数
from(
select c.member_id, c.is_vehicle, max(c.rk) day_ ,
	 case when c.is_vehicle=1 then c.member_id else null end 车主,
	 case when c.is_vehicle=0 then c.member_id else null end 粉丝
from(
	select a.member_id , b.IS_VEHICLE, ROW_NUMBER() over(PARTITION by a.member_id order by a.create_time desc) rk
	FROM mms.tt_sign_in_record a  -- 签到表
	left join `member`.tc_member_info b on a.member_id = b.ID and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.create_time between '2023-01-12' and date(now())
	and a.is_deleted = 0) c
GROUP by 1) c
group by 1
order by 1 """
df7_leijiqiandaotianshu = sql_to_df(sql7)


print('签到数据 sql完成')
