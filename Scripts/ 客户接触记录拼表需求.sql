--1.通过附件信息中商机id匹配 跟进 外呼 试驾 客流
--
--
--周度 
--每周四上午
--NB 取订单详细 
--总表 根据订单编号拉取 门店 客户姓名 大定时间 
--接触形式字段 手动清洗
--
--对总表加工 对订单编号去重 
--对开单顾问去重 加工
--
--
--月度
--根据vin去匹配有效订单，

-- 订单详情表
SELECT 
distinct
tso.customer_business_id 商机ID,
tsov.SALES_VIN AS vin,
tso.SO_NO AS 订单号,--订单号
tsov.DELIVERY_OWNER_CODE AS 门店, -- 门店
tso.CUSTOMER_NAME AS 客户姓名,--客户姓名
tsoe.first_deposit_date 定金支付时间 --定金支付时间
 FROM cyxdms_retail.tt_sales_order_vin tsov
 JOIN cyxdms_retail.tt_sales_order_detail tsod ON tsov.SALES_OEDER_DETAIL_ID=tsod.SALES_OEDER_DETAIL_ID
 JOIN cyxdms_retail.tt_sales_orders tso ON tsod.SO_NO_ID=tso.SO_NO_ID
 left join cyxdms_retail.tt_sales_orders_ext tsoe on tso.SO_NO_ID=tsoe.SO_NO_ID
 WHERE 1=1
 and tso.IS_DELETED=0 
 and tso.SO_STATUS<>'14041009' -- 订单状态剔除“已取消”
 and first_deposit_date >='2025-02-01' -- 定金支付时间
 and first_deposit_date <'2025-02-20' -- 定金支付时间
 and tsov.sale_type not in ('20131004','20131003')-- 订单类型剔除”试驾车”、“代步车”；
 and tso.STRONG_WEAK_AGENT not in ('87811003','87811004')--剔除 销售模式为“批零制“ “新零售“
 and tsoe.deposit_pay_way not in('88031001','88031002','88031003','88031005') -- 沃尔沃零售支付渠道”为“否” 的订单
 and tsoe.deposit_pay_status<>'88001002' -- 沃尔沃零售支付渠道”为“否” 的订单
 order by tso.CREATED_AT DESC
 
 -- 查询注释
select 
distinct drive_status
,a.code_cn_desc 
from drive_service.tt_testdrive_plan b
left join dictionary.tc_code a on b.drive_status=a.code_id 
order by 1 
 
select 
distinct tso.deposit_status
,a.type_name 
from cyxdms_retail.tt_sales_orders tso
left join dictionary.tc_type a on tso.deposit_status=a.id 
order by 1 

手机号：CUSTOMER_TEL
订单创建时间：CREATED_AT
订单状态：SO_STATUS
开票状态：INVOICE_STATUS
VIN:SALES_VIN
大区：salebigareaname
小区：salesmallareaname
经销商集团：GROUP_COMPANY_NAME
经销商：OWNER_CODE -- 门店
订单号：SO_NO
客户名称：CUSTOMER_NAME
订单类型：SALE_TYPE
开票时间：invoice_date
定金支付状态：deposit_pay_status(零售)IS_DEPOSIT(直售)
定金支付时间：first_deposit_date
是否上传定金支付凭证：has_deposit_attachment

-- 数据源:rds-mysql-newbie-prod-sales-shanghai1
-- 数据库:drive_service

--试驾
select 
--count(*)
DRIVE_S_AT,
created_at
from drive_service.tt_testdrive_plan a
where 1=1
and is_deleted = '0'
and drive_status!='20211002'
--and customer_business_id ='1898683790361739266' -- 1898989908971212802
--and a.created_at >='2025-01-01' -- 接触时间
--and ITEM_ID='1898583797206466562'


 --试驾ck
	select 
--	count(*)
	distinct 
	a.CUSTOMER_BUSINESS_ID `商机id`,
	'试驾' `接触形式`,
	case when a.drive_mode = '83861001' then '上门试驾'
	when a.drive_mode = '83861002' then '到店试驾'
	end `接触方式/渠道`,
	ITEM_ID::varchar `接触记录`, --试驾单号
	a.CREATED_AT `接触时间`,
	a.test_consultant `接触人员`,
	'取试驾单上试驾顾问' `备注（接触人员取值）`,
	*
	from ods_drse.ods_drse_tt_testdrive_plan_d a
	where 1=1
	and IS_DELETED = '0'
	and DRIVE_STATUS!='20211002'
--	and CUSTOMER_BUSINESS_ID='1898683790361739266'
	and ITEM_ID='1898683790361739266'

	
1898683790361739266
1898676996310679554
1898582727565889537
1898614954899914754
1898602045401845762
1897933028312596482
1897897067797135361
1896892991567118338
1896126410444881921
1895765617613590529
 
