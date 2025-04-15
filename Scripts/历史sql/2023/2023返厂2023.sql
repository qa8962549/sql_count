-- 截止上个月月底的剩余V值
select 
--count(distinct case when x.截止余额>300 then x.member_id else null end) V值余额大于300的车主数,
count(distinct case when x.截止余额>3000 then x.member_id else null end) V值余额大于3000的人数
from 
	(
	select
	f.member_id,
	IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) 用户当前剩余V值,
	(IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0)) - 
		sum(case when to_date(f.create_time) >'2023-10-31' then  -- 上月底
				case when f.RECORD_TYPE = 1 then -f.INTEGRAL 
					when f.RECORD_TYPE = 0 then f.INTEGRAL 
					else 0 end else 0 end) "截止余额"
	from "member".tt_member_flow_record f
	join "member".tc_member_info m on f.MEMBER_ID = m.ID and m.IS_DELETED = 0 and m.MEMBER_STATUS <> 60341003
	where 1=1
	and f.IS_DELETED = 0
	GROUP BY 1,2
	order by 2 desc 
)x

-- ——————————————————————售后卡券持有——————————————————————
select 
count(distinct c.one_id) as UV
from coupon.tt_coupon_detail c -- 卡券明细表
where 1=1--c.coupon_source = '83241003' -- 限制卡券来源：商城购买
and c.is_deleted = 0
and c.get_date < '2023-11-01' -- 卡券获得时间
and c.expiration_date >='2023-10-01' --卡券过期时间
and c.coupon_id in
	(-- 所有售后卡券
		select
		distinct b.coupon_id
		from goods.item_spu a
		left join goods.item_sku b on a.id = b.spu_id
		where a.item_type = '51121003' )  -- 保养类卡券：售后

