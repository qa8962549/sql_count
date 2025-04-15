

-- 兴趣圈发现圈子页面浏览
select date(client_time) 
,count(b.usr_merged_gio_id) pv
,count(distinct case when m.is_vehicle =1 then b.usr_merged_gio_id else null end) czuv
,count(distinct case when m.is_vehicle =0 then b.usr_merged_gio_id else null end) fsuv
,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
left join ods_memb.ods_memb_tc_member_info_cur m on a.var_memberId=m.id
where 1=1 
and event_time >= '2024-07-05'
and date(client_time) between '2024-07-29' and '2024-08-11'
and length(user)<9
and event_key='$page'
and $path in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController')
group by 1 with rollup

-- 兴趣圈详情页面浏览
select date(client_time) 
,count(b.usr_merged_gio_id) pv
,count(distinct case when m.is_vehicle =1 then b.usr_merged_gio_id else null end) czuv
,count(distinct case when m.is_vehicle =0 then b.usr_merged_gio_id else null end) fsuv
,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
left join ods_memb.ods_memb_tc_member_info_cur m on a.var_memberId=m.id
where 1=1 
and event_time >= '2024-06-13'
and date(client_time) between '2024-08-05' and '2024-08-11'
and length(user)<9
and event_key='$page'
and $path like '%mweb/circle/detail%'
group by 1 with rollup



-- 发帖
select 
formatDateTime(toDateTime(p.create_time), '%Y-%m')month
--date(p.create_time) 
,q.content
,q.join_count `兴趣圈总人数`
,count(distinct case when m.is_vehicle =1 then p.member_id else null end) czft
,count(distinct case when m.is_vehicle =0 then p.member_id else null end) fsft
,count(distinct p.member_id) ft
,count(case when m.is_vehicle =1 then 1 else null end) czft2
,count(case when m.is_vehicle =0 then 1 else null end) fsft2
,count(1) ft2
from ods_cmnt.ods_cmnt_tm_post_cur p
left join ods_memb.ods_memb_tc_member_info_cur m on p.member_id=m.id
join
(--圈子名称表
	select distinct p.coterie_id ,p.content,o.join_count join_count
	from ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d p
	left join ods_cocl.ods_cocl_tm_coterie_d o on o.coterie_id=p.coterie_id 
	where p.attr_type = 10010 
	and p.is_deleted =0
	and o.is_deleted=0
)q on p.club_id = q.coterie_id
where date(p.create_time) >= '2024-06-13' 
and date(p.create_time)<'2024-12-01'
group by 1,2,3 with ROLLUP 
order by 2,1


	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id  

-- 兴趣圈加入人数
	select 
	date(a.create_time),
	count(distinct case when m.is_vehicle=1 then  a.member_id else null end) cznum ,
	count(distinct case when m.is_vehicle=0 then  a.member_id else null end) fsnum ,
	count(distinct a.member_id) num 
	from ods_cocl.ods_cocl_tr_coterie_friends_d a 
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
	left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	where a.create_time>='2024-06-13'
	and a.create_time<today()
	and a.is_deleted=0
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	group by 1 with rollup
	order by 1 
	
-- 兴趣圈加入人数 -- 过去30天登录app人数
	select 
	count(distinct a.member_id) num 
	from ods_cocl.ods_cocl_tr_coterie_friends_d a 
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
	left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id
	join (
		--活动当日APP日活
		select distinct memberid
		from ods_oper_crm.ods_oper_crm_active_gio_d_si 
		where platform ='App'
		and date(dt)< '2024-09-27'
		and date(dt)>= '2024-08-27'
	)x on x.memberid=a.member_id 
	where 1=1
--	and a.create_time>='2024-06-13'
	and a.create_time<'2024-09-27'
	and a.is_deleted=0
	and a.audit_status=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	
	
	select 
	date(a.create_time),
	count(distinct case when m.is_vehicle=1 then  a.member_id else null end) cznum ,
	count(distinct case when m.is_vehicle=0 then  a.member_id else null end) fsnum ,
	count(distinct a.member_id) num 
	from ods_cocl.ods_cocl_tr_coterie_friends_d a 
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
	left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	where a.create_time>='2024-06-13'
	and a.create_time<'2024-11-01'
	and a.is_deleted=0
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	group by 1 with rollup
	order by 1 
	
