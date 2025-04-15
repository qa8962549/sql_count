DROP table ods_oper_crm.202503_tuijian

--清洗出 活跃车主id以及对应月份 --淘汰 
CREATE TABLE IF NOT EXISTS ods_oper_crm.202503_tuijian
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
select 
distinct
month(toDateTime(client_time)) mt,
user user,
is_vehicle
from 
ods_gio.ods_gio_event_d m
join
(
	-- 清洗会员表 取其对应的最新信息
	select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
	and m.is_vehicle = 1
) m2 on toString(m.user)=toString(m2.cust_id)
where 1=1
and date(client_time)  >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'



--连续留存率 整年 推荐享好礼活跃车主留存情况  --淘汰 
select 
--m.mt,
count(distinct m.user) `当月会员日人数`,
count(distinct x.user)`次(N+1)月留存人数`,
count(distinct case when x.user is not null then x2.user end) `N+2月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	then x3.user end) `N+3月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null 
	then x4.user end) `N+4月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	then x5.user end) `N+5月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null 
	then x6.user end) `N+6月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	then x7.user end) `N+7月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null 
	then x8.user end) `N+8月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	then x9.user end) `N+9月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	and x9.user is not null
	then x10.user end) `N+10月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	and x9.user is not null and x10.user is not null
	then x11.user end) `N+11月连续留存人数`
from ods_oper_crm.202503_tuijian m
left join ods_oper_crm.202503_tuijian x on m.user =x.user and x.mt=m.mt+1
left join ods_oper_crm.202503_tuijian x2 on m.user =x2.user and x2.mt=m.mt+2
left join ods_oper_crm.202503_tuijian x3 on m.user =x3.user and x3.mt=m.mt+3
left join ods_oper_crm.202503_tuijian x4 on m.user =x4.user and x4.mt=m.mt+4
left join ods_oper_crm.202503_tuijian x5 on m.user =x5.user and x5.mt=m.mt+5
left join ods_oper_crm.202503_tuijian x6 on m.user =x6.user and x6.mt=m.mt+6
left join ods_oper_crm.202503_tuijian x7 on m.user =x7.user and x7.mt=m.mt+7
left join ods_oper_crm.202503_tuijian x8 on m.user =x8.user and x8.mt=m.mt+8
left join ods_oper_crm.202503_tuijian x9 on m.user =x9.user and x9.mt=m.mt+9
left join ods_oper_crm.202503_tuijian x10 on m.user =x10.user and x10.mt=m.mt+10
left join ods_oper_crm.202503_tuijian x11 on m.user =x11.user and x11.mt=m.mt+11
--join ads_crm.ads_crm_event_keys_member_d m2 on m.user=m2.user
where 1=1
--and m.user is not null 
group by m.mt
order by m.mt
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0

DROP table ods_oper_crm.202503_tuijian_dtuv

--- 清洗出 活跃车主id以及对应日
CREATE TABLE IF NOT EXISTS ods_oper_crm.202503_tuijian_dtuv
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
--CREATE view ods_oper_crm.202503_tuijian_dtuv
--as
select 
date(client_time) mt,
count(distinct user) num
from 
ods_gio.ods_gio_event_d m
join
(
	-- 清洗会员表 取其对应的最新信息
	select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
	and m.is_vehicle = 1
) m2 on toString(m.user)=toString(m2.cust_id)
where 1=1
and date(client_time)  >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'
group by 1
order by 1

-- 日UV
select *
from ods_oper_crm.202503_tuijian_dtuv


-- 高活跃日期（活跃人数高于当月均值）
select x.m,groupArray(x.mt)
from 
(
select month(toDateTime(a.mt)) m,a.num,a1.avgnum,a.mt mt
from ods_oper_crm.202503_tuijian_dtuv a
left join (
	select
	month(toDateTime(mt)) mt,
	--num,
	avg(num) avgnum 
	from ods_oper_crm.202503_tuijian_dtuv
	group by 1
	order by 1 ) a1 on month(toDateTime(a.mt))=a1.mt
where a.num>a1.avgnum
)x
group by 1

-- 高活跃日期 活跃人数
select 
month(toDateTime(x.mt)) mt,
count(distinct user) num
from 
ods_gio.ods_gio_event_d m
join
(
	-- 清洗会员表 取其对应的最新信息
	select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
	from
	(
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
		,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
	) m
	where m.rk=1
	and m.is_vehicle = 1
	) m2 on toString(m.user)=toString(m2.cust_id)
join (
--高活跃日期
	select month(toDateTime(a.mt)) m,a.num,a1.avgnum,a.mt mt
	from ods_oper_crm.202503_tuijian_dtuv a
	left join (
		select
		month(toDateTime(mt)) mt,
		--num,
		avg(num) avgnum 
		from ods_oper_crm.202503_tuijian_dtuv
		group by 1
		order by 1 ) a1 on month(toDateTime(a.mt))=a1.mt
	where a.num>a1.avgnum
)x on date(m.client_time)=x.mt
where 1=1
and date(client_time)  >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'
group by 1
order by 1


--当月均值
select
month(toDateTime(mt)),
--num,
avg(num)
from ods_oper_crm.202503_tuijian_dtuv
group by 1
order by 1 

----------------------------------------------------------新车主-----------------------------------------------------------------
 
 DROP table ods_oper_crm.202503_tuijian_xcz

--双端活动主页的pv、uv
CREATE TABLE IF NOT EXISTS ods_oper_crm.202503_tuijian_xcz
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
--双端活动主页的pv、uv
select 
distinct
month(toDateTime(client_time)) mt,
user
from 
ods_gio.ods_gio_event_d m
join (-- 新车主
			select member_id ,
			cust_id,
			toDateTime(operate_date) bind_time
			from
			(
				select member_id ,
				m.cust_id,
				operate_date ,
				row_number() over(partition by member_id order by operate_date asc) rk
				from ods_vocm.ods_vocm_vehicle_bind_record_d vrd
				left join ods_memb.ods_memb_tc_member_info_cur m on vrd.member_id=m.id::String
				where 1=1
				and deleted = 0
				and member_id <> ''
				and is_owner = 1
				and event_type = '1' -- 绑定
			)a 
			where a.rk = 1
			and toDateTime(operate_date)  >= '2025-01-01'
			and toDateTime(operate_date) <'2025-04-01'
		) m2 on toString(m.user)=toString(m2.cust_id)
join
	(
		-- 清洗会员表 取其对应的最新信息
		select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
		from
		(
			select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where  m.member_status <> '60341003'
			and m.cust_id is not null
			and m.is_deleted =0 
			Settings allow_experimental_window_functions = 1
		) m
		where m.rk=1
--		and m.is_vehicle = 1
) m3 on toString(m.user)=toString(m3.cust_id)	
where 1=1
and toDateTime(m2.bind_time) <= toDateTime(m.client_time) -- 绑定时间小于活动浏览时间
and date(client_time)  >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'


--用户连续留存率 整年
select 
--m.mt,
count(distinct m.user) `当月会员日人数`,
count(distinct x.user)`次(N+1)月留存人数`,
count(distinct case when x.user is not null then x2.user end) `N+2月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	then x3.user end) `N+3月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null 
	then x4.user end) `N+4月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	then x5.user end) `N+5月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null 
	then x6.user end) `N+6月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	then x7.user end) `N+7月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null 
	then x8.user end) `N+8月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	then x9.user end) `N+9月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	and x9.user is not null
	then x10.user end) `N+10月连续留存人数`,
count(distinct case when x.user is not null and x2.user is not null 
	and x3.user is not null and x4.user is not null 
	and x5.user is not null and x6.user is not null 
	and x7.user is not null and x8.user is not null
	and x9.user is not null and x10.user is not null
	then x11.user end) `N+11月连续留存人数`
from ods_oper_crm.202503_tuijian_xcz m
left join ods_oper_crm.202503_tuijian_xcz x on m.user =x.user and x.mt=m.mt+1
left join ods_oper_crm.202503_tuijian_xcz x2 on m.user =x2.user and x2.mt=m.mt+2
left join ods_oper_crm.202503_tuijian_xcz x3 on m.user =x3.user and x3.mt=m.mt+3
left join ods_oper_crm.202503_tuijian_xcz x4 on m.user =x4.user and x4.mt=m.mt+4
left join ods_oper_crm.202503_tuijian_xcz x5 on m.user =x5.user and x5.mt=m.mt+5
left join ods_oper_crm.202503_tuijian_xcz x6 on m.user =x6.user and x6.mt=m.mt+6
left join ods_oper_crm.202503_tuijian_xcz x7 on m.user =x7.user and x7.mt=m.mt+7
left join ods_oper_crm.202503_tuijian_xcz x8 on m.user =x8.user and x8.mt=m.mt+8
left join ods_oper_crm.202503_tuijian_xcz x9 on m.user =x9.user and x9.mt=m.mt+9
left join ods_oper_crm.202503_tuijian_xcz x10 on m.user =x10.user and x10.mt=m.mt+10
left join ods_oper_crm.202503_tuijian_xcz x11 on m.user =x11.user and x11.mt=m.mt+11
--join ads_crm.ads_crm_event_keys_member_d m2 on m.user=m2.user
where 1=1
--and m.user is not null 
group by m.mt
order by m.mt
settings join_use_nulls=1 -- 使空值默认为null，而不是0. int类型字段为空时会默认为0


DROP table ods_oper_crm.202503_tuijian_xcz_dtuv

--每日UV
CREATE TABLE IF NOT EXISTS ods_oper_crm.202503_tuijian_xcz_dtuv
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
select 
date(client_time) mt,
count(distinct user) num
from 
ods_gio.ods_gio_event_d m
join (-- 新车主
			select member_id ,
			cust_id,
			toDateTime(operate_date) bind_time
			from
			(
				select member_id ,
				m.cust_id,
				operate_date ,
				row_number() over(partition by member_id order by operate_date asc) rk
				from ods_vocm.ods_vocm_vehicle_bind_record_d vrd
				left join ods_memb.ods_memb_tc_member_info_cur m on vrd.member_id=m.id::String
				where 1=1
				and deleted = 0
				and member_id <> ''
				and is_owner = 1
				and event_type = '1' -- 绑定
			)a 
			where a.rk = 1
			and toDateTime(operate_date)  >= '2025-01-01'
			and toDateTime(operate_date) <'2025-04-01'
		) m2 on toString(m.user)=toString(m2.cust_id)
join
	(
		-- 清洗会员表 取其对应的最新信息
		select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
		from
		(
			select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where  m.member_status <> '60341003'
			and m.cust_id is not null
			and m.is_deleted =0 
			Settings allow_experimental_window_functions = 1
		) m
		where m.rk=1
--		and m.is_vehicle = 1
) m3 on toString(m.user)=toString(m3.cust_id)	
where 1=1
and toDateTime(m2.bind_time) <= toDateTime(m.client_time) -- 绑定时间小于活动浏览时间
and date(client_time) >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'
group by 1
order by 1

-- uv 
select *
from ods_oper_crm.202503_tuijian_xcz_dtuv


-- 高活跃日期（活跃人数高于当月均值）
select x.m,groupArray(x.mt)
from 
(
select month(toDateTime(a.mt)) m,a.num,a1.avgnum,a.mt mt
from ods_oper_crm.202503_tuijian_xcz_dtuv a
left join (
	select
	month(toDateTime(mt)) mt,
	--num,
	avg(num) avgnum 
	from ods_oper_crm.202503_tuijian_xcz_dtuv
	group by 1
	order by 1 ) a1 on month(toDateTime(a.mt))=a1.mt
where a.num>a1.avgnum
)x
group by 1 

-- 高活跃日期 活跃人数
select 
month(toDateTime(x.mt)) mt,
count(distinct user) num
from 
ods_gio.ods_gio_event_d m
join (-- 新车主
			select member_id ,
			cust_id,
			toDateTime(operate_date) bind_time
			from
			(
				select member_id ,
				m.cust_id,
				operate_date ,
				row_number()over(partition by member_id order by operate_date asc) rk
				from ods_vocm.ods_vocm_vehicle_bind_record_d vrd
				left join ods_memb.ods_memb_tc_member_info_cur m on vrd.member_id=m.id::String
				where 1=1
				and deleted = 0
				and member_id <> ''
				and is_owner = 1
				and event_type = '1' -- 绑定
			)a 
			where a.rk = 1
			and toDateTime(operate_date)  >= '2025-01-01'
			and toDateTime(operate_date) <'2025-04-01'
		) m2 on toString(m.user)=toString(m2.cust_id)
join
	(
		-- 清洗会员表 取其对应的最新信息
		select m.cust_id,m.id id,m.member_phone,m.member_time,m.is_vehicle
		from
		(
			select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where  m.member_status <> '60341003'
			and m.cust_id is not null
			and m.is_deleted =0 
			Settings allow_experimental_window_functions = 1
		) m
		where m.rk=1
) m3 on toString(m.user)=toString(m3.cust_id)	
join (
--高活跃日期
	select month(toDateTime(a.mt)) m,a.num,a1.avgnum,a.mt mt
	from ods_oper_crm.202503_tuijian_xcz_dtuv a
	left join (
		select
		month(toDateTime(mt)) mt,
		--num,
		avg(num) avgnum 
		from ods_oper_crm.202503_tuijian_xcz_dtuv
		group by 1
		order by 1 ) a1 on month(toDateTime(a.mt))=a1.mt
	where a.num>a1.avgnum
)x on date(m.client_time)=x.mt
where 1=1
and toDateTime(m2.bind_time) <= toDateTime(m.client_time) -- 绑定时间小于活动浏览时间
and date(client_time) >= '2025-01-01'  
and date(client_time) <'2025-04-01'
and date(event_time)>='2025-01-01'
and date(event_time)<'2025-04-01'
and (((`$platform`  in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App') or (`$platform`  in('MinP') or var_channel ='Mini'))
and event_key='Page_entry' 
and var_page_title='推荐购_邀请好友'
group by 1
order by 1


-- 当月均值
select
month(toDateTime(mt)),
--num,
avg(num)
from ods_oper_crm.202503_tuijian_xcz_dtuv
group by 1
order by 1 