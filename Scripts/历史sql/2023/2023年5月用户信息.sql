-- 2023年5月交车的VIN，被绑的手机号、memberid、oneid；
-- 历史订单产生数量、订单车型
select x.车架号,
x.订单状态,
x.潜客电话,
x.开票人电话,
x.下单人手机号
from 
	(
	select 
	    a.SO_NO_ID 销售订单ID,
	    a.SO_NO 销售订单号,
	    a.COMPANY_CODE 公司代码,
	    h.COMPANY_NAME_CN 经销商名称,
	    h.GROUP_COMPANY_NAME 集团,
	    h.ORG_NAME_big 大区,
	    h.ORG_NAME_small 小区,
	    a.OWNER_CODE 经销商代码,
	    a.CREATED_AT 订单日期,
	    a.SHEET_CREATE_DATE 开单日期,
	    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
	    a.CUSTOMER_NAME 客户姓名,
	    a.DRAWER_NAME 开票人姓名,
	    a.CONTACT_NAME 联系人姓名,
	    a.CUSTOMER_TEL 潜客电话,
	    a.DRAWER_TEL 开票人电话,
	    a.PURCHASE_PHONE 下单人手机号,
	    g.CODE_CN_DESC 订单状态,
	    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
	    i.CODE_CN_DESC BUSINESS_TYPE,
	    a.smmOrderId 订单id_smm,
	    a.smmCustId 潜客id_smm,
	    a.CUSTOMER_ID ,
	    a.CUSTOMER_NO ,
	    a.CUSTOMER_ACTIVITY_ID 活动代码id,
	    c.CLUE_NAME 来源渠道,
	    b.active_code 市场活动代码,
	    b.active_name 市场活动名称,
	    d.SALES_VIN 车架号,
	    f.model_name 车型,
	    j.CODE_CN_DESC 线索客户类型,
	    k.CODE_CN_DESC 客户性别,
	    l.CODE_CN_DESC 交车状态,
	    n.CODE_CN_DESC 订单购买类型,
	    a.VEHICLE_RETURN_DATE 退车完成日期,
	    m.CODE_CN_DESC 退车状态,
	    a.RETURN_REASON 退单原因,
	    a.RETURN_REMARK 退单备注,
	    a.IS_DELETED
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	left join (
	    select 
	        tm.id 经销商表ID,
	        tm.ORG_ID 经销商组织ID,
	        tm.COMPANY_CODE ,
	        tL2.ID 大区组织ID,
	        tL2.ORG_NAME ORG_NAME_big,
	        tg1.ID 小区组织ID,
	        tg1.ORG_NAME ORG_NAME_small,
	        tm.COMPANY_NAME_CN ,
	        tm.GROUP_COMPANY_NAME
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
		) h on h.COMPANY_CODE = a.COMPANY_CODE
	 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
	 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
	 left join dictionary.tc_code k on k.code_id = a.GENDER
	 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
	 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
	left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT>='2023-05-01'
	and a.CREATED_AT <'2023-06-01'
--	and a.updated_at<'2023-06-15'
)x where x.订单是否有效='Y'

-- vin和memberid
select x.车架号,
x.订单状态,
m.id memberid
from 
	(
	select 
	    a.SO_NO_ID 销售订单ID,
	    a.SO_NO 销售订单号,
	    a.COMPANY_CODE 公司代码,
	    h.COMPANY_NAME_CN 经销商名称,
	    h.GROUP_COMPANY_NAME 集团,
	    h.ORG_NAME_big 大区,
	    h.ORG_NAME_small 小区,
	    a.OWNER_CODE 经销商代码,
	    a.CREATED_AT 订单日期,
	    a.SHEET_CREATE_DATE 开单日期,
	    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
	    a.CUSTOMER_NAME 客户姓名,
	    a.DRAWER_NAME 开票人姓名,
	    a.CONTACT_NAME 联系人姓名,
	    a.CUSTOMER_TEL 潜客电话,
	    a.DRAWER_TEL 开票人电话,
	    a.PURCHASE_PHONE 下单人手机号,
	    g.CODE_CN_DESC 订单状态,
	    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
	    i.CODE_CN_DESC BUSINESS_TYPE,
	    a.smmOrderId 订单id_smm,
	    a.smmCustId 潜客id_smm,
	    a.CUSTOMER_ID ,
	    a.CUSTOMER_NO ,
	    a.CUSTOMER_ACTIVITY_ID 活动代码id,
	    c.CLUE_NAME 来源渠道,
	    b.active_code 市场活动代码,
	    b.active_name 市场活动名称,
	    d.SALES_VIN 车架号,
	    f.model_name 车型,
	    j.CODE_CN_DESC 线索客户类型,
	    k.CODE_CN_DESC 客户性别,
	    l.CODE_CN_DESC 交车状态,
	    n.CODE_CN_DESC 订单购买类型,
	    a.VEHICLE_RETURN_DATE 退车完成日期,
	    m.CODE_CN_DESC 退车状态,
	    a.RETURN_REASON 退单原因,
	    a.RETURN_REMARK 退单备注,
	    a.IS_DELETED
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	left join (
	    select 
	        tm.id 经销商表ID,
	        tm.ORG_ID 经销商组织ID,
	        tm.COMPANY_CODE ,
	        tL2.ID 大区组织ID,
	        tL2.ORG_NAME ORG_NAME_big,
	        tg1.ID 小区组织ID,
	        tg1.ORG_NAME ORG_NAME_small,
	        tm.COMPANY_NAME_CN ,
	        tm.GROUP_COMPANY_NAME
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
		) h on h.COMPANY_CODE = a.COMPANY_CODE
	 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
	 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
	 left join dictionary.tc_code k on k.code_id = a.GENDER
	 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
	 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
	left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT>='2023-05-01'
	and a.CREATED_AT <'2023-06-01'
)x left join 
	(select a.*
	from 
		(
		select a.*,
		row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		where a.deleted = 0
		and a.is_bind=1)a 
	where a.rk=1)a on x.车架号=a.vin_code
