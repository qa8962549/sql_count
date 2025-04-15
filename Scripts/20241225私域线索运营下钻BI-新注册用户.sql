--2024年新用户注册量
	select count(distinct m.id)
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >='2024-01-01'
	and m.create_time <'2025-01-01'

----2024年新用户注册量 私域线索量 APP和小程序预约试驾+一键留资数量clue
select 
count(distinct business_id)
from 
	(
--	clue线索表每条商机的最早一条找出来 作为大前提
	-- 预约试驾表和clue线索同一个手机号，时间差在5S以内
	select 
	tcc.business_id,
	tcc.mobile
	from ods_cyap.ods_cyap_tt_appointment_d ta
	join 
		(
--		取线索商机ID最早的一条
		select tcc.business_id,
		create_time,
		mobile,
		ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
		from ods_cust.ods_cust_tt_clue_clean_cur tcc 
		where is_deleted =0
		)tcc on tcc.mobile=ta.CUSTOMER_PHONE and tcc.rk=1
	where 1=1
	and tcc.create_time>='2024-01-01'
	and tcc.create_time<'2025-01-01'
	and ta.IS_DELETED = 0
	and ta.APPOINTMENT_TYPE in ('70691002','70691001') 
	and ta.DATA_SOURCE='C' -- 预约试乘试驾
	and ta.CREATED_AT >= '2024-01-01'
	and ta.CREATED_AT < '2025-01-01'
	and abs(dateDiff('second',toDateTime(left(tcc.create_time::String ,19)),toDateTime(ta.CREATED_AT)))<= 5 -- 线索时间和到店时间时间差5 S内
	union all
	--	一键留资
		select 
		x.business_id,
		x.mobile
		from 
			(
			select 
			tcc.business_id,
			create_time,
			campaign_code,
			mobile,
			ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
			from ods_cust.ods_cust_tt_clue_clean_cur tcc
			where 1=1
		)x where x.rk=1
		and x.create_time>= '2024-01-01'
		and x.create_time< '2025-01-01'
		and x.campaign_code in 		
			(
					select distinct trim(hd.code) code
					from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
					where trim(hd.channel) = '一键留资'
					and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
				)
	)x
join (--2024年新用户注册量
	select m.member_phone
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >='2024-01-01'
	and m.create_time <'2025-01-01'
--	and length(m.member_phone)>10
	)x1 on x1.member_phone=x.mobile
join (
	-- BI线索
	select 
	a.biz_opp_id 
	from ods_oper_crm.ads_sales_leads_detail_detail_d a
	where pmonth <'202501'
	and pmonth >='202401'
	and dealer_code not in ('VVD','VVB')
	)x2 on x.business_id=x2.biz_opp_id
--join (-- BI到店
--	SELECT a.biz_opp_id 
--	FROM ads_bi.ads_sales_arrival_detail_detail_d a
--	WHERE pmonth <'202501'
--	and pmonth >='202401'
--	and is_first_arrival='100100001')x3 on x2.biz_opp_id=x3.biz_opp_id
join (-- 订单
	select biz_opp_id
	from ads_bi.ads_sales_order_detail_detail_d t1
	where t1.pmonth <'202501' 
	and t1.pmonth >='202401'
	and ((t1.dealer_code<>'VVD' and t1.order_status<>'14041009') or (t1.dealer_code='VVD' and t1.is_direct_sales_order='100100001'))
	)x4 on x2.biz_opp_id::String=x4.biz_opp_id


	
--2024年新用户注册量	公域：
	-- BI线索
	select 
	count(a.biz_opp_id)
	from ods_oper_crm.ads_sales_leads_detail_detail_d a
	left join 
		(
		select x.business_id,
		mobile
		from 
			(
	--		取线索商机ID最早的一条
			select tcc.business_id,
			create_time,
			mobile,
			ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
			from ods_cust.ods_cust_tt_clue_clean_cur tcc 
			where is_deleted =0
			)x 
		where x.rk=1 
		and x.create_time>= '2024-01-01'
		and x.create_time< '2025-01-01'
		)tcc on tcc.business_id=a.biz_opp_id
	join (--2024注册量
		select m.member_phone
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		and m.create_time >='2024-01-01'
		and m.create_time <'2025-01-01'
--		and length(m.member_phone)>10
		)x1 on x1.member_phone=tcc.mobile
	where pmonth <'202501'
	and pmonth >='202401'
	and dealer_code not in ('VVD','VVB')
		
--2024年新用户注册量 订单
select count(distinct x2.biz_opp_id)
from (
	-- BI线索
	select 
	a.biz_opp_id 
	from ods_oper_crm.ads_sales_leads_detail_detail_d a
	where pmonth <'202501'
	and pmonth >='202401'
	and dealer_code not in ('VVD','VVB')
	)x2 
join (-- 订单
	select biz_opp_id
	from ads_bi.ads_sales_order_detail_detail_d t1
	where t1.pmonth <'202501' 
	and t1.pmonth >='202401'
	and ((t1.dealer_code<>'VVD' and t1.order_status<>'14041009') or (t1.dealer_code='VVD' and t1.is_direct_sales_order='100100001'))
	)x4 on x2.biz_opp_id::String=x4.biz_opp_id
