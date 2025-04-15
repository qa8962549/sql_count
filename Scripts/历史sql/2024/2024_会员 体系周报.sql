____________________________________各等级用户周活、月活情况_______________________________________

-- 小程序各等级周度活跃用户人数
SELECT 
date_trunc('week',am.date) t,
m.member_level l,
count(DISTINCT case when m.is_owner=1 then distinct_id end)`车主`,
count(DISTINCT case when m.is_owner<>1 then distinct_id end)`粉丝`
from ads_crm.ads_crm_events_active_d am
join ads_crm.ads_crm_events_member_d m on am.distinct_id =m.distinct_id 
where 1=1
and am.channel='Mini'
and date>='2024-01-01'
group by t,l
order by t desc ,l

--小程序各等级月度活跃用户人数
SELECT 
date_trunc('month',am.date) t,
m.member_level l,
count(DISTINCT case when m.is_owner=1 then distinct_id end)`车主`,
count(DISTINCT case when m.is_owner=0 then distinct_id end)`粉丝`
from ads_crm.ads_crm_events_active_d am
join ads_crm.ads_crm_events_member_d m on am.distinct_id =m.distinct_id 
where 1=1
and am.channel='Mini'
and date>='2024-01-01'
group by t,l
order by t desc,l

-- App各等级3个月未活跃用户 APP/mini
SELECT 
--date_trunc('month',am.mt) t,
m.member_level l,
count(DISTINCT case when m.is_owner=1 then distinct_id end)`车主`,
count(DISTINCT case when m.is_owner=0 then distinct_id end)`粉丝`
from
(-- App用户的最近访问时间
	select am.distinct_id,
	max(am.date) mt
	from ads_crm.ads_crm_events_active_d am
	where 1=1
--	and am.channel='App'
	and am.channel='Mini'
	group by distinct_id
	having mt <toDate('2024-01-01')+ interval '-90 day'-- 沉睡用户：截止目前超过30天未活跃,但在60天内活跃
	and mt >=toDate('2024-01-01')+ interval '-120 day'  -- 
)a
left join ads_crm.ads_crm_events_member_d m on a.distinct_id=m.distinct_id 
group by l
order by l

-- App各等级9个月未活跃用户 APP/mini
SELECT 
--date_trunc('month',am.mt) t,
m.member_level l,
count(DISTINCT case when m.is_owner=1 then distinct_id end)`车主`,
count(DISTINCT case when m.is_owner=0 then distinct_id end)`粉丝`
from
(-- App用户的最近访问时间
	select am.distinct_id,
	max(am.date) mt
	from ads_crm.ads_crm_events_active_d am
	where 1=1
	and am.channel='App'
--	and am.channel='Mini'
	group by distinct_id
	having mt <toDate('2024-01-01')+ interval '-270 day'-- 
	and mt >=toDate('2024-01-01')+ interval '-300 day'  -- 
)a
left join ads_crm.ads_crm_events_member_d m on a.distinct_id=m.distinct_id 
group by l
order by l

-- APP注册用户
	select date_trunc('week',m.min_app_time) t
	,count(distinct m.distinct_id)
	from ads_crm.ads_crm_events_member_d m
	where m.min_app_time is not null 
	and m.min_app_time>='2024-01-01'
--	and m.min_app_time<'2024-02-01'
	group by t 
	order by t