1898990191365701634
1898583797206466562

	
--外呼
 select 
 business_id::int8 商机ID,
 '外呼' 接触形式,
 '电话（AI通话统计报表）' `接触方式/渠道`,
 task_id 接触记录,--跟进ID
 begin_time 接触时间,
 '外呼人' `备注（接触人员取值）`,
  CONSULTANT_ID 接触人员
 from cyx_cti.tt_record a
 where 1=1
 and call_direct='out'
 and business_id is not null 
 and task_id='ec3bec8051574287bbdbf2ebf23311e'
-- and a.begin_time >='2025-01-01'

 		--外呼
		 select count(*)
--		 distinct 
--		 business_id `商机ID`,
--		 '外呼' `接触形式`,
--		 '电话（AI通话统计报表）' `接触方式/渠道`,
--		 task_id `接触记录`,--跟进ID
--		 toDateTime(left(begin_time,19)) `接触时间`,
--		 CONSULTANT_ID `接触人员`,-- 接触人员
--		 '外呼人' `备注（接触人员取值）`
		 from ods_cyct.ods_cyct_tt_record_d a
		 where 1=1
--		 and call_direct='out'
--		 and business_id is not null 
--		 and a.begin_time >='2025-02-01'
--		 and a.begin_time <'2025-03-01' 

 
 --客流
 -- 数据源:rds-mysql-newbie-prod-sales-shanghai1
-- 数据库:cyx_passenger_flow
 select count(*)
-- distinct 
--  a.CUSTOMER_BUSINESS_ID 商机ID,
--   '接待' 接触形式,
--  case
--    when a.passenger_mode = '86891001' then '展厅接待'
--    when a.passenger_mode = '86891002' then '上门接待'
--  end `接触方式/渠道`,
--  a.ID 客流ID,
--  a.ARRIVE_DATE 接触时间,
--  a.RECEPTION_CONSULTANT 接待顾问
from
  cyx_passenger_flow.tt_passenger_flow_info a 
where 1=1
--  CUSTOMER_BUSINESS_ID in  (1874477025973100545)  
  and a.is_deleted=0
  order by a.ARRIVE_DATE DESC 
  
 		 --客流
		 select count(*)
--		 distinct 
--		  a.customer_business_id `商机ID`,
--		   '接待' `接触形式`,
--		  case
--		    when a.passenger_mode = '86891001' then '展厅接待'
--		    when a.passenger_mode = '86891002' then '上门接待'
--		  end `接触方式/渠道`,
--		  a.id::String `接触记录`,--`客流ID`
--		  toDateTime(left(a.arrive_date,19)) `接触时间`,
--		  a.reception_consultant `接待顾问`,
--		  '取接待顾问' `备注（接触人员取值）`
		from
		  ods_cypf.ods_cypf_tt_passenger_flow_info_cur a 
		where 1=1 
--		and a.arrive_date>='2025-02-01'
--		and a.arrive_date<'2025-03-01' 
		and a.is_deleted=0
--		order by a.arrive_date DESC  
  
  
--跟进
-- 数据源:rds-mysql-newbie-prod-sales-shanghai1
-- 数据库:customer_business
select count(*)
--  customer_business_id 商机ID,
--  action_id 跟进ID,
--  fact_action_date 接触时间,
--  consultant 接触人员,
--  action_status
from
  customer_business.tt_actioned
--where action_status not in (15171003) and   action_status <> '15171001'   --剔除自动完成跟进的部分
--and (( scene not like '%自动结束跟进'
--and  scene not like '%自动跟进'
--and  scene not like '%自动完成跟进'
--and  scene not like '%自动完成未完成跟进') or  scene is null or  scene = '')
--order by
--  fact_action_date DESC
  
  -- 跟进ck
  		select count(*)
		from
		  ods_cubu.ods_cubu_tt_actioned_d
		where 1=1
		--  CUSTOMER_BUSINESS_ID in (1874477025973100545) 
--		  and ACTION_STATUS not in (15171003) 
--		  and   ACTION_STATUS <> '15171001'  --剔除自动完成跟进的部分
--		and (( SCENE not like '%自动结束跟进'
--		and  SCENE not like '%自动跟进'
--		and  SCENE not like '%自动完成跟进'
--		and  SCENE not like '%自动完成未完成跟进') or  SCENE is null or  SCENE = '')
--		and FACT_ACTION_DATE>='2025-02-01'
--		and FACT_ACTION_DATE<'2025-03-01' 

  
-- 2.通过订单号匹配开单顾问
  select so_no,t.first_consultant  
  from cyxdms_retail.tt_sales_orders a 
  left join cyxdms_retail.tt_sales_orders_ext t on a.so_no_id =t.so_no_id where so_no in ('MGK2025020500001')

  -- 查 表 库
