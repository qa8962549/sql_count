--自动推送欢迎语
select x.*
from 
(
-- 专属权益：注册会员
select 
'1' a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id  else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%automatic_reply%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%register_member%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
-- 我是车主：车主服务
select 
'2' a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>=9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>=9 then distinct_id else null end) "游客UV"
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%automatic_reply%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%car_owner_service%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--我是粉丝：爱车首页
select 
'3' a ,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%automatic_reply%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%car_lovers_homepage%'
and event_time>='2024-12-01' 
and date>='2024-12-01'
and date<'2025-01-01'
--union all
-- 关于EX90：小程序ex90专区
--select 
--'4' a,
--count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
--count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
--count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
--count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
--count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV",
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
--from dwd_23.dwd_23_gio_tracking
--where 1=1
--and event='$MPViewScreen'
--and `$url` like '%miniprogram%'
--and `$url` like '%volvo_world%'
--and `$url` like '%automatic_reply%'
--and `$url` like'%volvo_world_servicecenter%'
--and `$url` like '%EX90%'
--and event_time>='2024-12-01' and date>='2024-12-01'
--and date<'2025-01-01'
union all
--用户口碑：口碑专区
select 
'5' a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%opinion_zone%'
and `$url` like'%servicecenter_autoreply%'
--and `$url` like '%EX90%'
and event_time>='2024-12-01' 
and date>='2024-12-01'
and date<'2025-01-01'
union all 
--推荐购车：推荐享好礼
select 
'6' a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%0b224030l36a%'
and `$url` like'%240730_tdrive%'
and event_time>='2024-12-01' 
and date>='2024-12-01'
and date<'2024-12-01'
union all 
--邀你试驾卡片
select 
'7' a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
--count(distinct case when var_is_bind='ture' or var_is_bind='1' and `$is_first_day` =1 then distinct_id else null end) "拉新车主",
--count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 and `$is_first_day` =1 then distinct_id else null end) "拉新粉丝"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%wechat_official_account%'
and `$url` like'%202312_test_drive_gift%'
and `$url` like '%auto%'
and event_time>='2024-12-01' 
and date>='2024-12-01'
and date<'2025-01-01') x order by 1