-- App新增用户留存 用户注册后第N天活跃
select date_trunc('week',x.mt) t
,x.lc
,count(distinct x.distinct_id)
from 
	(
	select 
	distinct 
	m.distinct_id
--	,a.date
	,date(m.min_app_time) mt
--	,a.date-date(m.min_app_time)
	,case when a.date-date(m.min_app_time)=3 then '1新增会员3日留存'
		when  a.date-date(m.min_app_time)=7 then '2新增会员7日留存'
		when  a.date-date(m.min_app_time)=15 then '3新增会员15日留存'
		when  a.date-date(m.min_app_time)=30 then '4新增会员30日留存'
		when  a.date-date(m.min_app_time)=60 then '5新增会员60日留存'
		when  a.date-date(m.min_app_time)=90 then '6新增会员90日留存'
		when  a.date-date(m.min_app_time)=180 then '7新增会员180日留存'
		end lc
	from ads_crm.ads_crm_events_member_d m
	join ads_crm.ads_crm_events_active_d a on m.distinct_id =a.distinct_id 
	where 1=1
	and m.min_app_time is not null 
	and a.channel ='App'
--	and am.channel='Mini'
--	and m.min_mini_time>'2000-01-01' -- 剔除mini空值
	and m.min_app_time>='2024-01-01'
--	and m.min_app_time<'2024-02-01'
	)x
group by t,lc
order by t desc ,lc

-- App/mini新增用户留存 用户注册后N天内活跃
select date_trunc('week',x.mt) t
,x.lc
,count(distinct x.distinct_id)
from 
	(
	select m.distinct_id
	,a.date
	,date(m.min_app_time) mt
	,a.date-date(m.min_app_time)
	,case when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=3 then '1新增会员3日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=7 then '2新增会员7日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=15 then '3新增会员15日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=30 then '4新增会员30日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=60 then '5新增会员60日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=90 then '6新增会员90日留存'
		when a.date-date(m.min_app_time)>=1 and a.date-date(m.min_app_time)<=180 then '7新增会员180日留存'
		end lc
	from ads_crm.ads_crm_events_member_d m
	join ads_crm.ads_crm_events_active_d a on m.distinct_id =a.distinct_id 
	where 1=1
	and m.min_app_time is not null 
	and a.channel ='App'
	--	and am.channel='Mini'
	and m.min_app_time>='2024-01-01'
--	and m.min_app_time<'2024-02-01'
	)x
group by t,lc
order by t desc,lc


-- MIni注册用户
	select date_trunc('week',m.min_mini_time) t
	,count(distinct m.distinct_id)
	from ads_crm.ads_crm_events_member_d m
	where 1=1
	and m.min_mini_time>='2024-01-01'
--	and m.min_mini_time<'2024-02-01'
	group by t 
	order by t

-- MINI新增用户留存 用户注册后第N天活跃
select date_trunc('week',x.mt) t
,x.lc
,count(distinct x.distinct_id)
from 
	(
	select 
	distinct 
	m.distinct_id
--	,a.date
	,date(m.min_mini_time) mt
--	,a.date-date(m.min_mini_time)
	,case when a.date-date(m.min_mini_time)=3 then '1新增会员3日留存'
		when  a.date-date(m.min_mini_time)=7 then '2新增会员7日留存'
		when  a.date-date(m.min_mini_time)=15 then '3新增会员15日留存'
		when  a.date-date(m.min_mini_time)=30 then '4新增会员30日留存'
		when  a.date-date(m.min_mini_time)=60 then '5新增会员60日留存'
		when  a.date-date(m.min_mini_time)=90 then '6新增会员90日留存'
		when  a.date-date(m.min_mini_time)=180 then '7新增会员180日留存'
		end lc
	from ads_crm.ads_crm_events_member_d m
	join ads_crm.ads_crm_events_active_d a on m.distinct_id =a.distinct_id 
	where 1=1
	and a.channel='Mini'
	and m.min_mini_time>='2024-01-01'
--	and m.min_mini_time<'2024-02-01'
	)x
group by t,lc
order by t desc,lc

-- mini新增用户留存 用户注册后N天内活跃
select date_trunc('week',x.mt) t
,x.lc
,count(distinct x.distinct_id)
from 
	(
	select m.distinct_id
	,a.date
	,date(m.min_mini_time) mt
	,a.date-date(m.min_mini_time)
	,case when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=3 then '1新增会员3日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=7 then '2新增会员7日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=15 then '3新增会员15日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=30 then '4新增会员30日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=60 then '5新增会员60日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=90 then '6新增会员90日留存'
		when a.date-date(m.min_mini_time)>=1 and a.date-date(m.min_mini_time)<=180 then '7新增会员180日留存'
		end lc
	from ads_crm.ads_crm_events_member_d m
	join ads_crm.ads_crm_events_active_d a on m.distinct_id =a.distinct_id 
	where 1=1
	and a.channel='Mini'
	and m.min_mini_time>='2024-01-01'
--	and m.min_mini_time<'2024-02-01'
	)x
