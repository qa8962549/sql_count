-- 查 表 库
SELECT database, name
FROM system.tables
WHERE database like '%ods_cydr%';

-- 查 表 库
SELECT database, name
FROM system.tables
where name like '%good_item_sku%'

SELECT  * from `system`.clusters -- 查询集群和其节点信息

SELECT * 
FROM system.replicas
where database='dms_manage'
; -- 查询当前节点信息：

SELECT * FROM system.parts;


select dateDiff('day', toDate(now()), addMonths(toDate(now()), 1));

SELECT formatDateTime(now(), '%Y-%m-%d %H:%M:%s');
 
SELECT addMonths(toDate('2024-01-01'), 3);

SELECT dateDiff('day', toDate('2024-01-01'), toDate('2024-01-10'));

SELECT subtractDays(toDate('2024-01-10'), 3);

SELECT toDate('2024-01-10')+3

SELECT extract(year from now());

--HarmonyOS Next的筛选条件 纯血鸿蒙系统2024年10月13日开始产生测试埋点数据，11月2日对外露出，
select 
from ods
and `$platform`='HarmonyOS'
and event_time >= '2024-10-13'
and client_time >='2024-10-13'
and $data_source_id='920eac3d085fb735'  --鸿蒙原生端的数据源，H5无法拆分出来

-- 人车关系表
select
c.vin_decrypt VIN,
right(round(b.mb_decrypt/5,0)::varchar,11) phone
from ods_cdp.ods_cdp_dws_vehicle_relation_d a
join ods_oper_crm.ods_oper_crm_cdp_mobile_decrypt_d_si b on a.mobile = b.mb_crypto
join ods_oper_crm.ods_oper_crm_cdp_vin_decrypt_d c on a.vin = c.vin_crypto
where a.cvr_type = '开票车主'

-- 用户表逻辑如下
select *
from ods_oper_crm.ods_oper_crm_usr_gio_d_si

--活跃表
select *
from ods_oper_crm.ods_oper_crm_active_gio_d_si 

 
-- 商城购物车
	select
	a.member_id `会员ID`,
	a.item_sku_id sku_id,
	a.item_spu_id spu_id,
	case when c.item_type = '51121001' then '沃尔沃精品'
		when c.item_type = '51121002' then '第三方卡券' 
		when c.item_type = '51121003' then '虚拟服务卡券' 
		when c.item_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
		when c.item_type = '51121006' then '一件代发'
		when c.item_type = '51121007' then '经销商端产品'
	    when c.item_type = '51121008' then '虚拟服务权益'
	    else null end `商品类型`,
	ifnull(f.`前台分类`,ifnull(case when d.name in('售后养护','充电专区','精品','生活服务') then d.name else null end,
	case when c.item_type = '51121001' then '精品'
		when c.item_type = '51121002' then '生活服务' 
		when c.item_type = '51121003' then '售后养护' 
		when c.item_type = '51121004' then '精品'    -- 还会新增一个子分类
		when c.item_type = '51121006' then '一件代发'
		when c.item_type = '51121007' then '经销商端产品'
	    when c.item_type = '51121008' then '售后养护'
	    else null end)) `前台分类`,
	case when b.boutique_type = 0 then '售后附件'
		else null end `精品二级分类`,
	a.count `加购数量`,
	case when a.select_status = 1 then '勾选'
		when a.select_status = 2 then '未勾选'
		else null end `是否勾选`,
	price/100/1.13 `商品不含税价格(元)`,
	a.name `商品名称`,
	case when a.delete_status = 1 then '未删除'
		when a.delete_status = 2 then '删除'
		else null end `是否删除`,
	case when a.delete_type = '1' then '用户主动删除'
		when a.delete_type = '2' then '下单删除'
		else null end `删除类型`,
	a.add_time `加购时间`,
	if(a.date_delete > '1970-01-01 08:00:00',a.date_delete,null) `删除时间`
	from ods_masi.ods_masi_cart_d a
	left join ods_good.ods_good_item_sku_d b on a.item_sku_id = b.id
	left join ods_good.ods_good_item_spu_d c on a.item_spu_id = c.id
	left join ods_good.ods_good_front_category_d d on d.id = c.front_category1_id     -- 前台专区列表(获取前台专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id,j.name `name`,f2.name as `前台分类`
		from ods_good.ods_good_item_spu_d j
		left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
		left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id
		left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
		where 1=1
		and f2.name='充电专区'
		and s.is_deleted ='0'
		and f2.is_deleted ='0'
	) f on f.spu_id = b.spu_id
	where 1=1
	and b.status <> '60291004'  -- 剔除已下架

