------------------------------- 3-1 【会员抽奖+膨胀券】卡券核销 Sheet -------------------------------

-- 1、卡券领用核销明细
select
count(case when a.卡券ID = '6736' then a.id else null end) "5元无门槛领取数",
count(case when a.卡券ID = '6736' and  a.卡券状态 = '已核销' then a.id else null end) "5元无门槛核销数",
round(count(case when a.卡券ID = '6736' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6738' then a.id else null end),5) "5元无门槛核销率",
count(case when a.卡券ID = '6738' then a.id else null end) "10元无门槛领取数",
count(case when a.卡券ID = '6738' and  a.卡券状态 = '已核销' then a.id else null end) "10元无门槛核销数",
round(count(case when a.卡券ID = '6738' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6738' then a.id else null end),5) "10元无门槛核销率",
count(case when a.卡券ID = '6737' then a.id else null end) "满200元减30元领取数",
count(case when a.卡券ID = '6737' and  a.卡券状态 = '已核销' then a.id else null end) "满200元减30元核销数",
round(count(case when a.卡券ID = '6737' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6737' then a.id else null end),5) "满200元减30元核销率",
count(case when a.卡券ID = '6729' then a.id else null end) "满100元减50元领取数",
count(case when a.卡券ID = '6729' and  a.卡券状态 = '已核销' then a.id else null end) "满100元减50元核销数",
round(count(case when a.卡券ID = '6729' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6729' then a.id else null end),5) "满100元减50元核销率",
count(case when a.卡券ID = '6730' then a.id else null end) "满100元减60元领取数",
count(case when a.卡券ID = '6730' and  a.卡券状态 = '已核销' then a.id else null end) "满100元减60元核销数",
round(count(case when a.卡券ID = '6730' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6730' then a.id else null end),5) "满100元减60元核销率",
count(case when a.卡券ID = '6731' then a.id else null end) "满100元减70元领取数",
count(case when a.卡券ID = '6731' and  a.卡券状态 = '已核销' then a.id else null end) "满100元减70元核销数",
round(count(case when a.卡券ID = '6731' and  a.卡券状态 = '已核销' then a.id else null end)/count(case when a.卡券ID = '6731' then a.id else null end),5) "满100元减70元核销率"
from
(
	select
	distinct
	a.id,
	b.id 卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	a.member_id 会员ID,
	m.is_vehicle 是否车主,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
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
	END AS 卡券状态,
	v.*
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id
	LEFT join
	(
		-- 卡券核销部分
		select v.coupon_detail_id
		,v.customer_name 核销用户名
		,v.customer_mobile 核销手机号
		,v.verify_amount 
		,IFNULL(v.dealer_code,v.dealer)  核销经销商
		,v.vin 核销VIN
		,v.operate_date 核销时间
		,v.order_no 订单号
		,v.PLATE_NUMBER
		from coupon.tt_coupon_verify v
		where v.is_deleted = 0
		order by v.create_time
	) v ON v.coupon_detail_id = a.id
	left join member.tc_member_info m on a.member_id = m.id and m.member_status <> 60341003 and m.is_deleted = 0
	where 1=1
	and b.id in ('6736','6738','6737','6729','6730','6731') -- 卡券ID
	and a.get_date >= '2024-05-15'
	and a.get_date < '2024-06-03'
	and a.is_deleted = 0
	-- and m.is_vehicle = 0    -- 筛选车主、粉丝
	order by a.get_date
) a



-- 2、精品膨胀券
select
count(distinct case when a.卡券ID = '6729' then a.会员ID else null end) "商城精品满100元减50元优惠券领取人数",
count(distinct case when a.卡券ID = '6729' and a.是否车主 = '1' then a.会员ID else null end) "商城精品满100元减50元优惠券领取车主人数",
count(distinct case when a.卡券ID = '6729' and a.是否车主 = '0' then a.会员ID else null end) "商城精品满100元减50元优惠券领取粉丝人数",
count(distinct case when a.卡券ID = '6730' then a.会员ID else null end) "商城精品满100元减60元优惠券领取人数",
count(distinct case when a.卡券ID = '6730' and a.是否车主 = '1' then a.会员ID else null end) "商城精品满100元减60元优惠券领取车主人数",
count(distinct case when a.卡券ID = '6730' and a.是否车主 = '0' then a.会员ID else null end) "商城精品满100元减60元优惠券领取粉丝人数",
count(distinct case when a.卡券ID = '6731' then a.会员ID else null end) "商城精品满100元减70元优惠券领取人数",
count(distinct case when a.卡券ID = '6731' and a.是否车主 = '1' then a.会员ID else null end) "商城精品满100元减70元优惠券领取车主人数",
count(distinct case when a.卡券ID = '6731' and a.是否车主 = '0' then a.会员ID else null end) "商城精品满100元减70元优惠券领取粉丝人数"
from
(
	select
	distinct
	a.id,
	b.id 卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	a.member_id 会员ID,
	m.is_vehicle 是否车主,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
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
	END AS 卡券状态,
	v.*
	FROM coupon.tt_coupon_detail a 
	JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id
	LEFT join
	(
		-- 卡券核销部分
		select v.coupon_detail_id
		,v.customer_name 核销用户名
		,v.customer_mobile 核销手机号
		,v.verify_amount 
		,IFNULL(v.dealer_code,v.dealer)  核销经销商
		,v.vin 核销VIN
		,v.operate_date 核销时间
		,v.order_no 订单号
		,v.PLATE_NUMBER
		from coupon.tt_coupon_verify v
		where v.is_deleted = 0
		order by v.create_time
	) v ON v.coupon_detail_id = a.id
	left join member.tc_member_info m on a.member_id = m.id and m.member_status <> 60341003 and m.is_deleted = 0
	where 1=1
	and b.id in ('6729','6730','6731') -- 卡券ID
	and a.get_date >= '2024-05-15'
	and a.is_deleted = 0
	-- and m.is_vehicle = 1    -- 筛选车主、粉丝
	order by a.get_date
) a



-- 获得优惠券人数-新老用户

新用户定义：浏览了525活动精品或膨胀券页面，5.15~5.31期间的注册用户，并且领取了满100-50、满100-60、满100-70的券的人。

-- 新用户领券
select
a.`卡券ID` `卡券ID`,
COUNT(DISTINCT a.`会员ID`) `领取人数`
from
(
	select
	distinct
	a.id,
	b.id `卡券ID`,
	b.coupon_name `卡券名称`,
	a.left_value/100 `面额`,
	b.coupon_code `券号`,
	a.member_id `会员ID`,
	a.get_date `获得时间`,
	a.activate_date `激活时间`,
	a.expiration_date `卡券失效日期`,
	CAST(a.exchange_code as varchar) `核销码`,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS `卡券来源`,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS `卡券状态`
	FROM ods_coup.ods_coup_tt_coupon_detail_d a 
	JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
	where 1=1
	and b.id in ('6729','6730','6731') -- 卡券ID
	and a.get_date >= '2024-05-15'
	and a.get_date < '2024-06-03'
	and a.is_deleted = 0
	and a.member_id in
	(
		-- 浏览了525活动精品或膨胀券页面，并且在5.15~5.31期间的注册用户
		select
		DISTINCT b.id
		from 
		(
			-- 525活动膨胀页
		    select 
			distinct_id,toDateTime(left(`time`,19)) as `time`,date(date) as date
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
			and event = 'Page_entry'
			and page_title in ('525车主节·商城礼券','525车主节.商城礼券')   -- 浏览了525活动精品或膨胀券页面
			and var_activity_name = '2024年5月525车主节'
			and LENGTH(distinct_id) < 9
			and toDate(`time`) >= '2024-05-15'
			and toDate(`time`) < '2024-06-03'
		) a
		inner join
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
			and m.member_time >= '2024-05-15' and m.member_time < '2024-06-03'   -- 限制注册时间在活动期间
		) b on a.distinct_id = b.cust_id::varchar
	)
	order by a.get_date
) a
group by 1


-- 老用户领券
select
a.`卡券ID` `卡券ID`,
COUNT(DISTINCT a.`会员ID`) `领取人数`
from
(
	select
	distinct
	a.id,
	b.id `卡券ID`,
	b.coupon_name `卡券名称`,
	a.left_value/100 `面额`,
	b.coupon_code `券号`,
	a.member_id `会员ID`,
	a.get_date `获得时间`,
	a.activate_date `激活时间`,
	a.expiration_date `卡券失效日期`,
	CAST(a.exchange_code as varchar) `核销码`,
	CASE a.coupon_source 
	  WHEN 83241001 THEN 'VCDC发券'
	  WHEN 83241002 THEN '沃世界领券'
	  WHEN 83241003 THEN '商城购买'
	END AS `卡券来源`,
	CASE a.ticket_state
	  WHEN 31061001 THEN '已领用'
	  WHEN 31061002 THEN '已锁定'
	  WHEN 31061003 THEN '已核销' 
	  WHEN 31061004 THEN '已失效'
	  WHEN 31061005 THEN '已作废'
	END AS `卡券状态`
	FROM ods_coup.ods_coup_tt_coupon_detail_d a 
	JOIN ods_coup.ods_coup_tt_coupon_info_d b ON a.coupon_id = b.id
	where 1=1
	and b.id in ('6729','6730','6731') -- 卡券ID
	and a.get_date >= '2024-05-15'
	and a.get_date < '2024-06-03'
	and a.is_deleted = 0
	and a.member_id in
	(
		-- 浏览了525活动精品或膨胀券页面，并且在5.15~5.31期间的注册用户
		select
		DISTINCT b.id
		from 
		(
			-- 525活动膨胀页
		    select 
			distinct_id,toDateTime(left(`time`,19)) as `time`,date(date) as date
			from dwd_23.dwd_23_gio_tracking a
			where 1=1
			and (((`$lib` in ('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel ='App') or (`$lib` in('MiniProgram') or channel ='Mini')) -- 双端
			and event = 'Page_entry'
			and page_title in ('525车主节·商城礼券','525车主节.商城礼券')   -- 浏览了525活动精品或膨胀券页面
			and var_activity_name = '2024年5月525车主节'
			and LENGTH(distinct_id) < 9
			and toDate(`time`) >= '2024-05-15'
			and toDate(`time`) < '2024-06-03'
		) a
		inner join
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
			and m.member_time < '2024-05-15'   -- 活动开始前注册的用户算老用户
		) b on a.distinct_id = b.cust_id::varchar
	)
	order by a.get_date
) a
group by 1