group by t,lc
order by t desc,lc

_________________________________一键留资 app mini_______________________________________

-- 留资弹窗触发次数PV
select count( user_id) PV 
,count(distinct user_id) UV
from ods_rawd.ods_rawd_events_d_di a
where 1=1
and event='Page_entry'
and length(distinct_id)<9 
and date>='2024-01-01'
and date<'2024-02-01'
and page_title='内容详情_留资弹窗'
and bussiness_name='社区'
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--and ($lib='MiniProgram' or channel='Mini') -- Mini
--and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))

-- 留资弹窗触发次数PV
select count( user_id) PV 
,count(distinct user_id) UV
from ods_rawd.ods_rawd_events_d_di a
where 1=1
and event='Button_click'
and length(distinct_id)<9 
and date>='2024-01-01'
and date<'2024-02-01'
and page_title='内容详情_留资弹窗'
and bussiness_name='社区'
and btn_name ='了解更多'
--and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
and ($lib='MiniProgram' or channel='Mini') -- Mini
--and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))


--线索数
select 
COUNT( DISTINCT a.one_id) num 
from 
	(select DISTINCT a.one_id,a.business_id
	from ods_cust.ods_cust_tt_clue_clean_cur a 
	where 1=1
	and a.create_time >= '2024-01-01'
	and a.create_time <'2024-02-01'
	and a.is_deleted=0)a
global join (select distinct distinct_id 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-01'
	and date<'2024-02-01'
	and page_title='内容详情_留资弹窗'
	and bussiness_name='社区'
	and btn_name ='了解更多'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
	and ($lib='MiniProgram' or channel='Mini') -- Mini
	--and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
	)
x on toString(x.distinct_id) =toString(a.one_id)  

--留资线索到店数量
select COUNT( DISTINCT a.one_id) num 
from 
	(select DISTINCT a.one_id,a.business_id
	from ods_cust.ods_cust_tt_clue_clean_cur a 
	where 1=1
	and a.create_time >= '2024-01-01'
	and a.create_time <'2024-02-01'
	and a.is_deleted=0)a
global join (select distinct distinct_id 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-01'
	and date<'2024-02-01'
	and page_title='内容详情_留资弹窗'
	and bussiness_name='社区'
	and btn_name ='了解更多'
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	--and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
)
x on toString(x.distinct_id) =toString(a.one_id)  
join (select distinct ta.ONE_ID
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where ta.CREATED_AT >= '2024-01-01'
	AND ta.CREATED_AT <'2024-02-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.ARRIVAL_DATE is not null -- 到点时间不为空
	)x2 on toString(x2.ONE_ID) =toString(a.one_id)  
	
--留资线索到店试驾人数
select COUNT( DISTINCT a.one_id) num 
from 
	(select DISTINCT a.one_id,a.business_id
	from ods_cust.ods_cust_tt_clue_clean_cur a 
	where 1=1
	and a.create_time >= '2024-01-01'
	and a.create_time <'2024-02-01'
	and a.is_deleted=0)a
global join (select distinct distinct_id 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-01'
	and date<'2024-02-01'
	and page_title='内容详情_留资弹窗'
	and bussiness_name='社区'
	and btn_name ='了解更多'
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	--and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
	)x on toString(x.distinct_id) =toString(a.one_id)  
join (select distinct ta.ONE_ID
	from ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	where ta.CREATED_AT >= '2024-01-01'
	AND ta.CREATED_AT <'2024-02-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.ARRIVAL_DATE is not null -- 到点时间不为空
	and tad.STATUS='70711002' -- 已试驾状态
	)x2 on toString(x2.ONE_ID) =toString(a.one_id)  


