

--一键留资所有线索 NEWBIE
select f.model_name 意向车型,
count(1)
from customer.tt_clue_clean a
left join activity.cms_active c on a.campaign_id = c.uid 
left join basic_data.tm_model f on a.model_id = f.id
where c.active_code= 'IBCRMJUNHAPPWZLZ2023VCCN'
and a.allot_clue_source = '90331001' -- 限制线索是直接下发的
and f.model_name is not null 
--and a.create_time <='2024-03-20'
group by 1
order by 2desc 

ods_vced.ods_vced_tm_leads_collection_pool_cur

--预约试驾线索数PG
select date_format(ta.CREATED_AT,'%Y-%m') 年月,
count(1) 预约试驾量
from cyx_appointment.tt_appointment ta
where date(ta.CREATED_AT) BETWEEN '2023-01-01' AND '2023-12-31'
AND ta.APPOINTMENT_TYPE = 70691002
AND ta.DATA_SOURCE = 'C'
and ta.is_deleted =0
group by 1
order by 1

--预约试驾到店数PG
select detail.年月,sum(detail.到店数final) as 到店数
from (
select 
	arrive.年月,arrive.mobile_phone,arrive.到店数,xiansuo.预约试驾量,if(arrive.到店数>xiansuo.预约试驾量,xiansuo.预约试驾量,arrive.到店数) 到店数final
from (
--预约试驾到店数
select date_format(base.liuzi,'%Y-%m') 年月,base.mobile_phone,count(1) 到店数
from (
select tpfi.id ,tpfi.mobile_phone,min(ta.created_at) liuzi
from cyx_appointment.tt_appointment ta
inner join cyx_passenger_flow.tt_passenger_flow_info tpfi 
	on ta.customer_phone = tpfi.mobile_phone and tpfi.created_at <= (ta.CREATED_AT+ INTERVAL '30 day') and tpfi.created_at >=ta.CREATED_AT
where date(ta.created_at) BETWEEN '2023-01-01' AND '2023-12-31'
AND ta.APPOINTMENT_TYPE = 70691002
AND ta.DATA_SOURCE = 'C'
and ta.is_deleted =0
group by 1,2
) base 
group by 1,2
) arrive 
left join (
--预约试驾线索数
select date_format(ta.CREATED_AT,'%Y-%m') 年月,ta.customer_phone,
count(1) 预约试驾量
from cyx_appointment.tt_appointment ta
where date(ta.CREATED_AT) BETWEEN '2023-01-01' AND '2023-12-31'
AND ta.APPOINTMENT_TYPE = 70691002
AND ta.DATA_SOURCE = 'C'
and ta.is_deleted =0
group by 1,2
) xiansuo
on xiansuo.年月=arrive.年月 and xiansuo.customer_phone=arrive.mobile_phone
where 1=1
) detail
group by 1
order by 1

select *
  from ods_vced.ods_vced_tm_leads_collection_pool_cur

  SELECT CURRENT_DATE AS time1, DATE_FORMAT(CURRENT_DATE, 'yyyyMMdd') AS time2;


-- 一键留资线索     hive数据库
		select DATE_FORMAT(create_time,'yyyyMM') year_month
		,count(1) xs_nums
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		where 1=1
		and a.create_time >= '2024-01-26'  
		and a.create_time < '2024-03-27'
		and campaign_code = 'IBCRMJUNHAPPWZLZ2023VCCN'
		group by DATE_FORMAT(create_time,'yyyyMM')
	

