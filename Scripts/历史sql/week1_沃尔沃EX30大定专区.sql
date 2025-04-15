------------------------------- EX30线索量 Sheet -------------------------------
-- v2
select a.*,b.*,case when b.`下单人手机号` is null then null when a.`留资时间`<=b.`订单时间` then 'T' else 'F' end as `时间关系`
from 
(-- EX30累计线索数
	-- 1、EX30一键留资累计线索
	select a.campaign_code `线索Code`,a.campaign_name `线索名称`,'一键留资' `type`,a.customer_mobile `留资手机号`
	,toDateTime(a.create_time) `留资时间`,a.customer_name `留资人姓名`,c.car_model_name `留资车型`
	from ods_vced.ods_vced_tm_leads_collection_pool_cur a
	left join ods_vced.ods_vced_t_sys_car_model_d c on a.preferred_model_id = c.car_model_id 
	where 1=1
	and a.`create_time` < '2024-07-15'
	and c.car_model_name = 'EX30'
	and a.campaign_code in 
	(-- 一键留资
		select distinct trim(code) code
		from ods_oper_crm.ods_oper_crm_umt001_em90_his_d  -- 一键留资表
		where (car_type ='ALL' or car_type ='EX30')-- 筛选车型
		and channel='一键留资'-- 筛选一键留资
	)
union all
	-- 2、预约试驾线索
	select ca.active_code `线索Code`,ca.active_name `线索名称`,'预约试驾线索' `type`,ta.CUSTOMER_PHONE `留资手机号`
	,toDateTime(ta.CREATED_AT) `留资时间`,ta.CUSTOMER_NAME `留资人姓名`,'EX30' `留资车型`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_drive_d tad on tad.APPOINTMENT_ID = ta.APPOINTMENT_ID
	left join ods_actv.ods_actv_cms_active_d ca on ca.uid = ta.CHANNEL_ID
	where 1=1
	and ta.CREATED_AT < '2024-07-15'
	and ta.APPOINTMENT_TYPE in ('70691001', '70691002')   -- 预约试驾、赏车
	and ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.THIRD_ID = '1114'    -- EX30
union all
	-- 3、推荐购线索
	select tir.channel_code `线索Code`,ca.active_name `线索名称`,'推荐购留资' `type`,tir.be_invite_mobile `留资手机号`
	,toDateTime(tir.create_time) `留资时间`,ifNull(m.real_name,'未知') `留资人姓名`,'EX30' `留资车型`
	from ods_invi.ods_invi_tm_invite_record_d tir
	left join ods_cyap.ods_cyap_tt_appointment_drive_d tad on tad.APPOINTMENT_ID = tir.appointment_id and tad.IS_DELETED = 0
	left join (select distinct active_code,active_name from ods_actv.ods_actv_cms_active_d) ca on ca.active_code = tir.channel_code
	left join ods_memb.ods_memb_tc_member_info_cur m on tir.be_invite_member_id =m.id -- 被邀请人会员ID
	where 1=1
	and tir.create_time < '2024-07-15'
	and tad.THIRD_ID = '1114'   -- EX30
	and tir.is_deleted = 0
union all
	-- 4、EX30线下保客活动
	select a.campaign_code `线索Code`,a.campaign_name `线索名称`,'EX30线下保客' `type`,a.customer_mobile `留资手机号`
	,toDateTime(a.create_time) `留资时间`,a.customer_name `留资人姓名`,c.car_model_name `留资车型`
	from ods_vced.ods_vced_tm_leads_collection_pool_cur a
	left join ods_vced.ods_vced_t_sys_car_model_d c on a.preferred_model_id = c.car_model_id 
	where 1=1
	and a.`create_time` < '2024-07-15'
	and c.car_model_name = 'EX30'
	and a.campaign_code in ('IBCRMMAYEX30000572024VCCN')    -- EX30线下保客活动Code
union all
	-- 5、2024年Q3俱乐部线下活动-沃尔沃认证俱乐部特邀观赛欧洲杯2024619累计线索   IBCRMJUNALL000552024VCCN
	select ca.active_code `线索Code`,ca.active_name `线索名称`,'2024年Q3俱乐部线下活动-沃尔沃认证俱乐部特邀观赛欧洲杯线索' `type`,cc.mobile `留资手机号`
	,toDateTime(left(cc.create_time,19)) `留资时间`,cc.name `留资人姓名`,'EX30' `留资车型`
	from ods_cust.ods_cust_tt_clue_clean_cur cc
	left join ods_actv.ods_actv_cms_active_d ca on ca.uid = cc.campaign_id and ca.is_deleted = 0
	where 1=1
	and cc.create_time < '2024-07-15'
	and ca.active_code = 'IBCRMJUNALL000552024VCCN'
	and cc.model_id = '1114'
	and cc.is_deleted = 0
union all
	-- 6、沃尔沃认证俱乐部特邀观赛欧洲杯-会长推荐 线索数    IBCRMJUNALL000582024VCCN
	select ca.active_code `线索Code`,ca.active_name `线索名称`,'沃尔沃认证俱乐部特邀观赛欧洲杯-会长推荐 线索' `type`,cc.mobile `留资手机号`
	,toDateTime(left(cc.create_time,19)) `留资时间`,cc.name `留资人姓名`,'EX30' `留资车型`
	from ods_cust.ods_cust_tt_clue_clean_cur cc
	left join ods_actv.ods_actv_cms_active_d ca on ca.uid = cc.campaign_id and ca.is_deleted = 0
	where 1=1
	and cc.create_time < '2024-07-15'
	and ca.active_code = 'IBCRMJUNALL000582024VCCN'
	and cc.model_id = '1114'
	and cc.is_deleted = 0
)a
left join
(-- EX30小订明细
	select a.purchase_phone `下单人手机号`,max(toDateTime(a.created_at)) `订单时间`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a
	join ods_oper_crm.ods_oper_crm_cyh_ex30_xd_l_si_1 d on a.so_no_id::varchar=RIGHT(d.SO_NO_ID,19) -- EX30小订冻结明细
	group by `下单人手机号`
)b on a.`留资手机号`=b.`下单人手机号`