-- 线索产生订单数
select 
COUNT(a.`商机id`) num 
from
	(select DISTINCT a.business_id `商机id`
		from 
			(select DISTINCT a.one_id,a.business_id
			from ods_cust.ods_cust_tt_clue_clean_cur a 
			where 1=1
			and a.create_time >= '2024-01-01'
			and a.create_time <'2024-02-01'
			and a.is_deleted=0)a
		global join (select distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event='Button_click'
			and length(distinct_id)<9 
			and date>='2024-01-01'
			and date<'2024-02-01'
			and page_title='内容详情_留资弹窗'
			and bussiness_name='社区'
			and btn_name ='了解更多'
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--			and ($lib='MiniProgram' or channel='Mini') -- Mini
--			and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
			)
		x on toString(x.distinct_id) =toString(a.one_id)  
		) a 
join 
	(
	select a.customer_business_id `商机id` ,min(a.created_at) `订单时间`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a 
	left join ods_dict.ods_dict_tc_code_d g on g.CODE_ID = a.so_status
	where a.business_type<>14031002
	and a.is_deleted = 0
	and a.created_at  >= '2024-01-01'
	and a.created_at  <'2024-02-01'
	and g.CODE_CN_DESC in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY `商机id`
	) b on a.`商机id`=b.`商机id`

-- 总开票人数
select 
COUNT(a.`商机id`) num 
from
	(select DISTINCT a.business_id `商机id`
		from 
			(select DISTINCT a.one_id,a.business_id
			from ods_cust.ods_cust_tt_clue_clean_cur a 
			where 1=1
			and a.create_time >= '2024-01-01'
			and a.create_time <'2024-02-01'
			and a.is_deleted=0)a
		global join (select distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event='Button_click'
			and length(distinct_id)<9 
			and date>='2024-01-01'
			and date<'2024-02-01'
			and page_title='内容详情_留资弹窗'
			and bussiness_name='社区'
			and btn_name ='了解更多'
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--			and ($lib='MiniProgram' or channel='Mini') -- Mini
--			and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
			)x on toString(x.distinct_id) =toString(a.one_id)  
		) a 
join 
	(
	select a.customer_business_id `商机id`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a 
	left join ods_dict.ods_dict_tc_code_d g on g.CODE_ID = a.so_status
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur d on d.vi_no = a.so_no
	join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur s on d.sales_vin=s.vin -- 与发票表关联
	where a.business_type<>14031002
	and a.is_deleted = 0
	and a.created_at  >= '2024-01-01'
	and a.created_at  <'2024-02-01'
	and g.CODE_CN_DESC in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY `商机id`
	) b on a.`商机id`=b.`商机id`

-- 线索产生订单数 有预约但未试驾并产生订单数
select 
COUNT(a.`商机id`) num 
from
	(select DISTINCT a.business_id `商机id`
		from 
			(select DISTINCT a.one_id,a.business_id
			from ods_cust.ods_cust_tt_clue_clean_cur a 
			where 1=1
			and a.create_time >= '2024-01-01'
			and a.create_time <'2024-02-01'
			and a.is_deleted=0)a
		global join (select distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event='Button_click'
			and length(distinct_id)<9 
			and date>='2024-01-01'
			and date<'2024-02-01'
			and page_title='内容详情_留资弹窗'
			and bussiness_name='社区'
			and btn_name ='了解更多'
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--			and ($lib='MiniProgram' or channel='Mini') -- Mini
--			and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
			)
		x on toString(x.distinct_id) =toString(a.one_id)  
		join (
		-- 未试驾
			select distinct ta.ONE_ID
			from ods_cyap.ods_cyap_tt_appointment_d ta
			LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
			where ta.CREATED_AT >= '2024-01-01'
			AND ta.CREATED_AT <'2024-02-01'
			AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
			AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
			and ta.ARRIVAL_DATE is not null -- 到点时间不为空
			and tad.STATUS<>'70711002' -- 已试驾状态
			)x2 on toString(x2.ONE_ID) =toString(a.one_id)  
		) a 