--用户表
select
a.user
,b.id memberid
,b.is_vehicle
,min(case when (a.`$platform`in('iOS','Android','HarmonyOS') or a.var_channel='App') then a.client_time else null end) min_app
,max(case when (a.`$platform`in('iOS','Android','HarmonyOS') or a.var_channel='App') then a.client_time else null end) max_app
,min(case when (a.`$platform`in('MinP') or a.var_channel='Mini') then a.client_time else null end) min_mini
,max(case when (a.`$platform`in('MinP') or a.var_channel='Mini') then a.client_time else null end) max_mini
from ods_gio.ods_gio_event_d a
left join 
    (-- 清洗cust_id 取其对应的最新信息
    	select m.cust_id,m.is_vehicle,m.id
    	from
    	(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
    		select m.cust_id,m.is_vehicle,m.id,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
    		from ods_memb.ods_memb_tc_member_info_cur m
    		where m.cust_id is not null
    		and m.member_status <> '60341003' and m.is_deleted =0
    	)m
    	where m.rk=1
    )b on a.user=toString(b.cust_id)
where 1=1
and ((a.`$platform`in('iOS','Android','HarmonyOS') or a.var_channel='App') or (a.`$platform`in('MinP') or a.var_channel='Mini'))
and a.event_key not like 'Tech%'
and length(a.user)<9
group by 1,2,3
;

--活跃表
select 
a.user
,b.id memberid
,b.is_vehicle
,case when (a.`$platform`in('iOS','Android','HarmonyOS') or a.var_channel='App') then 'App' when (a.`$platform`in('MinP') or a.var_channel='Mini') then 'Mini' else null end as platform
,date(a.client_time) dt
from ods_gio.ods_gio_event_d a
left join 
    (-- 清洗cust_id 取其对应的最新信息
    	select m.cust_id,m.is_vehicle,m.id
    	from
    	(-- 按创建时间取最新,当创建时间相同时,按会员ID取最新
    		select m.cust_id,m.is_vehicle,m.id,row_number() over(partition by m.cust_id order by m.create_time desc,m.id desc) rk
    		from ods_memb.ods_memb_tc_member_info_cur m
    		where m.cust_id is not null
    		and m.member_status <> '60341003' and m.is_deleted =0
    	)m
    	where m.rk=1
    )b on a.user=toString(b.cust_id)
where 1=1
and date(a.event_time) >='2024-06-01'
and date(a.event_time) <'2024-06-05'
and a.event_key not like 'Tech%'
and length(a.user)<9
and ((a.`$platform`in('iOS','Android','HarmonyOS') or a.var_channel='App') or (a.`$platform`in('MinP') or a.var_channel='Mini'))
group by 1,2,3,4,5
;

-- 创建本地表  
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_cyh_em90_booking_snapshot_l_si on cluster default_cluster
(
    `SO_NO` String,
    `SO_NO_ID` UInt64,
    `SALE_TYPE` Int32,
    `SO_STATUS` Int32,
    `IS_DEPOSIT` Int32,
    `OWNER_CODE` String,
    `DELIVERY_OWNER_CODE` String,
    `RECEIVE_DATE` String,
    `SALES_DIST_NAME_CN` String,
    `SALES_AREA_NAME_CN` String
)
ENGINE = ReplicatedMergeTree
ORDER BY SO_NO  -- 根据主键排序
SETTINGS index_granularity = 8192;

