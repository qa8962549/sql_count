-- 试驾提交数
select
--x.`预约渠道`,
x.is_vehicle,
count(1)
from 
(
	SELECT
	distinct 
	ta.ONE_ID `客户ID`,
	m.id `试驾memberID`,
	m.member_phone `沃世界注册手机号`,
	m.is_vehicle is_vehicle,
	ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	tm2.model_name `预约车型`,
	case when ta.ARRIVAL_DATE<'2000-01-01' then null else ta.ARRIVAL_DATE end  `预约单到店日期`,
--	ta.ARRIVAL_DATE `预约单到店日期`,
	ca.active_name `活动名称`,
	case when ca.active_name like '%App%'  then 'App'
		when ca.active_name like '%小程序%' or ca.active_name like '%沃世界%' then '小程序' 
		else null end `预约渠道`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	case when tad.DRIVE_S_AT<'2000-01-01' then null else tad.DRIVE_S_AT end  `预约试驾表开始时间`,
	case when tad.DRIVE_E_AT<'2000-01-01' then null else tad.DRIVE_E_AT end  `预约试驾表结束时间`,
	case when e.`试驾开始时间`<'2000-01-01' then null else e.`试驾开始时间` end  `试驾工单表试驾开始时间`,
	case when e.`试驾结束时间`<'2000-01-01' then null else e.`试驾结束时间` end  `试驾工单表试驾结束时间`,
	case when f.`到店时间`<'2000-01-01' then null else f.`到店时间` end  `到店表到店时间`,
	CASE 
		WHEN tad.STATUS=70711001 THEN '待试驾'
	    WHEN tad.STATUS=70711002 THEN '已试驾' 
	    WHEN tad.STATUS=70711003 THEN '已取消'
	    END `预约试驾表试驾状态`,
	case when (e.DRIVE_STATUS = 20211001 or e.DRIVE_STATUS = 20211004) then  '待试驾'
     when e.DRIVE_STATUS = 20211003  then  '已试驾'
     when e.DRIVE_STATUS = 20211002  then  '已取消'
      else null end `试驾工单表试驾状态`,
      tc.CODE_CN_DESC `预约表状态`,
	CASE WHEN tad.STATUS=70711002 or e.DRIVE_STATUS = 20211003 
		or tad.DRIVE_S_AT>'2000-01-01' or tad.DRIVE_E_AT>'2000-01-01'
		or e.`试驾开始时间`>'2000-01-01' or e.`试驾结束时间` >'2000-01-01' 
		or tc.CODE_CN_DESC='已到店'
			THEN '已试驾' 
	    else  '未试驾'
	    END `试驾状态`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.user_member_id)=toString(m.id) 
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN 
		( -- 存在一个商机ID对应多条到店信息 到店
		select
		q.customer_business_id 
		,q.arrive_date `到店时间`
		,ROW_NUMBER()over(PARTITION by q.customer_business_id order by q.arrive_date desc) rk
		from ods_cypf.ods_cypf_tt_passenger_flow_info_cur q
		where q.is_deleted =0
		and date(q.arrive_date) >= '2024-03-26'
		and date(q.arrive_date) <'2024-04-09'
		and q.customer_business_id is not null
		) f on ta.CUSTOMER_BUSINESS_ID = f.customer_business_id and f.rk=1 -- 到店表取最新仪表
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		p.ITEM_ID
		,p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT `试驾开始时间`
		,p.DRIVE_E_AT `试驾结束时间`
		,p.DRIVE_STATUS
		,p.APPOINTMENT_ID
		,p.TEST_DRIVE_SOURCE
		from ods_drse.ods_drse_tt_testdrive_plan_d p    -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where 1=1
		and toDate(p.DRIVE_S_AT) >= '2024-03-26' 
		and toDate(p.DRIVE_S_AT) <'2024-04-09' 
		and p.IS_DELETED = 0
--		and CUSTOMER_BUSINESS_ID='1718857734293647361'
	) e on e.ITEM_ID=tad.ITEM_ID 
--	ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID and 
	join (-- 浏览过活动页
		select distinct distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and `date` >= '2024-03-26' and `date` < '2024-04-09'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event='Button_click'
--		and event = 'Page_entry'
		and page_title='春服'
		and activity_name='2024年春服'
		and btn_name='预约试驾'
		and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App')
	)x on toString(x.distinct_id) =toString(m.cust_id) 
--	join (-- App通过试驾享好礼活动主页UV
--		select
--		distinct distinct_id
--		from ods_rawd.ods_rawd_events_d_di a
--		where LENGTH(a.distinct_id)<9 -- 会员
--		and `date` >='2024-03-26'
--		and `date` <='2024-04-09'
--		and event='Page_view'
--		and (`$title` ='试驾享好礼' or (page_title='试驾享好礼'))
--		and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App')
--		)x on toString(x.distinct_id) =toString(m.cust_id) 
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
	WHERE 1=1
	and ta.CREATED_AT >= '2024-03-26'
	and ta.CREATED_AT < '2024-04-09'
	AND ta.APPOINTMENT_TYPE in (70691001,70691002)   -- 预约试乘试驾[C端预约回店（APPOINTMENT_TYPE='70691001'）的单子，后续在处理预约试驾的相关需求时全部都要算进来]
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	order by ta.CREATED_AT
	)x
	group by ROLLUP(1)