left join 
		(
		select x.business_id,
		mobile
		from 
			(
	--		取线索商机ID最早的一条
			select tcc.business_id,
			create_time,
			mobile,
			ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
			from ods_cust.ods_cust_tt_clue_clean_cur tcc 
			where is_deleted =0
			)x 
		where x.rk=1 
		and x.create_time>= '2024-01-01'
		and x.create_time< '2025-01-01'
		)tcc on tcc.business_id::String=x4.biz_opp_id
join (--2024注册量
		select m.member_phone
		from ods_memb.ods_memb_tc_member_info_cur m 
		where m.member_status <> '60341003' and m.is_deleted =0 
		and m.create_time >='2024-01-01'
		and m.create_time <'2025-01-01'
--		and length(m.member_phone)>10
		)x1 on x1.member_phone=tcc.mobile
	
	
----------------------------------------------------------------------------------------------------------------------------------------

-- 私域线索量 到店量 订单量
select  
	case when x.create_time<x.arrive_date or x.arrive_date is null  then '下发前未到店' -- 下发后到店、未到店
		when x.create_time>x.arrive_date and toDate(x.create_time)<>toDate(x.arrive_date)	then '下发前已到店（非当天）'
		when x.create_time>=x.arrive_date and toDate(x.create_time)=toDate(x.arrive_date)  then '下发前已到店（当天）'
			else null end `下发到店状态`,
	count(distinct x.id)
from 
	(
	-- APP和小程序预约试驾+一键留资数量clue +到店时间
	select 
		x.business_id id,
		x.create_time create_time,-- `线索下发时间`,
		toDateTime(tpf.arrive_date) arrive_date,
		x.mobile,
		toDateTime(left(CAST( 
						case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date 
							when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
							else null end AS String),19)) arrive_date2, -- 大于30天的和空的一起置为2025-01-01
		ROW_NUMBER() over(partition by x.business_id order by 
				case when abs(toDate(x.create_time)-toDate(tpf.arrive_date))<=30 then tpf.arrive_date
				when abs(toDate(x.create_time)-toDate(COALESCE(tpf.arrive_date, '2025-01-01')))>30 then '2025-01-01'
				else null end
			)rk -- 取每个线索对应最早的到店时间
	from 
			(--	clue线索表每条商机的最早一条找出来 作为大前提
		-- 预约试驾表和clue线索同一个手机号，时间差在5S以内
		select 
		tcc.business_id business_id,
		mobile,
		toDateTime(left(ta.CREATED_AT::String ,19)) create_time
		from ods_cyap.ods_cyap_tt_appointment_d ta
		join 
			(
	--		取线索商机ID最早的一条
			select tcc.business_id,
			create_time,
			mobile,
			ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
			from ods_cust.ods_cust_tt_clue_clean_cur tcc 
			where is_deleted =0
			)tcc on tcc.mobile=ta.CUSTOMER_PHONE and tcc.rk=1
		where 1=1
		and tcc.create_time>='2024-01-01'
		and tcc.create_time<'2025-01-01'
		and ta.IS_DELETED = 0
		and ta.APPOINTMENT_TYPE in ('70691002','70691001') 
		and ta.DATA_SOURCE='C' -- 预约试乘试驾
		and ta.CREATED_AT >= '2024-01-01'
		and ta.CREATED_AT < '2025-01-01'
		and abs(dateDiff('second',toDateTime(left(tcc.create_time::String ,19)),toDateTime(ta.CREATED_AT)))<= 5 -- 线索时间和到店时间时间差5 S内
		union all
	--	一键留资
		select 
		x.business_id,
		x.mobile,
		toDateTime(left(x.create_time::String ,19)) create_time
		from 
			(
			select tcc.mobile mobile,
			tcc.business_id,
			create_time,
			campaign_code,
			ROW_NUMBER()over(partition by tcc.business_id order by create_time) rk 
			from ods_cust.ods_cust_tt_clue_clean_cur tcc
			where 1=1
		)x where x.rk=1
		and x.create_time>= '2024-01-01'
		and x.create_time< '2025-01-01'
		and x.campaign_code in 		
			(
					select distinct trim(hd.code) code
					from ods_oper_crm.ods_oper_crm_umt001_em90_his_d hd
					where trim(hd.channel) = '一键留资'
					and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = '2025-01-01'
				)
	)x
	join (--累计注册量
	select m.member_phone
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >='2024-01-01'
	and m.create_time <'2025-01-01'
	and length(m.member_phone)>10
	)x1 on x1.member_phone=x.mobile
	join (
		-- BI线索
		select 
		a.biz_opp_id 
		from ods_oper_crm.ads_sales_leads_detail_detail_d a
		where pmonth <'202501'
		and pmonth >='202401'
		and dealer_code not in ('VVD','VVB')
		)x2 on x.business_id=x2.biz_opp_id
	join -- BI到店
		(SELECT a.biz_opp_id,arrive_date
		FROM ads_bi.ads_sales_arrival_detail_detail_d a
		WHERE pmonth <'202501'
		and pmonth >='202401'
		and is_first_arrival='100100001') tpf on x2.biz_opp_id = tpf.biz_opp_id 
	join (-- 订单
		select biz_opp_id
		from ads_bi.ads_sales_order_detail_detail_d t1
		where t1.pmonth <'202501' 
		and t1.pmonth >='202401'
		and ((t1.dealer_code<>'VVD' and t1.order_status<>'14041009') or (t1.dealer_code='VVD' and t1.is_direct_sales_order='100100001'))
		)x4 on x2.biz_opp_id::String=x4.biz_opp_id
	)x
where rk=1
group by 1 
order by 1 



