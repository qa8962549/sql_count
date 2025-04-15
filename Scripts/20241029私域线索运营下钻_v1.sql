--私域：
--累计注册量
	select count(distinct m.id)
	from "member".tc_member_info m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time <'2024-10-29'

--私域留资量
-- 线索（一键留资） liteCRM
	select count(customer_mobile)
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	where 1=1
	and tlcp.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2024-10-29'

--私域线索量 APP和小程序预约试驾+一键留资数量clue
select count(x.mobile)
from 
	(
	select 
	ta.CUSTOMER_PHONE mobile
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2024-10-29'
	union all
	select tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2024-10-29'
	and tcc.campaign_code in 		
	(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
)x

--到店量
	select
	count(distinct concat(x.mobile,tp.arrive_date))
--	*
from 
	(
	select 
	distinct 
	ta.CUSTOMER_PHONE mobile,
	ta.CUSTOMER_BUSINESS_ID business_id,
	toDateTime(left(ta.CREATED_AT::String ,19)) create_time
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2024-10-29'
	union all
	select tcc.mobile mobile,
	tcc.business_id,
	toDateTime(left(tcc.create_time::String ,19)) create_time
--	tcc.create_time
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.is_deleted=0
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2024-10-29'
	and tcc.campaign_code in (
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
--	order by 3 desc 
)x
join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
where 1=1
and x.create_time is not null 
and tp.arrive_date is not null 
and tp.arrive_date >='2024-01-01'
and tp.arrive_date <'2024-10-29'
--and toDateTime(left(CAST(create_time AS String),19)) < toDateTime(left(CAST(tp.arrive_date AS String), 19))
and toDateTime(left(tp.arrive_date::String,19)) <=toDateTime(left(x.create_time::String ,19)) + interval '30 day'

--订单量
select
count(business_id)
--	*
from 
	(
	select 
	ta.CUSTOMER_PHONE mobile,
	ta.CUSTOMER_BUSINESS_ID business_id,
	toDateTime(ta.CREATED_AT ) create_time
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2024-10-29'
	union all
	select tcc.mobile mobile,
	tcc.business_id,
	toDateTime(tcc.create_time) 
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.is_deleted=0
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2024-10-29'
	and tcc.campaign_code in (
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
)x
join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
where 1=1
and x.create_time is not null 
and tso.so_status in (14041002,14041003,14041008,14041001)
and tso.is_deleted = 0 
and tso.created_at >='2024-01-01'
and tso.created_at <'2024-10-29'
and toDateTime(left(CAST(create_time AS String),19)) < toDateTime(left(CAST(tso.created_at AS String), 19))
and abs(toDate(tso.created_at)-toDate(x.create_time))<=60--60天内
--and toDateTime(left(tso.created_at::String,19)) <=toDateTime(left(x.create_time::String ,19)) + interval '60 day'

	
--	公域：
-- 留资
	select count(1) 
	from ods_vced.ods_vced_tm_leads_collection_pool_cur a
	where 1=1
	and a.`create_time` >='2024-01-01'
	and a.`create_time` < '2024-10-29'

-- 订单
	select 
	count(distinct a.so_no)
	FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
	left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on a.so_no_id =c.SO_NO_ID 
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on c.SALES_OEDER_DETAIL_ID::String =b.sales_oeder_detail_id::String 
	where 1=1
	and a.so_status in (14041001,14041002,14041003,14041008) -- 有效订单
	and a.created_at  < '2024-10-29'
	and a.created_at  >='2024-01-01'
	and a.is_deleted = 0
	and b.is_deleted = 0
	and c.IS_DELETED = 0    
 
--私域线索下发前未到店：  匹配NB和litecrm的线索，litecrm留资之后的30天内的首次到店，比较到店时间和留资线索时间（下发时间）
--私域线索下发已到店（非当天）：	
--私域线索下发已到店（当天）：
--	私域留资量
select count(1)
from 
	(
	-- litecrm留资之后的30天内的首次到店
	select x.customer_mobile mobile
	from 
		(
		select a.customer_mobile customer_mobile,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
		ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
		LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
		where 1=1
		and tpf.is_deleted =0
		and tcs.CLUE_NAME='总部CRM'
		and tcs.ID is not null 
		and ca.active_channel is not null
		and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
		)x
	where x.rk=1
	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
--	and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)
)x1
join  
(	select 
	distinct mobile
	from 
	(
	select 
	ta.CUSTOMER_PHONE mobile
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = ta.CUSTOMER_PHONE and m.is_deleted = 0
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
--	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2024-10-29'
	union all
	select customer_mobile
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
	where 1=1
	and tlcp.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-14'
		)
--	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2024-10-29'
	)x
)x2 on x2.mobile=x1.mobile

--私域线索量
select count(1)
from 
	(
	-- litecrm留资之后的30天内的首次到店
	select x.customer_mobile mobile
	from 
		(
		select a.customer_mobile customer_mobile,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
		ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
		LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
		where 1=1
		and tpf.is_deleted =0
		and tcs.CLUE_NAME='总部CRM'
		and tcs.ID is not null 
		and ca.active_channel is not null
		and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
		)x
	where x.rk=1
--	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
 and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)
)x1
join  
	(--私域线索量 总部CRM渠道下NB线索量
	select tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	JOIN ods_actv.ods_actv_cms_active_d ca on tcc.campaign_id = ca.uid
	LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
	where tcc.is_deleted = 0
	and tcc.create_time < '2024-10-29'
	and tcs.CLUE_NAME='总部CRM'
	and tcs.ID is not null 
	and ca.active_channel is not null
)x2 on x2.mobile=x1.mobile

