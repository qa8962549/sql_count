# 商城月报＆V值月报

# 同环比Sheet
# 沃世界MAU
select
DATE_FORMAT(t.`date`,'%Y-%m')月份,
count(DISTINCT m.id) 沃世界MAU
from track.track t 
join(
	#清洗user_id
	select m.*
	from (
	select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
	,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.USER_ID is not null 
	) m
	where m.rk=1
)m on CAST(m.user_id AS varchar)=t.usertag
left join (
	#商城新老用户
	select DISTINCT a.user_id
	from (
	select a.order_code ,a.user_id,a.create_time
	,row_number() over(partition by a.user_id order by a.create_time) rk
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join(
		#V值退款成功记录
		select so.order_code,sp.product_id
		,sum(sp.sales_return_num) 退货数量
		,sum(so.refund_point) 退回V值
		,max(so.create_time) 退回时间
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 and so.status=51171004 -- 退款成功
		GROUP BY 1,2
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
	where a.create_time <= '2022-12-31 23:59:59'    -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	) a 
	where a.rk=1
) o on m.id=o.user_id
where t.date >= '2022-01-01' and t.date <= '2022-12-31 23:59:59'
and t.date > m.member_time 
GROUP BY 1
order by 1

	
# 商城首页UV
select DATE_FORMAT(t.`date`,'%Y-%m')月份,
count(DISTINCT t.usertag) 商城首页UV
from track.track t 
left join(
	#清洗user_id
	select m.*
	from (
	select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
	,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.USER_ID is not null 
	) m
	where m.rk=1
)m on CAST(m.user_id AS varchar)=t.usertag
left join (
	#商城新老用户
	select DISTINCT a.user_id
	from (
	select a.order_code ,a.user_id,a.create_time
	,row_number() over(partition by a.user_id order by a.create_time) rk
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join(
		#V值退款成功记录
		select so.order_code,sp.product_id
		,sum(sp.sales_return_num) 退货数量
		,sum(so.refund_point) 退回V值
		,max(so.create_time) 退回时间
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 and so.status=51171004 -- 退款成功
		GROUP BY 1,2
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
	where a.create_time <= '2022-12-31 23:59:59'  -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	) a 
	where a.rk=1 and a.user_id is not null 
) o on m.id=o.user_id
where t.date >= '2022-01-01' and t.date <= '2022-12-31 23:59:59'
and t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V'
GROUP BY 1
order by 1


# 商城销售额
select
DATE_FORMAT(m.兑换时间,'%Y-%m')月份,
COUNT(case when m.商品类型 = '保养类卡券' then m.订单编号 end) 售后下单量,
COUNT(case when m.商品类型 = '精品' then m.订单编号 end) 精品下单量,
COUNT(case when m.商品类型 = '第三方卡券' then m.订单编号 end) 第三方卡券下单量,
SUM(case when m.商品类型 = '保养类卡券' then m.总金额 end) 售后销售额,
SUM(case when m.商品类型 = '精品' then m.总金额 end) 精品销售额,
SUM(case when m.商品类型 = '第三方卡券' then m.总金额 end) 第三方卡券销售额,
SUM(m.支付V值) V值消耗
from
(select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
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
where a.create_time BETWEEN '2022-01-01' and '2022-12-31 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
order by a.create_time)m
group by 1
order by 1



# 商城链路Sheet
-- 1、用户侧 商城新老用户
select a.*
,b.商城首页UV
,c.合计,c.精品详情页UV,c.售后详情页UV,c.第三方详情页UV
,c.合计/a.沃世界MAU 导流率合计
,c.精品详情页UV/a.沃世界MAU 导流率精品
,c.售后详情页UV/a.沃世界MAU 导流率售后
,c.第三方详情页UV/a.沃世界MAU 导流率第三方
,d.下单商品数合计,d.下单商品数精品,d.下单商品数售后,d.下单商品数第三方
,d.下单用户数合计,d.下单用户数精品,d.下单用户数售后,d.下单用户数第三方
,d.下单用户数合计/c.合计
,d.下单用户数精品/c.精品详情页UV
,d.下单用户数售后/c.售后详情页UV
,d.下单用户数第三方/c.第三方详情页UV
,d.订单数,d.订单数精品,d.订单数售后,d.订单数第三方
,d.客单价,d.客单价精品,d.客单价售后,d.客单价第三方
,d.销售额合计,d.销售额精品,d.销售额售后,d.销售额第三方
,d.销售额V值合计,d.销售额V值精品,d.销售额V值售后,d.销售额V值第三方
,d.销售额现金合计,d.销售额现金精品,d.销售额现金售后,d.销售额现金第三方
,d.销售额优惠券合计,d.销售额优惠券精品,d.销售额优惠券售后,d.销售额优惠券第三方
from (
	#沃世界MAU
	select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
	,count(DISTINCT m.id) 沃世界MAU
	from track.track t 
	join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	left join (
		#商城新老用户
		select DISTINCT a.user_id
		from (
		select a.order_code ,a.user_id,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.date>m.member_time 
	GROUP BY 1
) a 
left join (
	#商城首页UV
	select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
	,count(DISTINCT t.usertag) 商城首页UV
	from track.track t 
	left join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	left join (
		#商城新老用户
		select DISTINCT a.user_id
		from (
		select a.order_code ,a.user_id,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1 and a.user_id is not null 
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V'
	GROUP BY 1 
) b on a.用户分类=b.用户分类
left join (
	#商品详情页UV
	select a.用户分类
	,count(DISTINCT a.usertag) 合计
	,count(DISTINCT case when a.商品类型='精品' then a.usertag else null end) 精品详情页UV
	,count(DISTINCT case when a.商品类型='保养类卡券' then a.usertag else null end) 售后详情页UV
	,count(DISTINCT case when a.商品类型='第三方卡券' then a.usertag else null end) 第三方详情页UV
	from (
		select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
		,t.usertag
		,cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) spuid
		,CASE p.item_type
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			-- WHEN 51121006 THEN '一件代发'
			-- WHEN 51121007 THEN '经销商端产品' 
			ELSE '精品' end 商品类型
		from track.track t 
		left join(
			#清洗user_id
			select m.*
			from (
			select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
			,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
			from member.tc_member_info m
			where m.member_status<>60341003 and m.is_deleted=0
			and m.USER_ID is not null 
			) m
			where m.rk=1
		)m on CAST(m.user_id AS varchar)=t.usertag
		left join (
			#商城新老用户
			select DISTINCT a.user_id
			from (
			select a.order_code ,a.user_id,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on m.id=o.user_id
		left join goods.item_spu p on cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) = p.id
		where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
		and t.typeid = 'XWSJXCX_MALL_DETAIL_V' and json_extract(t.data,'$.spuId') is not null 
	) a 
	GROUP BY 1 
) c on c.用户分类=b.用户分类
left join (
	#订单
	select o.用户分类
	,sum(o.`兑换数量`) 下单商品数合计
	,sum(case when o.商品类型='精品' then o.`兑换数量` else null end) 下单商品数精品
	,sum(case when o.商品类型='保养类卡券' then o.`兑换数量` else null end) 下单商品数售后
	,sum(case when o.商品类型='第三方卡券' then o.`兑换数量` else null end) 下单商品数第三方

	,count(DISTINCT o.`会员id`) 下单用户数合计
	,count(DISTINCT case when o.商品类型='精品' then o.`会员id` else null end) 下单用户数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.`会员id` else null end) 下单用户数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.`会员id` else null end) 下单用户数第三方

	,count(DISTINCT o.`订单编号`) 订单数
	,count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end) 订单数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end) 订单数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end) 订单数第三方

	,round(sum(o.`实付金额`)/count(DISTINCT o.`订单编号`),0) 客单价
	,round(sum(case when o.商品类型='精品' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end)) 客单价精品
	,round(sum(case when o.商品类型='保养类卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end)) 客单价售后
	,round(sum(case when o.商品类型='第三方卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end)) 客单价第三方

	,sum(o.总金额) 销售额合计
	,sum(case when o.商品类型='精品' then o.总金额 else null end) 销售额精品
	,sum(case when o.商品类型='保养类卡券' then o.总金额 else null end) 销售额售后
	,sum(case when o.商品类型='第三方卡券' then o.总金额 else null end) 销售额第三方

	,ROUND(sum(o.支付V值)/3) 销售额V值合计
	,sum(case when o.商品类型='精品' then o.支付V值 else null end) 销售额V值精品
	,sum(case when o.商品类型='保养类卡券' then o.支付V值 else null end) 销售额V值售后
	,sum(case when o.商品类型='第三方卡券' then o.支付V值 else null end) 销售额V值第三方

	,sum(o.现金支付金额) 销售额现金合计
	,sum(case when o.商品类型='精品' then o.现金支付金额 else null end) 销售额现金精品
	,sum(case when o.商品类型='保养类卡券' then o.现金支付金额 else null end) 销售额现金售后
	,sum(case when o.商品类型='第三方卡券' then o.现金支付金额 else null end) 销售额现金第三方

	,sum(o.优惠券抵扣金额) 销售额优惠券合计
	,sum(case when o.商品类型='精品' then o.优惠券抵扣金额 else null end) 销售额优惠券精品
	,sum(case when o.商品类型='保养类卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券售后
	,sum(case when o.商品类型='第三方卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券第三方
	from (
		select a.order_code 订单编号
		,b.product_id 商城兑换id
		,a.user_id 会员id
		,a.user_name 会员姓名
		,b.spu_name 兑换商品
		,b.sku_real_point 商品单价
		,CASE b.spu_type 
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			WHEN 51121006 THEN '精品'-- '一件代发'
			WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
		,b.fee/100 总金额
		,b.coupon_fee/100 优惠券抵扣金额
		,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
		,b.pay_fee/100 现金支付金额
		,b.point_amount 支付V值
		,b.sku_num 兑换数量
		,a.create_time 兑换时间
		,case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
		left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
		left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		left join (
			#商城新老用户
			select DISTINCT a.user_id
			from (
			select a.order_code ,a.user_id,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on a.user_id=o.user_id
		where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) o GROUP BY 1 

) d on d.用户分类=c.用户分类



-- 用户侧 车主粉丝
select a.*
,b.商城首页UV
,c.合计,c.精品详情页UV,c.售后详情页UV,c.第三方详情页UV
,c.合计/a.沃世界MAU 导流率合计
,c.精品详情页UV/a.沃世界MAU 导流率精品
,c.售后详情页UV/a.沃世界MAU 导流率售后
,c.第三方详情页UV/a.沃世界MAU 导流率第三方
,d.下单商品数合计,d.下单商品数精品,d.下单商品数售后,d.下单商品数第三方
,d.下单用户数合计,d.下单用户数精品,d.下单用户数售后,d.下单用户数第三方
,d.下单用户数合计/c.合计
,d.下单用户数精品/c.精品详情页UV
,d.下单用户数售后/c.售后详情页UV
,d.下单用户数第三方/c.第三方详情页UV
,d.订单数,d.订单数精品,d.订单数售后,d.订单数第三方
,d.客单价,d.客单价精品,d.客单价售后,d.客单价第三方
,d.销售额合计,d.销售额精品,d.销售额售后,d.销售额第三方
,d.销售额V值合计,d.销售额V值精品,d.销售额V值售后,d.销售额V值第三方
,d.销售额现金合计,d.销售额现金精品,d.销售额现金售后,d.销售额现金第三方
,d.销售额优惠券合计,d.销售额优惠券精品,d.销售额优惠券售后,d.销售额优惠券第三方
from (
	#沃世界MAU
	select case when o.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
	,count(DISTINCT m.id) 沃世界MAU
	from track.track t 
	join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	left join (
		#商城下单车主粉丝
		select DISTINCT a.user_id,a.is_vehicle
		from (
		select a.order_code,a.user_id,m.is_vehicle,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.date>m.member_time 
	GROUP BY 1
) a 
left join (
	#商城首页UV
	select case when o.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
	,count(DISTINCT t.usertag) 商城首页UV
	from track.track t 
	left join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	left join (
		#商城下单车主粉丝
		select DISTINCT a.user_id,a.is_vehicle
		from (
		select a.order_code,a.user_id,m.is_vehicle,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1 and a.user_id is not null 
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V'
	GROUP BY 1 
) b on a.用户分类=b.用户分类
left join (
	#商品详情页UV
	select a.用户分类
	,count(DISTINCT a.usertag) 合计
	,count(DISTINCT case when a.商品类型='精品' then a.usertag else null end) 精品详情页UV
	,count(DISTINCT case when a.商品类型='保养类卡券' then a.usertag else null end) 售后详情页UV
	,count(DISTINCT case when a.商品类型='第三方卡券' then a.usertag else null end) 第三方详情页UV
	from (
		select case when o.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
		,t.usertag
		,cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) spuid
		,CASE p.item_type
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			-- WHEN 51121006 THEN '一件代发'
			-- WHEN 51121007 THEN '经销商端产品' 
			ELSE '精品' end 商品类型
		from track.track t 
		left join(
			#清洗user_id
			select m.*
			from (
			select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
			,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
			from member.tc_member_info m
			where m.member_status<>60341003 and m.is_deleted=0
			and m.USER_ID is not null 
			) m
			where m.rk=1
		)m on CAST(m.user_id AS varchar)=t.usertag
		left join (
			#商城下单车主粉丝
			select DISTINCT a.user_id,a.IS_VEHICLE
			from (
			select a.order_code,a.user_id,m.IS_VEHICLE,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on m.id=o.user_id
		left join goods.item_spu p on cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) = p.id
		where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
		and t.typeid = 'XWSJXCX_MALL_DETAIL_V' and json_extract(t.data,'$.spuId') is not null 
	) a 
	GROUP BY 1 
) c on c.用户分类=b.用户分类
left join (
	#订单
	select o.用户分类
	,sum(o.`兑换数量`) 下单商品数合计
	,sum(case when o.商品类型='精品' then o.`兑换数量` else null end) 下单商品数精品
	,sum(case when o.商品类型='保养类卡券' then o.`兑换数量` else null end) 下单商品数售后
	,sum(case when o.商品类型='第三方卡券' then o.`兑换数量` else null end) 下单商品数第三方

	,count(DISTINCT o.`会员id`) 下单用户数合计
	,count(DISTINCT case when o.商品类型='精品' then o.`会员id` else null end) 下单用户数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.`会员id` else null end) 下单用户数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.`会员id` else null end) 下单用户数第三方

	,count(DISTINCT o.`订单编号`) 订单数
	,count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end) 订单数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end) 订单数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end) 订单数第三方

	,round(sum(o.`实付金额`)/count(DISTINCT o.`订单编号`),0) 客单价
	,round(sum(case when o.商品类型='精品' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end)) 客单价精品
	,round(sum(case when o.商品类型='保养类卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end)) 客单价售后
	,round(sum(case when o.商品类型='第三方卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end)) 客单价第三方

	,sum(o.总金额) 销售额合计
	,sum(case when o.商品类型='精品' then o.总金额 else null end) 销售额精品
	,sum(case when o.商品类型='保养类卡券' then o.总金额 else null end) 销售额售后
	,sum(case when o.商品类型='第三方卡券' then o.总金额 else null end) 销售额第三方

	,ROUND(sum(o.支付V值)/3) 销售额V值合计
	,sum(case when o.商品类型='精品' then o.支付V值 else null end) 销售额V值精品
	,sum(case when o.商品类型='保养类卡券' then o.支付V值 else null end) 销售额V值售后
	,sum(case when o.商品类型='第三方卡券' then o.支付V值 else null end) 销售额V值第三方

	,sum(o.现金支付金额) 销售额现金合计
	,sum(case when o.商品类型='精品' then o.现金支付金额 else null end) 销售额现金精品
	,sum(case when o.商品类型='保养类卡券' then o.现金支付金额 else null end) 销售额现金售后
	,sum(case when o.商品类型='第三方卡券' then o.现金支付金额 else null end) 销售额现金第三方

	,sum(o.优惠券抵扣金额) 销售额优惠券合计
	,sum(case when o.商品类型='精品' then o.优惠券抵扣金额 else null end) 销售额优惠券精品
	,sum(case when o.商品类型='保养类卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券售后
	,sum(case when o.商品类型='第三方卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券第三方
	from (
		select a.order_code 订单编号
		,b.product_id 商城兑换id
		,a.user_id 会员id
		,a.user_name 会员姓名
		,b.spu_name 兑换商品
		,b.sku_real_point 商品单价
		,CASE b.spu_type 
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			WHEN 51121006 THEN '精品'-- '一件代发'
			WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
		,b.fee/100 总金额
		,b.coupon_fee/100 优惠券抵扣金额
		,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
		,b.pay_fee/100 现金支付金额
		,b.point_amount 支付V值
		,b.sku_num 兑换数量
		,a.create_time 兑换时间
		,case when h.IS_VEHICLE = 1 then '车主' else '粉丝' END 用户分类
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
		left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
		left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		left join (
			#商城下单车主粉丝
			select DISTINCT a.user_id
			from (
			select a.order_code,a.user_id,m.IS_VEHICLE,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null
		) o on a.user_id=o.user_id
		where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) o GROUP BY 1 

) d on d.用户分类=c.用户分类



-- 商品侧
-- 在线sku & spu数
select count(DISTINCT a.spu_bus_id) 在线商品数spu
,count(DISTINCT case when a.item_type in (51121001,51121004) then a.spu_bus_id else null end) 精品spu
,count(DISTINCT case when a.item_type = 51121003 then a.spu_bus_id else null end) 售后spu
,count(DISTINCT case when a.item_type = 51121002 then a.spu_bus_id else null end) 第三方spu
,count(DISTINCT b.sku_bus_id) 在线商品数sku
,count(DISTINCT case when a.item_type in (51121001,51121004) then b.sku_bus_id else null end) 精品sku
,count(DISTINCT case when a.item_type = 51121003 then b.sku_bus_id else null end) 售后sku
,count(DISTINCT case when a.item_type = 51121002 then b.sku_bus_id else null end) 第三方sku
from goods.item_spu a
LEFT JOIN goods.item_sku b ON a.id = b.spu_id
-- where a.`status`= 60291003
where (a.`status`= 60291003 or (a.lower_time >= '2022-07-01' and a.lower_time <= '2022-07-31 23:59:59' and a.`status`=60291004))
and a.item_type in (51121001,51121002,51121003,51121004)
and a.date_create <= '2022-07-31 23:59:59';


-- 动销商品数
select DATE_FORMAT(a.create_time,'%Y-%m')
,count(DISTINCT b.spu_bus_id) 动销商品数spu
,count(DISTINCT case when j.item_type in (51121001,51121004) then b.spu_bus_id else null end) 精品spu
,count(DISTINCT case when j.item_type = 51121003 then b.spu_bus_id else null end) 售后spu
,count(DISTINCT case when j.item_type = 51121002 then b.spu_bus_id else null end) 第三方spu
,count(DISTINCT b.sku_bus_id) 动销商品数sku
,count(DISTINCT case when j.item_type in (51121001,51121004) then b.sku_bus_id else null end) 精品sku
,count(DISTINCT case when j.item_type = 51121003 then b.sku_bus_id else null end) 售后sku
,count(DISTINCT case when j.item_type = 51121002 then b.sku_bus_id else null end) 第三方sku
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
left join(
	#V值退款成功记录
	select so.order_code,sp.product_id
	,sum(sp.sales_return_num) 退货数量
	,sum(so.refund_point) 退回V值
	,max(so.create_time) 退回时间
	from `order`.tt_sales_return_order so
	left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
	where so.is_deleted = 0 
	and so.status=51171004 -- 退款成功
	GROUP BY 1,2
) e on a.order_code = e.order_code and b.product_id =e.product_id 
-- where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
where a.create_time >= '2022-07-01' and a.create_time <= '2022-07-31 23:59:59'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
GROUP BY 1;



# 商城订单Sheet（未剔除退款订单）
select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
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
where a.create_time BETWEEN '2022-06-01' and '2022-06-30 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and e.order_code is null  -- 剔除退款订单
order by a.create_time;



# 商城退款订单Sheet
select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
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
where a.create_time BETWEEN '2022-06-01' and '2022-06-30 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is not null  -- 剔除退款订单
order by a.create_time;




------------------------------------- 分割线 -------------------------------------


# V值月报
-- 概览Sheet

# V值侧2022年5月
select
DATE_FORMAT(f.CREATE_TIME,'%Y-%m')年月,
SUM(f.INTEGRAL) 当月发放V值数
from member.tt_member_flow_record f
join `member`.tc_member_info m on f.member_id = m.ID and m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0
where f.create_time >= '2019-05-01'
and f.CREATE_TIME <= '2022-07-31 23:59:59'
and f.RECORD_TYPE = 0 
and f.IS_DELETED = 0
and f.EVENT_TYPE <> 60731025  -- V值退回
group by 1
order by 1




-- 预估过期量（当月1日）  （这个这个这个这个这个这个，8.4）
select x.月份,
sum(x.过期量)
from 
	(
	select 
	'08' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'09' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-09-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-09-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'10' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-10-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-10-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'11' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-11-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-11-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'12' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'13' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-01-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-01-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'14' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-02-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-02-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'15' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-03-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-03-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'16' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-04-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-04-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'17' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-05-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-05-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'18' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-06-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-06-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'19' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'20' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'21' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-09-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-09-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'22' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-10-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-10-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'23' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-11-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-11-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'24' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2023-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2023-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'25' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-01-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-01-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'26' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-02-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-02-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'27' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-03-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-03-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'28' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-04-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-04-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'29' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-05-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-05-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'30' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-06-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-06-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'31' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'32' 月份,
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2024-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2024-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	) x 
group by 1 
order by 1


-- 实际过期V值（次月1日-5日）
select
DATE_FORMAT(r.CREATE_TIME,'%Y-%m')年月,
sum(r.INTEGRAL) 预估过期V值数
from `member`.tt_member_flow_record r
join `member`.tc_member_info m on r.member_id = m.ID and m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0
where r.EVENT_TYPE = 60741032  -- V值过期
and r.CREATE_TIME >= '2022-08-01'   -- 过期时间
and r.CREATE_TIME <= '2022-08-05 23:59:59'
GROUP BY 1




-- 当前有效V值区间
select
	case when m.当前有效V值 >= 0 and m.当前有效V值 <= 100 then '01 0~100'
		when m.当前有效V值 >= 101 and m.当前有效V值 <= 200 then '02 101~200'
		when m.当前有效V值 >= 201 and m.当前有效V值 <= 300 then '03 201~300'
		when m.当前有效V值 >= 301 and m.当前有效V值 <= 400 then '04 301~400'
		when m.当前有效V值 >= 401 and m.当前有效V值 <= 500 then '05 401~500'
		when m.当前有效V值 >= 501 and m.当前有效V值 <= 600 then '06 501~600'
		when m.当前有效V值 >= 601 and m.当前有效V值 <= 700 then '07 601~700'
		when m.当前有效V值 >= 701 and m.当前有效V值 <= 800 then '08 701~800'
		when m.当前有效V值 >= 801 and m.当前有效V值 <= 900 then '09 801~900'
		when m.当前有效V值 >= 901 and m.当前有效V值 <= 1000 then '10 901~1000'
		when m.当前有效V值 >= 1001 and m.当前有效V值 <= 2000 then '11 1001~2000'
		when m.当前有效V值 >= 2001 and m.当前有效V值 <= 3000 then '12 2001~3000'
		when m.当前有效V值 >= 3001 and m.当前有效V值 <= 4000 then '13 3001~4000'
		when m.当前有效V值 >= 4001 and m.当前有效V值 <= 5000 then '14 4001~5000'
		when m.当前有效V值 >= 5001 and m.当前有效V值 <= 6000 then '15 5001~6000'
		when m.当前有效V值 >= 6001 and m.当前有效V值 <= 7000 then '16 6001~7000'
		when m.当前有效V值 >= 7001 and m.当前有效V值 <= 8000 then '17 7001~8000'
		when m.当前有效V值 >= 8001 and m.当前有效V值 <= 9000 then '18 8001~9000'
		when m.当前有效V值 >= 9001  then '19 9000+' else null end V值区间,
	COUNT(distinct m.会员ID) 人数,
	SUM(m.当前有效V值) V值数
from
(
	select
	tmi.ID 会员ID,
	tmi.MEMBER_V_NUM 当前有效V值
	from `member`.tc_member_info tmi
	where tmi.MEMBER_STATUS <> 60341003
	and tmi.IS_DELETED = 0
)m
group by 1
order by 1






-- TTD V值侧当前 Sheet
select
a.V值事件,
a.累计发放V值数,
a.累计发放用户数,
a.消耗量 消耗量,
a.消耗用户数 消耗用户数,
ROUND(a.消耗量/a.累计发放V值数,2)消耗占比,
ROUND(a.消耗用户数/a.累计发放用户数,2)消耗用户数占比,
ifnull(b.过期量,0),
ifnull(b.过期用户数,0)
from
	(
	-- V值侧当前实际发放和消耗
	select r.EVENT_DESC V值事件
	,sum(r.ADD_V_NUM) 累计发放V值数
	,count(DISTINCT r.MEMBER_ID) 累计发放用户数
	,sum(r.CONSUMPTION_INTEGRAL) 消耗量
	,count(DISTINCT case when r.CONSUMPTION_INTEGRAL > 0 then r.MEMBER_ID else null end) 消耗用户数
	from member.tt_member_score_record r
	where -- r.create_time < '2022-03-01'
	r.ADD_V_NUM > 0
	and r.IS_DELETED = 0 
	and r.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 1 order by 2 desc
	)a
left join
(
-- 过期V值（当前月的前一个月获取未使用的V值）
select x.过期v值事件 过期v值事件,
sum(x.过期量) 过期量,
sum(x.过期用户数) 过期用户数
from 
	(
	select 
	'1',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.EVENT_TYPE <> 60731025   -- V值退回
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'2',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.EVENT_TYPE <> 60731025   -- V值退回
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'3',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-06-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-06-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'4',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-05-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-05-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'5',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-04-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-04-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'6',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-03-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-03-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'7',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-02-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-02-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'8',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2022-01-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2022-01-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'9',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'10',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-12-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-12-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'11',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-11-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-11-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'12',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-10-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-10-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'13',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-09-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-09-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'14',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-08-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-08-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	union all
	select 
	'15',
	a.EVENT_DESC 过期v值事件,
	sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)过期量,
	count(DISTINCT a.MEMBER_ID)过期用户数
	from `member`.tt_member_score_record a
	where a.CREATE_TIME >= DATE_sub('2021-07-01',INTERVAL 25 MONTH)    -- 往前推25个月
	and a.CREATE_TIME <= DATE_sub('2021-07-01',INTERVAL 24 MONTH) -- 往前推24个月
	and a.IS_DELETED = 0
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.EVENT_TYPE <> 60731025   -- V值退回
	GROUP BY 2 
	order by 3 desc
	)x 
	group by 1
	order by 2 desc 
)b
on a.V值事件 = b.过期V值事件
order by 2 desc 




-- V值侧当前实际发放和消耗
select r.EVENT_DESC V值事件
,sum(r.ADD_V_NUM) 累计发放V值数
,count(DISTINCT r.MEMBER_ID) 累计发放用户数
,sum(r.CONSUMPTION_INTEGRAL) 消耗量
,count(DISTINCT case when r.CONSUMPTION_INTEGRAL > 0 then r.MEMBER_ID else null end) 消耗用户数
from member.tt_member_score_record r
where -- r.create_time < '2022-03-01'
r.ADD_V_NUM > 0
and r.IS_DELETED = 0 
and r.EVENT_TYPE <> 60731025   -- V值退回
GROUP BY 1 order by 2 desc


# V值侧2022年8月实际发放和消耗 Sheet
select f.EVENT_DESC
,sum(f.INTEGRAL) 累计发放V值数
,count(DISTINCT f.MEMBER_ID) 累计发放用户数
,SUM(case when f.create_time >= '2022-07-01' and f.create_time <'2022-08-01' then f.INTEGRAL else null end) 当月发放V值数
,count(DISTINCT case when f.create_time >= '2022-07-01' and f.create_time <'2022-08-01' then f.MEMBER_ID else null end) 当月发放用户数
from member.tt_member_flow_record f 
where f.create_time < '2022-08-01'
and f.RECORD_TYPE=0 
and f.IS_DELETED=0
and f.EVENT_TYPE<>60731025
GROUP BY 1 order by 2 desc ;


-- V值侧2022年6月消耗
SELECT
DATE_FORMAT(a.CREATE_TIME,'%Y-%m') 年月,
d.CODE_CN_DESC 部门,
c.BUSINESS_TYPE 预算类型,
a.event_desc AS remark,
	  -- ,a.record_type
sum(a.integral) 消耗额,
count(a.id) 消耗次数,
count(DISTINCT a.member_id) 消耗人数
FROM member.tt_member_flow_record a
LEFT JOIN member.tc_score_rule c ON a.event_type = c.event_code AND c.is_deleted <> 1
LEFT JOIN dictionary.tc_code d ON d.code_id = c.department
join member.tc_member_info m on a.member_id=m.id and m.is_deleted=0 and m.member_status<>60341003
WHERE a.create_time >= '2022-07-01'
AND a.create_time < '2022-08-01'
AND a.is_deleted <> 1
and a.RECORD_TYPE = 1
-- AND a.event_desc NOT LIKE '%商品兑换%'
GROUP BY 1,2,3,4
ORDER BY 5 desc;




-- 当月逾期用户回溯Sheet
select f.member_id
,f.8月总过期V值数
,r.V值事件数额
,r.V值来源事件名称
,case when v.member_id is not null then '是' else null end 是否曾为车主
,f.当前是否为车主
,b.截止7月31号V值余额
from (
	## V值过期数
	select f.member_id
	,case when m.is_vehicle=1 then '是' else null end 当前是否为车主
	,sum(f.INTEGRAL) 8月总过期V值数
	from member.tt_member_flow_record f 
	join member.tc_member_info m on m.id=f.MEMBER_ID and m.is_deleted=0 and m.member_status<>60341003
	where f.create_time >= '2022-08-01' and f.create_time < '2022-09-01'
	and f.IS_DELETED=0 
	and f.RECORD_TYPE=1
	and f.EVENT_TYPE= 60741032
	GROUP BY 1,2 order by 2
) f
left join (
	## V值过期明细
	select a.MEMBER_ID,a.event_desc V值来源事件名称,a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL V值事件数额
	from `member`.tt_member_score_record a
	join member.tc_member_info m on m.id=a.MEMBER_ID and m.is_deleted=0 and m.member_status<>60341003
	where a.CREATE_TIME >='2020-07-01' and a.CREATE_TIME <'2020-08-01'
	and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
	and a.IS_DELETED=0
	and a.LOCK_V_NUM<=0
	order by 3
) r on f.member_id = r.member_id
left join (
	## 是否曾为车主
	select DISTINCT v.member_id
	from member.tc_member_vehicle v 
) v on f.member_id = v.member_id
left join (
	## 截止7月31号23：59：59的剩余V值
	select f.MEMBER_ID,m.MEMBER_V_NUM
	,m.MEMBER_V_NUM-sum(case when f.create_time>='2022-08-01' then 
			case when f.RECORD_TYPE=1 then -f.INTEGRAL when f.RECORD_TYPE=0 then f.INTEGRAL else 0 end 
			else 0 end) 截止7月31号V值余额
	from member.tt_member_flow_record f
	join member.tc_member_info m on f.MEMBER_ID=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	where f.create_time >= '2022-08-01' and f.IS_DELETED=0
	GROUP BY 1,2 
) b on f.member_id=b.member_id ;



