-- 1、商城正向订单明细(下单时间在当月)  专属二维码订单
select
a.order_code `订单号`,
ifnull(a.parent_order_code,a.order_code) `母单号`,
case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end `订单来源`,
case when a.order_source = '51021001' then '立即下单'
	when a.order_source = '51021002' then '购物车下单'
	when a.order_source = '51021003' then '工单'
	when a.order_source = '51021004' then '秒杀'
	when a.order_source = '51021006' then '组合购订单'
	when a.order_source = '51021007' then '买赠订单'
	else null end `订单来源渠道`,
a.user_id `下单人会员ID`,
a.user_phone `下单人手机号`,
b.sku_code `商品货号`,
b.product_id `product_id`,
e.part_number `PN号`,
b.spu_name `兑换商品`,
b.spu_id `商品SPU_ID`,
b.sku_id `商品SKU_ID`,
b.sku_code `商品编码`,
b.sku_price/100 `商品零售含税价(元)`,
e.cls12/100 `商品DN价(元)`,
b.sku_real_point `商品单价`,
c.front_category_id `front_category_id`,
ifnull(f.`前台分类`,ifnull(case when d.name in('售后养护','充电专区','精品','生活服务') then d.name else null end,
	case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end)) `前台分类`,
case when b.spu_type = '51121001' then '沃尔沃精品'
	when b.spu_type = '51121002' then '第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
	when b.spu_type = '51121006' then '一件代发'
	when b.spu_type = '51121007' then '经销商端产品'
    when b.spu_type = '51121008' then '虚拟服务权益'
    else null end `商品类型`,
case when b.spu_type = '51121003' and b.spu_name like '%桩%' then '是' else '否' end `是否保养类卡券_充电桩`,
b.fee/100 `总金额(元)`,
round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
b.sku_total_fee/100 `商品金额(元)`,
b.express_fee/100 `运费金额(元)`,
b.coupon_fee/100 `优惠券抵扣金额(元)`,
round(b.point_amount/3+b.pay_fee/100,2) `实付金额(元)`,
b.pay_fee/100 `现金支付金额(元)`,
b.point_amount `支付V值(个)`,
b.sku_num `兑换数量`,
a.create_time `下单时间`,
date_format(a.create_time,'%Y-%m') `下单年月`,
a.pay_time `支付时间`,
case when b.pay_fee = 0 then '纯V值支付' when b.point_amount = 0 then '纯现金支付' else '混合支付' end `支付方式`,
h.dealer_code `下单经销商Code`,
case when b.spu_type = '51121001' then 'VOLVO仓商品' 
	when b.spu_type = '51121002' then 'VOLVO仓第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '京东仓商品'
	else null end `仓库`,
case when b.status = '51301001' then '待付款'
	when b.status = '51301002' then '待发货' 
	when b.status = '51301003' then '待收货' 
	when b.status = '51301004' then '收货确认'
	when b.status = '51301005' then '退货中'
	when b.status = '51301006' then '交易关闭'  
	else null end `订单商品状态`,
case when a.status = '51031001' then '预创建'
	when a.status = '51031002' then '待付款'
	when a.status = '51031003' then '待发货'
	when a.status = '51031004' then '待收货'
	when a.status = '51031005' then '已完成'
	when a.status = '51031006' then '交易关闭'
	when a.status = '51031007' then '创建失败'
	else null end `订单状态`,
case when a.close_reason = '51091001' then '超时未支付'
	when a.close_reason = '51091002' then '用户取消订单'
	when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end `订单关闭原因`,
case when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end `退货原因`,
g.`退货状态` `退货状态`,
g.`退货数量` `退货数量`,
g.`退回V值` `退回V值`,
g.`退回时间` `退回时间`
from "order".tt_order a    -- 订单表
left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1    -- 订单商品表
left join goods.item_spu c on b.spu_id = c.id    -- 前台spu表(获取商品前台专区ID)
left join goods.front_category d on d.id = c.front_category1_id     -- 前台专区列表(获取前台专区名称)
left join goods.item_sku e on e.id = b.sku_id      -- 前台sku表(获取商品DN价)
left join
(
	-- 获取前台分类[充电专区]的商品
	select distinct j.id as spu_id,j.name `name`,f2.name as `前台分类`
	from goods.item_spu j
	left join goods.item_sku i on j.id = i.spu_id 
	left join goods.item_sku_channel s on i.id = s.sku_id 
	left join goods.front_category f2 on s.front_category1_id = f2.id
	where 1=1
	and f2.name='充电专区'
	and s.is_deleted = 0
	and f2.is_deleted = 0
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
	from "order".tt_sales_return_order so
	left join "order".tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = 0
	and sp.is_deleted = 0
	GROUP BY 1,2,3,4
) g on a.order_code = g.order_code and b.product_id = g.product_id
inner join
(
	-- 扫一店一码对应的经销商Code
	select
	a.order_code order_code,
	a.order_product_id order_product_id,
	a.dealer_code dealer_code,
	a.create_time create_time
	from "order".tt_order_product_ex a
	where 1=1
	and a.dealer_code in ('ISHD01')   -- 北京车展期间的识别码、深圳高尔夫的识别码
	and a.is_deleted = 0
) h on a.order_code = h.order_code and b.product_id = h.order_product_id    -- 这里先用子单号关联，可能存在问题。
where 1=1
 and a.pay_time >= '2024-04-27' and a.pay_time < '2024-05-16'   -- 订单支付时间
and a.is_deleted <> 1
and a.type = '31011003'  -- 订单类型：沃世界商城订单
 and a.separate_status = '10041002' -- 拆单状态：否
 and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
 and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and g.order_code is null  -- 剔除退款订单
order by a.create_time