-- 试驾实际到店数
select 
count(1)
from 
(
	SELECT
	distinct 
	ta.ONE_ID `客户ID`,
	m.id `试驾memberID`,
	m.member_phone `沃世界注册手机号`,
	m.is_vehicle,
	ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	tm2.model_name `预约车型`,
	case when ta.ARRIVAL_DATE<'2000-01-01' then null else ta.ARRIVAL_DATE end  `预约单到店日期`,
--	ta.ARRIVAL_DATE `预约单到店日期`,
	ca.active_name `活动名称`,
	case when ca.active_name like '%App%'  then 'App'
		when ca.active_name like '%小程序%' or ca.active_name like '%沃世界%' then '小程序' 
		else null end `预约渠道`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	case when tad.DRIVE_S_AT<'2000-01-01' then null else tad.DRIVE_S_AT end  `预约试驾表开始时间`,
	case when tad.DRIVE_E_AT<'2000-01-01' then null else tad.DRIVE_E_AT end  `预约试驾表结束时间`,
	case when e.`试驾开始时间`<'2000-01-01' then null else e.`试驾开始时间` end  `试驾工单表试驾开始时间`,
	case when e.`试驾结束时间`<'2000-01-01' then null else e.`试驾结束时间` end  `试驾工单表试驾结束时间`,
	case when f.`到店时间`<'2000-01-01' then null else f.`到店时间` end  `到店表到店时间`,
	CASE 
		WHEN tad.STATUS=70711001 THEN '待试驾'
	    WHEN tad.STATUS=70711002 THEN '已试驾' 
	    WHEN tad.STATUS=70711003 THEN '已取消'
	    END `预约试驾表试驾状态`,
	case when (e.DRIVE_STATUS = 20211001 or e.DRIVE_STATUS = 20211004) then  '待试驾'
     when e.DRIVE_STATUS = 20211003  then  '已试驾'
     when e.DRIVE_STATUS = 20211002  then  '已取消'
      else null end `试驾工单表试驾状态`,
      tc.CODE_CN_DESC `预约表状态`,
	CASE WHEN tad.STATUS=70711002 or e.DRIVE_STATUS = 20211003 
		or tad.DRIVE_S_AT>'2000-01-01' or tad.DRIVE_E_AT>'2000-01-01'
		or e.`试驾开始时间`>'2000-01-01' or e.`试驾结束时间` >'2000-01-01' 
		or tc.CODE_CN_DESC='已到店'
			THEN '已试驾' 
	    else  '未试驾'
	    END `试驾状态`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(ta.user_member_id)=toString(m.id) 
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN 
		( -- 存在一个商机ID对应多条到店信息 到店
		select
		q.customer_business_id 
		,q.arrive_date `到店时间`
		,ROW_NUMBER()over(PARTITION by q.customer_business_id order by q.arrive_date desc) rk
		from ods_cypf.ods_cypf_tt_passenger_flow_info_cur q
		where q.is_deleted =0
		and date(q.arrive_date) >= '2024-03-26'
		and date(q.arrive_date) <'2024-04-09'
		and q.customer_business_id is not null
		) f on ta.CUSTOMER_BUSINESS_ID = f.customer_business_id and f.rk=1 -- 到店表取最新仪表
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		p.ITEM_ID
		,p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT `试驾开始时间`
		,p.DRIVE_E_AT `试驾结束时间`
		,p.DRIVE_STATUS
		,p.APPOINTMENT_ID
		,p.TEST_DRIVE_SOURCE
		from ods_drse.ods_drse_tt_testdrive_plan_d p    -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where 1=1
		and toDate(p.DRIVE_S_AT) >= '2024-03-26' 
		and toDate(p.DRIVE_S_AT) <'2024-04-09' 
		and p.IS_DELETED = 0
--		and CUSTOMER_BUSINESS_ID='1718857734293647361'
	) e on e.ITEM_ID=tad.ITEM_ID 
--	ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID and 
	join (-- 浏览过活动页
		select distinct distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and `date` >= '2024-03-26' and `date` < '2024-04-09'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and event='Button_click'
--		and event = 'Page_entry'
		and page_title='春服'
		and activity_name='2024年春服'
		and btn_name='预约试驾'
		and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App')
	)x on toString(x.distinct_id) =toString(m.cust_id) 
--	join (-- App通过试驾享好礼活动主页UV
--		select
--		distinct distinct_id
--		from ods_rawd.ods_rawd_events_d_di a
--		where LENGTH(a.distinct_id)<9 -- 会员
--		and `date` >='2024-03-26'
--		and `date` <='2024-04-09'
--		and event='Page_view'
--		and (`$title` ='试驾享好礼' or (page_title='试驾享好礼'))
--		and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App')
--		)x on toString(x.distinct_id) =toString(m.cust_id) 
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
	WHERE 1=1
	and ta.CREATED_AT >= '2024-03-26'
	and ta.CREATED_AT < '2024-04-09'
	AND ta.APPOINTMENT_TYPE in (70691001,70691002)   -- 预约试乘试驾[C端预约回店（APPOINTMENT_TYPE='70691001'）的单子，后续在处理预约试驾的相关需求时全部都要算进来]
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	order by ta.CREATED_AT
	)x where x.`到店表到店时间` is not null 
--	and toDateTime(x.`到店表到店时间`) >=toDateTime(x.`预约时间`) 


	
-- App通过试驾享好礼活动主页UV
	select
	distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where LENGTH(a.distinct_id)<9 -- 会员
	and `date` >='2024-03-26'
	and `date` <='2024-04-09'
	and event='Page_view'
	and (`$title` ='试驾享好礼' or (page_title='试驾享好礼'))
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or channel='App')
--	and ($lib in('MiniProgram') or channel ='Mini')

