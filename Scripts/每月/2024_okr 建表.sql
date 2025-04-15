-- 新车销售活跃用户
select memberid from ods_oper_crm.xinchexiaoshouhuoyue

CREATE TABLE IF NOT EXISTS ods_oper_crm.xinchexiaoshouhuoyue
ENGINE = Log() -- 剔除新车销售活跃会员
AS
	-- 剔除新车销售活跃会员
	select
	distinct b.memberid
	from
	(
		-- 购车数据
		select
		distinct a.phone_num,a.created_at
		from
		(
			select
			o.customer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> '14031002'
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
			AND o.is_deleted = 0
			AND o.created_at >= '2022-12-01'
			AND o.created_at < '2024-01-01'
			AND o.customer_tel IS NOT NULL
			UNION ALL   
			select
			o.drawer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2022-12-01'
			AND o.created_at < '2024-01-01'
			AND o.drawer_tel IS NOT NULL
			UNION ALL
			select
			o.purchase_phone phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2022-12-01'
			AND o.created_at < '2024-01-01'
			AND o.purchase_phone IS NOT null
		) a
		where length(a.phone_num) = '11'
		and left(a.phone_num,1) = '1'
	) a
	global inner join
	(
		-- 活跃会员(这张表每个人每天只有一条活跃记录)
		select
		distinct a.memberid,m.member_phone,a.`date`
		from ads_crm.ads_crm_events_active_d a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
		where a.`date` >= '2023-01-01'
		AND a.`date` < '2024-01-01'
	) b on toString(a.phone_num) = toString(b.member_phone)
	where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内








-- 售后工单活跃用户
select id from ods_oper_crm.shouhouhuichanghuoyue


CREATE TABLE IF NOT EXISTS ods_oper_crm.shouhouhuichanghuoyue
ENGINE = Log() --  售后回厂
AS	
-- 2、活跃用户售后回厂
select
distinct b.distinct_id as id
from
(
	-- 工单明细(先用会员表和工单表，找会员注册和返厂在同一天，且注册时间大于工单创建时间的，这样就把人都圈出来了)
	select
	m.cust_id,
	o.DELIVERER_MOBILE,
	o.RO_CREATE_DATE,
	m.member_time
	from ods_cyre.ods_cyre_tt_repair_order_d o
	global inner join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone
	where o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= '2023-01-01'
	and o.RO_CREATE_DATE < '2024-01-01'
	and m.member_status <> '60341003' and m.is_deleted = '0'
	and toDate(m.member_time)=toDate(o.RO_CREATE_DATE)    -- 会员注册和返厂在同一天
	and toDateTime(m.member_time) > toDateTime(o.RO_CREATE_DATE)   -- 会员注册时间晚于工单创建时间
) a
global inner join
(
	-- 活跃会员(这张表每个人每天只有一条活跃记录)
	select
	distinct a.distinct_id,date
	from ads_crm.ads_crm_events_active_d a
	-- left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
	where a.`date` >= '2023-01-01'
	AND a.`date` < '2024-01-01'
) b on a.cust_id::varchar = b.distinct_id::varchar and toDate(a.member_time) = toDate(b.date)   -- 会员注册时间和活跃时间在同一天
where a.cust_id global not in
(
	-- 剔除新车销售活跃会员
	select
	distinct b.cust_id
	from
	(
		-- 购车数据
		select
		distinct a.phone_num,a.created_at
		from
		(
			select
			o.customer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> '14031002'
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.customer_tel IS NOT NULL
			UNION ALL   
			select
			o.drawer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.drawer_tel IS NOT NULL
			UNION ALL
			select
			o.purchase_phone phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.purchase_phone IS NOT null
		) a
		where length(a.phone_num) = '11'
		and left(a.phone_num,1) = '1'
	) a
	global inner join
	(
		-- 活跃会员(这张表每个人每天只有一条活跃记录)
		select
		distinct m.cust_id,m.member_phone,a.`date`
		from ads_crm.ads_crm_events_active_d a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
		where a.`date` >= '2023-01-01'
		AND a.`date` < '2024-01-01'
	) b on toString(a.phone_num) = toString(b.member_phone)
	where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内
)