-- V1
select a.*,b.*,case when b.`下单人手机号` is null then null when a.`留资时间`<=b.`订单时间` then 'T' else 'F' end as `时间关系`
from 
(-- EX30线索量
	select
	a.campaign_code `线索Code`,
	a.campaign_name `线索名称`,
	case when a.campaign_name = 'IBCRMAPREX30000082024VCCN' then 'EX30订阅-线索'
		when a.campaign_name = 'IBCRMAPREX30000122024VCCN' then 'EX30专区-线索'
		when a.campaign_name in ('IBCRMAPREX30000132024VCCN','APP OGC文章浏览','APP文章留资') then 'EX30文章-线索'
		when a.campaign_name ='IBCRMMAREX30000012024VCCN' then 'EX30购车KV及车型页留资'
		else a.campaign_name end `线索渠道`,
	a.customer_mobile `留资手机号`,
	toDateTime(a.create_time) `留资时间`,
	a.customer_name `留资人姓名`,
	b.car_model_name `留资车型`
	from ods_vced.ods_vced_tm_leads_collection_pool_cur a
	left join ods_vced.ods_vced_t_sys_car_model_d b on a.preferred_model_id = b.car_model_id
	where 1=1 
	and a.create_time >= '2024-03-28'
	and a.create_time < '2024-07-08'
	-- and a.campaign_code in ('IBCRMAPREX30000082024VCCN','IBCRMAPREX30000122024VCCN','IBCRMAPREX30000132024VCCN')
	and a.campaign_code in ('IBCRMJUNHAPPWZLZ2023VCCN','IBCRMAPREX30000082024VCCN','IBCRMAPREX30000122024VCCN','IBCRMAPREX30000132024VCCN')
	and b.car_model_name = 'EX30'
	order by a.create_time
)a
left join
(-- EX30小订明细
	select a.purchase_phone `下单人手机号`,max(toDateTime(a.created_at)) `订单时间`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a
	join ods_oper_crm.ods_oper_crm_cyh_ex30_xd_l_si_1 d on a.so_no_id::varchar=RIGHT(d.SO_NO_ID,19) -- EX30小订冻结明细
	group by `下单人手机号`
)b on a.`留资手机号`=b.`下单人手机号`



------------------------------- EX30专区 Sheet -------------------------------

