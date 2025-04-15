

select distinct var_activity_name 
from dwd_23.dwd_23_gio_tracking m
where var_activity_name like '%2024%'
and time >'2025-01-01'

--会员日参加记录
CREATE TABLE IF NOT EXISTS ods_oper_crm.2025_VIP_month03
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
-- 每个用户活跃月份累计数
	select 
	distinct 
	m.user distinct_id
	,month(toDateTime(client_time)) mt
	,m2.is_vehicle is_vehicle
	from ods_gio.ods_gio_event_d m
	join 
	(-- 清洗
		select m.id,m.cust_id cust_id,is_vehicle
		from 
			(-- 清洗
			select m.id,
			m.cust_id,
			m.is_vehicle,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' 
			and m.is_deleted=0
			) m
		where m.rk=1 
		) m2 on toString(m2.cust_id)=toString(m.user)
	where 1=1
--	and m2.is_vehicle =1 -- 筛选当下身份为车主
--	and m2.is_vehicle =0 -- 筛选当下身份为粉丝
	and event_time>'2025-01-01'
	and m.client_time <'2025-04-01'
	and m.client_time >='2025-01-01'
	and event_key in('Page_view','Page_entry')
	and var_page_title in ('1月会员日','2月会员日','3月会员日','4月会员日'
		,'525车主节','6月会员日','7月会员日','8月会员日'
		,'9月会员日','10月会员日','11月会员日','沃尔沃汽车双旦会员日')
	and left(var_activity_name,4)='2025'
	settings join_use_nulls=1


	DROP table ods_oper_crm.2025_VIP_month03