SELECT database, name
FROM system.tables
where name like '%tm_user%'

  
--3.通过NB USER_ID云学院岗位
-- 数据源:rds-mysql-newbie-prod-mid-shanghai1
-- 数据库:authentication
select 
tncc.id, 
tncc.user_id as NB账号id, 
tncc.newbie_user_code NB账号, 
tncc.cloud_college_user_code 云学院账号,
group_concat(tnccr.position_detail_name) as 云学院岗位
from authentication.tm_user tu
inner join authentication.tr_newbie_cloud_college tncc on tncc.user_id = tu.user_id
left join authentication.tr_newbie_cloud_college_role tnccr on find_in_set(tnccr.position_detail_id,tncc.cloud_college_role) and tnccr.is_deleted = 0
where tncc.is_deleted = 0
group by tu.user_id;


--4.通过USER_ID匹配NB岗位及姓名
-- 数据源:rds-mysql-newbie-prod-mid-shanghai1
-- 数据库:authentication
select tu.user_id,
       e.EMPLOYEE_NAME,
       string_agg(distinct tr.ROLE_NAME,',') as 角色
  from authentication.tm_user tu
 inner join authentication.tm_emp e on e.emp_id=tu.emp_id
  left join `authentication`.tr_user_org tuo on tuo.USER_ID=tu.USER_ID and tuo.IS_DELETED=0
  left join `authentication`.tr_org_role tor on tor.USER_ORG_ID=tuo.USER_ORG_ID and tor.IS_DELETED=0
  left join `authentication`.tm_role tr on tr.ROLE_ID=tor.ROLE_ID and tr.IS_DELETED=0
 where 1=1
-- and tu.user_id in(6211387)
 group by tu.USER_ID
 order by tu.USER_ID asc;



SELECT tso.STRONG_WEAK_AGENT as strongWeakAgent,
       dealer_info.salebigareaname AS bigAreaName,
       dealer_info.salesmallareaname AS oemOrgName,
       dealer_info.GROUP_COMPANY_NAME AS groupCompanyName,
       dealer_info.COMPANY_NAME_CN AS companyName,
       dealer_info.COMPANY_SHORT_NAME_CN AS companyShortNameCn,
       tsov.SO_VIN_ID AS soVinId,
       tsov.SALES_VIN AS vin,
       tsov.SALES_VIN AS visibleVin,
       tsov.CANCEL_REASON as textDetail,
       tsov.IS_AFFIRM as confirmOverchargeStatus,
       tsov.IS_OVERCHARGE as overchargeStatus,
       tsov.GENERAL_ORDERNO as generalOrderno,
       ((
       case
         when tsov.VEHICLE_RETAIL_ALLAMOUNT is not null then tsov.VEHICLE_RETAIL_ALLAMOUNT
         else 0
       end) -(
       case
         when tso.SUBSIDY_PRICE is not null then tso.SUBSIDY_PRICE
         else 0
       end)+(
       case
         when tsov.DELICATE_TOTAL_PRICE is not null then tsov.DELICATE_TOTAL_PRICE
         else 0
       end)) AS actualTotalPrice,
       (
       case tsov.PAY_MODE
         when 14261001 then '全款'
         when 14261002 then '分期'
         else ''
       end) as payModes,
       tsov.PAY_MODE as payMode,
       tsov.INITIAL_PAYMENT AS initialPayment,
       tsov.LOAN_AMOUNTS AS loanAmounts,
       tso.SUBSIDY_PRICE AS subsidyPrice,
       tso.CONTRACT_EARNEST AS contractEarnest,
       tso.CONTRACT_NO AS contractNo,
       tso.smmOrderId,
       tso.SO_NO_ID AS soNoId,
       tso.IS_BILL AS isBill,
       tso.CUSTOMER_ID AS customerId,
       tso.CONTRACT_REMARK AS contractRemark,
       tso.CUSTOMER_CTCODE AS customerCtCode,
       tso.DRAWER_NEW_CTCODE AS drawerNewCtcode,
       tso.CUSTOMER_BUSINESS_ID AS customerBusinessId,      
tso.CUSTOMER_PROVINCE AS customerProvince,
       tso.CUSTOMER_CITY AS customerCity,    
