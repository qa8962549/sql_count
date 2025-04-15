-- 1-8-1 
-- APP iOS用户（这里需要在神策平台上面跑数，然后把结果导出来，导出来以后再和现在的NB会员表里面的Cust_ID关联，获取会员ID）
select distinct distinct_id 
from events 
where $lib = 'iOS'
and time between '2022-02-01' and '2023-01-03 23:59:59'
and length(distinct_id) < 9


-- 1-8人群包
-- 1-8-1 App全量IOS用户
select
distinct distinct_id
from events where $lib = 'iOS'
and time between '2022-02-01' and '2023-01-04 15:00:00'
and length(distinct_id)<9


-- 1-8-2 App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。为防止1个oneid对应多个手机号的情况出现，如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select
distinct distinct_id
from events where $lib in ('iOS','Android')
and time between '2022-02-01' and '2023-01-04 15:00:00'
and length(distinct_id)<9
and distinct_id not in
(
	select
	distinct distinct_id
	from events where $lib = 'iOS'
	and time between '2022-02-01' and '2023-01-04 15:00:00'
	and length(distinct_id)<9
)

-- 1-8-3 全平台银卡及以上用户
select
DISTINCT IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
from `member`.tc_member_info m
left join `member`.tc_member_info_phone_repetition r on m.ID = r.MEMBER_ID and r.IS_DELETED = 0
where m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0
and m.MEMBER_LEVEL >= 2
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' -- 排除无效手机号


-- 1-8-4 小程序最新活跃的粉丝2W+车主2W，总共需要4W.车主不要与1-9-2重复
-- 车主
select 
DISTINCT m.id 会员ID,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号
from track.track t 
join 
(select t.usertag,max(t.`date`) max_date
 from track.track t
 group by 1) a on a.usertag = t.usertag
join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar) and m.IS_VEHICLE = 1
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
where m.is_deleted = 0 and m.member_status <> 60341003
and (a.max_date <= '2023-01-04 15:00:00' or a.max_date is null)   -- 活跃时间最新
and (a.max_date > m.MEMBER_TIME or a.max_date is null)
order by a.max_date desc
limit 100000

-- 粉丝
select 
DISTINCT m.id 会员ID,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号
from track.track t 
join 
(select t.usertag,max(t.`date`) max_date
 from track.track t
 group by 1) a on a.usertag = t.usertag
join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar) and m.IS_VEHICLE <> 1
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
where m.is_deleted = 0 and m.member_status <> 60341003
and (a.max_date <= '2023-01-04 15:00:00' or a.max_date is null)   -- 活跃时间最新
and (a.max_date > m.MEMBER_TIME or a.max_date is null)
order by a.max_date desc
limit 100000



-- 1-5-1 12月开票车主
select distinct eco.open_id 微信公众号Open_ID
from (
 select
  a.MEMBER_PHONE 手机号,
  IFNULL(c.union_id,u.unionid) allunionid
 from vehicle.tt_invoice_statistics_dms t1 
 inner join member.tc_member_vehicle t2 
 on t1.vin = t2.vin
 and substr(first_invoice_date, 1, 7) = '2022-12' 
 and t2.is_deleted = 0 
 inner join `member`.tc_member_info a    -- 会员表作为主表
 on t2.member_id = a.id
 left join customer.tm_customer_info c on c.id=a.cust_id
 left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=a.old_memberid and u.unionid <> '00000000'
 where a.MEMBER_TIME <= '2023-01-09 15:00:00' 
 and a.MEMBER_STATUS <> 60341003
 and a.IS_DELETED = 0
 ) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''





-- 1-7-1 App全量IOS用户
select
distinct distinct_id
from events where $lib = 'iOS'
and time between '2022-02-01' and '2023-01-09 16:30:00'
and length(distinct_id)<9


-- 1-7-3
以下6项行为，有过3项及以上的用户
1、过去一年中，累计签到10天以上
2、过去一年中，进行过养修预约
3、过去一年中，进行过预约试驾
4、在商城有过历史购买记录
5、过去一年中，参加过任意会员日活动

select b.id,b.MEMBER_PHONE, count(distinct act_type)
from
(
	select
	si.member_id,
	'签到' as act_type
	from mine.sign_info si
	where si.year_int = '2022'
	and si.is_delete = 0
	GROUP BY 1
	having count(distinct time_str) > 10
	union 
	select tmi.id member_id, case when APPOINTMENT_TYPE = 70691005 then '养修' else '试驾' end as act_type
	from cyx_appointment.tt_appointment ta
	inner join member.tc_member_info tmi 
	on ta.ONE_ID = tmi.CUST_ID 
	where APPOINTMENT_TYPE in (70691002, 70691005)
	union 
	select a.user_id, '商城' as act_type
	from order.tt_order a
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join 
	(
	#V值退款成功记录
	SELECT a.*,b.refund_express_code,b.eclp_rtw_no
	from (
	select so.refund_order_code,so.order_code,sp.product_id
	,CASE so.status 
		WHEN 51171001 THEN '待审核' 
		WHEN 51171002 THEN '待退货入库' 
		WHEN 51171003 THEN '待退款' 
		WHEN 51171004 THEN '退款成功' 
		WHEN 51171005 THEN '退款失败' 
		WHEN 51171006 THEN '作废退货单' END AS 退货状态
	,sum(sp.sales_return_num) 退货数量
	,sum(so.refund_point) 退回V值
	,max(so.create_time) 退回时间
	from `order`.tt_sales_return_order so
	left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
	where so.is_deleted = 0 
	and so.status=51171004 -- 退款成功
	GROUP BY 1,2,3,4) a
	left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	union
	select DISTINCT tmi.ID member_id, '会员日' as act_type
	from track.track t 
	join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` >= '2022-01-25'
	and t.`date` <= '2022-12-25 23:59:59'
	and (json_extract(t.`data`,'$.embeddedpoint') in ('memberDay_home_ONLOAD' , 'memberDay2_home_onload', 'memberDay3_home_onload', 'memberDay4_home_onload',
	'memberDay5_home_onload', 'memberDay6_home_onload', 'memberDay7_home_onload', 'memberDay8_home_onload', 'memberDay9_home_onload',
	'memberDay10_home_onload','memberDay11_home_onload', 'memberDay12_home_onload', 'memberDay12_home_miniProgram_onload', 'memberDay12_home_app_onload'))
) a 
inner join member.tc_member_info b 
on a.member_id = b.id
and b.is_deleted = 0
and b.MEMBER_STATUS <> 60341003
GROUP BY 1,2
having count(distinct act_type) >= 3



-- 1-7-4 拥有爱心大使or特邀发言官or品牌大使勋章的用户
select
DISTINCT IF(d.member_phone='*',r.MEMBER_PHONE,d.member_phone) 手机号
from mine.madal_detail c
left join `member`.tc_member_info d on d.ID = c.user_id
left join `member`.tc_member_info_phone_repetition r on d.ID = r.MEMBER_ID and r.IS_DELETED = 0
left join mine.user_medal e on e.id = c.medal_id
left join `member`.tc_level f on f.LEVEL_CODE = d.MEMBER_LEVEL
left join mine.my_medal_type g on e.`type` = g.union_code
where c.create_time <= '2023-01-09 16:30:30'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name in ('爱心大使','特邀发言官','品牌大使')


-- 1-7-5 过去3个月没有过小程序/App活跃的用户

-- 小程序端未活跃
select distinct 手机号
from (
	select
	  IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号, a.max_date
	from track.track t 
	join (
		select t.usertag,max(t.`date`) max_date
		from track.track t 
		group by 1
		) a 
	on a.usertag = t.usertag
	left join member.tc_member_info m on t.usertag = cast(m.USER_ID as varchar)
	left join `member`.tc_member_info_phone_repetition r on m.ID = r.MEMBER_ID and r.IS_DELETED = 0
	where m.is_deleted = 0 and m.member_status <> 60341003
	and (a.max_date <= DATE_SUB('2023-01-09 16:30:00',INTERVAL 6 MONTH) or a.max_date is null)
	-- and (a.max_date <= '2023-01-09 16:30:00' or a.max_date is null)
	and (a.max_date > m.MEMBER_TIME or a.max_date is null)
	order by a.max_date desc
	) a 
limit 500000

-- APP端未活跃 
-- 神策平台取数
select distinct distinct_id
from events 
where $lib in('iOS','Android') 
and time between '2022-02-01' 
and '2023-01-09 17:30:00' 
and distinct_id not in
(
  select distinct distinct_id
  from events 
  where $lib in('iOS','Android') 
  and time between '2022-10-09 17:30:00' 
  and '2023-01-09 17:30:00'
)
and length(distinct_id)<9;



-- 1-2人群包
-- 1-2-1 车主：近30天将有大额过期积分，23年2月1号即将过期V值总和大于等于1,500 V值的人
select * from
(
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
		f.会员ID,
		f.手机号,
		f.是否车主,
		f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',
		f.'截止T月累计消耗V值',
		f.'截止T月累计过期V值',
		f.'用户当前剩余V值',
		CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
			WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
			END '第一个月预测过期V值数'
	from (	
		select 
			f.'会员ID',
			f.'手机号',
			f.'是否车主',
			f.'截止T-24月累计发放V值',
			f.'T-24月当月发放V值',
			f.'截止T月累计消耗V值',
			f.'截止T月累计过期V值',
			f.'用户当前剩余V值',
			CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
				WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
				ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
				END '第一个月预测过期V值数'
		from (
			select
				f.MEMBER_ID '会员ID',
				IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
				m.IS_VEHICLE '是否车主',
				IFNULL(SUM(case when f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) '截止T-24月累计发放V值',          -- 截止到2022.1.31 23:59:59发放的V值
				IFNULL(SUM(case when f.CREATE_TIME >= '2021-01-01' and f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) 'T-24月当月发放V值',       -- 2021.1.1 ~ 2021.1.31 23:59:59发放的V值
				IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else null end),0) '截止T月累计消耗V值',       -- 截止到取数时，用户累计消耗V值
				IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else null end),0) '截止T月累计过期V值',       -- 截止到取数时，用户累计过期V值
				IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left JOIN `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
			) f
		) f
	) f
where f.是否车主 = 1 and f.第一个月预测过期V值数 >= 1500


-- 1-2-2 粉丝：近30天将有大额过期积分，23年2月1号即将过期V值总和大于等于1,500 V值的人
select * from
(
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
	f.会员ID,
	f.手机号,
	f.是否车主,
	f.'截止T-24月累计发放V值',
	f.'T-24月当月发放V值',
	f.'截止T月累计消耗V值',
	f.'截止T月累计过期V值',
	f.'用户当前剩余V值',
	CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
		WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
		END '第一个月预测过期V值数'
	from
	(	
		select 
		f.'会员ID',
		f.'手机号',
		f.'是否车主',
		f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',
		f.'截止T月累计消耗V值',
		f.'截止T月累计过期V值',
		f.'用户当前剩余V值',
		CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
			WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
			ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
			END '第一个月预测过期V值数'
		from
		(
			select
			f.MEMBER_ID '会员ID',
			IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
			m.IS_VEHICLE '是否车主',
			IFNULL(SUM(case when f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) '截止T-24月累计发放V值',          -- 截止到2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME >= '2021-01-01' and f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) 'T-24月当月发放V值',       -- 2021.1.1 ~ 2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else null end),0) '截止T月累计消耗V值',       -- 截止到取数时，用户累计消耗V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else null end),0) '截止T月累计过期V值',       -- 截止到取数时，用户累计过期V值
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left join `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
		) f
	) f
) f
where f.是否车主 = 0 and f.第一个月预测过期V值数 >= 1500


-- 1-2-3 车主：近30天将有小额过期积分， 23年2月1号即将过期V值总和大于0且小于1,500 V值的人
select * from
(
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
	f.会员ID,
	f.手机号,
	f.是否车主,
	f.'截止T-24月累计发放V值',
	f.'T-24月当月发放V值',
	f.'截止T月累计消耗V值',
	f.'截止T月累计过期V值',
	f.'用户当前剩余V值',
	CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
		WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
		END '第一个月预测过期V值数'
	from
	(	
		select 
		f.'会员ID',
		f.'手机号',
		f.'是否车主',
		f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',
		f.'截止T月累计消耗V值',
		f.'截止T月累计过期V值',
		f.'用户当前剩余V值',
		CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
			WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
			ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
			END '第一个月预测过期V值数'
		from
		(
			select
			f.MEMBER_ID '会员ID',
			IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
			m.IS_VEHICLE '是否车主',
			IFNULL(SUM(case when f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) '截止T-24月累计发放V值',          -- 截止到2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME >= '2021-01-01' and f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) 'T-24月当月发放V值',       -- 2021.1.1 ~ 2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else null end),0) '截止T月累计消耗V值',       -- 截止到取数时，用户累计消耗V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else null end),0) '截止T月累计过期V值',       -- 截止到取数时，用户累计过期V值
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left JOIN `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
		) f
	) f
) f
where f.是否车主 = 1
and f.第一个月预测过期V值数 > 0
and f.第一个月预测过期V值数 < 1500


-- 1-2-4 粉丝：近30天将有小额过期积分， 23年2月1号即将过期V值总和大于0且小于1,500 V值的人
select * from
(
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
	f.会员ID,
	f.手机号,
	f.是否车主,
	f.'截止T-24月累计发放V值',
	f.'T-24月当月发放V值',
	f.'截止T月累计消耗V值',
	f.'截止T月累计过期V值',
	f.'用户当前剩余V值',
	CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
		WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
		END '第一个月预测过期V值数'
	from
	(	
		select 
		f.'会员ID',
		f.'手机号',
		f.'是否车主',
		f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',
		f.'截止T月累计消耗V值',
		f.'截止T月累计过期V值',
		f.'用户当前剩余V值',
		CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
			WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
			ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
			END '第一个月预测过期V值数'
		from
		(
			select
			f.MEMBER_ID '会员ID',
			IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
			m.IS_VEHICLE '是否车主',
			IFNULL(SUM(case when f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) '截止T-24月累计发放V值',          -- 截止到2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME >= '2021-01-01' and f.CREATE_TIME < '2021-02-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) 'T-24月当月发放V值',       -- 2021.1.1 ~ 2021.1.31 23:59:59发放的V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else null end),0) '截止T月累计消耗V值',       -- 截止到取数时，用户累计消耗V值
			IFNULL(SUM(case when f.CREATE_TIME <= '2023-01-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else null end),0) '截止T月累计过期V值',       -- 截止到取数时，用户累计过期V值
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left join `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
		) f
	) f
) f
where f.是否车主 = 0
and f.第一个月预测过期V值数 > 0
and f.第一个月预测过期V值数 < 1500
;



-- 1-9-3 2022活跃车主
select distinct tt.手机号, '1-9-3' as '人群包'
from (
	select m.id 会员ID
		,IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
		,t.max_date
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where (t.date >= '2022-01-01' and t.date < '2023-01-01') or t.date is null 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	left join `member`.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0
	where t.max_date > m.MEMBER_TIME or t.max_date is null
	order by t.max_date desc 
	) tt 
;



-- 1-9-4 近半年新绑定车主
select distinct 手机号
from (
	select d.vin
		,v.MEMBER_ID
		,IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
		,d.invoice_date
	from vehicle.tt_invoice_statistics_dms d
	inner join member.tc_member_vehicle v 
	on d.vin = v.VIN 
	and v.IS_DELETED = 0 and d.IS_DELETED = 0
	and d.invoice_date < '2023-01-13 14:30:00' and d.invoice_date >= '2022-07-13 14:30:00'
	inner join member.tc_member_info m 
	on v.MEMBER_ID = m.ID and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	left join member.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0	
	order by d.invoice_date desc
	) t
;


-- 年度回顾H5总PV、总UV
select
DISTINCT tmi.ID 会员ID
from track.track t  
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2023-01-10'
and t.`date` <= '2023-01-10 23:59:59'
and json_extract(t.`data`,'$.embeddedpoint') = 'yearReview_太阳码_ONLOAD'


-- 1-1-2  新注册会员
select distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
where tmi.MEMBER_TIME >= '2023-01-03'
and tmi.MEMBER_TIME <= '2023-01-15 23:59:59'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号




-- 1-6-3 V值余额大于1000的用户
select distinct 手机号
from (
	select
		m.id '会员ID',
		IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
		IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
	from `member`.tc_member_info m
	left join `member`.tc_member_info_phone_repetition p 
	on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	) f
where 用户当前剩余V值 > 1000
;



-- 1-3-2 已点亮WOW辈楷模电子勋章的用户
select DISTINCT IF(d.member_phone='*',r.MEMBER_PHONE,d.member_phone) 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
left join `member`.tc_member_info_phone_repetition r on d.ID = r.MEMBER_ID and r.IS_DELETED = 0
left join mine.user_medal e on e.id = c.medal_id
where c.create_time <= '2023-01-17 13:30:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name = 'WOW辈楷模'


-- 1-3-4 近半年登录过小程序，但从未登录过App的车主（取30万）
select distinct tt.手机号
from (
	select m.id 会员ID
		,m.cust_id
		,IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
		,t.max_date
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where (t.date >= '2022-07-17' and t.date < '2023-01-17') or t.date is null 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	left join `member`.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0
	where t.max_date > m.MEMBER_TIME or t.max_date is null
	order by t.max_date desc 
	) tt 
left join (
	-- 神策平台取数
	select distinct distinct_id, $lib as eve_type
	from events where $lib in ('iOS','Android')
	and time between '2022-02-01' and '2023-01-17 13:00:00'
	and length(distinct_id)<9
	) t1 
on tt.cust_id = t1.distinct_id
where t1.distinct_id is null
limit 300000
;



-- APP车主总数
select count(distinct distinct_id)
from
(
select distinct_id,time,is_bind,row_number() over(partition by distinct_id order by time desc) num
from events
where $lib in('iOS','Android') 
and time between '2022-02-01' and '2022-11-01' 
and length(distinct_id)<9
) t 
where t.num=1
and t.is_bind=1




-- 1-6-4 参与过1月新春活动，且抽签的天数≥2天
select distinct b.会员ID
from (
	-- 神策平台取数
	select distinct distinct_id
	from events 
	where event = 'Page_view'
	and page_title = '好物迎春 献礼新岁'
	and bussiness_name = '活动'
	and activity_name = '好物迎春 献礼新岁'
	and time between '2023-01-01' and '2023-01-31 23:59:59'
	and length(distinct_id) < 9
	) a 
inner join (
	select
		a.member_id 会员ID,
		a.phone 抽签手机号,
		d.cust_id,
		count(distinct substr(a.create_time,1,10))  抽奖天数
	from volvo_online_activity_module.lottery_draw_log a
	inner join `member`.tc_member_info d 
	on a.member_id = d.ID and d.MEMBER_STATUS <> 60341003 and d.IS_DELETED = 0
	and a.lottery_code = 'new_spring_2023'   -- 新年新春活动
	and a.lottery_play_code = 'new_spring_2023_1'   -- 第一场活动  编码会变化
	and a.create_time >= '2023-01-01'
	and a.create_time <= '2023-01-17 13:30:00'
	group by 1,2,3
	) b
on a.distinct_id = b.cust_id
and b.抽奖天数>= 2
;


-- 2-4-1 近180天商城有正向订单的会员 or近180天新注册会员
select t2.MEMBER_PHONE 手机号
from (
	select a.user_id
	from order.tt_order a
	left join order.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 180) >= '2023-01-31 00:00:00'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
inner join `member`.tc_member_info t2 
on t1.user_id = t2.ID and t2.is_deleted = 0 and t2.member_status <> 60341003
and LENGTH(t2.MEMBER_PHONE) = 11 and left(t2.MEMBER_PHONE,1) = '1' -- 排除无效手机号
union
select tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
where date_add(tmi.MEMBER_TIME, 180) >= '2023-01-31 00:00:00'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;



-- 1-7-6 尚未参与过年度回顾的客片
select distinct IF(tmi.member_phone='*',r.MEMBER_PHONE,tmi.member_phone) 手机号
from member.tc_member_info tmi
left join (
	select tmi.ID 会员ID
	from track.track t
	join member.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	where t.`date` >= '2023-01-10' and t.`date` <= '2023-01-13 18:00:00'
	and json_extract(t.`data`,'$.embeddedpoint') = 'yearReview_太阳码_ONLOAD'
	UNION

	select tmi.ID 会员ID
	from track.track t
	join member.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	left join member.tc_member_info_phone_repetition r on tmi.ID = r.MEMBER_ID and r.IS_DELETED = 0 
	where t.`date` >= '2023-01-13'
	and t.`date` <= '2023-01-13 18:00:00'and json_extract(t.`data`,'$.embeddedpoint') = 'yearReview_主页面_ONLOAD'
	) tt
on tmi.id = tt.会员ID
left join member.tc_member_info_phone_repetition r on tmi.ID = r.MEMBER_ID and r.IS_DELETED = 0
where tt.会员ID is null

-- 2-3-1 23年1月开票车主
select distinct eco.open_id 微信公众号Open_ID
from (
	select
		a.MEMBER_PHONE 手机号,
		IFNULL(c.union_id,u.unionid) allunionid
	from vehicle.tt_invoice_statistics_dms t1 
	inner join member.tc_member_vehicle t2 
	on t1.vin = t2.vin
	and substr(invoice_date, 1, 7) = '2023-01' 
	and t2.is_deleted = 0 
	inner join `member`.tc_member_info a    -- 会员表作为主表
	on t2.member_id = a.id
	left join customer.tm_customer_info c on c.id=a.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=a.old_memberid and u.unionid <> '00000000'
	where a.MEMBER_STATUS <> 60341003
	and a.IS_DELETED = 0
	-- and a.MEMBER_TIME <= '2023-01-31 23:59:59' 
	) a
inner join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''

-- 2-1-1 12月14日~2月2日新注册会员
select distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
where tmi.MEMBER_TIME >= '2022-12-14'
and tmi.MEMBER_TIME <= '2023-02-02 23:59:59'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号


-- 2-8-1,  2-8-2  App全量用户
select distinct_id, event_type
from (
	select *, row_number()over(partition by distinct_id order by event_type desc) as rn
	from (
		select distinct distinct_id, $lib event_type
		from events
		where $lib in ('iOS', 'Android')
		and length(distinct_id)<9
		and time between '2022-02-01' and  '2023-02-03 13:30:00'
		) a
	) b
where rn = 1


select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01'
			) a
		) b
	where rn = 1 and event_type='Android'
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0





-- 2-8-3 全平台银卡及以上用户(银卡、金卡、白金卡)
SELECT * 
FROM (
	select DISTINCT IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
	from `member`.tc_member_info m
	left join `member`.tc_member_info_phone_repetition r on m.ID = r.MEMBER_ID and r.IS_DELETED = 0
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	and m.MEMBER_LEVEL >= 2 and m.MEMBER_LEVEL <> 5
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号


-- 2-8-4 小程序23年1月活跃车主&粉丝
select * 
from (
	select distinct IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2023-01-01' and t.date < '2023-02-01'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	left join `member`.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号



-- 2-2-1~2-2-4 人群包
select case when 是否车主 = 1 and 第一个月预测过期V值数 >= 1500 then '2-2-1'
					when 是否车主 = 0 and 第一个月预测过期V值数 >= 1500 then '2-2-2'
					when 是否车主 = 1 and 第一个月预测过期V值数 < 1500 then '2-2-3'
					when 是否车主 = 0 and 第一个月预测过期V值数 < 1500 then '2-2-4'
					end as  '人群包',
	会员ID, 手机号, 是否车主, 第一个月预测过期V值数
from (
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
		f.会员ID,f.手机号,f.是否车主,f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
		CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
			WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
			END '第一个月预测过期V值数'
	from (	
		select 
			f.'会员ID',f.'手机号',f.'是否车主',f.'截止T-24月累计发放V值',f.'T-24月当月发放V值',
			f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
			CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
				WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
				ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
				END '第一个月预测过期V值数'
		from (
			select
				f.MEMBER_ID '会员ID',
				IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
				m.IS_VEHICLE '是否车主',
				IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值',
				IFNULL(SUM(case when f.CREATE_TIME < '2021-03-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) '截止T-24月累计发放V值',          -- 截止到2022.1.31 23:59:59发放的V值
				IFNULL(SUM(case when f.CREATE_TIME >= '2021-02-01' and f.CREATE_TIME < '2021-03-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else null end),0) 'T-24月当月发放V值',       -- 2021.1.1 ~ 2021.1.31 23:59:59发放的V值
				IFNULL(SUM(case when f.CREATE_TIME <= '2023-02-09 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else null end),0) '截止T月累计消耗V值',       -- 截止到取数时，用户累计消耗V值
				IFNULL(SUM(case when f.CREATE_TIME <= '2023-02-09 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else null end),0) '截止T月累计过期V值'        -- 截止到取数时，用户累计过期V值
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left JOIN `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
			) f
		) f
	) f
where f.第一个月预测过期V值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包 
;


-- 2-5-1 App全量IOS用户
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-02-17 14:00:00'
			) a
		) b
	where rn = 1 AND event_type = 'iOS'
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0


-- 2-5-2 近180天新注册会员 or V值余额大于500的用户
select distinct tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
where DATE_ADD(tmi.MEMBER_TIME, 180) >= '2023-02-17'
and tmi.MEMBER_TIME <= '2023-02-07 14:00:00'
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_DELETED = 0
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
UNION 
select distinct 手机号
from (
	select
		m.id '会员ID',
		IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
		IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
	from `member`.tc_member_info m
	left join `member`.tc_member_info_phone_repetition p 
	on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	) f
where 用户当前剩余V值 > 500
and LENGTH(手机号) = 11 and left(手机号, 1) = '1' -- 排除无效手机号


-- 2-6-1 已点亮WOW辈楷模电子勋章的用户
select DISTINCT IF(d.member_phone='*',r.MEMBER_PHONE,d.member_phone) 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
left join `member`.tc_member_info_phone_repetition r on d.ID = r.MEMBER_ID and r.IS_DELETED = 0
left join mine.user_medal e on e.id = c.medal_id
where c.create_time <= '2023-02-24 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name = 'WOW辈楷模'


-- 2-6-2, 2-6-4 App全量IOS用户,App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-02-24 14:00:00'
			) a
		) b
	where rn = 1
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0



-- 2-6-3 近1个月登录过小程序，但从未登录过App的车主（取30万）
select distinct tt.手机号
from (
	select m.id 会员ID
		,m.cust_id
		,IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
		,t.max_date
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where (t.date >= '2023-02-23' and t.date < '2023-02-24') or t.date is null 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	left join `member`.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0
	where t.max_date > m.MEMBER_TIME or t.max_date is null
	order by t.max_date desc 
	) tt 
left join (
	-- 神策平台取数
	select distinct distinct_id, $lib as eve_type
	from events where $lib in ('iOS','Android')
	and time between '2022-02-01' and '2023-02-24 14:00:00'
	and length(distinct_id)<9
	) t1 
on tt.cust_id = t1.distinct_id
where t1.distinct_id is null
limit 300000
;



-- 11-4-1 截至2月27日18时，会员日优惠券未使用的用户
select DISTINCT x.沃世界绑定手机号
from (
	SELECT 
		a.id,
		a.one_id,
		b.id coupon_id卡券ID,
		b.coupon_name 卡券名称,
		a.left_value/100 面额,
		b.coupon_code 券号,
		tmi.ID 沃世界会员ID,
		tmi.MEMBER_PHONE 沃世界绑定手机号,
		a.vin 购买VIN,
		a.get_date 获得时间,
		CASE a.coupon_source 
		  WHEN 83241001 THEN 'VCDC发券'
		  WHEN 83241002 THEN '沃世界领券'
		  WHEN 83241003 THEN '商城购买'
		END AS 卡券来源,
		CASE a.ticket_state
		  WHEN 31061001 THEN '已领用'
		  WHEN 31061002 THEN '已锁定'
		  WHEN 31061003 THEN '已核销' 
		  WHEN 31061004 THEN '已失效'
		  WHEN 31061005 THEN '已作废'
		END AS 卡券状态
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
	left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID
	WHERE a.get_date >= '2022-11-25'
	and b.id in ('4019','4062','4060','4032')
	and a.is_deleted = 0 
	and a.ticket_state = 31061001 -- 卡券状态为已领用
	order by a.get_date
	) x
	


-- 3-8-1, 3-8-2 App全量IOS用户,App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-03-03 14:00:00'
			) a
		) b
	where rn = 1
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0


-- 3-8-3 全平台银卡及以上用户(银卡、金卡、白金卡)
SELECT * 
FROM (
	select DISTINCT IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
	from `member`.tc_member_info m
	left join `member`.tc_member_info_phone_repetition r on m.ID = r.MEMBER_ID and r.IS_DELETED = 0
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	and m.MEMBER_LEVEL >= 2 and m.MEMBER_LEVEL <> 5
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号



-- 3-8-4 小程序23年2月活跃车主&粉丝
select * 
from (
	select distinct IF(m.member_phone='*',r.MEMBER_PHONE,m.member_phone) 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2023-02-01' and t.date < '2023-03-01'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	left join `member`.tc_member_info_phone_repetition r 
	on m.ID = r.MEMBER_ID 
	and r.IS_DELETED = 0
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号


-- 3-1-1~3-1-4 人群包
select case when 是否车主 = 1 and 第一个月预测过期V值数 >= 1500 then '3-1-1'
					when 是否车主 = 0 and 第一个月预测过期V值数 >= 1500 then '3-1-2'
					when 是否车主 = 1 and 第一个月预测过期V值数 < 1500 then '3-1-3'
					when 是否车主 = 0 and 第一个月预测过期V值数 < 1500 then '3-1-4'
					end as  '人群包',
	会员ID, 手机号, 是否车主, 第一个月预测过期V值数
from (
	-- 第一个月的过期V值预测（2023.2即将过期V值）
	select
		f.会员ID,f.手机号,f.是否车主,f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
		CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
			WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
			END '第一个月预测过期V值数'
	from (	
		select 
			f.'会员ID',f.'手机号',f.'是否车主',f.'截止T-24月累计发放V值',f.'T-24月当月发放V值',
			f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
			CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
				WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
				ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
				END '第一个月预测过期V值数'
		from (
			select
				f.MEMBER_ID '会员ID',
				IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
				m.IS_VEHICLE '是否车主',
				IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值',
				SUM(case when f.CREATE_TIME < '2021-04-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) '截止T-24月累计发放V值',   -- 截止到当前月底两年前发放的V值
				SUM(case when f.CREATE_TIME >= '2021-03-01' and f.CREATE_TIME < '2021-04-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) 'T-24月当月发放V值',
				SUM(case when f.CREATE_TIME <= '2023-03-07 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) '截止T月累计消耗V值',
				SUM(case when f.CREATE_TIME <= '2023-03-07 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) '截止T月累计过期V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left JOIN `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
			) f
		) f
	) f
where f.第一个月预测过期V值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包 
;

-- 3-5-3 小程序前一个月活跃用户（待定）
select * 
from (
	select distinct m.member_phone 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2023-02-10' and t.date < '2023-03-10'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号



-- 3-2-1 已点亮WOW辈楷模电子勋章的用户
select DISTINCT d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
left join mine.user_medal e on e.id = c.medal_id
where c.create_time <= '2023-03-24 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name = 'WOW辈楷模'



-- 3-2-2, 3-2-5 App全量IOS用户,App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-03-24 14:00:00'
			) a
		) b
	where rn = 1
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0


-- 3-2-3 近1个月登录过小程序，但从未登录过App的车主（取30万）
select distinct tt.手机号
from (
	select m.id 会员ID
		,m.cust_id
		,m.member_phone 手机号
		,t.max_date
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where (t.date >= '2022-09-23' and t.date < '2023-03-24') or t.date is null 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME or t.max_date is null
	order by t.max_date desc 
	) tt 
left join (
	-- 神策平台取数
	select distinct distinct_id, $lib as eve_type
	from events where $lib in ('iOS','Android')
	and time between '2022-02-01' and '2023-03-24 14:00:00'
	and length(distinct_id)<9
	) t1 
on tt.cust_id = t1.distinct_id
where t1.distinct_id is null
;


-- 3-2-4 V值余额超过1000V，且近30天内未在商城购买过商品的用户
select distinct 手机号
from (
	select
		m.id,
		m.MEMBER_PHONE '手机号',
		IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
	from `member`.tc_member_info m
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	and (IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 1000)
	) t1
left join (
	select a.user_id
	from order.tt_order a
	left join order.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 30) >= '2023-03-24 00:00:00'
	and a.order_time <= '2023-03-24 00:00:00'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t2 
on t2.user_id = t1.ID
where t2.user_id is null
and LENGTH(t1.手机号) = 11 and left(t1.手机号,1) = '1' -- 排除无效手机号
;

	
-- 4-5-1 沃世界绑车用户中，在绑S60或S90或XC60，且绑定时长在3年及以上的车主
select distinct m.member_phone 手机号, '4-5-1' as '人群包'
from member.tc_member_info m
inner join member.tc_member_vehicle tv
on m.id = tv.member_id
and tv.is_deleted = 0 and tv.create_time < '2020-03-31'
and m.is_deleted = 0 and m.member_status <> 60341003
inner join basic_data.tm_model td
on tv.VEHICLE_CODE = td.MODEL_CODE
and td.is_deleted = 0 and Td.MODEL_NAME IN ('S60', 'S90', 'XC60')
;

-- 4-5-2 近90天内活跃用户
select distinct m.member_phone 手机号, '4-5-2' as '人群包'
from (
	select t.usertag, max(t.`date`) max_date
	from track.track t 
	where date_add(t.date, 90) > '2023-03-31'
	group by 1
	) t 
inner join member.tc_member_info m 
on t.usertag = cast(m.USER_ID as varchar)
and m.is_deleted = 0 
and m.member_status <> 60341003
where t.max_date > m.MEMBER_TIME



-- 4-5-3 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id, $lib event_type
	from events
	where $lib = 'iOS' and length(distinct_id)<9
	and time between '2022-02-01' and '2023-03-31 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 4-6-1 近90天社区发帖用户
select distinct m.MEMBER_PHONE '手机号', '4-6-1' as '人群包'
from community.tm_post t1 
inner join `member`.tc_member_info m 
on t1.member_id = m.id
and t1.is_deleted = 0 and date_add(t1.create_time, 90) > '2023-03-31'
and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
;

-- 4-6-2 V值余额大于500的车主
select distinct m.MEMBER_PHONE '手机号', '4-6-2' as '人群包'
from `member`.tc_member_info m
where m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0 and IS_VEHICLE = 1
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 500
;

-- 4-6-3 V值余额大于500的粉丝
select distinct m.MEMBER_PHONE '手机号', '4-6-3' as '人群包'
from `member`.tc_member_info m
where m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0 and IS_VEHICLE = 0
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 500
;


-- 4-6-4 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id, $lib event_type
	from events
	where $lib = 'iOS' and length(distinct_id)<9
	and time between '2022-02-01' and '2023-03-31 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;


-- 4-4-1 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id, $lib event_type
	from events
	where $lib = 'iOS' and length(distinct_id)<9
	and time between '2022-02-01' and '2023-04-03 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;


-- 4-4-2 全平台银卡及以上用户(银卡、金卡、白金卡)
SELECT * 
FROM (
	select DISTINCT m.member_phone 手机号, '4-4-2' as '人群包'
	from `member`.tc_member_info m
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0
	and m.MEMBER_LEVEL >= 2 and m.MEMBER_LEVEL <> 5
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号
;

-- 4-4-3 小程序23年3月活跃车主&粉丝
select * 
from (
	select distinct m.member_phone 手机号, '4-4-3' as '人群包'
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2022-12-01' and t.date < '2023-04-01'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号
;




-- 4-1-1~4-1-4 人群包
select case when 是否车主 = 1 and 第一个月预测过期V值数 >= 1500 then '4-1-1'
					when 是否车主 = 0 and 第一个月预测过期V值数 >= 1500 then '4-1-2'
					when 是否车主 = 1 and 第一个月预测过期V值数 < 1500 then '4-1-3'
					when 是否车主 = 0 and 第一个月预测过期V值数 < 1500 then '4-1-4'
					end as  '人群包',
	会员ID, 手机号, 是否车主, 第一个月预测过期V值数
from (
	select
		f.会员ID,f.手机号,f.是否车主,f.'截止T-24月累计发放V值',
		f.'T-24月当月发放V值',f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
		CASE WHEN f.'第一个月预测过期V值数' >= f.'用户当前剩余V值' then f.'用户当前剩余V值'
			WHEN f.'第一个月预测过期V值数' < f.'用户当前剩余V值' then f.'第一个月预测过期V值数'
			END '第一个月预测过期V值数'
	from (	
		select 
			f.'会员ID',f.'手机号',f.'是否车主',f.'截止T-24月累计发放V值',f.'T-24月当月发放V值',
			f.'截止T月累计消耗V值',f.'截止T月累计过期V值',f.'用户当前剩余V值',
			CASE WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') >= f.'T-24月当月发放V值' then f.'T-24月当月发放V值'
				WHEN (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值') <= 0 then 0
				ELSE (f.'截止T-24月累计发放V值' - f.'截止T月累计消耗V值' - f.'截止T月累计过期V值')
				END '第一个月预测过期V值数'
		from (
			select
				f.MEMBER_ID '会员ID',
				IF(m.MEMBER_PHONE='*',p.MEMBER_PHONE,m.MEMBER_PHONE) '手机号',
				m.IS_VEHICLE '是否车主',
				IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值',
				SUM(case when f.CREATE_TIME < '2021-05-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) '截止T-24月累计发放V值',   -- 截止到当前月底两年前发放的V值
				SUM(case when f.CREATE_TIME >= '2021-04-01' and f.CREATE_TIME < '2021-05-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) 'T-24月当月发放V值',
				SUM(case when f.CREATE_TIME <= '2023-04-06 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) '截止T月累计消耗V值',
				SUM(case when f.CREATE_TIME <= '2023-04-06 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) '截止T月累计过期V值'
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			left JOIN `member`.tc_member_info_phone_repetition p on m.ID = p.MEMBER_ID and p.IS_DELETED = 0
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
			) f
		) f
	) f
where f.第一个月预测过期V值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
and 会员ID not in ('3033545','3034054','3040108','3041129'
	,'3082108','3086283','3093036','3094912','3104253','3112379'
	,'3118614','3129766','3139750','3141961','3156266','3192560'
	,'3218553','3223574','3232821','3257270','3282061','3297946'
	,'3307627','3340427','3350178','3352993','3402391','3404777'
	,'3429797','3456337','3459313','3489636','3500246','3503970'
	,'3536427','3576994','3591132','3591216','3592458','3626650'
	,'3634746','3688469','3711434','3754337','3791268','3828975'
	,'3854732','3861668','4139962','4222948','4310920','4432798'
	,'4435341','4469200','3042083','3042117','3079748')
order by 人群包 


select distinct_id
from rawdata.events 
where event = 'Page_view' 
and page_title in ('XC40 RECHARGE详情页', 'C40 RECHARGE详情页', 'XC90详情页')
and time >= '2022-10-12' and time < '2023-04-12'
and length(distinct_id)<9


-- 4-4-1 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id, $lib event_type
	from events
	where $lib = 'iOS' and length(distinct_id)<9
	and time between '2022-02-01' and '2023-04-03 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 4-7-1 App全量车主
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct distinct_id, $lib as eve_type
	from rawdata.events 
	where $lib in ('iOS', 'Android')
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-04-12 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0 and IS_VEHICLE = 1
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 4-7-2 App过去6个月浏览过XC90、XC40 BEV、C40车型的粉丝
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where event = 'Page_view' 
	and page_title in ('XC40 RECHARGE详情页', 'C40 RECHARGE详情页', 'XC90详情页')
	and time >= '2022-10-12' and time < '2023-04-12 14:00:00'
	and length(distinct_id)<9
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0 and IS_VEHICLE = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;


-- 4-7-3 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-04-12 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;





-- 4-3-1 已点亮WOW辈楷模电子勋章的用户
select DISTINCT d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
left join mine.user_medal e on e.id = c.medal_id
where c.create_time <= '2023-04-24 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name = 'WOW辈楷模'



-- 4-3-2, 4-3-5 App全量IOS用户,App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.id, t2.member_phone
from (
	-- 神策平台取数
	select distinct_id, event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-04-24 14:00:00'
			) a
		) b
	where rn = 1
	) t1 
inner join member.tc_member_info t2 
on t1.distinct_id = t2.cust_id
and member_status <> 60341003 and is_deleted = 0


-- 4-3-3 近1个月登录过小程序，但从未登录过App的车主（取30万）
select distinct tt.手机号
from (
	select m.id 会员ID
		,m.cust_id
		,m.member_phone 手机号
		,t.max_date
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2022-10-23' and t.date < '2023-04-24 14:00:00'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) tt 
left join (
	-- 神策平台取数
	select distinct distinct_id, $lib as eve_type
	from events where $lib in ('iOS','Android')
	and time between '2022-02-01' and '2023-04-24 14:00:00'
	and length(distinct_id)<9
	) t1 
on tt.cust_id = t1.distinct_id
where t1.distinct_id is null
;


-- 4-3-4 V值余额超过100V，且最近180天没有预约养修的车主
select distinct 手机号
from (
	select
		m.id,
		cust_id,
		m.MEMBER_PHONE '手机号',
		IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) '用户当前剩余V值'
	from `member`.tc_member_info m
	where m.MEMBER_STATUS <> 60341003
	and m.IS_DELETED = 0 and m.IS_VEHICLE = 1
	and (IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 100)
	and m.id not in ('3033545','3034054','3040108','3041129'
	,'3082108','3086283','3093036','3094912','3104253','3112379'
	,'3118614','3129766','3139750','3141961','3156266','3192560'
	,'3218553','3223574','3232821','3257270','3282061','3297946'
	,'3307627','3340427','3350178','3352993','3402391','3404777'
	,'3429797','3456337','3459313','3489636','3500246','3503970'
	,'3536427','3576994','3591132','3591216','3592458','3626650'
	,'3634746','3688469','3711434','3754337','3791268','3828975'
	,'3854732','3861668','4139962','4222948','4310920','4432798'
	,'4435341','4469200','3042083','3042117','3079748')
	) t1
left join cyx_appointment.tt_appointment ta
on t1.cust_id = ta.ONE_ID 
and ta.APPOINTMENT_TYPE = 70691005 and ta.IS_DELETED = 0
and date_add(ta.created_at, 180) >= '2023-04-24' and ta.created_at < '2023-04-24'
where ta.ONE_ID is null
;

-- 4-8-1 4月25日会员日拉新粉丝，需要剔除其中近90天有过留资记录的人
select distinct t1.member_phone as mobile
from (
	select m.member_phone
	from track.track t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and left(t.date, 10) = '2023-04-25'
	and json_extract(t.`data`,'$.embeddedpoint') in ('memberDay202304_home_app_ONLOAD', 'memberDay202304_home_miniProgram_ONLOAD')
	and m.is_deleted = 0 and m.MEMBER_STATUS <> 60341003 and m.IS_VEHICLE = 0
	where m.create_time between date_sub(t.date,interval 10 MINUTE) and DATE_ADD(t.date,INTERVAL 10 MINUTE)
	) t1 
left join (
	select mobile
	from customer.tt_clue_clean
	where is_deleted = 0 and date_add(create_time, 90) >= '2023-04-26'
	) t2 
on t1.member_phone = t2.mobile
where t2.mobile is null
and LENGTH(t1.member_phone) = 11 and left(t1.member_phone,1) = '1' 



-- 5-2-1 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-05-04 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;



-- 5-2-2 近3个月活跃的用户
select * 
from (
	select distinct m.member_phone 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2023-02-04' and t.date < '2023-05-04 14:00:00'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号


-- 5-2-3 自2022年1月-23年4月，在小程序浏览过会员日活动，但从未登录App参与会员日活动的用户
select tmi.MEMBER_PHONE as 手机号
from (
	select t1.usertag
	from (
		select distinct usertag
		from track.track 
		where `date` >= '2022-01-25'
		and `date` <= '2023-05-01'
		and json_extract(`data`,'$.embeddedpoint') in ('memberDay_home_ONLOAD' , 'memberDay2_home_onload', 'memberDay3_home_onload', 
			'memberDay4_home_onload','memberDay5_home_onload', 'memberDay6_home_onload', 'memberDay7_home_onload', 
			'memberDay8_home_onload', 'memberDay9_home_onload','memberDay10_home_onload','memberDay11_home_onload', 
			'memberDay12_home_onload', 'memberDay12_home_miniProgram_onload','memberDay202301_home_miniProgram_onload', 
			'memberDay202302_home_miniProgram_ONLOAD','memberDay202303_home_miniProgram_ONLOAD', 'memberDay202304_home_miniProgram_ONLOAD')
		) t1
	left join (
		select distinct usertag
		from track.track 
		where `date` >= '2022-12-25'
		and `date` <= '2023-05-01'	
		and json_extract(`data`,'$.embeddedpoint') in ('memberDay12_home_app_onload', 'memberDay202301_home_app_onload',
				'memberDay202302_home_app_ONLOAD', 'memberDay202303_home_app_ONLOAD', 'memberDay202304_home_app_ONLOAD')
		) t2
	on t1.usertag = t2.usertag
	where t2.usertag is null
	) tt 
inner join `member`.tc_member_info tmi 
on tt.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1'


-- 5-2-4 近3个月未登录过小程序/App的用户【粉丝&车主】取30万
select * 
from (
	select m.member_phone 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and t.max_date < '2023-02-04'
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号



-- 5-2-5 近3个月浏览过电车车型或提交试驾信息（不限车型）但未到店的用户
select distinct member_phone
from member.tc_member_info tmi 
left join (
	-- 神策平台取数
	select distinct_id as cust_id
	from rawdata.events 
	where event = 'Page_view' 
	and page_title in ('XC40 RECHARGE详情页', 'C40 RECHARGE详情页')
	and time >= '2023-02-04' and time < '2023-05-04 14:00:00'
	and $lib in ('Android', 'iOS')
	and length(distinct_id)<9
	union
	select distinct_id as cust_id
	from rawdata.events 
	where event = '$MPViewScreen' 
	and time >= '2023-02-04' and time < '2023-05-04 14:00:00'
	and $lib = 'MiniProgram'
	and length(distinct_id)<9
	and ($url like '%/car-detail-category/C40car/%' or url like '%/car-detail-category/xc40R/%')
	) t1
on tmi.cust_id = t1.cust_id
left join (
	select distinct ta.ONE_ID as cust_id
	from cyx_appointment.tt_appointment ta
	where APPOINTMENT_TYPE = 70691002
	and created_at >= '2023-02-04' and created_at < '2023-05-04 14:00:00'
	) t2
on tmi.cust_id = t2.cust_id
left join (
	select mobile_phone as member_phone
	from cyx_passenger_flow.tt_passenger_flow_info
	where created_at >= '2023-02-04' and created_at < '2023-05-04 14:00:00'
	union 
	select drawer_tel as member_phone
	from cyxdms_retail.tt_sales_orders
	where created_at >= '2023-02-04' and created_at < '2023-05-04 14:00:00'
	) t3
on tmi.member_phone = t3.member_phone
where coalesce(t1.cust_id, t2.cust_id) is not null and t3.member_phone is null


-- 5-1-1~5-1-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 第一个月预测过期v值数 >= 1500 then '5-1-1'
					when 是否车主 = 0 and 第一个月预测过期v值数 >= 1500 then '5-1-2'
					when 是否车主 = 1 and 第一个月预测过期v值数 < 1500 then '5-1-3'
					when 是否车主 = 0 and 第一个月预测过期v值数 < 1500 then '5-1-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数
from (
	select
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",
		f."T-24月当月发放v值",f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		CASE WHEN f."第一个月预测过期v值数" >= f."用户当前剩余v值" then f."用户当前剩余v值"
			WHEN f."第一个月预测过期v值数" < f."用户当前剩余v值" then f."第一个月预测过期v值数"
			END "第一个月预测过期v值数"
	from (	
		select 
			f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
			f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
			CASE WHEN (f."截止T-24月累计发放v值" - f."截止T月累计消耗v值" - f."截止T月累计过期v值") >= f."T-24月当月发放v值" then f."T-24月当月发放v值"
				WHEN (f."截止T-24月累计发放v值" - f."截止T月累计消耗v值" - f."截止T月累计过期v值") <= 0 then 0
				ELSE (f."截止T-24月累计发放v值" - f."截止T月累计消耗v值" - f."截止T月累计过期v值")
				END "第一个月预测过期v值数"
		from (
			select
				f.MEMBER_ID "会员id",
				m.MEMBER_PHONE "手机号",
				m.IS_VEHICLE "是否车主",
				IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
				SUM(case when f.CREATE_TIME < '2021-06-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
				SUM(case when f.CREATE_TIME >= '2021-05-01' and f.CREATE_TIME < '2021-06-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
				SUM(case when f.CREATE_TIME <= '2023-05-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
				SUM(case when f.CREATE_TIME <= '2023-05-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
			from `member`.tt_member_flow_record f     -- 流水表
			join `member`.tc_member_info m on f.MEMBER_ID = m.ID
			where f.IS_DELETED = 0
			and m.MEMBER_STATUS <> 60341003
			and m.IS_DELETED = 0
			group by 1
			order by 1
			) f
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
and 会员id not in ('3033545','3034054','3040108','3041129'
	,'3082108','3086283','3093036','3094912','3104253','3112379'
	,'3118614','3129766','3139750','3141961','3156266','3192560'
	,'3218553','3223574','3232821','3257270','3282061','3297946'
	,'3307627','3340427','3350178','3352993','3402391','3404777'
	,'3429797','3456337','3459313','3489636','3500246','3503970'
	,'3536427','3576994','3591132','3591216','3592458','3626650'
	,'3634746','3688469','3711434','3754337','3791268','3828975'
	,'3854732','3861668','4139962','4222948','4310920','4432798'
	,'4435341','4469200','3042083','3042117','3079748')
order by 人群包 


-- 5-2-6 近6个月有过社区浏览or互动行为（点赞/评论/收藏/发布）的用户
select distinct member_phone 
from member.tc_member_info tm 
inner join (
	-- 神策平台取数
	--社区浏览人数
	select distinct_id
	from events 
	where event='Page_view' and length(distinct_id)<9
	and page_title in ('此刻','社区此刻页','内容详情','文章详情','动态详情')
	and time between '2022-11-12' and '2023-05-12 17:00:00'
	union 
	--社区内容互动
	select distinct_id
	from events 
	where event='Button_click' and length(distinct_id)<9
	and page_title in ('此刻','社区此刻页','内容详情','文章详情','动态详情')
	and btn_name in('点赞','文章点赞','评论点赞','文章评论发送','回复评论发送','微信好友','朋友圈')
	and time between '2022-11-12' and '2023-05-12 17:00:00'
	) tt 
on tm.cust_id = tt.distinct_id 
and tm.member_status <> 60341003 and tm.is_deleted = 0
;


-- 5-2-7 浏览过本次525活动页面，但未参与过【525每日锦鲤】抽奖活动的用户
select distinct member_phone 
from member.tc_member_info tm 
inner join (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events
	where event = 'Page_view' and page_title =	'525车主节'
	and time>= '2023-05-05' and time <=  '2023-05-12 17:00:00'
	and length(distinct_id)<9
	) tt 
on tm.cust_id = tt.distinct_id 
and tm.member_status <> 60341003 and tm.is_deleted = 0
left join (
	select distinct member_id
	from volvo_online_activity_module.lottery_draw_log t1 
	inner join volvo_online_activity_module.lottery_play_init t2 
	on t1.lottery_play_code = t2.lottery_play_code
	and t2.lottery_play_name like '202305会员日抽奖%'
	) t2 
on tm.id = t2.member_id 
where t2.member_id is null 
;


-- 5-2-8 活动期间浏览过精品周边/售后聚惠/纯电出行活动页面，但未产生过实际订单交易的用户
select *
from (
	-- 神策平台取数
	select distinct_id
	from rawdata.events
	where length(distinct_id)<9
	and time >= '2023-05-12' and time <=  '2023-05-12 17:00:00'
	and (event = '$AppViewScreen' and $title in ('精品周边', '纯电出行', '售后聚惠') 
			or (event = 'Page_view' and page_title = '精品周边'))
	) tt
inner join member.tc_member_info tm 
on tt.distinct_id = tm.cust_id 
and tm.member_status <> 60341003 and tm.is_deleted = 0
left join (
	select a.user_id
	from order.tt_order a
	left join order.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time >= '2023-05-05 00:00:00'
	and a.order_time <= '2023-05-12 17:00:00'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) tr 
on tm.id = tr.user_id
where tr.user_id is null
;


-- 5-2-9 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-05-24 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 5-2-10 App/小程序已绑车但未浏览过525车主节活动页面的车主用户
select distinct member_phone 
from member.tc_member_info tm 
inner join (
	select member_id 
	from volvo_cms.vehicle_bind_relation
	where is_owner=1 and is_bind=1 and deleted=0
	) t1 
on tm.id = t1.member_id
left join (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events
	where event = 'Page_view' and page_title =	'525车主节'
	and time>= '2023-05-05' and time <=  '2023-05-24 14:00:00'
	and length(distinct_id)<9
	) tt 
on m.cust_id = tt.distinct_id 
where tm.member_status <> 60341003 and tm.is_deleted = 0
and tt.cust_id is null 
;


-- 5-2-11 近3个月非活跃的用户（与5/5人群包3去重，取前30万）
select * 
from (
	select m.member_phone 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and t.max_date < '2023-02-24'
	and m.is_deleted = 0 
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) a 
where LENGTH(手机号) = 11 and left(手机号,1) = '1'            -- 排除无效手机号
;



-- 5-2-12 近3个月于App参与过WOW DAY会员日活动的用户或已点亮【WOW辈楷模】电子勋章的用户
select distinct m.member_phone
from track.track t 
inner join member.tc_member_info m
on t.usertag = cast(m.USER_ID as varchar)
and substr(t.`date`, 9, 2) = '25'
and json_extract_path_text(cast("data" as json),'embeddedpoint') in ('memberDay202302_home_app_ONLOAD', 
					'memberDay202303_home_app_ONLOAD', 'memberDay202304_home_app_ONLOAD')
where m.is_deleted = 0 and m.member_status <> 60341003
union 
select d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
left join mine.user_medal e on e.id = c.medal_id
where c.create_time <= '2023-05-24 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
and e.medal_name = 'WOW辈楷模'
;




-- 5-2-13 活动期间“我的卡券”内领到过商城精品优惠券（通过商城精品活动/抽奖活动）但从未使用过的用户
select distinct m.member_phone
from (
	select id, member_phone, cust_id
		,row_number()over(partition by cust_id order by id desc) as rn
	from member.tc_member_info m
	where m.is_deleted = 0 
	and m.member_status <> 60341003
	) m 
inner join (
	select one_id 
		,count(*) "优惠券领取数"
		,sum(case when a.ticket_state = 31061003 then 1 else 0 end) "优惠券核销数"
	from coupon.tt_coupon_detail a 
	where a.is_deleted = 0 
	and a.get_date >= '2023-05-05' and a.get_date <= '2023-05-24 14:00:00'
	and a.coupon_id in (4643, 4645, 4646, 4648, 4649)
	group by 1
	) t 
on m.cust_id = t.one_id
and m.rn = 1
and t.优惠券核销数 = 0
;



-- 5-3-1 浏览过21年和22年爱心计划专区的用户
select distinct tmi.member_phone "手机号"
from (
	select t.usertag
	from track.track t
	where t.`date` >= '2022-01-01 00:00:00' and t.`date` <= '2022-12-31 23:59:59'
	and (t.`data` like '%爱心计划2期_首页_onload%'
		or t.`data` like '%爱心计划2期_首页_click_视频%'
		or t.`data` like '%爱心计划2期_专题页_onload%'
		or t.`data` like '%爱心计划2期_新增活动_click_提交按钮%'
		or t.`data` like '%爱心计划2期_首页/专题页_click_活动发起按钮%'
		or t.`data` like '%376734466CE84B2D8B1B44733FB5DC5C%'
		or t.`data` like '%CD26BB762B9748E6B45E0A170D8EAD81%'
		or t.`data` like '%C47798EE223C40D3BBABD2813A0DF708%'
		or t.`data` like '%BA5F73BBCA7842DDBF4FE83A5B9C1614%'
		or t.`data` like '%29EE304844CE4BACBB6221CC9CDD1F48%'
		or t.`data` like '%37B7B6E07EFC41F5B709DEA9FB0DDBB1%'
		or t.`data` like '%C7DD6C1DED314292A7375F8F2DB8CE01%'
		or t.`data` like '%581F3B2EA4354FD6860CD24C4549ED54%'
		or t.`data` like '%A222FFC20C7D46A8AEDB69D9A646205E%'
		or t.`data` like '%5E6659BDEB1A49B5A50ADA895D0A4D0F%'
		or t.`data` like '%0598EA51355B4DC7A9593F9AAF8EFFC6%'
		or t.`data` like '%54D294A1B8B6405AB4BA72BB19C2D3F3%'
		or t.`data` like '%42C25A742F824B518209C77E69C1859D%'
		or t.`data` like '%CFEA0E71EC7241529C2572C5748F3013%'
		or t.`data` like '%D15DB44917D24BFAB9F8061E5744393F%'
		or t.`data` like '%800BF503C530488D96D9049D6D46F192%'
		or t.`data` like '%C28B286001494D808CC32FD57F05BD07%'
		or t.`data` like '%2B92AB9FC0B140D6BFC0FFB71533CD05%'
		or t.`data` like '%38D7A05032A84E64B0CD1986DD2F3A18%'
		or t.`data` like '%6272348F4202465E92ADFB05654CB3D5%'
		or t.`data` like '%814FDABE68F8446EA7DC69BEECB3256A%'
		or t.`data` like '%爱心活动发起_click%'
		or t.`data` like '%活动分享_click%'
		or t.`data` like '%基金会介绍_click%'
		or t.`data` like '%复制链接_click%'
		or t.`data` like '%我要捐赠_click%'
		or t.`data` like '%我要留言_click%'
		or t.`data` like '%爱心助力榜_click%'
		or t.`data` like '%我的捐赠_click%'
		or t.`data` like '%查看品牌证书_click%'
		or t.`data` like '%查看用户证书_click%'
		or t.`data` like '%BCAlc8VGtX%'
		or t.`data` like '%zBAffYjDjx%'
		or t.`data` like '%Clu6eBXefi%'
		or t.`data` like '%4xOK78u7nR%'
		or t.`data` like '%BCAlc8VGtX%')
	union 
	select t.usertag
	from track.track t
	where t.`date` >= '2021-01-01 00:00:00' and t.`date` <= '2021-12-31 23:59:59'
	and t.`data` like '%爱心计划专区%'
	) t 
inner join `member`.tc_member_info tmi 
on t.usertag = cast(tmi.USER_ID as varchar)
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 5-3-2 浏览并参与22年先心捐赠活动的用户（捐赠V值/捐赠现金）
select distinct tmi.member_phone "手机号"
from `order`.tt_donation_order tdo
inner join `member`.tc_member_info tmi 
on tdo.member_id = tmi.ID 
and tdo.is_deleted = 0
and tdo.activity_type=31231001  -- 守护先天性心脏病儿童
and tdo.order_time >= '2022-03-21'
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 5-3-3 V值账户余额区间：20-500的平台用户，且近3个月小程序或App活跃
select distinct m.member_phone "手机号"
from (
	select t.usertag
	from track.track t 
	where t.date >= '2023-02-28'
	group by 1
	) t 
inner join member.tc_member_info m 
on t.usertag = cast(m.USER_ID as varchar)
and m.is_deleted = 0 
and m.member_status <> 60341003
and m.member_v_num between 20 and 500
;

-- 5-3-4 参与过沃尔沃汽车App此刻发帖的平台用户
SELECT distinct tmi.member_phone "手机号"
from community.tm_post tp 
inner join `member`.tc_member_info tmi 
on tp.member_id = tmi.ID 
where tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.platform_app = 1
and tp.is_deleted <> 1       -- 删除确定是非1还是0
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 5-3-5 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-05-31 13:30:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;


-- 6-4-1 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-06-02 13:30:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 6-4-2 近180天新注册用户 或 近180天有商城订单的用户
select tm.member_phone "手机号"
from member.tc_member_info tm
where member_status <> 60341003 and is_deleted = 0
and create_time + '180 day' >= '2023-06-02' 
union 
select tm.member_phone "手机号"
from member.tc_member_info tm
inner join (
	select a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time  + '180 day' >= '2023-06-02'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) tr 
on tm.id = tr.user_id
and tm.member_status <> 60341003 and tm.is_deleted = 0
;

-- 6-4-3 V值余额大于500V的用户
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 500
;


-- 过去12个月参加过会员日抽奖的用户
select distinct tm.member_phone "手机号"
from volvo_online_activity_module.lottery_draw_log t1 
inner join volvo_online_activity_module.lottery_play_init t2 
on t1.lottery_play_code = t2.lottery_play_code
and t1.create_time + '12 month' >= '2023-06-02'
and t2.lottery_name = '会员日抽奖'
inner join member.tc_member_info tm
on t1.member_id = tm.id 
and tm.member_status <> 60341003 and tm.is_deleted = 0


-- 全体KOC用户  -- 车主
select tm.member_phone "手机号"
from mine.koc_tasks_summary a
inner join member.tc_member_info tm
on a.member_id = tm.id 
and tm.member_status <> 60341003 and tm.is_deleted = 0 and tm.IS_VEHICLE=1
where a.tasks_status = 1  -- 1表示已完成
and a.tasks_type = 1  -- 筛选新手任务
and a.is_delete = 0  -- 逻辑删除
union 
select tm.member_phone
from member.tc_member_info tm
where tm.member_status <> 60341003 and tm.is_deleted = 0 and tm.IS_VEHICLE=1
and tm.id in ('3411867',
'3601819',
'3309080',
'3344124',
'3408495',
'3809456',
'4563552',
'4098690',
'3788147',
'3328449',
'3719761',
'4602847',
'4129905',
'4064023',
'4453841',
'3591412',
'3626987',
'3593618',
'3860425',
'3740505',
'3805627',
'4308006',
'4161678',
'4266297',
'4261392',
'3626969',
'4730874',
'3822616',
'4283973',
'4610896',
'3042212',
'4214720',
'3293491',
'3350199',
'3050529',
'4274374',
'3176846',
'4620091',
'4383767',
'3101493',
'3101898',
'4298836',
'4531565',
'3717910',
'4139687',
'4560722',
'4440915',
'3617822',
'3311366',
'3630544',
'4758236',
'3733345',
'3331548',
'3307627',
'4022482',
'4653910',
'4400867',
'3800116',
'3821981',
'3814559',
'3389334',
'4642876',
'3822138',
'3802310',
'3800669',
'3454326',
'3248236',
'4720247',
'4386523',
'3295132',
'4550513',
'3552079',
'4651366',
'3435461',
'3028306',
'3349169',
'3355830',
'3866999',
'3724051',
'3523731',
'3812974',
'3525309',
'4759228',
'3754337',
'4321992',
'4164043',
'4424584',
'3108458',
'4243761',
'3591234',
'4221647',
'4440421',
'3785174',
'3685575',
'3592946',
'4090961',
'4281269',
'4249974',
'3519318',
'3674197',
'3249150',
'3384061',
'4420380',
'3722040',
'4288040',
'3561555',
'4152308',
'3287386',
'4636198',
'3479201',
'4522807',
'3837164',
'4121573',
'4320609',
'4546229',
'3553719',
'4360389',
'4629597',
'3788328',
'3825460',
'3341906',
'3628276',
'4274362',
'4375251',
'3682552',
'4458294',
'3412758',
'3318942',
'4244475',
'4296518',
'4185098',
'4755437',
'3671351',
'3371339',
'4223730',
'3214557',
'4187837',
'4724180',
'3860698',
'4248946',
'4649212',
'3604841',
'3575258',
'3679689',
'3615310',
'4199686',
'3429131',
'3108564',
'4079402',
'3581910',
'3239549',
'4092173',
'4285255',
'3757922',
'4571486',
'3207376',
'4167554',
'4180301',
'3488334',
'4768242',
'4672169',
'3445868',
'3684450',
'3485120',
'4435851',
'5289267',
'3600965',
'4086758',
'3790887',
'4586290',
'4540253',
'4256572',
'4542446',
'3708101',
'3220540',
'4535279',
'4172246',
'3676537',
'4562714',
'3365019',
'3861562',
'4256621',
'4166004',
'3697031',
'4083099',
'3501462',
'4227941',
'3177594',
'4438683',
'3242011',
'3113722',
'3513672',
'3434492',
'3452001',
'3018468',
'3615064',
'4273645',
'3261811',
'4063478',
'3589851',
'4296701',
'4324115',
'3058390',
'3241647',
'3389623',
'3495260',
'3297946',
'3448832',
'3635049',
'4251644',
'3043532',
'3057338',
'4151420',
'4473220',
'4635355',
'4562028',
'4265474',
'4195002',
'3533837',
'3020766',
'3796122',
'4252048',
'3630117',
'3409839',
'4631183',
'3057542',
'3414342',
'4548748',
'4459845',
'3687485',
'3446374',
'4394408',
'4625444',
'3642270',
'3046007',
'3275563',
'4197346',
'3081573',
'4396366',
'3245834',
'3517216',
'3574349',
'3556414',
'4180737',
'3217591',
'4584610',
'3015036',
'3613721',
'3034054',
'3187265',
'3604794',
'3540936',
'4089827',
'3194296',
'3084482',
'3638754',
'3453336',
'4247541',
'4229236',
'3533265',
'3043124',
'3048243',
'3080741',
'3441684',
'4528755',
'4150626',
'4182731',
'4195993',
'3965863',
'4402533',
'3882618',
'3463958',
'3641739',
'3809300',
'3535422',
'3614808',
'3702002',
'3691480',
'3107498',
'3393368',
'3418439',
'3565830',
'3591132',
'3715735',
'3754927',
'3793060',
'4643060',
'4164065',
'4186308',
'4198684',
'4228570',
'4235935',
'4274821',
'4275322',
'4279022',
'4536898',
'4585335',
'4592442',
'3506063',
'4620659',
'4622300',
'4645502',
'4717955',
'4739443',
'4741416',
'5298720',
'4774555',
'4801100',
'5281786',
'4812800',
'5295706',
'5261644',
'5305600',
'5307627',
'3034404',
'3042183',
'3125147',
'3143192',
'3201606',
'3213258',
'3344016',
'3372255',
'3412275',
'3452942',
'3462708',
'4585027',
'3509211',
'3517203',
'3557378',
'3564683',
'3574519',
'3613218',
'3722161',
'3770540',
'3778818',
'3790920',
'3800660',
'3819397',
'3823652',
'3825289',
'3831581',
'3860095',
'3904896',
'3940470',
'3981866',
'4085778',
'4092740',
'4127954',
'4138098',
'4159383',
'4190959',
'4199589',
'4206256',
'4223368',
'4230352',
'4231713',
'4236611',
'4238701',
'4255493',
'4266927',
'4271320',
'4297298',
'4300095',
'4300436',
'4311270',
'4311747',
'4316586',
'4317618',
'4441405',
'4470667',
'4522383',
'4542963',
'4739051',
'4553162',
'4558007',
'4635112',
'4571397',
'4583698',
'4624047',
'4633511',
'4799528',
'4659350',
'4718444',
'4718467',
'4723138',
'4743194',
'4767549',
'4769056',
'4785741',
'4787286',
'4789772',
'4795210',
'4796886',
'4812670',
'4806337',
'4816892',
'3692243',
'5014314',
'5244449',
'5263073',
'5258632',
'5252355',
'5251762',
'5268167',
'5288367',
'5292685',
'5331830',
'3423365',
'4163033',
'4446673',
'4547897',
'4563391',
'5272696',
'5285843',
'5494760',
'3364486',
'3626069',
'4433094',
'4464554',
'4783691',
'5259758',
'4200742',
'4544991',
'3107704',
'4571268',
'5528144',
'5294504',
'5483467',
'5504678',
'5528197',
'4222087',
'4459994',
'4582931',
'4604927',
'4646855',
'4805582',
'5257058',
'5278513',
'3202500',
'3861097',
'4631077',
'4759669',
'5257915',
'5364882',
'5541941',
'5545919',
'5547704',
'5552034',
'5552056',
'4267056',
'4618192',
'4580039',
'5308440',
'3840991',
'4126782',
'4245024',
'4742574',
'4759478',
'3233378',
'4583172',
'3509293',
'3553870',
'3567772',
'3696540',
'3714985',
'3732534',
'3736566',
'3747040',
'3795080',
'3929460',
'4081500',
'4147110',
'4184642',
'4260499',
'4309450',
'4348641',
'4360440',
'4463008',
'4550899',
'4578038',
'4962285',
'4617766',
'4658183',
'4731571',
'3233418',
'4760708',
'4800301',
'4790181',
'5265148',
'5273556',
'3509627',
'4815507',
'5290054',
'4818278',
'5254746',
'5327713',
'5282830',
'5289473',
'5296793',
'5393075',
'5494420',
'5521627',
'5510407',
'5514662',
'5522782',
'5545686',
'5579700',
'5580232',
'5593871',
'5593962',
'5594937',
'4806858',
'5294766',
'3340894',
'3449438',
'3635608',
'3764874',
'4126645',
'4214622',
'4355171',
'4466560',
'4561719',
'5551404',
'5254237',
'5546643',
'5599197',
'4180488',
'4328129',
'4725663',
'4779488',
'5275779',
'5598493',
'3604788',
'3845338',
'4144601',
'4166585',
'4272473',
'4276321',
'4291446',
'4296819',
'4528368',
'4576792',
'4643889',
'4681377',
'4732922',
'5260219',
'5372608',
'5503211',
'5573048',
'5616737',
'5608855',
'5614472',
'5615688',
'5615749',
'5615778',
'5615823',
'5615828',
'5615883',
'5615952',
'5616660',
'5616802',
'5616807',
'5618064',
'5619219',
'5619551',
'3944889',
'4726645',
'4273566',
'3492282',
'4801678',
'4642162',
'4317118',
'5510280',
'4181117',
'4808707',
'4738050',
'4350376',
'3371240',
'4257172',
'5298120',
'5254852',
'4376599',
'4165030',
'5488075',
'4469618',
'4410468',
'4574046',
'4151011',
'4723986',
'4092870',
'4655909',
'5294786',
'5378466',
'5384393',
'5296962',
'5496243',
'5264418',
'5390081',
'3792798',
'5386654',
'5276312',
'4809820',
'4776172',
'4321844',
'4470397',
'5525389',
'3520892',
'3867398',
'4437744',
'5513259',
'3165849',
'3247721',
'3427253',
'3627123',
'3628265',
'3674436',
'3831579',
'4240661',
'4341064',
'4427756',
'4451749',
'5629158',
'4541383',
'4547906',
'4623811',
'5301007',
'5447955',
'5538299',
'5569437',
'5569889',
'5608860',
'5608866',
'5620474',
'5624686',
'5625623',
'5626231',
'3170680',
'3267170',
'3512574',
'3569109',
'3639475',
'3672654',
'3726452',
'3765235',
'4219287',
'4253999',
'4275933',
'4314517',
'4365416',
'4527581',
'4541678',
'3299379',
'4716803',
'4813937',
'3028879',
'5259955',
'5377693',
'5537266',
'5540517',
'5543840',
'5559434',
'5598545',
'5630291',
'5630525',
'5630669',
'5632374',
'3081915',
'3114065',
'3505941',
'3596775',
'3602582',
'3745608',
'3795015',
'3819279',
'3855974',
'3911718',
'4153557',
'4158861',
'4209773',
'4252885',
'4255181',
'4261642',
'4266757',
'4312507',
'4367654',
'4544672',
'4556047',
'3723442',
'4604856',
'4716993',
'4623722',
'5288031',
'4641361',
'4641502',
'4761833',
'4777184',
'4783434',
'4785354',
'5250425',
'4817254',
'5247014',
'5271677',
'5295783',
'5296243',
'5340366',
'5307349',
'5324938',
'5491604',
'5508664',
'5535623',
'5527095',
'5539668',
'5545840',
'5567692',
'5564141',
'5565993',
'5587788',
'5604877',
'5610874',
'5616752',
'5620482',
'5621095',
'5624742',
'5626576',
'5631091',
'5632085',
'5632104',
'5637253',
'5637057',
'5637243',
'5638249',
'5639303',
'5639378',
'5642081',
'5642322',
'5643154',
'5643533',
'5645732',
'5644842',
'5644843',
'5646267',
'5646434',
'5647178',
'5647238',
'5648443',
'5648736',
'5648766',
'5648772',
'5648784',
'5648800',
'3036801',
'3165261',
'3218973',
'3289946',
'3344719',
'3380401',
'3436784',
'3436850',
'3498101',
'3547146',
'3601368',
'3635273',
'3640476',
'3666201',
'3673613',
'3680198',
'3705678',
'3823613',
'3837133',
'3869061',
'3929630',
'4072083',
'4139753',
'4181882',
'4217189',
'4249258',
'4283254',
'4317537',
'4390568',
'4393616',
'4413403',
'4461972',
'4572454',
'4614871',
'3300247',
'4616515',
'4716992',
'4719602',
'4754673',
'4785415',
'4793090',
'4806616',
'5280568',
'5478594',
'5283683',
'5297441',
'5390343',
'5512756',
'5519950',
'5588862',
'5646320',
'5627216',
'5639482',
'5641775',
'5644804',
'5649709',
'5648437',
'5648642',
'5648653',
'5649996',
'5650730',
'5650782',
'5650793',
'5650940',
'5651024',
'5651049',
'5651057',
'5652093',
'5652165',
'5652168',
'5653236',
'5653398',
'5654103',
'5654435',
'5654570',
'5654623',
'5654685',
'5654811',
'5655793',
'5655862',
'5655923',
'5656483',
'5658180',
'5659160',
'5659591',
'5659664',
'5659704',
'5659725',
'5659896',
'5659966',
'5666709',
'5666801',
'5666870',
'3322748',
'3530495',
'3686496',
'3894150',
'4239231',
'4290095',
'4414066',
'4558799',
'5676984',
'4781480',
'5516409',
'5408817',
'5498249',
'5529932',
'5559817',
'5569725',
'5593315',
'5604781',
'5607279',
'5628787',
'5629056',
'5633497',
'5671071',
'5657471',
'5659650',
'5659726',
'5659724',
'5669454',
'5669487',
'5669527',
'5670539',
'5670550',
'5670946',
'5671042',
'5671048',
'5671052',
'5671057',
'5671067',
'5671400',
'5671555',
'5672080',
'5672394',
'5672417',
'5672598',
'5673374',
'5674048',
'5674239',
'5674554',
'5674685',
'5674761',
'5674766',
'5676395',
'5676500',
'5677857',
'3821903',
'5539462',
'5555390',
'3811287',
'3733339',
'4173028',
'5359121',
'3251320',
'3859872',
'4171505',
'5248465',
'5291373',
'4173098',
'3226592',
'3485812',
'3564391',
'3566082',
'3860355',
'4340367',
'4396454',
'4734637',
'5577532',
'5600279',
'5617872',
'5633244',
'5636916',
'5641963',
'5642067',
'5678946',
'5675586',
'5675720',
'5686185',
'3026098',
'3077478',
'3622357',
'3668683',
'3671918',
'3699562',
'3780692',
'3825458',
'4092961',
'4125901',
'4266050',
'4420646',
'4432052',
'4433361',
'4456294',
'4468395',
'5266017',
'4563537',
'3613190',
'4581874',
'4751628',
'4798008',
'4815132',
'5267840',
'5272243',
'5364212',
'5389476',
'5544657',
'5550781',
'5592117',
'5612658',
'5620072',
'5632379',
'5640961',
'5657797',
'5672272',
'5681169',
'5686388',
'5686786',
'5687078',
'5688897',
'5690376',
'5693160',
'5691490',
'5691656',
'5691691',
'5692296',
'5692518',
'5693668',
'5694462',
'5694471',
'5694506',
'3220714',
'5559232',
'5675671',
'5688160',
'5693249',
'5695318',
'3114597',
'3372047',
'3385021',
'3563301',
'3593518',
'3602679',
'3676773',
'3683015',
'3700620',
'3710893',
'3771166',
'3823275',
'3938093',
'4189039',
'4198749',
'4207198',
'4213912',
'4237655',
'4356594',
'4427895',
'4428600',
'4544829',
'4546363',
'4587243',
'4619844',
'4630944',
'4726487',
'4733031',
'4769352',
'4794149',
'4806564',
'5276416',
'5347640',
'5379555',
'5509185',
'5373424',
'5533063',
'5536835',
'5555442',
'5561417',
'5607518',
'5619038',
'5638654',
'5641150',
'5707201',
'5676860',
'5687102',
'5687116',
'5699719',
'5690247',
'5691033',
'5693764',
'5693774',
'5694587',
'5695884',
'5696214',
'5696218',
'5697025',
'5697806',
'5698752',
'5699989',
'5700041',
'5701283',
'5701319',
'5701361',
'5701372',
'5705157',
'5705329',
'5705364',
'5705372',
'5707189',
'5707239',
'3019159',
'3023933',
'3040441',
'3048571',
'3566398',
'3594625',
'3684781',
'3705479',
'3725039',
'3833627',
'4147389',
'4222471',
'4244792',
'4291874',
'4291892',
'4395237',
'4441575',
'5649517',
'5302530',
'4798944',
'4637033',
'5367196',
'4655974',
'4782233',
'5299712',
'5557940',
'5554537',
'5619105',
'5638241',
'5640101',
'5640669',
'5648079',
'5655287',
'5672439',
'5678326',
'5678710',
'5687611',
'5691506',
'5698142',
'5700093',
'5704798',
'5707283',
'5707304',
'5707325',
'5707778',
'5709408',
'5709925',
'5709917',
'5710251',
'5710275',
'5710363',
'5710705',
'5720356',
'5721508',
'5707189',
'5726127',
'5726124',
'5726149',
'5726209',
'5624686',
'5620482',
'5726272',
'5726735',
'5726751',
'5726968',
'5726984',
'5726973',
'5727039',
'5727082',
'5727139',
'5727382',
'3540979',
'4534538',
'4568567',
'5632773',
'5607964',
'5657015',
'5680689',
'5699242',
'5729527',
'5729595',
'5734454',
'5727881',
'5728596',
'5729609',
'5729606',
'5729610',
'5729606',
'5729677',
'4291874',
'5732322',
'5735198',
'5735567',
'3122907',
'3290398',
'3515036',
'3540956',
'4105855',
'4389860',
'4463354',
'4657935',
'4727816',
'4736230',
'4770529',
'5261991',
'5570205',
'5622798',
'5650251',
'5675532',
'5708496',
'5708547',
'5719248',
'5734871',
'5736869',
'5738068',
'5738082',
'5738101',
'5738110',
'5738120',
'5738314',
'5738703',
'5740673',
'4299895',
'4334540',
'4557362',
'5743453',
'4615202',
'4641514',
'5756294',
'5259962',
'5534170',
'5592320',
'5637109',
'5640263',
'5643397',
'5675657',
'5694242',
'5672394',
'5677600',
'5738718',
'5743330',
'5743575',
'5745355',
'5747349',
'5755445',
'5755823',
'5756694',
'5758188',
'5760176',
'3565931',
'3795263',
'4441765',
'4669538',
'4617847',
'5508033',
'5512726',
'4657615',
'5604798',
'5630712',
'5641587',
'5653993',
'5678119',
'5681856',
'5772388',
'5736517',
'5759745',
'5763838',
'5764294',
'5764784',
'5767494',
'4722247',
'5523921',
'5360467',
'5545254',
'5599571',
'5644163',
'5737794',
'5707283',
'5780735',
'5785372',
'3271120',
'4301324',
'4331238',
'4570441',
'4778818',
'5620008',
'5627221',
'5743847',
'5762232'
)


-- 在社区此地点击过 立即报名 的用户
select distinct t2.member_phone "手机号"
from (
	-- 神策平台取数
	select distinct distinct_id
	from events
	where event='Button_click'
	and btn_name='立即报名'
	and bussiness_name = '社区'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-06-02 13:30:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;



-- 过去12个月在社区有过发帖行为的用户
SELECT distinct tmi.member_phone "手机号"
from community.tm_post tp 
inner join `member`.tc_member_info tmi 
on tp.member_id = tmi.ID 
where tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.is_deleted <> 1       -- 删除确定是非1还是0
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
and tp.create_time + '12 month' >= '2023-06-02'
;



-- 参加过爱心计划委员会委员投票活动的用户  -- volvo提供数据


-- 6-1-1 参与并购买过沃世界22年春服、夏服、秋冬服产品的用户
select distinct m.member_phone "手机号"
from volvo_online_activity.season_activity_order t1 
inner join `member`.tc_member_info m
on t1.member_id = m.id 
and t1.code in ('spring_2022', 'summer_2022', 'winter_2022')
and t1.delete_flag = 0
and m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0
and m.is_vehicle = 1
;

-- 6-1-2 近3个月使用过沃尔沃汽车APP养修预约功能的车主
select distinct m.member_phone "手机号"
from member.tc_member_info m 
inner join (
	SELECT distinct a.one_id
	FROM cyx_appointment.`tt_appointment` a 
	left join `cyx_repair`.`tt_booking_order` c 
	on c.APPOINTMENT_ID = a.APPOINTMENT_ID 
	where a.APPOINTMENT_TYPE = '70691005' and a.IS_APP = 0 
	and c.BOOKING_SOURCE = '80101009'
	and c.created_at >= '2023-03-06'
	) am
on m.cust_id = am.one_id
where m.is_deleted = 0 
and m.member_status <> 60341003
and m.is_vehicle = 1
;



-- 6-1-3 近3个月于沃尔沃汽车App浏览【沃讲堂】系列文章的用户
select distinct tmi2.member_phone "手机号"
from community.tm_post tp 
inner join member.tc_member_info tmi 
on tp.member_id = tmi.id 
and tmi.id =6024362  -- 沃讲堂对应会员ID
inner join community.tt_view_post tvp 
on tp.post_id = tvp.post_id 
and tvp.is_deleted = 0
and tvp.create_time >= '2023-03-06'
inner join member.tc_member_info tmi2
on tvp.member_id = tmi2.id
and tmi2.MEMBER_STATUS <> 60341003
and tmi2.IS_DELETED = 0
and tmi2.is_vehicle = 1


-- 6-1-4 近3个月没有预约养修且近3个月沃尔沃汽车活跃车主
select distinct m.member_phone "手机号"
from (
	select t.usertag
	from track.track t 
	where t.date >= '2023-03-06'
	group by 1
	) t 
inner join member.tc_member_info m 
on t.usertag = cast(m.USER_ID as varchar)
and m.is_deleted = 0 
and m.member_status <> 60341003
left join (
	select distinct one_id
	FROM cyx_appointment.`tt_appointment`
	where created_at >= '2023-03-06'
	and APPOINTMENT_TYPE = '70691005'
	and is_deleted = 0
	) am
on m.cust_id = am.one_id
where am.one_id is null and m.is_vehicle = 1
;


-- 6-1-5 自在沃尔沃汽车APP商城上线以来，售后养护和充电专区有购买产品记录的用户
select distinct tm.member_phone "手机号"
from member.tc_member_info tm 
inner join (
	select a.user_id 会员id
		,a.user_name 会员姓名
		,b.spu_name 兑换商品
		,CASE  
			WHEN b.spu_type=51121001 THEN '精品' 
			WHEN b.spu_type=51121002 THEN '第三方卡券' 
			WHEN b.spu_type=51121003 and f.name not like '%充电%' THEN '保养类卡券' 
			WHEN f.name like '%充电%' THEN '充电产品' 
			WHEN b.spu_type=51121004 THEN '精品'
			WHEN b.spu_type=51121006 THEN '一件代发'
			WHEN b.spu_type=51121007 THEN '经销商端产品' ELSE null end 商品类型2
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	left join(
	--	#V值退款成功记录
		select so.order_code,sp.product_id
		,CASE so.status 
			WHEN 51171001 THEN '待审核' 
			WHEN 51171002 THEN '待退货入库' 
			WHEN 51171003 THEN '待退款' 
			WHEN 51171004 THEN '退款成功' 
			WHEN 51171005 THEN '退款失败' 
			WHEN 51171006 THEN '作废退货单' END AS 退货状态
		,sum(sp.sales_return_num) 退货数量
		,sum(so.refund_point) 退回V值
		,max(so.create_time) 退回时间
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 
		and so.status=51171004 -- 退款成功
		GROUP BY 1,2,3
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	--and e.退货状态='退款成功' 
	where a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	and (b.spu_type=51121003 or f.name like '%充电%')
	) p 
on tm.id = p.会员id
and tm.member_status <> 60341003 and tm.is_deleted = 0 and tm.is_vehicle = 1
;

-- 已参与23年先心捐赠V值的人群（6月1日先心捐赠短信推送人群包总和）
select distinct tm.id as member_id, tm.member_phone "手机号"
from volvo_online_activity.tt_love_donate_record ld
inner join member.tc_member_info tm
on tm.id = ld.member_id 
and tm.member_status <> 60341003 and tm.is_deleted = 0
and ld.is_deleted = 0
;


-- 近6个月登陆过沃尔沃汽车App和沃世界小程序的用户，剔除6月1日-6月7月通过活动页已捐赠的用户
select distinct m.member_phone "手机号"
from (
	select t.usertag
	from track.track t 
	where t.date >= '2022-12-06'
	group by 1
	) t 
inner join member.tc_member_info m 
on t.usertag = cast(m.USER_ID as varchar)
and m.is_deleted = 0 
and m.member_status <> 60341003
left join volvo_online_activity.tt_love_donate_record ld
on m.id = ld.member_id and ld.is_deleted = 0
where ld.member_id is null 
;


-- V值余额11-20或者大于500V的用户
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003
and (IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 500 or IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) between 11 and 20)
;


-- 人群包：App全量IOS平台用户（剔除已参与先心捐赠V值用户）
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-06-02 13:30:00'
	) t1 
left join (
	select cust_id, max(m.id) member_id, max(ld.id) love_id
	from member.tc_member_info m
	left join volvo_online_activity.tt_love_donate_record ld
	on m.id = ld.member_id and ld.is_deleted = 0
	where m.member_status <> 60341003 and m.is_deleted = 0
	group by 1
	) t2
on t1.distinct_id = t2.cust_id
where love_id is null
;


-- 6-1-1~6-1-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 第一个月预测过期v值数 >= 1500 then ' 6-1-1'
					when 是否车主 = 0 and 第一个月预测过期v值数 >= 1500 then ' 6-1-2'
					when 是否车主 = 1 and 第一个月预测过期v值数 < 1500 then ' 6-1-3'
					when 是否车主 = 0 and 第一个月预测过期v值数 < 1500 then ' 6-1-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值")) "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-07-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-06-01' and f.CREATE_TIME < '2021-07-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-06-08 00:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-06-08 00:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包, 会员id desc 
;


-- 开票3-5年S60+S60L绑车车主，省份为山东
select tm.model_name,substr(tcp.province_name,1,2) province, count(*) cnt
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
left join vehicle.tm_vehicle tv
on kp.vin = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
left join organization.tm_company tcp
on tcp.COMPANY_CODE = kp.dealer_code  and tcp.COMPANY_TYPE=15061003
left join member.tc_member_info tmi
on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where kp.invoice_date < '2020-06-13' and kp.is_deleted = 0 
-- and tcp.CITY_NAME = '青岛市'
and tcp.province_name like '%山东%'
and tm.model_name in ('S60', 'XC60', 'S90', 'XC90', 'S60L') 
and length(tmi.member_phone) = 11
group by 1,2
;

select *
from (
select case when tm.model_name in ('S60', 'S60L') then 'd6-3-1'
			when tm.model_name = 'XC60' then 'b6-3-2'
			when tm.model_name = 'S90' then 'c6-3-3'
			when tm.model_name = 'XC90' then 'a6-3-4'
			end as "人群包"
	,tm.model_name 
	,tmi.id  as member_id
	,tmi.member_phone 
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
left join vehicle.tm_vehicle tv
on kp.vin = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
left join organization.tm_company tcp
on tcp.COMPANY_CODE = kp.dealer_code  and tcp.COMPANY_TYPE=15061003
left join member.tc_member_info tmi
on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where kp.invoice_date < '2020-06-13' and kp.is_deleted = 0 
-- and tcp.CITY_NAME = '青岛市'
and tcp.province_name like '%山东%'
and tm.model_name in ('S60', 'XC60', 'S90', 'XC90', 'S60L') 
and length(tmi.member_phone) = 11
) tt 
order by "人群包"


-- 已领取618优惠券但仍未使用的用户  --4975
select distinct member_phone
from (
	select tmi.id
		,tmi.member_phone
		,a.coupon_id
		,sum(case when a.ticket_state = 31061003 then 1 else 0 end) as "卡券核销次数"
	FROM coupon.tt_coupon_detail a
	inner join "member".tc_member_info tmi 
	on a.one_id = tmi.CUST_ID 
	and a.is_deleted =0 
	and a.coupon_id in (4898, 4899)
	and length(tmi.member_phone) = 11
	and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
	group by 1,2,3
	) a 
where "卡券核销次数" = 0
;



select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-06-02 13:30:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 6-5-1 App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id,event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-06-21 14:00:00'
			group by 1,2
			) a
		) b
	where rn = 1 and event_type = 'Android'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1

-- 6-5-2 近3个月活跃但未在商城下单的用户
select distinct m.member_phone "手机号"
from (
	select t.usertag, max(t.`date`) max_date
	from track.track t 
	where t.date >= '2023-03-21'
	group by 1
	) t 
inner join member.tc_member_info m 
on t.usertag = cast(m.USER_ID as varchar)
and m.is_deleted = 0 and m.member_status <> 60341003
and t.max_date > m.MEMBER_TIME
left join (
	select a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time >= '2023-03-21'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) tr 
on m.id = tr.user_id
where tr.user_id is null
;


-- 6-5-3 近1个月登录过小程序，但从未登录过App的车主（取30万）-- 数据量不够则调整活跃时间
select distinct tt.手机号
from (
	select m.id 会员ID, m.cust_id, m.member_phone 手机号
	from (
		select t.usertag, max(t.`date`) max_date
		from track.track t 
		where t.date >= '2023-05-21'
		group by 1
		) t 
	inner join member.tc_member_info m 
	on t.usertag = cast(m.USER_ID as varchar)
	and m.is_deleted = 0 
	and m.IS_VEHICLE = 1
	and m.member_status <> 60341003
	where t.max_date > m.MEMBER_TIME
	) tt 
left join (
	-- 神策平台取数
	select distinct distinct_id
	from events where $lib in ('iOS','Android')
	and time between '2022-02-01' and '2023-06-21 14:00:00'
	and length(distinct_id)<9
	) t1 
on tt.cust_id = t1.distinct_id
where t1.distinct_id is null
;

-- 6-5-4 小程序端/App端已点亮【WOW辈楷模】电子勋章用户
select DISTINCT d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
inner join mine.user_medal e on e.id = c.medal_id and e.medal_name = 'WOW辈楷模'
where c.create_time <= '2023-06-21 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
;


-- 6-5-5 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct_id
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-06-24 14:00:00'
			group by 1,2
			) a
		) b
	where rn = 1 and event_type = 'iOS'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;



-- 6-1-5~6-1-8 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 第一个月预测过期v值数 >= 1500 then ' 6-1-5'
					when 是否车主 = 0 and 第一个月预测过期v值数 >= 1500 then ' 6-1-6'
					when 是否车主 = 1 and 第一个月预测过期v值数 < 1500 then ' 6-1-7'
					when 是否车主 = 0 and 第一个月预测过期v值数 < 1500 then ' 6-1-8'
					end as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值") "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-07-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-06-01' and f.CREATE_TIME < '2021-07-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-06-29 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-06-29 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1,2,3,4
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包, 会员id desc 
;



-- 6-7-1 账号中有未核销的卡券代码为4983、4984、4982的人群，手机号需要去重
select distinct member_phone
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.one_id = tmi.CUST_ID 
and a.is_deleted = 0 
and a.coupon_id in (4983, 4984, 4982)
and a.ticket_state <> 31061003
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 7-2-1 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-07-07 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

      
-- 7-2-2 所有电车绑车车主
select distinct tmi.member_phone -- vr.vin_code,tmi.member_phone
	-- ,tm.model_name "车型",tc.config_name "配置" 
from member.tc_member_info tmi
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on vr.member_id = tmi.id and vr.rn = 1
left join vehicle.tm_vehicle tv
on vr.vin_code = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
left join basic_data.tm_config tc 
on tv.config_id = tc.id
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
and tm.model_name in ('XC40 RECHARGE', '全新纯电C40')
;



-- 7-2-3~4 近一年有商城订单的粉丝或车主
select distinct m.member_phone "手机号"
	,case when m.is_vehicle=1 then '7-2-4' else '7-2-3' end as "人群包"
from member.tc_member_info m 
inner join (
	select a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b 
	on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time >= '2022-07-07'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) tr 
on m.id = tr.user_id
and m.is_deleted = 0 and m.member_status <> 60341003
;

-- 7-2-5 近3个月有发布动态的用户
SELECT distinct tmi.member_phone "手机号"
from community.tm_post tp 
inner join `member`.tc_member_info tmi 
on tp.member_id = tmi.ID 
and tp.post_type = 1001   -- 1001动态，1007UGC文章即用户文章
and tp.create_time >= '2023-04-07'
where tp.is_deleted <> 1
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 7-2-6 V值余额大于200V的用户
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 200
;



-- 7-1-1~7-1-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 第一个月预测过期v值数 >= 1500 then ' 7-1-1'
					when 是否车主 = 0 and 第一个月预测过期v值数 >= 1500 then ' 7-1-2'
					when 是否车主 = 1 and 第一个月预测过期v值数 < 1500 then ' 7-1-3'
					when 是否车主 = 0 and 第一个月预测过期v值数 < 1500 then ' 7-1-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值") "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-07-01' and f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-07-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-07-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1,2,3,4
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包, 会员id desc 
;



-- 7-1-1~7-1-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 第一个月预测过期v值数 >= 1500 then ' 7-1-1'
					when 是否车主 = 0 and 第一个月预测过期v值数 >= 1500 then ' 7-1-2'
					when 是否车主 = 1 and 第一个月预测过期v值数 < 1500 then ' 7-1-3'
					when 是否车主 = 0 and 第一个月预测过期v值数 < 1500 then ' 7-1-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值") "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-07-01' and f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-07-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-07-10 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1,2,3,4
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
and 会员id not in (
3014921
,3015176
,3017603
,3018733
,3019206
,3019804
,3021144
,3021825
,3025961
,3028190
,3028306
,3028394
,3029111
,3029591
,3031918
,3031949
,3032079
,3032348
,3033539
,3034037
,3034389
,3034408
,3034602
,3034795
,3035142
,3035480
,3036630
,3036821
,3036897
,3037374
,3037788
,3038850
,3039543
,3039893
,3040014
,3040204
,3041140
,3043052
,3044813
,3044815
,3045138
,3046906
,3047407
,3048494
,3052502
,3052605
,3053569
,3053661
,3054288
,3054315
,3054934
,3055151
,3055182
,3058041
,3058072
,3058157
,3060067
,3061335
,3061959
,3062358
,3062500
,3067259
,3067565
,3070086
,3071443
,3072629
,3075063
,3076474
,3076919
,3077553
,3078091
,3079123
,3079451
,3079549
,3081573
,3081630
,3087756
,3088405
,3089269
,3090638
,3090642
,3093001
,3093901
,3094140
,3097143
,3097765
,3099822
,3100025
,3101898
,3103237
,3108318
,3108458
,3108503
,3108676
,3108735
,3111641
,3116505
,3117693
,3118055
,3122818
,3126806
,3129045
,3131090
,3131447
,3131892
,3134133
,3134628
,3135720
,3136662
,3139426
,3144898
,3148410
,3149730
,3149960
,3150980
,3154271
,3154687
,3156414
,3157061
,3157437
,3157863
,3161959
,3162882
,3164077
,3166636
,3169055
,3176846
,3177192
,3177292
,3177352
,3177685
,3178003
,3178434
,3181609
,3183021
,3188368
,3188534
,3190318
,3193655
,3195126
,3199796
,3201090
,3203420
,3204717
,3204720
,3206416
,3206687
,3207561
,3208330
,3209351
,3209493
,3211018
,3211262
,3211341
,3211861
,3214957
,3214971
,3217811
,3225898
,3230901
,3235358
,3236855
,3237181
,3239549
,3241417
,3241430
,3244408
,3245077
,3245163
,3245834
,3248632
,3249709
,3250714
,3251496
,3251536
,3251554
,3253757
,3253892
,3254017
,3255614
,3255880
,3257731
,3258328
,3259853
,3259970
,3261664
,3261893
,3263619
,3264392
,3265027
,3265080
,3266676
,3269307
,3271574
,3275132
,3276966
,3277306
,3279516
,3282972
,3283069
,3287386
,3291770
,3292668
,3297263
,3299400
,3303923
,3306957
,3307492
,3309993
,3313175
,3315521
,3318942
,3319487
,3320196
,3321628
,3323470
,3323703
,3324507
,3325479
,3327287
,3327716
,3330047
,3331416
,3331619
,3332418
,3332883
,3333290
,3333951
,3335140
,3337076
,3338264
,3341094
,3343985
,3345218
,3348861
,3349832
,3350199
,3350655
,3350912
,3353088
,3353678
,3359605
,3360338
,3362412
,3363222
,3363556
,3365312
,3365497
,3368731
,3370403
,3371339
,3373315
,3373602
,3374467
,3375754
,3376365
,3379832
,3379932
,3382234
,3382452
,3383838
,3385488
,3392452
,3392593
,3393121
,3396820
,3397547
,3399720
,3400108
,3401268
,3401703
,3401811
,3402561
,3404291
,3406372
,3408275
,3408838
,3409601
,3409802
,3412424
,3412902
,3413570
,3413832
,3414310
,3417843
,3420313
,3421063
,3422232
,3423241
,3424734
,3426160
,3429135
,3429818
,3432560
,3434200
,3434211
,3434317
,3434322
,3434985
,3436596
,3437285
,3440880
,3442942
,3443872
,3445099
,3445868
,3447010
,3447457
,3448402
,3449560
,3449585
,3450702
,3450913
,3452659
,3453614
,3454672
,3456507
,3456593
,3462094
,3462434
,3463081
,3465074
,3465276
,3465342
,3466646
,3467015
,3467509
,3467957
,3469342
,3470549
,3473085
,3474875
,3476239
,3476259
,3481021
,3486591
,3487523
,3491251
,3491776
,3492414
,3493900
,3497313
,3502509
,3505318
,3507335
,3509468
,3510652
,3512246
,3513083
,3513735
,3515204
,3517583
,3519259
,3520759
,3520899
,3521716
,3525026
,3526191
,3526204
,3526229
,3528277
,3528931
,3529229
,3529760
,3530939
,3530983
,3531187
,3531921
,3533261
,3533938
,3536142
,3538526
,3539594
,3540874
,3541105
,3543089
,3545015
,3548119
,3548444
,3549023
,3549120
,3550016
,3551242
,3552079
,3552547
,3554085
,3554642
,3556591
,3557016
,3557197
,3558928
,3559820
,3563592
,3564399
,3565463
,3565789
,3566037
,3568094
,3568806
,3569342
,3569795
,3571194
,3574365
,3575218
,3575727
,3576317
,3577518
,3579173
,3579327
,3581879
,3582186
,3585375
,3585992
,3586032
,3588412
,3588531
,3589023
,3589290
,3590446
,3590588
,3590754
,3591892
,3592517
,3595235
,3596711
,3597428
,3599139
,3599942
,3600930
,3601703
,3603691
,3604277
,3604794
,3613158
,3613208
,3615152
,3615206
,3616316
,3622513
,3622557
,3623546
,3627333
,3629036
,3630180
,3630581
,3634746
,3635153
,3637224
,3637772
,3639927
,3641856
,3645509
,3646074
,3666727
,3667066
,3670225
,3673882
,3677021
,3677062
,3679689
,3680666
,3681221
,3682179
,3682393
,3685227
,3687318
,3687719
,3687830
,3689367
,3690643
,3690979
,3691229
,3691314
,3691532
,3692206
,3692863
,3695386
,3695578
,3695806
,3698048
,3698225
,3700684
,3703249
,3704106
,3704795
,3705609
,3706299
,3708137
,3708392
,3708560
,3708599
,3709587
,3711688
,3711931
,3712407
,3714798
,3715053
,3715735
,3715905
,3715926
,3716661
,3717270
,3717444
,3717519
,3719964
,3721402
,3722040
,3722960
,3723010
,3723048
,3724898
,3725847
,3726446
,3726542
,3727892
,3728118
,3728664
,3729646
,3729898
,3730819
,3730851
,3733941
,3734158
,3734446
,3736530
,3737096
,3737990
,3738627
,3739311
,3739640
,3742091
,3744131
,3745034
,3745634
,3745797
,3747335
,3753142
,3758023
,3758342
,3758849
,3763398
,3766276
,3770992
,3772732
,3773874
,3775538
,3775818
,3776174
,3776656
,3778144
,3779612
,3780839
,3782799
,3784087
,3785650
,3786126
,3786797
,3789958
,3790397
,3791025
,3791260
,3791282
,3791358
,3793138
,3793568
,3793967
,3795514
,3796859
,3798375
,3800669
,3801189
,3801898
,3802840
,3803073
,3803230
,3803300
,3803446
,3804065
,3806331
,3807878
,3810215
,3811689
,3812603
,3814482
,3814686
,3814705
,3819675
,3822616
,3822814
,3823171
,3825417
,3827728
,3828440
,3828900
,3828975
,3829218
,3829555
,3829867
,3830540
,3831317
,3831581
,3831734
,3833063
,3833978
,3836252
,3837129
,3837782
,3838077
,3838178
,3838891
,3839352
,3840037
,3840468
,3840875
,3840970
,3844064
,3845704
,3845759
,3845889
,3848247
,3849807
,3850001
,3850485
,3852723
,3853296
,3853508
,3854231
,3854568
,3854894
,3857067
,3857540
,3857783
,3860095
,3860367
,3860816
,3860984
,3861177
,3865861
,3867646
,3871037
,3880418
,3892733
,3893134
,3898909
,3906471
,3918792
,3923490
,3933474
,3943178
,3967447
,4019046
,4021061
,4023144
,4025053
,4025176
,4025560
,4030805
,4039558
,4054315
,4069439
,4070139
,4077412
,4077839
,4078417
,4079784
,4080944
,4083637
,4083716
,4084222
,4084351
,4084506
,4085694
,4086279
,4086782
,4087094
,4087377
,4088574
,4088865
,4089286
,4089329
,4089948
,4090515
,4090677
,4090806
,4091314
,4091674
,4092101
,4107820
,4109837
,4111984
,4113843
,4113951
,4114957
,4117138
,4130658
,4130725
,4132494
,4149841
,4149876
,4152213
,4153066
,4157050
,4169405
,4169743
,4172754
,4176174
,4177021
,4177700
,4178885
,4180989
,4184072
,4184587
,4184943
,4185454
,4185530
,4188788
,4199395
,4202762
,4215699
,4238196
,4248836
,4280467
,4283973
,4295544
,4312761
,4543919
,4737006
,5253300
,5286084
,6762264
,6843468
,7104583)
order by 人群包, 会员id desc 
;


-- 7-1-7 车主&粉丝：上个自然月累计获得V值大于等于300V的人群
select m.MEMBER_PHONE "手机号", count(distinct f.MEMBER_ID) "会员id数", sum(INTEGRAL) "获得V值"
from `member`.tt_member_flow_record f     -- 流水表
inner join `member`.tc_member_info m on f.MEMBER_ID = m.ID
and f.IS_DELETED = 0 and f.RECORD_TYPE = 0
and left(f.CREATE_TIME, 7) = '2023-06'
and m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0 and m.id <> 6247382
where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
and f.MEMBER_ID not in (
3014921
,3015176
,3017603
,3018733
,3019206
,3019804
,3021144
,3021825
,3025961
,3028190
,3028306
,3028394
,3029111
,3029591
,3031918
,3031949
,3032079
,3032348
,3033539
,3034037
,3034389
,3034408
,3034602
,3034795
,3035142
,3035480
,3036630
,3036821
,3036897
,3037374
,3037788
,3038850
,3039543
,3039893
,3040014
,3040204
,3041140
,3043052
,3044813
,3044815
,3045138
,3046906
,3047407
,3048494
,3052502
,3052605
,3053569
,3053661
,3054288
,3054315
,3054934
,3055151
,3055182
,3058041
,3058072
,3058157
,3060067
,3061335
,3061959
,3062358
,3062500
,3067259
,3067565
,3070086
,3071443
,3072629
,3075063
,3076474
,3076919
,3077553
,3078091
,3079123
,3079451
,3079549
,3081573
,3081630
,3087756
,3088405
,3089269
,3090638
,3090642
,3093001
,3093901
,3094140
,3097143
,3097765
,3099822
,3100025
,3101898
,3103237
,3108318
,3108458
,3108503
,3108676
,3108735
,3111641
,3116505
,3117693
,3118055
,3122818
,3126806
,3129045
,3131090
,3131447
,3131892
,3134133
,3134628
,3135720
,3136662
,3139426
,3144898
,3148410
,3149730
,3149960
,3150980
,3154271
,3154687
,3156414
,3157061
,3157437
,3157863
,3161959
,3162882
,3164077
,3166636
,3169055
,3176846
,3177192
,3177292
,3177352
,3177685
,3178003
,3178434
,3181609
,3183021
,3188368
,3188534
,3190318
,3193655
,3195126
,3199796
,3201090
,3203420
,3204717
,3204720
,3206416
,3206687
,3207561
,3208330
,3209351
,3209493
,3211018
,3211262
,3211341
,3211861
,3214957
,3214971
,3217811
,3225898
,3230901
,3235358
,3236855
,3237181
,3239549
,3241417
,3241430
,3244408
,3245077
,3245163
,3245834
,3248632
,3249709
,3250714
,3251496
,3251536
,3251554
,3253757
,3253892
,3254017
,3255614
,3255880
,3257731
,3258328
,3259853
,3259970
,3261664
,3261893
,3263619
,3264392
,3265027
,3265080
,3266676
,3269307
,3271574
,3275132
,3276966
,3277306
,3279516
,3282972
,3283069
,3287386
,3291770
,3292668
,3297263
,3299400
,3303923
,3306957
,3307492
,3309993
,3313175
,3315521
,3318942
,3319487
,3320196
,3321628
,3323470
,3323703
,3324507
,3325479
,3327287
,3327716
,3330047
,3331416
,3331619
,3332418
,3332883
,3333290
,3333951
,3335140
,3337076
,3338264
,3341094
,3343985
,3345218
,3348861
,3349832
,3350199
,3350655
,3350912
,3353088
,3353678
,3359605
,3360338
,3362412
,3363222
,3363556
,3365312
,3365497
,3368731
,3370403
,3371339
,3373315
,3373602
,3374467
,3375754
,3376365
,3379832
,3379932
,3382234
,3382452
,3383838
,3385488
,3392452
,3392593
,3393121
,3396820
,3397547
,3399720
,3400108
,3401268
,3401703
,3401811
,3402561
,3404291
,3406372
,3408275
,3408838
,3409601
,3409802
,3412424
,3412902
,3413570
,3413832
,3414310
,3417843
,3420313
,3421063
,3422232
,3423241
,3424734
,3426160
,3429135
,3429818
,3432560
,3434200
,3434211
,3434317
,3434322
,3434985
,3436596
,3437285
,3440880
,3442942
,3443872
,3445099
,3445868
,3447010
,3447457
,3448402
,3449560
,3449585
,3450702
,3450913
,3452659
,3453614
,3454672
,3456507
,3456593
,3462094
,3462434
,3463081
,3465074
,3465276
,3465342
,3466646
,3467015
,3467509
,3467957
,3469342
,3470549
,3473085
,3474875
,3476239
,3476259
,3481021
,3486591
,3487523
,3491251
,3491776
,3492414
,3493900
,3497313
,3502509
,3505318
,3507335
,3509468
,3510652
,3512246
,3513083
,3513735
,3515204
,3517583
,3519259
,3520759
,3520899
,3521716
,3525026
,3526191
,3526204
,3526229
,3528277
,3528931
,3529229
,3529760
,3530939
,3530983
,3531187
,3531921
,3533261
,3533938
,3536142
,3538526
,3539594
,3540874
,3541105
,3543089
,3545015
,3548119
,3548444
,3549023
,3549120
,3550016
,3551242
,3552079
,3552547
,3554085
,3554642
,3556591
,3557016
,3557197
,3558928
,3559820
,3563592
,3564399
,3565463
,3565789
,3566037
,3568094
,3568806
,3569342
,3569795
,3571194
,3574365
,3575218
,3575727
,3576317
,3577518
,3579173
,3579327
,3581879
,3582186
,3585375
,3585992
,3586032
,3588412
,3588531
,3589023
,3589290
,3590446
,3590588
,3590754
,3591892
,3592517
,3595235
,3596711
,3597428
,3599139
,3599942
,3600930
,3601703
,3603691
,3604277
,3604794
,3613158
,3613208
,3615152
,3615206
,3616316
,3622513
,3622557
,3623546
,3627333
,3629036
,3630180
,3630581
,3634746
,3635153
,3637224
,3637772
,3639927
,3641856
,3645509
,3646074
,3666727
,3667066
,3670225
,3673882
,3677021
,3677062
,3679689
,3680666
,3681221
,3682179
,3682393
,3685227
,3687318
,3687719
,3687830
,3689367
,3690643
,3690979
,3691229
,3691314
,3691532
,3692206
,3692863
,3695386
,3695578
,3695806
,3698048
,3698225
,3700684
,3703249
,3704106
,3704795
,3705609
,3706299
,3708137
,3708392
,3708560
,3708599
,3709587
,3711688
,3711931
,3712407
,3714798
,3715053
,3715735
,3715905
,3715926
,3716661
,3717270
,3717444
,3717519
,3719964
,3721402
,3722040
,3722960
,3723010
,3723048
,3724898
,3725847
,3726446
,3726542
,3727892
,3728118
,3728664
,3729646
,3729898
,3730819
,3730851
,3733941
,3734158
,3734446
,3736530
,3737096
,3737990
,3738627
,3739311
,3739640
,3742091
,3744131
,3745034
,3745634
,3745797
,3747335
,3753142
,3758023
,3758342
,3758849
,3763398
,3766276
,3770992
,3772732
,3773874
,3775538
,3775818
,3776174
,3776656
,3778144
,3779612
,3780839
,3782799
,3784087
,3785650
,3786126
,3786797
,3789958
,3790397
,3791025
,3791260
,3791282
,3791358
,3793138
,3793568
,3793967
,3795514
,3796859
,3798375
,3800669
,3801189
,3801898
,3802840
,3803073
,3803230
,3803300
,3803446
,3804065
,3806331
,3807878
,3810215
,3811689
,3812603
,3814482
,3814686
,3814705
,3819675
,3822616
,3822814
,3823171
,3825417
,3827728
,3828440
,3828900
,3828975
,3829218
,3829555
,3829867
,3830540
,3831317
,3831581
,3831734
,3833063
,3833978
,3836252
,3837129
,3837782
,3838077
,3838178
,3838891
,3839352
,3840037
,3840468
,3840875
,3840970
,3844064
,3845704
,3845759
,3845889
,3848247
,3849807
,3850001
,3850485
,3852723
,3853296
,3853508
,3854231
,3854568
,3854894
,3857067
,3857540
,3857783
,3860095
,3860367
,3860816
,3860984
,3861177
,3865861
,3867646
,3871037
,3880418
,3892733
,3893134
,3898909
,3906471
,3918792
,3923490
,3933474
,3943178
,3967447
,4019046
,4021061
,4023144
,4025053
,4025176
,4025560
,4030805
,4039558
,4054315
,4069439
,4070139
,4077412
,4077839
,4078417
,4079784
,4080944
,4083637
,4083716
,4084222
,4084351
,4084506
,4085694
,4086279
,4086782
,4087094
,4087377
,4088574
,4088865
,4089286
,4089329
,4089948
,4090515
,4090677
,4090806
,4091314
,4091674
,4092101
,4107820
,4109837
,4111984
,4113843
,4113951
,4114957
,4117138
,4130658
,4130725
,4132494
,4149841
,4149876
,4152213
,4153066
,4157050
,4169405
,4169743
,4172754
,4176174
,4177021
,4177700
,4178885
,4180989
,4184072
,4184587
,4184943
,4185454
,4185530
,4188788
,4199395
,4202762
,4215699
,4238196
,4248836
,4280467
,4283973
,4295544
,4312761
,4543919
,4737006
,5253300
,5286084
,6762264
,6843468
,7104583)
group by 1
having sum(INTEGRAL) >= 300
;	




-- 7-4-1 开票经销商区域为北区，且开票时间3年以上（小于2020-06-13）的S60+S60L绑车车主（剔除山东省车辆）-- 去重
select case when tm.model_name in ('S60', 'S60L') then 'd7-4-1'
			when tm.model_name = 'XC60' then 'b7-4-2'
			when tm.model_name = 'S90' then 'c7-4-3'
			when tm.model_name = 'XC90' then 'a7-4-4'
			end as "人群包"
	,tg.CITY_NAME as "开票经销商城市"
	,tm.model_name 
	,tmi.id  as member_id
	,tmi.member_phone 
-- select count (*), count(distinct kp.vin)
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select vin_code, member_id
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
inner join (
	select tm.COMPANY_CODE,
		tm.ORG_ID 经销商组织ID,
	    case when tm.city_name like '%市' then left(tm.city_name, length(tm.city_name)-1) else tm.city_name end CITY_NAME,
	    to1.ID 大区组织ID,
	    to1.ORG_NAME 大区名称
	from organization.tm_company tm
	inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	inner JOIN organization.tm_org to1 ON to1.id = tr2.parent_org_id and to1.ORG_TYPE = 15061005 
	where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	and tm.province_name not like '%山东%'
	) tg
on kp.dealer_code = tg.COMPANY_CODE and tg.大区名称='北区'
left join vehicle.tm_vehicle tv
on kp.vin = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
where kp.invoice_date < '2020-07-14' and kp.is_deleted = 0 
and tm.model_name in ('S60', 'XC60', 'S90', 'XC90', 'S60L') 
and length(tmi.member_phone) = 11
order by 1,2
;



-- 7-2-7 已购买优惠券但未使用的用户（券ID5269、5270）
select distinct tmi.member_phone 
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.member_id  = tmi.id 
and a.is_deleted =0 and a.ticket_state = 31061001
and a.coupon_id in (5269, 5270)
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;



-- 7-1-5 车主&粉丝：下月1号即将有过期V值
select ' 7-1-5' as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值") "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-07-01' and f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-07-21 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-07-21 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1,2,3,4
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
and 会员id not in (
3014921
,3015176
,3017603
,3018733
,3019206
,3019804
,3021144
,3021825
,3025961
,3028190
,3028306
,3028394
,3029111
,3029591
,3031918
,3031949
,3032079
,3032348
,3033539
,3034037
,3034389
,3034408
,3034602
,3034795
,3035142
,3035480
,3036630
,3036821
,3036897
,3037374
,3037788
,3038850
,3039543
,3039893
,3040014
,3040204
,3041140
,3043052
,3044813
,3044815
,3045138
,3046906
,3047407
,3048494
,3052502
,3052605
,3053569
,3053661
,3054288
,3054315
,3054934
,3055151
,3055182
,3058041
,3058072
,3058157
,3060067
,3061335
,3061959
,3062358
,3062500
,3067259
,3067565
,3070086
,3071443
,3072629
,3075063
,3076474
,3076919
,3077553
,3078091
,3079123
,3079451
,3079549
,3081573
,3081630
,3087756
,3088405
,3089269
,3090638
,3090642
,3093001
,3093901
,3094140
,3097143
,3097765
,3099822
,3100025
,3101898
,3103237
,3108318
,3108458
,3108503
,3108676
,3108735
,3111641
,3116505
,3117693
,3118055
,3122818
,3126806
,3129045
,3131090
,3131447
,3131892
,3134133
,3134628
,3135720
,3136662
,3139426
,3144898
,3148410
,3149730
,3149960
,3150980
,3154271
,3154687
,3156414
,3157061
,3157437
,3157863
,3161959
,3162882
,3164077
,3166636
,3169055
,3176846
,3177192
,3177292
,3177352
,3177685
,3178003
,3178434
,3181609
,3183021
,3188368
,3188534
,3190318
,3193655
,3195126
,3199796
,3201090
,3203420
,3204717
,3204720
,3206416
,3206687
,3207561
,3208330
,3209351
,3209493
,3211018
,3211262
,3211341
,3211861
,3214957
,3214971
,3217811
,3225898
,3230901
,3235358
,3236855
,3237181
,3239549
,3241417
,3241430
,3244408
,3245077
,3245163
,3245834
,3248632
,3249709
,3250714
,3251496
,3251536
,3251554
,3253757
,3253892
,3254017
,3255614
,3255880
,3257731
,3258328
,3259853
,3259970
,3261664
,3261893
,3263619
,3264392
,3265027
,3265080
,3266676
,3269307
,3271574
,3275132
,3276966
,3277306
,3279516
,3282972
,3283069
,3287386
,3291770
,3292668
,3297263
,3299400
,3303923
,3306957
,3307492
,3309993
,3313175
,3315521
,3318942
,3319487
,3320196
,3321628
,3323470
,3323703
,3324507
,3325479
,3327287
,3327716
,3330047
,3331416
,3331619
,3332418
,3332883
,3333290
,3333951
,3335140
,3337076
,3338264
,3341094
,3343985
,3345218
,3348861
,3349832
,3350199
,3350655
,3350912
,3353088
,3353678
,3359605
,3360338
,3362412
,3363222
,3363556
,3365312
,3365497
,3368731
,3370403
,3371339
,3373315
,3373602
,3374467
,3375754
,3376365
,3379832
,3379932
,3382234
,3382452
,3383838
,3385488
,3392452
,3392593
,3393121
,3396820
,3397547
,3399720
,3400108
,3401268
,3401703
,3401811
,3402561
,3404291
,3406372
,3408275
,3408838
,3409601
,3409802
,3412424
,3412902
,3413570
,3413832
,3414310
,3417843
,3420313
,3421063
,3422232
,3423241
,3424734
,3426160
,3429135
,3429818
,3432560
,3434200
,3434211
,3434317
,3434322
,3434985
,3436596
,3437285
,3440880
,3442942
,3443872
,3445099
,3445868
,3447010
,3447457
,3448402
,3449560
,3449585
,3450702
,3450913
,3452659
,3453614
,3454672
,3456507
,3456593
,3462094
,3462434
,3463081
,3465074
,3465276
,3465342
,3466646
,3467015
,3467509
,3467957
,3469342
,3470549
,3473085
,3474875
,3476239
,3476259
,3481021
,3486591
,3487523
,3491251
,3491776
,3492414
,3493900
,3497313
,3502509
,3505318
,3507335
,3509468
,3510652
,3512246
,3513083
,3513735
,3515204
,3517583
,3519259
,3520759
,3520899
,3521716
,3525026
,3526191
,3526204
,3526229
,3528277
,3528931
,3529229
,3529760
,3530939
,3530983
,3531187
,3531921
,3533261
,3533938
,3536142
,3538526
,3539594
,3540874
,3541105
,3543089
,3545015
,3548119
,3548444
,3549023
,3549120
,3550016
,3551242
,3552079
,3552547
,3554085
,3554642
,3556591
,3557016
,3557197
,3558928
,3559820
,3563592
,3564399
,3565463
,3565789
,3566037
,3568094
,3568806
,3569342
,3569795
,3571194
,3574365
,3575218
,3575727
,3576317
,3577518
,3579173
,3579327
,3581879
,3582186
,3585375
,3585992
,3586032
,3588412
,3588531
,3589023
,3589290
,3590446
,3590588
,3590754
,3591892
,3592517
,3595235
,3596711
,3597428
,3599139
,3599942
,3600930
,3601703
,3603691
,3604277
,3604794
,3613158
,3613208
,3615152
,3615206
,3616316
,3622513
,3622557
,3623546
,3627333
,3629036
,3630180
,3630581
,3634746
,3635153
,3637224
,3637772
,3639927
,3641856
,3645509
,3646074
,3666727
,3667066
,3670225
,3673882
,3677021
,3677062
,3679689
,3680666
,3681221
,3682179
,3682393
,3685227
,3687318
,3687719
,3687830
,3689367
,3690643
,3690979
,3691229
,3691314
,3691532
,3692206
,3692863
,3695386
,3695578
,3695806
,3698048
,3698225
,3700684
,3703249
,3704106
,3704795
,3705609
,3706299
,3708137
,3708392
,3708560
,3708599
,3709587
,3711688
,3711931
,3712407
,3714798
,3715053
,3715735
,3715905
,3715926
,3716661
,3717270
,3717444
,3717519
,3719964
,3721402
,3722040
,3722960
,3723010
,3723048
,3724898
,3725847
,3726446
,3726542
,3727892
,3728118
,3728664
,3729646
,3729898
,3730819
,3730851
,3733941
,3734158
,3734446
,3736530
,3737096
,3737990
,3738627
,3739311
,3739640
,3742091
,3744131
,3745034
,3745634
,3745797
,3747335
,3753142
,3758023
,3758342
,3758849
,3763398
,3766276
,3770992
,3772732
,3773874
,3775538
,3775818
,3776174
,3776656
,3778144
,3779612
,3780839
,3782799
,3784087
,3785650
,3786126
,3786797
,3789958
,3790397
,3791025
,3791260
,3791282
,3791358
,3793138
,3793568
,3793967
,3795514
,3796859
,3798375
,3800669
,3801189
,3801898
,3802840
,3803073
,3803230
,3803300
,3803446
,3804065
,3806331
,3807878
,3810215
,3811689
,3812603
,3814482
,3814686
,3814705
,3819675
,3822616
,3822814
,3823171
,3825417
,3827728
,3828440
,3828900
,3828975
,3829218
,3829555
,3829867
,3830540
,3831317
,3831581
,3831734
,3833063
,3833978
,3836252
,3837129
,3837782
,3838077
,3838178
,3838891
,3839352
,3840037
,3840468
,3840875
,3840970
,3844064
,3845704
,3845759
,3845889
,3848247
,3849807
,3850001
,3850485
,3852723
,3853296
,3853508
,3854231
,3854568
,3854894
,3857067
,3857540
,3857783
,3860095
,3860367
,3860816
,3860984
,3861177
,3865861
,3867646
,3871037
,3880418
,3892733
,3893134
,3898909
,3906471
,3918792
,3923490
,3933474
,3943178
,3967447
,4019046
,4021061
,4023144
,4025053
,4025176
,4025560
,4030805
,4039558
,4054315
,4069439
,4070139
,4077412
,4077839
,4078417
,4079784
,4080944
,4083637
,4083716
,4084222
,4084351
,4084506
,4085694
,4086279
,4086782
,4087094
,4087377
,4088574
,4088865
,4089286
,4089329
,4089948
,4090515
,4090677
,4090806
,4091314
,4091674
,4092101
,4107820
,4109837
,4111984
,4113843
,4113951
,4114957
,4117138
,4130658
,4130725
,4132494
,4149841
,4149876
,4152213
,4153066
,4157050
,4169405
,4169743
,4172754
,4176174
,4177021
,4177700
,4178885
,4180989
,4184072
,4184587
,4184943
,4185454
,4185530
,4188788
,4199395
,4202762
,4215699
,4238196
,4248836
,4280467
,4283973
,4295544
,4312761
,4543919
,4737006
,5253300
,5286084
,6762264
,6843468
,7104583)
order by 人群包, 会员id desc 
;


-- 7-3-1 App全量用户（去除IOS用户，需要先拉出oneid，然后通过oneid匹配对应手机号。如遇到1个oneid对应多个手机号的情况，请随机保留1个手机号）
select distinct t2.member_phone
from (
	-- 神策平台取数
	select distinct_id,event_type
	from (
		select *, row_number()over(partition by distinct_id order by event_type desc) as rn
		from (
			select distinct_id, $lib event_type
			from events
			where $lib in ('iOS', 'Android')
			and length(distinct_id)<9
			and time between '2022-02-01' and '2023-07-24 14:00:00'
			group by 1,2
			) a
		) b
	where rn = 1 and event_type = 'Android'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 7-3-2 参加过四季服活动的用户
select distinct m.member_phone "手机号"
from volvo_online_activity.season_activity_order t1 
inner join `member`.tc_member_info m
on t1.member_id = m.id 
and t1.code in ('spring_2022', 'summer_2022', 'winter_2022')
and t1.delete_flag = 0
and m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0
;

-- 7-3-3 V值大于100的车主
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003 and is_vehicle = 1
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 100
;

-- 7-3-4 小程序端/App端已点亮【WOW辈楷模】电子勋章用户
select DISTINCT d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on d.ID = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
inner join mine.user_medal e on e.id = c.medal_id and e.medal_name = 'WOW辈楷模'
where c.create_time <= '2023-07-24 14:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
;

-- 7-3-5 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-07-24 14:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 7-3-6 获奖实物奖未填地址用户（随会员日数据拉取）
select m.id,m.member_address, t1.*, t2.*, t3.*
from member.tc_member_info m 
inner join volvo_online_activity_module.lottery_draw_log t1 
on m.id = t1.member_id 
and m.member_status <> 60341003 and m.is_deleted = 0
and t1.lottery_play_code = 'member_202307' and t1.have_win = 1
inner join volvo_online_activity_module.lottery_play_pool t2 
on t1.lottery_play_code  = t2.lottery_play_code and t1.prize_code = t2.prize_code
and t2.prize_type = 'article'
left join member.tc_member_address t3
on m.id = t3.member_id and t3.IS_DELETED = 0 -- and t3.IS_DEFAULT = 1   -- 默认收货地址
where t3.member_address is null
;


-- 7-5 生日在8月的黑卡车主,粉丝
select case when is_vehicle = 1 then ' 7-5-1' else ' 7-5-2' end as "人群包"
	,id as member_id 
	,member_phone 
-- select left(member_birthday, 3) y,is_vehicle, count(*)
from `member`.tc_member_info m
where m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
and m.MEMBER_LEVEL = 4 
and substr(member_birthday, 6, 2)='08'
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' -- 排除无效手机号
and left(member_birthday, 3) between 195 and 199
order by 1,2
;



-- 7-1-6 车主&粉丝：下月1号即将有过期V值
select ' 7-1-6' as  "人群包",
	会员id, 手机号, 是否车主, 第一个月预测过期v值数  -- 结果注意去重
from (
	select 
		f."会员id",f."手机号",f."是否车主",f."截止T-24月累计发放v值",f."T-24月当月发放v值",
		f."截止T月累计消耗v值",f."截止T月累计过期v值",f."用户当前剩余v值",
		least(f."用户当前剩余v值", f."T-24月当月发放v值", f."截止T-24月累计发放v值"-f."截止T月累计消耗v值"-f."截止T月累计过期v值") "第一个月预测过期v值数"
	from (
		select
			f.MEMBER_ID "会员id",
			m.MEMBER_PHONE "手机号",
			m.IS_VEHICLE "是否车主",
			IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) "用户当前剩余v值",
			SUM(case when f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "截止T-24月累计发放v值",   -- 截止到当前月底两年前发放的v值
			SUM(case when f.CREATE_TIME >= '2021-07-01' and f.CREATE_TIME < '2021-08-01' and f.RECORD_TYPE = 0 then f.INTEGRAL else 0 end) "T-24月当月发放v值",
			SUM(case when f.CREATE_TIME < '2023-07-28 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE <> 60741032 then f.INTEGRAL else 0 end) "截止T月累计消耗v值",
			SUM(case when f.CREATE_TIME < '2023-07-28 11:00:00' and f.RECORD_TYPE = 1 and f.EVENT_TYPE = 60741032 then f.INTEGRAL else 0 end) "截止T月累计过期v值"
		from `member`.tt_member_flow_record f     -- 流水表
		join `member`.tc_member_info m on f.MEMBER_ID = m.ID
		where f.IS_DELETED = 0
		and m.MEMBER_STATUS <> 60341003
		and m.IS_DELETED = 0
		group by 1,2,3,4
		order by 1
		) f
	) f
where f.第一个月预测过期v值数 > 0 and LENGTH(手机号) = 11 and left(手机号,1) = '1'
order by 人群包, 会员id desc 
;



-- 8-4-1 5.5/6.5/7.5领取到卡券的人
select distinct tmi.id member_id, tmi.member_phone
from member_rights.tm_member_rights rights
inner join member_rights.tc_member_rights_config config on config.rights_id= rights.id
and rights.id in (16, 10, 20, 19, 9, 14, 15, 13, 24 ,26)
inner join member_rights.tt_member_get_record record on record.rights_config_id= config.id
inner join member.tc_member_info tmi on record.member_id  = tmi.id 
and tmi.member_status <> 60341003 and tmi.is_deleted = 0
where record.is_deleted = 0 
and length(tmi.member_phone) = 11 and tmi.member_phone <> '18715177798'
and left(record.create_time, 10) in ('2023-05-05', '2023-06-05', '2023-07-05')
;


-- 8-1-1~8-1-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 预测过期v值数 >= 1500 then ' 8-1-1'
					when 是否车主 = 0 and 预测过期v值数 >= 1500 then ' 8-1-2'
					when 是否车主 = 1 and 预测过期v值数 < 1500 then ' 8-1-3'
					when 是否车主 = 0 and 预测过期v值数 < 1500 then ' 8-1-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-08'
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2
	) a 
where 预测过期v值数 > 0
order by 人群包, 会员id desc
;


-- 8-1-7 车主&粉丝：上个自然月累计获得V值大于等于300V的人群
select m.MEMBER_PHONE "手机号", count(distinct f.MEMBER_ID) "会员id数", sum(INTEGRAL) "上月获得V值"
from `member`.tt_member_flow_record f     -- 流水表
inner join `member`.tc_member_info m on f.MEMBER_ID = m.ID
and f.IS_DELETED = 0 and f.RECORD_TYPE = 0
and left(f.CREATE_TIME, 7) = '2023-07' and f.enent_type <> '60731025'
and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
group by 1
having sum(INTEGRAL) >= 300
;	



-- 8-2-1 近180天新注册用户或近180天有商城正向订单的用户（除IOS）
select tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 90) >= '2023-08-18'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
on t1.user_id = tmi.ID
left join (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-08-18 14:00:00'
	) t2 
on tmi.cust_id = t2.distinct_id
where tmi.IS_DELETED = 0 
and tmi.MEMBER_STATUS <> 60341003 and t2.distinct_id is null
and (date_add(tmi.MEMBER_TIME, 90) >= '2023-08-18' or t1.user_id is not null)
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
; 



-- 8-2-2 绑定电车（XC40 Recharge和C40）的车主用户
select distinct m.MEMBER_PHONE "手机号"
from (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc, id desc) rn
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
inner join vehicle.tm_vehicle tv
on vr.vin_code = tv.vin and vr.rn = 1
inner join basic_data.tm_model tm 
on tv.model_id = tm.id 
and tm.model_name in ('XC40 RECHARGE', '全新纯电C40')
inner join `member`.tc_member_info m 
on vr.MEMBER_ID = m.ID
where m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
;

-- 8-2-3 V值余额大于500的用户
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 500
;

-- 8-2-4 近180天，新注册or浏览过商城or有过商城订单的用户(member_id)
select tmi.id member_id
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 90) >= '2023-08-18'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
on t1.user_id = tmi.ID
where tmi.IS_DELETED = 0 
and tmi.MEMBER_STATUS <> 60341003
and (date_add(tmi.MEMBER_TIME, 90) >= '2023-08-18' or t1.user_id is not null)
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
union 
select t2.id as member_id
from (
	-- 神策平台取数 商城浏览
	select distinct distinct_id
	from events 
	where 1=1 
	and date_add(time, 90) >= '2023-08-18'
	and time <= '2023-08-18 14:00:00'
	--and event in('$AppViewScreen','$MPViewScreen','Page_view','Button_click')
	and event in('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
	and (page_title in ('商城','首页','商城首页') or $title='商城')
	and length(distinct_id)<9
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
; 


-- 8-3-1 全平台银卡以上用户(金卡、白金卡、黑卡)
select DISTINCT m.member_phone 手机号
from `member`.tc_member_info m
where m.MEMBER_STATUS <> 60341003
and m.IS_DELETED = 0
and m.MEMBER_LEVEL >= 2
;

-- 8-3-2 一个月前登录过App，本月未活跃的车主用户
select distinct m.member_phone 手机号
from (
	-- 神策平台取数
	select t.distinct_id
	from events t 
	where t.time >= '2023-07-01' and length(distinct_id)<9
	and $lib in ('iOS', 'Android')
	group by 1
	having max(t.`time`) < '2023-08-01'
	) t 
inner join member.tc_member_info m 
on t.distinct_id = m.cust_id
and m.is_deleted = 0 and m.IS_VEHICLE = 1 and m.member_status <> 60341003
;

-- 8-3-3 近三个月登录过小程序，但从未登录过App的用户（如超过30取30万）
select distinct m.member_phone 手机号
from member.tc_member_info m 
inner join (
	-- 神策平台取数
	select a.distinct_id
	from (
		select distinct_id
		from events t 
		where $lib = 'MiniProgram' and length(distinct_id)<9
		and t.time between '2023-05-21' and '2023-08-21 17:00:00'
		group by 1
		) a 
	left join (
		select distinct_id
		from events 
		where $lib in ('iOS','Android') and length(distinct_id)<9
		and time between '2022-02-01' and '2023-08-21 17:00:00'
		group by 1
		) b 
	on a.distinct_id = b.distinct_id 
	where b.distinct_id is null
	) t 
on m.cust_id = t.distinct_id
where m.is_deleted = 0 and m.member_status <> 60341003
;

-- 8-3-4小程序端/App端已点亮【WOW辈楷模】电子勋章用户
select DISTINCT d.member_phone 手机号
from mine.madal_detail c
inner join `member`.tc_member_info d on cast(d.ID as varchar) = c.user_id and d.is_deleted = 0 and d.member_status <> 60341003
inner join mine.user_medal e on e.id = c.medal_id and e.medal_name = 'WOW辈楷模'
where c.create_time <= '2023-08-21 17:00:00'
and c.deleted = 1  -- 有效
and c.status = 1  -- 正常
;

-- 8-3-5 App全量IOS用户
select distinct t2.id as member_id
from (
	-- 神策平台取数
	select distinct distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-08-21 17:00:00'
	) t1 
inner join (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where member_status <> 60341003 and is_deleted = 0
	) t2
on t1.distinct_id = t2.cust_id
and t2.rn = 1
;

-- 8-1-5 车主&粉丝：下月1号即将有过期V值
select 会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-08'     -- 两年前的当月发放
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2,3
	) a 
where 预测过期v值数 > 0
;

-- 8-5-1 已购买夏服活动卡券但未进店核销用户（需剔除卡券，已作废的用户）
select distinct tmi.member_phone "手机号"
FROM  coupon.tt_coupon_detail tcd
join coupon.tt_coupon_info tci 
on tcd.coupon_id  = tci.id
and (tci.coupon_name like '23年夏服%' or tci.id = 4221)
and tcd.is_deleted =0 and tcd.ticket_state = 31061001
join "member".tc_member_info tmi 
on tcd.one_id  = tmi.cust_id
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 8-2-5 绑定电车（XC40 Recharge和C40）的车主用户
select distinct m.MEMBER_PHONE "手机号"
from (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc, id desc) rn
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
inner join vehicle.tm_vehicle tv
on vr.vin_code = tv.vin and vr.rn = 1
inner join basic_data.tm_model tm 
on tv.model_id = tm.id 
and tm.model_name in ('XC40 RECHARGE', '全新纯电C40')
inner join `member`.tc_member_info m 
on vr.MEMBER_ID = m.ID
where m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
;


-- 8-2-6 近3个月有过发布动态，但未发布#沃的书单#话题用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi 
inner join (
	select tp.member_id
		,count(t.post_id) topic_post_cnt
		,sum(case when tp.post_digest like '%topicId=''7hqEzNFurs''%' then 1 else 0 end) digest_cnt
	from community.tm_post tp
	left join (
		select post_id
		from community.tr_topic_post_link
		where is_deleted = 0 and topic_id = '7hqEzNFurs'
		) t 
	on tp.post_id = t.post_id
	where tp.is_deleted <> 1 and tp.post_type = 1001
	and tp.create_time + '3 month' >= '2023-08-28'
	group by 1
	) tt 
on tmi.id = tt.member_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
and tt.topic_post_cnt = 0 and tt.digest_cnt = 0
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1'
;


-- 8-3-6 中奖明细 获奖实物奖未填地址用户（随会员日数据拉取）
select
	a.member_id,
	a.nick_name 姓名,
	d.MEMBER_PHONE 沃世界注册手机号,
	case when a.have_win = '1' then '中奖'
		when a.have_win = '0' then '未中奖'
		end 是否中奖,
	case when a.have_send = '1' then '已发放'
		when a.have_send = '0' then '未发放'
		end 奖品是否发放,
	a.create_time 抽奖时间,
	b.prize_name 中奖奖品,
	b.prize_level_nick_name 奖品等级,
	x.收货人姓名 默认收货人姓名,
	x.收货人手机号 默认收货人手机号,
	x.收货地址 默认收货地址,
	c.收货人手机号 中奖之后填写收货手机号,
	c.收货人姓名 中奖之后填写收货人姓名,
	c.收货地址 中奖之后填写收货地址
from volvo_online_activity_module.lottery_draw_log a
left join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
left join (
	select
		c.lottery_play_code,
		c.会员ID,
		c.收货人姓名,
		c.收货人手机号,
		c.填写收货地址时间,
		c.收货地址
	from (
		select c.lottery_play_code,c.会员ID,c.收货人姓名,c.收货人手机号,c.填写收货地址时间,c.收货地址
			,row_number() over(partition by c.收货地址 order by c.填写收货地址时间 desc) rk
		from (
			select
				lai.lottery_play_code,
				lai.member_id 会员ID,
				lai.addressee 收货人姓名,
				lai.phone 收货人手机号,
				lai.create_time 填写收货地址时间,
				CONCAT(ifnull(lai.province_name,''),ifnull(lai.city_name,''),ifnull(lai.area_name,''),ifnull(lai.street,''),ifnull(lai.other_address,''))收货地址
			from volvo_online_activity_module.lottery_addressee_info lai
			where lai.is_delete = 0
			and lai.lottery_play_code='member_day_202307'
			order by lai.member_id
			)c
		)c 
	where c.rk = 1
	) c 
on a.member_id = c.会员ID
left join `member`.tc_member_info d on a.member_id = d.ID
left join (
	select 
		tma.MEMBER_ID 会员ID,
		tma.CONSIGNEE_NAME 收货人姓名,
		tma.CONSIGNEE_PHONE 收货人手机号,
		CONCAT(ifnull(tr.REGION_NAME,''),ifnull(tr2.REGION_NAME,''),ifnull(tr3.REGION_NAME,''),ifnull(tma.MEMBER_ADDRESS,''))收货地址,
		row_number() over(partition by tma.MEMBER_ID  order by tma.CREATE_TIME  desc) rk
	from `member`.tc_member_address tma
	left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
	left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
	left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
	where tma.IS_DELETED = 0
	and tma.IS_DEFAULT = 1  
	) x -- 默认收货地址
on a.member_id =x.会员ID and x.rk =1
where a.lottery_play_code = 'member_202307'  -- 7月会员日code
and date(a.create_time)='2023-08-25'
and a.have_win = 1   -- 中奖
order by a.create_time
;

-- 8-3-7 已抢购单读图书兑换券（卡券ID：5342）未核销兑换的用户提醒
select distinct tmi.member_phone "手机号"
FROM  coupon.tt_coupon_detail tcd
join coupon.tt_coupon_info tci 
on tcd.coupon_id  = tci.id
and tci.id = 5342
and tcd.is_deleted =0 and tcd.ticket_state = 31061001
join "member".tc_member_info tmi 
on tcd.one_id  = tmi.cust_id
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
and length(tmi.member_phone) = 11 and left(tmi.member_phone, 1)='1'
;

-- 9-1-1 浏览过22年先心捐赠和23年先心捐赠活动用户（去重）
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi 
left join (
	-- 22年浏览先心捐赠
	select usertag
	from track.track t 
	where left(t.date, 4) = '2022'
	and (t.data like '%3569F211D86743F2BE5730ED1718ED5B%'
		or t.data like '%8536EFCED32D4305AAFCD60349249085%'
		or t.data like '%75EA2C9EA9354D618F6F36DFBE01AC0D%'
		or t.data like '%59D7B1838D484B3C88BFA2C1B2DF3E1C%'
		or t.data like '%82030858D1D647459FF626D345933C7F%'
		or t.data like '%2A4856A8C0524030A5E01759932EE9B9%'
		or t.data like '%8A28FB3EF1874CD5AC8AD688D374C64E%'
		or t.data like '%C3D539ED439D406E977216DC5C8B5312%'
		or t.data like '%6600503720DB499590E68EF001C5DDB4%'
		or t.data like '%0C5B528CBDDE44F595676853E0FA7DD2%'
		or t.data like '%71F842BBB76F4D26B13586C5400FEBF5%'
		or t.data like '%2E44E9486D9443E38A8FFD2E35695B64%'
		or t.data like '%3A90A55AEB784F409BC53DB84F46E765%'
		or t.data like '%4312559BA5E148F6B84565D64D356052%'
		or t.data like '%5625763EC5774E4795E1FDFD23069DBB%'
		or t.data like '%74963288D2B549B38CA0B7C55731A927%'
		or t.data like '%2E32FB5205044E30B820B42CBBF28AC2%'
		or t.data like '%A281B8286331410BA897B2A49F84D55F%')
	group by 1
	) t1 
on t1.usertag = cast(tmi.USER_ID as varchar)
left join (
	-- 神策平台取数 -- -- 23年浏览先心捐赠
	select t.distinct_id
	from events t 
	where page_title = '先心捐赠'
	and length(distinct_id)<9
	and t.time >= '2023-01-01' and time <= '2023-08-31 14:00:00'
	group by 1
	) t2
on t2.distinct_id = tmi.cust_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003 
and length(tmi.member_phone) = 11 and left(tmi.member_phone, 1)='1'
and (t1.usertag is not null or t2.distinct_id is not null)
;

-- 9-1-2 浏览过21年和22年爱心计划专区的用户
select distinct tmi.member_phone "手机号"
from (
	select t.usertag
	from track.track t
	where t.`date` >= '2022-01-01 00:00:00' and t.`date` <= '2022-12-31 23:59:59'
	and (t.`data` like '%爱心计划2期_首页_onload%'
		or t.`data` like '%爱心计划2期_首页_click_视频%'
		or t.`data` like '%爱心计划2期_专题页_onload%'
		or t.`data` like '%爱心计划2期_新增活动_click_提交按钮%'
		or t.`data` like '%爱心计划2期_首页/专题页_click_活动发起按钮%'
		or t.`data` like '%376734466CE84B2D8B1B44733FB5DC5C%'
		or t.`data` like '%CD26BB762B9748E6B45E0A170D8EAD81%'
		or t.`data` like '%C47798EE223C40D3BBABD2813A0DF708%'
		or t.`data` like '%BA5F73BBCA7842DDBF4FE83A5B9C1614%'
		or t.`data` like '%29EE304844CE4BACBB6221CC9CDD1F48%'
		or t.`data` like '%37B7B6E07EFC41F5B709DEA9FB0DDBB1%'
		or t.`data` like '%C7DD6C1DED314292A7375F8F2DB8CE01%'
		or t.`data` like '%581F3B2EA4354FD6860CD24C4549ED54%'
		or t.`data` like '%A222FFC20C7D46A8AEDB69D9A646205E%'
		or t.`data` like '%5E6659BDEB1A49B5A50ADA895D0A4D0F%'
		or t.`data` like '%0598EA51355B4DC7A9593F9AAF8EFFC6%'
		or t.`data` like '%54D294A1B8B6405AB4BA72BB19C2D3F3%'
		or t.`data` like '%42C25A742F824B518209C77E69C1859D%'
		or t.`data` like '%CFEA0E71EC7241529C2572C5748F3013%'
		or t.`data` like '%D15DB44917D24BFAB9F8061E5744393F%'
		or t.`data` like '%800BF503C530488D96D9049D6D46F192%'
		or t.`data` like '%C28B286001494D808CC32FD57F05BD07%'
		or t.`data` like '%2B92AB9FC0B140D6BFC0FFB71533CD05%'
		or t.`data` like '%38D7A05032A84E64B0CD1986DD2F3A18%'
		or t.`data` like '%6272348F4202465E92ADFB05654CB3D5%'
		or t.`data` like '%814FDABE68F8446EA7DC69BEECB3256A%'
		or t.`data` like '%爱心活动发起_click%'
		or t.`data` like '%活动分享_click%'
		or t.`data` like '%基金会介绍_click%'
		or t.`data` like '%复制链接_click%'
		or t.`data` like '%我要捐赠_click%'
		or t.`data` like '%我要留言_click%'
		or t.`data` like '%爱心助力榜_click%'
		or t.`data` like '%我的捐赠_click%'
		or t.`data` like '%查看品牌证书_click%'
		or t.`data` like '%查看用户证书_click%'
		or t.`data` like '%BCAlc8VGtX%'
		or t.`data` like '%zBAffYjDjx%'
		or t.`data` like '%Clu6eBXefi%'
		or t.`data` like '%4xOK78u7nR%'
		or t.`data` like '%BCAlc8VGtX%')
	union 
	select t.usertag
	from track.track t
	where t.`date` >= '2021-01-01 00:00:00' and t.`date` <= '2021-12-31 23:59:59'
	and t.`data` like '%爱心计划专区%'
	) t 
inner join `member`.tc_member_info tmi 
on t.usertag = cast(tmi.USER_ID as varchar)
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 9-1-3 近3个月小程序或App活跃用户（去重）
select distinct m.member_phone 手机号
from (
	-- 神策平台取数
	select t.distinct_id
	from events t 
	where length(distinct_id)<9
	and t.time >= '2023-05-31' 
	and t.time <= '2023-08-31 14:00:00'
	and $lib in ('iOS', 'Android', 'MiniProgram')
	group by 1
	) t 
inner join member.tc_member_info m 
on t.distinct_id = m.cust_id
and m.is_deleted = 0 and m.member_status <> 60341003
;

-- 9-1-4 参与过沃尔沃汽车App此刻发帖的平台用户
SELECT distinct tmi.member_phone "手机号"
from community.tm_post tp 
inner join `member`.tc_member_info tmi 
on tp.member_id = tmi.ID 
where tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.platform_app = 1
and tp.is_deleted <> 1       -- 删除确定是非1还是0
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 9月实际过期V值
select 会员id, 手机号, 是否车主, 实际过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 实际过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 0
	and left(f.create_time, 7) = '2021-08'     -- 两年前的当月发放
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2,3
	) a 
where 实际过期v值数 > 0
;

-- 9-6-1~9-6-4 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 and 预测过期v值数 >= 1500 then ' 9-6-1'
					when 是否车主 = 0 and 预测过期v值数 >= 1500 then ' 9-6-2'
					when 是否车主 = 1 and 预测过期v值数 < 1500 then ' 9-6-3'
					when 是否车主 = 0 and 预测过期v值数 < 1500 then ' 9-6-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-09'
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2
	) a 
where 预测过期v值数 > 0
order by 人群包, 会员id desc
;


-- 9-7-1 车主&粉丝：上个自然月累计获得V值大于等于300V的人群
select m.MEMBER_PHONE "手机号", count(distinct f.MEMBER_ID) "会员id数", sum(INTEGRAL) "上月获得V值"
from `member`.tt_member_flow_record f     -- 流水表
inner join `member`.tc_member_info m on f.MEMBER_ID = m.ID
and f.IS_DELETED = 0 and f.RECORD_TYPE = 0
and left(f.CREATE_TIME, 7) = '2023-08' and f.event_type = '60731025'
and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
group by 1
having sum(INTEGRAL) >= 300
;	


-- 7-4-1 开票经销商区域为北区，且开票时间3年以上（小于2020-06-13）的S60+S60L绑车车主（剔除山东省车辆）-- 去重
select case when tm.model_name in ('S60', 'S60L') then 'd7-4-1'
			when tm.model_name = 'XC60' then 'b7-4-2'
			when tm.model_name = 'S90' then 'c7-4-3'
			when tm.model_name = 'XC90' then 'a7-4-4'
			end as "人群包"
	,tg.CITY_NAME as "开票经销商城市"
	,tm.model_name 
	,tmi.id  as member_id
	,tmi.member_phone 
-- select count (*), count(distinct kp.vin)
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select vin_code, member_id
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
inner join (
	select tm.COMPANY_CODE,
		tm.ORG_ID 经销商组织ID,
	    case when tm.city_name like '%市' then left(tm.city_name, length(tm.city_name)-1) else tm.city_name end CITY_NAME,
	    to1.ID 大区组织ID,
	    to1.ORG_NAME 大区名称
	from organization.tm_company tm
	inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	inner JOIN organization.tm_org to1 ON to1.id = tr2.parent_org_id and to1.ORG_TYPE = 15061005 
	where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	and tm.province_name not like '%山东%'
	) tg
on kp.dealer_code = tg.COMPANY_CODE and tg.大区名称='北区'
left join vehicle.tm_vehicle tv
on kp.vin = tv.vin 
left join basic_data.tm_model tm 
on tv.model_id = tm.id 
where kp.invoice_date < '2020-09-12' and kp.is_deleted = 0 
and tm.model_name in ('S60', 'XC60', 'S90', 'XC90', 'S60L') 
and length(tmi.member_phone) = 11
order by 1,2
;


-- 9-2-1 “开学季”活动获得单读图书兑换券未核销用户卡券即将过期提醒(卡券ID：5495)
select distinct member_phone "手机号"
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.one_id = tmi.CUST_ID 
and a.is_deleted = 0 and a.coupon_id = '5495' and a.ticket_state <> 31061003
and length(tmi.member_phone) = 11 and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 9-9-1 车主&粉丝：下月1号即将有过期V值
select 会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-09'     -- 两年前的当月发放
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2,3
	) a 
where 预测过期v值数 > 0
;


-- 9-9-2 2023/1/1-2023/8/21 留资且截止当前未购车非车主会员
select distinct m.member_phone "手机号"
from `member`.tc_member_info m
inner join customer.tt_clue_clean a
on m.member_phone = a.mobile 
and m.is_vehicle=0 and a.is_deleted=0
and a.create_time >= '2023-01-01' and a.create_time < '2023-08-22'
where m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
;



-- 9-2-7 近45天新注册用户或近180天有商城正向订单的用户（只要IOS的）(member_id)
select tmi.id member_id
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 180) >= '2023-09-26'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
on t1.user_id = tmi.ID
left join (
	-- 神策平台取数
	select distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-09-26 14:00:00'
	group by 1
	) t2 
on tmi.cust_id = t2.distinct_id
where tmi.IS_DELETED = 0 
and tmi.MEMBER_STATUS <> 60341003 and t2.distinct_id is not null 
and (date_add(tmi.MEMBER_TIME, 45) >= '2023-09-26' or t1.user_id is not null)
; 



-- 9-2-8 近45天新注册用户或近180天有商城正向订单的用户（除IOS）
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 180) >= '2023-09-26'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
on t1.user_id = tmi.ID
left join (
	-- 神策平台取数
	select distinct_id
	from rawdata.events 
	where $lib = 'iOS'
	and length(distinct_id)<9
	and time between '2022-02-01' and '2023-09-26 14:00:00'
	group by 1
	) t2 
on tmi.cust_id = t2.distinct_id
where tmi.IS_DELETED = 0 
and tmi.MEMBER_STATUS <> 60341003 and t2.distinct_id is null 
and (date_add(tmi.MEMBER_TIME, 45) >= '2023-09-26' or t1.user_id is not null)
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
; 



-- 9-2-9 V值余额大于200的用户（约10W用户）
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 200
;


-- 9-2-10 APP端在9月1号0点之前活跃过但9月1日~9月25日未在APP端活跃过的车主，最后保留20W（塞券+短信触达）
select distinct m.member_phone 手机号
from (
	-- 神策平台取数
	select t.distinct_id
	from events t 
	where length(distinct_id)<9
	and t.time >= '2022-02-01' 
	and $lib in ('iOS', 'Android')
	group by 1
	having max(t.time) < '2023-09-01'
	) t 
inner join member.tc_member_info m 
on t.distinct_id = m.cust_id
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> 60341003
;


-- 9-10-1 夏服未核销用户短信提醒
select distinct tmi.member_phone "手机号"
FROM  coupon.tt_coupon_detail tcd
join coupon.tt_coupon_info tci 
on tcd.coupon_id  = tci.id
and (tci.coupon_name like '23年夏服%' or tci.id = 4221)
and tcd.is_deleted =0 and tcd.ticket_state = 31061001
join "member".tc_member_info tmi 
on tcd.one_id  = tmi.cust_id
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;



-- 9-2-11 过去180天未在商城有正向订单,且注册时间距今在2-6个月,且APP端为非IOS,且V值余额>200
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where date_add(a.order_time, 180) >= '2023-09-26'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	) t1 
on t1.user_id = tmi.ID
left join (
	-- 神策平台取数
	select *, row_number()over(partition by distinct_id order by event_type desc) as rn
	from (
		select distinct_id, $lib event_type
		from events
		where $lib in ('iOS', 'Android')
		and length(distinct_id)<9
		and time between '2022-02-01' and '2023-09-26 17:00:00'
		group by 1,2
		) a
	) t2 
on tmi.cust_id = t2.distinct_id and t2.rn = 1
where t1.user_id is null and t2.event_type = 'Android'
and tmi.MEMBER_TIME between '2023-03-26' and '2023-07-26'
and IFNULL(tmi.MEMBER_V_NUM,0) - IFNULL(tmi.MEMBER_LOCK_V_NUM,0) > 200
and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003 
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 9-5-1 车主&粉丝：下月1号即将有过期V值
select 手机号, count(*)  -- 判断手机号是否重复
from (
	-- 提取子表结果 -- 9-5-1 车主&粉丝：下月1号即将有过期V值
	select m.id as 会员id
		,m.member_phone as 手机号
		,m.is_vehicle 是否车主
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-09'     -- 两年前的当月发放
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2,3
	having sum(f.add_v_num - CONSUMPTION_INTEGRAL) > 0
	) a 
group by 1
having count(*) > 1
;


-- 10-2-1~10-2-2 车主：近30天将有大额过期积分，23年5月1号即将过期v值总和大于等于1,500 v值的人
select case when 是否车主 = 1 then ' 10-2-1' else ' 10-2-2' end as  "人群包",				
	会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-10'
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2
	) a 
where 预测过期v值数 >= 1500
order by 人群包, 会员id desc
;





-- 10-5-1 23年6/1-10/6非车主会员留资2次及以上，且留资后未到店 或23年6/1-10/6车展活动留资后未到店的非车主会员
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi 
left join (
	select t1.mobile
	from (
		select mobile, count(*) clue_cnt, min(create_time) first_clue_time 
		from customer.tt_clue_clean a 
		where is_deleted = 0
		and create_time >= '2023-06-01' and create_time < '2023-10-07'
		group by 1
		having count(*) >= 2
		) t1
	left join (
		select mobile_phone, max(arrive_date) last_arrive_date
		from cyx_passenger_flow.tt_passenger_flow_info
		where is_deleted = 0 and arrive_date >= '2023-06-01'
		group by 1
		) t2 
	on t1.mobile = t2.mobile_phone and t1.first_clue_time < t2.last_arrive_date
	where t2.mobile_phone is null 
	) r1 
on tmi.member_phone = r1.mobile
left join (
	select t1.mobile
	from (
		select mobile, min(create_time) first_clue_time 
		from customer.tt_clue_clean a 
		left join activity.cms_active c on a.campaign_id = c.uid 
		where a.is_deleted = 0 and c.active_name like '%车展%'
		and create_time >= '2023-06-01' and create_time < '2023-10-07'
		group by 1
		) t1
	left join (
		select mobile_phone, max(arrive_date) last_arrive_date
		from cyx_passenger_flow.tt_passenger_flow_info
		where is_deleted = 0 and arrive_date >= '2023-06-01'
		group by 1
		) t2 
	on t1.mobile = t2.mobile_phone and t1.first_clue_time < t2.last_arrive_date
	where t2.mobile_phone is null 
	) r2
on tmi.member_phone = r2.mobile
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
and tmi.is_vehicle = 0 and (r1.mobile is not null or r2.mobile is not null)
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 10-6-2 789月活跃过但10月未在APP活跃的用户&近90天新注册用户 -- CK 取数
select tmi.id member_id
from `member`.tc_member_info tmi
left join (
	-- 神策平台取数
	select a.distinct_id
	from (
		select distinct_id
		from events t
		where length(distinct_id)<9
		and time >= '2023-07-01' and time < '2023-10-01'
		and ($lib in ('iOS', 'Android', 'MiniProgram') or channel in ('Mini', 'App'))
		group by 1
		) a 
	left join (
		select distinct_id
		from events
		where length(distinct_id)<9
		and time >= '2023-10-01' and time < '2023-10-17 15:00:00'
		and ($lib in ('iOS', 'Android') or channel ='App')
		group by 1
		) b 
	on a.distinct_id = b.distinct_id
	where b.distinct_id is null
	) t1
on tmi.cust_id = t2.distinct_id
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
and (date_add(tmi.MEMBER_TIME, 90) >= '2023-10-17' or t1.distinct_id is not null)
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
; 


-- 10-7-1 近4个月内App+小程序累计登录3天以上的非车主会员(剔除1个月内各渠道已留资的用户）
select distinct tmi.member_phone "手机号"
from (
	select cust_id, member_phone
		,row_number()over(partition by cust_id order by id desc) rn
	from "member".tc_member_info
	where IS_DELETED = 0 and MEMBER_STATUS <> 60341003
	) tmi
left join (
	-- 神策取数
    select distinct_id, count(distinct date) login_cnt
    from ods_rawd.ods_rawd_events_d_di a
    where `time` <= '2023-10-19 14:00:00' 
    and `time` + interval '4 month' >= '2023-10-19'
    and distinct_id not like '%#%'
    and length(a.distinct_id)<9
    and ($lib in ('iOS', 'Android', 'MiniProgram') or channel in ('Mini', 'App'))
    group by distinct_id
    having count(distinct date) >= 3
	) t1 
on tmi.cust_id = t1.distinct_id
left join (
	select tcc.mobile
	from customer.tt_clue_clean tcc 
	where tcc.is_deleted = 0 and create_time >= '2023-09-19'
	group by 1
	) t2
on tmi.member_phone = t2.mobile
where tmi.rn = 1 and is_vehicle = 0
and t1.distinct_id is not null and t2.mobile is null
;


-- 10-13-1 预约试驾预约到店时间在23年10月12日~18日，但是截止19号仍未完成试驾的客户
select distinct 手机号
from (
	select ta.appointment_id "预约ID"
		,ta.customer_phone "手机号"
		,ta.created_at "预约创建时间"
		,ta.invitations_date "预约到店时间"
		,tad.item_id "试乘试驾ID"
		,CASE tad.status WHEN 70711001 THEN '待试驾' WHEN 70711002 THEN '已试驾' WHEN 70711003 THEN '已取消' END 试驾状态
		,tad.drive_s_at "试驾时间1"
		,tp.drive_s_at "试驾时间2"
		,ifnull (tad.drive_s_at, tp.drive_s_at) "实际试驾时间"
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	left join drive_service.tt_testdrive_plan tp on tad.item_id = tp.item_id and tp.is_deleted = 0
	where ta.APPOINTMENT_TYPE = 70691002 -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.status <> 70711003   -- 非已取消
	and ta.invitations_date >= '2023-10-12' and ta.invitations_date < '2023-10-19'
	and tad.item_id is null
	) a 


-- 10-9-1 近1个月登录过小程序，但从未登录过App的车主
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
global inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where `date` >= '2023-09-24'
	and distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and ($lib = 'MiniProgram' or channel = 'Mini')
	group by distinct_id
	) t1 
on toString(m.cust_id) =toString(t1.distinct_id)
global left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by distinct_id
	) t2
on toString(m.cust_id) =toString(t2.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and t2.distinct_id is null and m.is_vehicle = 1
;


-- 10-9-3 当前剩余V值大于等于100V值的车主
select distinct m.member_phone "手机号"
from  member.tc_member_info m 
where m.is_deleted = 0 
and m.member_status <> 60341003 and m.is_vehicle = 1
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) >= 100
;


-- 10-9-4 之前活跃过但本月（23年10月）未活跃的车主
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or $lib='MiniProgram' or channel in ('Mini', 'App'))
	group by distinct_id
	having max(date) < '2023-10-01'
	) t1 
on toString(m.cust_id) =toString(t1.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
;


-- 10-9-5 近12个月没有回厂的绑车车主（剔除近3个月新绑车的车主）
select m.member_phone "手机号"
from member.tc_member_info m
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on vr.member_id = m.id and vr.rn = 1
left join (
	select vin
	from cyx_repair.tt_repair_order 
	where is_deleted = 0 and ro_create_date >= '2022-10-24'
	and repair_type_code <> 'P' and ro_status = 80491003 -- (已结算)的工单
	and ro_no = relation_ro_no -- relation_ro_no是关联工单的工单号，如果和RO_NO相同，说明这个工单是主工单/母工单
	group by 1
	) t2 
on vr.vin_code = t2.vin 
where m.is_deleted = 0 and m.member_status <> 60341003
and vr.bind_date <= '2023-07-24'
-- and t2.vin is null
group by 1
having count(t2.vin) = 0
;


-- 10-9-6 APP金卡及以上车主（剔除黑产，优先级最低）
select distinct m.member_phone "手机号"
from member.tc_member_info m
inner join (
	-- 神策取数
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by distinct_id
	) t1 
on m.cust_id = t1.distinct_id 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.MEMBER_LEVEL >= 2
and m.is_vehicle = 1
;


-- 10-9-7 App全量车主
select m.id member_id 
from member.tc_member_info m
inner join (
	-- 神策取数
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where distinct_id not like '%#%'
	and length(a.distinct_id)<9
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by distinct_id
	) t1 
on m.cust_id = t1.distinct_id 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.is_vehicle = 1
;


-- 10-14-1 23年1-9月在社区发过帖子，但10月尚未发帖的用户
SELECT tmi.member_phone "手机号", member_name "昵称"
from `member`.tc_member_info tmi 
inner join (
	select member_id
	from community.tm_post
	where is_deleted <> 1 
	and create_time >= '2023-01-01'
	and post_type in (1001, 1007)   -- 动态1001/文章1002/活动1006/UGC文章1007
	group by 1
	having max(create_time) < '2023-10-01'
	) tp
on tp.member_id = tmi.ID 
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 10-16-1 XC90、XC90 Recharge、S60 Recharge、S90 Recharge、XC60 Recharge、XC40 Recharge、C40绑车车主+所有EM90留资用户
select model_name_new, count(distinct member_id) p_cnt
from (
	select vr.vin_code, vr.member_id
		,case when tc.config_name like '%T8%' then concat(tm.model_name, ' RECHARGE') else tm.model_name end as model_name_new
	from (
	select vin_code, member_id
			,row_number ()over(partition by vin_code order by bind_date desc) rn 
		from volvo_cms.vehicle_bind_relation  
		where deleted=0 and is_bind=1 and is_owner=1
		) vr 
	left join vehicle.tm_vehicle tv
	on vr.vin_code = tv.vin 
	left join basic_data.tm_model tm 
	on tv.model_id = tm.id 
	left join basic_data.tm_config tc 
	on tv.config_id = tc.id
	where tm.model_name is not null
	) a 
where upper(model_name_new) like '%RECHARGE%' or model_name_new in ('全新纯电C40', 'XC90')
group by rollup(1)
order by 1
;


-- 10-12-2 App&小程序历史有过商城下单记录，但自23年5月1日起没有再下过单的用户
select tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select a.user_id
		,count(distinct case WHEN LEFT(a.client_id,1) = '6' then '小程序订单' WHEN LEFT(a.client_id,1) = '2' then 'APP订单' end) order_source_cnt
		,max(a.order_time) last_order_time
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) t1 
on t1.user_id = tmi.ID and t1.last_order_time < '2023-05-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 10-12-4 23年5月1日以后下过单的用户
select tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select a.user_id
		,count(distinct case WHEN LEFT(a.client_id,1) = '6' then '小程序订单' WHEN LEFT(a.client_id,1) = '2' then 'APP订单' end) order_source_cnt
		,max(a.order_time) last_order_time
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	) t1 
on t1.user_id = tmi.ID and t1.last_order_time >= '2023-05-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;

-- 11-2-1 近3个月活跃但未在APP浏览过双11活动的用户
SELECT tmi.MEMBER_PHONE
FROM (
	select *, row_number()over(partition by cust_id order by id desc) rn
	from member.tc_member_info 
	where tmi.is_deleted = 0 and tmi.member_status <> 60341003
	and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
	)tmi
INNER JOIN (
	-- 神策取数
	select t1.distinct_id
	FROM (
		select distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where date >= '2023-08-03'
		and distinct_id not like '%#%'
		and length(a.distinct_id)<9
		and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel in ('App', 'Mini') or $lib = 'MiniProgram' )
		group by distinct_id
		) t1 
	left join (
		select distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event='Page_entry'
		and length(distinct_id)<9 
		and date>='2023-10-31'
		and date<'2023-11-12'
		and page_title='WOW商城·双11'
		and activity_name='2023年双十一活动'
		and a.channel='App'
		group by distinct_id
		) t2 
	on t1.distinct_id = t2.distinct_id
	where t2.distinct_id is null 
	) tt 
on tmi.cust_id = tt.distinct_id
where rn = 1
;


-- 11-3-1~11-3-4 【车主】近30天将有大额过期积分，23年12月1号即将过期V值总和大于等于1500 V值的人
select case when 是否车主 = 1 and 预测过期v值数 >= 1500 then ' 11-3-1'
					when 是否车主 = 0 and 预测过期v值数 >= 1500 then ' 11-3-2'
					when 是否车主 = 1 and 预测过期v值数 < 1500 then ' 11-3-3'
					when 是否车主 = 0 and 预测过期v值数 < 1500 then ' 11-3-4'
					end as  "人群包",
	会员id, 手机号, 是否车主, 预测过期v值数  -- 结果注意去重
from (
	select m.id as 会员id, m.is_vehicle 是否车主, m.member_phone as 手机号
		,sum(f.add_v_num - CONSUMPTION_INTEGRAL) as 预测过期v值数
	from `member`.tt_member_score_record f     -- 履历表
	join `member`.tc_member_info m on f.MEMBER_ID = m.ID
	and f.is_deleted=0 and f.ADD_V_NUM > 0 and f.status = 1
	and left(f.create_time, 7) = '2021-11'
	and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
	where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
	group by 1,2
	) a 
where 预测过期v值数 > 0
order by 人群包, 会员id desc
;

-- 11-3-5 【车主&粉丝】10月1日00：00-10月31日24：00累计获得V值大于300V的用户
select m.MEMBER_PHONE "手机号", sum(INTEGRAL) "上月获得V值"
from `member`.tt_member_flow_record f     -- 流水表
inner join `member`.tc_member_info m on f.MEMBER_ID = m.ID
and f.IS_DELETED = 0 and f.RECORD_TYPE = 0
and left(f.CREATE_TIME, 7) = '2023-10' and f.event_type <> '60731025'
and m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
where LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
group by 1
having sum(INTEGRAL) > 300
;


-- 11-6-1 在活动答题奖池中兑换过卡券，但未核销的用户
select distinct member_phone "手机号"
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.one_id = tmi.CUST_ID 
and a.is_deleted = 0 
and a.coupon_id in (5672,5670,5671,5669,5667,5666,5662,5664,5665)
and left(a.create_time, 10) in ('2023-11-03', '2023-11-07')
and a.ticket_state <> 31061003
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 11-7-1 180天以前预约试驾过，但没有到店试驾，且30天内未留资的非车主
select distinct tmi.member_phone 手机号
from (
	select member_phone, max(is_vehicle)
	from "member".tc_member_info
	where MEMBER_STATUS <> 60341003 and IS_DELETED = 0
	group by 1
	having max(is_vehicle) = 0
	) tmi
left join (
	select ta.appointment_id "预约ID"
		,ta.customer_phone "手机号"
		,ta.created_at "预约创建时间"
		,ta.invitations_date "预约到店时间"
		,tad.item_id "试乘试驾ID"
		,CASE tad.status WHEN 70711001 THEN '待试驾' WHEN 70711002 THEN '已试驾' WHEN 70711003 THEN '已取消' END 试驾状态
		,tad.drive_s_at "试驾时间1"
		,tp.drive_s_at "试驾时间2"
		,ifnull (tad.drive_s_at, tp.drive_s_at) "实际试驾时间"
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	left join drive_service.tt_testdrive_plan tp on tad.item_id = tp.item_id and tp.is_deleted = 0
	where ta.APPOINTMENT_TYPE = 70691002 -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.item_id is null and tad.status in (70711001, 70711003)
	and date_add(ta.created_at, 180) < '2023-11-13'
	and ta.is_deleted=0
	) a 
on tmi.member_phone = a.手机号
left join customer.tt_clue_clean tcc on a.手机号=tcc.mobile 
and tcc.is_deleted =0 and date_add(tcc.create_time , 30) >= '2023-11-13'
where a.手机号 is not null and tcc.mobile is null
and length(tmi.member_phone) = 11

-- 2023年大型活动，进入过的用户数（商城CNY活动、525活动、夏日季共创）
select distinct tmi.member_phone
from "member".tc_member_info tmi
left join (
	-- 神策取数
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1 
	and event in('Page_entry','Page_view')
	and date>='2023-01-01'
	and date<'2023-11-14'
	and activity_name is not null 
	and activity_id is null 
	and page_title in(
		'10月会员日'
		,'10月商城亲子季'
		,'2022沃尔沃汽车用户年度报告'
		,'2023沃尔沃中国公开赛区域挑战赛'
		,'20分贝'
		,'1月会员日'
		,'2月会员日'
		,'3月会员日'
		,'4月会员日'
		,'525车主节'
		,'618活动'
		,'6月会员日'
		,'7月会员日'
		,'8月会员日'
		,'9月会员日'
		,'TECH DAY'
		,'Tech Day'
		,'WOW商城-开学季'
		,'WOW商城-开箱季'
		,'WOW商城-消暑季'
		,'WOW商城·双11'
		,'WO的社区1周年'
		,'一个鸡蛋的力量有多大？'
		,'先心捐赠'
		,'公益榜单'
		,'售后惠聚'
		,'商城出行季活动'
		,'夏服活动'
		,'好物迎春 献礼新岁'
		,'寻找525每日锦鲤'
		,'情人节活动'
		,'新年福签'
		,'本轮奖池'
		,'沃的好物 魅力季'
		,'精品周边'
		,'起杆见远 丈量万象'
		,'集齐拼图 兑换好礼'
		  )
	) tt 
on tmi.cust_id = tt.distinct_id
where MEMBER_STATUS <> 60341003 and IS_DELETED = 0
;

-- 11-8-1 2023年至今新绑定的车主中，曾在app或小程序端点击过“邀请好友“banner的车主
select tmi.member_phone
	,case when t1.distinct_id is not null then '11-8-1' else '11-8-3' end "人群包"
from member.tc_member_info tmi
inner join (
	select *, row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	and bind_date >= '2023-01-01'
	) vr
on vr.member_id = tmi.id and vr.rn = 1
left join (
	-- 神策取数
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where date >= '2023-01-01'
	and length(distinct_id)<9
	and event = 'Button_click' and btn_name='邀请好友'
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel in ('App', 'Mini') or $lib = 'MiniProgram')
	group by distinct_id
	) t1 
on tmi.cust_id = t1.distinct_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 11-8-2 2023年至今邀请过好友试驾，但被邀请人仍未成功购车的邀请人车主
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi
inner join invite.tm_invite_record r on tmi.id = r.invite_member_id 
and r.is_deleted=0 and r.create_time >= '2023-01-01'
and (r.order_no is null or r.order_status not in ('14041002', '14041003','14041008'))
where tmi.member_status <> 60341003 and tmi.is_deleted = 0
and tmi.is_vehicle = 1
;



-- 11-12-1 参加过历史525车主节、四夏服的车主用户
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	-- 神策取数
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1 
	and event in('Page_entry','Page_view')
	and date<'2023-11-22'
	and activity_name is not null 
	and activity_id is null 
	and page_title in('525车主节','夏服活动')
	) tt 
on tmi.cust_id = tt.distinct_id
where is_vehicle = 1
and MEMBER_STATUS <> 60341003 and IS_DELETED = 0
;


-- 11-12-3 近12个月没有回厂的绑车车主（剔除近3个月新绑车的车主）
select m.member_phone "手机号"
from member.tc_member_info m
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on vr.member_id = m.id and vr.rn = 1
left join (
	select vin
	from cyx_repair.tt_repair_order 
	where is_deleted = 0 and ro_create_date >= '2022-11-21'
	and repair_type_code <> 'P' and ro_status = 80491003 -- (已结算)的工单
	and ro_no = relation_ro_no -- relation_ro_no是关联工单的工单号，如果和RO_NO相同，说明这个工单是主工单/母工单
	group by 1
	) t2 
on vr.vin_code = t2.vin 
where m.is_deleted = 0 and m.member_status <> 60341003
and vr.bind_date <= '2023-08-21'
group by 1
having count(t2.vin) = 0
;



-- 12-1-1 2023忠诚守候券 200元未使用用户 券代码：KQ202301040001，couponID：4374
select distinct member_phone "手机号"
	,case when t1.coupon_id = 4374 then '12-1-1' else '12-1-2' end "人群包"
FROM (
	select coupon_id, vin 
	from coupon.tt_coupon_detail a
	where a.is_deleted = 0 
	and a.coupon_id in (4374, 3152)
	and a.ticket_state = 31061001
	) t1 
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on t1.vin = vr.vin_code and vr.rn = 1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
where length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
order by 2,1
;


-- 12-3-1 2022年10月1日-2023年11月26日期间，在社区有过发帖行为且正文大于50字、配图不少于2张的用户
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.create_time >= '2022-10-01' and tp.create_time < '2023-11-27' 
inner join (
	select
	t.post_id,
	string_agg(case when t.类型='text' then t.内容 else null end ,';') as 发帖内容, -- 聚合函数
	replace(regexp_replace(regexp_replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','') as 发帖内容2, -- 聚合函数
	char_length(replace(regexp_replace(regexp_replace(string_agg(case when t.类型='text' then t.内容 else null end,';'),'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')) as 发帖字数,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from (
		select
			tpm.post_id,
			tpm.create_time,
			replace(tpm.node_content,E'\\u0000','') 发帖内容,
			json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
			json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where tpm.is_deleted = 0
		and tpm.create_time >= '2022-10-01'
		and tpm.create_time < '2023-11-27' 
		) t
	group by t.post_id
	) tt 
on tp.post_id = tt.post_id and tt.发帖字数 > 50 and tt.发帖图片数量 >= 2
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0

-- 12-3-2 2023年1月1日-2023年11月24日期间，在社区有过评论或点赞或收藏行为的用户
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select tc.member_id 
	from community.tm_comment tc 
	where tc.is_deleted = 0
	and tc.create_time >= '2023-01-01'
	and tc.create_time < '2023-11-25'
	union
	select tlp.member_id
	from community.tt_like_post tlp 
	where tlp.is_deleted = 0
	and tlp.create_time >= '2023-01-01' 
	and tlp.create_time < '2023-11-25'
	) t2 
on tmi.id = t2.member_id
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 12-7-1 2023忠诚守候券 200元未使用用户 券代码：KQ202301040001，couponID：4374
select distinct member_phone "手机号"
	,case when t1.coupon_id = 4374 then '12-7-1' else '12-7-2' end "人群包"
FROM (
	select coupon_id, vin 
	from coupon.tt_coupon_detail a
	where a.is_deleted = 0 
	and a.coupon_id in (4374, 3152)
	and a.ticket_state = 31061001
	) t1 
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on t1.vin = vr.vin_code and vr.rn = 1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
where length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
order by 2,1
;

-- 12-10-1 2023年度参与过社区投票的用户
select distinct tmi.id member_id
from campaign.tr_vote_record tvr
left join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 -- 投票记录表
left join campaign.tr_vote_bind_info tp on tvr.object_no =tp.object_no and tp.is_deleted =0 -- 投票编号映射活动id表  找到活动对应的投票组件id
left join campaign.tm_vote tv on tp.vote_no =tv.vote_no and tv.is_deleted =0-- 投票编号对应投票标题
left join (
	SELECT vote_title 投票标题,
		option ->> 'voteOption' AS voteOption,
		option ->> 'picUrl' AS picUrl,
		option ->> 'name' AS 投票名称
	from (
		SELECT json_array_elements(cast(tv.vote_detail as json) -> 'voteOptions') AS option 
			,tv.vote_title
     	FROM campaign.tm_vote tv) AS subquery
		)x 
	on tvr.vote_option =x.voteOption
where tvr.is_deleted =0
and left(tvr.create_time, 4) ='2023'
;

-- 12-10-2 近3个月都没来App，但是当年来过App
select distinct tmi.id member_id
from "member".tc_member_info tmi
inner join (
	-- 神策平台取数
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t 
	where length(distinct_id)<9
	and t.date >= '2023-01-01' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by t.distinct_id
	having max(t.date) < '2023-09-08'
	) t1 
on tmi.cust_id=t1.distinct_id
where length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0

-- 12-10-3 2023年11月登录App，但12月（截止取数时间）尚未登录用户
select distinct tmi.id member_id
from "member".tc_member_info tmi
inner join (
	-- 神策平台取数
	select t.distinct_id
	from events t 
	where length(distinct_id)<9
	and t.date >= '2023-11-01' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	group by 1
	having max(t.date) < '2023-12-01'
	) t1 
on tmi.cust_id=t1.distinct_id
where length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;

-- 12-10-4 2024年度在商城购买过精品的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where left(a.order_time, 4) >= '2023'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	and b.spu_type in ('51121001','51121004')   -- 筛选精品
	) t1 
on t1.user_id = tmi.ID
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
; 


-- 12-6-1 2023年粉丝浏览过预约试驾页面，但未留资的用户
select tmi.id member_id
from "member".tc_member_info tmi
left join (
	select mobile
	from customer.tt_clue_clean a 
	where a.is_deleted = 0
	and left(create_time, 4) = '2023'
	group by 1
	) t1
on tmi.member_phone=t1.mobile
left join (
	-- 神策平台取数
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t 
	where length(distinct_id)<9
	and t.date >= '2023-01-01' 
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') 
		or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and event = 'Page_view' and $title = '试驾享好礼'
	group by t.distinct_id
	) t2
on tmi.cust_id=t1.distinct_id
where t1.mobile is null and t2.distinct_id is not null
and length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;

-- 12-6-2 2023年参加过线下车展且留资大于等于1次（剔除6.1-10.9日期间）
select 
from (
	select mobile
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0 and c.active_name like '%车展%'
	and left(create_time, 4) = '2023'
	group by 1
	) t1 
inner join (
	select mobile
	from customer.tt_clue_clean a 
	where a.is_deleted = 0
	and left(create_time, 4) = '2023'
	group by 1
	) t2 
on t1.mobile = t2.mobile 
left join (
	select mobile
	from customer.tt_clue_clean a 
	where a.is_deleted = 0
	and create_time >= '2023-06-01' and create_time <= '2023-10-09'
	group by 1
	) t3
on t1.mobile = t3.mobile 
where t3.mobile is null
;


-- 12-7-1 2023忠诚守候券 200元未使用用户 券代码：KQ202301040001，couponID：4374
select distinct member_phone "手机号"
	,case when t1.coupon_id = 4374 then '12-7-1' else '12-7-2' end "人群包"
FROM (
	select coupon_id, vin 
	from coupon.tt_coupon_detail a
	where a.is_deleted = 0 
	and a.coupon_id in (4374, 3152)
	and a.ticket_state = 31061001
	) t1 
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on t1.vin = vr.vin_code and vr.rn = 1
inner join "member".tc_member_info tmi on vr.member_id = tmi.id 
where length(tmi.member_phone) = 11
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
order by 2,1
;


-- 12-8-1 XC60/S60/S90 23年未参与过推荐购活动的车主
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select vr.*
	from (
		select member_id, vin_code
			,row_number ()over(partition by vin_code order by bind_date desc) rn 
		from volvo_cms.vehicle_bind_relation  
		where deleted=0 and is_bind=1 and is_owner=1
		) vr
	left join vehicle.tm_vehicle tv on vr.vin_code = tv.vin 
	left join basic_data.tm_model tm on tv.model_id = tm.id 
	where vr.rn=1
	and (tm.model_name like 'XC60%' or tm.model_name like 'S60%' or tm.model_name like 'S90%')
	) t1 
on tmi.id = t1.member_id 
left join (
	select invite_member_id
	from invite.tm_invite_record
	where is_deleted = 0
	and create_time >= '2023-01-01'
	group by 1
	) t2 
on tmi.id = t2.invite_member_id
where t2.invite_member_id is null 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;

-- 12-8-2 2021年1月1日至2022年12月31日购车车主
select tso.customer_tel "手机号"
from cyxdms_retail.tt_sales_orders tso 
where tso.is_deleted = 0 and tso.so_status = '14041008'
and tso.created_at >= '2021-01-01' and tso.created_at < '2023-01-01'
;

-- 12-11-2 参与过电车试驾的用户
select distinct tp.mobile "手机号"
from drive_service.tt_testdrive_plan tp
left join basic_data.tm_model tm on tp.second_id = tm.id
where tp.is_deleted = 0
and drive_status = '20211003'
and tm.model_name in ('XC40 RECHARGE', '全新纯电C40')
;


-- 12-12-1 近6个月商城下过单的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time + '6 month' >= '2023-12-15'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	-- and b.spu_type in ('51121001','51121004')   -- 筛选精品
	) t1 
on t1.user_id = tmi.ID
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
; 


-- 近2个月活跃但未浏览过秋冬服页面的车主用户
select distinct member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and time >= '2023-10-25'
	and length(distinct_id)<9
	group by distinct_id
	) t1 
on tmi.cust_id = t1.distinct_id
left join (
	-- 进入到2023年秋冬服活动主页的人
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and time >= '2023-10-25'
	and event='Page_entry'
	and activity_name='2023年秋冬服活动'
	and length(distinct_id)<9
	group by distinct_id
	) t2 
on t1.distinct_id = t2.distinct_id
where tmi.is_vehicle = 1 and t2.distinct_id is null
and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
;

-- 浏览过秋冬服页面但未下单的车主用户
select distinct member_phone "手机号"
from `member`.tc_member_info tmi
left join (
	select distinct a.user_id member_id
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- 发货单表
		select d.* 
		from (
			select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
				,row_number() over(partition by d.order_code order by d.create_time desc) rk
			from `order`.tt_order_delivery d 
			where d.is_deleted=0
			) d 
		where d.rk=1
		) d 
	ON a.order_code = d.order_code
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category1_id -- 前台专区列表(获取前天专区名称)
	LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
	left join goods.spu p on b.spu_bus_id=p.bus_id
	left join(
		--V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b on a.order_code=b.order_code 
		and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	--and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and sk.coupon_id in ('5693','5695','5694','5692','5691','5689','5690','5774')    -- 秋冬服卡券
	and e.order_code is not null  -- 退款订单
	) t1 
on tmi.id = t1.member_id
left join (
	-- 进入到2023年秋冬服活动主页的人
	select distinct distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and event='Page_entry'
	and activity_name='2023年秋冬服活动'
	and length(distinct_id)<9
	) t2 
on tmi.cust_id = t2.distinct_id 
where tmi.is_vehicle = 1 
and t1.member_id is null and t2.distinct_id is not null
and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
;


-- 12-17-1 参与2022年12月#花式show圣诞#话题发帖的用户
select distinct tp.member_id
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tt.topic_id = 'QR6dxUKzHm' and left(tp.create_time, 7) = '2022-12'
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 12-17-2 参与2022年12月会员日活动的用户
select DISTINCT tmi.ID member_id 
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) 
and left(t.`date`, 7) = '2022-12'
and json_extract_path_text(cast("data" as json),'embeddedpoint') in ('memberDay12_home_onload', 'memberDay12_home_miniProgram_onload', 'memberDay12_home_app_onload')
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;

-- 12-17-3 2023年8月-11月登录过社区，但12月未进入过社区的车主
select tmi.id member_id
from `member`.tc_member_info tmi
inner join (
	-- 神策取数
	select distinct_id, max(time) last_time
	from ods_rawd.ods_rawd_events_d_di
	where event in ('Page_view','Page_entry') 
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or page_title like '%会员日%' 
			or (activity_name like '2023%' and activity_id is null))
	and time >= '2023-08-01'
	group by distinct_id
	having max(time) < '2023-12-01'
	) tt 
on tmi.cust_id = tt.distinct_id 
where tmi.is_vehicle = 1
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 12-17-4 2023年1月-7月登录过社区，但8-12月未进入过社区的车主
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	-- 神策取数
	select distinct_id, max(time) last_time
	from ods_rawd.ods_rawd_events_d_di
	where event in ('Page_view','Page_entry') 
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or page_title like '%会员日%' 
			or (activity_name like '2023%' and activity_id is null))
	and time >= '2023-01-01'
	group by distinct_id
	having max(time) < '2023-08-01'
	) tt 
on tmi.cust_id = tt.distinct_id 
where tmi.is_vehicle = 1
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1'
;


-- 12-13-1 参与过23年1月-11月会员日活动的用户
select distinct m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and event='Page_view'
and (page_title like '%会员日' OR page_title = '525车主节') -- 2023年5月的会员日叫作车主节
and page_title<>'12月会员日'  -- 2022年12月会员日 会通过其他渠道进入产生脏数据
and page_title not like '%WOW%'
--	and year(date)='2023'
--	and day(date)='25'
and a.date>='2023-01-01' and a.date < '2023-12-01'
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
and length(distinct_id)<9
;

-- 12-13-2 近12个月没有回厂的绑车车主（剔除近3个月新绑车的车主）
select m.member_phone "手机号"
from member.tc_member_info m
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on vr.member_id = m.id and vr.rn = 1
left join (
	select vin
	from cyx_repair.tt_repair_order 
	where is_deleted = 0 and ro_create_date >= '2022-12-21'
	and repair_type_code <> 'P' and ro_status = 80491003 -- (已结算)的工单
	and ro_no = relation_ro_no -- relation_ro_no是关联工单的工单号，如果和RO_NO相同，说明这个工单是主工单/母工单
	group by 1
	) t2 
on vr.vin_code = t2.vin 
where m.is_deleted = 0 and m.member_status <> 60341003
and vr.bind_date <= '2023-09-21'
-- and t2.vin is null
group by 1
having count(t2.vin) = 0
;

-- 12-13-3 2023-10-21后活跃，且12-01后未活跃的，且未参加会员日的
select distinct member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and time >= '2023-10-21'
	and length(distinct_id)<9
	group by distinct_id
    having max(date) < '2023-12-01'
	) t1 
on tmi.cust_id = t1.distinct_id
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_view'
	and (page_title like '%会员日' OR page_title = '525车主节') -- 2023年5月的会员日叫作车主节
	and page_title<>'12月会员日'  -- 2022年12月会员日 会通过其他渠道进入产生脏数据
	and page_title not like '%WOW%'
	and a.date>='2023-10-21'
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by distinct_id
	) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null
and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
;


-- 12-18-2 EM90留资用户
select distinct tcc.mobile "手机号"
from customer.tt_clue_clean tcc
inner join basic_data.tm_model tm on tcc.model_id = tm.id and model_name='EM90'
where tcc.is_deleted = 0
and LENGTH(tcc.mobile) = 11 and left(tcc.mobile,1) = '1'
;


-- 12-18-3 历史浏览EM90相关页面次数>3次用户（EM90相关内容文章页面+EM90专题页面）
select distinct tmi.member_phone "手机号"
from (
	select tvp.member_id, count(*) cnt
	from (
		select tp.post_id -- 33篇
		from community.tm_post tp 
		where member_id = 6228927 and is_deleted = 0
		and create_time < '2023-12-22'
		) t1 
	inner join community.tt_view_post tvp 
	on t1.post_id = tvp.post_id 
	group by 1
	having count(*) > 3
	) a 
inner join "member".tc_member_info tmi on a.member_id = tmi.id
and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
;


-- 12-19-1 2023年发布过（50字以上含图）的动态/文章的用户
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.create_time >= '2023-01-01' and tp.is_deleted = 0
and tp.post_type in (1001, 1007)
inner join (
	select
	t.post_id,
	string_agg(case when t.类型='text' then t.内容 else null end ,';') as 发帖内容, -- 聚合函数
	replace(regexp_replace(regexp_replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','') as 发帖内容2, -- 聚合函数
	char_length(replace(regexp_replace(regexp_replace(string_agg(case when t.类型='text' then t.内容 else null end,';'),'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')) as 发帖字数,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from (
		select
			tpm.post_id,
			tpm.create_time,
			replace(tpm.node_content,E'\\u0000','') 发帖内容,
			json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
			json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where tpm.is_deleted = 0 and tpm.create_time >= '2023-01-01'
		) t
	group by t.post_id
	) tt 
on tp.post_id = tt.post_id and tt.发帖字数 > 50 and tt.发帖图片数量 >= 1
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 12-19-2 2023年在社区有过发动态/文章行为的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp 
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
and tp.is_deleted = 0 and tp.post_type in (1001, 1007)
and tp.create_time >= '2023-01-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 12-19-3 在社区有发布动态/文章，但10月-12月没有来过社区（若无法判断有没有来过社区，可以取有没有来过app）的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
from community.tm_post tp 
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
and tp.is_deleted = 0 and tp.post_type in (1001, 1007)
left join (
	-- 神策取数
	select distinct_id, max(time) last_time
	from ods_rawd.ods_rawd_events_d_di
	where length(distinct_id)<9
	and event in ('Page_view','Page_entry') 
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or page_title like '%会员日%' 
			or (activity_name like '2023%' and activity_id is null))
	group by distinct_id
	) t2 
on tmi.cust_id = t2.distinct_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and t2.last_time < '2023-10-01'
;

-- 12-19-4 在社区有发布动态/文章，但8月-12月没有来过社区（若无法判断有没有来过社区，可以取有没有来过app）的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
from community.tm_post tp 
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
and tp.is_deleted = 0 and tp.post_type in (1001, 1007)
left join (
	-- 神策取数
	select distinct_id, max(time) last_time
	from ods_rawd.ods_rawd_events_d_di
	where length(distinct_id)<9
	and event in ('Page_view','Page_entry') 
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or page_title like '%会员日%' 
			or (activity_name like '2023%' and activity_id is null))
	group by distinct_id
	) t2 
on tmi.cust_id = t2.distinct_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and t2.last_time < '2023-08-01'
;


-- 12-16-1 浏览过双旦活动的用户
select distinct m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and `date` >= '2023-12-20'
and event='Page_entry'
and page_title ='12月会员日'
and activity_name = '2023年12月会员日'
and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App'))
and length(distinct_id)<9
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 1-2-1 参与过夏日季共创话题#WO设计了一夏#发帖的用户，话题ID：smMvGTCVa5
select distinct tp.member_id
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tt.topic_id = 'smMvGTCVa5'
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 1-2-2 参与过【出发 生活家！】#生活的乌托邦，是 #话题发帖的用户，话题ID：Mf6ZTQXcre
select distinct tp.member_id
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tt.topic_id = 'Mf6ZTQXcre'
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 商城订单(宋雯要的年度的订单字段)
select
	a.order_code 订单编号,
	b.product_id 商城兑换id,
	a.user_id 会员ID,
	a.user_name 会员姓名,
	b.spu_name 兑换商品,
	b.spu_id,
	b.sku_id,
	b.sku_code,
	b.sku_real_point 商品单价,
	ifnull(f2.前台分类,ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,CASE WHEN b.spu_type =51121001 THEN '精品'
			WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
			WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
			WHEN b.spu_type =51121004 THEN '精品'
			WHEN b.spu_type =51121006 THEN '一件代发'
			WHEN b.spu_type =51121007 THEN '经销商端产品'
			WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
			ELSE null end)) 前台分类,
		CASE b.spu_type
			WHEN 51121001 THEN '沃尔沃精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '虚拟服务卡券' 
			WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
			WHEN 51121006 THEN '一件代发'
			WHEN 51121007 THEN '经销商端产品'
			WHEN 51121008 THEN '虚拟服务权益'
			ELSE null end 商品类型,
	'' 非沃尔沃精品二级分类, 
	b.fee/100 总金额,
	round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) 不含税的总金额,
	b.sku_total_fee/ 100 商品金额,
	b.express_fee/ 100 运费金额,
	b.coupon_fee/100 优惠券抵扣金额,
	round(b.point_amount/3+b.pay_fee/100,2) 实付金额,
	b.pay_fee/100 现金支付金额,
	b.point_amount 支付V值,
	b.sku_num 兑换数量,
	a.create_time 兑换时间,
	date_format(a.create_time,'%Y-%m') 月份,
	case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
	CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品' 
		WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '京东仓商品'
		ELSE NULL END AS 仓库,
	CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
		END AS 订单商品状态,
	CASE a.status
		WHEN 51031002 THEN '待付款'
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
		END AS 订单状态,
	CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因,
	e.`退货状态`,
	e.`退货数量`,
	e.退回V值,
	e.退回时间
from "order".tt_order a  -- 订单主表
left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	-- 发货单表
	select d.* 
	from (
		select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
			,row_number() over(partition by d.order_code order by d.create_time desc) rk
		from `order`.tt_order_delivery d 
		where d.is_deleted=0
		) d 
	where d.rk=1
	) d 
ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category1_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join (
	--V值退款成功记录
	SELECT a.*,b.refund_express_code,b.eclp_rtw_no
	from (
		select so.refund_order_code,so.order_code,sp.product_id
			,CASE so.status 
				WHEN 51171001 THEN '待审核' 
				WHEN 51171002 THEN '待退货入库' 
				WHEN 51171003 THEN '待退款' 
				WHEN 51171004 THEN '退款成功' 
				WHEN 51171005 THEN '退款失败' 
				WHEN 51171006 THEN '作废退货单' END AS 退货状态
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 
		and so.status=51171004 -- 退款成功
		GROUP BY 1,2,3,4
		) a
	left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
	) e on a.order_code = e.order_code and b.product_id = e.product_id
left join (
	-- 获取前台分类[充电专区]的商品 
	select distinct j.id as spu_id ,j."name" ,f2."name" as 前台分类
	from "goods".item_spu j
	left join goods.item_sku i on j.id =i.spu_id 
	left join goods.item_sku_channel s on i.id =s.sku_id 
	left join goods.front_category f2 on s.front_category1_id=f2.id
	where f2."name"='充电专区'
	and j.is_deleted =0
	and i.is_deleted =0
	and s.is_deleted =0
	and f2.is_deleted =0
	)f2 on f2.spu_id=b.spu_id
where a.create_time >= '2023-01-01' and a.create_time < '2024-01-01'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and e.order_code is not null  -- 剔除退款订单
order by a.create_time 


-- 1-3-1 23年Q1Q2Q3有过商城下单记录但23年Q4没有下过单的用户
select t1.member_phone "手机号"
from `member`.tc_member_info t1 
inner join (
	select a.user_id, count(distinct a.order_code) "订单数", max(a.create_time) "最后订单时间"
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category1_id -- 前台专区列表(获取前天专区名称)
	left join goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
	left join goods.spu p on b.spu_bus_id=p.bus_id
	left join (
		--V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e on a.order_code = e.order_code and b.product_id = e.product_id
	where a.create_time >= '2023-01-01' and a.create_time < '2024-01-01'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	and (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	group by 1
	having max(a.create_time) < '2023-10-01'
	) t2 
on t2.user_id = t1.ID and t1.is_deleted = 0 and t1.member_status <> 60341003
and LENGTH(t1.MEMBER_PHONE) = 11 and left(t1.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 1-4-1~3 参与过夏日季共创投票的用户，且近3个月登录过App
select distinct member_id, 人群包
from (
	select 
		tvr.object_no 帖子ID,
		tp.object_name 帖子名称,
		tmi.id member_id,
		cast(tmi.cust_id as varchar) as cust_id,
		tmi.MEMBER_PHONE 沃世界注册手机号,
		tv.vote_title 投票标题,
		x.投票名称,
		tvr.create_time 投票时间,
		case when tvr.object_no in ('d0Qp6E1WM9', 'KjM7LcPYKd', 'xYgzpJiTcj', '5m4a0iHuhv', 'BIMhbW50Ea') then '1-4-1'
			when tvr.object_no = 'b8wp4LrQMQ' then '1-4-2'
			when tvr.object_no = 'R0KqsqKjSO' then '1-4-3'
			end "人群包"
	from campaign.tr_vote_record tvr
	left join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 -- 投票记录表
	left join campaign.tr_vote_bind_info tp on tvr.object_no =tp.object_no and tp.is_deleted =0 -- 投票编号映射活动id表  找到活动对应的投票组件id
	left join campaign.tm_vote tv on tp.vote_no =tv.vote_no and tv.is_deleted =0-- 投票编号对应投票标题
	left join (
		SELECT vote_title 投票标题,
			option ->> 'voteOption' AS voteOption,
			option ->> 'picUrl' AS picUrl,
			option ->> 'name' AS 投票名称
		from (
			SELECT json_array_elements(cast(tv.vote_detail as json) -> 'voteOptions') AS option ,tv.vote_title
			FROM campaign.tm_vote tv
			) AS subquery
		 )x 
	on tvr.vote_option =x.voteOption
	where tvr.is_deleted =0
	and tvr.object_no in ('d0Qp6E1WM9', 'KjM7LcPYKd', 'xYgzpJiTcj', '5m4a0iHuhv', 'BIMhbW50Ea', 'b8wp4LrQMQ', 'R0KqsqKjSO')
	and tmi.is_deleted = 0 and tmi.member_status <> 60341003
	) t1 
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2023-10-16'
	group by distinct_id
	) t2 
on t1.cust_id = t2.distinct_id
;


-- 1-4-4 浏览过共创征集文章的用户，且近3个月登录过App
select distinct tmi.id member_id 
from `member`.tc_member_info tmi
inner join community.tt_view_post tvp 
on tmi.id = tvp.member_id and tvp.post_id = 'mzeEiQAogL' and tvp.is_deleted = 0
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2023-10-16'
	group by distinct_id
	) t2 
on tmi.cust_id = t2.distinct_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 1-4-5 在社区有发布动态/文章，但7月-12月没有登录过App
select distinct tp.member_id
from community.tm_post tp
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2023-07-01' and date < '2024-01-01'
	group by distinct_id
	) t2 
on tmi.cust_id = t2.distinct_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and t2.distinct_id is null 
;


-- 1-5-2 金卡粉丝用户30天内无试驾或预约记录
select tmi.member_phone "手机号"
from `member`.tc_member_info tmi
left join (
	select distinct tmi.id member_id
	from cyx_appointment.tt_appointment ta
	inner join member.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
	where APPOINTMENT_TYPE = 70691002 and date_add(created_at, 30) >= '2024-01-16'
	) t1 
on tmi.id = t1.member_id 
left join (
	select distinct tp.mobile
	from drive_service.tt_testdrive_plan tp
	where tp.is_deleted = 0 and date_add(drive_s_at, 30) >= '2024-01-16'
	) t2 
on tmi.member_phone = t2.mobile
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.level_id = 2 and tmi.is_vehicle = 0
and t1.member_id is null 
and t2.mobile is null 
;
	
	

-- 1-5-3 过去2个月浏览过购车页面5次以上
select tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct_id, count(*)
	from (
		select a.distinct_id, date
		from ods_rawd.ods_rawd_events_d_di a
		where length(a.distinct_id)<9
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') 
		and `date` >= '2023-11-16' 
		and a.event ='Page_view'
		and a.page_title ='购车'
		union all
		-- Mini
		select a.distinct_id, date
		from ods_rawd.ods_rawd_events_d_di a
		where length(a.distinct_id)<9
		and (a.`$lib` in ('MiniProgram') or a.channel ='Mini')
		and a.event ='Page_view' 
		and ((`$title` ='爱车-潜客'and page_title ='购车' and `date`>= '2023-11-16' ) 
			or (page_title ='爱车_车主'and `date`>= '2023-11-16'))
		) aa 
	group by distinct_id
	having count(*) > 5
	) tt 
on tmi.cust_id = tt.distinct_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 1-5-4 2023年参加过线下车展且留资大于等于3次
select tcc.mobile "手机号"
FROM customer.tt_clue_clean tcc
JOIN activity.cms_active ca on tcc.campaign_id = ca.uid and ca.active_name like '%车展%'
where tcc.is_deleted = 0 and left(tcc.create_time, 4) = '2023'
group by 1
having count(*) >= 3
;

-- 1-6-1 近45天APP活跃但未参与1月商城活动的车主
select tmi.id member_id 
from `member`.tc_member_info tmi
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and length(distinct_id)<9
	and addDays(date, 45) >= '2024-01-17'
	group by distinct_id
	) t1 
on tmi.cust_id = t1.distinct_id 
left join (
  select distinct_id
  from ods_rawd.ods_rawd_events_d_di 
  where length(distinct_id)<9
  and activity_name = '2024年1月商城星选季'
  group by distinct_id
  ) t2
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
;



-- 1-7-1 23年未参与过推荐购活动的S60/S90车主
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select vin_code, member_id
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on tmi.id = vr.member_id and vr.rn=1
left join vehicle.tm_vehicle tv on vr.vin_code = tv.vin 
left join basic_data.tm_model tm on tv.model_id = tm.id 
left join invite.tm_invite_record r on vr.member_id = r.invite_member_id 
and left(r.create_time,4)='2023' and r.is_deleted = 0
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and (tm.model_name like 'S60%' or tm.model_name like 'S90%')
and r.invite_member_id is null 
;

-- 1-7-2 2023年10月-12月参与过会员日的车主
select distinct m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and event='Page_view'
and page_title in ('10月会员日', '11月会员日', '12月会员日')
and a.date>='2023-10-01' and a.date < '2024-01-02'
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
and length(distinct_id)<9
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 1-7-3 2023年10月-12月社区内发过UGC内容的车主(帖子和动态都算，可以咨询子晨)
select distinct tmi.member_phone
from community.tm_post tp
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
and tp.create_time >= '2023-10-01' and tp.create_time < '2024-01-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and is_vehicle = 1
;


-- 1-7-4 2023年6月-12月新车主
select distinct tmi.member_phone
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select *
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr 
on kp.vin = vr.vin_code and vr.rn=1
inner join member.tc_member_info tmi on vr.member_id = tmi.id 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where kp.invoice_date >= '2023-06-01' and kp.invoice_date < '2024-01-01'
and kp.is_deleted = 0
;


-- 1-8-1 近半年沃世界+App 登录3天及以上非车主，且有过留资行为且未试驾用户（剔除一个月内留资）
select distinct tmi.member_phone
from `member`.tc_member_info tmi
inner join (
	select mobile, case when create_time + '1 MONTH' >= '2024-01-17' then 1 end last_1mth_clue
	from customer.tt_clue_clean tcc1
	where tcc1.is_deleted = 0 and tcc1.create_time + '6 MONTH' >= '2024-01-17'
	group by 1
	) t1
on tmi.member_phone=t1.mobile 
left join (
	select tp.mobile
	from drive_service.tt_testdrive_plan tp
	where tp.is_deleted = 0 and drive_s_at + '6 MONTH' >= '2024-01-17'
	group by 1
	) t2
on tmi.member_phone = t2.mobile 
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	and addMonths(date,6) >= '2024-01-17'
	group by distinct_id
	having count(distinct date) >= 3
	) t3
on tmi.cust_id = t3.distinct_id
where t1.last_1mth_clue is null 
and t2.mobile is null 
and t3.distinct_id is not null 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.is_vehicle = 0
;


-- 1-8-2 2023年全年车展留资过 且 2023年全年在私域活动留资过且2023年进入过沃世界首页浏览过，但截止当前未试驾的用户（私域活动code已发邮件给飞华）
select distinct tmi.member_phone
from `member`.tc_member_info tmi
inner join (
	select tcc.mobile
	FROM customer.tt_clue_clean tcc
	JOIN activity.cms_active ca on tcc.campaign_id = ca.uid and ca.active_name like '%车展%'
	where tcc.is_deleted = 0 and left(tcc.create_time, 4) = '2023'
	group by 1
	) t1 
on tmi.member_phone = t1.mobile
inner join (
	select tcc.mobile
	FROM customer.tt_clue_clean tcc
	JOIN activity.cms_active ca on tcc.campaign_id = ca.uid
	where tcc.is_deleted = 0 and left(tcc.create_time, 4) = '2023'
	and ca.active_code in (
		'IBDMMARWSJGZHHYY2023VCCN'
		,'IBDMAPRWSJZCHYT12023VCCN'
		,'IBDMAPRWSJYYSJT12023VCCN'
		,'IBDMAPRWSJZCHYT22023VCCN'
		,'IBDMAPRWSJZCHYT22023VCCN'
		,'IBDMNOV3WDYMYYSJ2021VCCN'
		,'WSJYY'
		,'IBDMJUNALLKSYYMP2023VCCN'
		,'IBDMJULALLWCDWXC2023VCCN'
		,'IBCRMJUNWEWAPPSJ2022VCCN'
		,'IBDMJANS905GZSBT2023VCCN'
		,'IBDMJANS603GZSBT2023VCCN'
		,'IBDMFEBS905GZSBT2023VCCN'
		,'IBDMJANC40XC4DJP2023VCCN'
		,'IBDMAPRC40XSBQET2023VCCN'
		,'IBDMAPRS90BTHYHJ2023VCCN'
		,'IBDMAPRXC40RYYSJ2023VCCN'
		,'IBDMAPRXC40BYYSJ2023VCCN'
		,'IBDMAPRC40BEYYSJ2023VCCN'
		,'IBDMAPRXC60YYSJI2023VCCN'
		,'IBDMAPRXC6T8YYSJ2023VCCN'
		,'IBDMAPRS60YYSJIA2023VCCN'
		,'IBDMAPRS60T8YYSJ2023VCCN'
		,'IBDMAPRV60YYSJIA2023VCCN'
		,'IBDMAPRXC90YYSJI2023VCCN'
		,'IBDMAPRXC9T8YYSJ2023VCCN'
		,'IBDMAPRS90YYSJIA2023VCCN'
		,'IBDMAPRS90T8YYSJ2023VCCN'
		,'IBDMAPRV90CCYYSJ2023VCCN'
		,'IBDMMAYC40BEVYSJ2023VCCN'
		,'IBDMMAYXC40BEVSJ2023VCCN'
		,'IBDMMAYV90CCYYSJ2023VCCN'
		,'IBDMMAYV60CXZCSJ2023VCCN'
		,'IBDMMAYXC40RYBSJ2023VCCN'
		,'IBDMMAYXC60CYYSJ2023VCCN'
		,'IBDMMAYS60CXZCSJ2023VCCN'
		,'IBDMMAYXC90CYYSJ2023VCCN'
		,'IBDMMAYS90CXZCSJ2023VCCN'
		,'IBDMJUNXC4CXZCSJ2023VCCN'
		,'IBDMJUNXC4BCXPSJ2023VCCN'
		,'IBDMJUNC40BCXPSJ2023VCCN'
		,'IBDMJUNXC6CXZCSJ2023VCCN'
		,'IBDMJUNS60CXZCSJ2023VCCN'
		,'IBDMJUNV60CXZCSJ2023VCCN'
		,'IBDMJUNXC9CXZCSJ2023VCCN'
		,'IBDMJUNS90CXZCSJ2023VCCN'
		,'IBDMJUNV90CXZCSJ2023VCCN'
		,'IBDMJULXC4CXZCSJ2023VCCN'
		,'IBDMJULX4BCXZCSJ2023VCCN'
		,'IBDMJULC4BCXZCSJ2023VCCN'
		,'IBDMJULXC6CXZCSJ2023VCCN'
		,'IBDMJULS60CXZCSJ2023VCCN'
		,'IBDMJULV60CXZCSJ2023VCCN'
		,'IBDMJULXC9CXZCSJ2023VCCN'
		,'IBDMJULS90CXZCSJ2023VCCN'
		,'IBDMJULV90CXZCSJ2023VCCN'
		,'IBDMAUGXC4ICPRTD2023VCCN'
		,'IBDMAUGXC4BCPRTD2023VCCN'
		,'IBDMAUGC40BCPRTD2023VCCN'
		,'IBDMAUGXC60CPRTD2023VCCN'
		,'IBDMAUGS609CPRTD2023VCCN'
		,'IBDMAUGV609CPRTD2023VCCN'
		,'IBDMAUGXC90CPRTD2023VCCN'
		,'IBDMAUGS909CPRTD2023VCCN'
		,'IBDMAUGV90CCPRTD2023VCCN'
		,'IBCRMDECALL000222023VCCN'
		,'IBCRMNOVALL000082023VCCN'
		,'IBCRMOCTALL000112023VCCN'
		,'IBDMDECHBJHHDXCX2022VCCN'
		,'IBDMDECHBJHHDAPP2022VCCN'
		,'IBDMMARHBJHLZXCX2023VCCN'
		,'IBDMMARHBJHLZAPP2023VCCN'
		,'IBDMJUNALLWSJXCX2023VCCN'
		,'IBDMJUNALLWEWAPP2023VCCN'
		,'IBDMSEPMIXTJXHLM2023VCCN'
		,'IBDMSEPMIXTJXHLA2023VCCN'
		,'IBDMMARXC4C40XCX2023VCCN'
		,'IBDMAPR525YYSXCX2023VCCN'
		,'IBDMMAYVXS469XCX2023VCCN'
		,'IBDMJUNALLXSSJMP2023VCCN'
		,'IBCRMAUGALL000102023VCCN'
		,'IBDMAUGMIXSJXCXD2023VCCN'
		,'IBCRMSEPALL000572023VCCN'
		,'IBCRMNOVALL000302023VCCN'
		,'IBCRMDECALL000152023VCCN'
		,'IBDMSEPMIXGEFXCX2023VCCN')
	group by 1
	) t2
on tmi.member_phone = t2.mobile
left join (
	select tp.mobile
	from drive_service.tt_testdrive_plan tp
	where tp.is_deleted = 0 and drive_s_at >= '2023-01-01'
	group by 1
	) t3
on tmi.member_phone = t3.mobile 
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	and date >= '2023-01-01' and date < '2024-01-01'
	and event = 'Page_view' and page_title = '推荐'
	group by distinct_id
	) t4
on tmi.cust_id = t4.distinct_id
where t3.mobile is null 
and t4.distinct_id is not null 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 1-9-1 23年参加过任一 一期及以上次数会员日的车主
select m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and a.event='Page_view' 
and a.date>='2023-01-01' and a.date < '2024-01-01'
and ((a.date < '2023-12-01' and page_title<>'12月会员日' and (page_title like '%会员日' OR page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
	or (a.date >= '2023-12-01' and page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
and page_title not like '%WOW%'
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
and length(distinct_id)<9
and m.is_vehicle  = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
group by m.member_phone
;

-- 1-9-2 23年累计参加过3次及以上会员日的粉丝用户
select m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and a.event='Page_view' 
and a.date>='2023-01-01' and a.date < '2024-01-01'
and ((a.date < '2023-12-01' and page_title<>'12月会员日' and (page_title like '%会员日' OR page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
	or (a.date >= '2023-12-01' and page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
and page_title not like '%WOW%'
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
and length(distinct_id)<9
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
group by m.member_phone
having count(distinct page_title) >= 3
;


-- 2-1-1 1月1日00：00-1月31日24：00累计获得V值大于300V的用户
select m.MEMBER_PHONE "手机号", sum(INTEGRAL) "上月获得V值"
from `member`.tt_member_flow_record f     -- 流水表
inner join `member`.tc_member_info m on f.MEMBER_ID = m.ID
and f.IS_DELETED = 0 and f.RECORD_TYPE = 0 and f.event_type <> '60731025'
and f.CREATE_TIME >= '2024-01-01' and f.CREATE_TIME < '2024-02-01'
where m.MEMBER_STATUS <> 60341003 and m.IS_DELETED = 0
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
group by 1
having sum(INTEGRAL) > 300
;


-- 2-2-1 23年参与过推荐购活动的白金卡和黑卡车主
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select invite_member_id
	from invite.tm_invite_record
	where is_deleted = 0
	and left(create_time, 4) = '2023'
	group by 1
	) t2 
on tmi.id = t2.invite_member_id
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
and tmi.is_vehicle = 1 and tmi.member_level >= 3
;


-- 2-2-2 23年6-12月内成功建立过邀约关系的车主（被推荐人留资过就算）
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select invite_member_id
	from invite.tm_invite_record
	where is_deleted = 0
	and create_time >= '2023-06-01' and create_time < '2024-01-01'
	group by 1
	) t2 
on tmi.id = t2.invite_member_id
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
and tmi.is_vehicle = 1
;



-- 2-2-3 23年1月-24年1月新绑车，且未参与过推荐购的车主
select distinct tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select vr.*
	from (
		select member_id, vin_code, bind_date
			,row_number ()over(partition by vin_code order by bind_date desc) rn 
		from volvo_cms.vehicle_bind_relation  
		where deleted=0 and is_bind=1 and is_owner=1
		) vr
	where vr.rn=1
	and bind_date >= '2023-01-01' and bind_date < '2024-02-01'
	) t1 
on tmi.id = t1.member_id 
left join (
	select invite_member_id
	from invite.tm_invite_record
	where is_deleted = 0
	group by 1
	) t2 
on tmi.id = t2.invite_member_id
where t2.invite_member_id is null 
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
and tmi.is_vehicle = 1
;



-- 3-1-1 23年6月1日-24年2月26日，通过沃尔沃汽车App或沃尔沃汽车沃世界+小程序提交过预约试驾，但未到店完成试驾的用户
select distinct 手机号
from (
	select ta.appointment_id "预约ID"
		,ta.customer_phone "手机号"
		,ta.created_at "预约创建时间"
		,ta.invitations_date "预约到店时间"
		,tad.item_id "试乘试驾ID"
		,CASE tad.status WHEN 70711001 THEN '待试驾' WHEN 70711002 THEN '已试驾' WHEN 70711003 THEN '已取消' END 试驾状态
		,tad.drive_s_at "试驾时间1"
		,tp.drive_s_at "试驾时间2"
		,ifnull (tad.drive_s_at, tp.drive_s_at) "实际试驾时间"
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	left join drive_service.tt_testdrive_plan tp on tad.item_id = tp.item_id and tp.is_deleted = 0
	where ta.APPOINTMENT_TYPE = 70691002 -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and tad.status <> 70711003   -- 非已取消
	and ta.created_at >= '2023-06-01' and ta.created_at < '2024-02-27'
	and tad.item_id is null
	) a 
;


-- 3-2-1 发布过#与爱心计划同行#话题内容的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt 
on tp.post_id = tt.post_id and tt.topic_id = '396Teg7oWI'
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' 
;

-- 3-3-1 发布过#小红花不怕晒# 话题内容的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt 
on tp.post_id = tt.post_id and tt.topic_id = '3ZAD1ixdbX'
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' 
;

-- 3-4-1 截止8号下午18：00浏览过3月平台活动H5首页且参与答题的用户
select distinct m.member_phone "手机号"
from `member`.tc_member_info m
inner join (
	-- 神策取数
	select distinct_id
	from events a
	where length(distinct_id)<9
	and time between '2024-03-08' and '2024-03-08 18:00:00' 
	and event = 'Button_click'
	and bussiness_name = '社区'
	and page_title = 'Hej Moment_参与答题 抽取好礼'
	group by distinct_id
	) t1
on cast(m.cust_id as varchar)=a.distinct_id 
and m.is_deleted = 0 and m.member_status <> '60341003'
and LENGTH(m.MEMBER_PHONE) = 11 and left(m.MEMBER_PHONE,1) = '1' 
;


-- 降级人群包取数逻辑V1
select
	a.MEMBER_ID,
	ifnull(b.当前有效成长值,0) 当前有效成长值,
	ifnull(c."截止到4.30即将过期的成长值",0) "截止到4.30即将过期的成长值",
	ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0) "截止到5.1剩余有效成长值",
	case when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 2000 then '银卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 5000 then '金卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 10000 then '白金卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) >= 10000 then '黑卡'
		else null end 会员等级
from (
	-- 23年即将降级的人群 886人
	select distinct MEMBER_ID
	from member.tt_member_level_change
	where substr(CREATE_TIME,1,7)='2022-09'
	and MEMBER_ID not in
		(select MEMBER_ID 
		from member.tt_member_level_change
		where date(CREATE_TIME)>='2022-10-01')
	) a
left join (
	-- 有效成长值 一年有效期
	select r.member_id, sum(r.add_c_num) 当前有效成长值 
	from "member".tt_member_score_record r
	where r.create_time >= curdate() ::TIMESTAMP + '-1 year'
	and r.create_time < curdate()
	and r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0
	group by 1
	) b on a.MEMBER_ID = b.member_id
left join (
	-- 截止到24年4.30日 24:00:00即将过期的人群
	select r.member_id, sum(r.add_c_num) "截止到4.30即将过期的成长值"
	from "member".tt_member_score_record r
	where r.create_time >= curdate() ::TIMESTAMP + '-1 year'
	and r.create_time < '2023-05-01'::TIMESTAMP    -- 截止到4.30
	and r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0
	group by 1
	) c on a.MEMBER_ID = c.member_id
	
	
-- 降级人群包取数逻辑V2
select
	a.MEMBER_ID,
	ifnull(b.当前有效成长值,0) 当前有效成长值,
	ifnull(c."截止到4.30即将过期的成长值",0) "截止到4.30即将过期的成长值",
	ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0) "截止到5.1剩余有效成长值",
	case when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 2000 then '银卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 5000 then '金卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) < 10000 then '白金卡'
		when (ifnull(b.当前有效成长值,0) - ifnull(c."截止到4.30即将过期的成长值",0)) >= 10000 then '黑卡'
		else null end 会员等级
from (
	-- 23年即将降级的人群 886人
	select distinct MEMBER_ID
	from member.tt_member_level_change
	where substr(CREATE_TIME,1,7)='2022-10'
	and MEMBER_ID not in
		(select MEMBER_ID 
		from member.tt_member_level_change
		where date(CREATE_TIME)>='2022-11-01')
	) a
left join (
	-- 有效成长值 一年有效期
	select r.member_id, sum(r.add_c_num) 当前有效成长值 
	from "member".tt_member_score_record r
	where r.create_time >= curdate() ::TIMESTAMP + '-1 year'
	and r.create_time < curdate()
	and r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0
	group by 1
	) b on a.MEMBER_ID = b.member_id
left join (
	-- 截止到24年4.30日 24:00:00即将过期的人群
	select r.member_id, sum(r.add_c_num) "截止到4.30即将过期的成长值"
	from "member".tt_member_score_record r
	where r.create_time >= curdate() ::TIMESTAMP + '-1 year'
	and r.create_time < '2023-05-01'::TIMESTAMP    -- 截止到4.30
	and r.status = 1  -- 状态：1 有效 0 无效
	and r.is_deleted = 0
	group by 1
	) c on a.MEMBER_ID = c.member_id
;


-- 4-1-1 24年至今推荐购活动页面浏览用户
select distinct member_phone "手机号"
from (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where event = 'Page_entry'
	and (($lib in ('iOS','Android') and left($app_version,1)='5') or channel in ('App', 'Mini') or $lib = 'MiniProgram')
	and page_title = '推荐购_邀请好友'
	and length(distinct_id)<9
	and date >= '2024-01-01'
	group by distinct_id
	) t1
inner join (
	-- 清洗cust_id
	select m.cust_id, m.member_time, m.is_vehicle,m.member_phone,
		 row_number() over(partition by m.cust_id order by m.create_time desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status<>'60341003' and m.is_deleted=0
	and m.cust_id is not null 
	and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
	Settings allow_experimental_window_functions = 1
	) t2
on toString(t1.distinct_id) = toString(t2.cust_id)
where t2.rk=1
;


-- 参与过23年6月“先心活动”和23年9月“一个鸡蛋的力量”小红花公益活动的用户
select distinct member_phone "手机号"
from (
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t
	where bussiness_name = '爱心计划'
	and activity_name = '2023年6月爱心计划-先心捐赠活动'
	and length(distinct_id)<9
	and t.time >= '2023-06-01' and time < '2023-07-01'
	union distinct
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t
	where event in('Page_entry','Page_view','MP_Page_view')
	and activity_name ='2023年腾讯99公益节活动'
	and page_title ='一个鸡蛋的力量有多大？'
	and length(distinct_id)<9
	and t.time >= '2023-09-01' and time < '2023-10-01'
	) t1
inner join (
	-- 清洗cust_id
	select m.cust_id, m.member_time, m.is_vehicle,m.member_phone,
		 row_number() over(partition by m.cust_id order by m.create_time desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status<>'60341003' and m.is_deleted=0
	and m.cust_id is not null 
	and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
	Settings allow_experimental_window_functions = 1
	) t2
on toString(t1.distinct_id) = toString(t2.cust_id)
where t2.rk=1
;


-- 4-3-1 2023年全年有发过贴，但24年截止到24年4月25日未发帖用户
SELECT distinct tmi.member_phone "手机号"
from (
	select tp.member_id, max(create_time)
	from community.tm_post tp 
	where 1=1
	and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	and tp.is_deleted <> 1       
	and tp.create_time >= '2023-01-01'
	group by 1
	having max(create_time) < '2024-01-01'
	) tp 
inner join `member`.tc_member_info tmi on tp.member_id = tmi.ID 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
;


-- 4-4-2 同时参与过24年1月、2月、3月3次会员日的人群
select distinct t2.member_phone "手机号"
from (
	select distinct_id, count(distinct activity_name) activity_cnt
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_entry'
	and page_title in ('1月会员日', '2月会员日', '3月会员日')
	and ((a.activity_name = '2024年1月会员日' and a.date = '2024-01-25')
		or (a.activity_name = '2024年2月会员日' and a.date = '2024-02-25')
		or (a.activity_name = '2024年3月会员日' and a.date = '2024-03-25'))
	and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by 1
	having count(distinct activity_name) = 3
	) t1
inner join (
	-- 清洗cust_id
	select m.cust_id, m.member_time, m.is_vehicle,m.member_phone,
		 row_number() over(partition by m.cust_id order by m.create_time desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status<>'60341003' and m.is_deleted=0
	and m.cust_id is not null 
	and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
	Settings allow_experimental_window_functions = 1
	) t2
on toString(t1.distinct_id) = toString(t2.cust_id)
where t2.rk=1
;


-- 4-4-3 参与过24年1月、2月、3月会员日中的1个或者2个的人群
select distinct t2.member_phone "手机号"
from (
	select distinct_id, count(distinct activity_name) activity_cnt
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_entry'
	and page_title in ('1月会员日', '2月会员日', '3月会员日')
	and ((a.activity_name = '2024年1月会员日' and a.date = '2024-01-25')
		or (a.activity_name = '2024年2月会员日' and a.date = '2024-02-25')
		or (a.activity_name = '2024年3月会员日' and a.date = '2024-03-25'))
	and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by 1
	having count(distinct activity_name) < 3
	) t1
inner join (
	-- 清洗cust_id
	select m.cust_id, m.member_time, m.is_vehicle,m.member_phone,
		 row_number() over(partition by m.cust_id order by m.create_time desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status<>'60341003' and m.is_deleted=0
	and m.cust_id is not null 
	and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
	Settings allow_experimental_window_functions = 1
	) t2
on toString(t1.distinct_id) = toString(t2.cust_id)
where t2.rk=1
;

-- 4-4-4 参与过24年1月-3月任意一期会员日，本月未于社区活跃的用户
select distinct t2.member_phone "手机号"
from (
	select distinct_id, count(distinct activity_name) activity_cnt
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_entry'
	and page_title in ('1月会员日', '2月会员日', '3月会员日')
	and ((a.activity_name = '2024年1月会员日' and a.date = '2024-01-25')
		or (a.activity_name = '2024年2月会员日' and a.date = '2024-02-25')
		or (a.activity_name = '2024年3月会员日' and a.date = '2024-03-25'))
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by 1
	) t1
inner join (
	-- 清洗cust_id
	select m.cust_id, m.member_time, m.is_vehicle,m.member_phone,
		 row_number() over(partition by m.cust_id order by m.create_time desc) rk
	from ods_memb.ods_memb_tc_member_info_cur m
	where m.member_status<>'60341003' and m.is_deleted=0
	and m.cust_id is not null 
	and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
	Settings allow_experimental_window_functions = 1
	) t2
on toString(t1.distinct_id) = toString(t2.cust_id)
left join (
    select distinct_id
    from ods_rawd.ods_rawd_events_d_di 
    where event in ('Page_view','Page_entry') 
    and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
    and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情')
       	  or page_title like '%会员日%' 
       	  or (activity_name like '2023%' and activity_id is null)
       	  or (activity_name like '2024%' and activity_id is null))
    and date >= '2024-04-01' 
    union distinct 
    select distinct_id
    from ods_rawd.ods_rawd_events_d_di 
    where event='Button_click' 
    and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
    and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
    and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送',
    				'朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
    and date >= '2024-04-01' 
    union distinct
    select distinct_id
    from ods_rawd.ods_rawd_events_d_di 
    where 1=1
    and event='$AppClick' 
    and `$element_content`='发现'
    and is_bind=1
    and date >= '2024-04-01'
	) t3
on t1.distinct_id = t3.distinct_id
where t2.rk=1 and t3.distinct_id is null
;


-- 4-5-1 EX30专区订阅人群
select distinct member_phone "手机号"
from 
	(
	select user_id,distinct_id,date
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and `date` >= '2024-04-16' and `date` < '2024-04-24'
	and event='Button_click'
	and length(distinct_id)<9
	and page_title ='沃尔沃EX30'
	and btn_name = '广告'
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or `$lib` ='MiniProgram' or  channel in ('Mini', 'App') )   -- 双端
	) a
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		and LENGTH(m.member_phone) = 11 and left(m.member_phone,1)='1'
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
;



-- 4-6-1 购买春服O2O卡券，但目前仍未到店核销的用户
select distinct member_phone "手机号"
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.one_id = tmi.CUST_ID 
and a.is_deleted = 0 
and a.coupon_id in (
	6203,6237,6238,6239,6240,6241,6220,6223
	,6221,6224,6228,6231,6229,6232,6227,6206
	,6207,6209,6212,6210,6213,6208,6215,6218
	,6214,6217,6216,6219,6233,6235,6234,6236
	,6205,6205,6205,6204,6204,6204,6258,6259
	,6287,6296,6283,6284,6288,6297,6260,6265
	,6289,6298,6285,6286,6290,6299,6267,6271
	,6291,6300,6274,6276,6292,6301,6277,6278
	,6293,6302,6279,6280,6294,6303,6281,6282
	,6295,6304)
and a.ticket_state = 31061001  -- 非已核销  
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
and length(tmi.member_phone) = 11 and left(tmi.member_phone, 1) = '1'
;

-- 5-1-1 2023&2024年线上活动留资但未到店用户
select t1.mobile "手机号"
from (
	select mobile, min(create_time) first_clue_time 
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0
	and create_time >= '2023-01-01' and create_time < '2024-05-08'
	and c.active_code in (
		'IBDMMARWSJGZHHYY2023VCCN'
		,'IBDMAPRWSJZCHYT12023VCCN'
		,'IBDMAPRWSJYYSJT12023VCCN'
		,'IBDMAPRWSJZCHYT22023VCCN'
		,'IBDMNOV3WDYMYYSJ2021VCCN'
		,'WSJYY'
		,'IBDMJUNALLKSYYMP2023VCCN'
		,'IBDMJULALLWCDWXC2023VCCN'
		,'IBCRMJUNWEWAPPSJ2022VCCN'
		,'IBDMJANS905GZSBT2023VCCN'
		,'IBDMJANS603GZSBT2023VCCN'
		,'IBDMFEBS905GZSBT2023VCCN'
		,'IBDMJANC40XC4DJP2023VCCN'
		,'IBDMAPRC40XSBQET2023VCCN'
		,'IBDMAPRS90BTHYHJ2023VCCN'
		,'IBDMAPRXC40RYYSJ2023VCCN'
		,'IBDMAPRXC40BYYSJ2023VCCN'
		,'IBDMAPRC40BEYYSJ2023VCCN'
		,'IBDMAPRXC60YYSJI2023VCCN'
		,'IBDMAPRXC6T8YYSJ2023VCCN'
		,'IBDMAPRS60YYSJIA2023VCCN'
		,'IBDMAPRS60T8YYSJ2023VCCN'
		,'IBDMAPRV60YYSJIA2023VCCN'
		,'IBDMAPRXC90YYSJI2023VCCN'
		,'IBDMAPRXC9T8YYSJ2023VCCN'
		,'IBDMAPRS90YYSJIA2023VCCN'
		,'IBDMAPRS90T8YYSJ2023VCCN'
		,'IBDMAPRV90CCYYSJ2023VCCN'
		,'IBDMMAYC40BEVYSJ2023VCCN'
		,'IBDMMAYXC40BEVSJ2023VCCN'
		,'IBDMMAYV90CCYYSJ2023VCCN'
		,'IBDMMAYV60CXZCSJ2023VCCN'
		,'IBDMMAYXC40RYBSJ2023VCCN'
		,'IBDMMAYXC60CYYSJ2023VCCN'
		,'IBDMMAYS60CXZCSJ2023VCCN'
		,'IBDMMAYXC90CYYSJ2023VCCN'
		,'IBDMMAYS90CXZCSJ2023VCCN'
		,'IBDMJUNXC4CXZCSJ2023VCCN'
		,'IBDMJUNXC4BCXPSJ2023VCCN'
		,'IBDMJUNC40BCXPSJ2023VCCN'
		,'IBDMJUNXC6CXZCSJ2023VCCN'
		,'IBDMJUNS60CXZCSJ2023VCCN'
		,'IBDMJUNV60CXZCSJ2023VCCN'
		,'IBDMJUNXC9CXZCSJ2023VCCN'
		,'IBDMJUNS90CXZCSJ2023VCCN'
		,'IBDMJUNV90CXZCSJ2023VCCN'
		,'IBDMJULXC4CXZCSJ2023VCCN'
		,'IBDMJULX4BCXZCSJ2023VCCN'
		,'IBDMJULC4BCXZCSJ2023VCCN'
		,'IBDMJULXC6CXZCSJ2023VCCN'
		,'IBDMJULS60CXZCSJ2023VCCN'
		,'IBDMJULV60CXZCSJ2023VCCN'
		,'IBDMJULXC9CXZCSJ2023VCCN'
		,'IBDMJULS90CXZCSJ2023VCCN'
		,'IBDMJULV90CXZCSJ2023VCCN'
		,'IBDMAUGXC4ICPRTD2023VCCN'
		,'IBDMAUGXC4BCPRTD2023VCCN'
		,'IBDMAUGC40BCPRTD2023VCCN'
		,'IBDMAUGXC60CPRTD2023VCCN'
		,'IBDMAUGS609CPRTD2023VCCN'
		,'IBDMAUGV609CPRTD2023VCCN'
		,'IBDMAUGXC90CPRTD2023VCCN'
		,'IBDMAUGS909CPRTD2023VCCN'
		,'IBDMAUGV90CCPRTD2023VCCN'
		,'IBCRMDECALL000222023VCCN'
		,'IBCRMNOVALL000082023VCCN'
		,'IBCRMOCTALL000112023VCCN'
		,'IBCRMJANALL000032024VCCN'
		,'IBCRMFEBALL000012024VCCN'
		,'IBCRMMARALL000012024VCCN'
		,'IBCRMAPRALL000032024VCCN'
		,'IBCRMMAYALL000462024VCCN'
		,'IBDMDECHBJHHDXCX2022VCCN'
		,'IBDMDECHBJHHDAPP2022VCCN'
		,'IBDMMARHBJHLZXCX2023VCCN'
		,'IBDMMARHBJHLZAPP2023VCCN'
		,'IBDMJUNALLWSJXCX2023VCCN'
		,'IBDMJUNALLWEWAPP2023VCCN'
		,'IBDMSEPMIXTJXHLM2023VCCN'
		,'IBDMSEPMIXTJXHLA2023VCCN'
		,'IBCRMJANALL000042024VCCN'
		,'IBCRMJANALL000052024VCCN'
		,'IBCRMJANALL000482024VCCN'
		,'IBCRMFEBALL000472024VCCN'
		,'IBCRMMARALL000272024VCCN'
		,'IBCRMMARALL000262024VCCN'
		,'IBDMMARXC4C40XCX2023VCCN'
		,'IBDMAPR525YYSXCX2023VCCN'
		,'IBDMMAYVXS469XCX2023VCCN'
		,'IBDMJUNALLXSSJMP2023VCCN'
		,'IBCRMAUGALL000102023VCCN'
		,'IBDMAUGMIXSJXCXD2023VCCN'
		,'IBCRMSEPALL000572023VCCN'
		,'IBCRMNOVALL000302023VCCN'
		,'IBCRMDECALL000152023VCCN'
		,'IBCRMJANALL000062024VCCN'
		,'IBCRMJANALL000492024VCCN'
		,'IBCRMMARALL000162024VCCN'
		,'IBCRMAPRALL000662024VCCN'
		,'IBDMSEPMIXGEFXCX2023VCCN')
	group by 1
	) t1
left join (
	select mobile_phone, max(arrive_date) last_arrive_date
	from cyx_passenger_flow.tt_passenger_flow_info
	where is_deleted = 0 and arrive_date >= '2023-01-01'
	group by 1
	) t2 
on t1.mobile = t2.mobile_phone and t1.first_clue_time < t2.last_arrive_date
where t2.mobile_phone is null 
;

-- 5-1-2 2024年截止5月车展留资未到店用户
select t1.mobile
from (
	select mobile, min(create_time) first_clue_time 
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0
	and create_time >= '2024-01-01' and create_time < '2024-05-08'
	and c.active_code in (
		'IBAUTOAPRALL000312024VCCN','IBAUTOAPRALL000592024VCCN','IBAUTOAPRALL000512024VCCN',
		'IBAUTOAPRALL000552024VCCN','IBAUTOMAYALL000212024VCCN','IBAUTOMAYALL000262024VCCN',
		'IBAUTOMAYALL000302024VCCN','IBAUTOMAYALL000342024VCCN','IBAUTOMAYALL000432024VCCN',
		'IBAUTOMAYALL000392024VCCN','IBAUTOAPRALL000322024VCCN'	)
	group by 1
	) t1
left join (
	select mobile_phone, max(arrive_date) last_arrive_date
	from cyx_passenger_flow.tt_passenger_flow_info
	where is_deleted = 0 and arrive_date >= '2024-01-01'
	group by 1
	) t2 
on t1.mobile = t2.mobile_phone and t1.first_clue_time < t2.last_arrive_date
where t2.mobile_phone is null 
;


-- 5-2-1 北京、上海、成都、广州、深圳、杭州的车主 报名过“运动”类活动且APP上线 或者 被加精或上推荐达到3次的
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on tmi.id = vr.member_id and vr.rn = 1
left join vehicle.tm_vehicle tv on vr.vin_code = tv.vin 
left join organization.tm_company tcp on tcp.company_code = tv.dealer_code and tcp.company_type=15061003
left join (
	-- 被加精或上推荐达到3次的
	select member_id
	from community.tm_post t1 
	where t1.is_deleted = 0 
	and (ifnull(selected_time, 0) <> 0 or recommend = 1)
	group by 1 having count(*) >= 3
	) tp 
on tmi.id = tp.member_id
where replace(tcp.city_name, '市', '') in ('北京', '上海', '成都', '广州', '深圳', '杭州')
and tp.member_id is not null
and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' 
;


-- 5-10-1 4月活跃但5月未活跃的APP用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
    select distinct_id, max(time) last_time
    from ods_rawd.ods_rawd_events_d_di t
    where 1=1 
    and length(distinct_id)<9
    and t.`time` >= '2024-04-01'
    and ((`$lib` in ('iOS','Android') and substr(`$app_version`,1, 1)='5') or  channel ='App')   -- 双端
    group by 1
    having max(t.`time`) < '2024-05-01'
    ) t1
on toString(m.cust_id) =toString(t1.distinct_id)
left join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((gio.$platform in('iOS','Android') and left(gio.`$client_version` ,1)='5') or gio.channel in ('App'))
	and length(gio.distinct_id)<9
    group by distinct_id
    ) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 5-10-2 近6个月小程序至少活跃过3天, 但从未在APP活跃的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from (
		select distinct_id, toDate(date) log_date
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and a.`time` >= '2023-11-10' 
		and a.`time` < '2024-05-01'
		and length(a.distinct_id)<9
		and (`$lib` = 'MiniProgram' or channel in ('Mini'))
		union distinct
		select distinct_id, toDate(date) log_date
		from dwd_23.dwd_23_gio_tracking gio
		where 1=1
		and toDate(gio.`time`) >= '2024-05-01'
		and (`$lib` = 'MiniProgram' or gio.channel in ('Mini'))
		and length(gio.distinct_id)<9
		) aa 
	group by 1 having count(distinct log_date) >= 3
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and a.`time` < '2024-05-01'
	and length(a.distinct_id)<9
	and ((a.`$lib` in('iOS','Android') and left(a.`$app_version`,1)='5') or channel in ('App'))
	union distinct
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((gio.$platform in('iOS','Android') and left(gio.`$client_version` ,1)='5') or gio.channel in ('App'))
	and length(gio.distinct_id)<9
	) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 5-3-1 浏览过23年四季服、24年春服、23年525售后&充电专场的平台注册用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_entry'
	and ((page_title = '夏服活动' and activity_name = '2023年夏服活动')
		or (page_title = '沃尔沃汽车服务节' and activity_name = '2023年秋冬服活动')
		or (page_title = '春服' and activity_name = '2024年春服')
		or `$url` like '%https://newbie.digitalvolvo.com/volvo-activity-h5/index.html#/525/aftermarket%'
		or `$url` like '%https://newbie.digitalvolvo.com/volvo-activity-h5/index.html#/525/charge%')
	and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by 1
	) t1
on toString(m.cust_id) = toString(t1.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 5-3-2 23年或24年回厂但未注册沃尔沃汽车App的车主用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select *, row_number ()over(partition by vin_code order by bind_date desc) rn 
	from ods_vocm.ods_vocm_vehicle_bind_relation_cur
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on toString(vr.member_id) = toString(m.id) and vr.rn = 1
inner join (
	select VIN
	from ods_cyre.ods_cyre_tt_repair_order_d octrod  
	WHERE IS_DELETED = 0 AND RO_CREATE_DATE >= '2023-01-01'
	AND REPAIR_TYPE_CODE <> 'P' AND RO_STATUS = 80491003 -- (已结算)的工单
	group by 1
	) t2 
on vr.vin_code = t2.VIN 
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and a.`time` < '2024-05-01'
	and length(a.distinct_id)<9
	and ((a.`$lib` in('iOS','Android') and left(a.`$app_version`,1)='5') or channel in ('App'))
	union distinct
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((gio.$platform in('iOS','Android') and left(gio.`$client_version` ,1)='5') or gio.channel in ('App'))
	and length(gio.distinct_id)<9
	) t3 
on toString(m.cust_id) = toString(t3.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and t3.distinct_id is null 
;

-- 5-4-1 23年和24年下单过精品且V值余额大于100的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select distinct a.user_id
	from `order`.tt_order a
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join (
		-- V值退款成功记录
		SELECT a.*,b.refund_express_code,b.eclp_rtw_no
		from (
			select so.refund_order_code,so.order_code,sp.product_id
				,CASE so.status 
					WHEN 51171001 THEN '待审核' 
					WHEN 51171002 THEN '待退货入库' 
					WHEN 51171003 THEN '待退款' 
					WHEN 51171004 THEN '退款成功' 
					WHEN 51171005 THEN '退款失败' 
					WHEN 51171006 THEN '作废退货单' END AS 退货状态
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp 
			on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2,3,4
			) a
		left join `order`.tt_sales_return_order b 
		on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
		) e 
	on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.order_time >= '2023-01-01'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and e.order_code is null  -- 剔除退款订单
	and b.spu_type in ('51121001','51121004')   -- 筛选精品
	) t1 
on t1.user_id = tmi.ID
where tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> 60341003
and tmi.member_v_num > 100
; 



-- 5-5-1 获得525勋章但过去1个月未登录过App的用户
select DISTINCT d.member_phone 手机号
from (
	select cast(d.cust_id as varchar) cust_id, d.member_phone
	from mine.madal_detail c
	inner join `member`.tc_member_info d on cast(d.ID as varchar) = c.user_id 
	and d.is_deleted = 0 and d.member_status <> 60341003
	inner join mine.user_medal e on e.id = c.medal_id and e.medal_name = '525乐享家'
	where c.deleted = 1  -- 有效
	and c.status = 1  -- 正常
	) t1 
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and a.`time` >= '2024-04-11'
	and a.`time` < '2024-05-01'
	and length(a.distinct_id)<9
	and ((a.`$lib` in('iOS','Android') and left(a.`$app_version`,1)='5') or channel in ('App'))
	union distinct
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((gio.$platform in('iOS','Android') and left(gio.`$client_version` ,1)='5') or gio.channel in ('App'))
	and length(gio.distinct_id)<9
	) t2
on t1.cust_id = t2.distinct_id 
where t2.distinct_id is null 
;


-- 5-5-2 参与过任一期会员日但过去1个月未登录过App的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and a.event='Page_entry' 
	and a.date>='2023-01-01' and a.date < '2024-05-01'
	and (a.date < '2023-12-01' and page_title<>'12月会员日')
	and (page_title like '%会员日' OR page_title = '525车主节')
	and page_title not like '%WOW%'
	and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by distinct_id
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and a.`time` >= '2024-04-11'
	and a.`time` < '2024-05-01'
	and length(a.distinct_id)<9
	and ((a.`$lib` in('iOS','Android') and left(a.`$app_version`,1)='5') or channel in ('App'))
	union distinct
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((gio.$platform in('iOS','Android') and left(gio.`$client_version` ,1)='5') or gio.channel in ('App'))
	and length(gio.distinct_id)<9
	) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 5-5-3 24年订阅过3月或4月会员日活动用户（订阅用户自动触达）
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event = 'Button_click' 
	and btn_name = '订阅活动'
	and page_title in ('3月会员日', '4月会员日')
	and activity_name in ('2024年3月会员日', '2024年4月会员日')
	and length(a.distinct_id)<9
	and ((a.`$lib` in('iOS','Android') and left(a.`$app_version`,1)='5') or `$lib` = 'MiniProgram' or channel in ('Mini', 'App'))
	group by 1
	) t3 
on toString(m.cust_id) = toString(t3.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;



-- 5-6-1 北京、上海、成都、广州、深圳、杭州的车主 且APP发帖被加精或上推荐至少1次的
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr
on tmi.id = vr.member_id and vr.rn = 1
left join vehicle.tm_vehicle tv on vr.vin_code = tv.vin 
left join organization.tm_company tcp on tcp.company_code = tv.dealer_code and tcp.company_type=15061003
left join (
	select member_id
	from community.tm_post t1 
	where t1.is_deleted = 0 and platform_app = 1
	and (ifnull(selected_time, 0) <> 0 or recommend = 1)
	group by 1 having count(*) >= 1
	) tp 
on tmi.id = tp.member_id
where replace(tcp.city_name, '市', '') in ('北京', '上海', '成都', '广州', '深圳', '杭州')
and tp.member_id is not null
and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' 
;



-- 5-11-1 2022年8月18日~2024年5月15日期间，App内累计发动态/文章超过3次车主的member ID
select member_id
from community.tm_post tp 
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id and tmi.is_vehicle = 1
where tp.is_deleted = 0 and platform_app = 1
and post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time >= '2022-08-18' and tp.create_time < '2024-05-16'
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
group by 1 
having count(*) > 3
;


-- 5-8-1 2024/5/15-2024/5/24，浏览过525车主节未下商城订单的车主/粉丝
select DISTINCT case when is_vehicle=1 then '5-8-1' else '5-8-2' end "rqb"
	,b.member_phone as member_phone
from (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and event = 'Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and var_activity_name = '2024年5月525车主节'
	and toDate(`time`) >=  '2024-05-15' and toDate(`time`) < '2024-05-25'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	) a
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
left join (
	-- 商城订单明细(CK)
	select
		a.order_code as order_code    -- `订单号`,
		,a.user_id as user_id         -- `下单人会员ID`,
		,a.user_phone as user_phone   --`下单人手机号`
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >='2024-05-15' and a.create_time < '2024-05-25'   -- 订单时间
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	order by a.create_time
	) c 
on toString(c.user_id) = toString(b.`id`)
where c.user_id is null
;


-- 5-12 24年4月~5月推荐购已下订未开票用户及其对应推荐人
select ti.be_invite_mobile "被推荐人手机号", ti.invite_mobile "推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and order_status <> '14041009'
and ti.order_no is not null 
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-04-01' and create_time < '2024-05-22'
;


-- 5-13-1 24年活跃1.1~4.30活跃过但是5月不活跃的APP车主
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
    select distinct_id, max(time) last_time
    from ods_rawd.ods_rawd_events_d_di t
    where 1=1 
    and length(distinct_id)<9
    and t.`time` >= '2024-01-01'
    and ((`$lib` in ('iOS','Android') and substr(`$app_version`,1, 1)='5') or  channel ='App')   -- 双端
    group by 1
    having max(t.`time`) < '2024-05-01'
    ) t1
on toString(m.cust_id) =toString(t1.distinct_id)
left join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version` ,1)='5') or channel in ('App'))
	and length(gio.distinct_id)<9
    group by distinct_id
    ) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and m.is_vehicle = '1'
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 5-14-1 5月不活跃的APP车主
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
    select distinct_id, max(time) last_time
    from ods_rawd.ods_rawd_events_d_di t
    where 1=1 
    and length(distinct_id)<9
    -- and t.`time` >= '2024-01-01'
    and ((`$lib` in ('iOS','Android') and substr(`$app_version`,1, 1)='5') or  channel ='App')   -- 双端
    group by 1
    having max(t.`time`) < '2024-05-01'
    ) t1
on toString(m.cust_id) =toString(t1.distinct_id)
left join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-05-01'
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version` ,1)='5') or channel in ('App'))
	and length(gio.distinct_id)<9
    group by distinct_id
    ) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null 
and m.is_vehicle = '1'
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 5-15-1 账户现有V值余额大于7500V值且近3-6个月有商城订单支付的车主/粉丝
select DISTINCT case when m.is_vehicle=1 then '5-15-1' else '5-15-2' end "人群包"
	,m.member_phone as "手机号"
	,IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) as "V值余额"
from member.tc_member_info m
inner join (
	select
		a.order_code as order_code    -- `订单号`,
		,a.user_id as user_id         -- `下单人会员ID`,
		,a.user_phone as user_phone   --`下单人手机号`
	from `order`.tt_order a    -- 订单表
	left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-11-25' and a.create_time < '2024-02-25'   -- 订单时间
	-- and a.create_time >='2023-12-25' and a.create_time < '2024-03-25'   -- 订单时间
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	order by a.create_time
	) a 
on a.user_id = m.`id`
where m.is_deleted =0 and m.member_status <> '60341003'
and IFNULL(m.MEMBER_V_NUM,0) - IFNULL(m.MEMBER_LOCK_V_NUM,0) > 7500
order by 1,2
;



-- 5-9-1 2024/5/15-2024/5/28期间参与过525车主节·会员权益页面抽奖活动的所有用户（自动触达）
select DISTINCT b.member_phone as member_phone
from (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and event = 'Button_click'
	and btn_name in ('每日任务抽奖', '限定任务抽奖')
	and page_title = '525车主节·会员权益'
	and var_activity_name = '2024年5月525车主节'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and toDate(`time`) >=  '2024-05-15' and toDate(`time`) < '2024-05-29'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) a
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
;

-- 5-16-1 24年1月1日-24年2月29日访问过APP社区首页，但24年3月1日起未访问过社区的用户
select distinct t1.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((`$lib` in ('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2024-01-01' and date < '2024-03-01'
	and event = 'Page_entry' and page_title = '推荐'
	group by distinct_id
	) t2 
on toString(t1.cust_id) =toString(t2.distinct_id)
left join (
	select w.`distinct_id` as  `distinct_id`--,w.`date` 
	from dwd_23.dwd_23_gio_tracking  w
	where w.`event` in ('Page_view','Page_entry') 
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and (w.`page_title` in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or w.`page_title` like '%会员日%' 
			or (w.`var_activity_name` like '2023%' and w.`var_activity_id` is null) 
			or (w.`var_activity_name` like '2024%' and w.`var_activity_id` is null))
	and w.`date` >= '2024-05-01'
	and w.`date`<='2024-05-31'
	union distinct 
	-- 社区互动人数
	select q.`distinct_id` as `distinct_id`--,q.`date`
	from dwd_23.dwd_23_gio_tracking q
	where q.`event`='Button_click' 
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
	and q.`page_title` in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and q.`btn_name` in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送',
						'回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and q.`date` >='2024-05-01'
	and q.`date`<='2024-05-31'
	union distinct 
	-- 发现 按钮点击（车主）7月开始
	select r.`distinct_id` as `distinct_id`--,r.`date`
	from dwd_23.dwd_23_gio_tracking r
	left join ods_memb.ods_memb_tc_member_info_cur m3 on toString(m3.cust_id)=toString(r.distinct_id) 
	where 1=1
	and r.`event`='Button_click' 
	and r.`btn_name`='发现'
	AND r.var_btn_type ='btn'
	and m3.`is_vehicle`=1
	and r.`date` >= '2024-05-01'
	and r.`date`<='2024-05-31'
	union distinct 
	select w.`distinct_id` as  `distinct_id`--,w.`date` 
	from ods_rawd.ods_rawd_events_d_di  w
	where w.`event` in ('Page_view','Page_entry') 
	and (((`$lib` in ('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib`='MiniProgram' or channel='Mini'))
	and (w.`page_title` in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or w.`page_title` like '%会员日%' or (w.`activity_name` like '2023%' and w.`activity_id` is null) or (w.`activity_name` like '2024%' and w.`activity_id` is null))
	and w.`date` >= '2024-03-01'
	and w.`date`<'2024-05-01'
	union distinct 
	-- 社区互动人数
	select q.`distinct_id` as `distinct_id`--,q.`date`
	from ods_rawd.ods_rawd_events_d_di q
	where q.`event`='Button_click' 
	and (((`$lib` in ('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib`='MiniProgram' or channel='Mini'))
	and q.`page_title` in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and q.`btn_name` in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and q.`date` >='2024-03-01'
	and q.`date`<'2024-05-01'
	union distinct 
	-- 发现 按钮点击（车主）7月开始
	select r.`distinct_id` as `distinct_id`--,r.`date`
	from ods_rawd.ods_rawd_events_d_di r
	left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(r.distinct_id) 
	where 1=1
	and r.`event`='$AppClick' 
	and r.`$element_content`='发现'
	and m.`is_vehicle`=1
	and r.`date` >= '2024-03-01'
	and r.`date`<'2024-05-01'
	) t3 
on t2.distinct_id = t3.distinct_id
where t3.distinct_id is null 
and t1.is_deleted = 0 and t1.member_status <> '60341003'
;


-- 5-17-1 24年4月1日-24年5月31日，访问过APP社区首页的用户
select distinct t1.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2024-05-01' and date < '2024-06-01'
	and event = 'Page_view' and page_title = '推荐'
	union distinct
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((`$lib` in ('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2024-04-01' and date < '2024-05-01'
	and event = 'Page_view' and page_title = '推荐'
	) t2 
on toString(t1.cust_id) =toString(t2.distinct_id)
where t1.is_deleted = 0 and t1.member_status <> '60341003'
;


-- 5-17-1 24年4月1日-24年5月31日，访问过APP社区首页的用户，且在4月1日-24年5月31日访问过商城or浏览过任一商详页
select distinct t1.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2024-05-01' and date < '2024-06-01'
	and event = 'Page_view' and page_title = '推荐'
	union distinct
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and ((`$lib` in ('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and length(distinct_id)<9
	and date >= '2024-04-01' and date < '2024-05-01'
	and event = 'Page_view' and page_title = '推荐'
	) t2 
on toString(t1.cust_id) =toString(t2.distinct_id)
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di
	where 1=1 
	and length(distinct_id)<9
	and `date` >= '2024-04-01' and `date` < '2024-05-01'
	and event in('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
	and (page_title in ('商城', '商城首页') or `$title`='商城')
	union distinct 
	select distinct_id
	from dwd_23.dwd_23_gio_tracking
	where 1=1 
	and length(distinct_id)<9
	and `date` >= '2024-05-01' and `date` < '2024-06-01'
	and event in ('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
	and (page_title in ('商城','商城首页') or `$title`='商城')
	) t3 
on t2.distinct_id = t3.distinct_id
where t1.is_deleted = 0 and t1.member_status <> '60341003'
;




-- 实验组1人群，逻辑见5月16日11：08飞华发的邮件“Re:FW: Fw: 绑车关系表1000行数据明细”
with all_vin_detail as (
	select t1.vin, t1.phone, t2.model_code, t2.model_name, t2.invoice_date, t2.car_age, nvl(t3.last_ro_date, '1900-01-01 00:00:00') last_ro_date
	from (
	    select distinct dwd.decrypt_for_hive(r.vin) vin, dwd.decrypt_for_hive(r.mobile) phone
	    from ods_cdp.ods_cdp_dws_vehicle_relation_cur r
	    where r.cvr_type = '开票车主' and r.pday = '2024-05-27'  -- 昨天的最新的数据
	    ) t1
	inner join (
		select dwd.decrypt_for_hive(translate(a.id_vin_crypto,'["]','')) vin
		    ,model_code, a.model_name, a.invoice_date
		    ,ROUND(DATEDIFF(CURRENT_DATE, a.invoice_date)/365, 1) car_age
		from ods_cdp.ods_cdvo_rtp_vehicle_profilebase_attribute_cur a
		) t2 
	on t1.vin = t2.vin
	left join (
		select vin, max(ro_create_date) last_ro_date
		from ods_cyre.ods_cyre_tt_repair_order_cur o
		where o.is_deleted = 0 and repair_type_code <> 'P' and o.ro_status = '80491003'   -- 已结算工单
		group by vin
		) t3 
	on t1.vin = t3.vin
	)
select phone, min(rqb) rqb
from (
	select vin, phone, invoice_date
		,case when last_ro_date >= '2023-05-14' then '5-16-1' else '5-16-2' end as rqb
	from all_vin_detail
	where model_code in ('1033','996') and car_age >= 5
	) a 
group by phone
;


-- 6-1-1 2024年1-5月粉丝浏览过试驾享好礼、预约试驾页面，但24年1月至今没有留资过的用户
select distinct tmi.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t 
	where length(distinct_id)<9
	and t.date >= '2024-01-01' and t.date < '2024-05-01'
	and ((($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and event = 'Page_entry' and page_title = '试驾享好礼'
	union distinct 
	select t.distinct_id
	from dwd_23.dwd_23_gio_tracking t 
	where length(distinct_id)<9
	and t.date >= '2024-05-01' and t.date < '2024-06-01'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and event = 'Page_entry' and page_title = '试驾享好礼'
	) t2
on toString(tmi.cust_id)= toString(t2.distinct_id)
left join (
	select mobile 
	from ods_cust.ods_cust_tt_clue_clean_cur 
	where is_deleted =0 and create_time >= '2024-01-01'
	group by mobile
	) t3
on tmi.member_phone = t3.mobile
where t3.mobile is null
and tmi.is_vehicle = '0'
and tmi.member_status <> '60341003' and tmi.is_deleted = 0
;

-- 6-1-2 2024年1-5月商城浏览3次及以上的粉丝
select distinct t1.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select distinct_id, count(distinct log_date)
	from (
		select distinct_id, left(cast(`date` as varchar), 10) log_date
		from ods_rawd.ods_rawd_events_d_di
		where 1=1 
		and length(distinct_id)<9
		and `date` >= '2024-01-01' and `date` < '2024-05-01'
		and event in('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
		and (page_title in ('商城', '商城首页') or `$title`='商城')
		union distinct 
		select distinct_id, left(cast(`date` as varchar), 10) log_date
		from dwd_23.dwd_23_gio_tracking
		where 1=1 
		and length(distinct_id)<9
		and `date` >= '2024-05-01' and `date` < '2024-06-01'
		and event in ('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
		and (page_title in ('商城','商城首页') or `$title`='商城')
		) aa 
	group by distinct_id
	having count(distinct log_date) >= 3
	) t2
on toString(t1.cust_id)= toString(t2.distinct_id)
where t1.is_deleted = 0 and t1.member_status <> '60341003'
and t1.is_vehicle = '0'
;


-- 6-1-3 60天前以前有过试驾预约记录，但是截止当前都没试驾，且近30天内也没留资过的潜客
select t1.member_phone 
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select *
	from (
	 	SELECT DISTINCT ta.APPOINTMENT_ID `预约ID`
		    ,ta.CUSTOMER_PHONE `预约手机号`
		    ,ifNull(ca.active_name,'空') `沃世界来源渠道`
		    ,ifNull(tm2.model_name,'空') `留资车型`
			,case when tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01' then '已试驾'
				when d.DRIVE_STATUS in (20211001,20211004) then '待试驾'
				when tc.CODE_CN_DESC in ('待确认','待进店') then '待试驾'
				when d.DRIVE_STATUS in (20211002) then '已取消'
				when tc.CODE_CN_DESC in ('超时取消','已取消') then '已取消'
				else tc.CODE_CN_DESC end as `最终试驾状态`
			,case when(tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01') and d.DRIVE_S_AT > 	'1990-01-01' and d.DRIVE_S_AT < ta.CREATED_AT then '异常_已试驾' end as `异常_已试驾状态`
			,ta.CREATED_AT `预约时间`
	    FROM ods_cyap.ods_cyap_tt_appointment_d ta
	    LEFT JOIN (select * from ods_cyap.ods_cyap_tt_appointment_drive_d where IS_DELETED =0) tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	    LEFT JOIN (select * from ods_drse.ods_drse_tt_testdrive_plan_d where IS_DELETED =0) d on tad.ITEM_ID = d.ITEM_ID
	    LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON tc.CODE_ID = ta.IS_ARRIVED
	    LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON ca.uid = ta.CHANNEL_ID 
	    LEFT JOIN ods_bada.ods_bada_tm_model_cur tm2 on tad.THIRD_ID = toString(tm2.id)
	    WHERE date_add(ta.CREATED_AT, 60)  < '2024-06-04'
	    and ta.APPOINTMENT_TYPE  in (70691001,70691002)    -- 预约试乘试驾
	    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	    order by ta.CREATED_AT
	    ) aa 
	where `最终试驾状态` <> '已试驾'
	) t2 
on t1.member_phone = t2.`预约手机号`
left join (
	select mobile 
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-05-04'
	group by 1
	) tcc 
on t1.member_phone=tcc.mobile
where tcc.mobile is null 
and t1.is_vehicle = '0'
and t1.is_deleted = 0 and t1.member_status <> '60341003'
;

-- 6-1-4 2024年1-5月内App+小程序累计登录3天以上的【非车主】
select DISTINCT t1.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select distinct_id, count(distinct log_date)
	from (
		select distinct_id, left(cast(`date` as varchar), 10) log_date
		from ods_rawd.ods_rawd_events_d_di t 
		where length(distinct_id)<9
		and t.date >= '2024-01-01' and t.date < '2024-05-01'
		and ((($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
		union distinct 
		select distinct_id, left(cast(`date` as varchar), 10) log_date
		from dwd_23.dwd_23_gio_tracking t 
		where length(distinct_id)<9
		and t.date >= '2024-05-01' and t.date < '2024-06-01'
		and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini'))
		) aa 
	group by distinct_id having count(distinct log_date) > 3
	) t2
on toString(t1.cust_id)= toString(t2.distinct_id)
where t1.is_deleted = 0 and t1.member_status <> '60341003'
and t1.is_vehicle = '0'
;


-- 6-2-1 累计签到≥4次和23年有过订单记录，但24年未下过单的用户
select distinct t1.member_phone "手机号"
from (
	select a.member_id, b.member_phone, count(*) sign_cnt
	FROM mms.tt_sign_in_record a  -- 签到表
	inner join `member`.tc_member_info b on a.member_id = b.ID 
	and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.is_deleted = 0
	group by 1,2
	having count(*) >= 4
	) t1
inner join (
	select a.user_id as member_id, max(a.create_time) create_time
	from `order`.tt_order a    -- 订单表
	left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'   -- 订单时间
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and h.order_code is null  -- 剔除退款订单
	group by 1 having max(a.create_time) < '2024-01-01'
	) t2
on t1.member_id = t2.member_id
;



-- 6-3-1 累计签到≥7次和24年1月1日起，浏览过沃尔沃汽车App或沃尔沃汽车沃世界+小程序预约试驾&邀约试驾的用户
select distinct t1.member_phone "手机号"
from (
	select a.member_id, cast(cust_id as varchar) cust_id, b.member_phone, count(*) sign_cnt
	FROM mms.tt_sign_in_record a  -- 签到表
	inner join `member`.tc_member_info b on a.member_id = b.ID 
	and b.is_deleted=0 and b.member_status<>60341003
	WHERE a.is_deleted = 0
	group by 1
	having count(*) >= 7
	) t1
inner join (
	-- CK取数
	select t.distinct_id
	from ods_rawd.ods_rawd_events_d_di t 
	where length(distinct_id)<9
	and t.date >= '2024-01-01' and t.date < '2024-05-01'
	and ((($lib in ('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
	and event = 'Page_entry' and page_title = '试驾享好礼'
	union DISTINCT
	select t.distinct_id
	from dwd_23.dwd_23_gio_tracking t 
	where length(distinct_id)<9
	and t.date >= '2024-05-01'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and event = 'Page_entry' and page_title = '试驾享好礼'
	) t2
on t1.cust_id = t2.distinct_id
;


-- 6-4-1 2024年1-5月商城下单累计消费超过1000元的车主用户
select distinct t1.member_phone "手机号"
from member.tc_member_info t1
inner join (
	select member_id, sum(amount)
	from (
		select a.order_code    -- `订单号`,
			,a.user_id as member_id         -- `下单人会员ID`,
			,round(b.point_amount/3+b.pay_fee/100,2) amount  -- 实付金额
		from `order`.tt_order a    -- 订单表
		left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
		left join (
			-- 退单明细
			select so.refund_order_code, so.order_code, sp.product_id,
				case when so.status = '51171001' then  '待审核' 
					when so.status = '51171002' then  '待退货入库' 
					when so.status = '51171003' then  '待退款' 
					when so.status = '51171004' then  '退款成功' 
					when so.status = '51171005' then  '退款失败' 
					when so.status = '51171006' then  '作废退货单'
					else null end `退货状态`,
				sum(sp.sales_return_num) `退货数量`,
				sum(so.refund_point) `退回V值`,
				max(so.create_time) `退回时间`
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
			where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
			and so.status = '51171004'     -- 退款成功
			GROUP BY 1,2,3,4
			) h 
		on a.order_code = h.order_code and b.product_id = h.product_id
		where 1=1
		and a.create_time >= '2024-01-01' and a.create_time < '2024-06-01'   -- 订单时间
		and a.is_deleted <> 1
		and b.is_deleted <> 1
		and a.type = '31011003'  -- 订单类型：沃世界商城订单
		and a.separate_status = '10041002' -- 拆单状态：否
		and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
		AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
		-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		-- and g.order_code is not null  -- 剔除退款订单
		)
	group by member_id
	having sum(amount) > 1000
	) t2 
on t1.id = t2.member_id 
and t1.is_vehicle = 1
and t1.is_deleted=0 and t1.member_status<>60341003
;


-- 6-5-1 24年参与过推荐购活动的白金卡和黑卡车主
select distinct t2.member_phone "手机号"
from invite.tm_invite_record t1
inner join member.tc_member_info t2 on t1.invite_member_id = t2.id
and t2.is_deleted=0 and t2.member_status<>60341003
and t2.is_vehicle = 1 and t2.member_level >= 3
where t1.is_deleted = 0 
and t1.create_time >= '2024-01-01'
;


-- 6-6-1 累计签到≥8次的车主&粉丝+全量电车用户（电车：XC40 Recharge，C40 Recharge，EM90）
select distinct t1.member_phone "手机号"
from member.tc_member_info t1
inner join (
	select a.member_id
	FROM mms.tt_sign_in_record a  -- 签到表
	WHERE a.is_deleted = 0
	group by 1 having count(*) >= 8
	union 
	select vr.member_id
	from (
		select vin_code, member_id, row_number()over(partition by vin_code order by bind_date desc) rn 
		from volvo_cms.vehicle_bind_relation  
		where deleted=0 and is_bind=1 and is_owner=1
		) vr 
	inner join vehicle.tm_vehicle tv on vr.vin_code = tv.vin and vr.rn=1
	left join basic_data.tm_model tm on tv.model_id = tm.id and tm.is_deleted = 0
	where tm.model_name in ('XC40 RECHARGE', 'C40 RECHARGE', 'EM90')
	group by 1	
	) t2
on t1.id = t2.member_id 
and t1.is_deleted=0 and t1.member_status<>60341003
;


-- 6-7-1 累计签到≥9次 or 获得优惠券且未核销用户
select distinct t1.member_phone "手机号"
from member.tc_member_info t1
inner join (
	select a.member_id
	FROM mms.tt_sign_in_record a  -- 签到表
	WHERE a.is_deleted = 0
	group by 1 having count(*) >= 9
	union 
	select cast(a.member_id as varchar) member_id
	FROM coupon.tt_coupon_detail a 
	where a.is_deleted = 0 
	and a.coupon_id in ('6869','6870','6873','6871','6872')
	and a.ticket_state = 31061001
	group by 1
	) t2
on t1.id = t2.member_id 
and t1.is_deleted=0 and t1.member_status<>60341003
;


-- 6-8-1 截止5/25（包含）参与集卡已达5次的用户
select distinct tmi.member_phone "手机号", case when card_cnt>=5 then '6-8-1' else '6-8-2' end "人群包"
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select cr.member_id, count(distinct cr.activity_card_id) card_cnt 
	from ods_voam.ods_voam_activity_card_record_d cr
	left join ods_voam.ods_voam_activity_card_d c on cr.activity_card_code=c.activity_card_code 
	where cr.is_deleted = 0
	and cr.create_time < '2024-05-26' -- 全部24年数据
	group by cr.member_id
	) tr 
on toString(tmi.id) = toString(tr.member_id) 
where tmi.is_deleted=0 and tmi.member_status<>'60341003'
order by card_cnt desc
;


-- 6-8-3 2024/4/25-2024/6/20未提交过养修预约的车主用户
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi 
left join (
	select ta.one_id 
	from cyx_appointment.tt_appointment ta
	where ta.is_deleted=0 
	and ta.APPOINTMENT_TYPE = 70691005
	and ta.DATA_SOURCE = 'C' 
	and ta.created_at >= '2024-04-25' and ta.created_at < '2024-06-21'
	group by 1
	) ta 
on ta.one_id = tmi.CUST_ID 
where ta.one_id is null 
and tmi.is_deleted=0 and tmi.member_status<>60341003
and tmi.is_vehicle = 1
;


-- 6-8-4 参与过24年1月-3月任意一期会员日，本月未在app活跃的用户
select distinct tmi.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select distinct_id
	from ods_rawd.ods_rawd_events_d_di a 
	where 1=1
	and event='Page_entry'
	and page_title in ('1月会员日', '2月会员日', '3月会员日')
	and ((a.activity_name = '2024年1月会员日' and a.date = '2024-01-25')
		or (a.activity_name = '2024年2月会员日' and a.date = '2024-02-25')
		or (a.activity_name = '2024年3月会员日' and a.date = '2024-03-25'))
	and (((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') or (`$lib` in ('MiniProgram') or channel ='Mini'))
	and length(distinct_id)<9
	group by 1
	) t1
on toString(tmi.cust_id) = t1.distinct_id
left join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking gio
	where 1=1
	and toDate(gio.`time`) >= '2024-06-01'
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- APP端
	and length(gio.distinct_id)<9
	group by distinct_id
	) t2 
on t1.distinct_id = t2.distinct_id
where t2.distinct_id is null
and tmi.is_deleted=0 and tmi.member_status<>'60341003'
;


-- 6-10-1 历史浏览EM90文章＞3次
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select member_id, count(*)
	from community.tt_view_post 
	where is_deleted = 0 
	and post_id in (
		'LtaG2DwBA6'
		,'WMsxrwR0N9'
		,'ADgF8VGODS'
		,'j1KA1iwVaF'
		,'yr8uH5TEHf'
		,'m7gjf0rkYf'
		,'SyOaNFpSO3'
		,'wje21Z4VDH'
		,'jcqGgsp4g2'
		,'BeOWlHH4sA'
		,'bfMlHRwVdN'
		,'BfcDq6S8fi'
		,'EJsJj5qXfC'
		,'uawvtZng0L'
		,'SkQl8fCDK6'
		,'ZpOUwR45lc'
		,'rN86aXJayZ'
		,'oBMb27pR2T'
		,'0AO0oEnc4F'
		,'r7KCc7Q94R'
		,'UnqIvxbt45'
		,'Vjgn718QuU'
		,'SJe4iPZx4a'
		,'PPQhUbc4xK'
		,'2rsLKB8ZX7'
		,'RruMWUeaF1'
		,'lGeaDJfEGd'
		,'aYqIteYxTF'
		,'QoQDHBg0qM'
		,'c5Kcf7VJg0'
		,'5waA1XVwbE'
		,'eMaI30IJEW'
		,'scchP8MYxl'
		,'ksstTRU6j2'
		,'WAQpM3kNVy'
		,'n9sZLQHpOC'
		,'2sOeP69Zfw'
		,'weeIgG327J'
		,'lUg3XRy8zG'
		,'ZBuUyH708g'
		,'6QwzNgGckU'
		,'9D63nuDMiQ'
		,'ZKcBFkSwPs'
		,'n94sF6wHCN'
		,'Q76ZHV83P0'
		,'m061ZMh4SV'
		,'XZ6DW4UVpX'
		,'V14of589W9'
		,'duewwa5AqU'
		,'DcOiPB3Dhm'
		,'kf4qEbUIuk'
		,'CIuyBnVgN6'
		,'glwpUhf3Mz'
		,'r2MvuisSAX'
		,'XLeeTqQXhS'
		,'OMM16js2rF'
		,'mC8uzxmBij'
		,'oUKCCzxi2r'
		,'6XA5MdUN9D'
		)
	group by member_id having count(*) > 3
	) tvp 
on tmi.id = tvp.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 7-0-1 过往参加过欧洲杯投票的用户
select distinct tmi.member_phone "手机号"
from campaign.tr_vote_record tvr -- 投票记录表
inner join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvr.is_deleted =0 
and tvr.object_no in (
'0xqgHQ67Fk'
,'SVglseeaP7'
,'x74ye6wsA8'
,'jaqIn0fgCm'
,'6SQPZAE5jz'
,'lO6zU2xbfx'
,'HwAHPrzHuZ'
,'1O8oC6fLUJ'
,'nguY8CtK7s'
,'q66jGxUKjv'
,'SIsXeZxaY2'
,'TgsN5QU1k5'
,'4Nq4LwHT81'
,'kkK8qKnL2G'
,'WKq23QA0Ap'
,'gFe2C4ahlq'
)
;


-- 7-1-1 2024年1-6月，浏览过一键留资弹窗、浮窗，但浏览后无任何留资或者到店及订单记录
select distinct m.member_phone as phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id, min(track_time) first_track_time 
	from (
		select distinct_id, `time` as track_time
		from dwd_23.dwd_23_gio_tracking a
		where 1=1 
		and `date`>='2024-01-01' and `date` < '2024-07-01'
		and event='Page_entry'
		and (page_title like '%留资%' or page_title in ('AR看车_诚挚邀请您预约赏车弹窗','360看车_诚挚邀请您试驾弹窗'))
		and length(distinct_id)<9
		and event_time >='2023-12-01'
		) tt 
	group by distinct_id
	) a 
on toString(m.cust_id) = toString(a.distinct_id)
left join (
	select mobile, max(data_time) as last_data_time
	from (
		select t1.mobile as mobile, toString(t1.create_time) data_time
		from ods_cust.ods_cust_tt_clue_clean_cur t1 
		where t1.is_deleted = 0 and t1.create_time >= '2024-01-01'
		union distinct 
		select mobile_phone as mobile, toString(arrive_date) data_time
		from ods_cypf.ods_cypf_tt_passenger_flow_info_cur 
		where is_deleted = 0 and arrive_date >= '2024-01-01'
		union distinct
		select customer_tel as mobile, toString(created_at) data_time
		from ods_cydr.ods_cydr_tt_sales_orders_cur
		where is_deleted = 0 and created_at >= '2024-01-01'
		) tt 
	group by mobile
	) b 
on m.member_phone = b.mobile
where m.is_deleted = 0 and m.member_status <> '60341003'
and (b.mobile is null or a.first_track_time > b.last_data_time)
;


-- 7-1-2 2024年1-6月，通过一键留资弹窗、浮窗留资但未试驾的用户
select distinct t1.mobile as phone
from ods_cust.ods_cust_tt_clue_clean_cur t1 
left join ods_actv.ods_actv_cms_active_d t2 on t1.campaign_id = t2.uid 
inner join (
	select distinct replace(code, ' ', '') code
	from ods_oper_crm.ods_oper_crm_umt001_em90_his_d
	where channel = '一键留资'
	) t3
on t2.active_code = t3.code
left join (
	select MOBILE as mobile, max(DRIVE_S_AT) last_drive_time
	from ods_drse.ods_drse_tt_testdrive_plan_d
	where IS_DELETED = 0 and DRIVE_S_AT >= '2024-01-01'
	group by MOBILE
	) t4
on toString(t1.mobile) = toString(t4.mobile)
where t1.is_deleted = 0
and t1.create_time >= '2024-01-01' and t1.create_time < '2024-07-01'
and (t4.mobile is null or toString(t1.create_time) > toString(t4.last_drive_time))
;

-- 7-2-1 过往参加过欧洲杯投票的用户
select distinct tmi.member_phone "手机号"
from campaign.tr_vote_record tvr -- 投票记录表
inner join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvr.is_deleted =0 
and tvr.object_no in (
	'5Y860ekcUl'
	,'hUcbOkJeJZ'
	,'vrwDj4ST0Q'
	,'mmsf8HJOU2'
	,'0xqgHQ67Fk'
	,'SVglseeaP7'
	,'x74ye6wsA8'
	,'jaqIn0fgCm'
	,'6SQPZAE5jz'
	,'lO6zU2xbfx'
	,'HwAHPrzHuZ'
	,'1O8oC6fLUJ'
	,'nguY8CtK7s'
	,'q66jGxUKjv'
	,'SIsXeZxaY2'
	,'TgsN5QU1k5'
	,'4Nq4LwHT81'
	,'kkK8qKnL2G'
	,'WKq23QA0Ap'
	,'gFe2C4ahlq'
	)
;


-- 7-3-1 历史浏览EM90文章＞3次
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select member_id, count(*)
	from community.tt_view_post 
	where is_deleted = 0 
	and post_id in (
		'LtaG2DwBA6'
		,'WMsxrwR0N9'
		,'ADgF8VGODS'
		,'j1KA1iwVaF'
		,'yr8uH5TEHf'
		,'m7gjf0rkYf'
		,'SyOaNFpSO3'
		,'wje21Z4VDH'
		,'jcqGgsp4g2'
		,'BeOWlHH4sA'
		,'bfMlHRwVdN'
		,'BfcDq6S8fi'
		,'EJsJj5qXfC'
		,'uawvtZng0L'
		,'SkQl8fCDK6'
		,'ZpOUwR45lc'
		,'rN86aXJayZ'
		,'oBMb27pR2T'
		,'0AO0oEnc4F'
		,'r7KCc7Q94R'
		,'UnqIvxbt45'
		,'Vjgn718QuU'
		,'SJe4iPZx4a'
		,'PPQhUbc4xK'
		,'2rsLKB8ZX7'
		,'RruMWUeaF1'
		,'lGeaDJfEGd'
		,'aYqIteYxTF'
		,'QoQDHBg0qM'
		,'c5Kcf7VJg0'
		,'5waA1XVwbE'
		,'eMaI30IJEW'
		,'scchP8MYxl'
		,'ksstTRU6j2'
		,'WAQpM3kNVy'
		,'n9sZLQHpOC'
		,'2sOeP69Zfw'
		,'weeIgG327J'
		,'lUg3XRy8zG'
		,'ZBuUyH708g'
		,'6QwzNgGckU'
		,'9D63nuDMiQ'
		,'ZKcBFkSwPs'
		,'n94sF6wHCN'
		,'Q76ZHV83P0'
		,'m061ZMh4SV'
		,'XZ6DW4UVpX'
		,'V14of589W9'
		,'duewwa5AqU'
		,'DcOiPB3Dhm'
		,'kf4qEbUIuk'
		,'CIuyBnVgN6'
		,'glwpUhf3Mz'
		,'r2MvuisSAX'
		,'XLeeTqQXhS'
		,'OMM16js2rF'
		,'mC8uzxmBij'
		,'oUKCCzxi2r'
		,'6XA5MdUN9D'
		,'m1sX4J98o4'
		,'G7slZ4uLgK'
		,'T1KQ3xyL8k'
		,'UUe0MPu1Os'
		)
	group by member_id having count(*) > 3
	) tvp 
on tmi.id = tvp.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;



-- 7-6-1 过往参加过欧洲杯投票的用户
select distinct tmi.member_phone "手机号"
from campaign.tr_vote_record tvr -- 投票记录表
inner join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvr.is_deleted =0 
and tvr.object_no in (
    'oEgRiN6HH3'
    ,'8HOGnghQFb'
    ,'vw4EJG5Vzo'
    ,'KzumZC6D2q'
    ,'dTqMBh3m62'
    ,'gDgfrlihiy'
    ,'5Y860ekcUl'
    ,'hUcbOkJeJZ'
    ,'vrwDj4ST0Q'
    ,'mmsf8HJOU2'
    ,'0xqgHQ67Fk'
    ,'SVglseeaP7'
    ,'x74ye6wsA8'
    ,'jaqIn0fgCm'
    ,'6SQPZAE5jz'
    ,'lO6zU2xbfx'
    ,'HwAHPrzHuZ'
    ,'1O8oC6fLUJ'
    ,'nguY8CtK7s'
    ,'q66jGxUKjv'
    ,'SIsXeZxaY2'
    ,'TgsN5QU1k5'
    ,'4Nq4LwHT81'
    ,'kkK8qKnL2G'
    ,'WKq23QA0Ap'
    ,'gFe2C4ahlq'
	)
;


-- 7-2-1 24年至今推荐购活动发起过邀请，但最终邀请好友未成功购车的用户
select distinct ti.invite_mobile "推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
and create_time >= '2024-01-01'
;

-- 7-2-2 23-24年成功推荐3次及以上的车主(成功推荐3次及以上，被推荐人不一定要购车)
select ti.invite_mobile "推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and create_time >= '2023-01-01'
group by 1
having count(*) >= 3
;

-- 7-2-3 6月+7月推荐购已下订未开票用户
select distinct ti.be_invite_mobile "被推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-06-01'
;

-- 7-2-4 6月+7月推荐购已下订未开票用户及其对应推荐人
select distinct ti.invite_mobile "推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-06-01'
;


-- 7-7-1 半年内参与过任一话题发帖的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time + '6 month' >= '2024-07-12'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 7-5-1 6月会员日已集齐5张卡或者6张卡，但6月会员日活动当天未成功兑换毛绒麋鹿挂件奖励的用户
select distinct tmi.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select cr.member_id, count(distinct cr.activity_card_id) card_cnt 
	from ods_voam.ods_voam_activity_card_record_d cr
	left join ods_voam.ods_voam_activity_card_d c on cr.activity_card_code=c.activity_card_code 
	where cr.is_deleted = 0
	and cr.create_time < '2024-06-26' -- 全部24年数据
	group by cr.member_id 
	having count(distinct cr.activity_card_id) >= 5
	) tr 
left join (
	-- 筛选已成功兑换奖励用户，并剔除
	) t2 
on toString(tmi.id) = toString(tr.member_id) 
where tmi.is_deleted=0 and tmi.member_status<>'60341003'
order by card_cnt desc
;

-- 7-5-2 2024年1月至6月累计参与过2次及以上会员日活动（包含525车主节）的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id, count(distinct page_title) act_cnt
	from dwd_23.dwd_23_gio_tracking a 
	where 1=1
	and a.event='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (page_title like '%会员日' OR page_title = '525车主节')
	and length(distinct_id)<9
	and event_time >='2023-12-01'
	and a.date>='2024-01-01' and a.date < '2024-07-01'
	group by distinct_id
	having count(distinct page_title) >= 2
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 7-5-3 24年Q1完成过推荐购(推荐购关系成立)，Q2还未发起过邀请的车主用户
select ti.invite_mobile
from invite.tm_invite_record ti
where is_deleted = 0 
and create_time >= '2024-01-01'
group by 1
having max(create_time) < '2024-04-01'
;

-- 7-10-1 全渠道留资EX30留资，且留资后没有到店，且没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EX30的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EX30'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、客流表到店(最晚)  1.1之后的到店
	select f.mobile_phone phone
		,max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	order by 2
	) b on a.mobile = b.phone
left join (
	-- 3、订单手机号（最晚）
	select DISTINCT o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
			tso.so_no so_no,
			tso.customer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
			tso.so_no so_no,
			tso.purchase_phone phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
			tso.so_no so_no,
			tso.drawer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
) c on a.mobile = c.phone
where 1=1
and ((a.create_time >= b.arrive_date or b.phone is null)     -- 留资前就已经有过到店，或者留资后就没有到过店
and (a.create_time >= c.created_at or c.phone is null))     -- 并且没有订单
;

-- 7-10-2 全渠道留资EX30留资，且留资后没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EX30的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EX30'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、订单手机号（最晚）
	select DISTINCT o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
		tso.so_no so_no,
		tso.customer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
		tso.so_no so_no,
		tso.purchase_phone phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
		tso.so_no so_no,
		tso.drawer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
	) b on a.mobile = b.phone
where 1=1
and (a.create_time >= b.created_at or b.phone is null)     -- 留资时间比订单时间晚，或者留资后没有订单
;

-- 7-8-1 24年7月1日-24年7月20日，访问过APP社区首页但未浏览商城消暑季的用户
select distinct b.member_phone
from ods_gio.ods_gio_event_d a
left join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b on a.user = b.cust_id::varchar
where 1=1 and length(a.`user`) < 9
and date(a.event_time) >= date('2024-07-01') and date(a.event_time) < date('2024-07-21') + INTERVAL 1 MONTH
and a.client_time >= '2024-07-01'  and a.client_time < '2024-07-21'
and ((a.`$platform` in ('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App') -- App
and (
	-- 社区浏览人数
	(a.event_key in ('Page_view','Page_entry')
		and (a.var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
			or a.var_page_title like '%会员日%' 
			or (a.var_activity_name like '2023%' and a.var_activity_id is null) 
			or (a.var_activity_name like '2024%' and a.var_activity_id is null)) )
    -- 社区互动人数
    or (a.event_key='Button_click' 
		and var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
    	and var_btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送',
			'朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') )
    -- 发现 按钮点击（车主）7月开始
    or ((a.event_key='Button_click' and a.var_btn_name='发现' )
    or (a.event_key='sa_AppClick' and a.var_sa_element_content='发现' ))
	)
and a.user not in (
	-- 商城消暑季活动主页
	select distinct a.distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')   -- APP
	and a.event = 'Page_entry'
	and a.page_title ='内容详情'
	and a.content_title = '夏日消暑季，一键觅清凉'
	and length(a.distinct_id) < 9
	and a.distinct_id = '27744487'
	)
;


-- 7-8-2 浏览消暑季页面未下单用户+获得优惠券且未核销用户(注意不要包含1里的人)

-- 1、浏览商城消暑季活动主页
select
distinct b.member_phone
from dwd_23.dwd_23_gio_tracking a
left join
(
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
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
) b on a.user = b.cust_id::varchar
where 1=1
and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App')   -- APP
and date(a.event_time) >= '2024-07-06' and date(a.event_time) < '2024-07-23'
and `date` >= '2024-07-06' and `date` < '2024-07-23'
and a.event = 'Page_entry'
and a.page_title ='内容详情'
and a.content_title = '夏日消暑季，一键觅清凉'
and length(a.distinct_id) < 9
and distinct_id not in
(
	-- 2、商城下单
	select
	distinct m.cust_id
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_memb.ods_memb_tc_member_info_cur m on a.user_id::varchar = m.id::varchar and m.member_status <> '60341003' and m.is_deleted = '0'
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id    -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d d on d.id = c.front_category1_id     -- 前台专区列表(获取前台专区名称)
	left join ods_good.ods_good_item_sku_d e on e.id = b.sku_id      -- 前台sku表(获取商品DN价)
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
	left join
	(
		-- 退单明细
		select
		so.refund_order_code,
		so.order_code,
		sp.product_id,
		case when so.status = '51171001' then  '待审核' 
			when so.status = '51171002' then  '待退货入库' 
			when so.status = '51171003' then  '待退款' 
			when so.status = '51171004' then  '退款成功' 
			when so.status = '51171005' then  '退款失败' 
			when so.status = '51171006' then  '作废退货单'
			else null end `退货状态`,
		sum(sp.sales_return_num) `退货数量`,
		sum(so.refund_point) `退回V值`,
		max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1
		and so.status = '51171004'     -- 退款成功
		and so.is_deleted = '0'
		and sp.is_deleted = '0'
		GROUP BY 1,2,3,4
	) h on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-07-06' and a.create_time < '2024-07-23'
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
)


-- 获得优惠券并且截止到现在未核销的用户
select
a.id,
b.id `卡券ID`,
b.coupon_name `卡券名称`,
a.left_value/100 `面额(元)`,
b.coupon_code `券号`,
a.member_id `会员ID`,
m.cust_id,
m.member_phone,
a.vin `购买VIN`,
a.get_date `获得时间`,
a.activate_date `激活时间`,
a.expiration_date `卡券失效日期`,
CAST(a.exchange_code as varchar) `核销码`,
case when a.coupon_source = '83241001' then 'VCDC发券'
	when a.coupon_source = '83241002' then '沃世界领券'
	when a.coupon_source = '83241003' then '商城购买'
	else null end `卡券来源`,
case when a.ticket_state = '31061001' then '已领用'
	when a.ticket_state = '31061002' then '已锁定'
	when a.ticket_state = '31061003' then '已核销'
	when a.ticket_state = '31061004' then '已失效'
	when a.ticket_state = '31061005' then '已作废'
	else null end `卡券状态`,
v.`coupon_detail_id` `coupon_detail_id`,
if(v.`核销时间` > '1970-01-01 08:00:00',v.`核销时间`,null) `核销时间`,
v.`核销用户名` `核销用户名`,
v.`核销手机号` `核销手机号`,
v.`核销金额` `核销金额`,
v.`核销经销商` `核销经销商`,
v.`核销VIN` `核销VIN`,
v.PLATE_NUMBER `PLATE_NUMBER`,
a.order_code `领用订单号`,
v.`核销订单号` `核销订单号`
from ods_coup.ods_coup_tt_coupon_detail_d a
join ods_coup.ods_coup_tt_coupon_info_d b on a.coupon_id = b.id
left join ods_memb.ods_memb_tc_member_info_cur m on a.member_id::varchar = m.id::varchar and m.member_status <> '60341003' and m.is_deleted = '0'
left join
(
	-- 卡券核销明细
	select
	v.coupon_detail_id `coupon_detail_id`,
	v.customer_name `核销用户名`,
	v.customer_mobile `核销手机号`,
	v.verify_amount `核销金额`,
	IFNULL(v.dealer_code,v.dealer) `核销经销商`,
	v.vin `核销VIN`,
	v.operate_date `核销时间`,
	v.order_no `核销订单号`,
	v.PLATE_NUMBER `PLATE_NUMBER`
	from ods_coup.ods_coup_tt_coupon_verify_d v
	where 1=1
	and v.is_deleted = 0
	order by v.create_time
) v on a.id = v.coupon_detail_id
where 1=1
and b.id in ('7122','7123')   -- 活动卡券
and a.get_date >= '2024-07-06' and a.get_date < '2024-07-23'   -- 领用时间在活动期间
and a.ticket_state = '31061001'   -- 卡券状态：已领用
and a.is_deleted = 0
order by a.get_date








-- 7-5-1 6月会员日已集齐5张卡或者6张卡，但6月会员日活动当天未成功兑换毛绒麋鹿挂件奖励的用户
select
*
-- distinct tmi.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	-- 筛选24年截止到现在，集卡累计大于等于5次的用户
	select
	cr.member_id,
	count(distinct cr.activity_card_id) card_cnt 
	from ods_voam.ods_voam_activity_card_record_d cr
	left join ods_voam.ods_voam_activity_card_d c on cr.activity_card_code = c.activity_card_code 
	where cr.is_deleted = 0
	and cr.create_time < '2024-06-26' -- 全部24年数据
	group by cr.member_id
	having count(distinct cr.activity_card_id) >= 5
	) tr on toString(tmi.id) = toString(tr.member_id) 
left join (
	-- 筛选已成功兑换奖励用户，并剔除
	-- 24年会员日兑换过商品的会员明细
	select DISTINCT a.member_id member_id
	from ods_camp.ods_camp_tr_activity_winner_d a 
	left join ods_camp.ods_camp_tm_prize_d b on a.prize_id = b.prize_id and b.is_deleted = 0
	left join ods_camp.ods_camp_tm_prize_activity_d c on a.activity_id = c.activity_id and c.is_deleted = 0
	where 1=1
	and c.activity_state = 1
	and a.is_enable = 1
	and a.is_deleted = 0
	and c.activity_name = '2024会员日集卡兑好礼活动奖励'    -- 会员日兑换过商品的人
	) t2 on toString(tr.member_id) = toString(t2.member_id)
where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
--and t2.member_id is null
and t2.member_id = ''
order by card_cnt desc
;


-- 7-5-2 2024年1月至6月累计参与过2次及以上会员日活动（包含525车主节）的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id, count(distinct page_title) act_cnt
	from dwd_23.dwd_23_gio_tracking a 
	where 1=1
	and a.event='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (page_title like '%会员日' OR page_title = '525车主节')
	and length(distinct_id)<9
	and event_time >='2023-12-01'
	and a.date>='2024-01-01' and a.date < '2024-07-01'
	group by distinct_id
	having count(distinct page_title) >= 2
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003';
;

-- 7-5-3 24年Q1完成过推荐购(推荐购关系成立)，Q2还未发起过邀请的车主用户
select ti.invite_mobile
from invite.tm_invite_record ti
where is_deleted = 0 
and create_time >= '2024-01-01'
group by 1
having max(create_time) < '2024-04-01'
;


select count(1) from "member".tc_member_info tmi
where tmi.is_vehicle = 1

-- 1、养修预约
select
distinct ta.CUSTOMER_PHONE
--CAST(tam.MAINTAIN_ID as VARCHAR) 养修预约ID,
--ta.APPOINTMENT_ID 预约ID,
--ta.OWNER_CODE 经销商代码,
--tc2.COMPANY_NAME_CN 经销商名称,
--ta.ONE_ID 车主oneid,
--ta.CUSTOMER_NAME 联系人姓名,
--ta.CUSTOMER_PHONE 联系人手机号,
--tam.CAR_MODEL 预约车型,
--tam.CAR_STYLE 预约车款,
--tam.VIN 车架号,
--case when tam.IS_TAKE_CAR = 10041001 then '是'
--	when tam.IS_TAKE_CAR = 10041002 then '否' 
--	end  是否取车,
--case when tam.IS_GIVE_CAR = 10041001 then '是'
--	when tam.IS_GIVE_CAR = 10041002 then '否'
--    end 是否送车,
--tc.CODE_CN_DESC 养修状态,
--tam.CREATED_AT 创建时间,
--tam.UPDATED_AT 修改时间,
--ta.CREATED_AT 预约时间,
--tam.WORK_ORDER_NUMBER 工单号
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
where ta.CREATED_AT >= '2023-01-01'   -- 时间
and ta.CREATED_AT < '2024-01-01'
and ta.DATA_SOURCE = 'C'
and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
-- and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效，即实际到店
and ta.CUSTOMER_PHONE not in (
	-- 1、养修预约
	select distinct ta.CUSTOMER_PHONE 联系人手机号
	from cyx_appointment.tt_appointment  ta
	left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
	left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
	left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	where ta.CREATED_AT >= '2024-01-01'   -- 时间
	and ta.CREATED_AT < '2024-07-22'
	and ta.DATA_SOURCE = 'C'
	and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
	-- and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效，即实际到店
	)
;






-- 7-12-1 2024年至今浏览过推荐购页面的车主
select distinct member_phone 
from (
	select distinct b.member_phone
	from ods_rawd.ods_rawd_events_d_di a
	left join (
		-- 清洗会员表
		select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
		from (
			select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
				,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where  m.member_status <> '60341003'
			and m.cust_id is not null
			and m.is_deleted =0 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1
		) b on a.distinct_id = b.cust_id::varchar
	where 1=1
	and a.`date` >= '2024-01-01'
	and a.`date` < '2024-05-01'
	and ((`$lib` in('iOS','Android') and left($app_version,1)='5') or `$lib` ='MiniProgram' or  channel in ('Mini', 'App') )   -- 双端
	and event='Page_entry'
	and page_title='推荐购_邀请好友'
	and a.is_bind = '1'   -- 车主
	and length(a.distinct_id) < 9
	and length(b.member_phone) = '11'
	and left(b.member_phone,1) = '1'
	union all
	select distinct b.member_phone
	from dwd_23.dwd_23_gio_tracking a
	left join (
		-- 清洗会员表
		select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
		from (
			select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
				,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where  m.member_status <> '60341003'
			and m.cust_id is not null
			and m.is_deleted =0 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1
		) b on a.distinct_id = b.cust_id::varchar
	where 1=1
	and `date` >= '2024-05-01' and `date` < '2024-07-24'
	and ((event='$page' and `$lib`='HarmonyOS' and left(`$client_version`,1)='5' and `$path` like '%InviteBuyNewView%')
		OR (event='$AppViewScreen' and `$lib`='Android' and left(`$client_version`,1)='5' and `$path` like '%InviteBuyNewView%')
		OR (event='$AppViewScreen' and `$lib`='iOS' and left(`$client_version`,1)='5' and `$path`like '%Volvo_Cars.InviteFriendsViewController%')
		or (`$lib`='MiniProgram' and event='$MPViewScreen' and `$path`='src/pages/market-package/recommend-buy/index'))
	and a.var_is_bind in ('1','true') -- 车主
	and length(a.distinct_id) < 9
	and length(b.member_phone) = '11'
	and left(b.member_phone,1) = '1'
)


-- 7-13-1 近半年上门取送车服务的车主用户


-- 7-13-2 近半年使用尊享代步车服务的车主用户

-- 7-14-1 过往参加过欧洲杯投票的用户
select distinct tmi.member_phone "手机号"
from campaign.tr_vote_record tvr -- 投票记录表
inner join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvr.is_deleted =0 
and tvr.object_no in (
    'oEgRiN6HH3'
    ,'8HOGnghQFb'
    ,'vw4EJG5Vzo'
    ,'KzumZC6D2q'
    ,'dTqMBh3m62'
    ,'gDgfrlihiy'
    ,'5Y860ekcUl'
    ,'hUcbOkJeJZ'
    ,'vrwDj4ST0Q'
    ,'mmsf8HJOU2'
    ,'0xqgHQ67Fk'
    ,'SVglseeaP7'
    ,'x74ye6wsA8'
    ,'jaqIn0fgCm'
    ,'6SQPZAE5jz'
    ,'lO6zU2xbfx'
    ,'HwAHPrzHuZ'
    ,'1O8oC6fLUJ'
    ,'nguY8CtK7s'
    ,'q66jGxUKjv'
    ,'SIsXeZxaY2'
    ,'TgsN5QU1k5'
    ,'4Nq4LwHT81'
    ,'kkK8qKnL2G'
    ,'WKq23QA0Ap'
    ,'gFe2C4ahlq'
	)
;

-- 7-15-1 【7月车主动态征集】：24年7月访问过APP社区首页，但没有参与过#用车小百科#话题的车主
select distinct b.member_phone
from (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 and m.is_vehicle = 1
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b
inner join (
	select user 
	from ods_gio.ods_gio_event_d a
	where length(a.`user`) < 9
	and date(a.event_time) >= date('2024-05-01')
	and a.client_time >= '2024-07-01'  and a.client_time < '2024-07-26'
	and ((a.`$platform` in ('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App') -- App
	and (
		-- 社区浏览人数
		(a.event_key in ('Page_view','Page_entry')
			and (a.var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') 
				or a.var_page_title like '%会员日%' 
				or (a.var_activity_name like '2023%' and a.var_activity_id is null) 
				or (a.var_activity_name like '2024%' and a.var_activity_id is null)) )
	    -- 社区互动人数
	    or (a.event_key='Button_click' 
			and var_page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	    	and var_btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送',
				'朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') )
	    -- 发现 按钮点击（车主）7月开始
	    or ((a.event_key='Button_click' and a.var_btn_name='发现' )
	    	or (a.event_key='sa_AppClick' and a.var_sa_element_content='发现' ))
		)
	) a on a.user = b.cust_id::varchar
left join (
	select distinct tp.member_id as member_id
	from ods_cmnt.ods_cmnt_tm_post_cur tp
	inner join ods_cmnt.ods_cmnt_tr_topic_post_link_cur tpl on tp.post_id = tpl.post_id
	and tp.create_time >= '2024-07-01' and tpl.topic_id = 'KQQ1iGPP9R'
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	) c on b.id = c.member_id
where 1=1 
and c.member_id is null 
;


-- 7-15-2【7月车主动态征集】：24年1月至今，参与过#用车小百科#话题，但24年6月至今未发帖的车主
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select tp.member_id
	from community.tm_post tp
	inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
	and tp.create_time >= '2024-01-01' and tpl.topic_id = 'KQQ1iGPP9R'
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	group by 1
	) t1 
on tmi.id = t1.member_id
left join community.tm_post t2 on tmi.id = t2.member_id and t2.create_time >= '2024-06-01'
where t2.member_id is null 
and tmi.is_vehicle = 1
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 7-17-1【雨刮异响与油膜】：23年7-12月在线预约过养修，24年1月至7月没有在线预约养修的车主用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select ta.CUSTOMER_PHONE, max(ta.CREATED_AT) last_appointment
	from cyx_appointment.tt_appointment  ta
	left join cyx_appointment.tt_appointment_maintain tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
	left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
	left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	where ta.CREATED_AT >= '2023-07-01'   -- 时间
	and ta.DATA_SOURCE = 'C'
	and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
	-- and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效，即实际到店
	group by 1
	having max(ta.CREATED_AT) < '2024-01-01'
	) tt 
on tmi.member_phone = tt.CUSTOMER_PHONE
where tmi.is_vehicle = 1
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 8-0-1 过往参加过欧洲杯投票的用户
select distinct tmi.member_phone "手机号"
from campaign.tr_vote_record tvr -- 投票记录表
inner join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvr.is_deleted =0 
and tvr.object_no in (
    'oEgRiN6HH3'
    ,'8HOGnghQFb'
    ,'vw4EJG5Vzo'
    ,'KzumZC6D2q'
    ,'dTqMBh3m62'
    ,'gDgfrlihiy'
    ,'5Y860ekcUl'
    ,'hUcbOkJeJZ'
    ,'vrwDj4ST0Q'
    ,'mmsf8HJOU2'
    ,'0xqgHQ67Fk'
    ,'SVglseeaP7'
    ,'x74ye6wsA8'
    ,'jaqIn0fgCm'
    ,'6SQPZAE5jz'
    ,'lO6zU2xbfx'
    ,'HwAHPrzHuZ'
    ,'1O8oC6fLUJ'
    ,'nguY8CtK7s'
    ,'q66jGxUKjv'
    ,'SIsXeZxaY2'
    ,'TgsN5QU1k5'
    ,'4Nq4LwHT81'
    ,'kkK8qKnL2G'
    ,'WKq23QA0Ap'
    ,'gFe2C4ahlq'
	)
;


-- 8-0-2 浏览过奥运会历史文章/帖子的用户
select distinct tmi.member_phone "手机号"
from community.tt_view_post tvp 
inner join `member`.tc_member_info tmi on tmi.id =tvp.member_id
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvp.is_deleted = 0
and tvp.post_id in ('91Ajjh4hkE','iQwL9wUR4Y','asc9gdLoPo','qfcXEtjFS4','onwhcYzdOb')
;


-- 8-0-3 参与过#运动一下更快乐#话题发帖用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select tp.member_id
	from community.tm_post tp
	inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
	and tpl.topic_id = 'onwhcYzdOb'
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	group by 1
	) tt
on tmi.id = tt.member_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 8-1-1 23年8月-24年2.1在线预约过养修，24年2.2月至8月没有在线预约养修的车主
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select ta.CUSTOMER_PHONE, max(ta.CREATED_AT) last_appointment
	from cyx_appointment.tt_appointment  ta
	left join cyx_appointment.tt_appointment_maintain tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
	left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
	left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	where ta.CREATED_AT >= '2023-08-01'   -- 时间
	and ta.DATA_SOURCE = 'C'
	and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
	-- and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')    -- 筛选预约状态为：有效，即实际到店
	group by 1
	having max(ta.CREATED_AT) < '2024-02-02'
	) tt 
on tmi.member_phone = tt.CUSTOMER_PHONE
where tmi.is_vehicle = 1
and tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 8-2-2 浏览过奥运会历史文章/帖子的用户
select distinct tmi.member_phone "手机号"
from community.tt_view_post tvp 
inner join `member`.tc_member_info tmi on tmi.id =tvp.member_id
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
where tvp.is_deleted = 0
and tvp.post_id in ('Cz8s25KUWj','g8wVmSehtu','91Ajjh4hkE','iQwL9wUR4Y','asc9gdLoPo','qfcXEtjFS4','onwhcYzdOb')
;


-- 8-2-3 参与过#在一起就是主场#话题发帖用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select tp.member_id
	from community.tm_post tp
	inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
	and tpl.topic_id = 'nNuogeZng1'
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	group by 1
	) tt
on tmi.id = tt.member_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 8-2-4 参与过#运动一下更快乐#话题发帖用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select tp.member_id
	from community.tm_post tp
	inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
	and tpl.topic_id = 'onwhcYzdOb'
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	group by 1
	) tt
on tmi.id = tt.member_id
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 8-3-1 5-8月的新注册粉丝 且30天内无预约或试驾记录
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
left join (
 	select ta.CUSTOMER_PHONE as mobile
 	from ods_cyap.ods_cyap_tt_appointment_d  ta
 	where ta.CREATED_AT >= '2024-07-05'   -- 时间
 	and ta.DATA_SOURCE = 'C'
 	and ta.APPOINTMENT_TYPE = '70691002'   -- 预约试乘试驾
 	union distinct 
 	select MOBILE as mobile
 	from ods_drse.ods_drse_tt_testdrive_plan_d tp
 	where IS_DELETED = 0 and DRIVE_STATUS = 20211003
 	and DRIVE_S_AT >= '2024-07-05'
 	) t2 
on m.member_phone = t2.mobile 
where t2.mobile is null
and m.member_time >= '2024-05-01'
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 8-3-2 2024年浏览过试驾享好礼、预约试驾页面的用户
select distinct b.member_phone
from (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key = 'Page_entry'
	and var_page_title in ('试驾享好礼', '预约试驾页')
	) a 
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.is_deleted =0 and m.member_status <> '60341003'
		and m.cust_id is not null
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
;
	
-- 8-3-3 2023-2024年兑换过东航积分卡券、雅高出行权益的用户
select distinct tmi.member_phone
from member_rights.tt_member_get_record gr
inner join member_rights.tc_member_rights_config config on gr.rights_config_id= config.id
inner join member_rights.tm_member_rights rights on config.rights_id= rights.id
and rights.id in (63,50,20,64,52,19,65,51,18,17,61,48,27,62,49,28)  -- 需调整
inner join member.tc_member_info tmi on gr.member_id  = tmi.id 
and tmi.member_status <> 60341003 and tmi.is_deleted = 0
where gr.is_deleted = 0 
and gr.create_time >= '2023-01-01'
;


-- 8-16-1 全渠道留资EM90留资，且留资后没有到店，且没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EM90的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、客流表到店(最晚)  1.1之后的到店
	select f.mobile_phone phone
		,max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	order by 2
	) b on a.mobile = b.phone
left join (
	-- 3、订单手机号（最晚）
	select o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
			tso.so_no so_no,
			tso.customer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
			tso.so_no so_no,
			tso.purchase_phone phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
			tso.so_no so_no,
			tso.drawer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
) c on a.mobile = c.phone
where 1=1
and ((a.create_time >= b.arrive_date or b.phone is null)     -- 留资前就已经有过到店，或者留资后就没有到过店
and (a.create_time >= c.created_at or c.phone is null))     -- 并且没有订单
;

-- 8-16-2 全渠道留资EM90留资，且留资后没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EM90的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、订单手机号（最晚）
	select o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
		tso.so_no so_no,
		tso.customer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
		tso.so_no so_no,
		tso.purchase_phone phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
		tso.so_no so_no,
		tso.drawer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
	) b on a.mobile = b.phone
where 1=1
and (a.create_time >= b.created_at or b.phone is null)     -- 留资时间比订单时间晚，或者留资后没有订单
;


-- 8-19-1 2024年至今浏览过推荐购页面两次及以上的用户（粉丝+车主）
select distinct member_phone 
from (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) m 
inner join (
	select user as distinct_id, count(distinct dt)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key = 'Page_entry'
	and var_page_title = '推荐购_邀请好友'
	group by user having count(distinct dt) >= 2
	) d 
on d.distinct_id = m.cust_id::varchar
;


-- 8-17-1 历史浏览过EM90相关文章≥3次的人
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select member_id, count(*)
	from community.tt_view_post 
	where is_deleted = 0 
	and post_id in (
		'LtaG2DwBA6'
		,'WMsxrwR0N9'
		,'ADgF8VGODS'
		,'j1KA1iwVaF'
		,'yr8uH5TEHf'
		,'m7gjf0rkYf'
		,'SyOaNFpSO3'
		,'wje21Z4VDH'
		,'jcqGgsp4g2'
		,'BeOWlHH4sA'
		,'bfMlHRwVdN'
		,'BfcDq6S8fi'
		,'EJsJj5qXfC'
		,'uawvtZng0L'
		,'SkQl8fCDK6'
		,'ZpOUwR45lc'
		,'rN86aXJayZ'
		,'oBMb27pR2T'
		,'0AO0oEnc4F'
		,'r7KCc7Q94R'
		,'UnqIvxbt45'
		,'Vjgn718QuU'
		,'SJe4iPZx4a'
		,'PPQhUbc4xK'
		,'2rsLKB8ZX7'
		,'RruMWUeaF1'
		,'lGeaDJfEGd'
		,'aYqIteYxTF'
		,'QoQDHBg0qM'
		,'c5Kcf7VJg0'
		,'5waA1XVwbE'
		,'eMaI30IJEW'
		,'scchP8MYxl'
		,'ksstTRU6j2'
		,'WAQpM3kNVy'
		,'n9sZLQHpOC'
		,'2sOeP69Zfw'
		,'weeIgG327J'
		,'lUg3XRy8zG'
		,'ZBuUyH708g'
		,'6QwzNgGckU'
		,'9D63nuDMiQ'
		,'ZKcBFkSwPs'
		,'n94sF6wHCN'
		,'Q76ZHV83P0'
		,'m061ZMh4SV'
		,'XZ6DW4UVpX'
		,'V14of589W9'
		,'duewwa5AqU'
		,'DcOiPB3Dhm'
		,'kf4qEbUIuk'
		,'CIuyBnVgN6'
		,'glwpUhf3Mz'
		,'r2MvuisSAX'
		,'XLeeTqQXhS'
		,'OMM16js2rF'
		,'mC8uzxmBij'
		,'oUKCCzxi2r'
		,'6XA5MdUN9D'
		,'m1sX4J98o4'
		,'G7slZ4uLgK'
		,'T1KQ3xyL8k'
		,'UUe0MPu1Os'
		)
	group by member_id having count(*) >= 3
	) tvp 
on tmi.id = tvp.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 8-11-1 近两月在车展留资的粉丝人群
select m.member_phone
from member.tc_member_info m 
inner join (
	select mobile
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0 and c.active_name like '%车展%'
	and create_time >= '2024-06-12'
	group by 1
	) c 
on m.member_phone = c.mobile 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.is_vehicle = 0
;

-- 8-11-2 接受过好友邀请，但截至目前仍未购车的用户
select distinct ti.be_invite_mobile "被推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
-- and create_time >= '2024-01-01'
;


-- 8-11-3 近3-6个月有商城购买的粉丝
select distinct t1.member_phone "手机号"
from `member`.tc_member_info t1
inner join (
	select a.user_id as member_id
	from `order`.tt_order a    -- 订单表
	left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-02-12'
	and a.create_time < '2024-06-12'   -- 订单时间
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and h.order_code is null  -- 剔除退款订单
	group by 1
	) t2
on t1.id = t2.member_id
where t1.is_deleted = 0 and t1.member_status <> 60341003
and t1.is_vehicle = 0
;

-- 8-11-4 参与过525线上活动的粉丝
select DISTINCT b.member_phone as member_phone
from (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and event = 'Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and var_activity_name = '2024年5月525车主节'
	and toDate(`time`) >=  '2024-05-15' and toDate(`time`) < '2024-06-01'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	) a
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
where b.is_vehicle = 0
;

-- 8-11-5 金卡和白金卡有过留资行为的粉丝
select m.member_phone 
from member.tc_member_info m 
inner join (
	select mobile
	from customer.tt_clue_clean a 
	where a.is_deleted = 0
	-- and create_time >= '2024-01-01'
	group by 1
	) c 
on m.member_phone = c.mobile 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.is_vehicle = 0
and m.member_level in (2, 3)
;

-- 8-4-1 2023-2024年参与过试驾享好礼抽奖的车主
select distinct tmi.member_phone "手机号"
from volvo_online_activity_module.lottery_draw_log a
inner join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
inner join volvo_online_activity_module.lottery_play_init c on b.lottery_play_code = c.lottery_play_code and c.lottery_play_name like '%试驾%'
inner join "member".tc_member_info tmi on a.member_id = tmi.id and tmi.is_vehicle = 1
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and a.create_time >= '2023-01-01'
;

-- 8-4-2 2023-2024年至今白金卡、黑卡完成推荐享好礼任务的车主
select distinct m.member_phone "手机号"
from invite.tm_invite_record ti
inner join member.tc_member_info m on ti.invite_member_id = m.id 
and ti.is_deleted = 0 and ti.create_time >= '2023-01-01'
where m.is_deleted = 0 and m.member_status <> 60341003
and m.level_id >= 3
and m.is_vehicle = 1
;

-- 8-4-3 2024年至今商城累计下单超过1000元的车主
select distinct t1.member_phone "手机号"
from member.tc_member_info t1
inner join (
	select member_id, sum(amount)
	from (
		select a.order_code    -- `订单号`,
			,a.user_id as member_id         -- `下单人会员ID`,
			,round(b.point_amount/3+b.pay_fee/100,2) amount  -- 实付金额
		from `order`.tt_order a    -- 订单表
		left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
		left join (
			-- 退单明细
			select so.refund_order_code, so.order_code, sp.product_id,
				case when so.status = '51171001' then  '待审核' 
					when so.status = '51171002' then  '待退货入库' 
					when so.status = '51171003' then  '待退款' 
					when so.status = '51171004' then  '退款成功' 
					when so.status = '51171005' then  '退款失败' 
					when so.status = '51171006' then  '作废退货单'
					else null end `退货状态`,
				sum(sp.sales_return_num) `退货数量`,
				sum(so.refund_point) `退回V值`,
				max(so.create_time) `退回时间`
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
			where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
			and so.status = '51171004'     -- 退款成功
			GROUP BY 1,2,3,4
			) h 
		on a.order_code = h.order_code and b.product_id = h.product_id
		where 1=1
		and a.create_time >= '2024-01-01'
		and a.is_deleted <> 1 and b.is_deleted <> 1
		and a.type = '31011003'  -- 订单类型：沃世界商城订单
		and a.separate_status = '10041002' -- 拆单状态：否
		and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
		AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
		-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		-- and g.order_code is not null  -- 剔除退款订单
		) aa
	group by member_id
	having sum(amount) > 1000
	) t2 
on t1.id = t2.member_id 
where t1.is_vehicle = 1
and t1.is_deleted=0 and t1.member_status<>60341003
;

-- 8-20-1 半年内参与过话题发帖的用户
select distinct tp.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
and tp.create_time >= '2024-02-15'
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 8-5-1 23年有过商城订单记录，但24年未下过商城单的用户
select distinct t1.member_phone "手机号"
from member.tc_member_info t1
inner join (
	select a.user_id as member_id, max(a.create_time) last_create_time
	from `order`.tt_order a    -- 订单表
	left join `order`.tt_order_product b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	having max(a.create_time) < '2024-01-01'
	) t2 
on t1.id = t2.member_id 
where t1.is_deleted=0 and t1.member_status<>60341003
;

-- 8-22-1 参与过社区历史共创话题的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
and tt.topic_id in ('8b8aRuGNXN', 'K0wRy9Xnoa', 'smMvGTCVa5')
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 8-6-1 2024年1-7月浏览过推荐购的人群
select distinct member_phone
from (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) m 
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and a.client_time < '2024-08-01'
	and event_key = 'Page_entry'
	and var_page_title = '推荐购_邀请好友'
	group by user
	) d 
on d.distinct_id = m.cust_id::varchar
;


-- 8-7-1 7月+8月推荐购已下订未开票用户
select distinct ti.be_invite_mobile "被推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-07-01'
;

-- 8-7-2 7月+8月推荐购已下订未开票用户所对应推荐人 
select distinct ti.invite_mobile "推荐人手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-07-01'
;


-- 8-10-1 2024年1月-7月累计参与2次及以上会员日的用户——会员日忠实&高意向用户留存触达
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, count(distinct var_page_title) act_cnt
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(user)<9
	and a.client_time>='2024-01-01' and a.client_time < '2024-08-01'
	group by user
	having count(distinct var_page_title) >= 2
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 8-10-2 2024年1月1日至7月30日提交过预约试驾并到店完成试驾的粉丝用户——粉丝推荐购权限触达
select distinct m.member_phone 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select *
	from (
	 	SELECT DISTINCT ta.APPOINTMENT_ID `预约ID`
		    ,ta.CUSTOMER_PHONE `预约手机号`
		    ,ifNull(ca.active_name,'空') `沃世界来源渠道`
		    ,ifNull(tm2.model_name,'空') `留资车型`
			,case when tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01' then '已试驾'
				when d.DRIVE_STATUS in (20211001,20211004) then '待试驾'
				when tc.CODE_CN_DESC in ('待确认','待进店') then '待试驾'
				when d.DRIVE_STATUS in (20211002) then '已取消'
				when tc.CODE_CN_DESC in ('超时取消','已取消') then '已取消'
				else tc.CODE_CN_DESC end as `最终试驾状态`
			,case when(tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01') and d.DRIVE_S_AT > 	'1990-01-01' and d.DRIVE_S_AT < ta.CREATED_AT then '异常_已试驾' end as `异常_已试驾状态`
			,ta.CREATED_AT `预约时间`
	    FROM ods_cyap.ods_cyap_tt_appointment_d ta
	    LEFT JOIN (select * from ods_cyap.ods_cyap_tt_appointment_drive_d where IS_DELETED =0) tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	    LEFT JOIN (select * from ods_drse.ods_drse_tt_testdrive_plan_d where IS_DELETED =0) d on tad.ITEM_ID = d.ITEM_ID
	    LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON tc.CODE_ID = ta.IS_ARRIVED
	    LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON ca.uid = ta.CHANNEL_ID 
	    LEFT JOIN ods_bada.ods_bada_tm_model_cur tm2 on tad.THIRD_ID = toString(tm2.id)
	    WHERE ta.APPOINTMENT_TYPE  in (70691001,70691002)    -- 预约试乘试驾
	    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
		and ta.CREATED_AT >= '2024-01-01' and ta.CREATED_AT < '2024-08-01'
	    ) aa 
	where `最终试驾状态` = '已试驾' and `异常_已试驾状态` is null 
	) t2 
on m.member_phone = t2.`预约手机号`
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 0
;


-- 8-18-1 全渠道留资EM90留资，且留资后没有到店，且没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EM90的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、客流表到店(最晚)  1.1之后的到店
	select f.mobile_phone phone
		,max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	order by 2
	) b on a.mobile = b.phone
left join (
	-- 3、订单手机号（最晚）
	select o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
			tso.so_no so_no,
			tso.customer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
			tso.so_no so_no,
			tso.purchase_phone phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
			tso.so_no so_no,
			tso.drawer_tel phone,
			tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
) c on a.mobile = c.phone
where 1=1
and ((a.create_time >= b.arrive_date or b.phone is null)     -- 留资前就已经有过到店，或者留资后就没有到过店
and (a.create_time >= c.created_at or c.phone is null))     -- 并且没有订单
;

-- 8-18-2 全渠道留资EM90留资，且留资后没有订单（订单表的3个手机号都需要剔除）
select DISTINCT a.mobile phone
from (
	-- 1、全渠道留资EM90的线索明细(取最早) 最早留资时间是几号 1.1
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	order by 2
	) a
left join (
	-- 2、订单手机号（最晚）
	select o.phone,max(toDateTime(o.created_at)) created_at 
	from (
		-- 潜客手机号
		select
		tso.so_no so_no,
		tso.customer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.customer_tel is not null
		union all
		-- 下单人手机号
		select
		tso.so_no so_no,
		tso.purchase_phone phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.purchase_phone is not null
		union all
		-- 开票人手机号
		select
		tso.so_no so_no,
		tso.drawer_tel phone,
		tso.created_at created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tso.so_no_id = tsod.SO_NO_ID and tsod.IS_DELETED =0
		left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on tsod.SALES_OEDER_DETAIL_ID = tsov.sales_oeder_detail_id and tsov.is_deleted =0
		where tso.drawer_tel is not null
		) o 
	group by 1
	order by 2
	) b on a.mobile = b.phone
where 1=1
and (a.create_time >= b.created_at or b.phone is null)     -- 留资时间比订单时间晚，或者留资后没有订单
;


-- 8-8-1 24年3月1日起，浏览过沃尔沃汽车App或沃尔沃汽车沃世界+小程序预约试驾&邀约试驾的用户
select distinct b.member_phone
from (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-03-01'
	and event_key = 'Page_entry'
	and var_page_title = '预约试驾页'
	and (((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$platform` in('MiniProgram') or channel ='Mini')) -- 双端
	) a 
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where m.is_deleted =0 and m.member_status <> '60341003'
		and m.cust_id is not null
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
;


-- 8-9-1 浏览夏服页未下单用户+获得优惠券且未核销用户  -- 7277,7278,7284
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_activity_name = '2024年夏服活动'
	and client_time >=   '2024-07-26'
	and toInt32OrNull(distinct_id) IS NOT NULL
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
left join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-07-26'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	) od
on m.id = od.member_id
where 1=1
and od.member_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
select tmi.member_phone 
FROM coupon.tt_coupon_detail a
inner join "member".tc_member_info tmi 
on a.member_id  = tmi.id 
and a.is_deleted =0 and a.ticket_state = 31061001
and a.coupon_id in (7277,7278,7284)
where tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
;


-- 8-21-1 2024年1月-7月累计参与2次及以上会员日的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, count(distinct var_page_title) act_cnt
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(user)<9
	and a.client_time>='2024-01-01' and a.client_time < '2024-08-01'
	group by user
	having count(distinct var_page_title) >= 2
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 8-21-2 2024年1月1日至7月30日提交过预约试驾并到店完成试驾的粉丝用户
select distinct m.member_phone 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select *
	from (
	 	SELECT DISTINCT ta.APPOINTMENT_ID `预约ID`
		    ,ta.CUSTOMER_PHONE `预约手机号`
		    ,ifNull(ca.active_name,'空') `沃世界来源渠道`
		    ,ifNull(tm2.model_name,'空') `留资车型`
			,case when tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01' then '已试驾'
				when d.DRIVE_STATUS in (20211001,20211004) then '待试驾'
				when tc.CODE_CN_DESC in ('待确认','待进店') then '待试驾'
				when d.DRIVE_STATUS in (20211002) then '已取消'
				when tc.CODE_CN_DESC in ('超时取消','已取消') then '已取消'
				else tc.CODE_CN_DESC end as `最终试驾状态`
			,case when(tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01') and d.DRIVE_S_AT > 	'1990-01-01' and d.DRIVE_S_AT < ta.CREATED_AT then '异常_已试驾' end as `异常_已试驾状态`
			,ta.CREATED_AT `预约时间`
	    FROM ods_cyap.ods_cyap_tt_appointment_d ta
	    LEFT JOIN (select * from ods_cyap.ods_cyap_tt_appointment_drive_d where IS_DELETED =0) tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	    LEFT JOIN (select * from ods_drse.ods_drse_tt_testdrive_plan_d where IS_DELETED =0) d on tad.ITEM_ID = d.ITEM_ID
	    LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON tc.CODE_ID = ta.IS_ARRIVED
	    LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON ca.uid = ta.CHANNEL_ID 
	    LEFT JOIN ods_bada.ods_bada_tm_model_cur tm2 on tad.THIRD_ID = toString(tm2.id)
	    WHERE ta.APPOINTMENT_TYPE  in (70691001,70691002)    -- 预约试乘试驾
	    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
		and ta.CREATED_AT >= '2024-01-01' and ta.CREATED_AT < '2024-08-01'
	    ) aa 
	where `最终试驾状态` = '已试驾' and `异常_已试驾状态` is null 
	) t2 
on m.member_phone = t2.`预约手机号`
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 0
;



-- 8-21-3 过去12个月仅在小程序活跃，但未在App活跃过的车主用户
select m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-08-21'
	and (`$platform` = 'MinP' or ifnull(var_channel, '') ='Mini')
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-08-21'
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or ifnull(var_channel, '') ='App')
	group by 1	
	) t2
on t1.distinct_id = t2.distinct_id
where 1=1
and t2.distinct_id is null
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 8-24-1 历史上未领取过会员三方权益的用户（4W人）
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi 
inner join (
	-- CK取数
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or ifnull(channel, '') ='App')
	group by 1	
	) t2
on toString(tmi.cust_id) = toString(t2.distinct_id)
left join (
	select gr.member_id
	from member_rights.tt_member_get_record gr
	inner join member_rights.tc_member_rights_config config on gr.rights_config_id= config.id
	inner join member_rights.tm_member_rights rights on config.rights_id= rights.id
	where gr.is_deleted = 0
	group by 1
	) gr 
on tmi.id = gr.member_id 
where tmi.member_status <> 60341003 and tmi.is_deleted = 0
and gr.member_id is null 
limit 42000
;

-- 8-24-2 历史上领取过会员第三方权益的用户（4W人）
select distinct tmi.member_phone "手机号"
from member.tc_member_info tmi 
inner join member_rights.tt_member_get_record gr on gr.member_id  = tmi.id and gr.is_deleted = 0
inner join member_rights.tc_member_rights_config config on gr.rights_config_id= config.id
inner join member_rights.tm_member_rights rights on config.rights_id= rights.id
inner join (
	-- CK取数
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or ifnull(channel, '') ='App')
	group by 1	
	) t2
on toString(tmi.cust_id) = toString(t2.distinct_id)
where tmi.member_status <> 60341003 and tmi.is_deleted = 0
limit 40000
;


-- 8-25-1 半年内参与过话题发帖的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
and tp.create_time >= '2024-02-23'
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 8-26-1 浏览过#沃尔沃成长树计划# #遛娃日记# #沃的亲子时光# 话题的用户，Ll4EHX3tl6，ojwLv9Lvs7，tMQL1R7ekb
select distinct tmi.member_phone "手机号"
from community.tt_view_post tvp 
inner join community.tr_topic_post_link tt on tvp.post_id = tt.post_id 
and tt.topic_id in ('Ll4EHX3tl6','ojwLv9Lvs7','tMQL1R7ekb')
inner join `member`.tc_member_info tmi on tmi.id =tvp.member_id
where tvp.is_deleted = 0
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 8-27-1 2023-2024年参与过试驾享好礼抽奖的车主
select distinct tmi.member_phone "手机号"
from volvo_online_activity_module.lottery_draw_log a
inner join volvo_online_activity_module.lottery_play_pool b on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
inner join volvo_online_activity_module.lottery_play_init c on b.lottery_play_code = c.lottery_play_code and c.lottery_play_name like '%试驾%'
inner join "member".tc_member_info tmi on a.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and a.create_time >= '2023-01-01'
and tmi.is_vehicle = 1
;

-- 8-27-2 2023-2024年至今白金卡、黑卡完成推荐享好礼任务的车主
select distinct m.member_phone "手机号"
from invite.tm_invite_record ti
inner join member.tc_member_info m on ti.invite_member_id = m.id 
and ti.is_deleted = 0 and ti.create_time >= '2023-01-01'
where m.is_deleted = 0 and m.member_status <> 60341003
and m.level_id >= 3
and m.is_vehicle = 1
;

-- 8-27-3 在今年车展留资的粉丝人群（车展活动可通过活动name like"%车展%"来定位）
select m.member_phone
from member.tc_member_info m 
inner join (
	select mobile
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0 and c.active_name like '%车展%'
	and create_time >= '2024-01-01'
	group by 1
	) c 
on m.member_phone = c.mobile 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.is_vehicle = 0
;

-- 8-27-4 接受过好友邀请，但截至目前仍未购车的用户
select distinct ti.be_invite_mobile "手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
;

-- 8-27-5 参与过525线上活动的粉丝
select DISTINCT b.member_phone as member_phone
from (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and event = 'Page_entry'
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and var_activity_name = '2024年5月525车主节'
	and toDate(`time`) >=  '2024-05-15' and toDate(`time`) < '2024-06-01'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	) a
inner join (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
	) b 
on a.distinct_id = b.cust_id::varchar
where b.is_vehicle = 0
;



-- 8-28-1 下单过儿童&商务系列商品的用户
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and b.sku_code in (
		'31300905','31422630','31422673','31422674','32355378','32355379','31422637','32284867','32284868','32284869'
		,'32284467','32284465','32284466','32284633','31422696','32284866','31422943','31300907','31422614','31300906'
		,'31422615','32284584','32284598','32284626','32284627','32284625','32284464','32284463','32284462','32284732'
		,'32284922','32284923','32284924','32284925','32284934','32284940','32355401','32355402','32355397','32355618'
		,'32421107','31422688','31422689','31422617','31422616','32284859','31110226','31110369','31110371','31300704'
		,'31300861','31300862','31300863','31300864','32284931','32284930','32284929','32284928','31422662','31422663'
		,'31422782','32355307','32355306','32355305','32355304','32355303','31422642','31422641','31422640','31422639'
		,'31422638','31422661','31422660','31422659','32284747','32284746','32284745','32284744','32284743','32284567'
		,'32284568','32284569','32284570','32284571','32204955','32386899','31320530','32261595','32355231','31422844'
		,'31422834','31422839','31422843','31422833','31422838','31422842','31422832','31422837','31422841','31422831'
		,'32284763','32284764','32284765','32284766','32284767','31422836','31422840','31422830','31422835','32284632'
		,'32284630','32355993','32355992','32355991','32284822','32284823','32355990','32355989','32284518','32284517'
		,'32284516','32284515','32284514','32284520','32284519','32284523','32284522','32284521','32284599','32284600'
		,'31422812','32355230','32355229','32284631','32284708','32284762','32284761','32284759','32284758','32284760'
		,'32284705','32284623','32284707','32284704','32284706','32355907','32355908','32355909','32355910','32355911'
		,'32355924','32355925','32355926','32355927','32355928','31300901','31300883','32355445','32355446','32355566'
		,'32355567','32355568','32355569','32355570','32355571','32355572','32355573','32355574','32355575','32355599'
		,'32355600','32355601','32355602','32355603','32355604','32355605','32355606','32355607','32355608','32355621'
		,'32355622','32355623','32355624','32355625','32421190','32421191','32421192','32421193','32421194','32421195'
		,'32421196','32421197','32421198','32421199','32284955','31422932','31110268','31110266','31110265','31110267'
		,'32284629','31422815','31422684','32284458','31422676','31422808','31422675','32284634','32284835','31422879'
		,'31422692','32284487','32284486','32284485','32284461','32284460','32284459','32355367','32355436','32355437'
		,'32355438','32355439','32355440','32355482','32355612','32355526','32355422','32355423','32284975','32355410'
		,'32421161','32421162'
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;



-- 9-2-1 全渠道留资，截止当前没有到任何店（限定EX30车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EX30'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	) b on a.mobile = b.phone
where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
;

-- 9-2-2 全渠道留资30天未下订且App访问非空（限定EX30车型）
select distinct t1.mobile
from (
	select a.mobile 
	from (
		select l.mobile mobile, min(toDateTime(l.create_time)) create_time
		from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
		where 1=1
		and l.model_name = 'EX30'
		and l.is_deleted = '0'
		and length(l.mobile) = '11'
		and left(l.mobile,1) = '1'
		group by 1
		) a
	left join (
		select o.phone, max(toDateTime(o.created_at)) created_at 
		from (
			select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			) o 
		where phone is not null 
		group by 1
		) c on a.mobile = c.phone
	where a.create_time > c.created_at or c.phone is null     -- 并且没有订单
	group by a.mobile
	) t1
inner join ods_memb.ods_memb_tc_member_info_cur t2 on t1.mobile = t2.member_phone
inner join (
	select distinct_id, max(`time`) last_time
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- 双端
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) t3 
on toString(t2.cust_id) = toString(t3.distinct_id)
where t2.is_deleted = 0 and t2.member_status <> '60341003'
;


-- 9-3-1 2024年1-8月，浏览过一键留资弹窗的用户
select distinct m.member_phone as phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1 
	and `date`>='2024-01-01' and `date` < '2024-09-01'
	and event='Page_entry'
	and page_title = '内容详情_留资弹窗'
	and length(distinct_id)<9
	and event_time >='2023-12-01'
	group by distinct_id
	) a 
on toString(m.cust_id) = toString(a.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-3-2 近6个月内App+小程序累计登录3天以上的【非车主】
select DISTINCT m.member_phone as member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id, count(distinct date)
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and toDate(`time`) >=  '2024-03-02'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	having count(distinct date) > 3
	) a
on toString(m.cust_id) = toString(a.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'	
and m.is_vehicle = 0
;

--9-3-3 2023-2024年在车展留资的用户（车展活动可通过活动name like"%车展%"来定位）
select m.member_phone
from member.tc_member_info m 
inner join (
	select mobile
	from customer.tt_clue_clean a 
	left join activity.cms_active c on a.campaign_id = c.uid 
	where a.is_deleted = 0 and c.active_name like '%车展%'
	and create_time >= '2023-01-01'
	group by 1
	) c 
on m.member_phone = c.mobile 
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 9-4-1 浏览过开学季活动页面未下单用户+下单卡券未核销的用户
select m.member_phone as member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct member_id 
	from ods_cmnt.ods_cmnt_tt_view_post_cur 
	where post_id = 'qeAPpEJoy8' and is_deleted=0
	) t 
on toString(m.id) = toString(t.member_id)
left join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-08-19'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where od.member_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
select tmi.member_phone as member_phone
FROM ods_memb.ods_memb_tc_member_info_cur tmi 
inner join (
	select member_id
	from ods_coup.ods_coup_tt_coupon_detail_d a
	where a.is_deleted =0 and a.ticket_state = 31061001
	and a.coupon_id in (7565, 7566)
	group by member_id
	) tt
on toString(tt.member_id) = toString(tmi.id) 
where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
;

-- 9-5-1 半年内参与过话题发帖的用户
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time + '6 month' >= '2024-09-06'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 9-6-1 截至9月9日浏览过三师tab页的全量用户
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	-- and client_time < '2024-09-09'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-7-1 24年至今推荐购活动发起过邀请的车主
select distinct ti.invite_mobile "手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and create_time >= '2024-01-01'
;

-- 9-7-2 社区内发过UGC内容和参与话题互动的车主 
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select tp.member_id
	from community.tm_post tp
	where tp.is_deleted <> 1 and tp.post_type = 1007   -- UGC文章
	union  
	select tp.member_id
	from community.tm_post tp
	inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	) tt 
on tmi.id = tt.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.is_vehicle = 1
;

-- 9-7-3 24年1月1日-8月1日已试驾未下单用户
select distinct t1.mobile "手机号"
from (
	select tp.mobile, min(drive_s_at) first_drive_time
	from drive_service.tt_testdrive_plan tp
	where tp.is_deleted = 0 and drive_status = 20211003
	and drive_s_at >= '2024-01-01' and drive_s_at < '2024-08-02'
	group by tp.mobile 
	) t1 
left join (
	select mobile, max(created_at) last_created_at 
	from (
		select customer_tel "mobile", created_at
		from cyxdms_retail.tt_sales_orders where is_deleted = 0 and created_at >= '2024-01-01'
		union 
		select purchase_phone "mobile", created_at
		from cyxdms_retail.tt_sales_orders where is_deleted = 0 and created_at >= '2024-01-01'
		union 
		select drawer_tel "mobile", created_at
		from cyxdms_retail.tt_sales_orders where is_deleted = 0 and created_at >= '2024-01-01'
		) aa 
	where mobile is not null 
	group by mobile 
	) t2 
on t1.mobile = t2.mobile and t1.first_drive_time <= t2.last_created_at
where t2.mobile is null 
;

-- 9-8-1 全渠道留资，截止当前没有到任何店（限定EM90车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	) b on a.mobile = b.phone
where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
;

-- 9-8-2 全渠道留资，，截止当前没有下单（限定EM90车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select o.phone, max(toDateTime(o.created_at)) created_at 
	from (
		select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		union all
		select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		union all
		select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		) o 
	where phone is not null 
	group by 1
	) c on a.mobile = c.phone
where a.create_time > c.created_at or c.phone is null    
;


-- 9-9-1 全渠道留资，截止当前没到任何店，且App访问非空（限定EX30车型）
select distinct t1.mobile
from (
	select a.mobile
	from (
		select l.mobile mobile, min(toDateTime(l.create_time)) create_time
		from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
		where 1=1
		and l.model_name = 'EX30'
		and l.is_deleted = '0'
		and length(l.mobile) = '11'
		and left(l.mobile,1) = '1'
		group by 1
		) a
	left join (
		select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
		from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
		where 1=1
		and length(f.mobile_phone) = '11'
		and left(f.mobile_phone,1) = '1'
		and f.is_deleted = 0
		group by 1
		) b on a.mobile = b.phone
	where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
	group by a.mobile
	) t1
inner join ods_memb.ods_memb_tc_member_info_cur t2 on t1.mobile = t2.member_phone
inner join (
	select distinct_id, max(`time`) last_time
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- 双端
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) t3 
on toString(t2.cust_id) = toString(t3.distinct_id)
where t2.is_deleted = 0 and t2.member_status <> '60341003'
;

-- 9-9-2 全渠道留资30天未下订且App访问非空（限定EX30车型）
select distinct t1.mobile
from (
	select a.mobile 
	from (
		select l.mobile mobile, min(toDateTime(l.create_time)) create_time
		from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
		where 1=1
		and l.model_name = 'EX30'
		and l.is_deleted = '0'
		and length(l.mobile) = '11'
		and left(l.mobile,1) = '1'
		group by 1
		) a
	left join (
		select o.phone, max(toDateTime(o.created_at)) created_at 
		from (
			select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			) o 
		where phone is not null 
		group by 1
		) c on a.mobile = c.phone
	where a.create_time > c.created_at or c.phone is null     -- 并且没有订单
	group by a.mobile
	) t1
inner join ods_memb.ods_memb_tc_member_info_cur t2 on t1.mobile = t2.member_phone
inner join (
	select distinct_id, max(`time`) last_time
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- 双端
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) t3 
on toString(t2.cust_id) = toString(t3.distinct_id)
where t2.is_deleted = 0 and t2.member_status <> '60341003'
;

-- 售后六大服务用户
select distinct m.member_phone "手机号"
from (
	-- 清洗会员表
	select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
	from (
		select m.member_phone,m.id,m.cust_id,m.level_id,m.member_time,m.is_vehicle
			,row_number() over(partition by m.cust_id order by m.member_time desc,m.id desc) rk
		from ods_memb.ods_memb_tc_member_info_cur m
		where  m.member_status <> '60341003'
		and m.cust_id is not null
		and m.is_deleted =0 
		Settings allow_experimental_window_functions = 1
		) m
	where m.rk=1
    ) m
inner join (
    select `user` as distinct_id
    from ods_gio.ods_gio_event_d a
    where 1=1
    and var_page_title in ('养修预约','上门取送车_取车服务','上门取送车-取车服务','尊享代步车','道路救援','二手车估值表单页')
    and (`$platform` in ('iOS','Android','HarmonyOS') or var_channel='App')
    and event_key='Page_entry'
    and client_time >=  '2024-03-05' 
    and length(user)<9
    group by user 
    ) t 
on toString(m.cust_id) = toString(t.distinct_id)
-- where m.member_status <> '60341003' and m.is_deleted =0  
;

-- 9-11-1 点击过守护计划（含益起走、益起学急救、急救官招募）活动&文章的用户
select m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select la.distinct_id
	from dwd_23.dwd_23_gio_tracking la
	where 1=1
	and la.event='Page_entry'
	and length(la.distinct_id)<9
	and ((la.page_title ='守护计划益起走活动' and la.var_activity_name = '2024年4月守护计划益起走活动')
		OR (la.page_title ='AED视频答题' and la.var_activity_name = '2024年AED视频答题'))
	and (((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	group by la.distinct_id
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.member_status <> '60341003' and m.is_deleted =0 
union distinct 
select m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
where t.post_id in ('nHuc4A7CFz', 'liMlz5xwOa', '3lgpOlfytu', 'O1Mhj6r3A1')
and m.member_status <> '60341003' and m.is_deleted =0 
;


-- 9-20-1 下单过宅家、露营系列商品的用户(编码见右侧M30单元格)
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and b.sku_code in (
		'32284606','31422952','32355998','32284807','32284806','32284832','32284831','32284805','32284804','31300871'
		,'32284803','31300874','32284802','31300876','31422756','32355433','32355369','32355434','32355427','32355441'
		,'32355368','32355431','31300870','32284927','32284926','32284813','32284735','32284814','32284589','32284836'
		,'32355233','31422758','31422862','31422869','31422868','31422866','31422867','31422865','31422777','32284686'
		,'32284681','32284683','32284685','32284684','32284682','32284857','31422816','31300875','31422954','31422753'
		,'31422751','31422752','32355432','31422754','31422953','32355435','31422896','32284810','31422755','31422878'
		,'31422880','31422885','32284733','32355349','32284620','32284621','32284808','32284809','32284946','32284879'
		,'31422821','32284877','32284876','31300873','32284875','31300899','31422894','31422892','32355400','31422820'
		,'31422950','31422881','31422873','31422711','31422874','31300880','32355209','32355929','32355930','32284717'
		,'32284716','32284715','31422606','31422604','31422607','31422605','32355428','32355429','32355430','32355389'
		,'32355404','32355405','32355443','32355444','32355259','32355258','32355392','32355381','32355395','32355442'
		,'32355361','32355384','32355520','32355370','32355501','32355420','32355383','32355481','32355403','32355524'
		,'32355525','32355531','32355532','32355530','32355424','32355421','32355615','32355616','32355546','32355547'
		,'32355548','32355549','32355534','32355390','32355391','32355609','32355613','32355614','32355488','32355487'
		,'32355489','32355617','32355475','32355619','32355688','32355472','32355473','32355500','32421088','32421089'
		,'32355696','32421079','32421080','32355399','32421044','32421057','32421055','32421045','32355587','32284954'
		,'32284953','32284979','32355543','32284956','32355425','32355426','32421077','32421076','32421075','32421074'
		,'32421073','32421072','32421071','32421070','32421081','32421082','32355512','32355538','32421238','32421239'
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 9-20-2 浏览过中秋节活动页面未下单用户+下单卡券未核销的用户
select m.member_phone as member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select member_id, min(create_time) first_view_time
	from ods_cmnt.ods_cmnt_tt_view_post_cur 
	where post_id = 'al82xZiGRe' and is_deleted=0
	group by member_id
	) t1 
on toString(m.id) = toString(t.member_id)
left join (
	select a.user_id as member_id, max(a.create_time) last_order_time
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-09-04'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	) t2
on toString(m.id) = toString(t2.member_id)
where t2.last_order_time is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
select tmi.member_phone as member_phone
FROM ods_memb.ods_memb_tc_member_info_cur tmi 
inner join (
	select member_id
	from ods_coup.ods_coup_tt_coupon_detail_d a
	where a.is_deleted =0 and a.ticket_state = 31061001
	and a.coupon_id in (7715, 7716)
	group by member_id
	) tt
on toString(tt.member_id) = toString(tmi.id) 
where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
;

-- 9-12-1 全渠道留资，截止当前没有到任何店（限定EM90车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	) b on a.mobile = b.phone
where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
;

-- 9-12-2 全渠道留资，，截止当前没有下单（限定EM90车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EM90'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select o.phone, max(toDateTime(o.created_at)) created_at 
	from (
		select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		union all
		select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		union all
		select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
		from ods_cydr.ods_cydr_tt_sales_orders_cur tso
		) o 
	where phone is not null 
	group by 1
	) c on a.mobile = c.phone
where a.create_time > c.created_at or c.phone is null    
;

-- 9-13-1 2024年参与过会员日活动车主
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
;

-- 9-13-2 2023-2024年至今白金卡、黑卡完成推荐享好礼任务的车主
select distinct m.member_phone "手机号"
from invite.tm_invite_record ti
inner join member.tc_member_info m on ti.invite_member_id = m.id 
and ti.is_deleted = 0 and ti.create_time >= '2023-01-01'
where m.is_deleted = 0 and m.member_status <> 60341003
and m.level_id >= 3
and m.is_vehicle = 1
;


-- 9-14-1 全渠道留资，截止当前没有到任何店（限定EX30车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EX30'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	) b on a.mobile = b.phone
where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
;

-- 9-14-2 全渠道留资，截止当前无订单，且App访问非空（限定EX30车型）
select distinct t1.mobile
from (
	select a.mobile 
	from (
		select l.mobile mobile, min(toDateTime(l.create_time)) create_time
		from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
		where 1=1
		and l.model_name = 'EX30'
		and l.is_deleted = '0'
		and length(l.mobile) = '11'
		and left(l.mobile,1) = '1'
		group by 1
		) a
	left join (
		select o.phone, max(toDateTime(o.created_at)) created_at 
		from (
			select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			) o 
		where phone is not null 
		group by 1
		) c on a.mobile = c.phone
	where a.create_time > c.created_at or c.phone is null     -- 并且没有订单
	group by a.mobile
	) t1
inner join ods_memb.ods_memb_tc_member_info_cur t2 on t1.mobile = t2.member_phone
inner join (
	select distinct_id, max(`time`) last_time
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- 双端
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) t3 
on toString(t2.cust_id) = toString(t3.distinct_id)
where t2.is_deleted = 0 and t2.member_status <> '60341003'
;

-- 9-18-1 8月+9月推荐购已下订未开票用户
select distinct ti.be_invite_mobile "手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-08-01'
;

-- 9-18-2 8月+9月推荐购已下订未开票用户及其对应推荐人 
select distinct ti.invite_mobile "手机号"
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-08-01'
;


-- 9-19-1 参与过24年任意一期会员日的用户（剔除黑产）
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	) d 
on toString(m.cust_id) = d.distinct_id
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-17-1 历史浏览过EM90相关文章≥3次的人
select distinct tmi.member_phone "手机号"
from `member`.tc_member_info tmi
inner join (
	select member_id, count(*)
	from community.tt_view_post 
	where is_deleted = 0 
	and post_id in (
		'LtaG2DwBA6'
		,'WMsxrwR0N9'
		,'ADgF8VGODS'
		,'j1KA1iwVaF'
		,'yr8uH5TEHf'
		,'m7gjf0rkYf'
		,'SyOaNFpSO3'
		,'wje21Z4VDH'
		,'jcqGgsp4g2'
		,'BeOWlHH4sA'
		,'bfMlHRwVdN'
		,'BfcDq6S8fi'
		,'EJsJj5qXfC'
		,'uawvtZng0L'
		,'SkQl8fCDK6'
		,'ZpOUwR45lc'
		,'rN86aXJayZ'
		,'oBMb27pR2T'
		,'0AO0oEnc4F'
		,'r7KCc7Q94R'
		,'UnqIvxbt45'
		,'Vjgn718QuU'
		,'SJe4iPZx4a'
		,'PPQhUbc4xK'
		,'2rsLKB8ZX7'
		,'RruMWUeaF1'
		,'lGeaDJfEGd'
		,'aYqIteYxTF'
		,'QoQDHBg0qM'
		,'c5Kcf7VJg0'
		,'5waA1XVwbE'
		,'eMaI30IJEW'
		,'scchP8MYxl'
		,'ksstTRU6j2'
		,'WAQpM3kNVy'
		,'n9sZLQHpOC'
		,'2sOeP69Zfw'
		,'weeIgG327J'
		,'lUg3XRy8zG'
		,'ZBuUyH708g'
		,'6QwzNgGckU'
		,'9D63nuDMiQ'
		,'ZKcBFkSwPs'
		,'n94sF6wHCN'
		,'Q76ZHV83P0'
		,'m061ZMh4SV'
		,'XZ6DW4UVpX'
		,'V14of589W9'
		,'duewwa5AqU'
		,'DcOiPB3Dhm'
		,'kf4qEbUIuk'
		,'CIuyBnVgN6'
		,'glwpUhf3Mz'
		,'r2MvuisSAX'
		,'XLeeTqQXhS'
		,'OMM16js2rF'
		,'mC8uzxmBij'
		,'oUKCCzxi2r'
		,'6XA5MdUN9D'
		,'m1sX4J98o4'
		,'G7slZ4uLgK'
		,'T1KQ3xyL8k'
		,'UUe0MPu1Os'
		,'JQ8C3DHjYY'
		,'iCcrUdCELl'
		,'JWu2jzyN42'
		,'7Su6AE9jd6'
		,'4MKk3qEFNq'
		,'T0gVQkYxTw'
		,'IhOW7APlaV'
		,'xxwxadkfi4'
		,'kdM7NGADIw'
		)
	group by member_id having count(*) >= 3
	) tvp 
on tmi.id = tvp.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 9-21-1 2023年至今商城下单过【趣味童年】精品系列的车主+粉丝
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and b.sku_code in (
		'32355410'
		,'32284955'
		,'32355422'
		,'32284975'
		,'32355423'
		,'32421190'
		,'32421191'
		,'32421192'
		,'32421193'
		,'32421194'
		,'32421195'
		,'32421196'
		,'32421197'
		,'32421198'
		,'32421199'
		,'32284514'
		,'32284515'
		,'32284516'
		,'32284517'
		,'32284518'
		,'32284519'
		,'32284520'
		,'32284521'
		,'32284522'
		,'32284523'
		,'32284743'
		,'32284744'
		,'32284745'
		,'32284746'
		,'32284747'
		,'31422684'
		,'32284630'
		,'31422835'
		,'31422830'
		,'31422840'
		,'31422836'
		,'31422831'
		,'31422841'
		,'31422837'
		,'31422832'
		,'31422842'
		,'31422838'
		,'31422833'
		,'31422843'
		,'31422839'
		,'31422834'
		,'31422844'
		,'32355229'
		,'32355230'
		,'32284629'
		,'32284705'
		,'32284706'
		,'32284707'
		,'32284708'
		,'32355989'
		,'32355990'
		,'32355991'
		,'32355992'
		,'32355993'
		,'32355566'
		,'32355567'
		,'32355568'
		,'32355569'
		,'32355570'
		,'32355571'
		,'32355572'
		,'32355573'
		,'32355574'
		,'32355575'
		,'32355231'
		,'31110265'
		,'31110266'
		,'31110267'
		,'31110268'
		,'31422812'
		,'31422631'
		,'31422632'
		,'31422633'
		,'31422634'
		,'31422635'
		,'31422638'
		,'31422639'
		,'31422640'
		,'31422641'
		,'31422642'
		,'32284614'
		,'32284615'
		,'32284616'
		,'32284617'
		,'32284618'
		,'32284619'
		,'32355235'
		,'32355236'
		,'32355237'
		,'32355238'
		,'32355239'
		,'32355240'
		,'32355241'
		,'32355303'
		,'32355304'
		,'32355305'
		,'32355306'
		,'32355307'
		,'32284632'
		,'32355599'
		,'32355600'
		,'32355601'
		,'32355602'
		,'32355603'
		,'32355604'
		,'32355605'
		,'32355606'
		,'32355607'
		,'32355608'
		,'31422932'
		,'32421240'
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 9-21-2 2023年至今商城下单过【麋鹿】精品系列的车主+粉丝
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and b.sku_code in (
		'31422675'
		,'31422676'
		,'31422808'
		,'32284458'
		,'32421079'
		,'32421080'
		,'32355422'
		,'32355423'
		,'32284975'
		,'32421161'
		,'32421162'
		,'32421164'
		,'32421165'
		,'32421163'
		,'32421291'
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-21-3 2024年8月至今浏览过三师tab页、三师推荐购页面的车主
select m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	and client_time >= '2024-08-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct 
select m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'mYKS40ByaO' and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' and m.is_deleted =0 
and m.is_vehicle = 1
;

-- 9-21-4 2024年4月至今浏览过守护计划tab的车主
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '沃尔沃汽车守护日'
	and client_time >= '2024-04-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
;



-- 9-15-1 参与过社区投票互动的用户+参与过#我的开箱惊喜#+参与过#WO最爱的夏日度假#参与过#中秋开箱惊喜#话题的用户
select distinct tmi.member_phone "手机号"
from community.tm_post tp
inner join community.tr_topic_post_link tt on tp.post_id = tt.post_id 
and tt.topic_id in ('VJMD82LYkY','DLMFHkzBjI','vTchj6YPVL')
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)
inner join `member`.tc_member_info tmi on tp.member_id = tmi.id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 9-15-2 下单过宅家、露营系列商品的用户（编码见L列）
select distinct m.member_phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and b.sku_code in (
		'32284606'
		,'31422952'
		,'32355998'
		,'32284807'
		,'32284806'
		,'32284832'
		,'32284831'
		,'32284805'
		,'32284804'
		,'31300871'
		,'32284803'
		,'31300874'
		,'32284802'
		,'31300876'
		,'31422756'
		,'32355433'
		,'32355369'
		,'32355434'
		,'32355427'
		,'32355441'
		,'32355368'
		,'32355431'
		,'31300870'
		,'32284927'
		,'32284926'
		,'32284813'
		,'32284735'
		,'32284814'
		,'32284589'
		,'32284836'
		,'32355233'
		,'31422758'
		,'31422862'
		,'31422869'
		,'31422868'
		,'31422866'
		,'31422867'
		,'31422865'
		,'31422777'
		,'32284686'
		,'32284681'
		,'32284683'
		,'32284685'
		,'32284684'
		,'32284682'
		,'32284857'
		,'31422816'
		,'31300875'
		,'31422954'
		,'31422753'
		,'31422751'
		,'31422752'
		,'32355432'
		,'31422754'
		,'31422953'
		,'32355435'
		,'31422896'
		,'32284810'
		,'31422755'
		,'31422878'
		,'31422880'
		,'31422885'
		,'32284733'
		,'32355349'
		,'32284620'
		,'32284621'
		,'32284808'
		,'32284809'
		,'32284946'
		,'32284879'
		,'31422821'
		,'32284877'
		,'32284876'
		,'31300873'
		,'32284875'
		,'31300899'
		,'31422894'
		,'31422895'
		,'31422892'
		,'31422822'
		,'32355380'
		,'32284878'
		,'32355400'
		,'31422871'
		,'31422897'
		,'31422886'
		,'31422811'
		,'32355219'
		,'31422820'
		,'31422950'
		,'31422881'
		,'31422873'
		,'31422711'
		,'31422874'
		,'31300880'
		,'32355209'
		,'32355929'
		,'32355930'
		,'32284717'
		,'32284716'
		,'32284715'
		,'31422606'
		,'31422604'
		,'31422607'
		,'31422605'
		,'32355428'
		,'32355429'
		,'32355430'
		,'32355375'
		,'32355389'
		,'32355404'
		,'32355405'
		,'32355443'
		,'32355444'
		,'32355259'
		,'32355258'
		,'32355392'
		,'32355381'
		,'32355395'
		,'32355442'
		,'32355361'
		,'32355384'
		,'32355520'
		,'32355370'
		,'32355501'
		,'32355420'
		,'32355383'
		,'32355481'
		,'32355403'
		,'32355524'
		,'32355525'
		,'32355531'
		,'32355532'
		,'32355530'
		,'32355424'
		,'32355421'
		,'32355615'
		,'32355616'
		,'32355546'
		,'32355547'
		,'32355548'
		,'32355549'
		,'32355396'
		,'32355534'
		,'32355390'
		,'32355391'
		,'32355609'
		,'32355613'
		,'32355614'
		,'32355488'
		,'32355487'
		,'32355489'
		,'32355617'
		,'32355475'
		,'32355619'
		,'32355688'
		,'32355472'
		,'32355473'
		,'32355500'
		,'32421088'
		,'32421089'
		,'32355696'
		,'32421079'
		,'32421080'
		,'32355399'
		,'32421044'
		,'32421057'
		,'32421055'
		,'32421045'
		,'32284979'
		,'32355587'
		,'32421081'
		,'32421082'
		,'32355512'
		,'32421077'
		,'32421076'
		,'32421075'
		,'32421074'
		,'32421073'
		,'32421072'
		,'32421071'
		,'32421070'
		,'32421175'
		,'32421049'
		,'32421054'
		,'32421053'
		,'32421052'
		,'32284954'
		,'32284953'
		,'32355543'
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-19-1 2024年1月-8月累计参与2次及以上会员日的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01' and a.client_time < '2024-09-01'
	group by `user`
	having count(distinct var_page_title) >= 2
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 9-19-2 参与过24年8月会员日活动的用户
select distinct m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and var_page_title = '8月会员日'
	and length(`user`)<9
	and a.client_time>='2024-08-01' and a.client_time < '2024-09-01'
	group by `user`
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 9-19-3 近12个月小程序活跃，App未活跃过的车主用户
select m.member_phone "手机号"
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-09-23'
	and (`$platform` = 'MinP' or ifnull(var_channel, '') ='Mini')
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-09-23'
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or ifnull(var_channel, '') ='App')
	group by 1	
	) t2
on t1.distinct_id = t2.distinct_id
where 1=1
and t2.distinct_id is null
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 9-22-1 全渠道留资，截止当前没有到任何店（限定EX30车型）
select DISTINCT a.mobile phone
from (
	select l.mobile mobile, min(toDateTime(l.create_time)) create_time
	from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
	where 1=1
	and l.model_name = 'EX30'
	and l.is_deleted = '0'
	and length(l.mobile) = '11'
	and left(l.mobile,1) = '1'
	group by 1
	) a
left join (
	select f.mobile_phone phone, max(toDateTime(left(f.arrive_date,19))) arrive_date
	from ods_cypf.ods_cypf_tt_passenger_flow_info_cur f
	where 1=1
	and length(f.mobile_phone) = '11'
	and left(f.mobile_phone,1) = '1'
	and f.is_deleted = 0
	group by 1
	) b on a.mobile = b.phone
where a.create_time > b.arrive_date or b.phone is null     -- 留资前就已经有过到店，或者留资后就没有到过店
;

-- 9-22-2 全渠道留资，截止当前无订单，且App访问非空（限定EX30车型）
select distinct t1.mobile phone
from (
	select a.mobile 
	from (
		select l.mobile mobile, min(toDateTime(l.create_time)) create_time
		from ods_oper_crm.all_channel_leads_202307_start l     -- 全渠道留资表
		where 1=1
		and l.model_name = 'EX30'
		and l.is_deleted = '0'
		and length(l.mobile) = '11'
		and left(l.mobile,1) = '1'
		group by 1
		) a
	left join (
		select o.phone, max(toDateTime(o.created_at)) created_at 
		from (
			select tso.customer_tel phone, tso.created_at created_at -- 潜客手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.purchase_phone phone, tso.created_at created_at -- 下单人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			union all
			select tso.drawer_tel phone, tso.created_at created_at -- 开票人手机号
			from ods_cydr.ods_cydr_tt_sales_orders_cur tso
			) o 
		where phone is not null 
		group by 1
		) c on a.mobile = c.phone
	where a.create_time > c.created_at or c.phone is null     -- 并且没有订单
	group by a.mobile
	) t1
inner join ods_memb.ods_memb_tc_member_info_cur t2 on t1.mobile = t2.member_phone
inner join (
	select distinct_id, max(`time`) last_time
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and ((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') -- 双端
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	) t3 
on toString(t2.cust_id) = toString(t3.distinct_id)
where t2.is_deleted = 0 and t2.member_status <> '60341003'
;

-- 9-24-1 参加过“益起走”并捐过步的用户+已点亮如下任一勋章用户：AED守护官/AED联盟/小红花栽培师/爱心大使/特邀发言官/原创达人+近30天在App发布过动态/文章的用户
select b.id as member_id
from ods_dmoa.ods_dmoa_tm_lovestep_log_d  a --会员步数流水表
inner join ods_memb.ods_memb_tc_member_info_cur b on a.member_id =b.id 
where b.is_deleted =0 and b.member_status <> '60341003'
and a.is_deleted = 0
and a.step_type = 2 --捐赠过并捐赠成功
union 
select tm.id as member_id
from mine.madal_detail t1
inner join mine.user_medal t2 on t2.id = t1.medal_id and t2.id in (1,2,9,16,23,24)
inner join `member`.tc_member_info tm on tm.ID = t1.user_id and tm.is_deleted = 0 and tm.member_status <> '60341003'
where t1.deleted = 1  -- 有效
and t1.status = 1  -- 正常
union 
select tm.id as member_id
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time >= '2024-08-29' and platform_app = 1
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;




-- 9-25-2 2024年1-9月，浏览过一键留资弹窗、浮窗但未留资(24年未留资)的用户
select distinct m.member_phone as phone
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id
	from dwd_23.dwd_23_gio_tracking a
	where 1=1 
	and `date`>='2024-01-01'
	and event='Page_entry'
	and page_title = '内容详情_留资弹窗'
	and length(distinct_id)<9
	and event_time >='2023-12-01'
	group by distinct_id
	) a 
on toString(m.cust_id) = toString(a.distinct_id)
left join (
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur t1 
	where t1.is_deleted = 0 and t1.create_time >= '2024-01-01'
	) t1 
on m.member_phone = t1.mobile
where m.is_deleted = 0 and m.member_status <> '60341003'
and t1.mobile is null 
;

-- 9-26-1 推荐购发起过邀请（建立过邀约关系），但最终被邀请人未成功购车的车主（邀请人）
select distinct invite_member_id member_id
from invite.tm_invite_record a
inner join `member`.tc_member_info m
on m.is_deleted = 0 and m.member_status <> 60341003
where a.is_deleted = 0 and m.is_vehicle=1
and (order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
;


-- 9-23-1 浏览过国庆节活动页面未下单用户+下单卡券未核销的用户
select m.id as member_id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select member_id, min(create_time) first_view_time
	from ods_cmnt.ods_cmnt_tt_view_post_cur 
	where post_id = 'VWqsdr9W3J' and is_deleted=0
	group by member_id
	) t1 
on toString(m.id) = toString(t1.member_id)
left join (
	select a.user_id as member_id, max(a.create_time) last_order_time
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-09-12'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	) t2
on toString(m.id) = toString(t2.member_id)
where t2.member_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
select tmi.id as member_id
FROM ods_memb.ods_memb_tc_member_info_cur tmi 
inner join (
	select member_id
	from ods_coup.ods_coup_tt_coupon_detail_d a
	where a.is_deleted =0 and a.ticket_state = 31061001
	and a.coupon_id in (7750, 7751)
	group by member_id
	) tt
on toString(tt.member_id) = toString(tmi.id) 
where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
;


-- 10-7-1 俱乐部车主
with club as (
	select club_id ,create_time 
	from ods_cocl.ods_cocl_tt_club_attr_audit_d 
	where is_deleted = 0
	and attr_type = '10010' 
	-- and content = '沃尔沃汽车湖北沃驰天下车友会'
 )
select m.id as member_id 
from ods_cocl.ods_cocl_tr_club_friends_d a
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.id) = a.member_id 
where a.club_id in (select club_id from club)
and m.is_deleted = 0
and m.member_status <> '60341003'
and m.is_vehicle = 1
;


-- 10-7-2 参与过推荐购活动的白金卡和黑卡车主
select distinct m.id as member_id
from invite.tm_invite_record ti
inner join member.tc_member_info m on ti.invite_member_id = m.id 
and ti.is_deleted = 0 -- and ti.create_time >= '2023-01-01'
where m.is_deleted = 0 and m.member_status <> 60341003
and m.level_id >= 3
and m.is_vehicle = 1
;


-- 10-8-1 近4个月内App+小程序累计登录3天以上的【非车主】(剔除1个月内留资的用户）
select DISTINCT m.id as member_id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct_id, count(distinct date)
	from dwd_23.dwd_23_gio_tracking oredd
	where 1=1
	and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
	and toDate(`time`) >=  '2024-06-10'
	and toInt32OrNull(distinct_id) IS NOT NULL and length(distinct_id)<9
	group by distinct_id
	having count(distinct date) > 3
	) a
on toString(m.cust_id) = toString(a.distinct_id)
left join (
	select mobile 
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-09-10'
	group by 1
	) tcc 
on m.member_phone=tcc.mobile
where m.is_deleted = 0 and m.member_status <> '60341003'	
and m.is_vehicle = 0
and tcc.mobile is null 
;

-- 10-8-2 2024年大型活动，进入过的用户数（2024年2月WOW商城贺岁季、2024年525车主节、2024年夏服活动、2024年4月守护计划益起走活动）
select distinct m.id as member_id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name in ('2024年2月WOW商城贺岁季', '2024年5月525车主节', '2024年夏服活动', '2024年4月守护计划益起走活动')
	and length(`user`)<9
	and a.client_time>='2024-02-01'
	group by `user`
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 10-14-1 24年有成功推荐过用户购车的车主用户（推荐享好礼）
select distinct invite_member_id as member_id
from invite.tm_invite_record a
inner join `member`.tc_member_info m
on m.is_deleted = 0 and m.member_status <> 60341003
where a.is_deleted = 0 and m.is_vehicle=1
and (a.order_no is not null and order_status not in ('14041009', '14041013', '14041012', '14041011'))
;


-- 10-14-2 24年有提交过预约试驾留资的用户
select distinct m.id as member_id  
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	SELECT DISTINCT ta.APPOINTMENT_ID `预约ID`
		,ta.CUSTOMER_PHONE `预约手机号`
		,ifNull(ca.active_name,'空') `沃世界来源渠道`
		,ifNull(tm2.model_name,'空') `留资车型`
		,case when tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01' then '已试驾'
			when d.DRIVE_STATUS in (20211001,20211004) then '待试驾'
			when tc.CODE_CN_DESC in ('待确认','待进店') then '待试驾'
			when d.DRIVE_STATUS in (20211002) then '已取消'
			when tc.CODE_CN_DESC in ('超时取消','已取消') then '已取消'
			else tc.CODE_CN_DESC end as `最终试驾状态`
		,case when(tc.CODE_CN_DESC ='已到店' or d.DRIVE_STATUS = 20211003 or d.DRIVE_S_AT > '1990-01-01' or d.DRIVE_E_AT > '1990-01-01') and d.DRIVE_S_AT > 	'1990-01-01' and d.DRIVE_S_AT < ta.CREATED_AT then '异常_已试驾' end as `异常_已试驾状态`
		,ta.CREATED_AT `预约时间`
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	LEFT JOIN (select * from ods_cyap.ods_cyap_tt_appointment_drive_d where IS_DELETED =0) tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	LEFT JOIN (select * from ods_drse.ods_drse_tt_testdrive_plan_d where IS_DELETED =0) d on tad.ITEM_ID = d.ITEM_ID
	LEFT JOIN ods_dict.ods_dict_tc_code_d tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN ods_actv.ods_actv_cms_active_d ca ON ca.uid = ta.CHANNEL_ID 
	LEFT JOIN ods_bada.ods_bada_tm_model_cur tm2 on tad.THIRD_ID = toString(tm2.id)
	WHERE ta.APPOINTMENT_TYPE = 70691002    -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	and ta.CREATED_AT >= '2024-01-01'
	) t2 
on m.member_phone = t2.`预约手机号`
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 10-14-3 24年参与过5次及以上会员日的车主用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	having count(distinct var_page_title) >= 5
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle=1
;


-- 10-20-1 24年参与过2次及以上会员日的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	having count(distinct var_page_title) >= 2
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 10-20-2 近12个月于小程序活跃过但未于app活跃的车主用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-10-21'
	and (`$platform` = 'MinP' or ifnull(var_channel, '') ='Mini')
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2023-10-21'
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or ifnull(var_channel, '') ='App')
	group by 1	
	) t2
on t1.distinct_id = t2.distinct_id
where 1=1
and t2.distinct_id is null
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 10-21-1 24年9月+10月推荐购已下订未开票用户
select distinct ti.be_invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-09-01'
;

-- 10-21-2 24年9月+10月推荐购已下订未开票用户及其对应推荐人
select distinct ti.invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-09-01'
;


-- 10-15-1 半年内参与过任一话题发帖的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time + '6 month' >= '2024-10-24'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 11-1-1 金卡10月活跃粉丝 且30天内无预约或试驾记录
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-10-01'
	and a.client_time < '2024-11-01'
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select distinct ta.ONE_ID as member_id
	from ods_cyap.ods_cyap_tt_appointment_d ta
	where APPOINTMENT_TYPE = 70691002 and CREATED_AT >= '2024-09-31'
	) t2
on toString(m.id) = toString(t2.member_id)
left join (
	select distinct tp.MOBILE AS mobile
	from ods_drse.ods_drse_tt_testdrive_plan_d tp
	where tp.IS_DELETED = 0 and DRIVE_S_AT >= '2024-09-31'
	) t3
on toString(m.member_phone) = toString(t3.mobile)
where 1=1
and m.level_id = 2 and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
and t2.member_id is null 
and t3.mobile is null 
;


-- 11-2-1 2024年浏览过推荐购页面，但未发起过推荐的车主
select distinct tmi.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key = 'Page_entry'
	and var_page_title = '推荐购_邀请好友'
	group by user
	) t1 
on toString(t1.distinct_id) = toString(tmi.cust_id)
left join (
	select invite_member_id
	from ods_invi.ods_invi_tm_invite_record_d 
	where is_deleted = 0 and create_time >= '2024-01-01'
	group by 1
	) t2 
on toString(t2.invite_member_id) = toString(tmi.id)
where t2.invite_member_id is null 
and tmi.is_vehicle = 1
and tmi.is_deleted=0 and tmi.member_status <> '60341003'
;


-- 11-2-2 2024年预约售后养修的车主
select distinct tmi.id as member_id 
from member.tc_member_info tmi 
inner join (
	select ta.one_id 
	from cyx_appointment.tt_appointment ta
	where ta.is_deleted=0 
	and ta.APPOINTMENT_TYPE = 70691005
	and ta.DATA_SOURCE = 'C' 
	and ta.created_at >= '2024-01-01'
	group by 1
	) ta 
on ta.one_id = tmi.CUST_ID 
where tmi.is_deleted=0 and tmi.member_status <> '60341003'
and tmi.is_vehicle = 1
;


-- 11-3-1 近半年沃世界+App 登录3天及以上非车主，且有过留资行为且未试驾用户（剔除一个月内留资）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, count(distinct dt)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-05-08'
	and ((`$platform` = 'MinP' or var_channel ='Mini') or ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'))
	group by 1 having count(distinct dt) >= 3
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
inner join (
	select mobile, max(create_time) last_create_time
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-05-08'
	group by 1 having max(create_time) < '2024-10-08'
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
left join (
	select distinct tp.MOBILE AS mobile
	from ods_drse.ods_drse_tt_testdrive_plan_d tp
	where tp.IS_DELETED = 0 and DRIVE_S_AT>= '2024-05-08'
	) t3
on toString(m.member_phone) = toString(t3.mobile)
where t3.mobile is null 
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 11-3-2 2024年截至11月浏览过试驾享好礼、预约试驾页面且未留资的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key = 'Page_entry'
	and var_page_title in ('试驾享好礼', '预约试驾页')
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-01-01'
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where t2.mobile is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 11-8-1 2024年8月至今浏览过三师tab页、三师推荐购页面的车主
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	and client_time >= '2024-08-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct 
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'mYKS40ByaO' and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' and m.is_deleted =0 
and m.is_vehicle = 1
;

-- 11-8-2 2024年4月至今浏览过守护计划tab的车主
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '沃尔沃汽车守护日'
	and client_time >= '2024-04-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
;

-- 11-8-3 "2023年至今商城下单过【趣味童年】精品系列的车主+粉丝、2023年至今商城下单过【麋鹿】精品系列的车主+粉丝"
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and (
		b.sku_code in (
		-- 趣味童年
		'32355410'
		,'32284955'
		,'32355422'
		,'32284975'
		,'32355423'
		,'32421190'
		,'32421191'
		,'32421192'
		,'32421193'
		,'32421194'
		,'32421195'
		,'32421196'
		,'32421197'
		,'32421198'
		,'32421199'
		,'32284514'
		,'32284515'
		,'32284516'
		,'32284517'
		,'32284518'
		,'32284519'
		,'32284520'
		,'32284521'
		,'32284522'
		,'32284523'
		,'32284743'
		,'32284744'
		,'32284745'
		,'32284746'
		,'32284747'
		,'31422684'
		,'32284630'
		,'31422835'
		,'31422830'
		,'31422840'
		,'31422836'
		,'31422831'
		,'31422841'
		,'31422837'
		,'31422832'
		,'31422842'
		,'31422838'
		,'31422833'
		,'31422843'
		,'31422839'
		,'31422834'
		,'31422844'
		,'32355229'
		,'32355230'
		,'32284629'
		,'32284705'
		,'32284706'
		,'32284707'
		,'32284708'
		,'32355989'
		,'32355990'
		,'32355991'
		,'32355992'
		,'32355993'
		,'32355566'
		,'32355567'
		,'32355568'
		,'32355569'
		,'32355570'
		,'32355571'
		,'32355572'
		,'32355573'
		,'32355574'
		,'32355575'
		,'32355231'
		,'31110265'
		,'31110266'
		,'31110267'
		,'31110268'
		,'31422812'
		,'31422631'
		,'31422632'
		,'31422633'
		,'31422634'
		,'31422635'
		,'31422638'
		,'31422639'
		,'31422640'
		,'31422641'
		,'31422642'
		,'32284614'
		,'32284615'
		,'32284616'
		,'32284617'
		,'32284618'
		,'32284619'
		,'32355235'
		,'32355236'
		,'32355237'
		,'32355238'
		,'32355239'
		,'32355240'
		,'32355241'
		,'32355303'
		,'32355304'
		,'32355305'
		,'32355306'
		,'32355307'
		,'32284632'
		,'32355599'
		,'32355600'
		,'32355601'
		,'32355602'
		,'32355603'
		,'32355604'
		,'32355605'
		,'32355606'
		,'32355607'
		,'32355608'
		,'31422932'
		,'32421240'
		) 
		or b.sku_code in (
		-- 麋鹿
		'31422675'
		,'31422676'
		,'31422808'
		,'32284458'
		,'32421079'
		,'32421080'
		,'32355422'
		,'32355423'
		,'32284975'
		,'32421161'
		,'32421162'
		,'32421164'
		,'32421165'
		,'32421163'
		,'32421291'
		)
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 11-6-1 半年内参与过任一话题发帖的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time + '6 month' >= '2024-11-15'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 11-6-2 24年8月当月活跃过，但11月未活跃的用户（车主+粉丝）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	-- 24年8月活跃过
	select distinct memberid 
	from ods_oper_crm.ods_oper_crm_active_gio_l_si a
	where a.dt >= '2024-08-01'
	and a.dt < '2024-09-01'
	) a on toString(m.id) = toString(a.memberid)
left join (
	-- 11月截止当前活跃过
	select distinct memberid 
	from ods_oper_crm.ods_oper_crm_active_gio_l_si a
	where a.dt >= '2024-11-01'
	) b on a.memberid = b.memberid
where b.memberid is null -- 剔除11月活动用户
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- EM90已交车客户数据提取
with bind_rn as (
	select vin_code, member_id, operate_date
		,row_number()over(partition by vin_code order by operate_date asc) rn 
		,row_number()over(partition by vin_code order by operate_date desc) rn_desc 
	from ods_vocm.ods_vocm_vehicle_bind_record_d
	where event_type='1' and deleted=0 -- and is_owner=1
	)
select tsov.sales_vin "订单VIN"
	,toDate(tso.created_at) "购车订单创建时间"
	,toDate(vb.operate_date) as "首次绑车时间"
	,vb.member_id as "首次绑车memberid"
	,case when vb.rn_desc > 1 then 1 when vb.vin_code is not null then 0 end "是否进行过换绑"
	,case when vb.vin_code is not null then vb.rn_desc - 1 end "换绑次数"
	,toDate(vb2.operate_date) "最近绑车时间"
	,toDate(mg.last_log_date) "首次绑车memberid最近登陆时间"
from ods_cydr.ods_cydr_tt_sales_orders_cur tso
left join ods_cydr.ods_cydr_tt_sales_order_detail_d tsod on tsod.SO_NO_ID = tso.so_no_id and tsod.IS_DELETED = 0
left join ods_cydr.ods_cydr_tt_sales_order_vin_cur tsov on toString(tsov.sales_oeder_detail_id) = toString(tsod.SALES_OEDER_DETAIL_ID)
left join ods_bada.ods_bada_tm_model_cur tm on toString(tsod.SECOND_ID) = toString(tm.id)
left join bind_rn vb on tsov.sales_vin = vb.vin_code and vb.rn=1
left join bind_rn vb2 on tsov.sales_vin = vb2.vin_code and vb2.rn_desc=1
left join (
	select memberid, max(dt) last_log_date
	from ods_oper_crm.ods_oper_crm_active_gio_l_si a
	group by memberid
	) mg on toString(vb.member_id) = toString(mg.memberid)
where tso.is_deleted = 0
and tso.so_status = '14041008'
and tm.model_name = 'EM90'
;

-- 11-10-1 2024年1月至11月20日未完成过养修的车主用户
select distinct vr.member_id 
from `member`.tc_member_info tmi
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr on vr.member_id = tmi.id and vr.rn = 1
inner join (
	select vin, max(ro_create_date)
	from cyx_repair.tt_repair_order
	where is_deleted = 0 
	group by vin 
	having max(ro_create_date) < '2024-01-01'
	) t1 on t1.vin = vr.vin_code
where tmi.is_vehicle=1
and tmi.is_deleted = 0 
and tmi.member_status <> 60341003
;

-- 11-10-2 24年参与过2次及以上会员日活动的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	having count(distinct var_page_title) >= 2
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 11-10-3 参与过24年8月会员日活动但未获得集卡补签卡的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name = '2024年8月会员日'
	and var_page_title = '8月会员日'
	and length(`user`)<9
	and a.client_time>='2024-08-01'
	group by `user`
	) d 
on toString(m.cust_id) = toString(d.distinct_id)
left join (
	-- 获得集卡补签卡的用户
	select a.member_id
	from ods_voam.ods_voam_lottery_draw_log_d a
	inner join ods_voam.ods_voam_lottery_play_pool_d b 
	on a.lottery_play_code = b.lottery_play_code and a.prize_code = b.prize_code
	where a.have_win = 1   -- 中奖
	and b.prize_code ='l4asPrhFdP'
	) tt
on toString(m.id) = toString(tt.member_id)
where tt.member_id is null 
and m.is_deleted = 0 and m.member_status <> '60341003'
;

--11-10-4 24年仅在小程序活跃，未在App活跃过的车主
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	-- 24年小程序活跃过
	select distinct memberid 
	from ods_oper_crm.ods_oper_crm_active_gio_l_si a
	where a.dt >= '2024-01-01'
	and platform = 'Mini'
	) a on toString(m.id) = toString(a.memberid)
left join (
	-- 24年APP活跃过
	select distinct memberid 
	from ods_oper_crm.ods_oper_crm_active_gio_l_si a
	where a.dt >= '2024-01-01'
	and platform = 'App'
	) b on a.memberid = b.memberid
where b.memberid is null
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

--11-11-1 10月+11月推荐购已下订未开票用户
select distinct ti.be_invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-10-01'
;

--11-11-2 10月+11月推荐购已下订未开票用户所对应的推荐人
select distinct ti.invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-10-01'
;

--11-7-1 过去三个月点击过【我要卖车】Button的用户
select distinct t1.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur t1
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and a.client_time >= '2024-08-21'
	and event_key = 'Button_click' 
	and var_btn_name = '我要卖车'
	and length(a.`user`)<9
	group by `user`
	) t2 
on toString(t1.cust_id) = toString(t2.distinct_id)
where t1.is_deleted = 0 and t1.member_status <> '60341003'
;

--11-7-2 历史在社区发帖/评论中发表过的内容中，包含“ 外地旅游”或“租车”这两个关键词的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join (
	select tp.member_id 
	from community.tm_post tp 
	left join community.tt_post_material tpm on tp.post_id = tpm.post_id
	where tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
	and (tp.post_title like '%外地旅游%' or tp.post_title like '%租车%' 
		or tpm.node_content like '%外地旅游%' or tpm.node_content like '%租车%')
	union 
	select tc.member_id 
	from community.tm_comment tc 
	where tc.is_deleted <> 1
	and (tc.comment_content like '%外地旅游%' or tc.comment_content like '%租车%')
	) tt on tmi.id = tt.member_id 
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
;


-- 参与过23年会员日4次以上，但未参与24年10月会员日的车主
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and a.event_key='Page_entry' 
	and a.client_time>='2023-01-01' and a.client_time < '2024-01-01'
	and ((a.client_time < '2023-12-01' and var_page_title<>'12月会员日' and (var_page_title like '%会员日' OR var_page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
		or (a.client_time >= '2023-12-01' and var_page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
	and var_page_title not like '%WOW%'
	and length(`user`)<9
	group by `user`
	having count(distinct var_page_title) > 4
	) t1 
on toString(m.cust_id)=toString(t1.distinct_id) 
left join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name = '2024年10月会员日'
	and var_page_title = '10月会员日'
	and length(`user`)<9
	and a.client_time>='2024-10-01'
	group by `user`
	) t2 
on t1.distinct_id=t2.distinct_id
where ifnull(t2.distinct_id, '') = ''
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;







select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur
inner join (
	select `user` as distinct_id, count(distinct var_page_title)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and a.event='Page_entry' 
	and a.client_time>='2023-01-01' and a.client_time < '2024-01-01'
	and ((a.client_time < '2023-12-01' and var_page_title<>'12月会员日' and (page_title like '%会员日' OR page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
		or (a.client_time >= '2023-12-01' and var_page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
	and page_title not like '%WOW%'
	and length(`user`)<9
	having count(distinct var_page_title) > 4
	) t1 
on toString(m.cust_id)=toString(a.distinct_id) 
left join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name = '2024年8月会员日'
	and var_page_title = '8月会员日'
	and length(`user`)<9
	and a.client_time>='2024-08-01'
	group by `user`
	) t2 
on t1.distinct_id=t2.distinct_id
where nvl(t2.distinct_id, '') <> ''
and m.is_deleted = 0 and m.member_status <> '60341003'

-- 
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name = '2024年8月会员日'
	and var_page_title = '8月会员日'
	and length(`user`)<9
	and a.client_time>='2024-08-01'
	group by `user`

-- 1-9-2 23年累计参加过3次及以上会员日的粉丝用户
select m.member_phone "手机号"
from ods_rawd.ods_rawd_events_d_di a
inner join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id)=toString(a.distinct_id)  
where 1=1
and a.event='Page_view' 
and a.date>='2023-01-01' and a.date < '2024-01-01'
and ((a.date < '2023-12-01' and page_title<>'12月会员日' and (page_title like '%会员日' OR page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
	or (a.date >= '2023-12-01' and page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
and page_title not like '%WOW%'
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib in('MiniProgram') or channel ='Mini'))
and length(distinct_id)<9
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
group by m.member_phone
having count(distinct page_title) >= 3
;


-- 11-12-1 近3年的开票车主中，2024年1月至今没有在线预约养修的车主用户，（剔除24年7-10月有回厂记录）
select distinct tmi.id member_id 
from vehicle.tt_invoice_statistics_dms kp 
inner join (
	select member_id, vin_code
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	) vr on vr.vin_code = kp.vin and vr.rn=1
inner join `member`.tc_member_info tmi on vr.member_id = tmi.id
left join (
	select ta.CUSTOMER_PHONE
	from cyx_appointment.tt_appointment  ta
	left join cyx_appointment.tt_appointment_maintain tam 
	on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
	where ta.CREATED_AT >= '2024-01-01'   -- 时间
	and ta.DATA_SOURCE = 'C'
	and ta.APPOINTMENT_TYPE = '70691005'   -- 养修预约
	group by 1
	) t1 on tmi.member_phone = t1.CUSTOMER_PHONE
left join (
	select a.vin
	from cyx_repair.tt_repair_order a 
	where a.is_deleted = 0 and a.ro_status = 80491003 -- (已结算)的工单
	and a.ro_create_date >= '2024-07-01' and a.ro_create_date < '2024-11-01'
	group by 1
	) t2 on kp.vin = t2.vin
where kp.invoice_date >= '2021-11-28' 
and t1.CUSTOMER_PHONE is null 
and t2.vin is null 
and tmi.is_vehicle = 1
and tmi.is_deleted = 0 and tmi.member_status <> 60341003
;

-- 11-13-1 2024年粉丝浏览过预约试驾页面，但未留资的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key = 'Page_entry'
	and var_page_title = '预约试驾页'
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-01-01'
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where 1=1
and ifnull(t2.mobile, '') = ''
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-1-1
-- 1、2024年8月至今浏览过三师tab页、三师推荐购页面的车主；
-- 2、2024年4月至今浏览过守护计划tab的车主；
-- 3、2023年至今商城下单过【趣味童年】精品系列的车主+粉丝；
-- 4、2023年至今商城下单过【麋鹿】精品系列的车主+粉丝；"
-- 1) 2024年8月至今浏览过三师tab页、三师推荐购页面的车主；
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	and client_time >= '2024-08-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct 
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'mYKS40ByaO' and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' and m.is_deleted =0 
and m.is_vehicle = 1
union distinct
-- 2) 2024年4月至今浏览过守护计划tab的车主
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '沃尔沃汽车守护日'
	and client_time >= '2024-04-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct
-- 3) "2023年至今商城下单过【趣味童年】精品系列的车主+粉丝、2023年至今商城下单过【麋鹿】精品系列的车主+粉丝"
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2023-01-01'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	and (
		b.sku_code in (
		-- 趣味童年
		'32355410'
		,'32284955'
		,'32355422'
		,'32284975'
		,'32355423'
		,'32421190'
		,'32421191'
		,'32421192'
		,'32421193'
		,'32421194'
		,'32421195'
		,'32421196'
		,'32421197'
		,'32421198'
		,'32421199'
		,'32284514'
		,'32284515'
		,'32284516'
		,'32284517'
		,'32284518'
		,'32284519'
		,'32284520'
		,'32284521'
		,'32284522'
		,'32284523'
		,'32284743'
		,'32284744'
		,'32284745'
		,'32284746'
		,'32284747'
		,'31422684'
		,'32284630'
		,'31422835'
		,'31422830'
		,'31422840'
		,'31422836'
		,'31422831'
		,'31422841'
		,'31422837'
		,'31422832'
		,'31422842'
		,'31422838'
		,'31422833'
		,'31422843'
		,'31422839'
		,'31422834'
		,'31422844'
		,'32355229'
		,'32355230'
		,'32284629'
		,'32284705'
		,'32284706'
		,'32284707'
		,'32284708'
		,'32355989'
		,'32355990'
		,'32355991'
		,'32355992'
		,'32355993'
		,'32355566'
		,'32355567'
		,'32355568'
		,'32355569'
		,'32355570'
		,'32355571'
		,'32355572'
		,'32355573'
		,'32355574'
		,'32355575'
		,'32355231'
		,'31110265'
		,'31110266'
		,'31110267'
		,'31110268'
		,'31422812'
		,'31422631'
		,'31422632'
		,'31422633'
		,'31422634'
		,'31422635'
		,'31422638'
		,'31422639'
		,'31422640'
		,'31422641'
		,'31422642'
		,'32284614'
		,'32284615'
		,'32284616'
		,'32284617'
		,'32284618'
		,'32284619'
		,'32355235'
		,'32355236'
		,'32355237'
		,'32355238'
		,'32355239'
		,'32355240'
		,'32355241'
		,'32355303'
		,'32355304'
		,'32355305'
		,'32355306'
		,'32355307'
		,'32284632'
		,'32355599'
		,'32355600'
		,'32355601'
		,'32355602'
		,'32355603'
		,'32355604'
		,'32355605'
		,'32355606'
		,'32355607'
		,'32355608'
		,'31422932'
		,'32421240'
		) 
		or b.sku_code in (
		-- 麋鹿
		'31422675'
		,'31422676'
		,'31422808'
		,'32284458'
		,'32421079'
		,'32421080'
		,'32355422'
		,'32355423'
		,'32284975'
		,'32421161'
		,'32421162'
		,'32421164'
		,'32421165'
		,'32421163'
		,'32421291'
		)
		)
	group by 1
	) od
on toString(m.id) = toString(od.member_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;



-- 12-2-1 半年内参与过话题发帖的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time + '6 month' >= '2024-12-09'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 12-5-1 "1、近4个月内App+小程序累计登录3天以上的【非车主】(剔除1个月内留资的用户）；2、2024年1月-12月社区内发过UGC内容的粉丝"
-- 近4个月内App+小程序累计登录3天以上的【非车主】(剔除1个月内留资的用户）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, count(distinct dt)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-08-09'
	and ((`$platform` = 'MinP' or var_channel ='Mini') or ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'))
	group by 1 having count(distinct dt) > 3
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select mobile, max(create_time) last_create_time
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-11-09'
	group by 1
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where 1=1
and ifnull(t2.mobile, '') = ''
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
-- 2024年1月-12月社区内发过UGC内容的粉丝
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type = 1007   -- UGC文章
and tp.create_time >= '2024-01-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.is_vehicle = 0
;


-- 12-8-1 24年5月1日起，浏览过沃尔沃汽车App或沃尔沃汽车沃世界小程序预约试驾+邀约试驾+车型专区+购车页面，且未提交试驾申请的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-05-01'
	and event_key = 'Page_entry'
	and var_page_title in ('预约试驾页', '推荐购_邀请好友', '车型详情', '购车')
	and ((`$platform` = 'MinP' or var_channel ='Mini') or ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'))
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
 	select distinct user_member_id
 	from ods_cyap.ods_cyap_tt_appointment_d  ta
 	where ta.CREATED_AT >= '2024-05-01' 
 	and ta.DATA_SOURCE = 'C'
 	and ta.APPOINTMENT_TYPE = '70691002'   -- 预约试乘试驾
	) t2 
on toString(m.id) = toString(t2.user_member_id)
where 1=1
and ifnull(t2.user_member_id, '') = ''
and m.is_deleted = 0 and m.member_status <> '60341003'
and m.member_time >= '2023-07-01'
;


-- 12-9-1 "1、24年1-11月建立过邀请关系（被推荐人没购车）的推荐人 2、2024年成功推荐2次及以上的车主"
select distinct tt.member_id
from `member`.tc_member_info m
inner join (
	-- 24年1-11月建立过邀请关系（被推荐人没购车）的推荐人
	select invite_member_id as member_id
	from invite.tm_invite_record a
	where a.is_deleted = 0 
	and create_time >= '2024-01-01' and create_time < '2024-12-01'
	and (order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
	union 
	-- 2024年成功推荐2次及以上的车主
	select invite_member_id as member_id
	from invite.tm_invite_record ti
	where is_deleted = 0 
	and create_time >= '2024-01-01'
	group by 1
	having count(*) >= 2
	) tt on m.id = tt.member_id 
where m.is_deleted = 0 and m.member_status <> 60341003
and m.is_vehicle=1
;


-- 12-11-1 活动开始前1个月活跃用户（活动开始时间：12月20日）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-11-20'
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 12-12-1 近3个月仅在小程序活跃车主
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-09-16'
	and (`$platform` = 'MinP' or var_channel ='Mini')
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-09-16'
	and ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App')
	group by 1
	) t2 
on toString(t1.distinct_id) = toString(t2.distinct_id)
where 1=1
and ifnull(t2.distinct_id, '') = ''
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-13-1 最后一次活跃时间在24年7、8、9月的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, max(client_time)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-07-01'
	group by 1 
	having max(client_time) < '2024-10-01'
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-14-1 最后一次活跃时间在24年6月的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, max(client_time)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-06-01'
	group by 1 
	having max(client_time) < '2024-07-01'
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-15-1 "1、24年活跃过且浏览过商城页面的车主用户,2、参与过23年任意一期会员日但未参与过24年会员日活动的车主用户"
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	group by 1 
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	and event_key in ('Mall_category_list_view','Page_view','Button_click','$MPViewScreen')
	and (var_page_title in ('商城','商城首页') or `$title`='商城')
	group by 1
	) t2 
on toString(t1.distinct_id) = toString(t2.distinct_id)
where 1=1
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
-- 2、参与过23年任意一期会员日但未参与过24年会员日活动的车主用户
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and a.event_key='Page_view' 
	and a.client_time>='2023-01-01' and a.client_time < '2024-01-01'
	and ((a.client_time < '2023-12-01' and var_page_title<>'12月会员日' and (var_page_title like '%会员日' OR var_page_title = '525车主节')) -- 2023年5月的会员日叫作车主节
		or (a.client_time >= '2023-12-01' and var_page_title = '12月会员日')) -- 2022年12月会员日 会通过其他渠道进入产生脏数据
	and var_page_title not like '%WOW%'
	and length(`user`)<9
	group by `user`
	) t1 
on toString(m.cust_id)=toString(t1.distinct_id) 
left join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	) t2 
on t1.distinct_id=t2.distinct_id
where ifnull(t2.distinct_id, '') = ''
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-16-1 "浏览秋冬服页未下单用户+获得优惠券且未核销用户"
select m.id as member_id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_activity_name in ('2024年沃尔沃汽车服务节', '2024年售后沃尔沃汽车服务节')
	and client_time >= '2024-11-25'
	group by user
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select a.user_id as member_id 
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
	left join (
		-- 退单明细
		select so.refund_order_code, so.order_code, sp.product_id,
			case when so.status = '51171001' then  '待审核' 
				when so.status = '51171002' then  '待退货入库' 
				when so.status = '51171003' then  '待退款' 
				when so.status = '51171004' then  '退款成功' 
				when so.status = '51171005' then  '退款失败' 
				when so.status = '51171006' then  '作废退货单'
				else null end `退货状态`,
			sum(sp.sales_return_num) `退货数量`,
			sum(so.refund_point) `退回V值`,
			max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1 and so.is_deleted = '0' and sp.is_deleted = '0'
		and so.status = '51171004'     -- 退款成功
		GROUP BY 1,2,3,4
		) h 
	on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >= '2024-11-25'
	and a.is_deleted <> 1 and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
	group by 1
	) t2
on toString(m.id) = toString(t2.member_id)
where 1=1
and ifnull(t2.member_id, '') = '' 
and m.is_deleted = 0 and m.member_status <> '60341003'
union distinct 
-- 获得优惠券且未核销用户
select tmi.id as member_id  
FROM ods_coup.ods_coup_tt_coupon_detail_d a
inner join ods_memb.ods_memb_tc_member_info_cur tmi on toString(a.member_id) = toString(tmi.id) 
and a.is_deleted =0 and a.ticket_state = 31061001
and a.coupon_id in (8172, 8157, 8158)
where tmi.member_status <> '60341003' and tmi.is_deleted = 0
;

-- 12-17-1 11、12月已下订未开票推荐人
select invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-11-01'
;

-- 12-17-2 11、12月已下订未开票的被推荐人
select be_invite_member_id as member_id
from invite.tm_invite_record ti
where is_deleted = 0 
and ti.order_no is not null 
and order_status <> '14041009'
and ti.invoice_no is null 
and vin is null
and create_time >= '2024-11-01'
;

-- 12-18-1 24年参与过会员日的车主
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d  a 
	where 1=1
	and a.event_key='Page_entry' 
	and a.var_activity_name like '2024年%'
	and (var_page_title like '%会员日' OR var_page_title = '525车主节')
	and length(`user`)<9
	and a.client_time>='2024-01-01'
	group by `user`
	) t1
on toString(m.cust_id)=toString(t1.distinct_id) 
where 1=1
and m.is_vehicle = 1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 12-19-1 最后一次活跃时间在24年3、4、5月的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, max(client_time)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-03-01'
	group by 1 
	having max(client_time) < '2024-06-01'
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-20-1 最后一次活跃时间在24年1、2月的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id, max(client_time)
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-01-01'
	group by 1 
	having max(client_time) < '2024-03-01'
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 12-21-1 今年内参与过话题发帖的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time >= '2024-01-01'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;

-- 12-25-1 2024/12/26-2024/12/30参与过心愿瓶活动的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and LENGTH(a.`user`)<9
	and a.event_time >= '2024-12-26' 
	and a.client_time >='2024-12-26' and a.client_time <'2025-01-02' 
	and event_key='Page_entry'
	and var_page_title ='沃尔沃汽车双旦会员日_漂流瓶'
	and var_activity_name='2024年12月沃尔沃汽车双旦会员日'
	group by `user`
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 12-22-1 访问过app活动 2024年益起走活动页面的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and LENGTH(a.`user`)<9
	and a.client_time >='2024-01-01'
	and event_key='Page_entry'
	and var_page_title ='守护计划益起走活动'
	and var_activity_name='2024年4月守护计划益起走活动'
	group by `user`
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 12-26-1 2024年1月至2025年12月新绑车车主
select distinct tmi.id as member_id
from `member`.tc_member_info tmi
inner join (
	select member_id, vin_code, bind_date
		,row_number ()over(partition by vin_code order by bind_date desc) rn 
	from volvo_cms.vehicle_bind_relation  
	where deleted=0 and is_bind=1 and is_owner=1
	and bind_date >= '2024-01-01'
	) vr on vr.member_id = tmi.id and vr.rn = 1
where tmi.is_vehicle=1
and tmi.is_deleted = 0 
and tmi.member_status <> 60341003
;

-- 12-27-1 浏览过推荐购页面的车主
select distinct tmi.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur tmi
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '推荐购_邀请好友'
	group by user
	) t1 
on toString(t1.distinct_id) = toString(tmi.cust_id)
where tmi.is_vehicle = 1
and tmi.is_deleted=0 and tmi.member_status <> '60341003'
;

-- 12-28-1 所有俱乐部车主
select distinct jlb.member_id as member_id 
from (
	select distinct b.member_id, a.content, b.create_time 
	from community_club.tt_club_attr_audit a --俱乐部信息表
	left join community_club.tr_club_friends b on a.club_id=b.club_id and b.is_deleted = 0 --俱乐部成员信息表
	where 
	--to_date(b.create_time)  BETWEEN '2024-01-01' and '2024-05-14'
	a.attr_type  = '10010'--俱乐部信息 10010俱乐部名称
	and a.is_deleted = 0
	and a.audit_status = '10030'--审核状态 已通过
	) jlb
left join `member`.tc_member_info lm on jlb.member_id = lm.id and lm.MEMBER_STATUS <> 60341003 and lm.IS_DELETED = 0
where lm.is_vehicle = '1' --车主
;

--12-29-1 参与过推荐购活动的白金卡和黑卡车主
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join invite.tm_invite_record tv on tmi.id=tv.invite_member_id and tv.is_deleted = 0 
where tmi.is_vehicle=1
and tmi.is_deleted = 0 
and tmi.member_status <> 60341003
and tmi.member_level >= 3
;


-- 1-1-1 24年内参与过话题发帖的用户
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type in (1001, 1007)   -- 动态，UGC文章
and tp.create_time >= '2024-01-01' and tp.create_time < '2025-01-01'
inner join community.tr_topic_post_link tpl on tp.post_id = tpl.post_id
where tmi.is_deleted = 0
and tmi.member_status <> 60341003
;


-- 1-2-1 2024年浏览过试驾享好礼、预约试驾页面、一键留资的全量用户（近30天内无试驾记录）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select `user` as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1 
	and LENGTH(a.`user`)<9
	and a.client_time >='2024-01-01'
	and a.client_time < '2025-01-01'
	and event_key='Page_entry'
	and var_page_title in ('试驾享好礼', '预约试驾页', '内容详情_留资弹窗', '内容详情_一键留资弹窗', '购车_一键留资弹窗', 'AR看车_一键留资弹窗')
	group by `user`
	) t1 
on toString(t1.distinct_id) = toString(m.cust_id)
left join (
	select MOBILE as mobile
	from ods_drse.ods_drse_tt_testdrive_plan_d
	where IS_DELETED = 0 and DRIVE_S_AT >= '2024-12-13'
	group by MOBILE
	) t2 
on m.member_phone = t2.mobile
where ifnull(t2.mobile, '') = ''
and m.is_deleted = 0 and m.member_status <> '60341003'
;

-- 1-2-2 2024年领取过会员权益的粉丝会员（且近30天内无试驾记录）
select distinct m.id as member_id 
from member.tc_member_info m 
inner join member_rights.tt_member_get_record gr on gr.member_id  = m.id and gr.is_deleted = 0
and gr.create_time >= '2024-01-01' and gr.create_time < '2025-01-01'
inner join member_rights.tc_member_rights_config config on gr.rights_config_id= config.id
inner join member_rights.tm_member_rights rights on config.rights_id= rights.id
left join (
	select MOBILE as mobile
	from drive_service.tt_testdrive_plan
	where IS_DELETED = 0 and DRIVE_S_AT >= '2024-12-13'
	group by MOBILE
	) t1 
on m.member_phone = t1.mobile
where ifnull(t1.mobile, '') = ''
and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
;


-- 1-2-3 2024年社区内发过UGC内容的车主
select distinct tmi.id as member_id 
from `member`.tc_member_info tmi
inner join community.tm_post tp on tmi.id = tp.member_id 
and tp.is_deleted <> 1 and tp.post_type = 1007   -- UGC文章
and tp.create_time >= '2024-01-01'
and tp.create_time < '2025-01-01'
where tmi.is_deleted = 0 and tmi.member_status <> 60341003
and tmi.is_vehicle = 1
;



-- 1-3-1 2024年8月至今浏览过三师tab页、三师推荐购页面的车主
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	and client_time >= '2024-08-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct 
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'mYKS40ByaO' and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' and m.is_deleted =0 
and m.is_vehicle = 1
;


-- 1-3-2 2024年4月至今浏览过守护计划tab的车主
select m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '沃尔沃汽车守护日'
	and client_time >= '2024-04-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
;


-- 1-6-1 近 1 个月 APP & 小程序活跃用户人群
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and a.client_time >= '2024-12-16'
	and ((`$platform` = 'MinP' or var_channel ='Mini') or ((`$platform` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or var_channel ='App'))
	group by 1
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
;


--1-9-2 小程序注册，App未注册车主
select distinct memberid
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and min_app is null -- App未注册
and min_mini is not null  -- 小程序注册
and is_vehicle ='1'-- 车主

-- 1-9-3 参与过2024年2次及以上会员日活动的用户
	select 
	distinct m2.id memberid
--	count(distinct var_page_title) num 
	from ods_gio.ods_gio_event_d m
	join 
	(-- 清洗
		select m.id id,m.cust_id cust_id,is_vehicle
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
	and event_time>'2024-01-01'
	and m.client_time <'2025-01-01'
	and m.client_time >='2024-01-25'
	and event_key in('Page_view','Page_entry')
	and var_page_title in ('1月会员日','2月会员日','3月会员日','4月会员日'
		,'525车主节','6月会员日','7月会员日','8月会员日'
		,'9月会员日','10月会员日','11月会员日','沃尔沃汽车双旦会员日')
	and left(var_activity_name,4)='2024'
	group by 1
	having count(distinct var_page_title) >= 2
--	order by num desc 
	
--2-3-1
select distinct x.member_id
from 
(
--25年1月新注册但未留资的用户
select distinct m.id::String as member_id 
from  (
--25年1月新注册
	select distinct id
	,cust_id
	,member_phone
	from ods_memb.ods_memb_tc_member_info_cur m
	where 1=1
	and m.create_time >='2025-01-01'
	and m.create_time <'2025-02-01'
	and m.is_deleted =0
	and m.member_status<>'60341003' 
	) m 
left join (
	select mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2024-01-01'
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where 1=1
--and ifnull(t2.mobile, '') = ''
and t2.mobile is null -- 未留资的用户
union all 
--25年1月领取过会员权益，且近30天未留资的用户
select distinct m.id::String as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_meri.ods_meri_tt_member_get_record_d gr on gr.member_id  = m.id and gr.is_deleted = 0 and gr.create_time >= '2025-01-01' and gr.create_time < '2025-02-01'
inner join ods_meri.ods_meri_tc_member_rights_config_d config on gr.rights_config_id= config.id
inner join ods_meri.ods_meri_tm_member_rights_d rights on config.rights_id= rights.id
left join (
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 
	and toDate(create_time) >=toDate(now()) - INTERVAL 30 day
	and toDate(create_time) < toDate(now())
	) t1 
on m.member_phone = t1.mobile
where ifnull(t1.mobile, '') = '' -- 近30天未留资的用户
--and m.is_vehicle = 0
and m.is_deleted = 0 and m.member_status <> '60341003'
union all 
--25年1月有3天及以上签到记录，且近30天未留资的用户
select 
distinct aa.member_id::String member_id
--,aa.member_phone
--,bb.mobile
from 
(
	select a.member_id member_id, b.member_phone member_phone, count(*) sign_cnt
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	inner join ods_memb.ods_memb_tc_member_info_cur b on a.member_id::String = b.id::String
	and b.is_deleted='0' and b.member_status<>'60341003'
	WHERE a.is_deleted = '0'
	and a.create_time >=  '2025-01-01'  
	and a.create_time <  '2025-02-10'  
	group by 1,2
	having count(*) >= 3
)aa
left join 
(
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 
	and toDate(create_time) >=toDate(now()) - INTERVAL 30 day
	and toDate(create_time) < toDate(now())
	)bb on aa.member_phone=bb.mobile
where bb.mobile is null 
and aa.member_id is not null
union all 
--近60天已进行一键留资但未生成线索的用户
select
distinct aa.id::String member_id
--,aa.customer_mobile
--,bb.mobile
from 
(
SELECT  m.id id,tlcp.customer_mobile,tlcp.create_time
from ods_vced.ods_vced_tm_leads_collection_pool_d tlcp
left join ods_memb.ods_memb_tc_member_info_cur m on  toString(tlcp.customer_mobile) = toString(m.`member_phone`)  and m.member_status <> '60341003'  and m.is_deleted =0-- 会员表(获取会员信息) 
where date(tlcp.create_time) >=  date_sub(date('2025-02-10'),60) 
and date(tlcp.create_time) <  '2025-02-10'  
and trim(tlcp.campaign_code) in( 
select distinct  trim(lz.code) 
from ods_oper_crm.ods_oper_crm_umt001_em90_his_d lz where trim(lz.channel) = '一键留资'
and date(concat(left(`_data_inlh_date`,4),'-',right(left(`_data_inlh_date`,6),2),'-',right(`_data_inlh_date`,2))) = yesterday()
)
)aa
left join 
(
    select  t1.id id,t1.clue_id clue_id,t1.one_id one_id,t1.mobile mobile,toDateTime(left(t1.create_time,19)) create_time
	from ods_cust.ods_cust_tt_clue_clean_cur  t1
	where t1.is_deleted = 0
	and date(t1.create_time) >=  date_sub(date('2025-02-10'),60) 
	and date(t1.create_time) <  '2025-02-10' 
--	and  t1.mobile='18723230855'
)bb on aa.customer_mobile= bb.mobile
where 1=1
--and aa.create_time <>bb.create_time
and bb.mobile is null 
and aa.id is not null
--settings join_use_nulls=1
)x


--2024年12月-2025年1月参与签到的车主用户
--2024年至今领取过会员权益的车主
--2024年参与过推荐购短促活动的车主

--2-5-1 24年11月-25年1月签到过，2月还没签到的用户
select 	
distinct a.member_id
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join (
--2月签到的用户
	select 	
	distinct 
	a.member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2025-02-01' 
	and a.create_time <'2025-02-15' 
	and a.is_deleted = '0'
)x on x.member_id=a.member_id
WHERE 1=1
and a.create_time >= '2024-11-01' 
and a.create_time <'2025-02-01' 
and a.is_deleted = '0'
and x.member_id ='' -- 2月还没签到的用户

--浏览过2月复工活动活动文章未下单用户 + 8871&8872卡券未核销的用户
--（1、活动文章ID：iVwZqmBBel
--2、商城精品20元无门槛抵扣券：8871
--3、商城精品满300元减80元优惠券：8872）
-- 1、商城订单明细(CK)
select
distinct x.member_id::String member_id
from (-- 浏览会员日活动
			-- 帖子的PVUV
		select distinct a.member_id member_id
		from ods_cmnt.ods_cmnt_tt_view_post_cur a
		where 1=1
		and a.create_time >='2025-01-21'
		and a.create_time <'2025-02-14'
		and a.is_deleted =0
		and a.post_id ='iVwZqmBBel'
		and member_id <>'0'
	)x 
left join 
	(
	-- 下单用户
	select distinct a.user_id user_id
	from ods_orde.ods_orde_tt_order_d a     -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
	left join
	(
		-- 退单明细
		select
		so.refund_order_code,
		so.order_code,
		sp.product_id,
		case when so.status = '51171001' then  '待审核' 
			when so.status = '51171002' then  '待退货入库' 
			when so.status = '51171003' then  '待退款' 
			when so.status = '51171004' then  '退款成功' 
			when so.status = '51171005' then  '退款失败' 
			when so.status = '51171006' then  '作废退货单'
			else null end `退货状态`,
		sum(sp.sales_return_num) `退货数量`,
		sum(so.refund_point) `退回V值`,
		max(so.create_time) `退回时间`
		from ods_orde.ods_orde_tt_sales_return_order_d so
		left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
		where 1=1
		and so.status = '51171004'     -- 退款成功
		and so.is_deleted = '0'
		and sp.is_deleted = '0'
		GROUP BY 1,2,3,4
	) h on a.order_code = h.order_code and b.product_id = h.product_id
	where 1=1
	and a.create_time >='2025-01-21' 
	and a.create_time <'2025-02-14'-- 订单时间
	and a.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and h.order_code is null  -- 剔除退款订单
)x2  on toString(x.member_id) =toString(x2.user_id)
where x2.user_id is null  -- 未下单用户
union all 
-- 8871&8872卡券未核销的用户
	select
	distinct tcd.member_id::String member_id
--	        CASE tcd.ticket_state
--            WHEN 31061001 THEN '已领用'
--            WHEN 31061002 THEN '已锁定'
--            WHEN 31061003 THEN '已核销' 
--            WHEN 31061004 THEN '已失效'
--            WHEN 31061005 THEN '已作废'
--            END AS `卡券状态`
	from ods_coup.ods_coup_tt_coupon_detail_d tcd -- 
--	left join ods_memb.ods_memb_tc_member_info_cur tmi on tcd.one_id = tmi.cust_id  -- 会员表
	where 1=1
	 and tcd.ticket_state = '31061001'   -- 卡券状态：已领用未核销
	 and tcd.coupon_id in ('8871','8872')
	 and tcd.is_deleted = 0


--2024年8月至今浏览过三师tab页、三师推荐购页面的车主
select m.id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '三师圈'
	and client_time >= '2024-08-01'
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1
union distinct 
select m.id
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'mYKS40ByaO' and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' and m.is_deleted =0 
and m.is_vehicle = 1

union distinct 

--2024年4月至今浏览过守护计划tab的车主
select distinct m.id
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and length(a.user) < 9
	and event_key = 'Page_entry'
	and var_page_title = '沃尔沃汽车守护计划'
	and client_time >= '2024-04-01'
--	order by 2 desc
	) t 
on toString(m.cust_id) = toString(t.distinct_id)
where m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle = 1

union distinct 

--2024年7月1日起至今邀请好友成功购车的车主
select distinct ti.invite_member_id "member_id"
from ods_invi.ods_invi_tm_invite_record_d ti
where is_deleted = 0 
and (ti.order_no is not null 
and order_status not in ('14041009', '14041013', '14041012', '14041011'))
and create_time >= '2024-07-01'

union distinct 

--2024年7月1日起至今邀请好友购车不成功的车主 
select distinct ti.invite_member_id "member_id"
from ods_invi.ods_invi_tm_invite_record_d ti
where is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
and create_time >= '2024-07-01'


--浏览过“送给孩子们的一堂安全启蒙课”这个活动报名页面的车主用户
--链接：https://mweb.digitalvolvo.com/mweb/activity/detail/M1K4kMJW2b?postType=1006
select distinct m.id
from ods_memb.ods_memb_tc_member_info_cur m
inner join ods_cmnt.ods_cmnt_tt_view_post_cur t on toString(m.id) = toString(t.member_id)
and t.post_id = 'M1K4kMJW2b' 
--and t.create_time >= '2024-08-01'
where m.member_status <> '60341003' 
and m.is_deleted =0 
and m.is_vehicle = 1

--M1K4kMJW2b


--3-8-1  24年12月-25年2月签到过，3月还没签到的用户
select 	
distinct a.member_id
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join (
--3月签到的用户
	select 	
	distinct 
	a.member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2025-03-01' 
	and a.create_time <'2025-03-11' 
	and a.is_deleted = '0'
)x on x.member_id=a.member_id
WHERE 1=1
and a.create_time >= '2024-12-01' 
and a.create_time <'2025-03-01' 
and a.is_deleted = '0'
and x.member_id ='' -- 3月还没签到的用户


--3-12-1 注册小程序未注册APP车主（去重）
select distinct memberid
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and min_app is null -- App未注册
and min_mini is not null  -- 小程序注册
and is_vehicle ='1'-- 车主

--3-12-2 24个月内回过厂的车主
select distinct m.id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select *, row_number ()over(partition by vin_code order by bind_date desc) rn 
	from ods_vocm.ods_vocm_vehicle_bind_relation_cur
	where deleted=0 and is_bind=1 and is_owner=1
	) vr on toString(vr.member_id) = toString(m.id) and vr.rn = 1
inner join (
	select distinct VIN
	from ods_cyre.ods_cyre_tt_repair_order_d octrod  
	WHERE IS_DELETED = 0 AND RO_CREATE_DATE >= '2023-03-14'
	AND REPAIR_TYPE_CODE <> 'P'
	AND RO_STATUS = 80491003 -- (已结算)的工单
	group by 1
	) t2 on vr.vin_code = t2.VIN 
where m.is_deleted = 0 and m.member_status <> '60341003'

--3-12-3 一年内登录过小程序的车主
select distinct memberid
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and max_mini >=toDate(now()) - interval '1'year -- 一年内登录过小程序
and is_vehicle ='1'-- 车主


--2024年10-12月邀请好友留资，但最终好友未购车的推荐人车主
select distinct 
ti.invite_member_id `推荐人会员ID`
from invite.tm_invite_record ti
--inner join `member`.tc_member_info m on m.id = ti.invite_member_id 
where ti.is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
and ti.create_time >= '2024-10-01'
and ti.create_time < '2025-01-01'
and ti.invite_member_id is not null 
--and m.is_vehicle=1

--select * from dictionary.tc_code tc  where code_id in ('14041009', '14041013', '14041012', '14041011')
--2024年绑车但未参与推荐购活动的车主
select distinct tmi.id `member_id`
--tmi.member_phone "手机号"
from "member".tc_member_info tmi
inner join (
	select vr.*
	from (
		select member_id, vin_code, bind_date
			,row_number ()over(partition by vin_code order by bind_date desc) rn 
		from volvo_cms.vehicle_bind_relation  
		where deleted=0 and is_bind=1 and is_owner=1
		) vr
	where vr.rn=1
	and bind_date >= '2024-01-01' and bind_date < '2025-01-01'
	) t1 
on tmi.id = t1.member_id 
left join (
	select invite_member_id
	from invite.tm_invite_record
	where is_deleted = 0
	group by 1
	) t2 
on tmi.id = t2.invite_member_id
where t2.invite_member_id is null 
and tmi.MEMBER_STATUS <> 60341003 
and tmi.IS_DELETED = 0
and tmi.is_vehicle = 1 --车主
and tmi.id is not null

--近1个月APP/小程序活跃用户
select distinct memberid
from ods_oper_crm.ods_oper_crm_active_gio_d_si 
where 1=1
and dt<'2025-03-11'
and dt>= '2025-02-11'

--2024年至今发布动态≥20字且配图1张的用户
-- 发帖明细
select 
distinct 
a.member_id 会员ID
from community.tm_post a
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join
(
		-- 发帖内容、图片
	select
	t.post_id,
	replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),' ','') as 发帖内容,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from
	(
		select
		tpm.post_id,
		tpm.create_time,
		replace(tpm.node_content,E'\\u0000','') 发帖内容,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where 1=1
--		and tpm.create_time >= '2023-11-06' and tpm.create_time < '2023-11-13'
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on a.post_id = pm.post_id
where a.is_deleted =0
and a.create_time >='2024-01-01'
and a.create_time <'2025-03-11'
--and l.topic_id ='1zeWlU2tjw' 
--and a.post_id='1zeWlU2tjw'
--and tmi.IS_VEHICLE = '1'-- 车主
and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=20 --帖子字数不少于20字
and pm.发帖图片数量>=1 -- 配图不少于1张的文章及动态
and a.post_type='1001'
--and datediff(a.create_time,tisd.invoice_date)<=365 -- 最后开票时间距发帖时间在一年以内
--and a.member_id ='6873815'
order by a.create_time

--2025年2月-3月11日24点参与过签到的人群
	select 	
	distinct 
	a.member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2025-02-01' 
	and a.create_time <'2025-03-12' 
	and a.is_deleted = '0'



--2025年1月&2月新注册未留资粉丝（剔除180天已留资人群）
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
left join (
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 and create_time >= '2025-01-01'
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where t2.mobile is null -- 未留资
and m.is_deleted = 0 and m.member_status <> '60341003'
and m.create_time >='2025-01-01' -- 2025年1月&2月新注册
and m.create_time <'2025-03-01'
and m.is_vehicle ='0' -- 粉丝
	
--留资时间在2024年9月1日-2025年2月28日的粉丝
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
join (
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 
	and create_time >= '2024-09-01'
	and create_time < '2025-03-01'
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where 1=1
and m.is_deleted = 0 and m.member_status <> '60341003'
and m.is_vehicle ='0'


--注册时间在2024年3月1日-8月30日，且从24年3月1日~至今未留资未试驾粉丝
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
left join (
	select distinct mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 
	and create_time >= '2024-03-01'
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where t2.mobile is null -- 未留资
and m.is_deleted = 0 and m.member_status <> '60341003'
and m.create_time >='2024-03-01' 
and m.create_time <'2024-09-01'
and m.is_vehicle ='0'




-- 近10天内浏览过预约试驾页、车型页面、一键留资等相关页面，但近10天未留资的用户
select distinct m.id as member_id 
from ods_memb.ods_memb_tc_member_info_cur m
inner join (
	select distinct user as distinct_id
	from ods_gio.ods_gio_event_d a
	where 1=1
	and date(a.event_time) >= date('2025-01-01')
	and length(a.user) < 9
	and toDate(a.client_time) >= toDate(now()) - interval '10' day
	and toDate(a.client_time) < toDate(now())
	and event_key = 'Page_entry'
	and (a.var_page_title like '%留资%' or a.var_page_title in ('AR看车_诚挚邀请您预约赏车弹窗','360看车_诚挚邀请您试驾弹窗','内容详情_留资弹窗')
		or a.var_page_title in ('试驾享好礼', '预约试驾页'))
--	and ((var_page_title in ('预约试驾页','内容详情_一键留资弹窗', '购车_一键留资弹窗', 'AR看车_一键留资弹窗')) 
--		or (var_page_title='购车' and var_car_type is not null ))
	) t1 
on toString(m.cust_id) = toString(t1.distinct_id)
left join (
	select mobile
	from ods_cust.ods_cust_tt_clue_clean_cur
	where is_deleted= 0 
	and toDate(create_time) >= toDate(now()) - interval 10 day
	and toDate(create_time) <toDate(now())
	group by 1 
	) t2 
on toString(m.member_phone) = toString(t2.mobile)
where 1=1
and ifnull(t2.mobile, '') = ''
--and t2.mobile is null   -- 未留资
and m.is_deleted = 0 
and m.member_status <> '60341003'


--注册小程序未注册APP车主（去重）
select distinct memberid
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and min_app is null -- App未注册
and min_mini is not null  -- 小程序注册
and is_vehicle ='1'-- 车主

--一年内登录过小程序的用户
select distinct memberid
from ods_oper_crm.ods_oper_crm_usr_gio_d_si
where 1=1
and max_mini >=toDate(now()) - interval '1'year -- 一年内登录过小程序
--and is_vehicle ='1'-- 车主

--1年内参加过推荐购的推荐人
select distinct ti.invite_member_id as member_id
from invite.tm_invite_record ti
where 1=1
and ti.is_deleted = 0 
and ti.create_time>=curdate() - interval '1'year 
and ti.create_time<curdate()


--1年前参加过推荐购的推荐人
select distinct ti.invite_member_id as member_id
from invite.tm_invite_record ti
where 1=1
and ti.is_deleted = 0 
and ti.create_time<curdate() - interval '1'year 


-- -- 专属权益：注册会员
select 
distinct var_memberId id
from ods_gio.ods_gio_event_d
where 1=1
and event_key='Button_click' -- $page
and `$query` like '%marathon-25%'
and event_time>='2025-01-01' 
and client_time>='2025-01-01'
and client_time<'2025-05-01'
and var_memberId is not null 

--25年1月-3月签过到的4月还没签到的用户
select 	
distinct a.member_id
FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
left join (
--4月
	select 	
	distinct 
	a.member_id
	FROM ods_mms.ods_mms_tt_sign_in_record_d a  -- 签到表
	WHERE 1=1
	and a.create_time >= '2025-04-01' 
	and a.create_time <'2025-04-11' 
	and a.is_deleted = '0'
)x on x.member_id=a.member_id
WHERE 1=1
and a.create_time >= '2025-01-01' 
and a.create_time <'2025-04-01' 
and a.is_deleted = '0'
and x.member_id ='' -- 4月还没签到的用户


--邀请好友留资过XC90，但最终好友未购车的车主
select distinct 
ti.invite_member_id `推荐人会员ID`
from invite.tm_invite_record ti
inner join `member`.tc_member_info m on m.id = ti.invite_member_id 
where ti.is_deleted = 0 
and (ti.order_no is null or order_status in ('14041009', '14041013', '14041012', '14041011'))
--and ti.create_time >= '2024-10-01'
--and ti.create_time < '2025-01-01'
and ti.invite_member_id is not null 
and ti.vehicle_name='XC90'
and m.is_vehicle=1