join 
	(
	select a.customer_business_id `商机id` ,min(a.created_at) `订单时间`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a 
	left join ods_dict.ods_dict_tc_code_d g on g.CODE_ID = a.so_status
	where a.business_type<>14031002
	and a.is_deleted = 0
	and a.created_at  >= '2024-01-01'
	and a.created_at  <'2024-02-01'
	and g.CODE_CN_DESC in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY `商机id`
	) b on a.`商机id`=b.`商机id`
	
-- 总开票人数 有预约但未试驾并产生开票数
select 
COUNT(a.`商机id`) num 
from
	(select DISTINCT a.business_id `商机id`
		from 
			(select DISTINCT a.one_id,a.business_id
			from ods_cust.ods_cust_tt_clue_clean_cur a 
			where 1=1
			and a.create_time >= '2024-01-01'
			and a.create_time <'2024-02-01'
			and a.is_deleted=0)a
		global join (select distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and event='Button_click'
			and length(distinct_id)<9 
			and date>='2024-01-01'
			and date<'2024-02-01'
			and page_title='内容详情_留资弹窗'
			and bussiness_name='社区'
			and btn_name ='了解更多'
			and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--			and ($lib='MiniProgram' or channel='Mini') -- Mini
--			and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
			)x on toString(x.distinct_id) =toString(a.one_id)  
		join (
		-- 未试驾
			select distinct ta.ONE_ID
			from ods_cyap.ods_cyap_tt_appointment_d ta
			LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
			where ta.CREATED_AT >= '2024-01-01'
			AND ta.CREATED_AT <'2024-02-01'
			AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
			AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
			and ta.ARRIVAL_DATE is not null -- 到点时间不为空
			and tad.STATUS<>'70711002' -- 已试驾状态
			)x2 on toString(x2.ONE_ID) =toString(a.one_id)  
		) a 
join 
	(
	select a.customer_business_id `商机id`
	from ods_cydr.ods_cydr_tt_sales_orders_cur a 
	left join ods_dict.ods_dict_tc_code_d g on g.CODE_ID = a.so_status
	left join ods_cydr.ods_cydr_tt_sales_order_vin_cur d on d.vi_no = a.so_no
	join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur s on d.sales_vin=s.vin -- 与发票表关联
	where a.business_type<>14031002
	and a.is_deleted = 0
	and a.created_at  >= '2024-01-01'
	and a.created_at  <'2024-02-01'
	and g.CODE_CN_DESC in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY `商机id`
	) b on a.`商机id`=b.`商机id`
	
__________________________________________各等级转化——————————————————————————————————————————————

