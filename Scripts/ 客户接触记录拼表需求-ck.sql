-- 订单详情表
select 
distinct
xx.customer_business_id `商机id`,
xx.sales_vin as vin,
xx.so_no as `订单号`,--订单号
xx.delivery_owner_code as `门店`, -- 门店
xx.customer_name as `客户姓名`,--客户姓名
xx.first_deposit_date `定金支付时间`,--定金支付时间
o.first_consultant `开单顾问`,
o.`人员姓名` `开单顾问姓名`,
o.`人员岗位` `开单顾问岗位`,
o.`云学院岗位` `开单顾问云学院岗位`,
x.`商机id` `商机id2`,
x.`接触形式` `接触形式`,
x.`接触方式/渠道` `接触方式/渠道`,
x.`接触记录` `接触记录`,
x.`接触时间` `接触时间`,
x.`接触人员` `接触人员`,
x.`备注（接触人员取值）` `备注（接触人员取值）`,
x.`接触人员姓名` `接触人员姓名`,
x.`接触人员岗位` `接触人员岗位`,
x.`接触人员云学院岗位` `接触人员云学院岗位`,
'' `备注`,
year(xx.first_deposit_date)`年份-订单定金支付`,
month(xx.first_deposit_date)`月份-订单定金支付`,
toDate(xx.first_deposit_date)`日期-订单定金支付`,
year(x.`接触时间`)`年份-接触记录`,
month(x.`接触时间`)`月份-接触记录`,
toDate(x.`接触时间`)`日期-接触记录`,
IF(year(x.`接触时间`)>2023,'是','否')`是否2024年及以后接触记录`,
IF(x.`接触时间`<=xx.first_deposit_date,'是','否')`接触是否早于定金支付时间`,
IF(o.first_consultant=x.`接触人员`,'是','否')`接触人是否一致（单次）`,
''`是否特殊车辆`,
(toUInt32(xx.first_deposit_date) - toUInt32(x.`接触时间`)) / (3600 * 24) `订单时间-接触时间`
--`订单序号,识别拼单`,
--`开单顾问总订单数`,
--`开单顾问绿灯订单数`,
--`总接触次数`,
--`开单顾问接触次数`
from ( 
-- 订单详情表 强代理 弱代理
	select 
	distinct
	tso.customer_business_id `customer_business_id`,
	tsov.sales_vin as sales_vin,
	tso.so_no as `so_no`,--订单号
	tsov.delivery_owner_code as `delivery_owner_code`, -- 门店
	tso.customer_name as `customer_name`,--客户姓名
	tsoe.first_deposit_date `first_deposit_date`
	 from ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov
	 join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tsov.sales_oeder_detail_id::String=tsod.SALES_OEDER_DETAIL_ID::String
	 join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tsod.SO_NO_ID=tso.so_no_id 
	 left join ods_cydr.ods_cydr_tt_sales_orders_ext_d tsoe on tso.so_no_id=tsoe.so_no_id
	 where 1=1
	 and tso.is_deleted=0
	 and tso.so_status<>'14041009' -- 订单状态剔除“已取消”
	 and first_deposit_date >='2025-03-01' -- 定金支付时间
	 and first_deposit_date <'2025-03-13' -- 定金支付时间
	 and tsov.sale_type not in ('20131004','20131003')-- 订单类型剔除”试驾车”、“代步车”；
	 and tso.strong_weak_agent not in ('87811003','87811004')--剔除 销售模式为“批零制“ “新零售“
	 AND tso.business_type=14031001
	-- and tso.so_no='VVD2025020100019'
	 union all 
	 -- 订单详情表 “批零制“ “新零售“
	select 
	distinct
	tso.customer_business_id `customer_business_id`,
	tsov.sales_vin as vin,
	tso.so_no as `so_no`,--订单号
	tsov.delivery_owner_code as `delivery_owner_code`, -- 门店
	tso.customer_name as `customer_name`,--客户姓名
	tsoe.first_deposit_date `first_deposit_date`
	 from ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov
	 join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tsov.sales_oeder_detail_id::String=tsod.SALES_OEDER_DETAIL_ID::String
	 join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tsod.SO_NO_ID=tso.so_no_id 
	 left join ods_cydr.ods_cydr_tt_sales_orders_ext_d tsoe on tso.so_no_id=tsoe.so_no_id
	 LEFT JOIN(
	    SELECT SUM(total_amount) as totalAmount,
	           so_id
	      FROM ods_cydr.ods_cydr_tt_order_pay_d
	     WHERE is_deleted=0
	       AND pay_status=88001003
	       and pay_source in ('VOLVO_PAY_SOURCE','LAKALA_TRANSFER_SOURCE','POS_PAY_SOURCE')
	     GROUP BY so_id
	    ) topy on tso.so_no_id=topy.so_id
	 where 1=1
	 and tso.is_deleted=0 
	 and tso.so_status<>'14041009' -- 订单状态剔除“已取消”
	 and tsoe.first_deposit_date >='2025-03-01' -- 定金支付时间
	 and tsoe.first_deposit_date <'2025-03-13' -- 定金支付时间
	 and tsov.sale_type not in ('20131004','20131003')-- 订单类型剔除”试驾车”、“代步车”；
	 and tso.strong_weak_agent in ('87811003','87811004')--销售模式为“批零制“ “新零售“
	 AND tso.business_type=14031001
	 and (((IFNULL(tso.strong_weak_agent,0)!=87811004 
	         or IFNULL(tsod.direct_dealer_is,0)!=96341002) 
	         AND tsoe.deposit_pay_way in ('88031001','88031002','88031003','88031005'))
	         or (tso.strong_weak_agent=87811004 
	         AND tsod.direct_dealer_is=96341002 
	         and IFNULL(topy.totalAmount,0)>=tso.contract_earnest*100 )) -- 沃尔沃零售支付渠道”为“是” 的订单
	-- and tso.so_no='TYB2025021900001'
	 order by tso.created_at desc
     )xx 
	 left join ( -- 2.通过订单号匹配开单顾问
	select so_no,
	t.first_consultant first_consultant,
	x.EMPLOYEE_NAME `人员姓名`,
	x.`角色` `人员岗位`,
	x2.`云学院岗位` `云学院岗位`
	  from ods_cydr.ods_cydr_tt_sales_orders_cur a 
	  left join ods_cydr.ods_cydr_tt_sales_orders_ext_d t on a.so_no_id =t.so_no_id 
	  left join (--4.通过USER_ID匹配NB岗位及姓名
		select tu.USER_ID USER_ID,
		       e.EMPLOYEE_NAME EMPLOYEE_NAME,
		       arrayStringConcat(groupArray(tr.ROLE_NAME), ', ') `角色`
		  from ods_oper_crm.ods_oper_crm_tm_user_d_ri tu
		 inner join ods_oper_crm.ods_oper_crm_tm_emp_d_ri e on e.EMP_ID=tu.EMP_ID
		  left join ods_auth.ods_auth_tr_user_org_d tuo on tuo.USER_ID=tu.USER_ID and tuo.IS_DELETED=0
		  left join ods_auth.ods_auth_tr_org_role_d tor on tor.USER_ORG_ID=tuo.USER_ORG_ID and tor.IS_DELETED=0
		  left join ods_auth.ods_auth_tm_role_d tr on tr.ROLE_ID=tor.ROLE_ID and tr.IS_DELETED=0
		 where 1=1
		 group by 1,2
		 order by tu.USER_ID asc
		 )x on ifnull(t.first_consultant,'')::String=x.USER_ID::String 
	left join (
	--云学院岗位
		select distinct 
		tncc.user_id `NB账号id`, 
		arrayStringConcat(groupArray(tnccr.position_detail_name), ',') `云学院岗位`
		--tnccr.position_detail_name
		from ods_oper_crm.ods_oper_crm_tm_user_d_ri tu
		join 
			(
			select 
			user_id,
			arrayJoin(splitByChar(',', ifnull(tncc.cloud_college_role,''))) cloud_college_role
			from ods_auth.ods_auth_tr_newbie_cloud_college_d tncc
			where 1=1
			and is_deleted = 0
		)tncc on tncc.user_id=tu.USER_ID
		left join ods_auth.ods_auth_tr_newbie_cloud_college_role_d tnccr on tnccr.position_detail_id=tncc.cloud_college_role
		group by 1 )x2 on x2.`NB账号id`::String=ifnull(t.first_consultant,'')::String
	  where 1=1
	--   and a.created_at >='2025-01-01'
      )o on o.so_no=xx.so_no