-- 创建分布式表
CREATE TABLE if not exists ods_oper_crm.ods_oper_crm_cyh_em90_booking_snapshot_d_si on cluster default_cluster
(
    `SO_NO` String,
    `SO_NO_ID` UInt64,
    `SALE_TYPE` Int32,
    `SO_STATUS` Int32,
    `IS_DEPOSIT` Int32,
    `OWNER_CODE` String,
    `DELIVERY_OWNER_CODE` String,
    `RECEIVE_DATE` String,
    `SALES_DIST_NAME_CN` String,
    `SALES_AREA_NAME_CN` String
)
ENGINE = Distributed('default_cluster', 'ods_oper_crm', 'ods_oper_crm_cyh_em90_booking_snapshot_l_si', rand());
-- 括号内参数依次为：cluster集群名（表示服务器集群配置），数据库名，本地表名，在读写时会根据rand()随机函数的取值来决定数据写⼊哪个分⽚(分片key)


-- 创建本地表  
CREATE TABLE if not exists ods_oper_crm.cyh_test_local on cluster default
(
   `id` Int32,
   `user_name` String,
   `age` Int32
)
ENGINE = ReplicatedMergeTree
ORDER BY id  -- 根据主键排序
SETTINGS index_granularity = 8192;

-- 创建分布式表
CREATE TABLE if not exists ods_oper_crm.cyh_test_all on cluster default
AS ods_oper_crm.cyh_test_local
ENGINE = Distributed('default', 'ods_oper_crm', 'cyh_test_local', rand());
-- 括号内参数依次为：cluster集群名（不需要改），数据库名，本地表名，在读写时会根据rand()随机函数的取值来决定数据写⼊哪个分⽚


参考资料：
https://blog.csdn.net/qq_45956730/article/details/127794874

-- APP注册用户
	select count(distinct m.distinct_id)
	from ads_crm.ads_crm_events_member_d m
	where m.min_app_time is not null 
	and m.min_app_time>='2000-01-01'

-- MIni注册用户
	select count(distinct m.distinct_id)
	from ads_crm.ads_crm_events_member_d m
	where 1=1
	and m.min_app_time is null -- 剔除APP注册用户就是小程序注册用户

-- 2023APP 总数
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-10-15' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP车主总数
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-10-15' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1
--Settings allow_experimental_window_functions = 1

-- APP车主月度活跃数量
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-10-01' 
and time<'2023-10-15' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- Mini活跃数量
select date
,count(distinct distinct_id)
from ods_rawd_events_d_di
where date >= '2023-11-08' 
and date<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and ($lib='MiniProgram' or channel='Mini') -- Mini
group by date
order by date 
--and is_bind=1

-- 召回车主人数（促活）（App30天内未活跃车主会员）
select 
count(distinct a.user_id)
from
(-- 访问过活动的车主用户-App
select distinct a.user_id,distinct_id
from ods_rawd.ods_rawd_events_d_di a
where 1=1
and event='Page_entry'
and length(distinct_id)<9 
and date>='2023-10-18'
and date<'2023-11-01'
and page_title='10月商城亲子季'
and activity_name='2023年10月商城亲子季'
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and a.is_bind=1
)a
left join
(-- 注册会员
select distinct m.cust_id
from ods_memb.ods_memb_tc_member_info_cur m 
where m.member_status <> '60341003' and m.is_deleted =0 
and m.create_time >= '2023-10-18'
and m.create_time <'2023-11-01'
)b on a.distinct_id=b.cust_id::varchar
left join
(-- App 访问过活动前30天内活跃过的车主会员
select 
distinct a.user_id
from
	(-- 访问过活动的车主用户-App
	select a.user_id,`time`,time+ interval '-10 MINUTE' as `time1`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-10-18'
	and date<'2023-11-01'
	and page_title='10月商城亲子季'
	and activity_name='2023年10月商城亲子季'
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and a.is_bind=1
	)a 
join
	(--前30天内活跃用户
	select a.user_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and length(distinct_id)<9 
	and date>='2023-09-18'
	and date<'2023-11-01'
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	)b on a.user_id=b.user_id
where a.`time`+ interval '-30 day'<= b.`time` and b.`time`<a.`time1`
)c on a.user_id=c.user_id
where 1=1
and b.cust_id is null -- 剔除新用户
and c.user_id =0 -- 剔除访问活动前30天内活跃过的车主会员

