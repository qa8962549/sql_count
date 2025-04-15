
--自动推送欢迎语
select x.*
from 
(
-- 专属权益：注册会员
select 
'1' a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page' -- $page
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%automatic_reply%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%register_member%'
and event_time>='2024-12-01' 
and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
-- 我是车主：车主服务
select 
'2' a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>=9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>=9 then user else null end) "游客UV"
--count(distinct case when var_is_bind='1' and `$is_first_day` =1 then user else null end) "拉新车主",
--count(distinct case when var_is_bind='0' and length(user)<9 and `$is_first_day` =1 then user else null end) "拉新粉丝"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%automatic_reply%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%car_owner_service%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--我是粉丝：爱车首页
select 
'3' a ,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
--count(distinct case when var_is_bind='1' and `$is_first_day` =1 then user else null end) "拉新车主",
--count(distinct case when var_is_bind='0' and length(user)<9 and `$is_first_day` =1 then user else null end) "拉新粉丝"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%automatic_reply%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%car_lovers_homepage%'
and event_time>='2024-12-01' 
and client_time>='2024-12-01'
and client_time<'2025-01-01'
--union all
-- 关于EX90：小程序ex90专区
--select 
--'4' a,
--count(case when var_is_bind='1' then user else null end) "车主PV",
--count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
--count(case when length(user)>9 then user else null end) "游客PV",
--count(distinct case when var_is_bind='1' then user else null end) "车主UV",
--count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
--count(distinct case when length(user)>9 then user else null end) "游客UV",
--count(distinct case when var_is_bind='1' and `$is_first_day` =1 then user else null end) "拉新车主",
--count(distinct case when var_is_bind='0' and length(user)<9 and `$is_first_day` =1 then user else null end) "拉新粉丝"
--from ods_gio.ods_gio_event_d
--where 1=1
--and event_key='$page'
--and `$query` like '%miniprogram%'
--and `$query` like '%volvo_world%'
--and `$query` like '%automatic_reply%'
--and `$query` like'%volvo_world_servicecenter%'
--and `$query` like '%EX90%'
--and event_time>='2024-12-01' and client_time>='2024-12-01'
--and client_time<'2025-01-01'
union all
--用户口碑：口碑专区
select 
'5' a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
--count(distinct case when var_is_bind='1' and `$is_first_day` =1 then user else null end) "拉新车主",
--count(distinct case when var_is_bind='0' and length(user)<9 and `$is_first_day` =1 then user else null end) "拉新粉丝"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%opinion_zone%'
and `$query` like'%servicecenter_autoreply%'
--and `$query` like '%EX90%'
and event_time>='2024-12-01' 
and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--推荐购车：推荐享好礼
select 
'6' a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%promotion_methods=recommended_purchase%'
and `$query` like'%promotion_activity=servicecenter_autoreply%'
and event_time>='2024-12-01' 
and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--邀你试驾卡片
select 
'7' a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
--count(distinct case when var_is_bind='1' and `$is_first_day` =1 then user else null end) "拉新车主",
--count(distinct case when var_is_bind='0' and length(user)<9 and `$is_first_day` =1 then user else null end) "拉新粉丝"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like'%240730_tdrive%'
and `$query` like '%0b224030l36a%'
and event_time>='2024-12-01' 
and client_time>='2024-12-01'
and client_time<'2025-01-01') x order by 1

