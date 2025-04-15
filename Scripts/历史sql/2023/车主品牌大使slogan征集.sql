-- PV UV

朋友圈海报
小程序首页弹窗
小程序首页banner 
沃的活动首页banner
公众号引流
月历订阅推送

-- PVUV  OkMhFt7uJW
-- 文章明细	

select o.ref_id,c.title,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
	from 'cms-center'.cms_operate_log o
	left join (
				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from `cms-center`.cms_content c 
			where c.deleted=0 
			union all 
			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.is_deleted=0
			-- and a.modifier like '%Wedo%' 
			and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	-- and date_create BETWEEN '2022-03-24' and '2021-12-23 23:59:59' 
	and date_create <='2022-07-04 23:59:59' and date_create >='2022-06-25 00:00:00'
	and o.ref_id='hIKmCPj3sj'  
	GROUP BY 1,2;

-- 拉新
select count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create <='2022-07-04 23:59:59' and l.date_create >='2022-06-25 00:00:00' 
and l.ref_id='hIKmCPj3sj' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE) ;

-- 激活
select '04激活沉睡用户数' 类目
,count(DISTINCT case when a.IS_VEHICLE=1 then a.usertag else null end) 车主
,count(DISTINCT case when IFNULL(a.IS_VEHICLE,0)=0 then a.usertag else null end) 粉丝
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.is_vehicle,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select m.is_vehicle,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from 'cms-center'.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			-- where l.date_create BETWEEN '2022-02-21' and '2022-03-20 23:59:59'  
			where l.date_create <='2022-07-04 23:59:59' and l.date_create >='2022-06-25 00:00:00'
			and l.ref_id='hIKmCPj3sj' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) ; 

-- PVUV
select case when t.`data` like '%D2170C3B5D524F3E8DCC240490A12A1E%' then '00 朋友圈海报'
	when t.`data` like '%D306CA4A3552465096723B1DEB7EFC57%' then '01 小程序首页弹窗'
	when t.`data` like '%C4207907205C4788968A5984A25B966E%' then '02 小程序首页banner '
	when t.`data` like '%F0406F45D2E14028A207391865156EF8%' then '03 沃的活动首页banner'
	when t.`data` like '%6756F70C16384E4FACECDE59742B271A%' then '04 公众号引流'	
	when t.`data` like '%DC11027D0FE048DEBAEFE619B47233F0%' then '05 月历订阅推送'	
else null end 分类,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2022-06-25 00:00:00' and t.`date` <= '2022-07-04 23:59:59'
group by 1
order by 1

-- 拉新人数
select case when t.`data` like '%D2170C3B5D524F3E8DCC240490A12A1E%' then '00 朋友圈海报'
	when t.`data` like '%D306CA4A3552465096723B1DEB7EFC57%' then '01 小程序首页弹窗'
	when t.`data` like '%C4207907205C4788968A5984A25B966E%' then '02 小程序首页banner '
	when t.`data` like '%F0406F45D2E14028A207391865156EF8%' then '03 沃的活动首页banner'
	when t.`data` like '%6756F70C16384E4FACECDE59742B271A%' then '04 公众号引流'	
	when t.`data` like '%DC11027D0FE048DEBAEFE619B47233F0%' then '05 月历订阅推送'	
else null end 分类,
	count(distinct m.id) 粉丝
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.IS_VEHICLE = 0
where t.`date` >= '2022-06-25 00:00:00'
and t.`date` <='2022-07-04 23:59:59'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
group by 1
order by 1


-- 激活僵尸粉数
select 
-- 	a.is_vehicle,
	a.channel,
	-- a.usertag
	count(distinct a.usertag)
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,b.channel,max(t.date) tdate
 from track.track t
 join 
	 (
	  -- 获取访问文章活动的最早时间
	  select m.is_vehicle,t.usertag,c.channel,min(t.date) mdate 
	  from track.track t 
	  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
	  join 
		  (select b.channel,b.usertag,b.min_date,
			ROW_NUMBER() over(partition by b.usertag order by b.min_date) as rk
			from 
				(select a.channel ,a.usertag,min(a.date) as min_date
				from 
					(select case when t.`data` like '%D2170C3B5D524F3E8DCC240490A12A1E%' then '00 朋友圈海报'
					when t.`data` like '%D306CA4A3552465096723B1DEB7EFC57%' then '01 小程序首页弹窗'
					when t.`data` like '%C4207907205C4788968A5984A25B966E%' then '02 小程序首页banner '
					when t.`data` like '%F0406F45D2E14028A207391865156EF8%' then '03 沃的活动首页banner'
					when t.`data` like '%6756F70C16384E4FACECDE59742B271A%' then '04 公众号引流'	
					when t.`data` like '%DC11027D0FE048DEBAEFE619B47233F0%' then '05 月历订阅推送'	
							else null end 'channel',
							t.usertag,
							t.`date` 
						from track.track t 
						where t.`date` >= '2022-06-25 00:00:00'
						and t.`date` <= '2022-07-04 23:59:59'
						) a 
				where a.channel is not null
				group by 1,2) 
			b) c on t.usertag = c.usertag
	  where 
	  t.date >= '2022-06-25 00:00:00'
	  and t.date <='2022-07-04 23:59:59'
	  GROUP BY 1,2,3
	 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3,4
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
order by 1

--- 活动评论数据
select
teh.name 评论姓名,
teh.user_id 评论用户ID,
teh.id 一级评论id,
tmi.MEMBER_PHONE 沃世界绑定手机号,
case when tmi.IS_VEHICLE=1 then '车主'
 else '非车主' end '是否为车主',
teh.content 评价内容,
teh.create_time 评论时间
-- teh.liked_count 点赞数,
-- tep.picture_url 
from comment.tt_evaluation_history teh
left join comment.tc_evaluation_picture tep on tep.evaluation_id = teh.id 
left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE 
where teh.object_id = 'hIKmCPj3sj'
and teh.create_time >= '2022-06-25 00:00:00'
and teh.create_time <= '2022-07-04 23:59:59'
and teh.parent_id is null 
and teh.is_deleted = 0
order by teh.create_time desc