-- App 访问过活动前30天内活跃过的车主会员
	select 
	a.distinct_id
	,a.t `参加活动时间`
	,b.t `浏览app时间`
	,abs(datediff('day',a.t,b.t))
	from
		(-- 访问过活动的车主用户-App
		select a.distinct_id ,`time` as t
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-10-18'
		and date<'2023-11-01'
		and page_title='10月商城亲子季'
		and activity_name='2023年10月商城亲子季'
		and a.channel='App'
		and a.is_bind=1
		)a 
    join
		(--前30天内活跃车主用户
		select a.distinct_id,`time` as t
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2023-09-18'
		and date<'2023-11-01'
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and a.is_bind=1
		)b on toString(a.distinct_id)=toString(b.distinct_id) 
	where a.t+ interval '-30 day'<= b.t and b.t<a.t
--	where a.time+ interval '-30 day'>= b.`time` and b.`time`<a.time




-- 拉新人数（App/Mini注册会员）
select 
count(distinct a.user_id)
from
	(-- 访问过活动的用户-App/Mini
	select a.user_id,distinct_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-10-18'
	and date<'2023-11-01'
	and page_title='10月商城亲子季'
	and activity_name='2023年10月商城亲子季'
	and a.channel='App' --'Mini'
)a 
join
	(-- 注册会员
	select distinct m.cust_id,m.create_time
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	--and m.member_source = '60511003' -- 首次注册app用户
	and m.create_time >= '2023-10-18'
	and m.create_time <'2023-11-01'
)b on a.distinct_id=b.cust_id::varchar
where toDateTime(a.time)-toDateTime(b.create_time)<=600 
and toDateTime(a.time)-toDateTime(b.create_time)>=-600



-- 车主活跃率
select num2/num1
from (
-- 车主数量
	select '1'a,count(distinct distinct_id) num1 
	from ods_rawd_events_d_di
	where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and time >= '2022-02-01' 
	and time<'2022-10-15' 
	and length(distinct_id)<9
	and distinct_id not like '%#%'
	and is_bind=1)a
left join 
-- 每月活跃数量
	(select '1'b,count(distinct distinct_id) num2 
	from ods_rawd_events_d_di
	where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and time >= '2022-10-01' 
	and time<'2022-10-15' 
	and length(distinct_id)<9
	and distinct_id not like '%#%'
	and is_bind=1)b on a.a=b.b

-- 新增用户 分天mini
select x.t
,count(distinct x.cust_id)
from 
	(
	select 
	toString(m.cust_id) as cust_id,
	min(toDate(t.`date`)) t
	from ods_trac.ods_trac_track_cur t 
	join ods_memb.ods_memb_tc_member_info_cur m on toString(m.user_id ) =toString(t.usertag) 
	where m.is_deleted = 0 
	and m.member_status <> '60341003'
	group by cust_id
	union all 
	select 
	toString(distinct_id) as cust_id,
	min(toDate(date)) t
	from ods_rawd_events_d_di
	where length(distinct_id)<=9
	and ($lib='MiniProgram' or channel='Mini') -- Mini
	group by distinct_id
)x
group by t
order by t

-- 新增用户 分时段mini
select x.t
,count(distinct x.cust_id)
from 
	(
	select 
	toString(m.cust_id) as cust_id,
	min(formatDateTime(toDateTime(t.`date`),'%H')) t
--	min(formatDateTime(toDateTime(t.`date`),'%Y-%m-%d %H')) t
	from ods_trac.ods_trac_track_cur t 
	join ods_memb.ods_memb_tc_member_info_cur m on toString(m.user_id ) =toString(t.usertag) 
	where m.is_deleted = 0 
	and m.member_status <> '60341003'
	group by cust_id
	union all 
	select 
	toString(distinct_id) as cust_id,
	min(formatDateTime(toDateTime(date),'%H')) t
	from ods_rawd_events_d_di
	where length(distinct_id)<=9
	and ($lib='MiniProgram' or channel='Mini') -- Mini
	group by cust_id
)x
group by t
order by t
	
