--车龄车辆数
	select 
	date_part('year',age('2023-12-12',invoice_date)),
	count(distinct x.vin_code),
	count(distinct tmi.id)
	from 
		(
		select * 
		from 
			(
			select a.member_id
			,a.vin_code
			,a.bind_date
			,b.model_name 拥车车型
			,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
			from volvo_cms.vehicle_bind_relation a
			left join basic_data.tm_model b on a.series_code =b.model_code
			where a.deleted = 0
			and a.is_bind=1
			and a.is_owner=1
			)x where x.rk=1
		)x 
	left join vehicle.tt_invoice_statistics_dms tisd on x.vin_code=tisd.vin and tisd.IS_DELETED =0    -- 与发票表关联
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	where 1=1
	and tmi.is_deleted =0
	group by rollup(1)
	order by 1,2

select count(1)
from vehicle.tt_invoice_statistics_dms
	
select date_part('year',age(date(now()),null))

select date(now())
	
--回厂车龄
	select 
	date_part('year',age('2023-12-12',invoice_date)),
	count(distinct x.vin_code),
	count(distinct tmi.id)
	from 
		(
		select * 
		from 
			(
			select a.member_id
			,a.vin_code
			,a.bind_date
			,b.model_name 拥车车型
			,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
			from volvo_cms.vehicle_bind_relation a
			left join basic_data.tm_model b on a.series_code =b.model_code
			where a.deleted = 0
			and a.is_bind=1
			and a.is_owner=1
			)x where x.rk=1
		)x 
	left join vehicle.tt_invoice_statistics_dms tisd on x.vin_code=tisd.vin and tisd.IS_DELETED =0    -- 与发票表关联
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	left join cyx_repair.tt_repair_order e on x.vin_code=e.vin 
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code   -- 非反结算 
	where 1=1
	and year(e.ro_create_date)='2023' 
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002 
	and tmi.is_deleted =0
	group by rollup(1)
	order by 1,2

	
--参与活动车辆数 车主数
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
--			 Settings allow_experimental_window_functions = 1
			 )a 
		where a.rk=1
		)xx 
	left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on xx.vin_code=tisd.vin  -- 与发票表关联
	join (
		select a.distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event ='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-01-01'
		and date<'2023-12-01'
		and page_title in ('11月会员日','沃尔沃汽车服务节',
		'10月商城亲子季','10月会员日','WOW商城·双11',
		'WOW商城-开箱季','9月会员日','WOW商城-开学季',
		'8月会员日','WOW商城-开学季',
		'1月会员日','好物迎春 献礼新岁','2月会员日','3月会员日','4月会员日','沃的好物 魅力节',
	 	'情人节活动','商城出行季活动','525车主节','6月会员日','618活动','夏服活动','WOW商城-消暑季','7月会员日')
		)a on toString(xx.id) =toString(a.distinct_id) 
	group by ROLLUP(t)
	order by t

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
		(select *
		from ods_cyre.ods_cyre_tt_repair_order_d e 
		where 1=1
		and year(e.RO_CREATE_DATE) ='2023' -- 2023年回过厂
	--	and e.ro_create_date >='2023-01-01'
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
		)e on xx.vin_code=e.VIN  --工单表
--	left join ods_cyre. a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	global join (
		select a.distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event ='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-01-01'
		and date<'2023-12-01'
		and page_title in ('11月会员日','沃尔沃汽车服务节',
		'10月商城亲子季','10月会员日','WOW商城·双11',
		'WOW商城-开箱季','9月会员日','WOW商城-开学季',
		'8月会员日','WOW商城-开学季',
		'1月会员日','好物迎春 献礼新岁','2月会员日','3月会员日','4月会员日','沃的好物 魅力节',
	 	'情人节活动','商城出行季活动','525车主节','6月会员日','618活动','夏服活动','WOW商城-消暑季','7月会员日')
		)a on toString(xx.id) =toString(a.distinct_id) 
	where 1=1
--	and a.IS_RED = 10041002   -- 非反结算 
	group by ROLLUP(t)
	order by t	

