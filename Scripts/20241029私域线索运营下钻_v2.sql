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
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') 
	and ta.DATA_SOURCE='C' -- 预约试乘试驾
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
	count(distinct x.business_id)
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
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
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
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
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
	
----------------------------------------------------------------------------------------------------------------------------------------
--	abs<30 or daodian.id is null
-- 
--1.线索关联到店（30天内）
--2.计算每一个组合的到店-线索的时间差，匹不到到店填充2025-01-01
--3.min 2的结果
--4.得到线索和到店一对一的数据
--5.分类：2的差<0，下发已到店，比较date，分类是否用一天
--        ，>0下发未到店

-- 私域线索下发前未到店： 私域留资量
	select 
--	count(distinct concat(x.customer_mobile,x.`到店时间`))
	count(distinct x.id)
	from 
		(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.id id,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		tpf.arrive_date `到店时间`
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2024-10-29'
		and abs(toDate(a2.allot_time)-toDate(tpf.arrive_date))<=30--绝对值30天内到店
		and a.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
	)x
	where 1=1
--	and x.rk=1
	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
--	and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)

	-- 私域线索下发前未到店： 私域留资量 考虑到店时间为空
	select 
--	count(distinct concat(x.customer_mobile,x.`线索下发时间`))
	count(distinct x.id)
	from 
		(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.id id,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		tpf.arrive_date `到店时间`
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2024-10-29'
		and a2.allot_time is not null 
		and tpf.arrive_date is null -- 无到店时间
--		and abs(toDate(a2.allot_time)-toDate(ifnull(tpf.arrive_date,'2025-01-01 00:00:00')))<=30--30天内到店
		and a.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
	)x
	where 1=1
	
-- 私域线索下发前未到店： 私域线索量
select 
--x.mobile,
--x.business_id,
--x.create_time `线索下发时间`,
--x.arrive_date `到店时间`
--count(distinct concat(x.mobile,x.arrive_date))
count(distinct x.business_id)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
	x.mobile,
	x.business_id,
	x.create_time create_time,
	tp.arrive_date arrive_date,
	toDate(COALESCE(tp.arrive_date, '1970-01-01')) t,
	abs(toDate(COALESCE(tp.arrive_date, '1970-01-01'))-toDate(left(x.create_time::String,19))) s
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
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
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
	)x
	left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
	where 1=1
	and x.create_time >='2024-01-01'
	and x.create_time <'2024-10-29'
	and tp.arrive_date >='2024-01-01'
	and tp.arrive_date <'2024-10-29'
	and abs(toDate(COALESCE(tp.arrive_date, '1970-01-01'))-toDate(left(x.create_time::String,19)))<=30--30天内到店
--	and abs(toDate(tp.arrive_date)-toDate(left(x.create_time::String ,19)))<=30--30天内到店
)x
where 1=1
and x.arrive_date is not null 
and x.create_time is not null 
--and toDateTime(left(CAST(x.create_time AS String),19))<toDateTime(left(CAST(x.arrive_date AS String), 19))  -- 私域线索下发前未到店：
--and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String), 19)) and toDate(x.create_time)<>toDate(x.arrive_date) -- 私域线索下发已到店（非当天）：
and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String), 19)) and toDate(x.create_time)=toDate(x.arrive_date) -- 私域线索下发已到店（当天）：

-- 私域线索下发前未到店： 私域线索量  到店空值
select 
--x.mobile,
--x.business_id,
--x.create_time `线索下发时间`,
--x.arrive_date `到店时间`
--count(distinct x.mobile)
count(distinct x.business_id)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
	x.mobile,
	x.business_id,
	x.create_time create_time,
	tp.arrive_date arrive_date,
	toDate(COALESCE(tp.arrive_date, '1970-01-01')) t,
	abs(toDate(COALESCE(tp.arrive_date, '1970-01-01'))-toDate(left(x.create_time::String,19))) s
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
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
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
	)x
	left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
	where 1=1
	and x.create_time >='2024-01-01'
	and x.create_time <'2024-10-29'
--	and tp.arrive_date >='2024-01-01'
--	and tp.arrive_date <'2024-10-29'
--	and abs(toDate(COALESCE(tp.arrive_date, '1970-01-01'))-toDate(left(x.create_time::String,19)))<=30--30天内到店
--	and toDateTime(left(tp.arrive_date::String,19)) <=toDateTime(left(x.create_time::String ,19)) + interval '30 day'
--	and abs(toDate(tp.arrive_date)-toDate(left(x.create_time::String ,19)))<=30--30天内到店
)x
where 1=1
--and abs(toDate(x.arrive_date)-toDate(left(x.create_time::String ,19)))<=30--30天内到店
--and toDateTime(left(x.arrive_date::String,19)) <=toDateTime(left(x.create_time::String ,19)) + interval '30 day'
and x.arrive_date is null 
--and x.create_time is not null 
--and toDateTime(left(CAST(x.create_time AS String),19))<toDateTime(left(CAST(x.arrive_date AS String), 19))  -- 私域线索下发前未到店：
--and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String), 19)) and toDate(x.create_time)<>toDate(x.arrive_date) -- 私域线索下发已到店（非当天）：
--and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String), 19)) and toDate(x.create_time)=toDate(x.arrive_date) -- 私域线索下发已到店（当天）：