-- 新增用户-- 分天
select x.t
,count(distinct x.distinct_id)
from 
	(
	select 
	distinct_id,
	min(date) t
	from ods_rawd_events_d_di
	where length(distinct_id)<=9
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') -- App
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	and date<'2023-10-17'
	group by distinct_id
)x
group by t
order by t

-- 新增用户-- 分时段
select toHour(x.t) t
,count(distinct distinct_id)
from 
	(
	select 
	distinct_id,
	min(time) t
	from ods_rawd_events_d_di
	where length(distinct_id)<=9
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') -- App
--	and ($lib='MiniProgram' or channel='Mini') -- Mini
	and date<'2023-10-17'
	group by distinct_id
)x
group by t
order by t 

-- 日活 app mini
select date t
,count(distinct distinct_id) 
from ods_rawd_events_d_di 
where 1=1
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
and time >= '2022-02-01' 
and time<'2023-10-15' 
and distinct_id not like '%#%'
and length(distinct_id)<9
group by t  
order by t

-- 日累计访问次数 app mini
select date t
,count(distinct_id) 
from ods_rawd_events_d_di 
where 1=1
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
and time >= '2022-02-01' 
and time<'2023-10-15' 
and distinct_id not like '%#%'
and length(distinct_id)<9
group by t  
order by t

-- 日累计访问次数 mini
select date_format(date,'%Y-%m-%d') t
,count(usertag) 
from track.track t 
group by 1
order by 1

--分时段活跃 app mini
select toHour(time) t
,count(distinct_id) `访问次数`
,count(distinct distinct_id) `活跃人数`
from ods_rawd_events_d_di 
where 1=1
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
and time >= '2022-02-01' 
and time<'2023-10-15' 
and distinct_id not like '%#%'
and length(distinct_id)<9
group by t  
order by t

-- 车主日活
select 
-- date_trunc('month',x.date)
avg(x.num) num
from 
  (
  select 
  date
  ,count(distinct distinct_id) num
  from ods_rawd_events_d_di
  where 1=1
  and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
  and time >= '2023-10-01' 
  and time<'2023-10-15' 
  and length(distinct_id)<9
  and distinct_id not like '%#%'
  and is_bind=1
  group by date
  )x

  
--30日启动天数分布
SELECT x.num,
count(distinct distinct_id)
from 
(
  select distinct_id,
  count(distinct date) num
  from ods_rawd_events_d_di
  where 1=1
  and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
  and time >= date(now()) - INTERVAL '30 day ' 
  and time < date(now())
  and length(distinct_id)<9
  and distinct_id not like '%#%'
  group by distinct_id)x
group by num
order by num 
  
--30日平均单日使用时长（秒）
select x.tt
,round(avg(x.num),2)
from 
	(
	-- 每人近30日每天的平均时长
	select x.tt,
	x.user_id,
	avg(x.view_dur) num
	from 
	(
	 -- 每个用户每天的汇总浏览时长
     	 select t.user_id
	     ,t.date tt
	     ,sum(t.view_dura) view_dur
	     from
			 (
			-- 每个用户每天每次的浏览时长
			select user_id
			,$lib
			,$app_version
			,$event_duration as view_dura
			,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in ('$AppEnd','$MPHide')
			and $event_duration is not null
			and time >= date(now()) - INTERVAL '30 day ' 
			and time < date(now())
			) t
	      group by t.user_id,t.date
	 )x group by x.tt,x.user_id
)x group by x.tt
order by x.tt

-- 全埋点事件用$event_duration
select event
,$event_duration
,view_duration
,user_id
,$lib
,$app_version
from ods_rawd_events_d_di
where event in ('$AppEnd','$MPHide')
and date='2023-10-17'

-- 查看版本号
select distinct $lib,$app_version
from ods_rawd_events_d_di
where 1=1
--and $app_version>'5.17.6'
order by $app_version

--30日平均单日使用时长（秒）
select t.date tt
,avg(t.view_dura) view_dur
from
	(
	-- 每个用户每天每次的浏览时长
	select user_id
	,$lib
	,$app_version
	,$event_duration as view_dura
	,date
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event in ('$AppEnd','$MPHide')
	and $event_duration is not null
	and time >= date(now()) - INTERVAL '30 day ' 
	and time < date(now())
) t
group by t.date
order by t.date

