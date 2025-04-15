	select 
--	distinct 
	a.user_id,
	a.distinct_id,
	m.member_phone,
	time,
	event
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString( m.cust_id) =toString(a.distinct_id ) 
	where 1=1
	and $url like '%promotion_channel_type=miniprogram%'
	and $url like '%promotion_channel_sub_type=volvo_world%'
	and $url like '%promotion_methods=sun_code%'
	and $url like '%promotion_activity=202312_shared_airport%'
	and $url like '%promotion_supplement=1%'
	and date>='2023-11-01'
	and date<'2024-03-01'

-- 共享机场投放太阳码
	select 
	count(user_id) PV,
	count(distinct user_id) UV
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='$MPViewScreen'
	and $url like '%promotion_channel_type=miniprogram%'
	and $url like '%promotion_channel_sub_type=volvo_world%'
	and $url like '%promotion_methods=sun_code%'
	and $url like '%promotion_activity=202312_shared_airport%'
	and $url like '%promotion_supplement=1%'
	and date>='2023-11-01'
	and date<'2024-03-01'

-- 内容专区太阳码
	select 
	count(user_id) PV,
	count(distinct user_id) UV
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='$MPViewScreen'
	and $url like '%postId=yGAxAz1WR3%'
	and $url like '%type=custom%'
	and $url like '%isfromShare=1%'
	and $url like '%promotion_channel_type=miniprogram%'
	and $url like '%promotion_methods=sun_code%'
	and $url like '%promotion_activity=202312_beijing_airport%'
	and $url like '%promotion_supplement=1%'
	and date>='2023-11-01'
	and date<'2024-03-01'

-- 留资数
select 
count(distinct a.distinct_id)
--distinct a.distinct_id,
--a.time,
--x.CREATED_AT,
--dateDiff('minute',a.time,x.CREATED_AT)
from (	
	select 
	distinct 
	a.user_id,
	a.distinct_id,
	m.member_phone member_phone,
	time
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString( m.cust_id) =toString(a.distinct_id ) 
	where 1=1
	and event='$MPViewScreen'
	and $url like '%promotion_channel_type=miniprogram%'
	and $url like '%promotion_channel_sub_type=volvo_world%'
	and $url like '%promotion_methods=sun_code%'
	and $url like '%promotion_activity=202312_shared_airport%'
	and $url like '%promotion_supplement=1%'
	and date>='2023-11-01'
	and date<'2024-03-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT CREATED_AT,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID `distinct_id`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `CUSTOMER_PHONE`,
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
	WHERE ta.CREATED_AT >= '2023-11-01'
	AND ta.CREATED_AT <'2024-03-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
	order by ta.CREATED_AT) x on toString(x.CUSTOMER_PHONE) =toString(a.member_phone)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约

a.`time`+ interval '-30 day'<= b.`time` and b.`time`<a.`time1`

-- 留资数 test 
select 
--count(distinct a.distinct_id)
distinct a.distinct_id,
a.time,
x.CREATED_AT,
dateDiff('minute',toDateTime(a.time),toDateTime(x.CREATED_AT))
from (	
	select 
	distinct 
	a.user_id,
	a.distinct_id,
	m.member_phone member_phone,
	time
	from ods_rawd.ods_rawd_events_d_di a
	left join ods_memb.ods_memb_tc_member_info_cur m on toString( m.cust_id) =toString(a.distinct_id ) 
	where 1=1
--	and event='$MPViewScreen'
	and $url like '%postId=yGAxAz1WR3%'
	and $url like '%type=custom%'
	and $url like '%isfromShare=1%'
	and $url like '%promotion_channel_type=miniprogram%'
	and $url like '%promotion_methods=sun_code%'
	and $url like '%promotion_activity=202312_beijing_airport%'
	and $url like '%promotion_supplement=1%'
	and date>='2023-11-01'
	and date<'2024-03-01'
	) a
global join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT CREATED_AT,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID `distinct_id`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE CUSTOMER_PHONE,
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
	WHERE ta.CREATED_AT >= '2023-11-01'
	AND ta.CREATED_AT <'2024-03-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
	order by ta.CREATED_AT) x on toString(x.CUSTOMER_PHONE) =toString(a.member_phone)  
where 1=1
and x.CREATED_AT>a.time -- 预约时间大于浏览时间
--and dateDiff('minute',a.time,x.CREATED_AT) <10  -- 浏览后十分中内预约