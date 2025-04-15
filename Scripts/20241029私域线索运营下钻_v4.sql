	--私域：
--累计注册量
	select count(distinct m.id)
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
--	and m.create_time >='2024-01-01'
	and m.create_time <'2025-01-01'
--	and length(m.member_phone)>10

--私域留资量
-- 线索（一键留资） liteCRM
	select count(distinct tlcp.id)
	from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp 
	where 1=1
	and tlcp.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
		)
	and tlcp.create_time >= '2024-01-01'
	and tlcp.create_time < '2025-01-01'

--私域线索量 APP和小程序预约试驾+一键留资数量clue
select 
count(distinct x.id)
from 
	(
	select 
	ta.CUSTOMER_PHONE mobile,
	ta.APPOINTMENT_ID::String id
	from ods_cyap.ods_cyap_tt_appointment_d ta
--	join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=CUSTOMER_BUSINESS_ID
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') 
	and ta.DATA_SOURCE='C' -- 预约试乘试驾
	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2025-01-01'
	union all
	select tcc.mobile mobile,
	tcc.id::String id
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2025-01-01'
	and tcc.campaign_code in 		
	(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
		)
)x

--到店量
	select
	count(distinct x.id)
--	count(distinct x.mobile),
--	count(distinct x.business_id)
from 
	(
	select 
	distinct 
	ta.CUSTOMER_PHONE mobile,
	ta.CUSTOMER_BUSINESS_ID business_id,
	ta.APPOINTMENT_ID::String id,
	toDateTime(left(ta.CREATED_AT::String ,19)) create_time
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2025-01-01'
	union all
	select tcc.mobile mobile,
	tcc.business_id,
	tcc.id::String id,
	toDateTime(left(tcc.create_time::String ,19)) create_time
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.is_deleted=0
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2025-01-01'
	and tcc.campaign_code in (
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
		)
)x
join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
where 1=1
and abs(toDate(left(CAST(create_time AS String),19))- toDate(left(CAST(tp.arrive_date AS String), 19))) <=30
--and tp.arrive_date is not null 

--订单量
select
count(distinct tso.so_no_id)
--count(distinct x.id)
from 
	(
	select 
	ta.CUSTOMER_PHONE mobile,
	ta.CUSTOMER_BUSINESS_ID business_id,
	ta.APPOINTMENT_ID::String id,
	toDateTime(ta.CREATED_AT ) create_time
	from ods_cyap.ods_cyap_tt_appointment_d ta
--	join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=CUSTOMER_BUSINESS_ID
	where 1=1
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2025-01-01'
	union all
	select tcc.mobile mobile,
	tcc.business_id,
	tcc.id::String id,
	toDateTime(tcc.create_time) 
	from ods_cust.ods_cust_tt_clue_clean_cur tcc
	where 1=1
	and tcc.is_deleted=0
	and tcc.create_time>= '2024-01-01'
	and tcc.create_time< '2025-01-01'
	and tcc.campaign_code in (
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
		)
)x
left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tp on x.business_id = tp.customer_business_id and tp.is_deleted = 0 
join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
where 1=1
and tso.so_status in (14041002,14041003,14041008,14041001)
and tso.is_deleted = 0 
--and abs(toDate(left(CAST(create_time AS String),19))- toDate(left(CAST(tp.arrive_date AS String), 19))) <=30 -- 30天内到店
and abs(toDate(tso.created_at)-toDate(x.create_time))<=180--60天内订单

	
--	公域：
-- 留资
	select count(distinct a.id) 
	from ods_vced.ods_vced_tm_leads_collection_pool_cur a
	where 1=1
	and a.`create_time` >='2024-01-01'
	and a.`create_time` < '2025-01-01'

-- 订单
	select 
	count(distinct a.so_no_id)
	FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
	left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on a.so_no_id =c.SO_NO_ID 
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on c.SALES_OEDER_DETAIL_ID::String =b.sales_oeder_detail_id::String 
	where 1=1
	and a.so_status in (14041001,14041002,14041003,14041008) -- 有效订单
	and a.created_at  < '2025-01-01'
	and a.created_at  >='2024-01-01'
	and a.is_deleted = 0
	and b.is_deleted = 0
	and c.IS_DELETED = 0    
	
