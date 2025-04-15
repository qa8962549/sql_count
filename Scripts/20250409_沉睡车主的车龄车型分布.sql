--拉取登录过app，但是近3个月未在app活跃过的车主，其绑车的车型和开票车龄分布
	select 
	a.memberid ,
	x.model_name ,
	x.car_age 
	from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
	left join 
		(
		--车龄
			select distinct 
			xx.member_id,
			xx.vin_code,
			tisd.invoice_date,
			xx.model_name model_name,
			floor(datediff('month', toDate(invoice_date), toDate(now())) / 12) AS car_age,
			datediff('year',toDate(tisd.invoice_date),toDate(now())) num
			from 
				(select distinct a.cust_id as id,
				a.member_id member_id,
				a.vin_code vin_code,
				a.model_name model_name
				from (
			--		 取最近一次绑车时间
					 select
					 r.member_id member_id,
					 m.cust_id cust_id,
					 r.bind_date,
					 r.vin_code vin_code,
					 m.member_phone,
					 row_number() over(partition by r.member_id order by r.bind_date desc) rk,
					 m2.model_name model_name
					 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
					 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
					  left join ods_bada.ods_bada_tm_model_cur m2 on r.series_code=m2.model_code
					 where r.deleted = 0
					 and r.is_bind = 1   -- 绑车
					 and r.is_owner=1  -- 车主
					 )a 
				where a.rk=1 
				)xx 
			left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on xx.vin_code=tisd.vin  -- 与发票表关联
			where xx.id is not null 
			and model_name='EM90'
			)x on x.member_id =a.memberid 
	where 1=1
	and a.is_vehicle='1' -- 车主
	and a.min_app is not null 
	and a.max_app <toDate(now()) - INTERVAL '3'month -- 近3个月未活跃
	
--拉取登录过app，但是近3个月未在app活跃过的车主，其绑车的车型和开票车龄分布
	select 
	x.model_name ,
	ifnull(toString(x.car_age),'未知车龄')car_age,
	count(distinct a.memberid) num 
	from ods_oper_crm.ods_oper_crm_usrv2_gio_d_si a
	left join 
		(
		--车龄
			select distinct 
			xx.member_id,
			tisd.invoice_date,
			xx.model_name model_name,
			floor(datediff('month', toDate(invoice_date), toDate(now())) / 12) AS car_age,
			datediff('year',toDate(tisd.invoice_date),toDate(now())) num
			from 
				(select distinct a.cust_id as id,
				a.member_id member_id,
				a.vin_code vin_code,
				a.model_name model_name
				from (
			--		 取最近一次绑车时间
					 select
					 r.member_id member_id,
					 m.cust_id cust_id,
					 r.bind_date,
					 r.vin_code vin_code,
					 m.member_phone,
					 row_number() over(partition by r.member_id order by r.bind_date desc) rk,
					 m2.model_name model_name
					 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
					 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
					  left join ods_bada.ods_bada_tm_model_cur m2 on r.series_code=m2.model_code
					 where r.deleted = 0
					 and r.is_bind = 1   -- 绑车
					 and r.is_owner=1  -- 车主
					 )a 
				where a.rk=1 
				)xx 
			left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd on xx.vin_code=tisd.vin  -- 与发票表关联
			where xx.id is not null 
			)x on x.member_id =a.memberid 
	where 1=1
	and a.is_vehicle='1' -- 车主
	and a.min_app is not null -- 登陆过app
	and a.max_app <toDate(now()) - INTERVAL '3'month -- 近3个月未活跃
	group by 1,2
	order by 1,2
	