--到店量
select count(1)
from 
	(
	-- litecrm留资之后的30天内的首次到店
	select x.customer_mobile mobile
	from 
		(
		select a.customer_mobile customer_mobile,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
		ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
		LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
		where 1=1
		and tpf.is_deleted =0
		and tcs.CLUE_NAME='总部CRM'
		and tcs.ID is not null 
		and ca.active_channel is not null
		and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
		)x
	where x.rk=1
--	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
	and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)
)x1
join  
(--到店量
	select 
	distinct tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	JOIN ods_actv.ods_actv_cms_active_d ca on tcc.campaign_id = ca.uid
	LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
	join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on tcc.business_id = tp.customer_business_id 
	where tcc.is_deleted = 0
	and tp.arrive_date is not null 
	and tp.is_deleted = 0 
	and tp.arrive_date <'2024-10-29'
	and tcc.create_time < tp.arrive_date 
	and tcs.CLUE_NAME='总部CRM'
	and tcs.ID is not null 
	and ca.active_channel is not null
	and toDateTime(left(tp.arrive_date,19)) <=toDateTime(left(tcc.create_time,19)) + interval '30 day'
	)x2 on x2.mobile=x1.mobile

--订单量
select count(1)
from 
	(
	-- litecrm留资之后的30天内的首次到店
	select x.customer_mobile mobile
	from 
		(
		select a.customer_mobile customer_mobile,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
		ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
		LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
		where 1=1
		and tpf.is_deleted =0
		and tcs.CLUE_NAME='总部CRM'
		and tcs.ID is not null 
		and ca.active_channel is not null
		and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
		)x
	where x.rk=1
--	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
	and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)
)x1
join  
(--订单量
    select 
      distinct a.mobile mobile
    from ods_cust.ods_cust_tt_clue_clean_cur a 
    left join ods_cust.ods_cust_tt_pontential_customer_d tpc on a.mobile = tpc.mobile 
    left join ods_cubu.ods_cubu_tt_customer_business_cur tcb on tpc.id = tcb.potential_customers_id 
    left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on tcb.customer_business_id = tpf.customer_business_id 
    left join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tcb.customer_business_id = tso.customer_business_id 
    where 1=1
    and tso.is_deleted = 0 
    and tso.created_at < '2024-10-29'
    and tso.so_status in (14041002,14041003,14041008,14041001)
    and a.create_time <= tpf.arrive_date 
    and a.create_time <= tso.created_at 
    and tpf.is_deleted = 0 
    and toDateTime(left(tso.created_at,19)) <=toDateTime(left(a.create_time,19)) + interval '60 day'  -- 只看线索，60天内
    )x2 on x2.mobile=x1.mobile	
	

    