-- 私域线索下发前未到店：  订单量 私域线索量
-- 私域线索下发前未到店： 私域线索量
select 
--x.mobile,
--x.business_id,
--x.create_time `线索下发时间`,
--x.arrive_date `到店时间`
count(distinct x.mobile)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
	x.mobile mobile,
	x.business_id business_id,
	x.create_time create_time,
--	toDateTime(left(CAST(tp.arrive_date AS String), 19))arrive_date
	tp.arrive_date arrive_date
--	COALESCE(tp.arrive_date, '1970-01-01') arrive_date
--	toDate(COALESCE(tp.arrive_date, '1970-01-01')) arrive_date
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
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2024-10-29'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
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
	left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
	join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
	where 1=1
	and x.create_time >='2024-01-01'
	and x.create_time <'2024-10-29'
	and tp.arrive_date >='2024-01-01'
	and tp.arrive_date <'2024-10-29'
	and abs(toDate(COALESCE(tp.arrive_date, '1970-01-01'))-toDate(left(x.create_time::String,19)))<=30--30天内到店
		and x.create_time is not null 
		and tso.so_status in (14041002,14041003,14041008,14041001)
		and tso.is_deleted = 0 
		and tso.created_at >='2024-01-01'
		and tso.created_at <'2024-10-29'
		and toDateTime(left(CAST(create_time AS String),19)) < toDateTime(left(CAST(tso.created_at AS String), 19))
		and abs(toDate(tso.created_at)-toDate(x.create_time))<=60--60天内
)x
where 1=1
and toDateTime(left(CAST(x.create_time AS String),19))<toDateTime(left(CAST(x.arrive_date AS String), 19))  -- 私域线索下发前未到店：
--and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String),19)) and toDate(x.create_time)<>toDate(x.arrive_date) -- 私域线索下发已到店（非当天）：
--and toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(x.arrive_date AS String), 19)) and toDate(x.create_time)=toDate(x.arrive_date) -- 私域线索下发已到店（当天）：



------------------------首触
-- 私域线索下发前未到店： 私域留资量
	select 
--	count(distinct concat(x.customer_mobile,x.`到店时间`))
	count(distinct x.id)
	from 
		(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.id id,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		tpf.arrive_date `到店时间`,
		a.campaign_code campaign_code,
		ROW_NUMBER() over(partition by a.customer_mobile order by a.create_time) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2024-10-29'
		and abs(toDate(COALESCE(tpf.arrive_date, '1970-01-01'))-toDate(left(a.create_time::String,19)))<=30--30天内到店
	)x
	where 1=1
	and x.rk=1
	and x.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
	and toDateTime(left(x.`线索下发时间`,19))<toDateTime(left(x.`到店时间`,19)) 
--	and toDate(x.`线索下发时间`)>toDate(x.`到店时间`)
--	and toDateTime(left(x.`线索下发时间`,19))>toDateTime(left(x.`到店时间`,19))  and toDate(x.`线索下发时间`)=toDate(x.`到店时间`)

	-- 私域线索下发前未到店： 私域留资量 到店为空
	select count(distinct x.customer_mobile)
	from 
		(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.create_time `线索时间`,
		a2.allot_time `线索下发时间`,
		tpf.arrive_date `到店时间`,
		a.campaign_code campaign_code,
		ROW_NUMBER() over(partition by a.customer_mobile order by a.create_time) rk
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2024-10-29'
		and a2.allot_time is not null 
		and tpf.arrive_date is null 
--		and abs(toDate(COALESCE(tpf.arrive_date, '1970-01-01'))-toDate(left(a.create_time::String,19)))<=30--30天内到店
	)x
	where 1=1
	and x.rk=1
	and x.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
		)