left join 
	(select a.`商机id` `商机id`,
	a.`接触形式` `接触形式`,
	a.`接触方式/渠道` `接触方式/渠道`,
	a.`接触记录` `接触记录`,
	a.`接触时间` `接触时间`,
	a.`接触人员` `接触人员`,
	a.`备注（接触人员取值）` `备注（接触人员取值）`,
	x.EMPLOYEE_NAME `接触人员姓名`,
	x.`角色` `接触人员岗位`,
	x2.`云学院岗位` `接触人员云学院岗位`
	from 
		(
		--试驾
		select
		distinct 
		a.CUSTOMER_BUSINESS_ID `商机id`,
		'试驾' `接触形式`,
		case when a.drive_mode = '83861001' then '上门试驾'
		when a.drive_mode = '83861002' then '到店试驾'
		end `接触方式/渠道`,
		ITEM_ID::varchar `接触记录`, --试驾单号
		a.DRIVE_S_AT `接触时间`,
		a.test_consultant `接触人员`,
		'取试驾单上试驾顾问' `备注（接触人员取值）`
		--x.EMPLOYEE_NAME `接触人员姓名`,
		--x.`角色` `接触人员岗位`,
		--x2.`云学院岗位`
		from ods_drse.ods_drse_tt_testdrive_plan_d a
		where 1=1
		and IS_DELETED = '0'
		and DRIVE_STATUS!='20211002'
		 and a.DRIVE_S_AT >='2025-03-01' -- 接触时间
		and a.DRIVE_S_AT <'2025-03-13' -- 接触时间
		union all
		--外呼
		 select
		 distinct 
		 business_id `商机ID`,
		 '外呼' `接触形式`,
		 '电话（AI通话统计报表）' `接触方式/渠道`,
		 task_id `接触记录`,--跟进ID
		 toDateTime(left(begin_time,19)) `接触时间`,
		 CONSULTANT_ID `接触人员`,-- 接触人员
		 '外呼人' `备注（接触人员取值）`
		-- x.EMPLOYEE_NAME `接触人员姓名`,
		-- x.`角色` `接触人员岗位`,
		-- x2.`云学院岗位`
		 from ods_cyct.ods_cyct_tt_record_d a
		 where 1=1
		 and call_direct='out'
		 and business_id is not null 
		  and a.begin_time >='2025-03-01'
		 and a.begin_time <'2025-03-13' 
		union all
		 --客流
		 select
		 distinct 
		  a.customer_business_id `商机ID`,
		   '接待' `接触形式`,
		  case
		    when a.passenger_mode = '86891001' then '展厅接待'
		    when a.passenger_mode = '86891002' then '上门接待'
		  end `接触方式/渠道`,
		  a.id::String `接触记录`,--`客流ID`
		  toDateTime(left(a.arrive_date,19)) `接触时间`,
		  a.reception_consultant `接待顾问`,
		  '取接待顾问' `备注（接触人员取值）`
		-- x.EMPLOYEE_NAME `接触人员姓名`,
		-- x.`角色` `接触人员岗位`,
		-- x2.`云学院岗位`
		from
		  ods_cypf.ods_cypf_tt_passenger_flow_info_cur a 
		where 1=1 
		 and a.arrive_date>='2025-03-01'
		and a.arrive_date<'2025-03-13' 
		and a.is_deleted=0
		order by a.arrive_date DESC 
		union all 
		--跟进
		-- 数据源:rds-mysql-newbie-prod-sales-shanghai1
		-- 数据库:customer_business
		select
		distinct 
		  CUSTOMER_BUSINESS_ID `商机ID`,
		  '跟进' `接触形式`,
		  '跟进（潜客跟进）' `接触方式/渠道`,
		  ACTION_ID::String `接触记录`,-- `跟进ID`
		  FACT_ACTION_DATE `接触时间`,
		  CONSULTANT `接待顾问`,
		  '取跟进记录创建人' `备注（接触人员取值）`
		from
		  ods_cubu.ods_cubu_tt_actioned_d
		where 1=1
		--  CUSTOMER_BUSINESS_ID in (1874477025973100545) 
		  and ACTION_STATUS not in (15171003) 
		  and   ACTION_STATUS <> '15171001'  --剔除自动完成跟进的部分
		and (( SCENE not like '%自动结束跟进'
		and  SCENE not like '%自动跟进'
		and  SCENE not like '%自动完成跟进'
		and  SCENE not like '%自动完成未完成跟进') or  SCENE is null or  SCENE = '')
		and FACT_ACTION_DATE>='2025-03-01'
		and FACT_ACTION_DATE<'2025-03-13' 
		)a
	left join (--4.通过USER_ID匹配NB岗位及姓名
		-- 数据源:rds-mysql-newbie-prod-mid-shanghai1
		-- 数据库:ods_oper_crm
		select tu.USER_ID USER_ID,
		       e.EMPLOYEE_NAME EMPLOYEE_NAME,
		       arrayStringConcat(groupArray(tr.ROLE_NAME), ', ') `角色`
		  from ods_oper_crm.ods_oper_crm_tm_user_d_ri tu
		 inner join ods_oper_crm.ods_oper_crm_tm_emp_d_ri e on e.EMP_ID=tu.EMP_ID
		  left join ods_auth.ods_auth_tr_user_org_d tuo on tuo.USER_ID=tu.USER_ID and tuo.IS_DELETED=0
		  left join ods_auth.ods_auth_tr_org_role_d tor on tor.USER_ORG_ID=tuo.USER_ORG_ID and tor.IS_DELETED=0
		  left join ods_auth.ods_auth_tm_role_d tr on tr.ROLE_ID=tor.ROLE_ID and tr.IS_DELETED=0
		 where 1=1
		 group by 1,2
		 order by tu.USER_ID asc
		 )x on ifnull(x.USER_ID,'')::String=ifnull(a.`接触人员`,'')::String
	left join (
	--云学院岗位
		select distinct 
		tncc.user_id `NB账号id`, 
		arrayStringConcat(groupArray(tnccr.position_detail_name), ',') `云学院岗位`
		--tnccr.position_detail_name
		from ods_oper_crm.ods_oper_crm_tm_user_d_ri tu
		join 
			(
			select 
			user_id,
			arrayJoin(splitByChar(',', ifnull(tncc.cloud_college_role,''))) cloud_college_role
			from ods_auth.ods_auth_tr_newbie_cloud_college_d tncc
			where 1=1
			and is_deleted = 0
		)tncc on tncc.user_id=tu.USER_ID
		left join ods_auth.ods_auth_tr_newbie_cloud_college_role_d tnccr on tnccr.position_detail_id=tncc.cloud_college_role
		group by 1 )x2 on ifnull(x2.`NB账号id`,'')::String=ifnull(a.`接触人员`,'')::String
	)x on x.`商机id`=xx.customer_business_id 
 where 1=1
 and x.`商机id`='1898989908971212802'
 order by x.`接触时间` desc
 
 

 -----------------------------------------------------
 
  select *
 from 
 (
-- 订单详情表 强代理 弱代理
select 
distinct
tso.customer_business_id `商机id`,
tsov.sales_vin as vin,
tso.so_no as `订单号`,--订单号
tsov.delivery_owner_code as `门店`, -- 门店
tso.customer_name as `客户姓名`,--客户姓名
tsoe.first_deposit_date `定金支付时间`
 from ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov
 join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tsov.sales_oeder_detail_id::String=tsod.SALES_OEDER_DETAIL_ID::String
 join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tsod.SO_NO_ID=tso.so_no_id 
 left join ods_cydr.ods_cydr_tt_sales_orders_ext_d tsoe on tso.so_no_id=tsoe.so_no_id
 where 1=1
 and tso.is_deleted=0
 and tso.so_status<>'14041009' -- 订单状态剔除“已取消”
 and first_deposit_date >='2025-03-01' -- 定金支付时间
 and first_deposit_date <'2025-03-13' -- 定金支付时间
 and tsov.sale_type not in ('20131004','20131003')-- 订单类型剔除”试驾车”、“代步车”；
 and tso.strong_weak_agent not in ('87811003','87811004')--剔除 销售模式为“批零制“ “新零售“
 AND tso.business_type=14031001
-- and tso.so_no='VVD2025020100019'
 union all 
 -- 订单详情表 “批零制“ “新零售“
select 
distinct
tso.customer_business_id `商机id`,
tsov.sales_vin as vin,
tso.so_no as `订单号`,--订单号
tsov.delivery_owner_code as `门店`, -- 门店
tso.customer_name as `客户姓名`,--客户姓名
tsoe.first_deposit_date `定金支付时间`
 from ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov
 join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tsov.sales_oeder_detail_id::String=tsod.SALES_OEDER_DETAIL_ID::String
 join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tsod.SO_NO_ID=tso.so_no_id 
 left join ods_cydr.ods_cydr_tt_sales_orders_ext_d tsoe on tso.so_no_id=tsoe.so_no_id
 LEFT JOIN(
    SELECT SUM(total_amount) as totalAmount,
           so_id
      FROM ods_cydr.ods_cydr_tt_order_pay_d
     WHERE is_deleted=0
       AND pay_status=88001003
       and pay_source in ('VOLVO_PAY_SOURCE','LAKALA_TRANSFER_SOURCE','POS_PAY_SOURCE')
     GROUP BY so_id
    ) topy on tso.so_no_id=topy.so_id
 where 1=1
 and tso.is_deleted=0 
 and tso.so_status<>'14041009' -- 订单状态剔除“已取消”
 and tsoe.first_deposit_date >='2025-03-01' -- 定金支付时间
 and tsoe.first_deposit_date <'2025-03-13' -- 定金支付时间
 and tsov.sale_type not in ('20131004','20131003')-- 订单类型剔除”试驾车”、“代步车”；
 and tso.strong_weak_agent in ('87811003','87811004')--销售模式为“批零制“ “新零售“
 AND tso.business_type=14031001
 and (((IFNULL(tso.strong_weak_agent,0)!=87811004 
         or IFNULL(tsod.direct_dealer_is,0)!=96341002) 
         AND tsoe.deposit_pay_way in ('88031001','88031002','88031003','88031005'))
         or (tso.strong_weak_agent=87811004 
         AND tsod.direct_dealer_is=96341002 
         and IFNULL(topy.totalAmount,0)>=tso.contract_earnest*100 ))
-- and tso.so_no='TYB2025021900001'
 order by tso.created_at desc
 )x 
 where x.`商机id`='1898989908971212802'
 
 