tsod.SECOND_ID as secondId,
       tsod.THIRD_ID as thirdName,
       tsod.THIRD_ID as thirdCode,
       tsod.FOUR_ID as fourId,
       tsod.SECOND_ID AS secondId,
       tsod.FOUR_ID AS fourId,
       tso.CUSTOMER_NO AS customerNo,
       tso.CUSTOMER_NAME AS customerName,
       tso.VEHICLE_RETURN_DATE AS vehicleReturnDate,
       tso.VEHICLE_RETURN_DATE AS vehicleReturnDates,
       tso.CUSTOMER_SURNAMES AS customerSurnames,
       tso.GENDER AS gender,
       tso.CONTACT_NAME AS contactName,
       tso.SO_NO AS soNo,
       tso.SO_STATUS AS soStatus,
       tso.STATUS_MARK AS statusMark,
       tso.CONSULTANT AS consultant,
       tso.IS_CLEARING AS isClearing,
       tso.SHEET_CREATED_BY AS sheetCreatedBy,
       tso.SHEET_CREATE_DATE AS sheetCreateDate,
       tso.CUSTOMER_TEL AS customerTel,
       tso.CUSTOMER_TEL AS VisibleCustomerTel,
       tso.CUSTOMER_TYPE AS customerType,
       tso.CUSTOMER_CERTIFICATE_NO AS customerCertificateNo,
       tso.CUSTOMER_ADDRESS AS customerAddress,
       tsod.MATERIAL_ID AS materialId,
       tsod.MATERIAL_LEVEL AS materialLevel,
       tsov.DELIVERING_DATE AS deliveringDates,
       tsov.DELIVERING_DATE AS deliveringDate,
       tsov.HAND_VEHICLE_DATE AS handVehicleDate,
       tsov.HAND_VEHICLE_DATE AS handVehicleDates,
       tso.CUSTOMER_SOURCE AS customerSource,
       tso.DRAWER_SURNAMES AS drawerSurnames,
       tso.DRAWER_NAME AS drawerName,
       tso.DRAWER_TEL AS drawerTel,
       tso.DRAWER_TEL AS drawerEncryptionTel,
       tso.DRAWER_CTCODE AS drawerCtcode,
       tso.DRAWER_CERTIFICATE_NO AS drawerCertificateNo,
       tso.DRAWER_ADDRESS AS drawerAddress,
       tso.CUSTOMER_NO AS customerNo,
       tsov.SALE_TYPE AS saleType,
       tsov.VEHICLE_RETAIL_ALLAMOUNT AS vehicleRetailAllAmount,
       tsov.VEHICLE_DEAL_ALLAMOUNT AS vehicleDealAllAmount,
       tsov.DISPATCHED_STATUS AS dispatchedStatus,
       tsov.AUXILIARY_STATUS as auxiliaryStatus,
       tsov.DELICATE_TOTAL_PRICE AS delicateTotalPrice,
       CASE
         WHEN tsov.DISPATCHED_STATUS=14141002 THEN '是'
         ELSE '否'
       END ex_dispatchedStatus,
       tsov.ORDER_ALL_AMOUNT AS orderAllAmount,
       tsov.VEHICLE_PRICE AS vehiclePrice,
       tsov.OFFSET_AMOUNT AS offsetAmount,
       tsov.HAND_VEHICLE_DATE AS handVehicleDate,
       tsov.HAND_VEHICLE_DATE AS handVehicleDates,
       tsov.DISPATCHED_DATE AS dispatchedDate,
       tsov.VS_STOCK_ID AS vsStockId,
       tsov.ORDER_OWNER_CODE as orderOwnerCode,
       tso.DEPOSIT_STATUS AS depositStatus,
       tso.IS_DEPOSIT AS isDeposit,
       tso.PAYMENT_STATUS AS paymentStatus,
       tso.INVOICE_STATUS AS invoiceStatus,
       tso.INVOICING_DATE AS invoicingDate,
       tso.ACTIVITY_ID AS activityId,
       tso.CREATED_AT AS createdAt,
       tso.CREATED_AT AS createdAts,
       tso.SUBMIT_TIME AS submitTime,
       tso.SUBMIT_TIME AS submitTimes,
       tso.AUDITED_BY_MANAGER_DATE AS auditedByManagerDate,
       tso.AUDITED_BY_MANAGER_DATE AS auditedByManagerDates,
       tso.IS_APP AS isApp
  FROM cyxdms_retail.tt_sales_order_vin tsov
 INNER JOIN cyxdms_retail.tt_sales_order_detail tsod ON tsov.SALES_OEDER_DETAIL_ID=tsod.SALES_OEDER_DETAIL_ID
 INNER JOIN cyxdms_retail.tt_sales_orders tso ON tsod.SO_NO_ID=tso.SO_NO_ID
 inner join sales_report.view_organization_info dealer_info on tso.OWNER_CODE=dealer_info.company_code
 left join cyxdms_retail.tt_sales_orders_ext tsoe on tso.so_no_id=tsoe.so_no_id
 WHERE tso.IS_DELETED=0 
-- and tsov.SALES_VIN='LVYPDH5D0RP392102' 
 and tso.SO_STATUS='14041008'
  AND tso.BUSINESS_TYPE=14031001
	 and tsoe.first_deposit_date >='2025-02-01' -- 定金支付时间
	 and tsoe.first_deposit_date <'2025-03-01' -- 定金支付时间
 GROUP BY tso.SO_NO_ID
 order by tso.CREATED_AT DESC