--	and x.`到店时间` is null 


	

	
--   到店量
select 	
--	x.mobile,
--	x.business_id,
--	x.create_time create_time,
--	tp.arrive_date arrive_date,
count(distinct case when tp.arrive_date is null then mobile else null end) `私域线索量`
--count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))<toDateTime(left(CAST(tp.arrive_date AS String), 19)) then x.mobile else null end)
--count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(tp.arrive_date AS String), 19))and toDate(x.create_time)<>toDate(tp.arrive_date) then x.mobile else null end)
--count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(tp.arrive_date AS String), 19))and toDate(x.create_time)=toDate(tp.arrive_date) then x.mobile else null end)
from 
	(select x.*
from 
	(
		select x.mobile,
		x.business_id,
		x.`01`,
		ROW_NUMBER ()over(partition by x.mobile order by x.create_time) rk,
		x.create_time create_time -- mini time
		from 
			(
			select 
			distinct b.mobile `mobile`,
			b.business_id,
			toDateTime(left(b.create_time::String ,19)) create_time,
			'clue' as `01`
			from ods_cust.ods_cust_tt_clue_clean_cur b
			where 1=1
			and b.is_deleted =0 
			and concat(b.create_time,b.mobile) not in(
			    select concat(b.create_time ,b.mobile)
			    from ods_cust.ods_cust_tt_clue_clean_cur b
			    left join ods_cyap.ods_cyap_tt_appointment_d ta on ta.CUSTOMER_PHONE=b.mobile and ta.IS_DELETED =0
			    where 1=1
			    and abs(toDateTime(ta.CREATED_AT)-toDateTime(left(b.create_time,19)))<5
			    and b.is_deleted =0 
			)
			and b.campaign_code not in (
					select distinct trim(hd.code) code
					from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
					where trim(hd.channel) = '一键留资'
					and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
				)
			and b.create_time>= '2024-01-01'
			and b.create_time< '2024-10-29'
			union all 
			select 
			distinct 
			ta.CUSTOMER_PHONE mobile,
			ta.CUSTOMER_BUSINESS_ID business_id,
			toDateTime(left(ta.CREATED_AT::String ,19)) create_time,
			'预约试驾' as `02`
			from ods_cyap.ods_cyap_tt_appointment_d ta
			where 1=1
			and ta.IS_DELETED = 0
			and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
			and ta.CREATED_AT >= '2024-01-01'
			and ta.CREATED_AT < '2024-10-29'
			union all
			select tcc.mobile mobile,
			tcc.business_id,
			toDateTime(left(tcc.create_time::String ,19)) create_time,
			'一键留资' as `03`
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
	)x where x.rk=1
		and x.`01` in ('预约试驾','一键留资')
)x
left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
--where tp.arrive_date>= '2024-01-01' and tp.arrive_date < '2024-10-29'






--   订单量
--   订单量
select 	
--	x.mobile,
--	x.business_id,
--	x.create_time create_time,
--	tp.arrive_date arrive_date,
--count(distinct case when tp.arrive_date is null then mobile else null end) `私域线索量`
--count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))<toDateTime(left(CAST(tp.arrive_date AS String), 19)) then x.mobile else null end)
--count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(tp.arrive_date AS String), 19))and toDate(x.create_time)<>toDate(tp.arrive_date) then x.mobile else null end)
count(distinct case when toDateTime(left(CAST(x.create_time AS String),19))>toDateTime(left(CAST(tp.arrive_date AS String), 19))and toDate(x.create_time)=toDate(tp.arrive_date) then x.mobile else null end)
from 
(select x.*
from 
	(
		select x.mobile,
		x.business_id,
		x.`01`,
		ROW_NUMBER ()over(partition by x.mobile order by x.create_time) rk,
		x.create_time create_time -- mini time
		from 
			(
			select 
			distinct b.mobile `mobile`,
			b.business_id,
			toDateTime(left(b.create_time::String ,19)) create_time,
			'clue' as `01`
			from ods_cust.ods_cust_tt_clue_clean_cur b
			where 1=1
			and b.is_deleted =0 
			and concat(b.create_time,b.mobile) not in(
			    select concat(b.create_time ,b.mobile)
			    from ods_cust.ods_cust_tt_clue_clean_cur b
			    left join ods_cyap.ods_cyap_tt_appointment_d ta on ta.CUSTOMER_PHONE=b.mobile and ta.IS_DELETED =0
			    where 1=1
			    and abs(toDateTime(ta.CREATED_AT)-toDateTime(left(b.create_time,19)))<5
			    and b.is_deleted =0 
			)
			and b.campaign_code not in (
					select distinct trim(hd.code) code
					from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
					where trim(hd.channel) = '一键留资'
					and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2024-10-29'
				)
			and b.create_time>= '2024-01-01'
			and b.create_time< '2024-10-29'
			union all 
			select 
			distinct 
			ta.CUSTOMER_PHONE mobile,
			ta.CUSTOMER_BUSINESS_ID business_id,
			toDateTime(left(ta.CREATED_AT::String ,19)) create_time,
			'预约试驾' as `02`
			from ods_cyap.ods_cyap_tt_appointment_d ta
			where 1=1
			and ta.IS_DELETED = 0
			and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
			and ta.CREATED_AT >= '2024-01-01'
			and ta.CREATED_AT < '2024-10-29'
			union all
			select tcc.mobile mobile,
			tcc.business_id,
			toDateTime(left(tcc.create_time::String ,19)) create_time,
			'一键留资' as `03`
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
	)x where x.rk=1
		and x.`01` in ('预约试驾','一键留资')
)x
left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
where tp.arrive_date>= '2024-01-01' and tp.arrive_date < '2024-10-29'
		and x.create_time is not null 
		and tso.so_status in (14041002,14041003,14041008,14041001)
		and tso.is_deleted = 0 
		and tso.created_at >='2024-01-01'
		and tso.created_at <'2024-10-29'
		and toDateTime(left(CAST(create_time AS String),19)) < toDateTime(left(CAST(tso.created_at AS String), 19))
		and abs(toDate(tso.created_at)-toDate(x.create_time))<=60--60天内