select a.`商机id` `商机id`,
	a.`接触形式` `接触形式`,
	a.`接触方式/渠道` `接触方式/渠道`,
	a.`接触记录` `接触记录`,
	a.`接触时间` `接触时间`,
	a.`接触人员` `接触人员`,
	a.`备注（接触人员取值）` `备注（接触人员取值）`
	from 
		(
		--试驾
		select
		distinct 
		a.CUSTOMER_BUSINESS_ID `商机id`,
		'试驾' `接触形式`,
		case when a.drive_mode = '83861001' then '上门试驾'
		when a.drive_mode = '83861002' then '到店试驾'
		end `接触方式/渠道`,
		ITEM_ID::varchar `接触记录`, --试驾单号
--		a.CREATED_AT`接触时间`,
		a.DRIVE_S_AT  `接触时间`,
		a.test_consultant `接触人员`,
		'取试驾单上试驾顾问' `备注（接触人员取值）`
		--x.EMPLOYEE_NAME `接触人员姓名`,
		--x.`角色` `接触人员岗位`,
		--x2.`云学院岗位`
		from ods_drse.ods_drse_tt_testdrive_plan_d a
		where 1=1
		and IS_DELETED = '0'
		and DRIVE_STATUS!='20211002'
		 and a.DRIVE_S_AT >='2025-03-01' -- 接触时间
		and a.DRIVE_S_AT <'2025-03-13' -- 接触时间
		union all
		--外呼
		 select
		 distinct 
		 business_id `商机ID`,
		 '外呼' `接触形式`,
		 '电话（AI通话统计报表）' `接触方式/渠道`,
		 task_id `接触记录`,--跟进ID
		 toDateTime(left(begin_time,19)) `接触时间`,
		 CONSULTANT_ID `接触人员`,-- 接触人员
		 '外呼人' `备注（接触人员取值）`
		-- x.EMPLOYEE_NAME `接触人员姓名`,
		-- x.`角色` `接触人员岗位`,
		-- x2.`云学院岗位`
		 from ods_cyct.ods_cyct_tt_record_d a
		 where 1=1
		 and call_direct='out'
		 and business_id is not null 
		  and a.begin_time >='2025-03-01'
		 and a.begin_time <'2025-03-13' 
		union all
		 --客流
		 select
		 distinct 
		  a.customer_business_id `商机ID`,
		   '接待' `接触形式`,
		  case
		    when a.passenger_mode = '86891001' then '展厅接待'
		    when a.passenger_mode = '86891002' then '上门接待'
		  end `接触方式/渠道`,
		  a.id::String `接触记录`,--`客流ID`
		  toDateTime(left(a.arrive_date,19)) `接触时间`,
		  a.reception_consultant `接待顾问`,
		  '取接待顾问' `备注（接触人员取值）`
		-- x.EMPLOYEE_NAME `接触人员姓名`,
		-- x.`角色` `接触人员岗位`,
		-- x2.`云学院岗位`
		from
		  ods_cypf.ods_cypf_tt_passenger_flow_info_cur a 
		where 1=1 
		 and a.arrive_date>='2025-03-01'
		and a.arrive_date<'2025-03-13' 
		and a.is_deleted=0
		order by a.arrive_date DESC 
		union all 
		--跟进
		-- 数据源:rds-mysql-newbie-prod-sales-shanghai1
		-- 数据库:customer_business
		select
		distinct 
		  CUSTOMER_BUSINESS_ID `商机ID`,
		  '跟进' `接触形式`,
		  '跟进（潜客跟进）' `接触方式/渠道`,
		  ACTION_ID::String `接触记录`,-- `跟进ID`
		  FACT_ACTION_DATE `接触时间`,
		  CONSULTANT `接待顾问`,
		  '取跟进记录创建人' `备注（接触人员取值）`
		from
		  ods_cubu.ods_cubu_tt_actioned_d
		where 1=1
		--  CUSTOMER_BUSINESS_ID in (1874477025973100545) 
		  and ACTION_STATUS not in (15171003) 
		  and   ACTION_STATUS <> '15171001'  --剔除自动完成跟进的部分
		and (( SCENE not like '%自动结束跟进'
		and  SCENE not like '%自动跟进'
		and  SCENE not like '%自动完成跟进'
		and  SCENE not like '%自动完成未完成跟进') or  SCENE is null or  SCENE = '')
		and FACT_ACTION_DATE>='2025-03-01'
		and FACT_ACTION_DATE<'2025-03-13' 
		)a
 where 1=1
 and a.`接触记录`='1898990191365701634' -- 1898676996310679554
-- and a.`商机id`='1898582727565889537' -- 1898676996310679554