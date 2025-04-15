-- 1、参与过签到活动的用户占所有活跃用户的比例这个可以拉取
## 签到人数活跃比例
-- 当日签到人数
select 
-- DATE(i.create_time) adate,
count(DISTINCT i.member_id) 签到人数
-- ,count(DISTINCT case when m.IS_VEHICLE=1 then i.member_id else null end) 当日签到车主
-- ,count(DISTINCT case when m.IS_VEHICLE=0 then i.member_id else null end) 当日签到粉丝
from mine.sign_info i 
left join member.tc_member_info m on i.member_id=m.ID
where i.is_delete=0
and i.create_time >='2022-10-15' 
-- and i.create_time <='2022-11-09 23:59:59'
-- GROUP BY 1　
order by 1 

-- 小程序活跃用户数
SELECT 
-- DATE_FORMAT(t.date,'%Y-%m-%d'),
count(DISTINCT tmi.id) 数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE t.date >='2022-10-15'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
    AND t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
-- GROUP BY 1 -- with rollup
order by 1

-- 2、所有参与签到活动的用户中的连续签到时长的区间占比--->看有多少人是能够连续签到的，以及连续签到的极这个也是可以拉取的，就看连续签到1天，多少人；连续签到2天，多少人。。。以此类推。
#连续签到7天及以上人数
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
			# 日期降序排序
			select a.MEMBER_ID
			,a.`日期`
			,row_number() over(PARTITION by a.MEMBER_ID order by a.`日期` ) rank
			from (
			select DISTINCT i.MEMBER_ID,DATE(i.CREATE_TIME) 日期
			from mine.sign_info i 
			join member.tc_member_info m on i.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
			where i.is_delete=0 and i.create_time <= '2022-11-15 23:59:59'
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
			where i.is_delete=0 
			and i.create_time <= '2022-11-15 23:59:59'
			and i.create_time >='2022-10-15'
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
			where i.is_delete=0 and i.create_time <= '2022-11-15 23:59:59'
			and i.create_time >='2022-10-15'
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
			where i.is_delete=0 and i.create_time <= '2022-11-15 23:59:59'
			and i.create_time >='2022-10-15'
			) a 
		) b
	) c GROUP BY 1,2 order by 3 desc 
) d GROUP BY 1 HAVING max(d.次数)>=30 order by 2 desc 
) a 
left join member.tc_member_info m on a.member_id=m.id 
order by 1

-- 2. 签到2次以上的用户里有多少在他做首次签到之前已经是沉睡状态的
### 签到天数人数统计
select 
i.member_id,
min(i.time_str)
from mine.sign_info i
left join member.tc_member_info m on m.id=i.member_id 
left join track.track t on cast(m.USER_ID as varchar)=t.usertag 
where i.member_id in(
#签到2次以上的用户
select a.member_id
from (
	select a.MEMBER_ID,a.IS_VEHICLE,count(1) 累计天数
	from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
		from mine.sign_info i 
		left join member.tc_member_info m on i.member_id=m.id -- and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time >='2022-01-10' and i.create_time <= '2022-11-15 23:59:59'
	) a 
	GROUP BY 1,2 order by 2 desc 
) a where a.累计天数>=2
GROUP BY 1 
order by 1
)group by 1





select 
i.member_id,
min(i.time_str) mt -- 第一次签到时间
from mine.sign_info i
left join member.tc_member_info m on m.id=i.member_id 
join track.track t 
where i.member_id in(
#签到2次以上的用户
select a.member_id
from (
	select a.MEMBER_ID,a.IS_VEHICLE,count(1) 累计天数
	from (
		select DISTINCT i.MEMBER_ID,m.IS_VEHICLE,i.time_str 日期
		from mine.sign_info i 
		left join member.tc_member_info m on i.member_id=m.id -- and m.is_deleted=0 and m.member_status<>60341003 -- and m.is_vehicle=1
		where i.is_delete=0 
		and i.create_time >='2022-01-10' and i.create_time <= '2022-11-15 23:59:59'
	) a 
	GROUP BY 1,2 order by 2 desc 
) a where a.累计天数>=2
GROUP BY 1 
order by 1
)group by 1



-- 连续签到三天以上的用户
select
  x.member_id
  ,min(x.create_time) as start_date
  ,max(x.create_time) as end_date
  ,count(1) as times
from
(
  select 
    i.member_id
    ,i.create_time
    ,date_sub(i.create_time,rn) as date_diff
    from
    (
      select 
        i.member_id
        ,i.create_time
        ,row_number() over(partition by
          i.member_id order by i.create_time) as rn
      from 
        mine.sign_info i
    )
)x
group by x.member_id,x.date_diff
having times >= 3