-- GMV
select 
date_trunc('week',m.tt) tt 
--date_trunc('month',m.tt) tt 
,m.level_id
,SUM(case when m.fl='精品'and m.is_vehicle=0 then m.`不含税的总金额` end) `粉丝精品GMV`
,SUM(case when m.fl='精品'and m.is_vehicle=1 then m.`不含税的总金额` end) `车主精品GMV`
,SUM(case when m.fl='售后养护'and m.is_vehicle=0 then m.`不含税的总金额` end) `粉丝售后养护GMV`
,SUM(case when m.fl='售后养护'and m.is_vehicle=1 then m.`不含税的总金额` end) `车主售后养护GMV`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,h.level_id level_id
	,h.is_vehicle is_vehicle
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
	,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end) `fl`
	,((b.fee/100) - (b.coupon_fee/100))/1.13 `不含税的总金额`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time as tt
	,case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
	,f.name `分类`
	from ods_orde.ods_orde_tt_order_d a  -- 订单主表
	left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
	left join (
		-- 清洗cust_id
		select m.*
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,
		j.name,
		f2.name as fl
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
--		and j.is_deleted ='0' -- 该表该字段全为空
--		and i.is_deleted ='0' -- 该表该字段全为空
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	)f2 on f2.spu_id=b.spu_id
	left join(
	--	#V值退款成功记录
		select so.order_code
		,sp.product_id
		,CASE 
			WHEN so.status ='51171001' THEN '待审核'
			WHEN so.status ='51171002' THEN '待退货入库'
			WHEN so.status ='51171003' THEN '待退款'
			WHEN so.status ='51171004' THEN '退款成功'
			WHEN so.status ='51171005' THEN '退款失败'
			WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
		,sum(sp.sales_return_num) `退货数量`
		,sum(so.refund_point) `退回V值`
		,max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
		where so.is_deleted = 0 
		and so.status='51171004' -- 退款成功
		and sp.is_deleted=0
		GROUP BY order_code,product_id,`退货状态`
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where 1=1
	and toDate(a.create_time) >= '2024-01-01' 
--	and toDate(a.create_time) <'2024-02-01'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m
group by tt,level_id 
order by tt desc,level_id

-- 推荐购订单
	select 
	date_trunc('week',r.create_time) tt 
--	date_trunc('month',r.create_time) tt 
	,m.level_id
	,count(case when m.is_vehicle =0 then r.order_no end) `粉丝推荐购订单`
	,count(case when m.is_vehicle =1 then r.order_no end) `车主推荐购订单`
	from ods_invi.ods_invi_tm_invite_record_d r
	left join ods_memb.ods_memb_tc_member_info_cur m on r.invite_member_id=m.id
	where 1=1
	and r.create_time >= '2024-01-01'
--	and r.create_time <= '2024-02-01'
	and r.is_deleted = 0
	and r.order_status in ('14041008','14041003')   -- 有效订单 已交车、审核已通过
	and r.order_no is not NULL   -- 筛选订单号不为空
	and r.cancel_large_setorder_time <'2000-01-01'    -- 取消订单时间为空，排除取消订单的情况
	and r.red_invoice_time <'2000-01-01'  -- 红冲发票为空
	group by tt,level_id 
	order by tt desc,level_id

--一键留资
select 
date_trunc('week',a.create_time) t
--date_trunc('month',a.create_time) t
,x.level_id
,COUNT(DISTINCT case when x.is_vehicle=0 then a.one_id end ) `粉丝一键留资`
,COUNT(DISTINCT case when x.is_vehicle=1 then a.one_id end ) `车主一键留资` 
from 
	(select DISTINCT a.one_id
	,toDate(a.create_time)  create_time
	from ods_cust.ods_cust_tt_clue_clean_cur a 
	where 1=1
	and a.create_time >= '2024-01-01'
--	and a.create_time <'2024-02-01'
	and a.is_deleted=0)a
global join (select distinct distinct_id 
	,m.level_id level_id
	,m.is_vehicle is_vehicle
	from ods_rawd.ods_rawd_events_d_di a
	join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id) =toString(a.distinct_id) 
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-01'
--	and date<'2024-02-01'
	and page_title='内容详情_留资弹窗'
	and bussiness_name='社区'
	and btn_name ='了解更多'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') --APP 
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')or ($lib='MiniProgram' or channel='Mini'))
	)x on toString(x.distinct_id) =toString(a.one_id)  
group by t,level_id
order by t desc,level_id

-- 预约试驾
select 
--date_trunc('week', ta.CREATED_AT) t
date_trunc('month', ta.CREATED_AT) t
,m.level_id
,COUNT(DISTINCT case when m.is_vehicle=0 then ta.ONE_ID end ) `粉丝一键留资`
,COUNT(DISTINCT case when m.is_vehicle=1 then ta.ONE_ID end ) `车主一键留资` 
from ods_cyap.ods_cyap_tt_appointment_d ta
LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id) =toString(ta.ONE_ID) 
where ta.CREATED_AT >= '2024-01-01'
AND ta.CREATED_AT <'2024-02-01'
AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--and ta.ARRIVAL_DATE is not null -- 到点时间不为空
--and tad.STATUS='70711002' -- 已试驾状态
group by t,level_id
order by t,level_id