-- 拉新人数（App/Mini注册会员） 专属权益：注册会员
select x.*
from 
	(
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
		and event_key='$page'
		and `$query` like '%miniprogram%'
		and `$query` like '%volvo_world%'
		and `$query` like '%automatic_reply%'
		and `$query` like'%volvo_world_servicecenter%'
		and `$query` like '%register_member%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 我是车主：车主服务
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%automatic_reply%'
	and `$query` like'%volvo_world_servicecenter%'
	and `$query` like '%car_owner_service%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 我是粉丝：爱车首页
	select 
	3,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%automatic_reply%'
	and `$query` like'%volvo_world_servicecenter%'
	and `$query` like '%car_lovers_homepage%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 用户口碑：口碑专区
	select 
	4,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%opinion_zone%'
	and `$query` like'%servicecenter_autoreply%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 推荐购车：推荐享好礼
	select 
	5,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%recommended_purchase%'
	and `$query` like'%servicecenter_autoreply%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 邀你试驾卡片
	select 
	6,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%0b224030l36a%'
	and `$query` like'%240730_tdrive%'
		and event_time>='2024-10-01' and client_time>='2024-10-01'
		and client_time<'2024-12-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-10-01'
		and m.create_time <'2024-12-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	)x
order by 1


-- 邀约试驾 自动推送欢迎语：邀你试驾卡片
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	o.`id_$basic_userId` user,
	client_time time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%0b224030l36a%'
	and `$query` like'%240730_tdrive%'
	and event_time>='2024-10-01' and client_time>='2024-10-01'
	and client_time<'2024-12-01'
	order by 2 desc 
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	toDateTime(ta.CREATED_AT)  `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID user,
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
	WHERE ta.CREATED_AT >= '2024-10-01'
	AND ta.CREATED_AT <'2024-12-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约


-- 养修预约 我是车主：车主服务
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	o.`id_$basic_userId` user,
	client_time time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event_key='$page'
	and `$query` like '%miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%automatic_reply%'
	and `$query` like'%volvo_world_servicecenter%'
	and `$query` like '%car_owner_service%'
	and event_time>='2024-12-01' 
	and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	) a
join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "user",
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
		and ta.ONE_ID is not null) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10



-- 预约试驾
	select 
	 user,
	 event_key,
	client_time time
	from ods_gio.ods_gio_event_d a
	where 1=1
--	and event_key='$page'
--	and `$query` like '%wechat_official_account%'
	and `$query` like '%202312_test_drive_gift%'
--	and `$query` like '%menu_bar%'
	and event_time>='2024-12-01' 
	and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	

-- 预约试驾 菜单栏：预约试驾
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 预约试驾
	select 
	 user,
	client_time time
	from ods_gio.ods_gio_event_d a
	where 1=1
	and event_key='$page'
--	and `$query` like '%202312_test_drive_gift%'
	and `$query` like '%volvo_world%'
	and `$query` like '%miniprogram%'
	and `$query` like'%wow_select_car_testdrivde%'
	and `$query` like '%service_menu_bar%'
	and event_time>='2024-12-01' 
	and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID user,
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
	) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约





--养修预约明细 菜单栏
select 
count(distinct a.user)
from (
	select 
	o.`id_$basic_userId` user,
	client_time time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d o on a.gio_id=o.gio_id
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%maintenance_appointment%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	) a
global join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "user",
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
		and ta.ONE_ID is not null) x on toString(x.user) =toString(a.user)  
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
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%9SeSJFOo5p%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%subscribes_only%'
and `$query` like'%new_exploration_guides%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
-- 1点击”订阅“及“预约试驾”
select 
'2'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+1_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%subscriberortestdrive%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--3点击“订阅”及“注册会员”
select 
'3'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%9SeSJFOo5p%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%subscribes_only%'
and `$query` like'%new_exploration_guides%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all
-- 1点击“订阅”及“注册会员”，“预约试驾”
select 
'4'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+1_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%register_member%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all
--1点击“订阅”及“车主服务”
select 
'5'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+1_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%car_owner_service%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--1点击“订阅”及“爱车首页”
select 
'6'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+1_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%car_lovers_homepage%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--2仅点击“订阅”
select 
'7'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+2_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%only_subscriber%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--2点击”订阅“及“预约试驾”
select 
'8'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+2_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%subscriberortestdrive2%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--2点击“订阅”及“注册会员”
select 
'9'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
and `$query` like '%KgeU64RmUD%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+2_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%register_member2%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 

--2点击“订阅”及“注册会员”，“预约试驾”
select 
'10'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%service_menu_bar%'
and `$query` like'%wow_select_car_testdrivde%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'

union all 
--2点击“订阅”及“车主服务”
select 
'11'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+2_push%'
and `$query` like'%volvo_world_servicecenter%'
and `$query` like '%car_owner_service2%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
union all 
--2点击“订阅”及“爱车首页”
select 
'12'::int a,
count(case when var_is_bind='1' then user else null end) "车主PV",
count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
count(case when length(user)>9 then user else null end) "游客PV",
count(distinct case when var_is_bind='1' then user else null end) "车主UV",
count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
count(distinct case when length(user)>9 then user else null end) "游客UV"
from ods_gio.ods_gio_event_d
where 1=1
and event_key='$page'
--and `$query` like '%FO4K4QrVFS%'
and `$query` like '%miniprogram%'
and `$query` like '%volvo_world%'
and `$query` like '%T+2_push%'
and `$query` like'%servicecenter_push%'
and `$query` like '%test_drive%'
and event_time>='2024-12-01' and client_time>='2024-12-01'
and client_time<'2025-01-01'
) x order by 1


	-- 官方直售
	select 
	'1'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%https://ds-f2e.digitalvolvo.com/webroot-h5/index.html%'
	and `$query` like '%promotion_channel_type=MinP%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=direct_sale%'
	and `$query` like '%promotion_activity=direct_sale%'
	and `$query` like'%promotion_supplement=service_menubar%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'

-------------------------------------菜单栏------------------------------------------
select x.*
from 
	(
	-- 官方直售
	select 
	'1'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%https://ds-f2e.digitalvolvo.com/webroot-h5/index.html%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=direct_sale%'
	and `$query` like '%promotion_activity=direct_sale%'
	and `$query` like'%promotion_supplement=service_menubar%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	-- 探索车型
	select 
	'2'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=explore_vehicle%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--金融方案
	select 
	'3'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%9SeSJFOo5p%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like'%promotion_supplement=financial_solutions%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all
	-- 预约试驾
	select 
	'4'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
--	and event_key='$page'
--	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%volvo_world%'
	and `$query` like '%miniprogram%'
	and `$query` like'%wow_select_car_testdrivde%'
	and `$query` like '%service_menu_bar%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all
	--查找经销商
	select 
	'5'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=find_dealers%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--沃世界主场
	select 
	'6'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=volvo_world%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--沃商城
	select 
	'7'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=volvo_store%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--车主俱乐部
	select 
	'8'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=owners_club%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
		union all 
	--守护计划
	select 
	'9'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=volvo%'
	and `$query` like'%promotion_activity=240723_guardplan%'
	and `$query` like '%promotion_supplement=4n216052n56r%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--推荐购
	select 
	'10'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%KgeU64RmUD%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=recommended_purchase%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--下载APP
	select 
	'11'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
--	and event_key='$APPViewScreen'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=wechat_official_account%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu%'
	--and `$query` like'%volvo_world_servicecenter%'
	--and `$query` like '%register_member%'
	and event_time>='2024-12-01' 
	and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--养修预约
	select 
	'12'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=maintenance_appointment%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--沃家客服
	select '13'::int a,toUInt64(0) ,toUInt64(0),toUInt64(0),toUInt64(0),toUInt64(0),toUInt64(0)
	union all 
	--上门取送车
	select 
	'14'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=home_delivery%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--官方回购
	select 
	'15'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
--	and event_key='$page'
	and `$path` like '%/src/pages/usedcar/info/index%'
--	and `$query` like '%promotion_channel_type=miniprogram%'
--	and `$query` like '%promotion_channel_sub_type=volvo_world%'
--	and `$query` like '%promotion_methods=menu_bar%'
--	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
--	and `$query` like '%promotion_supplement=official_repurchase%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--充电桩安装
	select 
	'16'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=charge_station_install%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
) x order by 1


-- 拉新人数（App/Mini注册会员） 菜单栏
select x.*
from 
	(
--	 官方直售
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
		and event_key='$page'
	and `$query` like '%https://ds-f2e.digitalvolvo.com/webroot-h5/index.html%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=direct_sale%'
	and `$query` like '%promotion_activity=direct_sale%'
	and `$query` like'%promotion_supplement=service_menubar%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 官方直售
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=explore_vehicle%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
	-- 拉新人数（App/Mini注册会员） 金融方案
	select 
	3,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like'%promotion_supplement=financial_solutions%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 预约试驾
	select 
	4,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%volvo_world%'
	and `$query` like '%miniprogram%'
	and `$query` like'%wow_select_car_testdrivde%'
	and `$query` like '%service_menu_bar%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 查找经销商
	select 
	5,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=find_dealers%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 沃世界主场
	select 
	6,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=volvo_world%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 沃商城
	select 
	7,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=volvo_store%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 车主俱乐部
	select 
	8,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=owners_club%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 	
	-- 拉新人数（App/Mini注册会员） 守护计划
	select 
	8.5,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=volvo%'
	and `$query` like'%promotion_activity=240723_guardplan%'
	and `$query` like '%promotion_supplement=4n216052n56r%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 	
	-- 拉新人数（App/Mini注册会员） 推荐购
	select 
	9,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=recommended_purchase%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 下载APP
	select 
	10,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and `$query` like '%promotion_channel_type=wechat_official_account%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 养修预约
	select 
	11,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=maintenance_appointment%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
	--沃家客服
	select '12'::int a,toUInt64(0) ,toUInt64(0)
		union all 	
	-- 拉新人数（App/Mini注册会员） 上门取送车
	select 
	13,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=home_delivery%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
			union all 	
	-- 拉新人数（App/Mini注册会员） 官方回购
	select 
	14,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%ty8oE4rf7w%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=official_repurchase%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
				union all 	
	-- 拉新人数（App/Mini注册会员） 充电桩安装
	select 
	15,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=menu_bar%'
	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=charge_station_install%'
		and event_time>='2024-12-01' and client_time>='2024-12-01'
		and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	)x
order by 1





----------------------推文----------------------------
select x.*
from 
	(
	-- 预约试驾：
	select 
	'1'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%IBCRMNOVALL000652024VCCN%'
	and `$query` like '%e7s3k8L2Ev%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	-- 邀请好友:
	select 
	'2'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=btn%'
	and `$query` like'%promotion_activity=241122_12xxsj%'
	and `$query` like '%promotion_supplement=7w299515e73o%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--推荐购车：
	select 
	'3'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%9SeSJFOo5p%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=btn%'
	and `$query` like'%promotion_activity=241122_12tjgdc%'
	and `$query` like'%promotion_supplement=7w301184y96j%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all
	-- 预约试驾
	select 
	'4'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%IBCRMSEPALL000212024VCCN%'
	and `$query` like '%mzegaWo2W5%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all
	--感恩季：
	select 
	'5'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_channel_type=app%'
	and `$query` like '%promotion_channel_sub_type=app%'
	and `$query` like '%promotion_methods=cardjump%'
	and `$query` like'%promotion_activity=241129_buttomcard%'
	and `$query` like '%promotion_supplement=5s307484s95b%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--XC60购车政策：
	select 
	'6'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%pageId=EdAhQi114D%'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=cardjump%'
	and `$query` like'%promotion_activity=241129_buttomcard%'
	and `$query` like '%promotion_supplement=5q307627k41z%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--兴趣圈博物馆：
	select 
	'7'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
--	and `$query` like '%postId=gmg93pDGjE%'
--	and `$query` like '%promotion_channel_type=miniprogram%'
--	and `$query` like '%promotion_channel_sub_type=volvo_world%'
--	and `$query` like '%promotion_methods=menu_bar%'
--	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=9y307375j71w%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--宠物包：
	select 
	'8'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
--	and `$query` like '%promotion_channel_type=miniprogram%'
--	and `$query` like '%promotion_channel_sub_type=volvo_world%'
--	and `$query` like '%promotion_methods=menu_bar%'
--	and `$query` like'%promotion_activity=volvo_world_servicecenter%'
	and `$query` like '%promotion_supplement=7u30837v15r%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
		union all 
	--背带套装：
	select 
	'9'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=4j308469m12f%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--EX30购车政策：
	select 
	'10'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%KgeU64RmUD%'
	and `$query` like '%promotion_supplement=7c308553m30%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--试驾活动文章页：
	select 
	'11'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	--and `$query` like '%FO4K4QrVFS%'
	and `$query` like '%promotion_supplement=5n308796n55g%'
	--and `$query` like'%volvo_world_servicecenter%'
	--and `$query` like '%register_member%'
	and event_time>='2024-12-01' 
	and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--会员日App活动页
	select 
	'12'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=8a30993d63p%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--试驾活动文章页：
	select 
	'13'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%5n308796n55g%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--App图书圈活动
	select 
	'14'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%5g313746z52c%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--跑向2025：
	select 
	'15'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%9v307276y11h%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	union all 
	--精品-杯垫：
	select 
	'16'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%0v314488l68s%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
		union all 
	--精品-冰箱贴：
	select 
	'17'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%5d314592c81e%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
		union all 
	--精品-拼图：
	select 
	'18'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%8c314677h6k%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
		union all 
	--会员日App活动页
	select 
	'19'::int a,
	count(case when var_is_bind='1' then user else null end) "车主PV",
	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
	count(case when length(user)>9 then user else null end) "游客PV",
	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
	count(distinct case when length(user)>9 then user else null end) "游客UV"
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%8a30993d63p%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
) x order by 1


-- 拉新人数（App/Mini注册会员） 推文
select x.*
from 
	(
--	 预约试驾
	select 
	1,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%IBCRMNOVALL000652024VCCN%'
	and `$query` like '%e7s3k8L2Ev%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
--	 预约试驾
	select 
	2,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=7w299515e73o%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
	union all 
--	 预约试驾
	select 
	3,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like'%promotion_supplement=7w301184y96j%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	4,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%IBCRMSEPALL000212024VCCN%'
	and `$query` like '%mzegaWo2W5%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	5,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5s307484s95b%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	6,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5q307627k41z%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	7,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=9y307375j71w%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	8,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=7u30837v15r%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	9,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=4j308469m12f%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	10,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=7c308553m30%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	11,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5n308796n55g%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	12,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=8a30993d63p%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	13,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5n308796n55g%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	14,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5g313746z52c%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	15,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=9v307276y11h%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	16,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=0v314488l68s%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	17,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=5d314592c81e%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	18,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=8c314677h6k%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
		union all 
--	 预约试驾
	select 
	19,
	count(distinct case when b.is_vehicle=1 then a.user end)`拉新车主人数`,
	count(distinct case when b.is_vehicle=0 then a.user end)`拉新粉丝人数`
	from
		(select 
		user,client_time time
		from ods_gio.ods_gio_event_d
		where 1=1
	and event_key='$page'
	and `$query` like '%promotion_supplement=8a30993d63p%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	)a 
	join
		(-- 注册会员
		select distinct m.cust_id,m.create_time,m.is_vehicle 
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		--and m.member_source = '60511003' -- 首次注册app用户
		and m.create_time >= '2024-12-01'
		and m.create_time <'2025-01-01'
	)b on a.user=b.cust_id::varchar
	where toDateTime(a.time)-toDateTime(b.create_time)<=600 
	and toDateTime(a.time)-toDateTime(b.create_time)>=-600	
)x order by 1 



-- 预约试驾 菜单栏：预约试驾
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	user,
	client_time time
	from ods_gio.ods_gio_event_d
	where 1=1
and event_key='$page'
	and `$query` like '%promotion_supplement=7w299515e73o%'
--	and `$query` like '%e7s3k8L2Ev%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID user,
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
	) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约



-- 推文预约试驾
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	user,
	client_time time
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%IBCRMNOVALL000652024VCCN%'
	and `$query` like '%e7s3k8L2Ev%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	) a
join (--养修预约
		select cast(tam.MAINTAIN_ID as varchar) YYID,
		       ta.APPOINTMENT_ID "预约ID",
		       ta.OWNER_CODE "经销商代码",
		       tc2.company_name_cn "经销商名称",
		       ta.ONE_ID "user",
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
		and ta.ONE_ID is not null) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10
	


-- 邀约试驾 自动推送欢迎语：邀你试驾卡片
select 
count(distinct a.user)
--distinct a.user,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (
-- 我是车主：车主服务
	select 
	user,
	client_time time
	from ods_gio.ods_gio_event_d
	where 1=1
	and event_key='$page'
	and `$query` like '%7w299515e73o%'
	and `$query` like '%241122_12xxsj%'
	and event_time>='2024-12-01' and client_time>='2024-12-01'
	and client_time<'2025-01-01'
	order by 2 desc 
	) a
join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	toDateTime(ta.CREATED_AT)  `CREATED_AT`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID user,
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
--	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
	) x on toString(x.user) =toString(a.user)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
and dateDiff('minute',toDateTime(x.CREATED_AT),toDateTime(a.time)) <10  -- 浏览后十分中内预约




-----------------------------7月--------------------------
--充电桩安装
--	select 
--	'15' a,
--	count(case when var_is_bind='1' then user else null end) "车主PV",
--	count(case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝PV",
--	count(case when length(user)>9 then user else null end) "游客PV",
--	count(distinct case when var_is_bind='1' then user else null end) "车主UV",
--	count(distinct case when var_is_bind='0' and length(user)<9 then user else null end) "粉丝UV",
--	count(distinct case when length(user)>9 then user else null end) "游客UV"
--	from ods_gio.ods_gio_event_d
--	where 1=1
--	and event_key='$page'
--	and `$query` like '%FO4K4QrVFS%'
--	and `$query` like '%promotion_channel_type=miniprogram%'
--	and `$query` like '%promotion_channel_sub_type=volvo_world%'
--	and `$query` like '%tweets%'
--	and `$query` like'%202307_gift_for_recommend_tutorial%'
--	and `$query` like '%charge_station_install%'
--	and event_time>='2024-12-01' and client_time>='2024-12-01'
--	and client_time<'2025-01-01'