--回厂分月
	select 
	date_format(e.ro_create_date,'%Y-%m')返厂时间,
	count(distinct tisd.vin)
	from vehicle.tt_invoice_statistics_dms tisd   -- 与发票表关联
	left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
	and tisd.IS_DELETED =0
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
	and e.ro_create_date <'2023-10-01' -- 2023年回过厂
	and e.ro_create_date >='2023-01-01'
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002   -- 非反结算 
	group by 1
	order by 1
	
--开票时间分年
	select 
--	year(invoice_date) 开票时间,
	count(distinct tisd.vin)
	from vehicle.tt_invoice_statistics_dms tisd   -- 与发票表关联
	left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	where 1=1
	and tisd.IS_DELETED =0
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
	and tisd.invoice_date<'2017-01-01'
--	and tisd.invoice_date>='2018-01-01' -- 车龄在3年以内
--	and tisd.invoice_date<'2023-10-01'
--	group by 1
--	order by 1 desc 
	
--回厂车型分月
	select 
	x.拥车车型,
	count(distinct tisd.vin)
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-01' then tisd.vin else null end) `2023-01`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-02' then tisd.vin else null end) `2023-02`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-03' then tisd.vin else null end) `2023-03`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-04' then tisd.vin else null end) `2023-04`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-05' then tisd.vin else null end) `2023-05`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-06' then tisd.vin else null end) `2023-06`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-07' then tisd.vin else null end) `2023-07`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-08' then tisd.vin else null end) `2023-08`,
--	count(distinct case when date_format(e.ro_create_date,'%Y-%m')='2023-09' then tisd.vin else null end) `2023-09`
	from vehicle.tt_invoice_statistics_dms tisd   -- 与发票表关联
	left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
	and tisd.IS_DELETED =0
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
--	and tisd.invoice_date<'2017-01-01'
--	and tisd.invoice_date>='2018-01-01'
--	and tisd.invoice_date<'2023-10-01'
--	and e.ro_create_date <'2023-10-01' -- 2023年回过厂
--	and e.ro_create_date >='2023-01-01'
	and year(e.ro_create_date)='2022'
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002   -- 非反结算 
	group by 1
	order by 1 desc 
	
--2.    截止2023年9月，车辆在3年以内的车在2023年回过厂的车辆数
	select 
	count(distinct tisd.vin)
	from vehicle.tt_invoice_statistics_dms tisd   -- 与发票表关联
	left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)x on x.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =x.member_id
	left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
	and tisd.IS_DELETED =0
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
--	and year(invoice_date)=2023
--	and tisd.invoice_date>='2020-01-01' -- 车龄在3年以内
--	and tisd.invoice_date<'2023-10-01'
		and tisd.invoice_date>='2019-01-01' -- 车龄在3年以内
		and tisd.invoice_date<'2022-10-01'
--	and tisd.invoice_date>='2018-01-01' -- 车龄在3-5
--	and tisd.invoice_date<'2020-01-01'
--	and tisd.invoice_date<'2018-01-01' -- 车龄在5以上
	and e.ro_create_date <'2022-10-01' -- 2023年回过厂
	and e.ro_create_date >='2022-01-01'
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002   -- 非反结算 


-- 	进厂 且 活跃过
select 
count(distinct tisd.vin)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
left join	
	(select distinct a.cust_id as id,
	a.vin_code
	from (
--		 取最近一次绑车时间
		 select
		 r.member_id,
		 m.cust_id,
		 r.bind_date,
		 r.vin_code,
		 m.member_phone
		 row_number() over(partition by r.vin_code order by r.bind_date desc) rk
		 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
		 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
		 where r.deleted = 0
		 and r.is_bind = 1   -- 绑车
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
		 )a 
	where a.rk=1
	)xx on xx.vin_code=tisd.vin
join
	(-- 私域活跃
		select distinct x.id
		from 
			(
--			 小程序活跃
			select distinct toString(m.cust_id) id,toDate(t.`date`) t
			from ods_trac.ods_trac_track_cur t
			left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
			where t<'2023-10-01'
			and t>='2023-01-01' -- 当年活跃
			and id is not null 
			union all
			-- APP活跃 mini 
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
--			and event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5'
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
--			and event in('$MPViewScreen','$MPClick')
			and t<'2023-10-01'
			and t>='2023-01-01' -- 当年活跃
			and id is not null 
			)x
	)x1 on toString(x1.id)=toString(xx.id) 