--    私域首触线索下发前未到店：
--	私域留资量
select count(1)
from 
	(
--	首触线索下发时间与首次到店实际比较
	select 
--	x1.mobile mobile
	*
	from 
		(
		-- litecrm 总部CRM 首触线索下发时间
		select x.customer_mobile mobile,
--		x.`线索下发时间`
		toDateTime(left(x.`线索下发时间`,19)) `线索下发时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			tcs.CLUE_NAME,
	--		a.create_time `线索时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by a2.allot_time) rk,
			a2.allot_time `线索下发时间`
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			where 1=1
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			)x
		where 1=1
		and x.rk=1 
		and tcs.CLUE_NAME='总部CRM'
		)x1
	left join 
		(-- litecrm留资之后的30天内的首次到店
		select x.customer_mobile mobile,
		toDateTime(left(x.`到店时间`,19)) `到店时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			a.create_time `线索时间`,
			a2.allot_time `线索下发时间`,
			ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
			where 1=1
			and tpf.is_deleted =0
			and tcs.CLUE_NAME='总部CRM'
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
			)x
		where x.rk=1
		)x2 on x1.mobile=x2.mobile
	where 1=1
	and x1.`线索下发时间`<if(x2.`到店时间`<'2000-01-01','2025-01-01',x2.`到店时间`)
--	and toDate(x1.`线索下发时间`)>if(x2.`到店时间`<'2000-01-01','2025-01-01')
--	and toDateTime(left(x1.`线索下发时间`,19))>toDateTime(left(x2.`到店时间`,19))  and toDate(x1.`线索下发时间`)=toDate(x2.`到店时间`)
)x1
join  
(	select 
	distinct mobile
	from 
	(
	select 
	ta.CUSTOMER_PHONE mobile
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = ta.CUSTOMER_PHONE and m.is_deleted = 0
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') -- 预约试乘试驾
--	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2024-10-29'
	union all
	select customer_mobile
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	left join ods_memb.ods_memb_tc_member_info_cur m on m.member_phone = tlcp.customer_mobile and m.is_deleted = 0
	where 1=1
	and tlcp.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-14'
		)
--	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2024-10-29'
	)x
)x2 on x2.mobile=x1.mobile    

--	私域线索量
select count(1)
from 
	(
--	首触线索下发时间与首次到店实际比较
	select 
	x1.mobile mobile
--	*
	from 
		(
		-- litecrm 总部CRM 首触线索下发时间
		select x.customer_mobile mobile,
--		x.`线索下发时间`
		toDateTime(left(x.`线索下发时间`,19)) `线索下发时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			tcs.CLUE_NAME,
	--		a.create_time `线索时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by a2.allot_time) rk,
			a2.allot_time `线索下发时间`
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			where 1=1
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			)x
		where 1=1
		and x.rk=1 
		and tcs.CLUE_NAME='总部CRM'
		)x1
	left join 
		(-- litecrm留资之后的30天内的首次到店
		select x.customer_mobile mobile,
		toDateTime(left(x.`到店时间`,19)) `到店时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			a.create_time `线索时间`,
			a2.allot_time `线索下发时间`,
			ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
			where 1=1
			and tpf.is_deleted =0
			and tcs.CLUE_NAME='总部CRM'
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
			)x
		where x.rk=1
		)x2 on x1.mobile=x2.mobile
	where 1=1
	and x1.`线索下发时间`<ifnull(x2.`到店时间`,'2025-01-01 00:00:00')
--	and toDate(x1.`线索下发时间`)>toDate(x2.`到店时间`)
--	and toDateTime(left(x1.`线索下发时间`,19))>toDateTime(left(x2.`到店时间`,19))  and toDate(x1.`线索下发时间`)=toDate(x2.`到店时间`)
)x1
join  
(--私域线索量 总部CRM渠道下NB线索量
	select tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	JOIN ods_actv.ods_actv_cms_active_d ca on tcc.campaign_id = ca.uid
	LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
	where tcc.is_deleted = 0
	and tcc.create_time < '2024-10-29'
	and tcs.CLUE_NAME='总部CRM'
	and tcs.ID is not null 
	and ca.active_channel is not null
)x2 on x2.mobile=x1.mobile    

