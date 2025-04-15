NsAnphg9kQ
1、 数据需求目的：筛选中奖留言

2、 活动起止时间：2022.9.26—2022.10.10

3、 数据字段见附件数据模板

4、 期望交付时间：10.11日中午12点前    时间维度：2022.9.26 0点—2022.10.10 24点 （字段见附件模板）

5、活动链接见附件数据模板




-- 小程序活跃用户数
SELECT tmi.IS_VEHICLE ,
count(DISTINCT tmi.id) 数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE t.date >= '2022-10-14' AND t.date<'2022-10-18'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
    AND t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
GROUP BY 1 with rollup
order by 1

3TMBfbzeex  Z1eqz0UH2o

-- 文章明细	 
select m.is_vehicle
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
	and date_create <'2022-10-18' and date_create >='2022-10-14'
	and o.ref_id='3TMBfbzeex' 
	GROUP BY 1


-- 拉新
select count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create >='2022-10-14' and l.date_create <'2022-10-18' 
and l.ref_id='3TMBfbzeex'and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE) ;

-- 僵尸粉-track表计算
select
a.is_vehicle 是否车主,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select t.usertag,b.mdate,b.is_vehicle,max(t.date) tdate
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select m.is_vehicle,t.usertag,min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
  where json_extract(t.`data`,'$.pageId')='iigvhQ4NER'
  and t.date >= '2022-03-15 14:00:00' and t.date < '2022-03-25'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1;

-- 激活
select a.is_vehicle
,count(DISTINCT a.usertag ) 总数
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
			where l.date_create >='2022-10-14' and l.date_create <'2022-10-18' 
			and l.ref_id='3TMBfbzeex'
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY)
group by 1

-- PV UV
select 
tmi.IS_VEHICLE 是否车主,
case when t.`data` like '%BD0465B5EE67445FA5CD16CDAF310467%' then '01 推文'
	when t.`data` like '%53594C3A293E408B83072780A88B90B5%' then '02 海报'	
	when t.`data` like '%C2489CBEC9CE40F6978706A28F257998%' then '03首页banner'	
	when t.`data` like '%3C8742D885544940ADEF16ABBAC8C936%' then '04首页活动'	
	when t.`data` like '%1566C225AD60423290EB312A8879BBFE%' then '05 弹窗'	
else null end 分类,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-10-14' and t.`date` <'2022-10-18'
group by 1,2
order by 1,2


-- 2022_10_parent_child_challange_session_activity
2022_10_parent_child_challange_session_activity

-- 报名数据
select 
''序号,
a.contact_name 姓名,
a.gender 性别,
a.certificate_no 身份证号,
a.phone 手机号,
a.ex_field_3 随行人数,
a.ex_field_4 随行人员姓名,
a.ex_field_5 随行人员性别,
a.ex_field_7 随行人员身份证号,
a.ex_field_1 是否驾车前往,
a.ex_field_2 车牌号,
cc.REGION_NAME 城市
from volvo_online_activity_module.activity_capital_info a 
left join `member`.tc_member_info m on m.id=a.member_id 
left join dictionary.tc_region cc on m.MEMBER_PROVINCE=cc.REGION_ID
where a.capital_retention_id ='79'

-- app评论
select tmi.MEMBER_NAME 昵称,
a.member_id 会员ID,
tmi.MEMBER_PHONE 注册手机号码,
a.comment_content 评论内容,
a.create_time 评论时间,
-- case when c.score_level is not null then c.name
-- 	else '非沃尔沃官方认证俱乐部成员' end as 所属认证俱乐部名称,
-- c.name 所属认证俱乐部名称,
tmi.MEMBER_NAME 评论用户,
tmi.REAL_NAME 客户姓名,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tv.PLATE_NUMBER 车牌号,
a.member_id 会员ID,
tmi.MEMBER_PHONE 注册手机号码,
cc.REGION_NAME 所属地区
from community.tm_comment a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join car_friends.car_friends_user b on b.member_id =a.member_id  and b.is_deleted =0
left join car_friends.car_friends_activity c on b.activity_id =c.id  and c.is_deleted =0
left join dictionary.tc_region cc on tmi.MEMBER_PROVINCE=cc.REGION_ID
left join vehicle.tm_vehicle tv on tmi.CUST_ID =tv.CUSTOMER_ID 
where a.is_deleted =0
and a.create_time >='2022-10-14' 
and a.create_time <'2022-10-18'
and a.post_id in ('JUqq6BS5dz','JAMf6yFNmi')
-- and tmi.MEMBER_PHONE=13516121816