-- 一键留资线索到店HIVE
SELECT year_month,sum(dd_final)
from 
(
	SELECT arrive.year_month,
	arrive.mobile_phone,
	arrive.dd_nums,
	xiansuo.xs_nums,
	if(arrive.dd_nums>xiansuo.xs_nums,xiansuo.xs_nums,arrive.dd_nums) as dd_final
	from 
	(-- 一键留资线索到店
	 select DATE_FORMAT(base.liuzi ,'%Y-%m') year_month,base.mobile_phone,count(1) dd_nums
	 from (
		 select pfi.id,pfi.mobile_phone,min(a.create_time) as liuzi
		 from ods_cypf.ods_cypf_tt_passenger_flow_info_cur pfi  
		 inner join ods_vced.ods_vced_tm_leads_collection_pool_cur a  
		 on a.customer_mobile = pfi.mobile_phone and pfi.created_at <= date_add(a.create_time,30) and pfi.created_at >=a.create_time  
		 join 
		 (-- 一键留资线索     hive数据库
			 select distinct a.customer_mobile   
			 from ods_vced.ods_vced_tm_leads_collection_pool_cur a  
			 join ods_vced.ods_vced_tm_push_media_record_cur  b on a.`id`=b.`leads_id`  
			 where a.campaign_code = 'IBCRMJUNHAPPWZLZ2023VCCN'
			 and a.create_time >= '2024-03-26'  and a.create_time < '2024-03-27'
		 )zz on zz.customer_mobile = pfi.mobile_phone 
		 where pfi.created_at >= '2024-03-26' and pfi.created_at < '2024-03-27'
		 and a.campaign_code = 'IBCRMJUNHAPPWZLZ2023VCCN'
		 group by pfi.id,pfi.mobile_phone
		) base
		group by DATE_FORMAT(base.liuzi ,'%Y-%m'),base.mobile_phone
	) arrive 
	left join 
	(-- 一键留资线索     hive数据库
		select DATE_FORMAT(create_time,'%Y-%m') year_month,customer_mobile,count(1) xs_nums
		from ods_vced.ods_vced_tm_leads_collection_pool_cur a
		where a.create_time >= '2024-03-26'  and a.create_time < '2024-03-27'
		and campaign_code = 'IBCRMJUNHAPPWZLZ2023VCCN'
		group by DATE_FORMAT(create_time,'%Y-%m') ,customer_mobile
	) xiansuo on xiansuo.year_month=arrive.year_month and xiansuo.customer_mobile=arrive.mobile_phone
) detail
group by year_month
order by 1



--23年预约试驾首触线索数量（历史全渠道去重）
select count(distinct x.customer_phone)
from 
(
-- 首次试驾在2023的用户
	select
	ta.customer_phone,
	min(ta.CREATED_AT) mt ,-- 首次预约试驾时间
	x.mt mt2 --首次线索时间
	FROM cyx_appointment.tt_appointment ta
	join (
	-- 第一次留过资在2023的用户
		select t.mobile,
		min(t.create_time) mt 
		from customer.tt_clue_clean t
		where 1=1
		and t.is_deleted = 0
--		and t.create_time < '2023-01-01'
		group by mobile
		having min(t.create_time)>= '2023-01-01'
		AND min(t.create_time) <'2024-01-01'
		)x on x.mobile= ta.customer_phone
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	group by 1
	having min(ta.CREATED_AT) >= '2023-01-01'
	AND min(ta.CREATED_AT) <'2024-01-01'
)x where 1=1
and x.mt2=x.mt -- 首次线索时间=首次预约试驾时间 剔除预约试驾以前的线索数据
--and DATEDIFF(x.mt,x.mt2)+1<=7 -- 首次线索时间和预约试驾时间差小于等于7天


	
--23年预约试驾全量线索量
select count(distinct x.customer_phone)
from 
(
	SELECT
	ta.CREATED_AT,
--	row_number ()over(partition by ta.customer_phone order by ta.CREATED_AT) rk,
	ta.one_id 客户ID,
	ta.customer_phone
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	and ta.CREATED_AT >= '2023-01-01'
	AND ta.CREATED_AT <'2024-01-01'
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	order by ta.CREATED_AT
)x

--24年预约试驾首触线索数量（历史全渠道去重）
select count(distinct x.customer_phone)
from 
(
-- 首次试驾在2023的用户
	select
	ta.customer_phone,
	min(ta.CREATED_AT) mt,
	x.mt mt2
	FROM cyx_appointment.tt_appointment ta
	join (
	-- 第一次留过资在2023的用户
		select t.mobile,
		min(t.create_time) mt 
		from customer.tt_clue_clean t
		where 1=1
		and t.is_deleted = 0
--		and t.create_time < '2023-01-01'
		group by mobile
		having min(t.create_time)>= '2024-01-01'
		AND min(t.create_time) <'2024-03-15'
		)x on x.mobile= ta.customer_phone
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	group by 1
	having min(ta.CREATED_AT) >= '2024-01-01'
	AND min(ta.CREATED_AT) <'2024-03-15'
)x where 1=1
and x.mt2=x.mt -- 首次线索时间小于预约试驾时间
--and DATEDIFF(x.mt,x.mt2)+1<=7 -- 首次线索时间和预约试驾时间差小于等于7天


--24年至今预约试驾全量线索量
select count(distinct x.customer_phone)
from 
(
	SELECT
	ta.CREATED_AT,
--	row_number ()over(partition by ta.customer_phone order by ta.CREATED_AT) rk,
	ta.one_id 客户ID,
	ta.customer_phone
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	and ta.CREATED_AT >= '2024-01-01'
	AND ta.CREATED_AT <'2024-03-15'
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	order by ta.CREATED_AT
)x
	
