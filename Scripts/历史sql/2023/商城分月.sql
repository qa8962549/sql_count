
	-- 商城订单
select 
date_format(m.兑换时间,'%Y-%m') 月份,
count(distinct case when m.支付方式='纯现金支付' then m.会员ID else null end) 纯现金支付订单人数,
count(distinct  case when m.支付方式='纯现金支付' then m.订单编号  else null end) 纯现金支付订单数,
SUM(case when m.支付方式='纯现金支付' then m.总金额 else null end) 纯现金支付订单总金额,
count(distinct case when m.支付方式='纯V值支付' then m.会员ID else null end) 纯V值支付订单人数,
count(distinct  case when m.支付方式='纯V值支付' then m.订单编号  else null end) 纯V值支付订单数,
SUM(case when m.支付方式='纯V值支付' then m.总金额 else null end) 纯V值支付订单总金额,
count(distinct case when m.支付方式='混合支付' then m.会员ID else null end) 混合支付订单人数,
count(distinct  case when m.支付方式='混合支付' then m.订单编号  else null end) 混合支付订单数,
SUM(case when m.支付方式='混合支付' then m.总金额 else null end) 混合支付订单总金额,
SUM(case when m.支付方式='混合支付' then m.现金支付金额 else null end) 混合支付现金金额,
SUM(case when m.支付方式='混合支付' then m.支付V值 else null end) 混合支付V值数量
from 
(
	select
	a.order_code 订单编号,
	ifnull(a.parent_order_code,a.order_code) 母单号,
	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
		WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
		else null end 订单来源,
	a.user_id 会员ID,
	a.user_name 会员姓名,
	a.user_phone 会员手机号,
	a.receiver_name 收货姓名,
	a.receiver_phone 收货手机号,
	concat
	(
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
	) AS 收货地址,
	b.sku_code 商品货号,
	b.spu_name 兑换商品,
	b.spu_bus_id,
	b.spu_id,
	b.sku_id,
	b.sku_bus_id,
	b.sku_real_point 商品单价,
	sk.cls12 DN价,
	j.front_category_id,
	CASE b.spu_type 
		WHEN 51121001 THEN '精品' 
		WHEN 51121002 THEN '第三方卡券'
		WHEN 51121003 THEN '保养类卡券'
		WHEN 51121004 THEN '精品'
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
		WHEN 51121008 THEN '车辆权益'
		ELSE null end 商品类型,
	ty.exchange_type_name 兑换类型,
	b.fee/100 总金额,
	b.sku_total_fee/ 100 商品金额,
	b.express_fee/ 100 运费金额,
	b.coupon_fee/100 优惠券抵扣金额,
	b.pay_fee/100 现金支付金额,
	b.point_amount 支付V值,
	b.sku_num 兑换数量,
	CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品' 
		WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '京东仓商品'
		ELSE NULL END AS 仓库,
	CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
		END AS 订单状态,
	CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
		END AS 订单商品状态,
	a.create_time 兑换时间,
	a.pay_time 支付时间,
	b.product_id 商城兑换id,
	case 
		when b.pay_fee=0 then '纯V值支付'
		when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`,
	e.`退货状态`,
	e.退回时间,
	e.退回V值,
	e.`退货数量`,
	CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因,
	e.refund_express_code 退货物流单号,
	e.eclp_rtw_no 京东退货单号,
	d.delivery_status,
	d.express_company 快递公司,
	d.express_code 快递单号
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
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
	where a.create_time >= '2023-01-01' and a.create_time < '2023-10-01'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	--and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	--and e.order_code is null  -- 剔除退款订单
	order by a.create_time)m
	group by rollup(1)
	order by 1