where 1=1
	and tisd.is_deleted =0
--	and tisd.invoice_date>='2023-01-01'
	and tisd.invoice_date>='2020-01-01' -- 车龄在3年以内
	and tisd.invoice_date<'2023-10-01'
--		and tisd.invoice_date>='2019-01-01' -- 车龄在3年以内
--		and tisd.invoice_date<'2022-10-01'
--	and tisd.invoice_date>='2018-01-01' -- 车龄在3-5
--	and tisd.invoice_date<'2020-01-01'
--	and tisd.invoice_date<'2018-01-01' -- 车龄在5以上
	and e.RO_CREATE_DATE <'2023-10-01' -- 2023年回过厂
	and e.RO_CREATE_DATE >='2023-01-01'
	and e.RO_STATUS = '80491003'-- 已结算工单
	and e.REPAIR_TYPE_CODE <> 'P'-- 售后
	and e.REPAIR_TYPE_CODE <> 'S'
	and e.IS_DELETED = 0

-- 未回厂 且 活跃
	-- 	活跃过
select 
count(distinct tisd.vin)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
global left join 
		(
		select 
		distinct tisd.vin as vin 
		from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
		left join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
		where 1=1
		and tisd.is_deleted =0
	and tisd.invoice_date>='2023-01-01'
--	and tisd.invoice_date>='2020-01-01' -- 车龄在3年以内
--	and tisd.invoice_date<'2023-10-01'
--	and tisd.invoice_date>='2018-01-01' -- 车龄在3-5
--	and tisd.invoice_date<'2020-01-01'
--	and tisd.invoice_date<'2018-01-01' -- 车龄在5以上
--		and tisd.invoice_date>='2019-01-01' -- 车龄在3年以内
--		and tisd.invoice_date<'2022-10-01'
--		and tisd.invoice_date>='2017-01-01' -- 车龄在3-5
--		and tisd.invoice_date<'2019-01-01'
--		and tisd.invoice_date<'2017-01-01' -- 车龄在5以上
		and e.RO_CREATE_DATE <'2022-10-01' -- 2023年回过厂
		and e.RO_CREATE_DATE >='2022-01-01'
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
		)x on x.vin=tisd.vin
left join	
	(select distinct a.cust_id as id,
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
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
		 )a 
	where a.rk=1
	)xx on xx.vin_code=tisd.vin
join
	(-- 私域活跃
		select distinct x.id
		from 
			(
			-- 小程序活跃
			select distinct toString(m.cust_id) id,toDate(t.`date`) t
			from ods_trac.ods_trac_track_cur t
			left join ods_memb.ods_memb_tc_member_info_cur m on toString(t.usertag)=toString(m.user_id) 
			where t<toDate('2022-10-01')
			and t>='2022-01-01' -- 当年活跃
			and id is not null 
			union all
			-- APP活跃
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
			and t<toDate('2022-10-01')
			and t>='2022-01-01' -- 当年活跃
			and id is not null )x
	)x1 on toString(x1.id)=toString(xx.id) 
where 1=1
	and tisd.is_deleted =0
	and tisd.invoice_date>='2023-01-01'
--	and tisd.invoice_date>='2020-01-01' -- 车龄在3年以内
--	and tisd.invoice_date<'2023-10-01'
--	and tisd.invoice_date>='2018-01-01' -- 车龄在3-5
--	and tisd.invoice_date<'2020-01-01'
--	and tisd.invoice_date<'2018-01-01' -- 车龄在5以上
--		and tisd.invoice_date>='2019-01-01' -- 车龄在3年以内
--		and tisd.invoice_date<'2022-10-01'
--		and tisd.invoice_date>='2017-01-01' -- 车龄在3-5
--		and tisd.invoice_date<'2019-01-01'
--		and tisd.invoice_date<'2017-01-01' -- 车龄在5以上
	and x.vin is null 