--2.    开票时间在2023年1-9月车辆在2023年1-9月回过厂的车辆数
	select 
	count(distinct tisd.vin)
			from (
					select distinct vin
				from (
				select ts.CLUE_NAME 来源渠道
				    ,b.active_code 市场活动代码
				    ,a.mobile 
				    ,a.dealer_code 
				    ,a.create_time
				    ,a.business_id
				    ,a.id
				    ,b.active_name
				    ,c.so_no
				    ,k.vin
				    ,case when k.vin is not null then 1 end as "kp_check"
				    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
				from customer.tt_clue_clean a 
				left join activity.cms_active b on a.campaign_id = b.uid 
				left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
				left join (
					SELECT so_no, CUSTOMER_BUSINESS_ID
						,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
					FROM cyxdms_retail.tt_sales_orders
					WHERE IS_DELETED = 0 
					AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
					) c 
				on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
				left join (
					select *, row_number()over(partition by vi_no order by created_at desc) as rn 
					from cyxdms_retail.tt_sales_order_vin 
					where is_deleted = 0 
					) d
				on c.so_no = d.vi_no and d.rn = 1
				left join (
					select cjh as vin, fpje
						,row_number()over(partition by cjh order by fphm desc) rn
					from `vehicle`.`v_jdcfphz`
					) k
				on d.sales_vin = k.vin and k.rn = 1
				where a.is_deleted = 0
				and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
				) tt 
				where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
	left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
	left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where 1=1
	and e.ro_create_date <'2023-11-01' -- 2023年1-9月回过厂
	and e.ro_create_date >='2023-01-01'
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and a.IS_RED = 10041002   -- 非反结算 

--2.    开票时间在2023年1-9月车辆在2023年1-9月回过厂的车辆数  车主
	select 
	count(distinct tisd.vin)
			from (
					select distinct vin
				from (
				select ts.CLUE_NAME 来源渠道
				    ,b.active_code 市场活动代码
				    ,a.mobile 
				    ,a.dealer_code 
				    ,a.create_time
				    ,a.business_id
				    ,a.id
				    ,b.active_name
				    ,c.so_no
				    ,k.vin
				    ,case when k.vin is not null then 1 end as "kp_check"
				    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
				from customer.tt_clue_clean a 
				left join activity.cms_active b on a.campaign_id = b.uid 
				left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
				left join (
					SELECT so_no, CUSTOMER_BUSINESS_ID
						,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
					FROM cyxdms_retail.tt_sales_orders
					WHERE IS_DELETED = 0 
					AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
					) c 
				on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
				left join (
					select *, row_number()over(partition by vi_no order by created_at desc) as rn 
					from cyxdms_retail.tt_sales_order_vin 
					where is_deleted = 0 
					) d
				on c.so_no = d.vi_no and d.rn = 1
				left join (
					select cjh as vin, fpje
						,row_number()over(partition by cjh order by fphm desc) rn
					from `vehicle`.`v_jdcfphz`
					) k
				on d.sales_vin = k.vin and k.rn = 1
				where a.is_deleted = 0
				and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
				) tt 
				where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
	left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
	left join cyx_repair.tt_balance_accounts b on b.ro_no = e.ro_no and b.owner_code = e.owner_code
	left join	(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)a on a.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =a.member_id
	where 1=1
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
	and e.ro_create_date <'2023-11-01' -- 2023年1-9月回过厂
	and e.ro_create_date >='2023-01-01'
	and e.ro_status = '80491003'-- 已结算工单
	and e.repair_type_code <> 'P'-- 售后
	and e.repair_type_code <> 'S'
	and e.is_deleted = 0
	and b.IS_RED = 10041002   -- 非反结算 

--3.1   
	select 
	count(distinct tisd.vin)
	from (
					select distinct vin
				from (
				select ts.CLUE_NAME 来源渠道
				    ,b.active_code 市场活动代码
				    ,a.mobile 
				    ,a.dealer_code 
				    ,a.create_time
				    ,a.business_id
				    ,a.id
				    ,b.active_name
				    ,c.so_no
				    ,k.vin
				    ,case when k.vin is not null then 1 end as "kp_check"
				    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
				from customer.tt_clue_clean a 
				left join activity.cms_active b on a.campaign_id = b.uid 
				left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
				left join (
					SELECT so_no, CUSTOMER_BUSINESS_ID
						,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
					FROM cyxdms_retail.tt_sales_orders
					WHERE IS_DELETED = 0 
					AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
					) c 
				on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
				left join (
					select *, row_number()over(partition by vi_no order by created_at desc) as rn 
					from cyxdms_retail.tt_sales_order_vin 
					where is_deleted = 0 
					) d
				on c.so_no = d.vi_no and d.rn = 1
				left join (
					select cjh as vin, fpje
						,row_number()over(partition by cjh order by fphm desc) rn
					from `vehicle`.`v_jdcfphz`
					) k
				on d.sales_vin = k.vin and k.rn = 1
				where a.is_deleted = 0
				and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
				) tt 
				where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
	where 1=1
			and tisd.vin not in (select 
			distinct tisd.vin
					from (
							select distinct vin
						from (
						select ts.CLUE_NAME 来源渠道
						    ,b.active_code 市场活动代码
						    ,a.mobile 
						    ,a.dealer_code 
						    ,a.create_time
						    ,a.business_id
						    ,a.id
						    ,b.active_name
						    ,c.so_no
						    ,k.vin
						    ,case when k.vin is not null then 1 end as "kp_check"
						    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
						from customer.tt_clue_clean a 
						left join activity.cms_active b on a.campaign_id = b.uid 
						left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
						left join (
							SELECT so_no, CUSTOMER_BUSINESS_ID
								,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
							FROM cyxdms_retail.tt_sales_orders
							WHERE IS_DELETED = 0 
							AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
							) c 
						on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
						left join (
							select *, row_number()over(partition by vi_no order by created_at desc) as rn 
							from cyxdms_retail.tt_sales_order_vin 
							where is_deleted = 0 
							) d
						on c.so_no = d.vi_no and d.rn = 1
						left join (
							select cjh as vin, fpje
								,row_number()over(partition by cjh order by fphm desc) rn
							from `vehicle`.`v_jdcfphz`
							) k
						on d.sales_vin = k.vin and k.rn = 1
						where a.is_deleted = 0
						and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
						) tt 
						where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
			left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
			left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
			where 1=1
			and e.ro_create_date <'2023-11-01' -- 2023年1-9月回过厂
			and e.ro_create_date >='2023-01-01'
			and e.ro_status = '80491003'-- 已结算工单
			and e.repair_type_code <> 'P'-- 售后
			and e.repair_type_code <> 'S'
			and e.is_deleted = 0
			and a.IS_RED = 10041002   -- 非反结算 
			)

--3.2 车主	
	select 
	count(distinct tmi.id)
	from (
					select distinct vin
				from (
				select ts.CLUE_NAME 来源渠道
				    ,b.active_code 市场活动代码
				    ,a.mobile 
				    ,a.dealer_code 
				    ,a.create_time
				    ,a.business_id
				    ,a.id
				    ,b.active_name
				    ,c.so_no
				    ,k.vin
				    ,case when k.vin is not null then 1 end as "kp_check"
				    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
				from customer.tt_clue_clean a 
				left join activity.cms_active b on a.campaign_id = b.uid 
				left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
				left join (
					SELECT so_no, CUSTOMER_BUSINESS_ID
						,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
					FROM cyxdms_retail.tt_sales_orders
					WHERE IS_DELETED = 0 
					AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
					) c 
				on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
				left join (
					select *, row_number()over(partition by vi_no order by created_at desc) as rn 
					from cyxdms_retail.tt_sales_order_vin 
					where is_deleted = 0 
					) d
				on c.so_no = d.vi_no and d.rn = 1
				left join (
					select cjh as vin, fpje
						,row_number()over(partition by cjh order by fphm desc) rn
					from `vehicle`.`v_jdcfphz`
					) k
				on d.sales_vin = k.vin and k.rn = 1
				where a.is_deleted = 0
				and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
				) tt 
				where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
	left join	(
				select a.member_id
				,a.vin_code
				,a.bind_date
				,b.model_name 拥车车型
				,row_number()over(partition by a.vin_code order by a.bind_date desc) rk 
				from volvo_cms.vehicle_bind_relation a
				left join basic_data.tm_model b on a.series_code =b.model_code
				where a.deleted = 0
				and a.is_bind=1
				)a on a.vin_code=tisd.vin 
	left join "member".tc_member_info tmi on tmi.id =a.member_id
	where 1=1
	and tmi.is_vehicle =1
	and tmi.is_deleted =0
	and tisd.vin not in (select 
			distinct tisd.vin
					from (
							select distinct vin
						from (
						select ts.CLUE_NAME 来源渠道
						    ,b.active_code 市场活动代码
						    ,a.mobile 
						    ,a.dealer_code 
						    ,a.create_time
						    ,a.business_id
						    ,a.id
						    ,b.active_name
						    ,c.so_no
						    ,k.vin
						    ,case when k.vin is not null then 1 end as "kp_check"
						    ,case when k.vin is not null and k.fpje <=0 then 1 end as "tp_check"    
						from customer.tt_clue_clean a 
						left join activity.cms_active b on a.campaign_id = b.uid 
						left join customer_business.tm_clue_source ts on ts.ID = b.active_channel
						left join (
							SELECT so_no, CUSTOMER_BUSINESS_ID
								,row_number()over(partition by CUSTOMER_BUSINESS_ID order by CREATED_AT desc) rn
							FROM cyxdms_retail.tt_sales_orders
							WHERE IS_DELETED = 0 
							AND CREATED_AT >= '2023-01-01' and CREATED_AT < '2023-11-01'
							) c 
						on a.business_id = c.CUSTOMER_BUSINESS_ID and c.rn = 1
						left join (
							select *, row_number()over(partition by vi_no order by created_at desc) as rn 
							from cyxdms_retail.tt_sales_order_vin 
							where is_deleted = 0 
							) d
						on c.so_no = d.vi_no and d.rn = 1
						left join (
							select cjh as vin, fpje
								,row_number()over(partition by cjh order by fphm desc) rn
							from `vehicle`.`v_jdcfphz`
							) k
						on d.sales_vin = k.vin and k.rn = 1
						where a.is_deleted = 0
						and a.create_time >= '2023-01-01' and a.create_time < '2023-11-01'
						) tt 
						where so_no is not null and kp_check is not null ) tisd   -- 与发票表关联
			left join cyx_repair.tt_repair_order e on tisd.vin=e.vin  --工单表
			left join cyx_repair.tt_balance_accounts a on a.ro_no = e.ro_no and a.owner_code = e.owner_code
			where 1=1
			and e.ro_create_date <'2023-11-01' -- 2023年1-9月回过厂
			and e.ro_create_date >='2023-01-01'
			and e.ro_status = '80491003'-- 已结算工单
			and e.repair_type_code <> 'P'-- 售后
			and e.repair_type_code <> 'S'
			and e.is_deleted = 0
			and a.IS_RED = 10041002   -- 非反结算 
			)			
	
-- 进厂 且 活跃
select count(distinct xx.member_id)
from ods_oper_crm.NewTable tisd
join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
left join	
	(select distinct a.cust_id as id,
	a.member_id as member_id,
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
		 and m.is_vehicle=1
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
			where t<toDate('2023-11-01')
			and t>='2023-01-01' -- 当年活跃
			and id is not null 
			union all
			-- APP活跃
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
			and t<toDate('2023-11-01')
			and t>='2023-01-01' -- 当年活跃
			and id is not null )x
	)x1 on toString(x1.id)=toString(xx.id) 
where 1=1
and e.RO_CREATE_DATE <'2023-11-01' -- 2023年回过厂
and e.RO_CREATE_DATE >='2023-01-01'
and e.RO_STATUS = '80491003'-- 已结算工单
and e.REPAIR_TYPE_CODE <> 'P'-- 售后
and e.REPAIR_TYPE_CODE <> 'S'
and e.IS_DELETED = 0
	
		
-- 未回厂 且 活跃
select count(distinct xx.member_id)
from ods_oper_crm.NewTable tisd
left join	
	(select distinct a.cust_id as id,
	a.member_id as member_id,
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
		 and m.is_vehicle=1
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
			where t<toDate('2023-11-01')
			and t>='2023-01-01' -- 当年活跃
			and id is not null 
			union all
			-- APP活跃
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
			and t<toDate('2023-11-01')
			and t>='2023-01-01' -- 当年活跃
			and id is not null )x
	)x1 on toString(x1.id)=toString(xx.id) 
where tisd.vin not in 
		(
		select 
		distinct tisd.vin as vin 
		from ods_oper_crm.NewTable tisd   -- 与发票表关联
		left join ods_cyre.ods_cyre_tt_repair_order_d e on tisd.vin=e.VIN  --工单表
		where 1=1
		and e.RO_CREATE_DATE <'2023-11-01' -- 2023年回过厂
		and e.RO_CREATE_DATE >='2023-01-01'
		and e.RO_STATUS = '80491003'-- 已结算工单
		and e.REPAIR_TYPE_CODE <> 'P'-- 售后
		and e.REPAIR_TYPE_CODE <> 'S'
		and e.IS_DELETED = 0
		)