--7日人均浏览深度
--7日平均浏览深度
--单日/7日/30日浏览页面数分布
select user_id 
,count(distinct page_title)`浏览页面数量`
,count(page_title) `浏览页面次数`
from ods_rawd.ods_rawd_events_d_di
where view_duration is not null
and event ='Page_view'
and time >= date(now()) - INTERVAL '30 day ' 
and time < date(now())
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and ($lib='MiniProgram' or channel='Mini') -- Mini
group by user_id

--老客户消费频率
--老客户平均消费金额
--老客户重复购买次数
--用户负面评价/差评数
 
select distinct $lib,appname ,channel 
from ods_rawd_events_d_di 

  
 --浏览时长中位数
-- 每天每个用户浏览时长进行排序
select avg(x.num)
from 
	(
	select x.tt,
	quantile(x.view_dur) num
	from 
	(
	 -- 每个用户每天的汇总浏览时长
	      select t.user_id
	      ,t.date tt
	      ,sum(t.view_dura) view_dur
	      from
	        (
			-- 每个用户每天每次的浏览时长
			select user_id
			,$lib
			,$app_version
			,case when view_duration is null then null
			when $lib ='MiniProgram' and $app_version is null then null
			when view_duration <=0 then 0   --- 小于等于0的数据全部清洗为0 
		    when view_duration>300000 then 5   --- 超过300000全部清洗为5，不论版本和端口
		    when $app_version <'5.17.6' and view_duration>300 then 5  -- app5.17.6版本及以后得浏览时长单位均是s(秒)
			when (($app_version >='5.17.6' -- app 5.17.6版本及以后得浏览时长单位均是ms ，所以除以1000
				and $lib in ('iOS','Android'))						
				or $lib in ('MiniProgram','js'))						-- 小程序浏览时长单位均是ms，js端的浏览时长均是ms，均除以1000
				and view_duration<=300000
			then view_duration/1000
			else view_duration
			end as view_dura
			,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in ('Page_view','Page_entry') 
        	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
			and view_duration is not null
			and time >= date(now()) - INTERVAL '30 day ' 
			and time < date(now())
			) t
	      group by t.user_id,t.date
	 )x group by x.tt
)x
  
-- 每个用户每天每次的浏览时长
select user_id
,$lib
,$app_version
,case when view_duration is null then null
when view_duration <=0 then 0   --- 小于等于0的数据全部清洗为0 
when view_duration>300000 then 5   --- 超过300000全部清洗为5，不论版本和端口
when $app_version <'5.17.6' and view_duration>300 then 5  -- app5.17.6版本以前浏览时长单位均是s(秒)
when (($app_version >='5.17.6' -- app 5.17.6版本及以后得浏览时长单位均是ms ，所以除以1000
	and $lib in ('iOS','Android'))						
	or $lib in ('MiniProgram','js'))						-- 小程序浏览时长单位均是ms，js端的浏览时长均是ms，均除以1000
	and view_duration<=300000
then view_duration/1000
else view_duration
end as view_dura
,date
from ods_rawd.ods_rawd_events_d_di
where 1=1
and view_duration is not null
and time >= date(now()) - INTERVAL '30 day ' 
and time < date(now()) 