-- 新车销售活跃用户
select id from ods_oper_crm.appxinchexiaoshouhuoyue
	
	
CREATE TABLE IF NOT EXISTS ods_oper_crm.appxinchexiaoshouhuoyue
ENGINE = Log() -- 剔除新车销售活跃会员
AS
select
distinct b.id
from
(
	-- 购车数据
	select
	distinct a.phone_num,a.created_at
	from
	(
		select
		o.customer_tel phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> '14031002'
		AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.customer_tel IS NOT NULL
		UNION ALL   
		select
		o.drawer_tel phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> 14031002
		AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.drawer_tel IS NOT NULL
		UNION ALL
		select
		o.purchase_phone phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> 14031002
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.purchase_phone IS NOT null
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
) a
global inner join
(
	-- 取2023年活跃的人群，匹配对应的会员ID、手机号
	select distinct b.id,b.member_phone,a.date
	from
	(
		SELECT distinct distinct_id,date
		FROM ads_crm.ads_crm_events_active_d
		where date>='2023-01-01' 
		and date<'2024-01-01'
		--  and channel='App'
	) a
	inner join
	(
		-- 清洗member_phone 取其对应的最新信息
		select m.cust_id,m.id,m.member_phone,m.member_time
		from
		(
			select m.member_phone,m.id,m.cust_id,m.level_id ,m.member_time
			,row_number() over(partition by m.member_phone order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where length(member_phone) = '11'
			and left(member_phone,1) = '1'
			and cust_id is not null
			Settings allow_experimental_window_functions = 1
		) m
		where m.rk=1
	) b on toString(a.distinct_id)=toString(b.cust_id)
) b on toString(a.phone_num) = toString(b.member_phone)
where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内





-- 售后工单活跃用户
select id from ods_oper_crm.appshouhouhuichanghuoyue


CREATE TABLE IF NOT EXISTS ods_oper_crm.appshouhouhuichanghuoyue
ENGINE = Log() -- 剔除新车销售活跃会员
AS
select
distinct b.distinct_id as id
from
(
	-- 工单明细(先用会员表和工单表，找会员注册和返厂在同一天，且注册时间大于工单创建时间的，这样就把人都圈出来了)
	select
	m.cust_id,
	o.DELIVERER_MOBILE,
	o.RO_CREATE_DATE,
	m.member_time
	from ods_cyre.ods_cyre_tt_repair_order_d o
	global inner join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone
	where o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= '2023-01-01'
	and o.RO_CREATE_DATE < '2024-01-01'
	and m.member_status <> '60341003' and m.is_deleted = '0'
	and toDate(m.member_time)=toDate(o.RO_CREATE_DATE)    -- 会员注册和返厂在同一天
	and toDateTime(m.member_time) > toDateTime(o.RO_CREATE_DATE)   -- 会员注册时间晚于工单创建时间
) a
global inner join
(
	-- 活跃会员(这张表每个人每天只有一条活跃记录)
	select
	distinct a.distinct_id,date
	from ads_crm.ads_crm_events_active_d a
	-- left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
	where a.`date` >= '2023-01-01'
	AND a.`date` < '2024-01-01'
	and channel='App'
) b on a.cust_id::varchar = b.distinct_id::varchar and toDate(a.member_time) = toDate(b.date)   -- 会员注册时间和活跃时间在同一天
where a.cust_id global not in
(
	-- 剔除新车销售活跃会员
	select
	distinct b.cust_id
	from
	(
		-- 购车数据
		select
		distinct a.phone_num,a.created_at
		from
		(
			select
			o.customer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> '14031002'
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.customer_tel IS NOT NULL
			UNION ALL   
			select
			o.drawer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.drawer_tel IS NOT NULL
			UNION ALL
			select
			o.purchase_phone phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.purchase_phone IS NOT null
		) a
		where length(a.phone_num) = '11'
		and left(a.phone_num,1) = '1'
	) a
	global inner join
	(
		-- 活跃会员(这张表每个人每天只有一条活跃记录)
		select
		distinct m.cust_id,m.member_phone,a.`date`
		from ads_crm.ads_crm_events_active_d a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
		where a.`date` >= '2023-01-01'
		AND a.`date` < '2024-01-01'
	) b on toString(a.phone_num) = toString(b.member_phone)
	where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内
)







-- 新车销售活跃车主用户
select id from ods_oper_crm.appchezhuxinchexiaoshouhuoyue

	
CREATE TABLE IF NOT EXISTS ods_oper_crm.appchezhuxinchexiaoshouhuoyue
ENGINE = Log() -- 剔除新车销售活跃会员
AS	
select
distinct b.id
from
(
	-- 购车数据
	select
	distinct a.phone_num,a.created_at
	from
	(
		select
		o.customer_tel phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> '14031002'
		AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.customer_tel IS NOT NULL
		UNION ALL   
		select
		o.drawer_tel phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> 14031002
		AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.drawer_tel IS NOT NULL
		UNION ALL
		select
		o.purchase_phone phone_num,
		o.created_at
		FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
		WHERE o.business_type <> 14031002
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		AND o.is_deleted = 0
		AND o.created_at >= '2022-12-01'
		AND o.created_at < '2024-01-01'
		AND o.purchase_phone IS NOT null
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
) a
global inner join
(
	-- 取2023年活跃的人群，匹配对应的会员ID、手机号
	select distinct b.id,b.member_phone,a.date
	from
	(
		SELECT distinct distinct_id,date
		FROM ads_crm.ads_crm_events_active_d
		where date>='2023-01-01' 
		and date<'2024-01-01'
		  and channel='App'
	) a
	inner join
	(
		-- 清洗member_phone 取其对应的最新信息
		select m.cust_id,m.id,m.member_phone,m.member_time,m.is_vehicle
		from
		(
			select m.member_phone,m.id,m.cust_id,m.level_id ,m.member_time,m.is_vehicle
			,row_number() over(partition by m.member_phone order by m.member_time desc,m.id desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where length(member_phone) = '11'
			and left(member_phone,1) = '1'
			and cust_id is not null
			Settings allow_experimental_window_functions = 1
		) m
		where m.rk=1 and m.is_vehicle = 1   -- 限制车主
	) b on toString(a.distinct_id)=toString(b.cust_id)
) b on toString(a.phone_num) = toString(b.member_phone)
where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内	
	
	
	
	

	
	
	
-- 售后工单活跃车主用户
select id from ods_oper_crm.appchezhushouhouhuichanghuoyue


CREATE TABLE IF NOT EXISTS ods_oper_crm.appchezhushouhouhuichanghuoyue
ENGINE = Log() -- 剔除新车销售活跃会员
AS	
select
distinct b.distinct_id as id
from
(
	-- 工单明细(先用会员表和工单表，找会员注册和返厂在同一天，且注册时间大于工单创建时间的，这样就把人都圈出来了)
	select
	m.cust_id,
	o.DELIVERER_MOBILE,
	o.RO_CREATE_DATE,
	m.member_time
	from ods_cyre.ods_cyre_tt_repair_order_d o
	global inner join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone
	where o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= '2023-01-01'
	and o.RO_CREATE_DATE < '2024-01-01'
	and m.member_status <> '60341003' and m.is_deleted = '0'
	and toDate(m.member_time)=toDate(o.RO_CREATE_DATE)    -- 会员注册和返厂在同一天
	and toDateTime(m.member_time) > toDateTime(o.RO_CREATE_DATE)   -- 会员注册时间晚于工单创建时间
	and m.is_vehicle =1
) a
global inner join
(
	-- 活跃会员(这张表每个人每天只有一条活跃记录)
	select
	distinct a.distinct_id,date
	from ads_crm.ads_crm_events_active_d a
	-- left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
	where a.`date` >= '2023-01-01'
	AND a.`date` < '2024-01-01'
	and channel='App'
) b on a.cust_id::varchar = b.distinct_id::varchar and toDate(a.member_time) = toDate(b.date)   -- 会员注册时间和活跃时间在同一天
where a.cust_id global not in
(
	-- 剔除新车销售活跃会员
	select
	distinct b.cust_id
	from
	(
		-- 购车数据
		select
		distinct a.phone_num,a.created_at
		from
		(
			select
			o.customer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> '14031002'
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')   -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.customer_tel IS NOT NULL
			UNION ALL   
			select
			o.drawer_tel phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status in ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.drawer_tel IS NOT NULL
			UNION ALL
			select
			o.purchase_phone phone_num,
			o.created_at
			FROM ods_cydr.ods_cydr_tt_sales_orders_cur o
			WHERE o.business_type <> 14031002
			AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
			AND o.is_deleted = 0
			AND o.created_at >= '2023-01-01'
			AND o.created_at < '2024-01-01'
			AND o.purchase_phone IS NOT null
		) a
		where length(a.phone_num) = '11'
		and left(a.phone_num,1) = '1'
	) a
	global inner join
	(
		-- 活跃会员(这张表每个人每天只有一条活跃记录)
		select
		distinct m.cust_id,m.member_phone,a.`date`
		from ads_crm.ads_crm_events_active_d a
		left join ods_memb.ods_memb_tc_member_info_cur m on a.memberid = m.id
		where a.`date` >= '2023-01-01'
		AND a.`date` < '2024-01-01'
	) b on toString(a.phone_num) = toString(b.member_phone)
	where b.date <= (CAST(a.created_at AS TIMESTAMP) + INTERVAL '1 MONTH') and CAST(a.created_at AS TIMESTAMP) < b.date    -- 会员注册时间在订单时间30天内
)