left join "member".tc_member_info m on a.member_id =m.id
where x.订单是否有效='Y'

-- vin和custid
select x.车架号,
x.订单状态,
m.cust_id oneid
from 
	(
	select 
	    a.SO_NO_ID 销售订单ID,
	    a.SO_NO 销售订单号,
	    a.COMPANY_CODE 公司代码,
	    h.COMPANY_NAME_CN 经销商名称,
	    h.GROUP_COMPANY_NAME 集团,
	    h.ORG_NAME_big 大区,
	    h.ORG_NAME_small 小区,
	    a.OWNER_CODE 经销商代码,
	    a.CREATED_AT 订单日期,
	    a.SHEET_CREATE_DATE 开单日期,
	    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
	    a.CUSTOMER_NAME 客户姓名,
	    a.DRAWER_NAME 开票人姓名,
	    a.CONTACT_NAME 联系人姓名,
	    a.CUSTOMER_TEL 潜客电话,
	    a.DRAWER_TEL 开票人电话,
	    a.PURCHASE_PHONE 下单人手机号,
	    g.CODE_CN_DESC 订单状态,
	    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
	    i.CODE_CN_DESC BUSINESS_TYPE,
	    a.smmOrderId 订单id_smm,
	    a.smmCustId 潜客id_smm,
	    a.CUSTOMER_ID ,
	    a.CUSTOMER_NO ,
	    a.CUSTOMER_ACTIVITY_ID 活动代码id,
	    c.CLUE_NAME 来源渠道,
	    b.active_code 市场活动代码,
	    b.active_name 市场活动名称,
	    d.SALES_VIN 车架号,
	    f.model_name 车型,
	    j.CODE_CN_DESC 线索客户类型,
	    k.CODE_CN_DESC 客户性别,
	    l.CODE_CN_DESC 交车状态,
	    n.CODE_CN_DESC 订单购买类型,
	    a.VEHICLE_RETURN_DATE 退车完成日期,
	    m.CODE_CN_DESC 退车状态,
	    a.RETURN_REASON 退单原因,
	    a.RETURN_REMARK 退单备注,
	    a.IS_DELETED
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	left join (
	    select 
	        tm.id 经销商表ID,
	        tm.ORG_ID 经销商组织ID,
	        tm.COMPANY_CODE ,
	        tL2.ID 大区组织ID,
	        tL2.ORG_NAME ORG_NAME_big,
	        tg1.ID 小区组织ID,
	        tg1.ORG_NAME ORG_NAME_small,
	        tm.COMPANY_NAME_CN ,
	        tm.GROUP_COMPANY_NAME
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
		) h on h.COMPANY_CODE = a.COMPANY_CODE
	 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
	 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
	 left join dictionary.tc_code k on k.code_id = a.GENDER
	 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
	 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
	left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
	and a.CREATED_AT>='2023-05-01'
	and a.CREATED_AT <'2023-06-01'
)x left join 
	(select a.*
	from 
		(
		select a.*,
		row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		where a.deleted = 0
		and a.is_bind=1)a 
	where a.rk=1)a on x.车架号=a.vin_code
left join "member".tc_member_info m on a.member_id =m.id
where x.订单是否有效='Y'

-- 2023年5月交车的VIN，被绑的手机号、memberid、oneid
select x.vin,
m.member_phone 被绑的手机号,
m.id memberid,
m.cust_id oneid
from 
	(-- 总开票数
	select d.vin
	from vehicle.tt_invoice_statistics_dms d
	where d.IS_DELETED = 0
	and d.invoice_date >= '2023-05-01'
	and d.invoice_date < '2023-06-01')x 
left join 
	(select a.*
	from 
		(
		select a.*,
		row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		where a.deleted = 0
		and a.is_bind=1)a 
	where a.rk=1)a on x.vin=a.vin_code
left join "member".tc_member_info m on a.member_id =m.id