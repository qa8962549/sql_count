
-- PVUV  5jKcBirg9Q
-- 文章明细	

select m.is_vehicle,o.ref_id,c.title,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
-- 				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
-- 				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
-- 				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) '点赞量'
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) '收藏量'
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) '转发量'
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
	and date_create <='2022-08-31 23:59:59' and date_create >='2022-08-22'
	and o.ref_id='5jKcBirg9Q'  
	GROUP BY 1

--- 活动评论数据
select 
'01评论',
count(case when x.IS_VEHICLE=1 then x.评价内容 else null end) 车主,
count(case when x.IS_VEHICLE=0 then x.评价内容 else null end) 粉丝
from 
(
select
teh.object_id 活动ID,
teh.content 评价内容,
case when teh.is_top = '10041001' then '是'
	else '否' end '是否置顶',
teh.create_time 评论时间,
teh.evaluation_source 评论来源,
teh.user_id 评论用户ID,
teh.name 评论姓名,
teh.mobile 评论用户手机号,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
tmi.IS_VEHICLE ,
teh.liked_count 点赞数,
tep.picture_url 
from comment.tt_evaluation_history teh
left join comment.tc_evaluation_picture tep on tep.evaluation_id = teh.id 
left join `member`.tc_member_info tmi on teh.mobile = tmi.MEMBER_PHONE 
where teh.object_id = '5jKcBirg9Q'
and teh.create_time >= '2022-08-22'
and teh.create_time <= '2022-08-31 23:59:59'
and teh.is_deleted = 0
order by teh.create_time desc
) x
union all
-- 拉新
select 
'02拉新',
'0',
count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create <='2022-08-31 23:59:59' and l.date_create >='2022-08-22' 
and l.ref_id='5jKcBirg9Q' and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE)
union all
-- 激活
select '03激活沉睡用户数' 类目
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
			where l.date_create <='2022-08-31 23:59:59' and l.date_create >='2022-08-22'
			and l.ref_id='5jKcBirg9Q' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) 
order by 1

	
-- 3-1、渠道数据
select
'01首页 置顶banner UV',
COUNT(distinct case when t.`data` like '%2406F69E277D4FBF8DC3C0AAEF1B3908%' and m.IS_VEHICLE =1 then t.usertag else null end) as '首页 置顶banner UV',
COUNT(distinct case when t.`data` like '%2406F69E277D4FBF8DC3C0AAEF1B3908%' and m.IS_VEHICLE =0 then t.usertag else null end) as '首页 置顶banner UV'
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.date<='2022-08-31 23:59:59'
union all
select
'02首页 活动banner UV',
COUNT(distinct case when t.`data` like '%38C65A6A827B49FC80AF400D3A41263E%' and m.IS_VEHICLE =1 then t.usertag else null end) as '首页 活动banner UV',
COUNT(distinct case when t.`data` like '%38C65A6A827B49FC80AF400D3A41263E%' and m.IS_VEHICLE =0 then t.usertag else null end) as '首页 活动banner UV'
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.date<='2022-08-31 23:59:59'
union all 
select
'03弹窗 UV',
COUNT(distinct case when t.`data` like '%5F67C3AB93924D95BA9A86A13B7AB16E%' and m.IS_VEHICLE =1 then t.usertag else null end) as '弹窗车主UV',
COUNT(distinct case when t.`data` like '%5F67C3AB93924D95BA9A86A13B7AB16E%' and m.IS_VEHICLE =0 then t.usertag else null end) as '弹窗粉丝UV'
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.date<='2022-08-31 23:59:59'
union all 
select
'04太阳码扫码PV',
COUNT(case when t.`data` like '%E5EE4A53D65C41D6ABC7EEF1EC7761B2%' and m.IS_VEHICLE =1 then t.usertag else null end) as '太阳码车主PV',
COUNT(case when t.`data` like '%E5EE4A53D65C41D6ABC7EEF1EC7761B2%' and m.IS_VEHICLE =0 then t.usertag else null end) as '太阳码粉丝PV'
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.date<='2022-08-31 23:59:59'
union all 
select
'05太阳码扫码UV',
COUNT(distinct case when t.`data` like '%E5EE4A53D65C41D6ABC7EEF1EC7761B2%' and m.IS_VEHICLE =1 then t.usertag else null end) as '太阳码车主PV',
COUNT(distinct case when t.`data` like '%E5EE4A53D65C41D6ABC7EEF1EC7761B2%' and m.IS_VEHICLE =0 then t.usertag else null end) as '太阳码粉丝PV'
from track.track t
join `member`.tc_member_info m on t.usertag = CAST(m.USER_ID as VARCHAR) and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.date<='2022-08-31 23:59:59'
order by 1



-- 成功提交养修预约人数
select COUNT(b.养修预约ID)成功提交养修预约人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.`date` <= '2022-08-31 23:59:59'
and t.`data` like '%4082B6E32C364A14AD86FBB5631AB7AA%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-08-22'
and ta.CREATED_AT < now()
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID

-- 成功提交养修预约并进厂人数
select COUNT(b.养修预约ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.`date` <= '2022-08-31 23:59:59'
and t.`data` like '%4082B6E32C364A14AD86FBB5631AB7AA%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = "10041001" then "是" 
    when tam.IS_TAKE_CAR = "10041002" then "否" 
     end  "是否取车",
       case when tam.IS_GIVE_CAR = "10041001" then "是"
         when tam.IS_GIVE_CAR = "10041002" then "否"
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta.CREATED_AT "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-08-22'
and ta.CREATED_AT < now()
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