-- 总站销售额
-- 销售概览分类型 活动引流
select 
date_trunc('month',m.tt) tt 
,m.fl
,SUM(m.`总金额`) `GMV汇总`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,x.distinct_id
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
,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end `商品类型`
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
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品'
		WHEN 51121002 THEN 'VOLVO仓第三方卡券'
		WHEN 51121003 THEN '虚拟服务卡券'
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
	,CASE b.status
			WHEN 51301001 THEN '待付款'
			WHEN 51301002 THEN '待发货'
			WHEN 51301003 THEN '待收货'
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭' 
	END AS `商品状态`
	,CASE a.status
			WHEN 51031002 THEN '待付款'
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS `订单状态`
	,CASE a.close_reason 
	WHEN 51091003 THEN '用户退款' 
	WHEN 51091004 THEN '用户退货退款' 
	WHEN 51091005 THEN '商家退款' END AS `关闭原因`
	,e.`退货状态` `退货状态`
	,e.`退货数量` `退货数量`
	,e.`退回V值` `退回V值`
	,e.`退回时间` `退回时间`
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
	join (
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
					'11月会员日','沃尔沃汽车服务节','WOW商城·双11' -- 11
--					'10月商城亲子季','10月会员日','WOW商城·双11'  -- 10
--					'WOW商城-开箱季','9月会员日','WOW商城-开学季'  -- 9月
--					'WOW商城-开学季','8月会员日','夏服活动'   -- 8月
--					'7月会员日','WOW商城-消暑季','夏服活动'    -- 7月
--					'6月会员日','618活动'  --6月
		--			'525车主节',  --  5月
--					'4月会员日','商城出行季活动' -- 4月
--					'3月会员日' ,'沃的好物 魅力季' -- 3月
--					'2月会员日' ,'沃的好物 魅力季','情人节活动'  -- 2月
--					'1月会员日','好物迎春 献礼新岁'  -- 1月
					) 
--				and activity_name='2023年5月车主节活动'--  5月
				)
			and date>='2023-11-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
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
	and toDate(a.create_time) >= '2023-11-01' 
	and toDate(a.create_time) <'2023-12-01'   -- 订单时间
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
group by tt,fl
order by tt,fl desc 

	-- 养修预约
	select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.company_name_cn "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.id "会员ID",
       tmi.member_phone "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then'是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
       ta."CREATED_AT" "预约时间",
       tam.WORK_ORDER_NUMBER "工单号",
       case when x.APPOINTMENT_ID is not null then '是' else '否' end as `是否通过活动养修预约`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	left join 
		(-- 浏览过活动页面&提交养修预约工单数量
		select distinct x.APPOINTMENT_ID as APPOINTMENT_ID
		from ods_rawd.ods_rawd_events_d_di a
		global join (
			-- 养修预约
			select 
			       ta.ONE_ID as one_id,
			       tmi.id "会员ID",
			       ta.APPOINTMENT_ID as APPOINTMENT_ID 
			from ods_cyap.ods_cyap_tt_appointment_d ta 
			left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
			left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
			left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
			left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
			where 1=1
			and tam.IS_DELETED <>1
			and ta.CREATED_AT >= '2023-12-01'
			and ta.CREATED_AT <'2023-12-15'
			and ta.DATA_SOURCE ='C'
			and ta.APPOINTMENT_TYPE =70691005
		)x on toString(a.distinct_id)=toString(x.one_id) 
		where 1=1
		and event='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-12-01'
		and date<'2023-12-15'
		and page_title='忠诚车主回厂活动')x on toString(x.APPOINTMENT_ID) =toString(ta.APPOINTMENT_ID) 
	where 1=1
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2023-12-01'
	and ta.CREATED_AT <'2023-12-15'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂


-- 邀约试驾 当月总留资量
SELECT 
t2.code `邀约code`, 
	t2.member_id `邀请人会员ID`,
	tmi.member_phone  `邀请人手机号`,
	t2.create_time `邀约时间`,
	t1.be_invite_member_id `被邀请人会员ID`,
	t1.be_invite_mobile `被邀请人会员手机号`,
	t1.reserve_time `留资时间`,
	t1.be_invite_mobile `被邀请人手机号`,
	t1.vehicle_name `留资车型`,
	t1.drive_time `实际试驾时间`,
	tmi.cust_id as distinct_id
FROM ods_invi.ods_invi_tm_invite_code_d t2
left join ods_invi.ods_invi_tm_invite_record_d t1 on t1.invite_code = t2.code 
left join ods_memb.ods_memb_tc_member_info_cur tmi on t2.member_id = tmi.id
WHERE t2.create_time >='2024-01-25' 
and t2.create_time <'2024-01-26'