--	到店量
select count(1)
from 
	(
--	首触线索下发时间与首次到店实际比较
	select 
	x1.mobile mobile
--	*
	from 
		(
		-- litecrm 总部CRM 首触线索下发时间
		select x.customer_mobile mobile,
--		x.`线索下发时间`
		toDateTime(left(x.`线索下发时间`,19)) `线索下发时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			tcs.CLUE_NAME,
	--		a.create_time `线索时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by a2.allot_time) rk,
			a2.allot_time `线索下发时间`
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			where 1=1
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			)x
		where 1=1
		and x.rk=1 
		and tcs.CLUE_NAME='总部CRM'
		)x1
	left join 
		(-- litecrm留资之后的30天内的首次到店
		select x.customer_mobile mobile,
		toDateTime(left(x.`到店时间`,19)) `到店时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			a.create_time `线索时间`,
			a2.allot_time `线索下发时间`,
			ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
			where 1=1
			and tpf.is_deleted =0
			and tcs.CLUE_NAME='总部CRM'
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
			)x
		where x.rk=1
		)x2 on x1.mobile=x2.mobile
	where 1=1
	and x1.`线索下发时间`<ifnull(x2.`到店时间`,'2025-01-01 00:00:00')
--	and toDate(x1.`线索下发时间`)>toDate(x2.`到店时间`)
--	and toDateTime(left(x1.`线索下发时间`,19))>toDateTime(left(x2.`到店时间`,19))  and toDate(x1.`线索下发时间`)=toDate(x2.`到店时间`)
)x1
join  
(--到店量
	select 
	distinct tcc.mobile mobile
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	JOIN ods_actv.ods_actv_cms_active_d ca on tcc.campaign_id = ca.uid
	LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
	join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on tcc.business_id = tp.customer_business_id 
	where tcc.is_deleted = 0
	and tp.arrive_date is not null 
	and tp.is_deleted = 0 
	and tp.arrive_date <'2024-10-29'
	and tcc.create_time < tp.arrive_date 
	and tcs.CLUE_NAME='总部CRM'
	and tcs.ID is not null 
	and ca.active_channel is not null
	and toDateTime(left(tp.arrive_date,19)) <=toDateTime(left(tcc.create_time,19)) + interval '30 day'
	)x2 on x2.mobile=x1.mobile
	
	--	订单量
select count(1)
from 
	(
--	首触线索下发时间与首次到店实际比较
	select 
	x1.mobile mobile
--	*
	from 
		(
		-- litecrm 总部CRM 首触线索下发时间
		select x.customer_mobile mobile,
--		x.`线索下发时间`
		toDateTime(left(x.`线索下发时间`,19)) `线索下发时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			tcs.CLUE_NAME,
	--		a.create_time `线索时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by a2.allot_time) rk,
			a2.allot_time `线索下发时间`
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			where 1=1
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			)x
		where 1=1
		and x.rk=1 
		and tcs.CLUE_NAME='总部CRM'
		)x1
	left join 
		(-- litecrm留资之后的30天内的首次到店
		select x.customer_mobile mobile,
		toDateTime(left(x.`到店时间`,19)) `到店时间`
		from 
			(
			select a.customer_mobile customer_mobile,
			a.create_time `线索时间`,
			a2.allot_time `线索下发时间`,
			ifnull(tpf.arrive_date,'2000-01-01') `到店时间`,
			ROW_NUMBER() over(partition by a.customer_mobile order by tpf.arrive_date) rk
			from ods_vced.ods_vced_tm_leads_collection_pool_cur a
			left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
			JOIN ods_actv.ods_actv_cms_active_d ca on a2.campaign_id = ca.uid
			LEFT JOIN ods_cubu.ods_cubu_tm_clue_source_d tcs ON tcs.ID::String = ca.active_channel::String
			left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id
			where 1=1
			and tpf.is_deleted =0
			and tcs.CLUE_NAME='总部CRM'
			and tcs.ID is not null 
			and ca.active_channel is not null
			and a.create_time<'2024-10-29'
			and toDateTime(left(tpf.arrive_date,19)) <=toDateTime(left(a.create_time,19)) + interval '30 day'--30天内到店
			)x
		where x.rk=1
		)x2 on x1.mobile=x2.mobile
	where 1=1
	and x1.`线索下发时间`<ifnull(x2.`到店时间`,'2025-01-01 00:00:00')
--	and toDate(x1.`线索下发时间`)>toDate(x2.`到店时间`)
--	and toDateTime(left(x1.`线索下发时间`,19))>toDateTime(left(x2.`到店时间`,19))  and toDate(x1.`线索下发时间`)=toDate(x2.`到店时间`)
)x1
join  
(--订单量
    select 
      distinct a.mobile mobile
    from ods_cust.ods_cust_tt_clue_clean_cur a 
    left join ods_cust.ods_cust_tt_pontential_customer_d tpc on a.mobile = tpc.mobile 
    left join ods_cubu.ods_cubu_tt_customer_business_cur tcb on tpc.id = tcb.potential_customers_id 
    left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on tcb.customer_business_id = tpf.customer_business_id 
    left join ods_cydr.ods_cydr_tt_sales_orders_cur tso on tcb.customer_business_id = tso.customer_business_id 
    where 1=1
    and tso.is_deleted = 0 
    and tso.created_at < '2024-10-29'
    and tso.so_status in (14041002,14041003,14041008,14041001)
    and a.create_time <= tpf.arrive_date 
    and a.create_time <= tso.created_at 
    and tpf.is_deleted = 0 
    and toDateTime(left(tso.created_at,19)) <=toDateTime(left(a.create_time,19)) + interval '60 day'  -- 只看线索，60天内
    )x2 on x2.mobile=x1.mobile   