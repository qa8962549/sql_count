-- 3、近三个月商城精品下单用户中（订单量>=2），近一年仅在App下过单的用户数量
select
'App订单' 渠道,
count(distinct a.user_id) 近一年仅在App下过单的用户数量,
count(distinct a.order_code) 下单的订单数 
from "order".tt_order a  -- 订单主表
left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join
(
	-- 发货单表
	select
	d.* 
	from
	(
		select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
		,row_number() over(partition by d.order_code order by d.create_time desc) rk
		from `order`.tt_order_delivery d 
		where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id = ty.exchange_type_id 
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
	GROUP BY 1,2,3,4) a
	left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
) e on a.order_code = e.order_code and b.product_id =e.product_id 
where 1=1
and a.create_time >= (CURRENT_DATE - INTERVAL '12 months') 
and a.create_time < (CURRENT_DATE - INTERVAL '1 day') + INTERVAL '1 day'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and b.spu_type in ('51121001','51121004')   -- 筛选精品
--and LEFT(a.client_id,1) = '2'   -- APP下单
and LEFT(a.client_id,1) = '6'   -- 小程序下单
and a.user_id in
(
	-- 近三个月商城精品下单用户（订单量>=2）
	select
	distinct a.user_id
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join
	(
		-- 发货单表
		select
		d.* 
		from
		(
			select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
			,row_number() over(partition by d.order_code order by d.create_time desc) rk
			from `order`.tt_order_delivery d 
			where d.is_deleted=0
		) d where d.rk=1
	) d ON a.order_code = d.order_code
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
	left join goods.spu p on b.spu_bus_id=p.bus_id
	left join goods.exchange_type ty on p.exchange_type_id = ty.exchange_type_id 
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
		GROUP BY 1,2,3,4) a
		left join `order`.tt_sales_return_order b on a.order_code=b.order_code and a.退回时间=b.create_time and b.is_deleted=0 and b.status=51171004
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	where a.create_time >= (CURRENT_DATE - INTERVAL '3 months') and a.create_time < (CURRENT_DATE - INTERVAL '1 day') + INTERVAL '1 day'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	and b.spu_type in ('51121001','51121004')   -- 筛选精品
	group by 1
	having count(distinct cast(a.order_code as VARCHAR)) >= 2
)



CREATE TABLE ods_oper_crm.test_shangcheng(
	order_code VARCHAR(50),
	order_source VARCHAR(50),
	spu_id INTEGER,
	sku_id INTEGER,
	member_id INTEGER,
	cust_id INTEGER,
	member_v_num INTEGER,
	huiling REAL,
	is_vehicle VARCHAR(50),
	sex VARCHAR(50),
	member_level INTEGER,
	member_birthday VARCHAR(50),
	ege INTEGER,
	model_name VARCHAR(50),
	carage REAL,
	`是否授权亲友` VARCHAR(50),
	`授权亲友` VARCHAR(50),
	`商品类型` VARCHAR(50),
	`总金额` REAL,
	`现金支付金额` REAL,
	`支付V值` INTEGER,
	`兑换数量` INTEGER,
	`历史累计精品订单数` INTEGER,
	`历史累计精品订单金额` REAL,
	`历史累计精品现金支付金额` REAL,
	`历史累计精品v值支付金额` INTEGER,
	`下单时间` VARCHAR(50)
) ENGINE = MergeTree ()
ORDER BY (order_code, order_source);

CREATE TABLE ods_oper_crm.test_shangcheng2(
	order_code VARCHAR(50),
	order_source VARCHAR(50),
	spu_id INTEGER,
	sku_id INTEGER,
	member_id INTEGER,
	cust_id INTEGER,
	member_v_num INTEGER,
	huiling REAL,
	is_vehicle VARCHAR(50),
	sex VARCHAR(50),
	member_level INTEGER,
	member_birthday VARCHAR(50),
	ege INTEGER,
	model_name VARCHAR(50),
	carage REAL,
	`是否授权亲友` VARCHAR(50),
	`授权亲友` VARCHAR(50),
	`商品类型` VARCHAR(50),
	`总金额` REAL,
	`现金支付金额` REAL,
	`支付V值` INTEGER,
	`兑换数量` INTEGER,
	`历史累计精品订单数` INTEGER,
	`历史累计精品订单金额` REAL,
	`历史累计精品现金支付金额` REAL,
	`历史累计精品v值支付金额` INTEGER,
	`下单时间` VARCHAR(50)
) ENGINE = log
--ORDER BY (order_code, `下单时间`);