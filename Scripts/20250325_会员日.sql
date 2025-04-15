-- PVUV
select 
count(usr_merged_gio_id ) pv,
count(distinct usr_merged_gio_id ) uv,
count(distinct case when m.is_vehicle =1 then usr_merged_gio_id else null end) cz_uv
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
where ((`$platform`  in('iOS','Android','HarmonyOS','Minip') and left(`$client_version`,1)='5') or var_channel ='App'or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_time>='2025-03-25'
and toDate(client_time) = '2025-03-25' -- App开始使用
and event_key ='Page_entry'
and var_page_title ='3月会员日二级页面'
and var_activity_name='2025年3月会员日'
--and client_time < '2025-01-01'
--and length(user)<9

select distinct var_page_title,
var_activity_name,
event_key,
var_btn_name
from ods_gio.ods_gio_event_d a
where ((`$platform`  in('iOS','Android','HarmonyOS','Mini') and left(`$client_version`,1)='5') or var_channel ='App'or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_time>='2025-03-25'
and toDate(client_time) = '2025-03-25' -- App开始使用
--and event_key ='Page_entry'
and var_page_title like'%3月会员日%'
and var_activity_name='2025年3月会员日'
order by 1 


-- PVUV
select 
count(case when var_btn_name ='立即组队' then usr_merged_gio_id else null end) `组队发起PV`,
count(distinct case when var_btn_name ='立即组队'  then usr_merged_gio_id else null end) `组队发起UV`,
count(case when var_btn_name ='前往预约试驾'  then usr_merged_gio_id else null end) `前往预约试驾PV`,
count(distinct case when var_btn_name ='前往预约试驾'  then usr_merged_gio_id else null end) `前往预约试驾UV`
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_time>='2025-03-01'
and toDate(client_time) = '2025-03-25' -- App开始使用
and event_key ='Button_click'
and var_page_title in ('3月会员日二级页面','3月会员日二级页面_接受预组队成功弹窗')
and var_activity_name='2025年3月会员日'
--and var_btn_name ='立即预约试驾' 


-- 组队结果
SELECT count(x.id),
count(case when x.business_code<>'0' then x.id else null end)
FROM 
(
select 
a.id id,
a.member_id`A-memberID（组队发起人）` ,
m.is_vehicle`A-是否车主`,
a.related_member_id`B-memberID（接受组队邀请成功）`,
a.update_time `组队成功时间`,
a.create_time,
business_code
from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id 
left join ods_memb.ods_memb_tc_member_info_cur m2 on m2.id=a.related_member_id 
where 1=1
and a.event_code ='group'
and a.is_deleted =0
and date(a.create_time) ='2025-03-25'
and a.activity_code ='memberday-invite'
order by 5 desc 
)x


-- 到店产品核销明细
select 
distinct 
	tci.coupon_name 卡券名称
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
--	,tmi.member_phone 沃世界注册手机号
--	,top.associate_vin 购买关联vin
	,top.fee/100 总金额
	,top.create_time 下单时间
	,top.pay_fee/100 现金支付金额
	,top.point_amount 支付v值
	,declear_list.company_code 购买关联经销商code
	,top.associate_dealer 购买关联经销商
	,tcd.get_date 获得时间
	,tcd.activate_date 激活时间
	,tcd.expiration_date 卡券失效日期
	,tcd.exchange_code 核销码
	,tc.code_cn_desc 卡券状态
	,tcd.id 卡券领取id
	,tcv.核销用户名
	,tcv.核销手机号
	,tcv.核销金额
	,tcv.核销经销商
	,tcv.核销vin
	,tcv.核销时间
	,tcv.核销工单号
	,tcv.核销车牌
	,top.spu_id
	,tcd.is_refunded 是否退款
	,h.退回时间
from coupon.tt_coupon_detail tcd 
left join coupon.tt_coupon_info tci on tci.id =tcd.coupon_id and tci.is_deleted =0
left join "member".tc_member_info tmi on tmi.id =tcd.member_id and tmi.is_deleted =0
left join "order".tt_order_rt_coupon torc on torc.coupon_id =tcd.id and torc.is_deleted =0
left join "order".tt_order_product top on top.order_code =torc.order_code and top.product_id = torc.product_id and top.is_deleted =0
left join "order".tt_order to2 on to2.order_code =top.order_code 
left join
(
	-- 退单明细
	select
	so.refund_order_code,
	so.order_code,
	sp.product_id,
	case when so.status = '51171001' then  '待审核' 
		when so.status = '51171002' then  '待退货入库' 
		when so.status = '51171003' then  '待退款' 
		when so.status = '51171004' then  '退款成功' 
		when so.status = '51171005' then  '退款失败' 
		when so.status = '51171006' then  '作废退货单'
		else null end 退货状态,
	sum(sp.sales_return_num) 退货数量,
	sum(so.refund_point) `退回V值`,
	max(so.create_time) 退回时间
	from "order".tt_sales_return_order so
	left join "order".tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = 0
	and sp.is_deleted = 0
	GROUP BY 1,2,3,4
) h on to2.order_code = h.order_code and top.product_id = h.product_id
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0 and COMPANY_TYPE = 15061003 
left join "dictionary".tc_code tc on tc.code_id =tcd.ticket_state and tc.is_deleted ='N'
left join (
	select v.coupon_detail_id
	,string_agg(v.customer_name,';' order by id) 核销用户名
	,string_agg(v.customer_mobile,';' order by id) 核销手机号
	,string_agg(round(v.verify_amount/100,2),';' order by id) 核销金额
	,string_agg(v.dealer_code,';' order by id) 核销经销商
	,string_agg(v.vin,';' order by id) 核销VIN
	,string_agg(v.operate_date,';' order by id) 核销时间
	,string_agg(v.order_no,';' order by id) 核销工单号
	,string_agg(v.PLATE_NUMBER,';' order by id) 核销车牌
	from coupon.tt_coupon_verify v  -- 卡券核销信息表
	where  v.is_deleted=0
	group by v.coupon_detail_id
) tcv on tcv.coupon_detail_id =tcd.id
	where 1=1
	and date(tcd.get_date) >= '2025-03-01' 
--	and date(tcd.get_date) < '2025-03-24' 
	and tcd.is_deleted=0 
	and tcd.coupon_id='9215'
order by tcd.get_date desc 

-- PVUV
select 
count(case when var_btn_name ='预约试驾'  then usr_merged_gio_id else null end) `PV`,
count(distinct case when var_btn_name ='预约试驾'  then usr_merged_gio_id else null end) `UV`
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
and event_time>='2025-03-25'
and toDate(client_time) = '2025-03-25' -- App开始使用
and event_key ='Button_click'
and var_page_title ='3月会员日'
and var_activity_name='2025年3月会员日'
--and var_btn_name ='立即预约试驾' 


-- 预约试驾 减去 组队
select count( x.`客户ID`),
count( case when x.`实际到店日期` >'2000-01-01' then x.`客户ID` else null end) `试驾到店数`
from 
(
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID `客户ID`,
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
	WHERE 1=1
--	and ta.CREATED_AT >= '2023-01-01'
	AND toDate(ta.CREATED_AT) ='2025-03-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT
)x
join (select distinct user
from ods_gio.ods_gio_event_d a
left join ods_gio.ods_gio_user_d b on b.gio_id =a.gio_id 
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id)=toString(a.var_memberId) -- 2024年以后得数据可以用mmeberid关联
where ((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_time>='2025-03-25'
and toDate(client_time) = '2025-03-25' -- App开始使用
and event_key ='Button_click'
and var_page_title ='3月会员日'
and var_activity_name='2025年3月会员日'
and var_btn_name ='预约试驾'
)x2 on toString(x2.user) =toString(x.`客户ID`) 


-- 试驾线索量 组队
SELECT 
count(distinct m.id) `试驾留资数`,
count(distinct case when x2.`实际到店日期`  >'2000-01-01' then  m.id else null end) `试驾到店数`
from ods_memb.ods_memb_tc_member_info_cur m 
join (
	select 
	a.id id,
	a.member_id`A-memberID（组队发起人）` ,
	m.is_vehicle`A-是否车主`,
	a.related_member_id related_member_id,
	a.update_time `组队成功时间`,
	a.create_time,
	business_code
	from ods_dmoa.ods_dmoa_tm_onlineactivity_event_record_d a
	left join ods_memb.ods_memb_tc_member_info_cur m on m.id=a.member_id 
	left join ods_memb.ods_memb_tc_member_info_cur m2 on m2.id=a.related_member_id 
	where 1=1
	and a.event_code ='group'
	and a.is_deleted =0
	and date(a.create_time) ='2025-03-25'
	and a.activity_code ='memberday-invite'
	and business_code<>'0' -- 成功组队
	order by 5 desc 
)x on toString(x.related_member_id) =toString(m.id) 
join (-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID `客户ID`,
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
	WHERE 1=1
--	and ta.CREATED_AT >= '2023-01-01'
	AND toDate(ta.CREATED_AT) ='2025-03-25'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT)x2 on x2. `客户ID`=m.cust_id