-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID `预约ID`,
	ta.CREATED_AT `预约时间`,
	ta.ARRIVAL_DATE `实际到店日期`,
	ca.active_name `活动名称`,
	ta.ONE_ID `客户ID`,
	ta.CUSTOMER_NAME `姓名`,
	ta.CUSTOMER_PHONE `手机号`,
	tm2.model_name `预约车型`,
	h.`大区` as `大区`,
	h.`小区` as `小区`,
	ta.OWNER_CODE `经销商`,
	CASE tad.STATUS
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END `试驾状态`,
	tad.DRIVE_S_AT `试驾开始时间`,
	tad.DRIVE_E_AT `试驾结束时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON toString(tc.CODE_ID)  = toString(ta.IS_ARRIVED)
	LEFT JOIN ods_cyap.ods_cyap_tt_appointment_drive_d tad ON toString(tad.APPOINTMENT_ID) = toString(ta.APPOINTMENT_ID )
	LEFT JOIN ods_cydr.ods_cydr_tt_sales_orders_cur tso ON toString(tso.customer_business_id) = toString(ta.CUSTOMER_BUSINESS_ID)
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON toString(ca.uid) = toString(ta.CHANNEL_ID )
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc1 ON toString(tc1.CODE_ID) = toString(tso.so_status)
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.company_code as company_code,
	        tg2.ORG_NAME `大区`,
	        tg1.ORG_NAME `小区`
	    from ods_orga.ods_orga_tm_company_cur tm
	     JOIN ods_orga.ods_orga_tr_org_d tr1 ON tr1.org_id = tm.org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg1 ON tg1.ID = tr1.parent_org_id 
	     JOIN ods_orga.ods_orga_tr_org_d tr2 ON tr2.org_id = tr1.parent_org_id
	     JOIN ods_orga.ods_orga_tm_org_d tg2 ON tg2.ID = tr2.parent_org_id 
	    where tm.is_deleted = 0 
	    AND tm.company_type = 15061003 
	    and tg1.ORG_TYPE = 15061007 
	    and tg2.ORG_TYPE = 15061005 
	    ORDER BY tm.company_code ASC) h on toString(h.company_code) = toString(ta.OWNER_CODE)
	left join ods_bada.ods_bada_tm_model_cur tm2 on toString(tad.THIRD_ID) = toString(tm2.id )
	WHERE ta.CREATED_AT >= '2023-01-01'
	AND ta.CREATED_AT <'2023-12-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tm2.is_deleted = 0
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT

-- 
CREATE TABLE IF NOT EXISTS app_chenshui
ENGINE = Log() -- 这里使用MergeTree存储引擎作为示例，你可以根据需要选择其他存储引擎 Memory 存储引擎：将数据存储在内存中，适用于需要快速访问的小型数据集。
AS
	select cast(distinct_id as int) did
	,time
	,is_bind
--	,m.is_vehicle
	,row_number() over(partition by distinct_id order by time desc) num
	from ods_rawd_events_d_di t
--	left join ods_memb.ods_memb_tc_member_info_cur m on m.cust_id =t.distinct_id
	where ($lib in('iOS','Android') or channel ='App')
	and event in('$AppStart','$AppInstall','$AppStartPassively','$AppDeepLinkLaunch','$AppViewScreen')
	and time >= '2022-08-01' 
	and time<'2022-09-01' 
	and length(distinct_id)<9
	and left($app_version,1)>='5' 
	and distinct_id not like '%#%'
	Settings allow_experimental_window_functions = 1






--如何处理窗口函数问题
Settings allow_experimental_window_functions = 1


--下订时间
select tmi.cust_id 
FROM ods_cydr.ods_cydr_tt_sales_orders_cur a
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur b on toString(a.so_no) = toString(b.vi_no) 
left join ods_cydr.ods_cydr_tt_sales_order_detail_d c on toString(c.SALES_OEDER_DETAIL_ID) = toString(b.sales_oeder_detail_id) 
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.customer_tel) =toString(tmi.member_phone ) 
WHERE b.sale_type = 20131010 -- 预售
and a.is_deposit='10421009' -- 付定金
and a.created_at >= '2023-01-01'      
and a.created_at < '2024-01-01'
and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
and a.is_deleted =0
and b.is_deleted =0
and tmi.id is not null 
and tmi.is_deleted = 0 
and tmi.member_status <> '60341003'
order by 1