--当前全量用户中0-3年车主数量
select 
count(distinct tisd.vin)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
join	
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
		 and r.is_owner =1 
		 and r.member_id is not null 
		 and r.member_id <>''
		 and m.member_phone<>'*'
		 and m.member_phone is not null 
		 Settings allow_experimental_window_functions = 1
		 )a 
	where a.rk=1
	)xx on xx.vin_code=tisd.vin
where 1=1
	and tisd.is_deleted =0
--	and date(tisd.invoice_date)>=date(now()) - interval 3 year -- 车龄在3年以内
--	and date(tisd.invoice_date)<date(now())
	and tisd.invoice_date>='2021-03-15' -- 车龄在3年以内
	and tisd.invoice_date<'2024-03-15'

select '2024-03-15'

--当前全量0-3年车主中过去12个月有过活跃行为的用户量
select 
count(distinct tisd.vin)
from ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur tisd   -- 与发票表关联
join	
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
		 and r.is_owner =1 
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
			where t<'2024-03-15'
			and t>='2023-03-15' -- 当年活跃
			and id is not null 
			union all
			-- APP活跃 mini 
			select distinct toString(e.distinct_id) id,toDate(e.date) t
			from ods_rawd.ods_rawd_events_d_di e 
			where length(e.distinct_id)<=9
--			and event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5'
			and ((event in ('$AppViewScreen','$AppClick') and left($app_version,1)='5') or event in('$MPViewScreen','$MPClick'))
--			and event in('$MPViewScreen','$MPClick')
			and t<'2024-03-15'
			and t>='2023-03-15' -- 当年活跃
			and id is not null 
			)x
	)x1 on toString(x1.id)=toString(xx.id) 
where 1=1
	and tisd.is_deleted =0
	and tisd.invoice_date>='2021-03-15' -- 车龄在3年以内
	and tisd.invoice_date<'2024-03-15'
	
	
	————————————————————————————————————————————————————————————————————————————————————old

	--23年预约试驾首触线索数量（历史全渠道去重）
select count(distinct x.customer_phone)
from 
(
-- 首次试驾在2023的用户
	select
	ta.customer_phone,
	min(ta.CREATED_AT) mt,
	x.mt mt2
	FROM cyx_appointment.tt_appointment ta
	join (
	-- 第一次留过资在2023的用户
		select t.mobile,
		min(t.create_time) mt 
		from customer.tt_clue_clean t
		where 1=1
		and t.is_deleted = 0
--		and t.create_time < '2023-01-01'
		group by mobile
		having min(t.create_time)>= '2023-01-01'
		AND min(t.create_time) <'2024-01-01'
		)x on x.mobile= ta.customer_phone
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	group by 1
	having min(ta.CREATED_AT) >= '2023-01-01'
	AND min(ta.CREATED_AT) <'2024-01-01'
)x where 1=1
and x.mt2<x.mt -- 首次线索时间小于预约试驾时间
and DATEDIFF(x.mt,x.mt2)+1<=7 -- 首次线索时间和预约试驾时间差小于等于7天
	
--23年预约试驾首触线索数量（历史全渠道去重）
select count(distinct x.customer_phone)
from 
(
-- 首次试驾在2023的用户
	select
	ta.customer_phone,
	min(ta.CREATED_AT) mt 
	FROM cyx_appointment.tt_appointment ta
	left join (
	-- 第一次留过资用户的时间
		select t.mobile
		from customer.tt_clue_clean t
		where 1=1
		and t.is_deleted = 0
		and t.create_time < '2023-01-01'
		group by mobile
		)x on x.mobile= ta.customer_phone
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	group by 1
	having min(ta.CREATED_AT) >= '2023-01-01'
	AND min(ta.CREATED_AT) <'2024-01-01'
	and x.mobile is null -- 剔除2023以前留资用户
)x
	
	
--24年至今预约试驾首触线索数量（历史全渠道去重
	select count(distinct x.customer_phone)
from 
(
	SELECT
	ta.CREATED_AT,
	row_number ()over(partition by ta.customer_phone order by ta.CREATED_AT) rk,
--	ta.ARRIVAL_DATE 实际到店日期,
	ta.one_id 客户ID,
	ta.customer_phone
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	where 1=1
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.IS_DELETED =0
	order by ta.CREATED_AT
)x
	WHERE x.rk=1
	and x.CREATED_AT >= '2024-01-01'
	AND x.CREATED_AT <'2024-03-15'