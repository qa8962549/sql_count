-- created by curlyan
-- create time 2022-06-09
-- 沃世界签到2.0活动

## 签到人数活跃比例
-- 当日签到人数
select DATE(i.create_time) adate
,count(DISTINCT i.member_id) 签到人数
-- ,count(DISTINCT case when m.IS_VEHICLE=1 then i.member_id else null end) 当日签到车主
-- ,count(DISTINCT case when m.IS_VEHICLE=0 then i.member_id else null end) 当日签到粉丝
from mine.sign_info i 
left join member.tc_member_info m on i.member_id=m.ID
where i.is_delete=0
and i.create_time >='2023-01-01' 
and i.create_time <='2023-12-31 23:59:59'
GROUP BY 1　order by 1 

-- 小程序活跃用户数
SELECT DATE_FORMAT(t.date,'%Y-%m-%d'),
count(DISTINCT tmi.id) 数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE t.date between '2023-01-01' AND '2023-12-31 23:59:59'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
    AND t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
GROUP BY 1 -- with rollup
order by 1

----------------------------------------------------------------------------------------------------------------------------------------------------
## 月报 签到人数活跃比例 

-- 小程序活跃用户数
SELECT 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
count(DISTINCT tmi.id) 数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE t.date between '2023-01-01' AND '2023-12-31 23:59:59'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
    AND t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
-- GROUP BY 1 -- with rollup
-- order by 1

-- 当月累计签到人数
select DATE(a.mdate)
,max(a.rk) '8月累计签到人数'
-- ,max(a.rk1) 8月车主累计签到人数
-- ,max(a.rk2)  8月粉丝累计签到人数 
from (
	select i.member_id,m.is_vehicle,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	left join member.tc_member_info m on i.member_id=m.id
	where i.is_delete=0 
	and i.create_time >='2023-01-01' and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2
	order by 2,3,5 
) a 
GROUP BY 1 
order by 1 desc
limit 1

----------------------------------------------------------------------------------------------------------------------------------------------------;
######################### 数据统计sheet
累计签到人数在sheet活动数据明细表

--  累计签到人数
select DATE(a.mdate) tt
,max(a.rk)
,max(a.rk1) 车主累计签到人数
,max(a.rk2)  粉丝累计签到人数 
from (
	select i.member_id
	,m.is_vehicle
	,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	join member.tc_member_info m on i.member_id=m.id -- and m.IS_DELETED =0 and m.STATUS <>60341003
	where i.is_delete=0  
	and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2
	order by 2,3,5 
) a 
GROUP BY 1 with ROLLUP 
order by 1 desc
limit 1

select x.member_id,
max(num)
from 
	(
	select x.member_id,
	x.tt,
	count(1) num 
	from 
	(
	select x.member_id,
	x.t,
	x.t - interval '1 day' * x.rk tt
	from 
		(
		select i.member_id,
		to_date(i.create_time) t,
		row_number()over(partition by i.member_id order by i.create_time) rk
		from mine.sign_info i
		order by create_time desc)x
	)x group by 1,2
)x group by 1
order by 2 desc 

