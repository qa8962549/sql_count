--参与活动&23年回厂车辆数
	select 
	datediff('year',toDate(tisd.invoice_date),toDate('2023-12-12')) t,
	count(distinct xx.vin_code),
	count(distinct xx.id)
	from 
		(select distinct a.cust_id as id,
		a.member_id,
		a.vin_code
		from (
	--		 取最近一次绑车时间
			 select
			 r.member_id,
			 m.cust_id,
			 r.bind_date,
			 r.vin_code,
			 m.member_phone,
			 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
			 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
			 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
			 where r.deleted = 0
			 and r.is_bind = 1   -- 绑车
			 and r.is_owner=1  -- 车主
			 and r.member_id is not null 
			 and r.member_id <>''
			 and m.member_phone<>'*'
			 and m.member_phone is not null 
			 Settings allow_experimental_window_functions = 1
			 )a 
		where a.rk=1
		)xx 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on xx.vin_code=tisd.vin  -- 与发票表关联
	join 
		(select e.DELIVERER_MOBILE
		from ods_cyre.ods_cyre_tt_repair_order_d e 
		where 1=1
--		and year(e.RO_CREATE_DATE) ='2023' -- 2023年回过厂
		and e.RO_CREATE_DATE >='2024-04-01'
		and e.RO_CREATE_DATE <'2024-05-01'
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
		)e on xx.vin_code=e.VIN  --工单表
--	left join ods_cyre. a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
--	and a.IS_RED = 10041002   -- 非反结算 
	group by ROLLUP(t)
	order by t	
	
select distinct e.DELIVERER_MOBILE
from ods_cyre.ods_cyre_tt_repair_order_d e 
where 1=1
--and year(e.RO_CREATE_DATE) ='2023' -- 2023年回过厂
and e.RO_CREATE_DATE >='2024-04-01'
and e.RO_CREATE_DATE <'2024-05-01'
and e.RO_STATUS = '80491003'-- 已结算工单
and e.REPAIR_TYPE_CODE <> 'P'-- 售后
and e.REPAIR_TYPE_CODE <> 'S'
and e.IS_DELETED = 0
and e.DELIVERER_MOBILE not in (-- APP用户手机号
	select distinct m2.member_phone 
	from ads_crm.ads_crm_events_member_d m
	left join ods_memb.ods_memb_tc_member_info_cur m2 on  toString(m.distinct_id) =toString(m2.cust_id) 
	where 1=1
	and min_app_time is not null  -- 筛选app用户
	and date(min_app_time)<= '2024-05-01')

		