----------------------------------------------------------

-- 兴趣圈加入人数_圈友非圈友
	select 
--	formatDateTime(toDateTime(a.create_time), '%Y-%m')month,
--	toYYYYMM(a.create_time),
	date(a.create_time),
	count(distinct case when m.is_vehicle=1 then  a.member_id else null end) `车主` ,
	count(distinct case when m.is_vehicle=0 then  a.member_id else null end) `非车主` ,
	count(distinct case when date(a2.create_time)<date(a.create_time) then a.member_id else null end) `圈友` ,
	count(distinct case when date(a2.create_time)=date(a.create_time) then a.member_id else null end) `非圈友` ,
	count(distinct a.member_id) num 
	from ods_cocl.ods_cocl_tr_coterie_friends_d a 
	left join 
	(
		select a.member_id member_id,
		ROW_NUMBER()over(partition by a.member_id order by a.create_time)rk,
		a.create_time create_time
		from ods_cocl.ods_cocl_tr_coterie_friends_d a 
		left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
		left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
		where 1=1
		and a.is_deleted=0
		and ca.attr_type = 10010  -- 筛选兴趣圈
		and o.is_deleted =0
		and ca.is_deleted =0 
--		and a.member_id ='8436261'
		)a2 on a2.member_id=a.member_id and a2.rk=1
	left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
	left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id
	where a.create_time>='2024-06-13'
	and a.create_time<'2024-12-01'
	and a.is_deleted=0
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	group by 1 with rollup
	order by 1 
	
-- 兴趣圈发现圈子页面浏览&详情页面浏览(兴趣圈活跃人数)
select 
formatDateTime(toDateTime(a.client_time), '%Y-%m') month
--date(client_time) 
,count(distinct case when m.is_vehicle =1 then b.usr_merged_gio_id else null end) `车主`
,count(distinct b.usr_merged_gio_id) - count(distinct case when m.is_vehicle =1 then b.usr_merged_gio_id else null end)  `非车主`
,count(distinct case when ifnull(date(a2.create_time),'2100-01-01')<date(client_time) then b.usr_merged_gio_id else null end) `圈友` 
,count(distinct b.usr_merged_gio_id)- count(distinct case when ifnull(date(a2.create_time),'2100-01-01')<date(client_time) then b.usr_merged_gio_id else null end) `非圈友`
,count(distinct b.usr_merged_gio_id) uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
left join ods_memb.ods_memb_tc_member_info_cur m on a.var_memberId=m.id
left join 
	(
		select a.member_id member_id,
		ROW_NUMBER()over(partition by a.member_id order by a.create_time)rk,
		a.create_time create_time
		from ods_cocl.ods_cocl_tr_coterie_friends_d a 
		left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
		left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
		where 1=1
		and a.is_deleted=0
		and ca.attr_type = 10010  -- 筛选兴趣圈
		and o.is_deleted =0
		and ca.is_deleted =0 
		and a.member_id is not null 
		)a2 on toInt32(a2.member_id) = toInt32(a.var_memberId) AND a2.rk = 1