--#连续签到7天及以上人数
select 7
,count(1) 
,count(case when m.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when m.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
--			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2023-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=7 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id
union all 
#连续签到14天及以上
select 14
,count(1) 
,count(case when m.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when m.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2023-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=14 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id 
union all
#连续签到21天及以上
select 21
,count(1) 
,count(case when m.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when m.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2023-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=21 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id 
union all 
#连续签到30天及以上
select 30
,count(1) 
,count(case when m.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when m.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2023-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=30 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id 
order by 1


# 满签90
select '9'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>= 0.9*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all
# 满签80
select '8'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.8*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a 
union all 
# 满签70
select '7'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.7*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all 
# 满签60
select '6'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.6*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all 
# 满签50
select '5'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.5*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all 
# 满签40
select '4'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.4*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all
# 满签30
select '3'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.3*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all 
# 满签20
select '2'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.2*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
union all 
# 满签10
select '1'
,count(1)
,count(case when a.IS_VEHICLE=1 then 1 else null end ) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end ) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=0.1*DATEDIFF('2023-12-31 23:59:59','2022-01-10')+1
order by 2 desc 
) a  
order by 1 desc 


#本月连续签到7天及以上人数
select count(1) 
,count(case when m.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when m.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select d.member_id,max(d.次数) 连续签到次数
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time >= '2023-01-01' and i.create_time <= '2023-12-31 23:59:59'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=7 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id  


# 11月累计签到20天及以上人数
select count(1)
,count(case when a.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when a.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 and i.create_time >='2023-01-01' and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=20
order by 2 desc 
) a

# 累计签到100天去重
select 100
,count(1)
,count(case when a.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when a.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=100
order by 2 desc 
) a 
union all 
# 累计签到200天去重
select 200
,count(1)
,count(case when a.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when a.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=200
order by 2 desc 
) a 
union all 
# 累计签到300天去重
select 300
,count(1)
,count(case when a.is_vehicle=1 then a.member_id else null end) 车主数
,count(case when a.is_vehicle=0 then a.member_id else null end) 粉丝数
from (
select a.MEMBER_ID,a.IS_VEHICLE,count(1)
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1,2 
HAVING count(1)>=300
order by 2 desc 
) a 
order by 1

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 活动引流情况

# 累计拉新数
select 1
,count(a.id)
from (
select DISTINCT m.id
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle=0 and m.is_deleted=0 and m.member_status<>60341003
where t.date >= '2023-01-01' and t.date <= '2023-12-31 23:59:59'
and json_extract(t.`data`,'$.pageId')='8BKmcX95gK' 
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
union
select DISTINCT m.id
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle=0 and m.is_deleted=0 and m.member_status<>60341003
where t.date >= '2023-01-01' and t.date <= '2023-12-31 23:59:59'
and json_extract(t.`data`,'$.pageId')='FvqSGa7DjD' 
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
union 
select DISTINCT m.id
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle=0 and m.is_deleted=0 and m.member_status<>60341003
where t.date >= '2023-01-01' and t.date <= '2023-12-31 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
) a 
union all 
-- 僵尸粉-track表计算
select 2,
count(DISTINCT a.usertag) sli
from(
	-- 获取访问文章活动10分钟之前的最晚访问时间
	select t.usertag,b.mdate,max(t.date) tdate
	from track.track t
	join (
		-- 获取访问文章活动的最早时间
		select '8BKmcX95gK' page_id,t.usertag,min(t.date) mdate 
		from track.track t 
		join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
		where t.date >= '2023-01-01' and t.date <= '2023-12-31 23:59:59'
		and json_extract(t.data,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
		-- and t.data like '%C17A45F99091449696CA64A4CDC4104F%'
		GROUP BY 1,2
	) b on b.usertag=t.usertag
	where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
	GROUP BY 1,2
	union all 
	-- 获取访问文章活动10分钟之前的最晚访问时间
	select t.usertag,b.ldate,max(t.date) tdate
	from track.track t
	join (
		-- 获取访问文章活动的最早时间
		select ref_id,cast(l.user_id as varchar) user_id,min(date_create) ldate 
		from 'cms-center'.cms_operate_log l
		join member.tc_member_info m on l.user_id=m.user_id
		where l.date_create >= '2023-01-01' and l.date_create <= '2023-12-31 23:59:59'
		and l.ref_id in ('8BKmcX95gK','FvqSGa7DjD') 
		and l.type ='VIEW' 
		GROUP BY 1,2
	) b on b.user_id=t.usertag
	where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
	GROUP BY 1,2
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
union all 
# 小程序总召回人数
select 3
,count(DISTINCT t.usertag) -- t.*
from (
	select t1.usertag,t1.tdate,t1.min_date,t2.mdate
  from (
		select t.usertag,DATE(t.date) tdate,min(t.date) min_date
		from track.track t 
		where t.date >= '2023-01-01' and t.date <= '2023-12-31 23:59:59'
		group by 1,2 
	) t1
 left join (select t.usertag,max(t.date) mdate from track.track t where t.date<'2023-01-01' GROUP BY 1 )t2 on t1.usertag = t2.usertag
 group by 1,2,3
) t
where t.mdate < DATE_SUB(t.min_date,INTERVAL 30 DAY) 
order by 1


# 签到页&活动页PV,UV  注意UV去重
-- 签到页
select 
1,
count(1) 签到页总PV
from track.track t
-- join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.date>='2023-01-01' and t.date <= '2023-12-31 23:59:59'
and  json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
union all 
select
2,
count(DISTINCT t.usertag) 签到页总UV
from track.track t
-- join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
where t.date>='2023-01-01' and t.date <= '2023-12-31 23:59:59'
and  json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' 
order by 1

-- 长图文
select 
1,
count(1)
from 'cms-center'.cms_operate_log l
where l.date_create>='2023-01-01' and  l.date_create <= '2023-12-31 23:59:59'
and l.ref_id in ('8BKmcX95gK','FvqSGa7DjD') 
and l.type ='VIEW' 
union all 
select 
2,
count(DISTINCT l.user_id)
from 'cms-center'.cms_operate_log l
where l.date_create>='2023-01-01' and  l.date_create <= '2023-12-31 23:59:59'
and l.ref_id in ('8BKmcX95gK','FvqSGa7DjD') 
and l.type ='VIEW' 
order by 1

-- 月活跃用户活动参与率-粉丝  = 本月累计签到粉丝数量\沃世界总粉丝数量    58872        16214     1479308

-- 月活跃用户活动参与率-车主  = 本月累计签到车主数量\沃世界总车主数量    142,913      29710      1050283

#沃世界去重绑定车主数--g
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期
	,count(DISTINCT member_id) 绑定车主数
	from member.tc_member_vehicle v
	where v.IS_DELETED=0
	and v.create_time<CURDATE()
	GROUP BY 1
    union 
#小程序注册数--a
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 注册数
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.create_time <CURDATE()
	GROUP BY 1 

	
-- 当月累计签到人数
select DATE(a.mdate)
,max(a.rk1) 9月车主累计签到人数
,max(a.rk2)  9月粉丝累计签到人数 
from (
	select i.member_id,m.is_vehicle,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	left join member.tc_member_info m on i.member_id=m.id
	where i.is_delete=0 
	and i.create_time >='2023-01-01' and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2　order by 2,3,5 
) a GROUP BY 1 order by 1 desc
limit 1

--  累计签到人数
select DATE(a.mdate)
-- ,max(a.rk)
,max(a.rk1) 车主累计签到人数
,max(a.rk2)  粉丝累计签到人数 
from (
	select i.member_id
	,m.is_vehicle
	,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	join member.tc_member_info m on i.member_id=m.id -- and m.IS_DELETED =0 and m.STATUS <>60341003
	where i.is_delete=0  
	and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2　order by 2,3,5 
) a 
GROUP BY 1 with ROLLUP 
order by 1 desc 
limit 1








----------------------------------------------------------------------------------------------------------------------------------------------------;
### 页面数据明细


-- 活动PV&UV
select DATE(a.date)
,count(case when a.事件='01长图文' then a.usertag else null end) PV签到长图文
,count(case when a.事件='02弹窗' then a.usertag else null end) PV弹窗
,count(case when a.事件='03首页Banner' then a.usertag else null end) PV首页Banner
,count(case when a.事件='04沃的活动Banner' then a.usertag else null end) PV沃的活动Banner
,count(case when a.事件='05签到短信' then a.usertag else null end) PV签到短信
,count(case when a.事件='06公众号' then a.usertag else null end) PV公众号欢迎语
,count(DISTINCT case when a.事件='01长图文' then a.usertag else null end) UV签到长图文
,count(DISTINCT case when a.事件='02弹窗' then a.usertag else null end) UV弹窗
,count(DISTINCT case when a.事件='03首页Banner' then a.usertag else null end) UV首页Banner
,count(DISTINCT case when a.事件='04沃的活动Banner' then a.usertag else null end) UV沃的活动Banner
,count(DISTINCT case when a.事件='05签到短信' then a.usertag else null end) UV签到短信
,count(DISTINCT case when a.事件='06公众号' then a.usertag else null end) UV公众号欢迎语
from (
	SELECT 
	case when t.typeid='XWSJPC_CMSHOME_DETAILS_V' and json_extract(t.`data`,'$.pageId')='FvqSGa7DjD' then '01长图文'
			 when json_extract(t.`data`,'$.tcode')='113C710EA64640BBAF06199646C3248E' then '02弹窗'
			 when json_extract(t.`data`,'$.tcode')='3884BE945DED4F89A3B7E64186D56F8C' then '03首页Banner'
			 when json_extract(t.`data`,'$.tcode')='5736E873392343DF96D8C50953C1AD35' then '04沃的活动Banner'
			 when json_extract(t.`data`,'$.tcode')='6CFC07A9EF374EB489ACA1AE9EFF1CBA' then '05签到短信'
			 when json_extract(t.`data`,'$.tcode')='4E609567D39941BB9D26FCCA1B0729E0' then '06公众号'
	else null end 事件
	,t.usertag
	,t.date
	from track.track t 
	where t.date between '2023-01-01' and '2023-12-31 23:59:59'
) a 
where a.事件 is not null 
GROUP BY 1 order by 1 ;

-- 入口PV&UV
select DATE(a.date)
,count(case when a.事件='02入口' then a.usertag else null end) 01声量
,count(case when a.事件='01入口' then a.usertag else null end) 02声量
,count(case when a.事件='03入口' then a.usertag else null end) 03声量
,count(case when a.事件='04入口' then a.usertag else null end) 04声量
,count(case when a.事件='05签到图文引流入口' then a.usertag else null end) 05声量
,count(case when a.事件='06主页' then a.usertag else null end) 06声量
,count(DISTINCT case when a.事件='01入口' then a.usertag else null end) 01声量
,count(DISTINCT case when a.事件='02入口' then a.usertag else null end) 02声量
,count(DISTINCT case when a.事件='03入口' then a.usertag else null end) 03声量
,count(DISTINCT case when a.事件='04入口' then a.usertag else null end) 04声量
,count(DISTINCT case when a.事件='05签到图文引流入口' then a.usertag else null end) 05声量
,count(DISTINCT case when a.事件='06主页' then a.usertag else null end) 06声量
from (
	SELECT
	case when t.typeid='NEWBIE_HOME_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='快速入口_首页_点击：' and json_extract(t.`data`,'$.tcode') = 'FEC7DB302EAE4F4DB2A26CD9CC50F4F4' and json_extract(t.`data`,'$.type')='粉丝'  then '01入口'
			 when t.typeid='NEWBIE_HOME_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='快速入口_首页_点击：' and json_extract(t.`data`,'$.tcode') = 'FEC7DB302EAE4F4DB2A26CD9CC50F4F4' and json_extract(t.`data`,'$.type')='车主'  then '02入口'
			 when json_extract(t.`data`,'$.tcode')='693DC24C1A9948F1910D1F3B0ED8C2C8' and json_extract(t.`data`,'$.type')='车主' then '03入口'
			 when json_extract(t.`data`,'$.tcode')='D2A9451B741949E48AE2FB1F5AA59B39' and json_extract(t.`data`,'$.type')='粉丝' then '04入口'
			 when t.typeid='XWSJPC_CMSHOME_TPGG_C' and json_extract(t.`data`,'$.tcode')='CEF6F057E26F4059B4AEAF53F418483D' then '05签到图文引流入口'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_ONLOAD' then '06主页'
	else null end 事件
	,t.usertag
	,t.date
	from track.track t 
	where t.date between '2023-01-01' and '2023-12-31 23:59:59'
) a 
where a.事件 is not null 
GROUP BY 1 order by 1 

-- 页面PV&UV
select DATE(a.date)
,count(DISTINCT case when a.事件='01弹窗逛一逛' then a.usertag else null end) 01PV
,count(DISTINCT case when a.事件='02主页逛一逛' then a.usertag else null end) 02PV
,count(DISTINCT case when a.事件='03补签卡传送门' then a.usertag else null end) 03PV
,count(DISTINCT case when a.事件='04补签卡开心收下' then a.usertag else null end) 04PV
,count(DISTINCT case when a.事件='05补签卡立即兑换' then a.usertag else null end) 05PV
,count(DISTINCT case when a.事件='06补签卡立即使用' then a.usertag else null end) 06PV
,count(DISTINCT case when a.事件='07点击补字' then a.usertag else null end) 07PV
,count(DISTINCT case when a.事件='08完成任务立即抽奖' then a.usertag else null end) 08PV
,count(DISTINCT case when a.事件='09点击首页抽奖礼盒' then a.usertag else null end) 09PV
,count(DISTINCT case when a.事件='10一级奖池立即抽奖' then a.usertag else null end) 10PV
,count(DISTINCT case when a.事件='11二级到五级立即抽奖' then a.usertag else null end) 11PV
,count(DISTINCT case when a.事件='16点击开启订阅' then a.usertag else null end) 12PV
,count(DISTINCT case when a.事件='15点击服务消息提醒' then a.usertag else null end) 13PV
,count(DISTINCT case when a.事件='12查看中奖记录' then a.usertag else null end) 14PV
,count(DISTINCT case when a.事件='13查看活动规则' then a.usertag else null end) 15PV
,count(DISTINCT case when a.事件='14通告板块banner' then a.usertag else null end) 16PV
,count(case when a.事件='01弹窗逛一逛' then a.usertag else null end) 01UV
,count(case when a.事件='02主页逛一逛' then a.usertag else null end) 02UV
,count(case when a.事件='03补签卡传送门' then a.usertag else null end) 03UV
,count(case when a.事件='04补签卡开心收下' then a.usertag else null end) 04UV
,count(case when a.事件='05补签卡立即兑换' then a.usertag else null end) 05UV
,count(case when a.事件='06补签卡立即使用' then a.usertag else null end) 06UV
,count(case when a.事件='07点击补字' then a.usertag else null end) 07UV
,count(case when a.事件='08完成任务立即抽奖' then a.usertag else null end) 08UV
,count(case when a.事件='09点击首页抽奖礼盒' then a.usertag else null end) 09UV
,count(case when a.事件='10一级奖池立即抽奖' then a.usertag else null end) 10UV
,count(case when a.事件='11二级到五级立即抽奖' then a.usertag else null end) 11UV
,count(case when a.事件='16点击开启订阅' then a.usertag else null end) 12UV
,count(case when a.事件='15点击服务消息提醒' then a.usertag else null end) 13UV
,count(case when a.事件='12查看中奖记录' then a.usertag else null end) 14UV
,count(case when a.事件='13查看活动规则' then a.usertag else null end) 15UV
,count(case when a.事件='14通告板块banner' then a.usertag else null end) 16UV
from (
	SELECT 
	case when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页逛一逛_ONCLICK' and json_extract(t.`data`,'$.type')='modal' then '01弹窗逛一逛'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页逛一逛_ONCLICK' and json_extract(t.`data`,'$.type')='button' then '02主页逛一逛'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页去补签卡页面_ONCLICK' and json_extract(t.`data`,'$.type')='modal' then '03补签卡传送门'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页开心收下_ONCLICK' then '04补签卡开心收下'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_补签卡页面点击立即兑换_ONCLICK' then '05补签卡立即兑换'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_补签卡页面点击立即使用_ONCLICK' then '06补签卡立即使用'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页去补签卡页面_ONCLICK' and json_extract(t.`data`,'$.type')='icon' then '07点击补字'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_FANHUIQIANDAO' then '08完成任务立即抽奖'
			 when (json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页点击礼盒没次数_ONCLICK' 
					or json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页点击礼盒有次数_ONCLICK') then '09点击首页抽奖礼盒'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_TANCHUANGCHOUJIANG' then '10一级奖池立即抽奖'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_抽奖页高级奖池抽奖_ONCLICK' then '11二级到五级立即抽奖'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_SHOUYE_CHAKANJILU' then '12查看中奖记录'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页打开规则弹窗_ONCLICK' then '13查看活动规则'
			 when json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_首页点击活动banner_ONCLICK' then '14通告板块banner'
			 when t.typeid='XWSJXCX_QRCODE_V' and json_extract(t.`data`,'$.tcode')='AC2D0BC8C0244786802B7B25452569BA' then '15点击服务消息提醒'
			 when (json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_抽奖抽到V值再订阅_ONCLICK'
					or json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_抽奖抽中NV值再订阅_ONCLICK'
					or json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_抽奖没中奖品且没有次数再订阅_ONCLICK'
					or json_extract(t.`data`,'$.embeddedpoint')='QIANDAO_抽奖抽到精品再订阅_ONCLICK')				
		   then '16点击开启订阅'
	else null end 事件
	,t.usertag
	,t.date
	from track.track t 
	where t.date between '2023-01-01' and '2023-12-31 23:59:59'
) a 
where a.事件 is not null 
GROUP BY 1 order by 1 ;

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 补签卡兑换明细

select i.source
,count(1) 总量
-- ,count(case when i.`status`=0 then 1 else null end ) 未使用数
,count(case when i.`status`=0 and m.IS_VEHICLE=1 then 1 else null end) 车主未使用数
,count(case when i.`status`=0 and m.IS_VEHICLE=0 then 1 else null end) 粉丝未使用数
-- ,count(case when i.`status`=1 then 1 else null end ) 已使用数
,count(case when i.`status`=1 and m.IS_VEHICLE=1 then 1 else null end) 车主已使用数
,count(case when i.`status`=1 and m.IS_VEHICLE=0 then 1 else null end) 粉丝已使用数
-- ,count(case when i.`status`=2 then 1 else null end ) 已过期数
,count(case when i.`status`=2 and m.IS_VEHICLE=1 then 1 else null end) 车主已过期数
,count(case when i.`status`=2 and m.IS_VEHICLE=0 then 1 else null end) 粉丝已过期数
from mine.sign_comple_sign_card_info i
left join member.tc_member_info m on i.member_id=m.ID
where i.create_time BETWEEN '2022-06-01' and '2023-12-31 23:59:59'
-- and i.`status`=1
GROUP BY 1 order by 1 desc;

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 活动数据明细

-- 当日签到人数
select DATE(i.create_time) adate
,count(DISTINCT i.member_id) 签到人数
,count(DISTINCT case when m.IS_VEHICLE=1 then i.member_id else null end) 当日签到车主
,count(DISTINCT case when m.IS_VEHICLE=0 then i.member_id else null end) 当日签到粉丝
from mine.sign_info i 
left join member.tc_member_info m on i.member_id=m.ID
where i.is_delete=0
and i.create_time >='2023-01-01' 
and i.create_time <='2023-12-31 23:59:59'
GROUP BY 1　order by 1 ;

--  累计签到人数
select DATE(a.mdate)
,max(a.rk)
,max(a.rk1) 车主累计签到人数
,max(a.rk2)  粉丝累计签到人数 
from (
	select i.member_id
	,m.is_vehicle
	,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	join member.tc_member_info m on i.member_id=m.id -- and m.IS_DELETED =0 and m.STATUS <>60341003
	where i.is_delete=0  
	and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2　order by 2,3,5 
) a 
GROUP BY 1 with ROLLUP 
order by 1

-- 当月累计签到人数

select DATE(a.mdate)
,max(a.rk) 9月累计签到人数
,max(a.rk1) 9月车主累计签到人数
,max(a.rk2)  9月粉丝累计签到人数 
from (
	select i.member_id,m.is_vehicle,min(i.create_time) mdate
	,row_number() over(order by min(i.create_time) ) rk
	,case when m.is_vehicle=1 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk1
	,case when m.is_vehicle=0 then row_number() over(partition by m.is_vehicle order by min(i.create_time) )  else null end rk2
	from mine.sign_info i 
	left join member.tc_member_info m on i.member_id=m.id
	where i.is_delete=0 
	and i.create_time >='2023-01-01' and i.create_time <= '2023-12-31 23:59:59'
	GROUP BY 1,2　order by 2,3,5 
) a GROUP BY 1 order by 1  ;

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 签到天数人数统计
select a.累计天数
,count(1) 用户数
,count(case when a.IS_VEHICLE=1 then 1 else null end) 车主数
,count(case when a.IS_VEHICLE=0 then 1 else null end) 粉丝数
from (
	select a.MEMBER_ID,a.IS_VEHICLE,count(1) 累计天数
	from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,DATE(i.CREATE_TIME) 日期
		from mine.sign_info i 
		left join member.tc_member_info m on i.member_id=m.id -- and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time >='2022-01-10' and i.create_time <= '2023-12-31 23:59:59'
	) a 
	GROUP BY 1,2 order by 2 desc 
) a 
GROUP BY 1 order by 1;

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 抽奖数据明细
select DATE(l.create_time) bdate
,count(DISTINCT case when l.lottery_play_code='signLv1' then l.member_id else null end) 一级奖池抽奖人数
,count(DISTINCT case when l.lottery_play_code='signLv1' and l.have_win=1 then l.member_id else null end) 一级奖池中奖人数
,count(DISTINCT case when l.lottery_play_code='signLv1' and l.have_win=1 and m.IS_VEHICLE=1 then l.member_id else null end) 一级奖池中奖车主人数
,count(DISTINCT case when l.lottery_play_code='signLv1' and l.have_win=1 and m.IS_VEHICLE=0 then l.member_id else null end) 一级奖池中奖粉丝人数
,sum(case when l.lottery_play_code='signLv1' and l.have_win=1 then cast(left(l.prize_name,LENGTH(l.prize_name)-1) as INT) else null end) 一级奖池发放V值数
,count(DISTINCT case when l.lottery_play_code='signLv2' then l.member_id else null end) 二级奖池抽奖人数
,count(DISTINCT case when l.lottery_play_code='signLv2' and l.have_win=1 then l.member_id else null end) 二级奖池中奖人数
,count(DISTINCT case when l.lottery_play_code='signLv2' and l.have_win=1 and m.IS_VEHICLE=1 then l.member_id else null end) 二级奖池中奖车主人数
,count(DISTINCT case when l.lottery_play_code='signLv2' and l.have_win=1 and m.IS_VEHICLE=0 then l.member_id else null end) 二级奖池中奖粉丝人数
,sum(case when l.lottery_play_code='signLv2' and l.have_win=1 then cast(left(l.prize_name,LENGTH(l.prize_name)-1) as INT) else null end) 二级奖池发放V值数
,count(DISTINCT case when l.lottery_play_code in ('signLv3','signLv7') then l.member_id else null end) 三级奖池抽奖人数
,count(DISTINCT case when l.lottery_play_code in ('signLv3','signLv7') and l.have_win=1 then l.member_id else null end) 三级奖池中奖人数
,count(DISTINCT case when l.lottery_play_code in ('signLv3','signLv7') and l.have_win=1 and m.IS_VEHICLE=1 then l.member_id else null end) 三级奖池中奖车主人数
,count(DISTINCT case when l.lottery_play_code in ('signLv3','signLv7') and l.have_win=1 and m.IS_VEHICLE=0 then l.member_id else null end) 三级奖池中奖粉丝人数
,count(DISTINCT case when l.lottery_play_code='signLv4' then l.member_id else null end) 四级奖池抽奖人数
,count(DISTINCT case when l.lottery_play_code='signLv4' and l.have_win=1 then l.member_id else null end) 四级奖池中奖人数
,count(DISTINCT case when l.lottery_play_code='signLv4' and l.have_win=1 and m.IS_VEHICLE=1 then l.member_id else null end) 四级奖池中奖车主人数
,count(DISTINCT case when l.lottery_play_code='signLv4' and l.have_win=1 and m.IS_VEHICLE=0 then l.member_id else null end) 四级奖池中奖粉丝人数
,count(DISTINCT case when l.lottery_play_code='signLv6' then l.member_id else null end) 五级奖池抽奖人数
,count(DISTINCT case when l.lottery_play_code='signLv6' and l.have_win=1 then l.member_id else null end) 五级奖池中奖人数
,count(DISTINCT case when l.lottery_play_code='signLv6' and l.have_win=1 and m.IS_VEHICLE=1 then l.member_id else null end) 五级奖池中奖车主人数
,count(DISTINCT case when l.lottery_play_code='signLv6' and l.have_win=1 and m.IS_VEHICLE=0 then l.member_id else null end) 五级奖池中奖粉丝人数
,sum(case when l.lottery_play_code='signLv6' and l.have_win=1 then cast(left(l.prize_name,LENGTH(l.prize_name)-1) as INT) else null end) 五级奖池发放V值数
from mine.sign_lottery_log l
left join member.tc_member_info m on l.member_id=m.ID
where l.is_delete=0
and l.create_time >= '2023-01-01'
and l.create_time <= '2023-12-31 23:59:59'
GROUP BY 1 order by 1 ;


select l.member_id 参加lv6抽奖用户,
x.member_id 签到满300天用户
from mine.sign_lottery_log l
left join (
select a.MEMBER_ID
from (
select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
and i.create_time <= '2023-12-31 23:59:59'
) a GROUP BY 1
HAVING count(1)>=300
)x on x.MEMBER_ID=l.member_id
where l.create_time <= '2023-12-31 23:59:59'
and l.create_time >='2022-01-10'
and l.lottery_play_code='signLv6'
order by 1


select DISTINCT i.MEMBER_ID,i.time_str
from mine.sign_info i 
join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
where i.is_delete=0 
-- and i.create_time <= '2023-12-31 23:59:59'
and i.member_id =3018468

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 连续签到未中奖
select a.连续签到N天一级奖池未中奖,a.member_id
,case when m.is_vehicle=1 then '车主' when m.is_vehicle=0 then '粉丝' else null end 身份
,m.member_phone 注册手机号
from (
select d.member_id,max(d.次数) 连续签到N天一级奖池未中奖
	from (
	select c.member_id,c.最早登录时间,count(1) 次数
	from (
		select b.member_id,b.日期,DATE_SUB(b.日期,b.rank) 最早登录时间
		from (
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DATE(i.CREATE_TIME) 日期,i.member_id,sum(i.have_win) win
			from mine.sign_lottery_log i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.lottery_play_code='signLv1' -- and i.have_win=0
			and i.is_delete=0 and i.create_time <= '2023-12-31 23:59:59'
			-- and i.member_id=4729950
			GROUP BY 1,2 HAVING sum(i.have_win)=0 order by 1 
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=7 order by 2 desc
) a 
left join member.tc_member_info m on a.member_id=m.id
where a.member_id not in (
# 一级奖池中奖名单
select DISTINCT l.member_id
from mine.sign_lottery_log l 
where l.lottery_play_code='signLv1' and l.have_win=1
and l.create_time <= '2023-12-31 23:59:59'
and l.member_id is not null 
)
order by 1 desc ;
----------------------------------------------------------------------------------------------------------------------------------------------------;

### 实物奖品中奖明细
select DATE(l.create_time) bdate,l.prize_name,count(1)
from mine.sign_lottery_log l 
where l.is_delete=0 
and l.lottery_play_code<>'signLv1'
and l.have_win=1
and l.create_time >= '2023-01-01'
and l.create_time <= '2023-12-31 23:59:59'
and l.prize_name<>'9V'
and l.prize_name<>'2V'
GROUP BY 1,2 order by 1,2; 
----------------------------------------------------------------------------------------------------------------------------------------------------;

### 签到人数时间段
select `HOUR`(f.create_time),count(1),count(DISTINCT f.member_id)
from mine.sign_info f 
where f.create_time >='2022-01-10' and f.create_time <= '2023-12-31 23:59:59'
and f.is_delete=0
GROUP BY 1 order by 1;
----------------------------------------------------------------------------------------------------------------------------------------------------;

### 签到粉丝注册明细
select m.id 会员ID,m.create_time 注册时间,min(f.create_time) 最早签到时间,max(f.create_time) 最晚签到时间,count(DISTINCT f.day_int) 签到天数
from mine.sign_info f 
join member.tc_member_info m on f.member_id=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 and m.IS_VEHICLE=0
where f.create_time <= '2023-12-31 23:59:59'
GROUP BY 1,2 order by 2

----------------------------------------------------------------------------------------------------------------------------------------------------;

### 文章RAWDATA

## by day

-- C40预售
select 'C40预热' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-01-11' and t.date<'2022-02-14'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='C40YUSHOU_C40DINGYUE_ONLOAD'
GROUP BY 1,2 order by 2
union all 
-- C40
select 'C40预售' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-02-14' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
GROUP BY 1,2 order by 2 
union all
-- 2022春服
select '2022春服' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-02-14' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='CHUNFU2022_SHOUYE_ONLOAD'
GROUP BY 1,2 order by 2 
union all
-- 沃尔沃心选路线
select '别赶路 去感受路-一期' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-04-01' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='别赶路_首页_onload_'
GROUP BY 1,2 order by 2 
union all
-- 爱心计划2期
select '爱心计划2期' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-05' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_地图页面_onload'
GROUP BY 1,2 order by 2 
union ALL
-- 525车主节主预热
select '525车主节主预热页' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-22' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_home_预热_click'
GROUP BY 1,2 order by 2 
union ALL
-- 525车主节主会场
select '525车主节主会场' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-22' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_home_正式_click'
GROUP BY 1,2 order by 2 
union ALL
-- 525车主狂欢节
select '525车主狂欢节' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-23' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_homePage_车主狂欢_click'
GROUP BY 1,2 order by 2 
union all 
-- 沃世界三周年
select '沃世界三周年' pageid,date(t.date) 日期,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-06-01' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='三周年_进行页_ONLOAD'
GROUP BY 1,2 order by 2 
union all 
select l.ref_id,date(l.date_create) 日期,count(1) PV,count(DISTINCT l.user_id) UV
from `cms-center`.cms_operate_log l 
where l.date_create >='2022-01-10' and l.date_create <= '2023-12-31 23:59:59'
and l.type='VIEW'
and l.ref_id in (
'ZQugecciVM','zL6faSqfRr','wTee7UKGH3','wNwnvQ4Aji','wngT1xz7vM ','vRKiyaTXhx','vf4oHsGX4u','sgQhKsheAK','rpQj9nR75f','RksZTV7hMZ','RAQnztVzTQ','q2aKctC56c',
'pV6Xi6SCtT','ot8Ik00cVP','MoeSZ7KEGc','MKQvJ4cv6P','m54iiZydDS','LP8EUZoTZE','kS8YclpgrJ','JYa6dh61tp','J1ghscoul2','i6APhU36N4','HaALXbLrXu','GV44NqnZcC',
'gNAZ0gdKY2','dIcviOn0wL','d5aEH2Mjsw','cGa0NCD2PP','c1eUKRjJut','bPQnTGPxdi','bHgj1CP6oN','b3eyrlKNxU','7Z8QiluAsJ','73egsyfVhX','56gPjhHfAR','4Xgt8r9n48',
'3rqm2zitW1','3Jae879DUl','pV6Xi6SCtT','bPQnTGPxdi','z9shvN121s','on8SVVVNtn','vf4oHsGX4u','iigvhQ4NER','8OaYDI10LN','ireQc6ugCG','mbaMDNtwh5','9RuIcPRsgf',
'Z2uQOE0iIz','baAjVCdUB3','Lw61x6ydmo','C3uwSMsuKQ','flwV00PgWo','z04MJGyK3Q','l3uIuK8etQ','Y74o5m8Po5','1SeYuMXzCS','sswzlyLkxc','dx8Wj3Y1TK','F4whcq7Cn3',
'JO6Huo52Bq','9seM29CczV','SXg1EZ2U3T','Lrcn6ShnQX','FXAZcLW8cy','m3qgzmak8j','JO6Huo52Bq','FXAZcLW8cy','tWaWUUSqIS','WwaGUtSl3f','mA4YjLEJII','k0qiOWc99W'
,'sZagbEF8yR','RjAbp6HFQb','k0qiOWc99W','FvqSGa7DjD','OkMhFt7uJW','4l8s8HGtUx','7T8SLz531e','4l8s8HGtUx','Kq6vKFJygI','4l8s8HGtUx','Kq6vKFJygI','BNcZFsegGZ',
'RjAbp6HFQb','BNcZFsegGZ','H3g1ABFEmI','7T8SLz531e','hIKmCPj3sj','BNcZFsegGZ','WwaGUtSl3f','H3g1ABFEmI','BNcZFsegGZ','hIKmCPj3sj','WwaGUtSl3f','hIKmCPj3sj',
'4yKsV7dZ76','BNcZFsegGZ','7pesc4r91g','FvqSGa7DjD','4yKsV7dZ76','Dccl3IbAt5','BNcZFsegGZ','8twdMdNosm','u8MVrj0kdw','FvqSGa7DjD','MH6nGzQcHz','zguiHsGH0s',
'u8MVrj0kdw','8twdMdNosm','gBeq5m0usW','MH6nGzQcHz','s3KUD1MuAB','s3KUD1MuAB','u8MVrj0kdw','KeaWK9K3Ya','u8MVrj0kdw','u8MVrj0kdw','MH6nGzQcHz','FwKYDdCXpw',
'hiqq4lmPIK','F7aKyDnSTz','FwKYDdCXpw','8twdMdNosm','ToMXYgHRzr','Taa2oqHVhi','icgZ4UEARE','Taa2oqHVhi','HzKy4p5waD','CjQREOxeZ3','OXQv3mJoE9','icgZ4UEARE',
'2iamw9752z','nf48mM4YE3','CjQREOxeZ3','BPQVu8FovT','6FK6ZO642d','CjQREOxeZ3','Taa2oqHVhi','0K6ZxmF0r3','rt4M3dkRfe','5jKcBirg9Q','cCMhtKmxkv','Uk4En69iaE',
'NqsnOVDj3l','2iamw9752z','wxgNy2Hg3o','uue0gTcB6C','ji86Zh2dN8','sgQhKsheAK','BPQVu8FovT','ji86Zh2dN8','dfe42Y2dvd','o06zgVHzJF','uue0gTcB6C','ji86Zh2dN8',
'o06zgVHzJF','uue0gTcB6C','dfe42Y2dvd','Wlw7p6yt2B','h3c5XLUQ17','dfe42Y2dvd','Clu6eBXefi','o06zgVHzJF','h3c5XLUQ17','dfe42Y2dvd','MmAlKT4iDQ','GdcBrOCMpH',
'h3c5XLUQ17','RoQ7H5mXq5','qK61J4QbEl','gGeut3Kg0t','w6u6IjZ1tP','gGeut3Kg0t','qK61J4QbEl','gGeut3Kg0t','h3c5XLUQ17','gGeut3Kg0t','kCaABXt3T9','o06zgVHzJF',
'Flq45AEDui','M1sTamGa42','3TMBfbzeex','7CqI7T4VFX','Z1eqz0UH2o','Huu6fD7tsT','gGeut3Kg0t',
'7CqI7T4VFX',
'M1sTamGa42',
'FeKykIj74c',
'kCaABXt3T9',
'kCaABXt3T9',
'g2uOnS152e',
'1bsJ9WEBmB',
'M1sTamGa42',
'kfa6dHvIs1',
'kCaABXt3T9',
'FeKykIj74c',
'M1sTamGa42',
'kfa6dHvIs1',
'kCaABXt3T9',
'FeKykIj74c',
'kfa6dHvIs1',
'gGeut3Kg0t',
'B58ODJZO20',
'afqIdU5gUS',
'gGeut3Kg0t',
'1bsJ9WEBmB',
'UvsJx3G684',
'gGeut3Kg0t',
'1bsJ9WEBmB',
'B58ODJZO20',
'nm8aduA8PX',
'kfa6dHvIs1',
'WmOWnAnTgp',
'afqIdU5gUS',
'gGeut3Kg0t',
'cN82km4BZs',
'GOKOymSuue',
'gGeut3Kg0t',
'MSaQXkRXr1',
'GOKOymSuue',
'MSaQXkRXr1',
'Hqe8f2pwHD',
'8J4KSp8tuJ',
'cN82km4BZs',
'qRq0fjx6tn',
'3oAnP6nnWF',
'gGeut3Kg0t',
'gGeut3Kg0t',
'mXam4QBrel',
'gGeut3Kg0t',
'A8wJgV6W4p',
'AF6FFR0Opx',
'qqQ5erua0w',
'c0gzTef0GC',
'A8wJgV6W4p',
'AF6FFR0Opx',
'mXam4QBrel',
'qqQ5erua0w',
'c0gzTef0GC',
'MSaQXkRXr1',
'AF6FFR0Opx',
'gGeut3Kg0t',
'qqQ5erua0w',
'c0gzTef0GC',
'GOKOymSuue',
'MSaQXkRXr1',
'AF6FFR0Opx',
'A8wJgV6W4p',
'afqIdU5gUS',
'MSaQXkRXr1',
'A8wJgV6W4p',
'IKcTeuFVL4',
'gGeut3Kg0t',
'qqQ5erua0w',
'KIQHF2TyKt',
'VGg7RSihKA',
'qqQ5erua0w',
'A8wJgV6W4p',
'gGeut3Kg0t',
'MSaQXkRXr1',
'lZ4mG0sn9d'
)
GROUP BY 1,2 order by 1,2 

## 总计

-- C40预售
select 'C40预热' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-01-11' and t.date<'2022-02-14'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='C40YUSHOU_C40DINGYUE_ONLOAD'
GROUP BY 1
union all 
-- C40
select 'C40预售' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-02-14' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
GROUP BY 1
union ALL
-- 2022春服
select '2022春服' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-02-14' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.data,'$.embeddedpoint')='CHUNFU2022_SHOUYE_ONLOAD'
GROUP BY 1
union ALL
-- 沃尔沃心选路线
select '别赶路 去感受路-一期' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-03-25' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='别赶路_首页_onload_'
GROUP BY 1
union ALL
-- 爱心计划2期
select '爱心计划2期' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-05' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='爱心计划2期_地图页面_onload'
GROUP BY 1
union ALL
-- 525车主节主预热
select '525车主节主预热页' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-22' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_home_预热_click'
GROUP BY 1
union ALL
-- 525车主节主会场
select '525车主节主会场' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-23' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_home_正式_click'
GROUP BY 1
union ALL
-- 525车主狂欢节
select '525车主狂欢节' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-05-23' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='collectionPage_homePage_车主狂欢_click'
GROUP BY 1
union ALL
-- 沃世界三周年
select '沃世界三周年' pageid,count(1) PV,count(DISTINCT t.usertag) UV
from track.track t 
where t.date >= '2022-06-01' and t.date <= '2023-12-31 23:59:59'
and t.typeid='NEWBIE_ACTIVITY_TRACK' and json_extract(t.`data`,'$.embeddedpoint')='三周年_进行页_ONLOAD'
GROUP BY 1
union all 
select l.ref_id,count(1) PV,count(DISTINCT l.user_id) UV
from `cms-center`.cms_operate_log l 
where l.date_create >='2022-01-10' and l.date_create <= '2023-12-31 23:59:59'
and l.type='VIEW'
and l.ref_id in (
'ZQugecciVM','zL6faSqfRr','wTee7UKGH3','wNwnvQ4Aji','wngT1xz7vM ','vRKiyaTXhx','vf4oHsGX4u','sgQhKsheAK','rpQj9nR75f','RksZTV7hMZ','RAQnztVzTQ','q2aKctC56c',
'pV6Xi6SCtT','ot8Ik00cVP','MoeSZ7KEGc','MKQvJ4cv6P','m54iiZydDS','LP8EUZoTZE','kS8YclpgrJ','JYa6dh61tp','J1ghscoul2','i6APhU36N4','HaALXbLrXu','GV44NqnZcC',
'gNAZ0gdKY2','dIcviOn0wL','d5aEH2Mjsw','cGa0NCD2PP','c1eUKRjJut','bPQnTGPxdi','bHgj1CP6oN','b3eyrlKNxU','7Z8QiluAsJ','73egsyfVhX','56gPjhHfAR','4Xgt8r9n48',
'3rqm2zitW1','3Jae879DUl','pV6Xi6SCtT','bPQnTGPxdi','z9shvN121s','on8SVVVNtn','vf4oHsGX4u','iigvhQ4NER','8OaYDI10LN','ireQc6ugCG','mbaMDNtwh5','9RuIcPRsgf',
'Z2uQOE0iIz','baAjVCdUB3','Lw61x6ydmo','C3uwSMsuKQ','flwV00PgWo','z04MJGyK3Q','l3uIuK8etQ','Y74o5m8Po5','1SeYuMXzCS','sswzlyLkxc','dx8Wj3Y1TK','F4whcq7Cn3',
'JO6Huo52Bq','9seM29CczV','SXg1EZ2U3T','Lrcn6ShnQX','FXAZcLW8cy','m3qgzmak8j','JO6Huo52Bq','FXAZcLW8cy','tWaWUUSqIS','WwaGUtSl3f','mA4YjLEJII','k0qiOWc99W'
,'sZagbEF8yR','RjAbp6HFQb','k0qiOWc99W','FvqSGa7DjD','OkMhFt7uJW','4l8s8HGtUx','7T8SLz531e','4l8s8HGtUx','Kq6vKFJygI','4l8s8HGtUx','Kq6vKFJygI','BNcZFsegGZ',
'RjAbp6HFQb','BNcZFsegGZ','H3g1ABFEmI','7T8SLz531e','hIKmCPj3sj','BNcZFsegGZ','WwaGUtSl3f','H3g1ABFEmI','BNcZFsegGZ','hIKmCPj3sj','WwaGUtSl3f','hIKmCPj3sj',
'4yKsV7dZ76','BNcZFsegGZ','7pesc4r91g','FvqSGa7DjD','4yKsV7dZ76','Dccl3IbAt5','BNcZFsegGZ','8twdMdNosm','u8MVrj0kdw','FvqSGa7DjD','MH6nGzQcHz','zguiHsGH0s',
'u8MVrj0kdw','8twdMdNosm','gBeq5m0usW','MH6nGzQcHz','s3KUD1MuAB','s3KUD1MuAB','u8MVrj0kdw','KeaWK9K3Ya','u8MVrj0kdw','u8MVrj0kdw','MH6nGzQcHz','FwKYDdCXpw',
'hiqq4lmPIK','F7aKyDnSTz','FwKYDdCXpw','8twdMdNosm','ToMXYgHRzr','Taa2oqHVhi','icgZ4UEARE','Taa2oqHVhi','HzKy4p5waD','CjQREOxeZ3','OXQv3mJoE9','icgZ4UEARE',
'2iamw9752z','nf48mM4YE3','CjQREOxeZ3','BPQVu8FovT','6FK6ZO642d','CjQREOxeZ3','Taa2oqHVhi','0K6ZxmF0r3','rt4M3dkRfe','5jKcBirg9Q','cCMhtKmxkv','Uk4En69iaE',
'NqsnOVDj3l','2iamw9752z','wxgNy2Hg3o','uue0gTcB6C','ji86Zh2dN8','sgQhKsheAK','BPQVu8FovT','ji86Zh2dN8','dfe42Y2dvd','o06zgVHzJF','uue0gTcB6C','ji86Zh2dN8',
'o06zgVHzJF','uue0gTcB6C','dfe42Y2dvd','Wlw7p6yt2B','h3c5XLUQ17','dfe42Y2dvd','Clu6eBXefi','o06zgVHzJF','h3c5XLUQ17','MmAlKT4iDQ','GdcBrOCMpH',
'h3c5XLUQ17','RoQ7H5mXq5','qK61J4QbEl','gGeut3Kg0t','w6u6IjZ1tP','gGeut3Kg0t','qK61J4QbEl','gGeut3Kg0t','h3c5XLUQ17','gGeut3Kg0t','kCaABXt3T9','o06zgVHzJF',
'Flq45AEDui','M1sTamGa42','3TMBfbzeex','7CqI7T4VFX','Z1eqz0UH2o','Huu6fD7tsT','gGeut3Kg0t',
'7CqI7T4VFX',
'M1sTamGa42',
'FeKykIj74c',
'kCaABXt3T9',
'kCaABXt3T9',
'g2uOnS152e',
'1bsJ9WEBmB',
'M1sTamGa42',
'kfa6dHvIs1',
'kCaABXt3T9',
'FeKykIj74c',
'M1sTamGa42',
'kfa6dHvIs1',
'kCaABXt3T9',
'FeKykIj74c',
'kfa6dHvIs1',
'gGeut3Kg0t',
'B58ODJZO20',
'afqIdU5gUS',
'gGeut3Kg0t',
'1bsJ9WEBmB',
'UvsJx3G684',
'gGeut3Kg0t',
'1bsJ9WEBmB',
'B58ODJZO20',
'nm8aduA8PX',
'kfa6dHvIs1',
'WmOWnAnTgp',
'afqIdU5gUS',
'gGeut3Kg0t',
'cN82km4BZs',
'GOKOymSuue',
'gGeut3Kg0t',
'MSaQXkRXr1',
'GOKOymSuue',
'MSaQXkRXr1',
'Hqe8f2pwHD',
'8J4KSp8tuJ',
'cN82km4BZs',
'qRq0fjx6tn',
'3oAnP6nnWF',
'gGeut3Kg0t',
'gGeut3Kg0t',
'mXam4QBrel',
'gGeut3Kg0t',
'A8wJgV6W4p',
'AF6FFR0Opx',
'qqQ5erua0w',
'c0gzTef0GC',
'A8wJgV6W4p',
'AF6FFR0Opx',
'mXam4QBrel',
'qqQ5erua0w',
'c0gzTef0GC',
'MSaQXkRXr1',
'AF6FFR0Opx',
'gGeut3Kg0t',
'qqQ5erua0w',
'c0gzTef0GC',
'GOKOymSuue',
'MSaQXkRXr1',
'AF6FFR0Opx',
'A8wJgV6W4p',
'afqIdU5gUS',
'MSaQXkRXr1',
'A8wJgV6W4p',
'IKcTeuFVL4',
'gGeut3Kg0t',
'qqQ5erua0w',
'KIQHF2TyKt',
'VGg7RSihKA',
'qqQ5erua0w',
'A8wJgV6W4p',
'gGeut3Kg0t',
'MSaQXkRXr1',
'lZ4mG0sn9d'
)
GROUP BY 1 ;
----------------------------------------------------------------------------------------------------------------------------------------------------;