-- 1、EX30专区PV UV（双端、APP、小程序）
select a.channel,
count(a.`distinct_id`) "活动浏览总PV",
COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主pv",
COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝pv",
COUNT(a.`distinct_id`)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客pv",
COUNT(distinct a.`distinct_id`) as "活动浏览总UV",
COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主UV",
COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝UV",
COUNT(distinct a.`distinct_id`)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客uv"
from 
(-- EX30专区首页
	select var_channel as channel,a.`user` as distinct_id,`client_time`,gio_id,var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key = 'Page_entry'
	and a.var_page_title = '沃尔沃EX30'
	and (`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or `$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
	and a.var_channel in ('App','Mini') 
) a
left join
(-- 清洗会员表
	select * from
	(
		select m.member_phone,m.id,toString(m.cust_id) as distinct_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003' and m.is_deleted =0 
	)m	
	where rk=1
) b on a.distinct_id = b.distinct_id
group by ROLLUP(a.channel)  order by a.channel


-- 2、外部 PV UV
select a.type1,
count(a.`distinct_id`) "活动浏览总PV",
COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主pv",
COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝pv",
COUNT(a.`distinct_id`)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客pv",
COUNT(distinct a.`distinct_id`) as "活动浏览总UV",
COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主UV",
COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝UV",
COUNT(distinct a.`distinct_id`)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客uv"
from 
(-- ----------------------短信：EX30直播----------------------
	select 'A1 EX30直播' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_memberId as memberid  
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Page_view'
	and `$query` like '%promotion_channel_type=miniprogram%'
	and `$query` like '%promotion_channel_sub_type=volvo_world%'
	and `$query` like '%promotion_methods=mini_jump%'
	and `$query` like '%promotion_activity=20240517_ex30%'
	and `$query` like '%promotion_supplement=240517a1%'
union all
	-- ----------------------短信：EX30专区（App）----------------------
	select 'A2 EX30专区（App）' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_memberId as memberid  
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='$page'
	and `$query` like '%promotion_channel_type=sms%'
	and `$query` like '%promotion_channel_sub_type=sms%'
	and `$query` like '%promotion_methods=short_link%'
	and `$query` like '%promotion_activity=20240517_ex30%'
	and `$query` like '%promotion_supplement=240517a2%'
union all	
	-- ----------------------短信：EX30预约试驾（小程序）----------------------
	select 'A3 EX30预约试驾（小程序）' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_memberId as memberid  
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Page_view'
	and `$query` like '%promotion_channel_type=sms%'
	and `$query` like '%promotion_channel_sub_type=sms%'
	and `$query` like '%promotion_methods=short_link%'
	and `$query` like '%promotion_activity=20240517_ex30%'
	and `$query` like '%promotion_supplement=240517a4%'
union all
	-- ----------------------App push：EX30专区----------------------
	select 'A4 EX30专区' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_memberId as memberid  
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='$page'
	and `$query` like '%promotion_channel_type=app%'
	and `$query` like '%promotion_channel_sub_type=app%'
	and `$query` like '%promotion_methods=push%'
	and `$query` like '%promotion_activity=20240517_ex30%'
	and `$query` like '%promotion_supplement=240517a3%'
union all
	-- ----------------------App push：EX30预约试驾----------------------
	select 'A5 EX30预约试驾' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_memberId as memberid  
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and `var_link_url` like '%vocApp://app/sale/testDriver/makeAppointment?query={"modelCode":"416"}%'
) a
left join
(-- 清洗会员表
	select * from
	(
		select m.member_phone,m.id,toString(m.cust_id) as distinct_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003' and m.is_deleted =0 
	)m	
	where rk=1
) b on a.distinct_id = b.distinct_id
group by a.type1 order by a.type1





-- 3、App EX30专区各页面及按钮PV UV

-- 启动APP/启动小程序 UV
select a.channel1,
COUNT(distinct a.`distinct_id`) as "活动浏览总UV",
COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主UV",
COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝UV",
COUNT(distinct a.`distinct_id`)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客uv"
from
(-- APP/小程序启动
	select a.`user` as distinct_id,`client_time`,gio_id,a.var_memberId as memberid 
	,case when ((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App') then 'App'
		when (a.`$platform` in('MinP') or a.var_channel ='Mini') then 'Mini' end as channel1
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and (((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App')or (a.`$platform` in('MinP') or a.var_channel ='Mini')) -- 双端	
) a
left join
(-- 清洗会员表
	select * from
	(
		select m.member_phone,m.id,toString(m.cust_id) as distinct_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003' and m.is_deleted =0 
	)m	
	where rk=1
) b on a.distinct_id = b.distinct_id
group by a.channel1 order by a.channel1



-- 置顶banner、三宫格、一图看懂、视频、订阅、话题互动、限时购车礼遇、即刻下定沃尔沃EX30、沃尔沃EX30小而强大集合页、沃尔沃EX30大咖测评集合页、美图、分享 PVUV
select a.type1,a.var_channel ,
count(a.`distinct_id`) "活动浏览总PV",
COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主pv",
COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝pv",
COUNT(a.`distinct_id`)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客pv",
COUNT(distinct a.`distinct_id`) as "活动浏览总UV",
COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end) "车主UV",
COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end) "粉丝UV",
COUNT(distinct a.`distinct_id`)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id else null end)-(COUNT(distinct case when length(a.`distinct_id`)<9 then distinct_id end)-COUNT(distinct case when b.is_vehicle = '1' and length(a.`distinct_id`)<9 then distinct_id end)) "游客uv"
from 
(-- ----------------------EX30下定页----------------------
	select 'B1 EX30下定页' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid 
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='banner'
	and a.var_component_type  ='图片组件_轮播'
	and a.var_content_id in('1713507179042b74n0bkkj2a','1713334912032aihd6cdh95nk')
	and var_lateral_position =1.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------EX30预约试驾----------------------
	select 'B2 EX30预约试驾' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='banner'
	and a.var_component_type  ='图片组件_轮播'
	and a.var_content_id in('1713507179042b74n0bkkj2a','1713334912032aihd6cdh95nk')
	and a.var_lateral_position =2.0000
	and a.var_channel  in ('App','Mini')
union all	
	-- ----------------------EX30心动智选礼----------------------
	select 'B3 EX30心动智选礼' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='banner'
	and a.var_component_type  ='图片组件_轮播'
	and a.var_content_id in('1713507179042b74n0bkkj2a','1713334912032aihd6cdh95nk')
	and var_lateral_position =3.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------沃尔沃EX30正式登场----------------------
	select 'B4 沃尔沃EX30正式登场' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='banner'
	and a.var_component_type  ='图片组件_轮播'
	and a.var_content_id in('1713507179042b74n0bkkj2a','1713334912032aihd6cdh95nk')
	and var_lateral_position =4.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------【沃尔沃EX30荣获2024年度都市车冠军】----------------------
	select 'B5 沃尔沃EX30荣获2024年度都市车冠军' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='banner'
	and a.var_component_type  ='图片组件_轮播'
	and a.var_content_id in('1713507179042b74n0bkkj2a','1713334912032aihd6cdh95nk')
	and var_lateral_position =5.0000
	and a.var_channel  in ('App','Mini')
union all
	 ----------------------推荐享好礼----------------------
	select 'B6 推荐享好礼' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid 
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一行三个'
	and a.var_content_id in('171612129427579cda8d5id0l','1716121173847b6nf0bchkg3d')
	and var_lateral_position =1.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------置换增购----------------------	
	select 'B7 置换增购' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid 
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一行三个'
	and a.var_content_id in('171612129427579cda8d5id0l','1716121173847b6nf0bchkg3d')
	and var_lateral_position =2.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------金融计算器----------------------	
	select 'B8 金融计算器' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一行三个'
	and a.var_content_id in('171612129427579cda8d5id0l','1716121173847b6nf0bchkg3d')
	and var_lateral_position =3.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------一图看懂沃尔沃EX30----------------------	
	select 'B9 一图看懂沃尔沃EX30' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_btn_name ='广告'
	and a.var_component_type  ='图片组件_广告'
	and a.var_content_id in('1716134733417a767m9aj2jc8','171613508362307ah73546j6i')
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------开启小而强大的奇妙之旅----------------------	
	select 'C1 开启小而强大的奇妙之旅' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='播放'
	and a.var_content_id in('17161214180143enjjch276e1','171612137988249ml5jgbmdk5')
	and a.var_channel  in ('App','Mini')
union all
	 ----------------------即刻订阅----------------------	
	select 'C2 即刻订阅' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name = '广告'
	and a.var_content_id in('17138514101457f6jj974fckc','1713335990944egcd8na121bm')
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------沃尔沃EX30首席体验官----------------------	
	select 'C4 沃尔沃EX30首席体验官' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key='Page_entry'
	and a.var_page_title ='话题详情'
	and a.`$path` like '%kouwUpori6%'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------参与话题----------------------	
	select 'C5 参与话题1' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key='Button_click'
	and a.var_page_title ='话题详情'
	and a.`$path` like '%kouwUpori6%'
	and a.var_btn_name ='参与话题'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------沃尔沃EX30问答----------------------	
	select 'C6 沃尔沃EX30问答' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key='Page_entry'
	and a.var_page_title ='话题详情'
	and a.`$path` like '%Ah4iOkEMrG%'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------参与话题----------------------	
	select 'C7 参与话题2' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key='Button_click'
	and a.var_page_title ='话题详情'
	and a.`$path` like '%Ah4iOkEMrG%'
	and a.var_btn_name ='参与话题'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------了解车型----------------------	
	select 'C8 了解车型' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一行二个'
	and a.var_content_id in('1716121527207aj2j52ldfdll','171612165167011lgbbcal8j2')
	and var_lateral_position =1.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------心动智选礼----------------------	
	select 'C9 心动智选礼' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一行二个'
	and a.var_content_id in('1716121527207aj2j52ldfdll','171612165167011lgbbcal8j2')
	and var_lateral_position =2.0000
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------即刻下定----------------------	
	select 'D1 即刻下定' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一上二下'
	and a.var_content_id in('1714009165420bfnkn69bhib7','171401119218647224el67cdb')
	and var_lateral_position =1.0000
	and var_list_index ='1'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------预约试驾----------------------	
	select 'D2 预约试驾' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一上二下'
	and a.var_content_id in('1714009165420bfnkn69bhib7','171401119218647224el67cdb')
	and var_lateral_position =1.0000
	and var_list_index ='2'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------驾享随沃----------------------	
	select 'D3 驾享随沃' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='图片'
	and a.var_component_type  ='魔方组件_一上二下'
	and a.var_content_id in('1714009165420bfnkn69bhib7','171401119218647224el67cdb')
	and var_lateral_position =2.0000
	and var_list_index ='2'
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------沃尔沃EX30登场----------------------
	select 'D4 沃尔沃EX30登场' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30小而强大'
	and a.var_content_id ='Pzq4s1Ra6N'
	and a.var_content_title ='沃尔沃EX30登场丨小而强大'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------小而卓越,有型有品----------------------	
	select 'D5 小而卓越,有型有品' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30小而强大'
	and a.var_content_id ='5cu0kQ42lr'
	and a.var_content_title ='沃尔沃EX30丨小而卓越，有型有品'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------一图看懂沃尔沃EX30----------------------	
	select 'D6 一图看懂沃尔沃EX30' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30小而强大'
	and a.var_content_id ='eAcz2b85VI'
	and a.var_content_title ='一图看懂沃尔沃EX30的小而强大'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------更多----------------------	
	select 'D7 更多' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='更多'
	and a.var_column_name ='沃尔沃EX30小而强大'
	and a.var_component_type  ='集合页组件'
	and a.var_content_id in('17161345700645efh7km802m1','1716134987759nb3kkn9b81ak')
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------Yes秦九月----------------------	
	select 'D8 Yes秦九月' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08'  
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30大咖测评'
	and a.var_content_id ='1ku4m3PWoY'
	and a.var_content_title ='Yes秦九月丨来北京City drive咯，一起感受沃尔沃EX30小而强大'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------酷玩实验室 | 沃尔沃EX30瑞典试驾，探索纯真欧风----------------------	
	select 'D9 酷玩实验室 | 沃尔沃EX30瑞典试驾，探索纯真欧风' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30大咖测评'
	and a.var_content_id ='FWu8ThtSBv'
	and a.var_content_title ='酷玩实验室 | 沃尔沃EX30瑞典试驾，探索纯真欧风'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------商务范 | 斯堪的纳维亚设计，不只是一种美学，更是一种生活----------------------	
	select 'E1 商务范 | 斯堪的纳维亚设计，不只是一种美学，更是一种生活' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30大咖测评'
	and a.var_content_id ='ISQdOpxRh4'
	and a.var_content_title ='商务范 | 斯堪的纳维亚设计，不只是一种美学，更是一种生活'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------塑最 | 瑞典冰雪之旅，领略沃尔沃「大势化小」的纯电美学----------------------	
	select 'E2 塑最 | 瑞典冰雪之旅，领略沃尔沃「大势化小」的纯电美学' as type1,a.`user` as distinct_id,client_time,gio_id,case when a.var_channel ='App' then 'App' else 'Mini' end as var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='内容合集'
	and a.var_btn_name ='文章'
	and a.var_column_name ='沃尔沃EX30大咖测评'
	and a.var_content_id ='2zg14Y1wLv'
	and a.var_content_title ='SOOZY塑最 | 瑞典冰雪之旅，领略沃尔沃「大势化小」的纯电美学'
	and (a.var_channel  in ('App') or `$platform` ='MinP')
union all
	-- ----------------------更多----------------------	
	select 'E3 更多' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='更多'
	and a.var_column_name ='沃尔沃EX30大咖测评'
	and a.var_component_type  ='集合页组件'
	and a.var_content_id in('17138514719208m4hic348jj4','17133361888519979155k81ki')
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------美图----------------------	
	select 'E4 美图' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='美图'
	and a.var_component_type  ='浏览图组件_一左二右'
	and a.var_content_id in('17138515090393mj448clh9bi','17133362312186e43cbeak043')
	and a.var_channel  in ('App','Mini')
union all
	-- ----------------------分享----------------------	
	select 'E5 分享' as type1,a.`user` as distinct_id,client_time,gio_id,a.var_channel ,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and a.event_key ='Button_click'
	and a.var_page_title ='沃尔沃EX30'
	and a.var_btn_name ='分享'
	and a.var_component_type  ='分享组件'
	and a.var_content_id ='1713851675215n59l5m2iih1'
	and a.var_channel  in ('App','Mini')
) a
left join
(-- 清洗会员表
	select * from
	(
		select m.member_phone,m.id,toString(m.cust_id) as distinct_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003' and m.is_deleted =0 
	)m	
	where rk=1
) b on a.distinct_id = b.distinct_id
group by a.type1,a.var_channel  order by a.type1,a.var_channel 




------------------------------- EX30 tracking list Sheet -------------------------------
-- 1、公众号拉新人数(10分钟左右)
select
count(distinct tci.id) `公众号拉新数`
from ods_cust.ods_cust_tm_customer_info_d tci
global join
(-- 公众号关注
	select unionid, min(create_time) first_subscribe_time
	from ods_vwl.ods_vwl_es_car_owners_d
	where unionid <> ''
	and subscribe_status = 1 -- 关注
	group by unionid
) t2 on tci.union_id = t2.unionid
inner join
(-- EX30页面
	select a.`user` as distinct_id,toDateTime(client_time) as `time`,a.var_memberId 
	from ods_gio.ods_gio_event_d a
	where 1=1
	and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and length(a.`user`)<9
	and a.event_key = 'Page_entry'
	and a.var_page_title = '沃尔沃EX30'
	and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
	and a.var_channel in ('App','Mini')   -- 双端
) x 
on toString(x.distinct_id) =toString(tci.id) 
where abs(DATEDIFF('minute',t2.first_subscribe_time,x.time))<=10





-- 小程序拉新人数(点击EX30活动后，前后十分钟注册成为了新会员)
select
count(distinct a.distinct_id) "拉新人数"
from
(-- EX30页面
	select gio_id,a.`user` as distinct_id,toDateTime(client_time) as `time`,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and length(a.`user`)<9
	and a.event_key = 'Page_entry'
	and a.var_page_title = '沃尔沃EX30'
	and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
	and a.var_channel in ('Mini')   -- ('App','Mini')
)a 
join
(-- 清洗会员表
	select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
	,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where  m.member_status <> '60341003' and m.is_deleted =0 
) b on a.distinct_id = toString(b.cust_id)
join
(-- Mini-用户最早访问时间
	select distinct_id,min(`time`) as create_time
	from 
	(-- Mini活跃
		select a.`user` as distinct_id,min(toDateTime(client_time)) as `time` 
		from ods_gio.ods_gio_event_d a
		where length(a.`user`)<9 
		and (`$platform` in('MinP') or a.var_channel ='Mini')
		group by distinct_id
	union ALL 
	--	Mini活跃
		select toString(m.cust_id) as distinct_id,min(toDateTime(`date`)) as `time` 
		from ods_trac.ods_trac_track_cur t
		inner join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id)
		group by distinct_id
	)a
	group by distinct_id
)b1 on a.distinct_id=b1.distinct_id
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600







-- APP拉新人数(点击EX30活动后，前后十分钟注册成为了新会员)
select
count(distinct a.distinct_id) "APP拉新人数"
from
(-- EX30页面
	select gio_id,a.`user` as distinct_id,toDateTime(client_time) as `time`,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and length(a.`user`)<9
	and a.event_key = 'Page_entry'
	and a.var_page_title = '沃尔沃EX30'
	and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
	and a.var_channel in ('App')   -- ('App','Mini')
)a 
join
(-- 清洗会员表
	select m.cust_id--,m.member_phone,m.id,m.level_id,m.member_time,m.is_vehicle
	--,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where  m.member_status <> '60341003' and m.is_deleted =0 
) b on a.distinct_id = toString(b.cust_id)
join
(-- App-用户最早访问时间
	select a.`user` as distinct_id,toDateTime(min(client_time)) as create_time
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and length(a.`user`)<9 
	and ((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App')
	group by distinct_id
)b1 on a.distinct_id=b1.distinct_id
where toDateTime(a.`time`)-toDateTime(b1.create_time)<=600 
and toDateTime(a.`time`)-toDateTime(b1.create_time)>=-600






-- 3、整体召回车主、APP召回车主、小程序召回车主
select 
count(distinct a.distinct_id) `召回车主人数`
from
(-- EX30页面
	select gio_id,a.`user` as distinct_id,toDateTime(client_time) as `time`,a.var_memberId as memberid
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
	and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
	and length(a.`user`)<9
	and a.event_key = 'Page_entry'
	and a.var_page_title = '沃尔沃EX30'
	and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
	and a.var_channel in ('Mini')   -- ('App','Mini')
) a
left join
(-- 注册会员
	select distinct toString(m.cust_id) as distinct_id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2024-05-19 21:00:00' and m.create_time < '2024-07-08'
) b on a.distinct_id=b.distinct_id
left join
(-- 访问过活动前30天内活跃过的车主会员
	select distinct a.distinct_id as distinct_id
	from
	(-- EX30页面
		select a.`user` as distinct_id,toDateTime(client_time) as `time`,toDateTime(client_time)+ interval '-10 MINUTE' as `time1`
		from ods_gio.ods_gio_event_d a
		where 1=1 
		and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
		and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
		and length(a.`user`)<9
		and a.event_key = 'Page_entry' and a.var_page_title = '沃尔沃EX30'
		and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
		or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
		and a.var_channel in ('Mini') -- ('App','Mini')
	)a 
	join
	(-- 前30天内活跃用户
		select a.`user` as distinct_id,toDateTime(client_time) as `time` 
		from ods_gio.ods_gio_event_d a
		where 1=1 
		and a.event_time >= '2024-03-01' and a.event_time < '2024-08-08'
		and a.client_time >='2024-04-19 21:00:00' and a.client_time <'2024-07-08' 
--		and (((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App')or (a.`$platform` in('MinP') or a.var_channel ='Mini')) -- 双端
--		and ((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App') -- App
		and (a.`$platform` in('MinP') or a.var_channel ='Mini') -- 小程序
	) b on a.distinct_id=b.distinct_id
	where a.`time`+ interval '-30 day'<= b.`time` and b.`time`< a.`time1`
) c on a.distinct_id = c.distinct_id
where 1=1
and b.distinct_id is null -- 剔除新用户
and c.distinct_id is null -- 剔除访问活动前30天内活跃过的车主会员






-- 4、总活跃车主人数
select count(distinct a.`user`)
,count(distinct case when a.var_channel='App' then a.`user` end) as App_UV
,count(distinct case when a.var_channel='Mini' then a.`user` end) as Mini_UV
from ods_gio.ods_gio_event_d a
where 1=1 
and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
and length(a.`user`)<9
and a.event_key = 'Page_entry'
and a.var_page_title = '沃尔沃EX30'
and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
and a.var_channel in ('App','Mini')   -- ('App','Mini')
and a.`user` in 
(-- 清洗会员表
	select distinct toString(m.cust_id) as distinct_id
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status <> '60341003' and m.is_deleted =0 and m.is_vehicle =1
)

-- 5、APP、小程序活跃用户数
select count(distinct a.`user`)
,count(distinct case when a.var_channel='App' then a.`user` end) as App_UV
,count(distinct case when a.var_channel='Mini' then a.`user` end) as Mini_UV
from ods_gio.ods_gio_event_d a
where 1=1 
and a.event_time >= '2024-04-01' and a.event_time < '2024-08-08'
and a.client_time >='2024-05-19 21:00:00' and a.client_time <'2024-07-08' 
and length(a.`user`)<9
and a.event_key = 'Page_entry'
and a.var_page_title = '沃尔沃EX30'
and (a.`$path` like '%mweb/custom/detail/ztqGYpYpsc%' -- App
	or a.`$path` like '%mweb/custom/detail/TL6DWV5uDZ%') -- 小程序
and a.var_channel in ('App','Mini')   -- ('App','Mini')
and a.`user` in 
(-- 清洗会员表
	select distinct toString(m.cust_id) as distinct_id
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status <> '60341003' and m.is_deleted =0
)


------------------------------- EX30小订明细 Sheet -------------------------------
-- 1、EX30预售阶段下单且已支付小订的用户手机号(EX30小订截止到5.19，大订从5.19开始)
select
a.so_no_id `销售订单ID`,
a.so_no `订单号`,
case when b.sale_type = '20131010' then '预售'
	else null end `销售类型`,
case when a.so_status = '14041001' then '未提交'
	else null end `订单状态`,
case when a.is_deposit = '10421009' then '已支付'
	else null end `是否付订金`,
a.purchase_phone `下单人手机号`,
a.created_at `订单时间`,
case when c.SECOND_ID = '1114' then 'EX30'
	else null end `车型`
from ods_cydr.ods_cydr_tt_sales_orders_cur a
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on a.so_no = b.vi_no and b.is_deleted = 0
left join ods_cydr.ods_cydr_tt_sales_order_detail_d c ON a.so_no_id = c.SO_NO_ID
join ods_oper_crm.ods_oper_crm_cyh_ex30_xd_l_si_1 d on a.so_no_id::varchar=RIGHT(d.SO_NO_ID,19) -- EX30小订冻结明细




------------------------------- EX30大定明细 Sheet -------------------------------
-- V2[2024-06-11]
select toString(t1.so_no_id)as SO_NO_ID,
ex30.SO_NO as SO_NO,
tc1.CODE_CN_DESC `销售类型`,
tc2.CODE_CN_DESC `订单状态`,
tc3.CODE_CN_DESC `是否付订金`,
ex30.PURCHASE_PHONE `下单人手机号`,
t1.created_at `订单时间`
,'EX30' `车型`
from ods_oper_crm.ods_oper_crm_cyh_ex30_dd_l_si ex30-- EX30大定订单
join ods_cydr.ods_cydr_tt_sales_orders_cur t1 on ex30.SO_NO =t1.so_no 
LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_vin_cur t2 ON t1.so_no = t2.vi_no
left join ods_dict.ods_dict_tc_code_d tc1 on t2.sale_type=tc1.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc2 on t1.so_status=tc2.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc3 on t1.is_deposit =tc3.CODE_ID 
order by t1.created_at



-- V1[2024-05-23]
-- EX30小定转大定
select
toString(SO_NO_ID) as SO_NO_ID,SO_NO,
tc1.CODE_CN_DESC `销售类型`,
tc2.CODE_CN_DESC `订单状态`,
tc3.CODE_CN_DESC `是否付订金`,
PURCHASE_PHONE `下单人手机号`,
created_at `订单时间`,
case when SECOND_ID = '1114' then 'EX30' else null end `车型`
from
(
	select
	t1.so_no as SO_NO
	, t1.purchase_phone as PURCHASE_PHONE
	, m.is_vehicle as IS_VEHICLE
	, t1.so_no_id as SO_NO_ID
	, t2.sale_type as SALE_TYPE
	, t1.so_status as SO_STATUS
	, t1.is_deposit as IS_DEPOSIT
	, t1.record_version as RECORD_VERSION
	, t1.updated_at as UPDATED_AT
	, t1.owner_code as OWNER_CODE
	, t2.delivery_owner_code as DELIVERY_OWNER_CODE
	, t9.SECOND_ID as SECOND_ID
	, t1.is_deleted as IS_DELETED
	, case when t1.is_deposit = 10041001 then subString(toString(t8.first_deposit_date) ,1,10)
		   else subString(toString(t8.first_qualify_audit_pass_time),1,10) end as first_deposit_date
	, row_number () over (PARTITION BY t1.so_no ORDER BY t1.updated_at DESC, t1.record_version desc, t1.`_etl_time` desc) AS rn
	,t1.created_at as created_at
	from ods_cydr.ods_cydr_tt_sales_orders_cur t1
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_vin_cur t2 ON t1.so_no = t2.vi_no
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_detail_d t9 ON t1.so_no_id = t9.SO_NO_ID
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_ext_d t8 on t8.so_no_id=t1.so_no_id
	left join ods_memb.ods_memb_tc_member_info_cur m on t1.purchase_phone = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where t9.SECOND_ID = '1114' 
	and t1.owner_code = 'VVD'
	and case when t1.is_deposit = 10041001 then subString(toString(t8.first_deposit_date),1,13)
	else subString(toString(t8.first_qualify_audit_pass_time),1,13) end >= '2024-05-19 20' -- 生产要加上
	) tt
left join ods_dict.ods_dict_tc_code_d tc1 on tt.SALE_TYPE=tc1.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc2 on tt.SO_STATUS=tc2.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc3 on tt.IS_DEPOSIT=tc3.CODE_ID 
where tt.rn = 1
and tt.IS_DELETED = 0
and tt.SALE_TYPE = 20131010
and tt.SO_STATUS != 14041009
and (tt.IS_DEPOSIT = 10041001 or tt.SO_STATUS in (14041008, 14041003)) -- 已付定金 或已交车、审批通过
union distinct
-- EX30新增订单
select
toString(SO_NO_ID) as SO_NO_ID,SO_NO,
tc1.CODE_CN_DESC `销售类型`,
tc2.CODE_CN_DESC `订单状态`,
tc3.CODE_CN_DESC `是否付订金`,
PURCHASE_PHONE `下单人手机号`,
created_at `订单时间`,
case when SECOND_ID = '1114' then 'EX30' else null end `车型`
from
(
	select
	t1.so_no as SO_NO
	, t1.purchase_phone as PURCHASE_PHONE
	, m.is_vehicle as IS_VEHICLE
	, t1.so_no_id as SO_NO_ID
	, t2.sale_type as SALE_TYPE
	, t1.so_status as SO_STATUS
	, t1.is_deposit as IS_DEPOSIT
	, t1.record_version as RECORD_VERSION
	, t1.updated_at as UPDATED_AT
	, t1.owner_code as OWNER_CODE
	, t2.delivery_owner_code as DELIVERY_OWNER_CODE
	, t9.SECOND_ID as SECOND_ID
	, t1.is_deleted as IS_DELETED
	, case when t1.is_deposit = 10041001 then subString(toString(t8.first_deposit_date) ,1,10)
		   else subString(toString(t8.first_qualify_audit_pass_time),1,10) end as first_deposit_date
	, row_number () over (PARTITION BY t1.so_no ORDER BY t1.updated_at DESC, t1.record_version desc, t1.`_etl_time` desc) AS rn
	,t1.created_at as created_at
	from ods_cydr.ods_cydr_tt_sales_orders_cur t1
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_vin_cur t2 ON t1.so_no = t2.vi_no
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_order_detail_d t9 ON t1.so_no_id = t9.SO_NO_ID
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_ext_d t8 on t8.so_no_id=t1.so_no_id
	left join ods_memb.ods_memb_tc_member_info_cur m on t1.purchase_phone = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where t9.SECOND_ID = '1114' 
	and t1.owner_code = 'VVD'
	and case when t1.is_deposit = 10041001 then subString(toString(t8.first_deposit_date),1,13)
	else subString(toString(t8.first_qualify_audit_pass_time),1,13) end >= '2024-05-19 21' -- 生产要加上
) tt
left join ods_dict.ods_dict_tc_code_d tc1 on tt.SALE_TYPE=tc1.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc2 on tt.SO_STATUS=tc2.CODE_ID 
left join ods_dict.ods_dict_tc_code_d tc3 on tt.IS_DEPOSIT=tc3.CODE_ID 
where tt.rn = 1
and tt.IS_DELETED = 0
and tt.SALE_TYPE != 20131010
and tt.SO_STATUS != 14041009
and (tt.IS_DEPOSIT = 10041001 or tt.SO_STATUS in (14041008, 14041003)) -- 已付定金 或已交车、审批通过
and tt.SALE_TYPE <> 20131003  -- 剔除试驾车