where 1=1 
and event_time >= '2024-06-13'
and date(client_time) >='2024-06-13' 
and date(client_time) <'2024-11-01'
and length(user)<9
and event_key='$page'
and ($path in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController') or $path like '%mweb/circle/detail%')
group by 1 with rollup
order by 1 


	
--  兴趣圈活动数据
	select 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	c.campaign_name`活动名称`,
--	o.join_count `兴趣圈总人数`,
	c.sign_up_start_time `活动发起日期`,
	c.campaign_start_time`活动开始日期`,
	case when campaign_type=1 then '线上' else '线下' end `活动类型`,
	ifnull(x2.cznum,0)`报名车主`,
	ifnull(x2.fsnum,0)`报名非车主`,
	ifnull(x2.`圈友`,0)`报名圈友`,
	ifnull(x2.`非圈友`,0)`报名非圈友`,
	ifnull(x2.num,0)`报名合计人数`,
	ifnull(x3.cznum,0)`签到车主`,
	ifnull(x3.fsnum,0)`签到非车主`,
	ifnull(x3.`圈友`,0)`签到圈友`,
	ifnull(x3.`非圈友`,0)`签到非圈友`,
	ifnull(x3.num,0)`签到合计人数`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id  
	left join ods_camp.ods_camp_tm_campaign_d c on c.club_id=o.coterie_id
	left join  
		(
	--	活动报名人数  
		select oct.campaign_code campaign_code,
		count(distinct case when m.is_vehicle =1 then oc.member_id else null end) cznum, 
		count(distinct case when m.is_vehicle =0 then oc.member_id else null end) fsnum,
		count(distinct case when date(a2.create_time)<date(oct.sign_up_start_time) then oc.member_id else null end) `圈友` ,
		count(distinct case when date(a2.create_time)>=date(oct.sign_up_start_time) then oc.member_id else null end) `非圈友` ,
		count(distinct oc.member_id) num 
		from ods_camp.ods_camp_tm_campaign_d oct 
		left join ods_camp.ods_camp_tr_campaign_sign_up_d oc on oct.campaign_code=oc.campaign_code
		left join ods_memb.ods_memb_tc_member_info_cur m on oc.member_id::String=m.id::String
		left join 
			(
				select a.member_id member_id,
				ROW_NUMBER()over(partition by a.member_id order by a.create_time)rk,
				a.create_time create_time
				from ods_cocl.ods_cocl_tr_coterie_friends_d a 
				left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
				left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
				where 1=1
				and a.is_deleted=0
				and ca.attr_type = 10010  -- 筛选兴趣圈
				and o.is_deleted =0
				and ca.is_deleted =0 
				and a.member_id is not null 
				)a2 on toInt32(a2.member_id) = toInt32(oc.member_id) AND a2.rk = 1
		where oc.is_deleted=0
		and oc.create_time>='2024-06-13'
		and oc.create_time<'2024-11-01'
		group by 1
		order by 1
		)x2 on x2.campaign_code=c.campaign_code
	left join  
		(
	--	活动报名人数  
		select oct.campaign_code campaign_code,
		count(distinct case when m.is_vehicle =1 then oc.member_id else null end) cznum, 
		count(distinct case when m.is_vehicle =0 then oc.member_id else null end) fsnum,
		count(distinct case when date(a2.create_time)<date(oct.sign_up_start_time) then oc.member_id else null end) `圈友` ,
		count(distinct case when date(a2.create_time)>=date(oct.sign_up_start_time) then oc.member_id else null end) `非圈友` ,
		count(distinct oc.member_id) num 
		from ods_camp.ods_camp_tm_campaign_d oct 
		left join ods_camp.ods_camp_tr_campaign_sign_up_d oc on oct.campaign_code=oc.campaign_code
		left join ods_memb.ods_memb_tc_member_info_cur m on oc.member_id::String=m.id::String
		left join 
			(
				select a.member_id member_id,
				ROW_NUMBER()over(partition by a.member_id order by a.create_time)rk,
				a.create_time create_time
				from ods_cocl.ods_cocl_tr_coterie_friends_d a 
				left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
				left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
				where 1=1
				and a.is_deleted=0
				and ca.attr_type = 10010  -- 筛选兴趣圈
				and o.is_deleted =0
				and ca.is_deleted =0 
				and a.member_id is not null 
				)a2 on toInt32(a2.member_id) = toInt32(oc.member_id) AND a2.rk = 1
		where oc.is_deleted=0
		and oc.create_time>='2024-06-13'
		and oc.create_time<'2024-11-01'
		and sign_up_status=2 -- 签到报名人数
		group by 1
		order by 1
		)x3 on x3.campaign_code=c.campaign_code   	
	where 1=1
	and c.campaign_start_time>='2024-06-13'
	and c.campaign_start_time<'2024-11-01'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	and c.is_deleted=0 
	order by 2 desc 
	
--兴趣圈活动数据详情
	select 
	ca.content `兴趣圈名称`,
	c.campaign_name`活动名称`,
--	c.sign_up_start_time `活动发起日期`,
	c.campaign_start_time`活动开始日期`,
	case when campaign_type=1 then '线上' else '线下' end `活动类型`,
	x2.member_id `参与活动的用户ID`,
	x2.member_name `参与的用户昵称`
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id  
	left join ods_camp.ods_camp_tm_campaign_d c on c.club_id=o.coterie_id
	left join  
		(
	--	活动签到报名人数  
		select campaign_code,
		oc.member_id,
		m.member_name
		from ods_camp.ods_camp_tr_campaign_sign_up_d oc 
		left join ods_memb.ods_memb_tc_member_info_cur m on oc.member_id::String=m.id::String
		where oc.is_deleted=0
		and sign_up_status=2 -- 签到报名人数
		and oc.create_time>='2024-06-13'
		and oc.create_time<'2024-11-01'
		)x2 on x2.campaign_code=c.campaign_code
	where 1=1
	and c.campaign_start_time>='2024-06-13'
	and c.campaign_start_time<'2024-11-01'
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	and c.is_deleted=0 
	order by 3 

---------------------------------------------------------------------------------------------------------
-- 兴趣圈发现圈子页面浏览id
select distinct a.var_memberId
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on a.gio_id=b.gio_id
where 1=1 
and event_time >= '2024-06-01'
and date(client_time) between '2024-06-01' and '2024-07-31'
and length(user)<9
and event_key='$page'
and $path in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController')


--UV（浏览推荐—此地/ 浏览过活动/发现圈子页面）
select count(distinct distinct_id)
from(-- 浏览过推荐的用户——(漏斗)浏览此地
	SELECT DISTINCT a.distinct_id
	from dwd_23.dwd_23_gio_tracking a
	join(-- 浏览推荐的用户
		SELECT distinct_id,time
    	from dwd_23.dwd_23_gio_tracking
    	where 1=1
    	and date(event_time) >= '2024-08-05'
    	and date(time) between '2024-08-05' and '2024-08-11'
    	and event='Page_view'
    	and page_title='推荐'
		and var_bussiness_name='社区'
	)b on a.distinct_id=b.distinct_id
	where 1=1
	and date(a.event_time) >= '2024-08-05'
	and a.time >b.time
	and date(a.time) between '2024-08-05' and '2024-08-11'
	and a.event='Page_view'
	and a.page_title='此地'
	and a.var_bussiness_name='社区'
	union all
	-- 浏览过活动页的
	select DISTINCT d.distinct_id 
	from dwd_23.dwd_23_gio_tracking d
	where d.event='Page_view'
	and date(event_time) >= '2024-08-05'
	and date(time) between '2024-08-05' and '2024-08-11'
	and d.var_activity_id in 
		()
	union all
	-- 发现圈子页面
	select distinct distinct_id
	from dwd_23.dwd_23_gio_tracking
	where event_time >= '2024-08-05'
	and date(`time`) between '2024-08-05' and '2024-08-11'
	and event = '$page'
	and `$url` in ('/ActivityPageView' ,'/Volvo_Cars.DiscoverCircleViewController')
)z




	-- 发现圈子页面
	select distinct distinct_id,`$url` ,event 
	from dwd_23.dwd_23_gio_tracking
	where event_time >= '2024-08-05'
--	and date(`time`) between '2024-08-05' and '2024-08-11'
--	and event = '$page'
	and `$url` like '%https://newbie.digitalvolvo.com/onlineactivity/testdrive/index.html#/testDrive%'

	select *
	from ods_cmnt.ods_cmnt_tc_case_config_d
	where object_type =149
	
------------------------------------20250503 兴趣圈总览
--兴趣圈拉新数据
	select 
	distinct 
--	o.coterie_id ,
	ca.content `兴趣圈名称`,
	bq.option_content `类型`,
	concat(o.province_name,o.city_name) `所在地`,
	o.applicant_name `兴趣圈圈主名称`,
	o.member_id `圈主ID`,
	o.phone `圈主手机号`,
	x2.`兴趣圈总人数`,
	x2. `兴趣圈车主人数`,
	x2. `兴趣圈粉丝人数`,
	x3.`圈内发帖量PV-累计`,
	x3.`圈内发帖人数UV-累计` ,
	x3.`圈内发帖量PV-25年1月-2月` ,
	x3.`圈内发帖人数UV-25年1月-2月` ,
	c1.`累计活动发起数` ,
	c.`活动报名PV` ,
	c.`活动报名UV` ,
	c2.`最近一次活动发起时间` 
	from ods_cocl.ods_cocl_tm_coterie_d o 
	left join ods_cmnt.ods_cmnt_tc_case_config_d bq on o.label_type =bq.task_id
	left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
	left join 
		(
		select 
		a.coterie_id,
		count(distinct case when a.create_time<'2025-03-01' then a.member_id else null end) `兴趣圈总人数`,
		count(distinct case when a.create_time<'2025-03-01' and m.is_vehicle=1 then a.member_id else null end)  `兴趣圈车主人数`,
		count(distinct case when a.create_time<'2025-03-01' and m.is_vehicle=0 then a.member_id else null end)  `兴趣圈粉丝人数`
		from ods_cocl.ods_cocl_tr_coterie_friends_d a 
		left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::String=m.id::String
		where 1=1
		and a.audit_status=1
		and a.create_time>='2024-06-01'
		and a.create_time <'2025-03-01'
		group by 1 
		order by 1 
		)x2 on x2.coterie_id = o.coterie_id
	left join 
		(--兴趣圈用户内容数据
		select 
		o.coterie_id coterie_id,
--		ca.content `兴趣圈名称`,
		count(p.post_id) `圈内发帖量PV-累计`,
		count(distinct p.member_id) `圈内发帖人数UV-累计`,
		count(case when p.create_time>='2025-01-01' and p.create_time<'2025-03-01' then p.post_id else null end) `圈内发帖量PV-25年1月-2月`,
		count(distinct case when p.create_time>='2025-01-01' and p.create_time<'2025-03-01' then p.member_id else null end) `圈内发帖人数UV-25年1月-2月`
		from ods_cocl.ods_cocl_tm_coterie_d o 
		left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
		left join ods_cmnt.ods_cmnt_tm_post_cur p on toString(p.club_id)=toString(o.coterie_id)
		where 1=1
		and ca.attr_type = 10010  -- 筛选兴趣圈
		and o.is_deleted =0
		and ca.is_deleted =0 
		and p.create_time>='2024-06-01'
		and p.create_time<'2025-03-01'
		group by 1
		order by 2 desc )x3 on x3.coterie_id = o.coterie_id
	left join 
		(
		select club_id,
		count(campaign_code) `累计活动发起数`
		from 
		ods_camp.ods_camp_tm_campaign_d 
		where create_time>='2024-06-01'
		and create_time<'2025-03-01'
		group by 1 
		)c1 on c1.club_id=o.coterie_id
	left join 
		(
		select club_id,
		row_number()over(partition by club_id order by create_time desc) rk,
		create_time `最近一次活动发起时间`
		from ods_camp.ods_camp_tm_campaign_d 
		where create_time>='2024-06-01'
		and create_time<'2025-03-01'
--		group by 1 
		)c2 on c2.club_id=o.coterie_id and c2.rk=1
	left join 
		(select c.club_id club_id,
		count(oc.member_id) `活动报名PV`,
		count(distinct oc.member_id) `活动报名UV`
		from ods_camp.ods_camp_tm_campaign_d c 
		left join  
			(
		--	活动报名人数  
			select oct.campaign_code campaign_code,
			oc.member_id
			from ods_camp.ods_camp_tm_campaign_d oct 
			left join ods_camp.ods_camp_tr_campaign_sign_up_d oc on oct.campaign_code=oc.campaign_code
			left join ods_memb.ods_memb_tc_member_info_cur m on oc.member_id::String=m.id::String
			left join 
				(
					select a.member_id member_id,
					ROW_NUMBER()over(partition by a.member_id order by a.create_time)rk,
					a.create_time create_time
					from ods_cocl.ods_cocl_tr_coterie_friends_d a 
					left join ods_cocl.ods_cocl_tm_coterie_d o on a.coterie_id = o.coterie_id
					left join ods_cocl.ods_cocl_tt_coterie_attr_audit_approve_d ca on o.coterie_id =ca.coterie_id 
					where 1=1
					and a.is_deleted=0
					and ca.attr_type = 10010  -- 筛选兴趣圈
					and o.is_deleted =0
					and ca.is_deleted =0 
					and a.member_id is not null 
					)a2 on toInt32(a2.member_id) = toInt32(oc.member_id) AND a2.rk = 1
			where oc.is_deleted=0
			and oc.create_time>='2024-06-01'
			and oc.create_time<'2025-03-01'
	--		group by 1
	--		order by 1
			)x4 on x4.campaign_code=c.campaign_code
			group by 1 
			order by 1 
		)c on c.club_id=o.coterie_id
	where 1=1
	and ca.attr_type = 10010  -- 筛选兴趣圈
	and o.is_deleted =0
	and ca.is_deleted =0 
	order by 2 desc 
	

