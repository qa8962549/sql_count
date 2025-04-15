通过沃世界试驾预约用户
1.用户手机号
2.用户留资时间、到店时间、购车开票时间、开票车型
3.用户到店试驾与留资平均时间差
4.用户购车开票与到店试驾平均时间差
5.用户购车开票与留资平均时间差
6.Campaign code来源
2021.1.1 -至今

-- 通过沃世界试驾预约用户 2021.1.1 至今  ---Newbie 线索表
select x.客户电话 用户手机号
,x.商机创建时间 用户留资时间
,x.首次试驾时间 到店试驾时间
,x.开单日期 购车开票时间
,x.车型 开票车型
,TIMESTAMPDIFF(hour,x.商机创建时间,x.首次试驾时间) 用户到店试驾与留资时间差（小时）
,TIMESTAMPDIFF(hour,x.首次试驾时间,x.开单日期) 用户购车开票与到店试驾时间差（小时）
,TIMESTAMPDIFF(hour,x.商机创建时间,x.开单日期) 用户购车开票与留资时间差（小时）
,x.市场活动代码
,x.市场活动名称
from 
	(
		(select 
		cast(a.business_id as varchar) 商机id,
	    a.clue_id 线索编号,
	    a.create_time 最早线索创建时间,
	    a.dealer_code 经销商代码,
	    h.COMPANY_NAME_CN 经销商名称,
	    h.GROUP_COMPANY_NAME 集团,
	    h.ORG_NAME_big 大区,
	    h.ORG_NAME_small 小区,
	    a.name 客户姓名,
	    a.mobile 客户电话,
	    i.CODE_CN_DESC 客户性别,
	    a.campaign_id 活动代码id,
	    c.active_code 市场活动代码,
	    c.active_name 市场活动名称,
	    d.CLUE_NAME 来源渠道,
	    f.model_name 意向车型,
	    b.SHOP_NUMBER 到店次数,
	    if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
	    g.FIRST_DRIVE_TIME 首次试驾时间,
	    b.TEST_DRIVE_TIME 试驾次数,
	    if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
	    a.allot_time 线索下发时间,
	    b.FATE_AFFIRM_TIME 首次跟进时间,
	    b.NEW_ACTION_TIME 最后跟进时间,
	    a.handle_time 采集时间,
	    b.created_at 商机创建时间,
	    a.create_time 线索创建时间,
	    e.CODE_CN_DESC 线索状态,
	    a.allot_user_name 渠道来源,
	    a.smmclueid 线索id_SMM,
	    if(a.smmclueid is null,'NEWBIE','SMM') 来源系统,
	    a.smmcustid 潜客id_SMM,
	    g.FIRST_ORDER_TIME 首次下单时间,
	    g.DEFEAT_DATE 战败时间,
	    g.MIN_WORK_CALL_TIME 最早工作号外呼时间,
	    g.MAX_WORK_CALL_TIME 最新工作号外呼时间,
	    g.TOTAL_CALL_NUM newbie外呼次数,
	    g.WORK_CALL_NUM 工作号通话次数,
	    g.WORK_CONNECT_NUM 工作号接通次数,
	    g.WORK_CONNECT_TIMES 工作号累计通话时长
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	left join dictionary.tc_code e on a.clue_status = e.CODE_ID
	left join basic_data.tm_model f on a.model_id = f.id
	left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
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
		) h on h.COMPANY_CODE = a.dealer_code
	 left join dictionary.tc_code i on i.code_id = a.gender
	where a.create_time between '2021-01-01' and '2022-07-14 23:59:59' 
	-- and a.mobile = '18556875894'   -- 李彪的手机号
	and a.allot_user_name = 'woshijie'
	) x   -- 通过沃世界接口进来的留资数据-- AND d.CLUE_NAME in ('eVolvo(总部)','eVolvo(经销商)')
left join 
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
	    b.active_code 市场活动代码2,
	    b.active_name 市场活动名称2,
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
	order by a.CREATED_AT
		) b on x.`商机id`=b.`商机id`
) x
