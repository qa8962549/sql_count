--开票时间分年
	select 
	tisd.vin,
	tisd.invoice_date 开票时间,
	x.拥车车型,
	x.member_phone 绑车人手机号,
	x2.drawer_tel 开票人电话,
	x1.返厂时间,
	tisd.dealer_code 经销商代码
	from vehicle.tt_invoice_statistics_dms tisd   -- 与发票表关联
	left join(
		select x.*
		from 
		(
			select a.member_id
			,a.vin_code
			,a.bind_date
			,b.model_name 拥车车型
			,tmi.member_phone
			,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
			from volvo_cms.vehicle_bind_relation a
			left join "member".tc_member_info tmi on tmi.id=a.member_id
			left join basic_data.tm_model b on a.series_code =b.model_code
			where a.deleted = 0
			and a.is_bind=1
		)x where x.rk=1
)x on x.vin_code=tisd.vin 
	left join (--回厂
		select distinct e.vin,
		max(e.ro_create_date) 返厂时间
		from cyx_repair.tt_repair_order e   --工单表
		left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
		where 1=1
		and e.ro_create_date <curdate()  
		and e.ro_create_date >curdate() - interval '18' month
		and e.ro_status = '80491003'-- 已结算工单
		and e.repair_type_code <> 'P'-- 售后
		and e.repair_type_code <> 'S'
		and e.is_deleted = 0
		and a.IS_RED = 10041002   -- 非反结算 
		group by 1
		order by 2 
	)x1 on x1.vin=tisd.vin 
--	left join "member".tc_member_info tmi on tmi.id =x.member_id
	left join (select 
			distinct d.SALES_VIN,
			a.DRAWER_TEL
--			row_number ()over(partition by d.SALES_VIN order by )
			from cyxdms_retail.tt_sales_order_vin d
			left join cyxdms_retail.tt_sales_orders a on d.VI_NO = a.SO_NO
			where a.is_deleted  = 0
			AND a.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')-- 14041008
			)x2 on tisd.vin  = x2.SALES_VIN 
	where 1=1
	and tisd.IS_DELETED =0

select 
x.vin,
x.开单日期,
x.车型,
x2.member_phone 绑车人手机号,
x.开票人电话,
x1.返厂时间,
x.经销商代码
from 
(
	select 
--	    a.SO_NO_ID 销售订单ID,
--	    a.SO_NO 销售订单号,
--	    a.COMPANY_CODE 公司代码,
	    a.OWNER_CODE 经销商代码,
--	    a.CREATED_AT 订单日期,
	    a.SHEET_CREATE_DATE 开单日期,
--	    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
--	    a.CUSTOMER_NAME 客户姓名,
--	    a.DRAWER_NAME 开票人姓名,
--	    a.CONTACT_NAME 联系人姓名,
--	    a.CUSTOMER_TEL 潜客电话,
	    a.DRAWER_TEL 开票人电话,
--	    a.PURCHASE_PHONE 下单人手机号,
	    a.SO_STATUS,
	    g.CODE_CN_DESC 订单状态,
	    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
--	    a.CUSTOMER_ACTIVITY_ID 活动代码id,
--	    c.CLUE_NAME 来源渠道,
--	    b.active_code 市场活动代码,
--	    b.active_name 市场活动名称,
	    d.SALES_VIN vin,
	    f.model_name 车型
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
	left join basic_data.tm_model f on f.id = e.SECOND_ID
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
	left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
	left join dictionary.tc_code k on k.code_id = a.GENDER
	left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
	left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
	left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
	where 1=1
	and a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
--	and a.CREATED_AT>= '2024-04-05' 
--	AND a.CREATED_AT< '2023-04-25 23:59:59'
--	and d.SALES_VIN= 'YV1DZ40C4F2652099'
	order by a.CREATED_AT
)x
left join (--回厂
	select distinct e.vin,
	max(e.ro_create_date) 返厂时间
	from cyx_repair.tt_repair_order e   --工单表
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
	and e.ro_create_date <curdate()  
	and e.ro_create_date >curdate() - interval '18' month
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002   -- 非反结算 
	group by 1
	order by 2 
)x1 on x1.vin=x.vin
left join(
	select x.*
	from 
	(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,tmi.member_phone
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join "member".tc_member_info tmi on tmi.id=a.member_id
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
	)x where x.rk=1
)x2 on x2.vin_code=x.vin 
where x.订单是否有效='Y'