--APP用户会员日连续留存率 整年
select 
--m.mt,
count(distinct m.distinct_id) `当月会员日人数`,
count(distinct x.distinct_id)`次(N+1)月留存人数`,
count(distinct case when x.distinct_id is not null then x2.distinct_id end) `N+2月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	then x3.distinct_id end) `N+3月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null 
	then x4.distinct_id end) `N+4月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	then x5.distinct_id end) `N+5月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null 
	then x6.distinct_id end) `N+6月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	then x7.distinct_id end) `N+7月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null 
	then x8.distinct_id end) `N+8月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	then x9.distinct_id end) `N+9月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	and x9.distinct_id is not null
	then x10.distinct_id end) `N+10月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	and x9.distinct_id is not null and x10.distinct_id is not null
	then x11.distinct_id end) `N+11月连续留存人数`
from ods_oper_crm.2025_VIP_month03 m
left join ods_oper_crm.2025_VIP_month03 x on m.distinct_id =x.distinct_id and x.mt=m.mt+1
left join ods_oper_crm.2025_VIP_month03 x2 on m.distinct_id =x2.distinct_id and x2.mt=m.mt+2
left join ods_oper_crm.2025_VIP_month03 x3 on m.distinct_id =x3.distinct_id and x3.mt=m.mt+3
left join ods_oper_crm.2025_VIP_month03 x4 on m.distinct_id =x4.distinct_id and x4.mt=m.mt+4
left join ods_oper_crm.2025_VIP_month03 x5 on m.distinct_id =x5.distinct_id and x5.mt=m.mt+5
left join ods_oper_crm.2025_VIP_month03 x6 on m.distinct_id =x6.distinct_id and x6.mt=m.mt+6
left join ods_oper_crm.2025_VIP_month03 x7 on m.distinct_id =x7.distinct_id and x7.mt=m.mt+7
left join ods_oper_crm.2025_VIP_month03 x8 on m.distinct_id =x8.distinct_id and x8.mt=m.mt+8
left join ods_oper_crm.2025_VIP_month03 x9 on m.distinct_id =x9.distinct_id and x9.mt=m.mt+9
left join ods_oper_crm.2025_VIP_month03 x10 on m.distinct_id =x10.distinct_id and x10.mt=m.mt+10
left join ods_oper_crm.2025_VIP_month03 x11 on m.distinct_id =x11.distinct_id and x11.mt=m.mt+11
join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
where 1=1
and m.is_vehicle =1 -- 筛选当下身份为车主
--and m.is_vehicle =0 -- 筛选当下身份为粉丝
group by m.mt
order by m.mt




--平台本月 平台次月留存
select 
formatDateTime(m.dt,'%Y-%m') t,
count(distinct m.memberid),
count(distinct case when month(x.dt)=month(m.dt)+1 then x.memberid else null end)`次(N+1)月留存人数`
from ods_oper_crm.ods_oper_crm_active_gio_d_si m
left join ods_oper_crm.ods_oper_crm_active_gio_d_si x on m.memberid =x.memberid
where platform ='App'
and m.dt<'2025-04-01'
and m.dt>= '2025-01-01'
and x.dt<'2025-04-01'
and x.dt>= '2025-01-01'
and m.is_vehicle ='1'
group by 1 
order by 1 



———————————————————————————————————————————————————————————————————————————————————————订阅按钮点击————————————————————————————————————————————————————————————————

DROP table ods_oper_crm.2024_dingyue_month11

--订阅点击记录
CREATE TABLE IF NOT EXISTS ods_oper_crm.2024_dingyue_month11
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
-- 每个用户活跃月份累计数
select 
distinct 
distinct_id,
month(toDateTime(date)) mt
from dwd_23.dwd_23_gio_tracking
where 1=1
and event_time>'2025-01-01'
and event='Button_click'
and date < '2025-04-01'
and date > '2025-01-01'
--	and page_title ='4月会员日'
and left(var_activity_name,4)='2024'
and (var_activity_name like '%会员日%' or var_activity_name like '%525%')
and btn_name in ('订阅活动','订阅本活动')
and length(distinct_id)<9 
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or `$lib` ='MiniProgram' or  channel in ('Mini', 'App') )--双端
	
--订阅连续留存率 整年
select 
--m.mt,
count(distinct m.distinct_id) `当月订阅人数`,
count(distinct x.distinct_id)`次(N+1)月留存人数`,
count(distinct case when x.distinct_id is not null then x2.distinct_id end) `N+2月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	then x3.distinct_id end) `N+3月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null 
	then x4.distinct_id end) `N+4月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	then x5.distinct_id end) `N+5月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null 
	then x6.distinct_id end) `N+6月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	then x7.distinct_id end) `N+7月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null 
	then x8.distinct_id end) `N+8月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	then x9.distinct_id end) `N+9月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	and x9.distinct_id is not null
	then x10.distinct_id end) `N+10月连续留存人数`,
count(distinct case when x.distinct_id is not null and x2.distinct_id is not null 
	and x3.distinct_id is not null and x4.distinct_id is not null 
	and x5.distinct_id is not null and x6.distinct_id is not null 
	and x7.distinct_id is not null and x8.distinct_id is not null
	and x9.distinct_id is not null and x10.distinct_id is not null
	then x11.distinct_id end) `N+11月连续留存人数`
from ods_oper_crm.2024_dingyue_month11 m
left join ods_oper_crm.2024_dingyue_month11 x on m.distinct_id =x.distinct_id and x.mt=m.mt+1
left join ods_oper_crm.2024_dingyue_month11 x2 on m.distinct_id =x2.distinct_id and x2.mt=m.mt+2
left join ods_oper_crm.2024_dingyue_month11 x3 on m.distinct_id =x3.distinct_id and x3.mt=m.mt+3
left join ods_oper_crm.2024_dingyue_month11 x4 on m.distinct_id =x4.distinct_id and x4.mt=m.mt+4
left join ods_oper_crm.2024_dingyue_month11 x5 on m.distinct_id =x5.distinct_id and x5.mt=m.mt+5
left join ods_oper_crm.2024_dingyue_month11 x6 on m.distinct_id =x6.distinct_id and x6.mt=m.mt+6
left join ods_oper_crm.2024_dingyue_month11 x7 on m.distinct_id =x7.distinct_id and x7.mt=m.mt+7
left join ods_oper_crm.2024_dingyue_month11 x8 on m.distinct_id =x8.distinct_id and x8.mt=m.mt+8
left join ods_oper_crm.2024_dingyue_month11 x9 on m.distinct_id =x9.distinct_id and x9.mt=m.mt+9
left join ods_oper_crm.2024_dingyue_month11 x10 on m.distinct_id =x10.distinct_id and x10.mt=m.mt+10
left join ods_oper_crm.2024_dingyue_month11 x11 on m.distinct_id =x11.distinct_id and x11.mt=m.mt+11
--join ads_crm.ads_crm_events_member_d m2 on m.distinct_id=m2.distinct_id
where 1=1
--and m2.is_owner =1 -- 筛选当下身份为车主
--and m2.is_owner =0 -- 筛选当下身份为粉丝
group by m.mt
order by m.mt


-- 累计活跃了N个会员日的人数
select x.num num,
count(distinct x.user) vip_num 
from 
(
-- 每个用户活跃月份累计数
	select 
	m.user,
	count(distinct var_page_title) num 
	from ods_gio.ods_gio_event_d m
	join 
	(-- 清洗
		select m.id,m.cust_id cust_id,is_vehicle
		from 
			(-- 清洗
			select m.id,
			m.cust_id,
			m.is_vehicle,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' 
			and m.is_deleted=0
			) m
		where m.rk=1 
		) m2 on toString(m2.cust_id)=toString(m.user)
	where 1=1
--	and m2.is_vehicle =1 -- 筛选当下身份为车主
--	and m2.is_vehicle =0 -- 筛选当下身份为粉丝
	and event_time>'2025-01-01'
	and m.client_time <'2025-04-01'
	and m.client_time >='2025-01-01'
	and event_key in('Page_view','Page_entry')
--	and var_page_title = '1月会员日'
	and var_page_title in ('1月会员日','2月会员日','3月会员日','4月会员日'
		,'525车主节','6月会员日','7月会员日','8月会员日'
		,'9月会员日','10月会员日','11月会员日','沃尔沃汽车双旦会员日')
	and left(var_activity_name,4)='2025'
	group by user
	order by num desc 
)x
group by num
order by num 