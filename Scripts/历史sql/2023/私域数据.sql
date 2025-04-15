select o.time,o.date,toDate(o.time)
 FROM ods_rawd.ods_rawd_events_d_di o
limit 10

-- 1、总注册数
SELECT 
toDate(o.time) tt,
count(DISTINCT o.distinct_id)
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and o.time< '2023-05-17'
and length(o.distinct_id) > 9
group by tt

--游客（当天未注册）
select sum(x.xx)/90
from 
	(
	select a.tt
	,a.xx xx1
	,b.xx xx2
	,a.xx-b.xx xx -- 当天未注册
	from 
		(
		-- 当天所有游客
		SELECT 
		toDate(o.time) tt,
		count(DISTINCT o.user_id ) xx
		FROM ods_rawd.ods_rawd_events_d_di o
		WHERE o.`$app_version` >= '5.0'
		and o.`$lib` in ('iOS','Android')
		and o.time< '2023-05-17'
		and o.time>= '2023-02-01'
		and `$is_first_day` =1
		and length(o.distinct_id) > 9
		group by tt)a
	left join 
		(
		-- 当天注册会员
		SELECT 
			toDate(o.time) tt,
			count(DISTINCT o.user_id) xx
			FROM ods_rawd.ods_rawd_events_d_di o
			WHERE o.`$app_version` >= '5.0'
			and o.`$lib` in ('iOS','Android')
			and o.time< '2023-05-17'
			and o.time>= '2023-02-01'
			and length(o.distinct_id) < 9
			and `$is_first_day` =1
			group by tt)b on a.tt=b.tt
)x

-- 2、车主数




-- 3、近三个月平均日活总数

select avg(a.count_dis) -- 平均
FROM (
	SELECT 
	Date(o.`time`),count(DISTINCT o.distinct_id) count_dis
	FROM ods_rawd.ods_rawd_events_d_di o
	WHERE o.`$app_version` >= '5.0'
	and o.`$lib` in ('iOS','Android')
	and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
	GROUP by date(o.`time`)
	) a 
	
	
-- 4、近三个月平均日活会员
select avg(a.count_dis)
FROM (
SELECT 
Date(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) < 9
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by date(o.`time`)) a 



-- 近3个月平均日活车主
select avg(a.count_dis)
FROM (
SELECT 
Date(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) < 9
and o.is_bind = 1 -- 车主
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by date(o.`time`)) a 



-- 近3个月平均日活粉丝
select avg(a.count_dis)
FROM (
SELECT 
Date(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) < 9
and o.is_bind = 0 -- 粉丝
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by date(o.`time`)) a 



-- 游客当天未注册

select avg(a.count_dis)
FROM (
SELECT 
Date(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) > 9
and o.is_has_oneid_when_happen = '否'
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by date(o.`time`)) a 




-- 近三个月月活 
select avg(a.count_dis) -- 平均
FROM (
	SELECT 
	MONTH(o.`time`),count(DISTINCT o.distinct_id) count_dis
	FROM ods_rawd.ods_rawd_events_d_di o
	WHERE o.`$app_version` >= '5.0'
	and o.`$lib` in ('iOS','Android')
	and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
	GROUP by MONTH (o.`time`)
	) a 
	
-- 4、近三个月平均月活会员
select avg(a.count_dis)
FROM (
SELECT 
MONTH(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) < 9
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by MONTH(o.`time`)) a 


-- 近3个月平均月活车主
select avg(a.count_dis)
FROM (
SELECT 
MONTH(o.`time`),count(DISTINCT o.distinct_id) count_dis
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and length(o.distinct_id) < 9
and o.is_bind = 1 -- 车主
and o.time BETWEEN  '2023-02-01' and '2023-04-30 23:59:59'
GROUP by MONTH(o.`time`)) a 

-- 游客每日浏览人数
SELECT 
o.day,o.date,o.user_id
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and o.time< '2023-05-17'
and o.`time`>= '2022-06-01'
and length(o.distinct_id) > 9
GROUP by o.day,o.date,o.user_id

-- 游客历史最早浏览天数
SELECT 
o.user_id,min(o.day)
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and o.time< '2023-05-17'
and o.`time`>= '2022-06-01'
and length(o.distinct_id) > 9
GROUP by o.user_id

--游客（当天注册）
	select a.tt
	,a.xx "当天所有游客"
	,b.xx "当天注册会员"
	,b.xx/a.xx xx -- 当天游客注册/所有游客
	from 
		(
		-- 当天所有游客
		SELECT 
		toDate(o.time) tt,
		count(DISTINCT o.user_id ) xx
		FROM ods_rawd.ods_rawd_events_d_di o
		WHERE o.`$app_version` >= '5.0'
--		and (o.`$lib` in ('iOS','Android') or channel='App')
		and o.time< '2023-05-17'
		and o.time>= '2022-03-30'
		and length(o.distinct_id) > 9-- 游客
		group by tt)a
	left join 
		(
		-- 当天注册会员
		SELECT 
			toDate(o.time) tt,
			count(DISTINCT o.distinct_id) xx
			FROM ods_rawd.ods_rawd_events_d_di o
			WHERE o.`$app_version` >= '5.0'
--			and (o.`$lib` in ('iOS','Android') or channel='App')
			and o.time< '2023-05-17'
			and o.time>= '2022-03-30'
			and length(o.distinct_id) < 9 -- 会员
			and is_has_oneid_when_happen='是'
			group by tt)b on a.tt=b.tt


	select a.tt
	,a.xx xx1
	,b.xx xx2
	,b.xx/a.xx xx -- 当天游客注册/所有游客
	from 
		(
		-- 当天所有游客
		SELECT 
--		toYYYYMM(toDate(o.time)) tt,
		toDate(o.time) tt,
		count(DISTINCT o.user_id ) xx
		FROM ods_rawd.ods_rawd_events_d_di o
		WHERE o.`$app_version` >= '5.0'
		and (o.`$lib` in ('iOS','Android') or channel='App')
		and o.time< '2023-05-17'
		and o.time>= '2022-06-01'
--		and `$is_first_day` =1
		and length(o.distinct_id) > 9-- 游客
		group by tt)a
	left join 
		(
		-- 注册会员
		SELECT 
--			toYYYYMM(toDate(o.time)) tt,
			toDate(o.time) tt,
			count(DISTINCT o.distinct_id) xx
			FROM ods_rawd.ods_rawd_events_d_di o
			WHERE o.`$app_version` >= '5.0'
			and (o.`$lib` in ('iOS','Android') or channel='App')
			and o.time< '2023-05-17'
			and o.time>= '2022-06-01'
			and length(o.distinct_id) < 9 -- 会员
			and `$is_first_day` =1
			group by tt)b on a.tt=b.tt
		order by a.tt


SELECT 
count(o.user_id)
FROM ods_rawd.ods_rawd_events_d_di o
WHERE o.`$app_version` >= '5.0'
and o.`$lib` in ('iOS','Android')
and o.time< '2023-05-17'
and o.`time`>= '2022-03-30'
and length(o.distinct_id) < 9
-- and o.event = '$AppStart'
GROUP by o.distinct_id,o.user_id
		