-- 拉新人数（App/Mini注册会员） 专属权益：注册会员
select x.*
from 
	(
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
		and event='$MPViewScreen'
		and `$url` like '%miniprogram%'
		and `$url` like '%volvo_world%'
		and `$url` like '%automatic_reply%'
		and `$url` like'%volvo_world_servicecenter%'
		and `$url` like '%register_member%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 我是车主：车主服务
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%automatic_reply%'
	and `$url` like'%volvo_world_servicecenter%'
	and `$url` like '%car_owner_service%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 我是粉丝：爱车首页
	select 
	3,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%automatic_reply%'
	and `$url` like'%volvo_world_servicecenter%'
	and `$url` like '%car_lovers_homepage%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 用户口碑：口碑专区
	select 
	4,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%opinion_zone%'
	and `$url` like'%servicecenter_autoreply%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 推荐购车：推荐享好礼
	select 
	5,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%recommended_purchase%'
	and `$url` like'%servicecenter_autoreply%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 邀你试驾卡片
	select 
	6,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%0b224030l36a%'
	and `$url` like'%240730_tdrive%'
		and event_time>='2024-08-01' and date>='2024-08-01'
		and date<'2024-12-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-08-01'
		and m.create_time <'2024-12-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	)x
order by 1

select *
	from  ods_gio.ods_gio_user_d 
	limit 10 

-- 邀约试驾 自动推送欢迎语：邀你试驾卡片
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	o.`id_$basic_userId` distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event='$MPViewScreen'
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%0b224030l36a%'
	and `$url` like'%240730_tdrive%'
	and event_time>='2024-08-01' and date>='2024-08-01'
	and date<'2024-12-01'
	order by 2 desc 
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	toDateTime(ta.CREATED_AT)  `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID distinct_id,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	tm2.model_name `预约车型`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE ta.CREATED_AT >= '2024-08-01'
	AND ta.CREATED_AT <'2024-12-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约


-- 养修预约 我是车主：车主服务
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	o.`id_$basic_userId` distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event='$MPViewScreen'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%automatic_reply%'
	and `$url` like'%volvo_world_servicecenter%'
	and `$url` like '%car_owner_service%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	) a
join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "distinct_id",
		       tam.OWNER_ONE_ID,
		       ta.CUSTOMER_NAME "联系人姓名",
		       ta.CUSTOMER_PHONE "联系人手机号",
		       tmi.id "会员ID",
		       tmi.member_phone "沃世界绑定手机号",
		       tam.CAR_MODEL "预约车型",
		       tam.CAR_STYLE "预约车款",
		       tam.VIN "车架号",
		       case when tam.IS_TAKE_CAR = 10041001 then '是'
		    when tam.IS_TAKE_CAR = 10041002 then '否'
		     end  "是否取车",
		       case when tam.IS_GIVE_CAR = 10041001 then '是'
		         when tam.IS_GIVE_CAR = 10041002 then '否'
		       end "是否送车",
		       tam.MAINTAIN_STATUS "养修状态code",
		       tc.CODE_CN_DESC "养修状态",
		       tam.CREATED_AT "创建时间",
		       tam.UPDATED_AT "修改时间",
		       ta.CREATED_AT as CREATED_AT,-- "预约时间",
		       tam.WORK_ORDER_NUMBER "工单号"
		from ods_cyap.ods_cyap_tt_appointment_d ta
		left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID
		left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
		left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
		left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
		where ta.CREATED_AT >= '2024-12-01'
		and tam.IS_DELETED <>1
		AND ta.CREATED_AT < '2025-01-01'
		and ta.DATA_SOURCE ='C'
		and ta.APPOINTMENT_TYPE =70691005
		and ta.ONE_ID is not null) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10

-- 预约试驾 菜单栏：预约试驾
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	select 
	o.`id_$basic_userId` distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%miniprogram%'
	and `$url` like'%wow_select_car_testdrivde%'
	and `$url` like '%service_menu_bar%'
	and event_time>='2024-12-01' 
	and date>='2024-12-01'
	and date<'2025-01-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID distinct_id,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	tm2.model_name `预约车型`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE ta.CREATED_AT >= '2024-12-01'
	AND ta.CREATED_AT <'2025-01-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约





--养修预约明细 菜单栏
select 
count(distinct a.distinct_id)
from (
	select 
	o.`id_$basic_userId` distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%maintenance_appointment%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	) a
global join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "distinct_id",
		       tam.OWNER_ONE_ID,
		       ta.CUSTOMER_NAME "联系人姓名",
		       ta.CUSTOMER_PHONE "联系人手机号",
		       tmi.id "会员ID",
		       tmi.member_phone "沃世界绑定手机号",
		       tam.CAR_MODEL "预约车型",
		       tam.CAR_STYLE "预约车款",
		       tam.VIN "车架号",
		       case when tam.IS_TAKE_CAR = 10041001 then '是'
		    when tam.IS_TAKE_CAR = 10041002 then '否'
		     end  "是否取车",
		       case when tam.IS_GIVE_CAR = 10041001 then '是'
		         when tam.IS_GIVE_CAR = 10041002 then '否'
		       end "是否送车",
		       tam.MAINTAIN_STATUS "养修状态code",
		       tc.CODE_CN_DESC "养修状态",
		       tam.CREATED_AT "创建时间",
		       tam.UPDATED_AT "修改时间",
		       ta.CREATED_AT as CREATED_AT,-- "预约时间",
		       tam.WORK_ORDER_NUMBER "工单号"
		from ods_cyap.ods_cyap_tt_appointment_d ta
		left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID
		left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
		left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
		left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
		where ta.CREATED_AT >= '2024-12-01'
		and tam.IS_DELETED <>1
		AND ta.CREATED_AT < '2025-01-01'
		and ta.DATA_SOURCE ='C'
		and ta.APPOINTMENT_TYPE =70691005
		and ta.ONE_ID is not null) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10


	


		


-----------T+1&T+2推送---------------------------------------------------------------------------
select x.*
from 
(
-- 1仅点击“订阅”
select 
'1'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%9SeSJFOo5p%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%subscribes_only%'
and `$url` like'%new_exploration_guides%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
-- 1点击”订阅“及“预约试驾”
select 
'2'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+1_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%subscriberortestdrive%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--3点击“订阅”及“注册会员”
select 
'3'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%9SeSJFOo5p%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%subscribes_only%'
and `$url` like'%new_exploration_guides%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all
-- 1点击“订阅”及“注册会员”，“预约试驾”
select 
'4'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+1_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%register_member%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all
--1点击“订阅”及“车主服务”
select 
'5'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+1_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%car_owner_service%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--1点击“订阅”及“爱车首页”
select 
'6'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+1_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%car_lovers_homepage%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2仅点击“订阅”
select 
'7'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%only_subscriber%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2点击”订阅“及“预约试驾”
select 
'8'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%subscriberortestdrive2%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2点击“订阅”及“注册会员”
select 
'9'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
and `$url` like '%KgeU64RmUD%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%register_member2%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2点击“订阅”及“注册会员”，“预约试驾”
select 
'10'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%register_member%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2点击“订阅”及“车主服务”
select 
'11'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%volvo_world_servicecenter%'
and `$url` like '%car_owner_service2%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
union all 
--2点击“订阅”及“爱车首页”
select 
'12'::int a,
count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
from dwd_23.dwd_23_gio_tracking
where 1=1
and event='$MPViewScreen'
--and `$url` like '%FO4K4QrVFS%'
and `$url` like '%miniprogram%'
and `$url` like '%volvo_world%'
and `$url` like '%T+2_push%'
and `$url` like'%servicecenter_push%'
and `$url` like '%test_drive%'
and event_time>='2024-12-01' and date>='2024-12-01'
and date<'2025-01-01'
) x order by 1

-------------------------------------菜单栏------------------------------------------
select x.*
from 
	(
	-- 官方直售
	select 
	'1'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	and `$url` like '%https://ds-f2e.digitalvolvo.com/webroot-h5/index.html%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=direct_sale%'
	and `$url` like '%promotion_activity=direct_sale%'
	and `$url` like'%promotion_supplement=service_menubar%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	-- 探索车型
	select 
	'2'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=explore_vehicle%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--金融方案
	select 
	'3'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%9SeSJFOo5p%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like'%promotion_supplement=financial_solutions%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all
	-- 预约试驾
	select 
	'4'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
--	and event='$MPViewScreen'
--	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%miniprogram%'
	and `$url` like'%wow_select_car_testdrivde%'
	and `$url` like '%service_menu_bar%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all
	--查找经销商
	select 
	'5'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=find_dealers%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--沃世界主场
	select 
	'6'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=volvo_world%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--沃商城
	select 
	'7'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=volvo_store%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--车主俱乐部
	select 
	'8'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=owners_club%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
		union all 
	--守护计划
	select 
	'9'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=volvo%'
	and `$url` like'%promotion_activity=240723_guardplan%'
	and `$url` like '%promotion_supplement=4n216052n56r%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--推荐购
	select 
	'10'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%KgeU64RmUD%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=recommended_purchase%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--下载APP
	select 
	'11'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
--	and event='$APPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=wechat_official_account%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu%'
	--and `$url` like'%volvo_world_servicecenter%'
	--and `$url` like '%register_member%'
	and event_time>='2024-12-01' 
	and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--养修预约
	select 
	'12'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=maintenance_appointment%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--沃家客服
	select '13'::int a,toUInt64(0) ,toUInt64(0),toUInt64(0),toUInt64(0),toUInt64(0),toUInt64(0)
	union all 
	--上门取送车
	select 
	'14'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=home_delivery%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--官方回购
	select 
	'15'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	and `$url` like '%ty8oE4rf7w%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=official_repurchase%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	union all 
	--充电桩安装
	select 
	'16'::int a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='$MPViewScreen'
	--and `$url` like '%FO4K4QrVFS%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=charge_station_install%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
) x order by 1


-- 拉新人数（App/Mini注册会员） 菜单栏
select x.*
from 
	(
--	 官方直售
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
		and event='$MPViewScreen'
	and `$url` like '%https://ds-f2e.digitalvolvo.com/webroot-h5/index.html%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=direct_sale%'
	and `$url` like '%promotion_activity=direct_sale%'
	and `$url` like'%promotion_supplement=service_menubar%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 官方直售
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=explore_vehicle%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 金融方案
	select 
	3,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like'%promotion_supplement=financial_solutions%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 预约试驾
	select 
	4,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%volvo_world%'
	and `$url` like '%miniprogram%'
	and `$url` like'%wow_select_car_testdrivde%'
	and `$url` like '%service_menu_bar%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 查找经销商
	select 
	5,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=find_dealers%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 沃世界主场
	select 
	6,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=volvo_world%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 沃商城
	select 
	7,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=volvo_store%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 车主俱乐部
	select 
	8,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=owners_club%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 守护计划
	select 
	8.5,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=volvo%'
	and `$url` like'%promotion_activity=240723_guardplan%'
	and `$url` like '%promotion_supplement=4n216052n56r%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 推荐购
	select 
	9,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=recommended_purchase%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 下载APP
	select 
	10,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and `$url` like '%promotion_channel_type=wechat_official_account%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 养修预约
	select 
	11,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=maintenance_appointment%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
	--沃家客服
	select '12'::int a,toUInt64(0) ,toUInt64(0)
		union all 	
	-- 拉新人数（App/Mini注册会员） 上门取送车
	select 
	13,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=home_delivery%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 官方回购
	select 
	14,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%ty8oE4rf7w%'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=official_repurchase%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
				union all 	
	-- 拉新人数（App/Mini注册会员） 充电桩安装
	select 
	15,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
	and event='$MPViewScreen'
	and `$url` like '%promotion_channel_type=miniprogram%'
	and `$url` like '%promotion_channel_sub_type=volvo_world%'
	and `$url` like '%promotion_methods=menu_bar%'
	and `$url` like'%promotion_activity=volvo_world_servicecenter%'
	and `$url` like '%promotion_supplement=charge_station_install%'
		and event_time>='2024-12-01' and date>='2024-12-01'
		and date<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	)x
order by 1





----------------------推文----------------------------
	select x.*
from 
	(
--预约试驾： 预约试驾
	select 
	'1' a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
--	and event ='$MPViewScreen'
--	and event='$AppViewScreen'
--	and event='Page_view'
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%IBCRMJUNALL000482024VCCN%'
	and `$url` like '%52Apm1Iw2M%'
	and event_time>='2024-12-01' 
	and date>='2024-12-01'
	and date<'2025-01-01'
union all 
	select 
	'2' a,
	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
	from dwd_23.dwd_23_gio_tracking
	where 1=1
--	and event ='$MPViewScreen'
--	and event='$AppViewScreen'
--	and event='Page_view'
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn4%'
	and `$url` like'%241024_11sjhd%'
    and `$url` like'%3b277928i70n%'
	and event_time>='2024-12-01' 
	and date>='2024-12-01'
	and date<'2025-01-01'
)x order by 1

-- 拉新人数（App/Mini注册会员） 推文
select x.*
from 
	(
--	 预约试驾
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
--	and event ='$MPViewScreen'
--	and event='$AppViewScreen'
--	and event='Page_view'
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%IBCRMOCTALL000952024VCCN%'
	and event_time>='{tt}' and date>='{start_day}'
	and date<'{end_day}'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '{start_day}'
		and m.create_time <'{end_day}'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.distinct_id end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.distinct_id end)`拉新粉丝人数`
	from
		(select 
		distinct_id,toDateTime(left(time,19)) time
		from dwd_23.dwd_23_gio_tracking
		where 1=1
--	and event ='$MPViewScreen'
--	and event='$AppViewScreen'
--	and event='Page_view'
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn%'
	and `$url` like'%241024_11sjhd%'
    and `$url` like'%3b277928i70n%'
	and event_time>='{tt}' and date>='{start_day}'
	and date<'{end_day}'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '{start_day}'
		and m.create_time <'{end_day}'
	)b on a.distinct_id=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
)x order by 1 
	
-- 养修预约 我是车主：车主服务
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn%'
	and `$url` like'%20240428_limited_testdrive%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	) a
join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "distinct_id",
		       tam.OWNER_ONE_ID,
		       ta.CUSTOMER_NAME "联系人姓名",
		       ta.CUSTOMER_PHONE "联系人手机号",
		       tmi.id "会员ID",
		       tmi.member_phone "沃世界绑定手机号",
		       tam.CAR_MODEL "预约车型",
		       tam.CAR_STYLE "预约车款",
		       tam.VIN "车架号",
		       case when tam.IS_TAKE_CAR = 10041001 then '是'
		    when tam.IS_TAKE_CAR = 10041002 then '否'
		     end  "是否取车",
		       case when tam.IS_GIVE_CAR = 10041001 then '是'
		         when tam.IS_GIVE_CAR = 10041002 then '否'
		       end "是否送车",
		       tam.MAINTAIN_STATUS "养修状态code",
		       tc.CODE_CN_DESC "养修状态",
		       tam.CREATED_AT "创建时间",
		       tam.UPDATED_AT "修改时间",
		       ta.CREATED_AT as CREATED_AT,-- "预约时间",
		       tam.WORK_ORDER_NUMBER "工单号"
		from ods_cyap.ods_cyap_tt_appointment_d ta
		left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID
		left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
		left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
		left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
		where ta.CREATED_AT >= '2024-12-01'
		and tam.IS_DELETED <>1
		AND ta.CREATED_AT < '2025-01-01'
		and ta.DATA_SOURCE ='C'
		and ta.APPOINTMENT_TYPE =70691005
		and ta.ONE_ID is not null) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10
	


-- 邀约试驾 自动推送欢迎语：邀你试驾卡片
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn%'
	and `$url` like'%20240520_testdrive%'
	and event_time>='2024-12-01' and date>='2024-12-01'
	and date<'2025-01-01'
	order by 2 desc 
	) a
join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	toDateTime(ta.CREATED_AT)  `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID distinct_id,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	tm2.model_name `预约车型`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE ta.CREATED_AT >= '2024-12-01'
	AND ta.CREATED_AT <'2025-01-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约

-- 预约试驾 菜单栏：预约试驾
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	distinct_id,
	toDateTime(left(time,19)) time
	from dwd_23.dwd_23_gio_tracking
	where 1=1
--	and event ='$MPViewScreen'
--	and event='$AppViewScreen'
--	and event='Page_view'
	and event='Page_entry'
--	and event='Button_click'
	and `$url` like '%miniprogram%'
	and `$url` like '%volvo_world%'
	and `$url` like '%btn%'
	and `$url` like'%240625_timeddrive%'
	and event_time>='2024-12-01' and date>='2025-01-01'
	and date<'2024-08-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID distinct_id,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	tm2.model_name `预约车型`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE ta.CREATED_AT >= '2025-01-01'
	AND ta.CREATED_AT <'2024-08-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.distinct_id) =toString(a.distinct_id)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约





-----------------------------7月--------------------------
--充电桩安装
--	select 
--	'15' a,
--	count(case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主PV",
--	count(case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝PV",
--	count(case when length(distinct_id)>9 then distinct_id else null end) "游客PV",
--	count(distinct case when var_is_bind='ture' or var_is_bind='1' then distinct_id else null end) "车主UV",
--	count(distinct case when var_is_bind='false' or var_is_bind='0' and length(distinct_id)<9 then distinct_id else null end) "粉丝UV",
--	count(distinct case when length(distinct_id)>9 then distinct_id else null end) "游客UV"
--	from dwd_23.dwd_23_gio_tracking
--	where 1=1
--	and event='$MPViewScreen'
--	and `$url` like '%FO4K4QrVFS%'
--	and `$url` like '%promotion_channel_type=miniprogram%'
--	and `$url` like '%promotion_channel_sub_type=volvo_world%'
--	and `$url` like '%tweets%'
--	and `$url` like'%202307_gift_for_recommend_tutorial%'
--	and `$url` like '%charge_station_install%'
--	and event_time>='2024-12-01' and date>='2024-12-01'
--	and date<'2025-01-01'