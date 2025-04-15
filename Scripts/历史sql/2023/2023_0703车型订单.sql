后续绑车相关数据，从这两张表中取数：
-- 绑车流水表
select * from volvo_cms.vehicle_bind_record r
where r.deleted = 0

-- 绑车关系表
select 
distinct 
m.id,
m.member_phone,
date(x.开票时间),
a.拥车车型,
x.车辆年款,
x.owner_code
from "member".tc_member_info m
left join (
	select a.member_id
	,a.vin_code
	,a.series_code
	,a.bind_date
	,a.拥车车型
	from 
		(
		select a.*
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)a 
--	where a.rk=2
	)a on a.member_id =m.id
left join (
	select x.*
	from 
		(
		select 
		b.SALES_VIN,
		b.delivery_owner_code 购车门店 ,
		b.created_at ,
		kp.invoice_date 开票时间,
		tc.province_name 门店所在省份,
		tc.CITY_NAME 门店所在城市,
		kp.buy_name ,
		kp.config_year 车辆年款,
		row_number() over(partition by b.sales_vin order by b.created_at desc ) rk,
		a.owner_code
		from cyxdms_retail.tt_sales_orders a
		left join cyxdms_retail.tt_sales_order_vin b  on a.so_no  = b.vi_no
		left join  vehicle.tt_invoice_statistics_dms kp on b.SALES_VIN  = kp.vin 
		left join organization.tm_company tc on tc.COMPANY_CODE = b.delivery_owner_code
		where kp.is_deleted  = 0
		and a.is_deleted  = 0)x 
--	where x.rk=1
	)x on x.sales_vin=a.vin_code
where 1=1
and m.is_deleted='0'


select x.潜客电话
,x.开票时间
,x.车型
,x.经销商代码
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
	    kp.invoice_date 开票时间,
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
	    a.IS_DELETED,
	    row_number ()over(partition by a.CUSTOMER_TEL order by a.CREATED_AT desc ) rk 
	from cyxdms_retail.tt_sales_orders a 
	left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
	left join customer_business.tm_clue_source c on c.ID = b.active_channel
	left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
	left join  vehicle.tt_invoice_statistics_dms kp on d.SALES_VIN  = kp.vin 
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
	and 订单是否有效='Y'
	and a.IS_DELETED = 0
	--and a.CREATED_AT BETWEEN '2022-01-01' AND '2022-07-31 23:59:59'
	and ifnull(ifnull(a.CUSTOMER_TEL,a.DRAWER_TEL),a.PURCHASE_PHONE) in ('13075324310',
	'13105126551',
	'13181636668',
	'13210721899',
	'13255639899',
	'13305353591',
	'13305412357',
	'13326206896',
	'13335100653',
	'13355316000',
	'13355749555',
	'13356616750',
	'13361328959',
	'13376395727',
	'13395359598',
	'13397778889',
	'13475691138',
	'13508920832',
	'13518686388',
	'13522630365',
	'13562264268',
	'13573770872',
	'13583280967',
	'13605414922',
	'13606411578',
	'13656346289',
	'13675315050',
	'13697695693',
	'13708930329',
	'13792958555',
	'13853616013',
	'13863168816',
	'13869971884',
	'13906362229',
	'13919892679',
	'13953576506',
	'13953920707',
	'13954892356',
	'13963168685',
	'13964289778',
	'13969900013',
	'15069139558',
	'15105388000',
	'15153755199',
	'15166098567',
	'15192288376',
	'15254256369',
	'15315317170',
	'15315405353',
	'15315698080',
	'15315865220',
	'15318629091',
	'15376761577',
	'15552078989',
	'15553700001',
	'15621083222',
	'15621215344',
	'15650122680',
	'15666618868',
	'15806316888',
	'15853713886',
	'15866675999',
	'15963038559',
	'15965898883',
	'15966291999',
	'15969679582',
	'17605430100',
	'18005392666',
	'18013000828',
	'18097025306',
	'18353082866',
	'18505350987',
	'18506468182',
	'18553756312',
	'18605317354',
	'18615513567',
	'18615637367',
	'18653160023',
	'18653588030',
	'18660279907',
	'18660861016',
	'18661696956',
	'18661930003',
	'18663192199',
	'18663708899',
	'18668906336',
	'18669828190',
	'18678032968',
	'18905318098',
	'18953050222',
	'19131881777',
	'19131887777',
	'19153222615',
	'13031732488',
	'13305371901',
	'15064380555',
	'13355000257',
	'13853180761',
	'15564568662',
	'18765377376',
	'15688885221',
	'13863506789',
	'18817843866',
	'13706319902',
	'13953921306',
	'18366647337',
	'15865318171',
	'18002011986',
	'15666599797',
	'13561586725',
	'13573410915',
	'13375376990',
	'15866583166')
	order by a.CREATED_AT DESC  
)x where x.rk=1


-- 订单数
  select
  distinct o."手机号",
  o."订单日期"
  from
  (
      select
      o.CUSTOMER_TEL "手机号",
      o.CREATED_AT "订单日期"
      FROM cyxdms_retail.tt_sales_orders o
      WHERE o.BUSINESS_TYPE <> 14031002
      AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
      AND o.IS_DELETED = 0
      AND o.CREATED_AT >= '2022-05-01'
--      AND o.CREATED_AT <= '2023-04-30 23:59:59'
      AND o.CUSTOMER_TEL IS NOT NULL
      UNION ALL   
      select
      o.DRAWER_TEL "手机号",
      o.CREATED_AT "订单日期"
      FROM cyxdms_retail.tt_sales_orders o
      WHERE o.BUSINESS_TYPE <> 14031002
      AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
      AND o.IS_DELETED = 0
      AND o.CREATED_AT >= '2022-05-01'
--      AND o.CREATED_AT <= '2023-04-30 23:59:59'
      AND o.DRAWER_TEL IS NOT NULL
      UNION ALL
      select
      o.PURCHASE_PHONE "手机号",
      o.CREATED_AT "订单日期"
      FROM cyxdms_retail.tt_sales_orders o
      WHERE o.BUSINESS_TYPE <> 14031002
      AND o.SO_STATUS IN ('14041003', '14041008', '14041001', '14041002')
      AND o.IS_DELETED = 0
      AND o.CREATED_AT >= '2022-05-01'
--      AND o.CREATED_AT <= '2023-04-30 23:59:59'
      AND o.PURCHASE_PHONE IS NOT NULL
  ) o