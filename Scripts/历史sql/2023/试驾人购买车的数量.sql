-- 预约试驾
select count(distinct x.one_id)
from 
(
select
distinct  
ta.APPOINTMENT_ID 预约ID,
ta.APPOINTMENT_TYPE,
ta.CREATED_AT 预约日期,
ta.OWNER_CODE 经销商代码,
-- tc2.COMPANY_NAME_CN "经销商名称",
tad.user_name 姓名,
tad.phone 预约手机号,
ta.one_id ,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
tc.code_id,
case when tc.code_id = '70711001' then '预约待试驾'
	when tc.code_id = '70711002' then '预约已试驾'
	when tc.code_id = '70711003' then '预约已取消'
	end 预约试驾状态
from cyx_appointment.tt_appointment ta
left join cyx_appointment.tt_appointment_drive tad on ta.APPOINTMENT_ID = tad.APPOINTMENT_ID
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
--left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
--left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
left join dictionary.tc_code tc on tad.STATUS = tc.CODE_ID 
-- left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
--left join vehicle.tt_invoice_statistics_dms tisd on 
where 1=1
and ta.CREATED_AT >= '2023-05-01'
and ta.CREATED_AT < '2023-06-01'
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ta.IS_DELETED = 0
--and tc.code_id in ('70711002','70711001','70711003')
and ta.APPOINTMENT_TYPE=70691002
)x

--### 预约试驾订单数量  预约试驾到店率
select 
count(1) 预约试驾订单数量
,count(distinct a.cust_id)
-- ,sum(case when a.FIRST_PASSENGER_TIME is not null and a.FIRST_PASSENGER_TIME>a.mdate then 1 else 0 end) 到店数
-- ,sum(case when a.FIRST_DRIVE_TIME is not null and a.FIRST_DRIVE_TIME>a.mdate then 1 else 0 end) 试驾数
,round(sum(case when a.FIRST_PASSENGER_TIME is not null and a.FIRST_PASSENGER_TIME>a.mdate then 1 else 0 end)/count(1),3)"预约试驾到店率 - 整体"
-- ,round(sum(case when a.FIRST_DRIVE_TIME is not null and a.FIRST_DRIVE_TIME>a.mdate then 1 else 0 end)/count(1),3) 试驾率
from (
	select a.*,s.FIRST_PASSENGER_TIME,s.FIRST_DRIVE_TIME
	from (
		select m.id memberid
		,m.member_phone
		,a.one_id cust_id
		,a.OWNER_CODE
		-- ,a.CREATED_AT 预约时间
		,a.CUSTOMER_BUSINESS_ID
		,t.active_name 
		,case when t.active_name in ('2022年Q1 沃世界推荐购活动-零售&直售车型','2022年Q3 沃世界推荐购活动-零售&直售车型','2022年Q4 沃世界推荐购活动-零售&直售车型','2022年Q2 沃世界推荐购活动-零售&直售车型') then '推荐购'
					when t.active_name in ('沃世界预约','3.0改版-我的页面-预约试驾','2021 沃世界公众号欢迎语推送','3.0改版-商城首页-预约试驾') then '自然流量'
					else '沃世界线上活动' end 沃世界来源渠道
		,min(a.CREATED_AT) mdate
		from cyx_appointment.tt_appointment a 
		left join activity.cms_active t on a.CHANNEL_ID=t.uid
		left join (
--			#存在cust_id一对多memberid,所以获取最新的cust_id对应的memberid
			select m.*
			from (
				select m.CUST_ID,max(m.ID) mid
				from member.tc_member_info m
				GROUP BY 1)a 
			left JOIN member.tc_member_info m on a.mid=m.ID
		) m on a.ONE_ID=m.cust_id
		where a.APPOINTMENT_TYPE=70691002  -- 预约类型:试驾
		and a.DATA_SOURCE='C' -- 试驾来源: C端
		and a.ONE_ID is not null and a.ONE_ID<>''
		and a.CREATED_AT >='2023-05-01' and a.CREATED_AT <'2023-06-01'
		GROUP BY 1,2,3,4,5,6 
		order by 3 desc 
	) a 
	left join customer_business.tt_business_statistics s on a.CUSTOMER_BUSINESS_ID=s.CUSTOMER_BUSINESS_ID
) a 


-- 判断预约试驾用户后续买车数量
select count(x.vin),
count(x.车架号)
from 
(
select
distinct  
ta.APPOINTMENT_ID 预约ID,
ta.CREATED_AT 预约日期,
ta.OWNER_CODE 经销商代码,
-- tc2.COMPANY_NAME_CN "经销商名称",
tad.user_name 姓名,
tad.phone 预约手机号,
ta.one_id ,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 沃世界绑定手机号,
--tm.MODEL_NAME 车型,
case when tc.code_id = '70711001' then '预约待试驾'
	when tc.code_id = '70711002' then '预约已试驾'
	when tc.code_id = '70711003' then '预约已取消'
	end 预约试驾状态,
tisd.vin ,
xx.车架号
from cyx_appointment.tt_appointment ta
left join cyx_appointment.tt_appointment_drive tad on ta.APPOINTMENT_ID = tad.APPOINTMENT_ID
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
--left join basic_data.tm_model tm on tad.SECOND_ID = tm.SERIES_ID
--left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.MODEL_NAME 
left join dictionary.tc_code tc on tad.STATUS = tc.CODE_ID 
-- left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left join (select a.member_id
	,a.vin_code
	,a.series_code
	from 
		(
		select a.*,
		row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		where a.deleted = 0
		and a.is_bind=1)a 
	where a.rk=1)a on a.member_id =tmi.id
left join vehicle.tt_invoice_statistics_dms tisd on tisd.vin =a.vin_code and tisd.invoice_date >ta.CREATED_AT
	left join (-- 历史订单产生数量、订单车型
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
	and a.CREATED_AT>'2023-05-01'
	and a.IS_DELETED = 0)xx on tmi.MEMBER_PHONE=ifnull(ifnull(xx.潜客电话,开票人电话),xx.下单人手机号) and xx.订单状态='已交车' and xx.订单日期>ta.CREATED_AT
where 1=1
and ta.CREATED_AT >= '2023-05-01'
and ta.CREATED_AT < '2023-06-01'
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
and ta.IS_DELETED = 0
and tc.code_id = '70711002'
)x