----------------------------------------------------------------------------------------------------------------------------------------
--1、第一步case when 清洗时间abs 小于等于30 保留时间，大于30清洗为空
--2、第二步，这部分数据和到店为空数据union all
--3、在这个基础上处理
--如果一个线索既有大于30的也有小于30的，  最终大于30的和空的一起置为2025-01-01，商机id，线索id（线索id union 预约id）,到店时间(时间差—），
--rouw_number(pritition by 线索id order by 到店时间)取 1

	--	abs<30 or daodian.id is null
-- 
--1.线索关联到店（30天内）
--2.计算每一个组合的到店-线索的时间差，匹不到到店填充2025-01-01
--3.min 2的结果
--4.得到线索和到店一对一的数据
--5.分类：2的差<0，下发已到店，比较date，分类是否用一天
--        ，>0下发未到店

-- 私域留资量
	select 
	case when abs(toDate(x.allot_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.allot_time-x.arrive_date <0 
				and abs(toDate(x.allot_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.allot_time)-toDate(x.arrive_date))<=30 
			and x.allot_time-x.arrive_date >0
			and toDate(x.allot_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.allot_time)-toDate(x.arrive_date))<=30 
			and x.allot_time-x.arrive_date >0
			and toDate(x.allot_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
	count(distinct x.id)
	from 
		(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.id id,
		toDateTime(a.create_time) create_time,-- `线索时间`,
		toDateTime(left(CAST(a2.allot_time AS String),19))allot_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(left(CAST( 
						case when abs(toDate(a2.allot_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(a2.allot_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by a.id order by 
				case when abs(toDate(a2.allot_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(a2.allot_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2025-01-01'
		and a2.allot_time is not null 
--		and tpf.arrive_date is not null 
		and a.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
		)
	)x
	where x.rk=1
	group by 1 
	order by 1 
	
	
-- 私域线索量 到店量
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >=0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
	count(distinct x.id)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by x.id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
	where abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 -- 到店量
	)x
where rk=1
group by 1 
order by 1 

-- 私域线索量 到店量 平均时长
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
--	count(distinct x.id)
--			x.create_time,
--			x.arrive_date,
	sum(timestampDiff('hour', x.create_time, x.arrive_date))/count(distinct x.id) AS hour_diff
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by x.id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
	where abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 -- 到店量
	)x
where rk=1
group by 1 
order by 1 


--订单量
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >=0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
	count(distinct x.so_no_id)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		tso.so_no_id so_no_id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		tso.created_at created_at, --订单时间
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-02-01')))>30 then '2025-02-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by tso.so_no_id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-02-01')))>30 then '2025-02-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
		join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
		where 1=1
		and tso.so_status in (14041002,14041003,14041008,14041001)
		and tso.is_deleted = 0 
--		and arrive_date is not null 
	)x
where rk=1
--	and abs(toDate(left(CAST(x.create_time AS String),19))- toDate(left(CAST(x.arrive_date AS String), 19))) <=30 -- 30天内到店
	and abs(toDate(x.created_at)-toDate(x.create_time))<=180--180天内订单
	and x.arrive_date is not null 
group by 1 
order by 1 


--订单量  平均时长
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
--	count(distinct x.so_no_id)
--	x.arrive_date,
--	x.created_at,
--	timestampDiff('hour', x.arrive_date, x.created_at)
	sum(timestampDiff('hour', x.arrive_date, x.created_at))/count(distinct x.so_no_id) AS hour_diff
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		tso.so_no_id so_no_id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(tso.created_at) created_at, --订单时间
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by tso.so_no_id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
		join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
		where 1=1
		and tso.so_status in (14041002,14041003,14041008,14041001)
		and tso.is_deleted = 0 
	)x
where rk=1
	and abs(toDate(left(CAST(x.create_time AS String),19))- toDate(left(CAST(x.arrive_date AS String), 19))) <=30 -- 30天内到店
	and abs(toDate(x.created_at)-toDate(x.create_time))<=60--60天内订单
group by 1 
order by 1  


--首触逻辑
--1.拿到上面线索和到店一对一的关系
--2.拿到干净的线索表（剔除C端预约试驾）
--3.每条线索的手机号找该线索创建之前历史上是否有其他线索，没有则该线索为首触
--4.继续后续计算

-- 私域留资量 首触 （以用户手机号为单位）
select 
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
	count(distinct x.customer_mobile)
from 
	(
	select x.*
	from 
	(
		select 
		distinct 
		a.customer_mobile customer_mobile,
		a.id id,
		toDateTime(a.create_time) create_time,-- `线索时间`,
		toDateTime(left(CAST(a2.allot_time AS String),19))allot_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(left(CAST( 
						case when abs(toDate(a2.allot_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(a2.allot_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by a.id order by 
				case when abs(toDate(a2.allot_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(a2.allot_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		left join ods_cust.ods_cust_tt_clue_clean_cur a2 on a2.media_id = a.id 
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on a2.business_id = tpf.customer_business_id and tpf.is_deleted =0
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.create_time < '2025-01-01'
		and a2.allot_time is not null 
--		and tpf.arrive_date is not null 
		and a.campaign_code in
		(
			select distinct trim(hd.code) code
			from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
			where trim(hd.channel) = '一键留资'
			and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01')
			)x
	where x.rk=1
	)x
JOIN 
		(
		-- 历史用户首触线索明细
		select 
		distinct x.customer_mobile mobile,
		x.id
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
--			and a.create_time >= '2024-01-01'
			and a.create_time < '2025-01-01'
			)x
		where 1=1
		and x.rk=1
	)x2 on x2.id=x.id
group by 1 
order by 1
	
-- 私域 线索量 到店量 首触 平均时长
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
--	count(distinct x.mobile) -- 到店量
	sum(timestampDiff('hour', x.create_time, x.arrive_date))/count(distinct x.mobile) AS hour_diff -- 平均时长
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by x.id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
	where abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 --求到店量 需要注释掉
	)x
JOIN 
		(
		select x.mobile mobile,
		x.id,
		x.create_time
		from 
		(
		-- 历史用户首触线索明细
		select 
		x.mobile mobile,
		ROW_NUMBER ()over(partition by x.mobile order by x.create_time) rk,
		x.create_time,
		x.id
		from 
				(		
				select tcc.mobile mobile,
				tcc.business_id,
				tcc.id::String id,
	--			ROW_NUMBER ()over(partition by tcc.mobile order by tcc.create_time) rk,
				toDateTime(left(tcc.create_time::String ,19)) create_time
				from ods_cust.ods_cust_tt_clue_clean_cur tcc
				where 1=1
				and tcc.is_deleted=0
	--			and tcc.create_time>= '2024-01-01'
				and tcc.create_time< '2025-01-01'
					and concat(tcc.create_time,tcc.mobile) not in(
					    select concat(b.create_time ,b.mobile)
					    from ods_cust.ods_cust_tt_clue_clean_cur b
					    left join ods_cyap.ods_cyap_tt_appointment_d ta on ta.CUSTOMER_PHONE =b.mobile and ta.IS_DELETED =0
					    where 1=1
					    and abs(toDateTime(ta.CREATED_AT)-toDateTime(left(b.create_time,19)))<5
					    and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
					    and b.is_deleted =0 
					    and ta.CREATED_AT < '2025-01-01'
					    )
			union all 
				select 
				distinct 
				ta.CUSTOMER_PHONE mobile,
				ta.CUSTOMER_BUSINESS_ID business_id,
				ta.APPOINTMENT_ID::String id,
				toDateTime(left(ta.CREATED_AT::String ,19)) create_time
				from ods_cyap.ods_cyap_tt_appointment_d ta
--				join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
				where 1=1
				and ta.IS_DELETED = 0
				and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
	--			and ta.CREATED_AT >= '2024-01-01'
				and ta.CREATED_AT < '2025-01-01'
				)x
			)x
			where x.rk=1
	)x2 on x2.id=x.id and x2.create_time=x.create_time
where rk=1
group by 1 
order by 1 


--订单量
select  
	case when abs(toDate(x.create_time)-toDate(x.arrive_date))>30  -- （超过30天、未到店）
			or (x.create_time-x.arrive_date <0 
				and abs(toDate(x.create_time)-toDate(x.arrive_date))<=30) then '下发前未到店' -- 下发后30天内到店
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when abs(toDate(x.create_time)-toDate(x.arrive_date))<=30 
			and x.create_time-x.arrive_date >0
			and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
--	count(distinct x.so_no_id)
			sum(timestampDiff('hour', x.arrive_date, x.created_at))/count(distinct x.so_no_id) AS hour_diff
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.mobile mobile,
		x.id id,
		tso.so_no_id so_no_id,
		x.create_time create_time,-- `线索下发时间`,
--		tpf.arrive_date `到店时间`,
		toDateTime(tso.created_at) created_at, --订单时间
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by tso.so_no_id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
		(	
		select 
		distinct 
		ta.CUSTOMER_PHONE mobile,
		ta.CUSTOMER_BUSINESS_ID business_id,
		ta.APPOINTMENT_ID::String id,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
--		join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
		where 1=1
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		union all
		select tcc.mobile mobile,
		tcc.business_id,
		tcc.id::String id,
		toDateTime(left(tcc.create_time::String ,19)) create_time
		from ods_cust.ods_cust_tt_clue_clean_cur tcc
		where 1=1
		and tcc.is_deleted=0
		and tcc.create_time>= '2024-01-01'
		and tcc.create_time< '2025-01-01'
		and tcc.campaign_code in (
				select distinct trim(hd.code) code
				from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
				where trim(hd.channel) = '一键留资'
				and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
			)			
		)x
		left join ods_cypf.ods_cypf_tt_passenger_flow_info_cur tpf on x.business_id = tpf.customer_business_id and tpf.is_deleted = 0 
		join ods_cydr.ods_cydr_tt_sales_orders_cur tso on x.business_id = tso.customer_business_id 
		where 1=1
		and tso.so_status in (14041002,14041003,14041008,14041001)
		and tso.is_deleted = 0 
--		where 1=1
	)x
join		(
		select x.mobile mobile,
		x.id,
		x.create_time
		from 
		(
		-- 历史用户首触线索明细
		select 
		x.mobile mobile,
		ROW_NUMBER ()over(partition by x.mobile order by x.create_time) rk,
		x.create_time,
		x.id
		from 
				(		
				select tcc.mobile mobile,
				tcc.business_id,
				tcc.id::String id,
	--			ROW_NUMBER ()over(partition by tcc.mobile order by tcc.create_time) rk,
				toDateTime(left(tcc.create_time::String ,19)) create_time
				from ods_cust.ods_cust_tt_clue_clean_cur tcc
				where 1=1
				and tcc.is_deleted=0
	--			and tcc.create_time>= '2024-01-01'
				and tcc.create_time< '2025-01-01'
					and concat(tcc.create_time,tcc.mobile) not in(
					    select concat(b.create_time ,b.mobile)
					    from ods_cust.ods_cust_tt_clue_clean_cur b
					    left join ods_cyap.ods_cyap_tt_appointment_d ta on ta.CUSTOMER_PHONE =b.mobile and ta.IS_DELETED =0
					    where 1=1
					    and abs(toDateTime(ta.CREATED_AT)-toDateTime(left(b.create_time,19)))<5
					    and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
					    and b.is_deleted =0 
					    and ta.CREATED_AT < '2025-01-01'
					    )
			union all 
				select 
				distinct 
				ta.CUSTOMER_PHONE mobile,
				ta.CUSTOMER_BUSINESS_ID business_id,
				ta.APPOINTMENT_ID::String id,
				toDateTime(left(ta.CREATED_AT::String ,19)) create_time
				from ods_cyap.ods_cyap_tt_appointment_d ta
--				join ods_cust.ods_cust_tt_clue_clean_cur tcc on tcc.business_id=ta.CUSTOMER_BUSINESS_ID
				where 1=1
				and ta.IS_DELETED = 0
				and ta.APPOINTMENT_TYPE in ('70691002','70691001') and ta.DATA_SOURCE='C' -- 预约试乘试驾
	--			and ta.CREATED_AT >= '2024-01-01'
				and ta.CREATED_AT < '2025-01-01'
				)x
			)x
			where x.rk=1
	)x2 on x2.id=x.id and x2.create_time=x.create_time
where rk=1
	and abs(toDate(left(CAST(x.create_time AS String),19))- toDate(left(CAST(x.arrive_date AS String), 19))) <=30 -- 30天内到店
	and abs(toDate(x.created_at)-toDate(x.create_time))<=60--60天内订单
group by 1 
order by 1 