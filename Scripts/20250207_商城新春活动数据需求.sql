-- OKR口径GMV
select m.`下单人会员ID`,
m.`下单人手机号`,
m.member_name `会员昵称`,
m.is_vehicle `用户类型`,
--m.`下单时间`,
--m.`订单号`,
arrayStringConcat(groupArray(m.`下单时间`), ', ') `下单时间`,
arrayStringConcat(groupArray(m.`订单号`), ', ') AS concatenated_values,
SUM(m.`实付金额(元)`) `总计`
from 
(-- 1、商城订单明细(CK)
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
	m.member_name member_name,
	m.is_vehicle is_vehicle,
b.sku_code `商品货号`,
b.product_id `product_id`,
d.part_number `PN号`,
b.spu_name `兑换商品`,
b.spu_id `商品SPU_ID`,
b.sku_id `商品SKU_ID`,
b.sku_code `商品编码`,
b.sku_price/100 `商品零售含税价(元)`,
d.cls12/100 `商品DN价(元)`,
b.sku_real_point `商品单价`,
c.front_category_id `front_category_id`,
ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,
	case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end) `前台分类`,
case when b.spu_type = '51121001' then '沃尔沃精品'
	when b.spu_type = '51121002' then '第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
	when b.spu_type = '51121006' then '一件代发'
	when b.spu_type = '51121007' then '经销商端产品'
    when b.spu_type = '51121008' then '虚拟服务权益'
    else null end `商品类型`,
case when d.boutique_type = 0 then '售后附件'
	else null end `精品二级分类`,
case when b.spu_type = '51121003' and b.spu_name like '%桩%' then '是' else '否' end `是否保养类卡券_充电桩`,
b.fee/100 `总金额(元)`,
round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
b.sku_total_fee/100 `商品金额(元)`,
b.express_fee/100 `运费金额(元)`,
ifnull(j.id,k.id) `卡券唯一ID`,
ifnull(j.coupon_id,k.coupon_id) `优惠券卡券ID`,
ifnull(j.coupon_name,k.coupon_name) `优惠券名称`,
b.coupon_fee/100 `优惠券抵扣金额(元)`,
round(b.point_amount/3+b.pay_fee/100,2) `实付金额(元)`,
b.pay_fee/100 `现金支付金额(元)`,
b.point_amount `支付V值(个)`,
b.sku_num `兑换数量`,
a.create_time `下单时间`,
formatDateTime(a.create_time,'%Y-%m') `下单年月`,
a.pay_time `支付时间`,
case when b.pay_fee = 0 then '纯V值支付' when b.point_amount = 0 then '纯现金支付' else '混合支付' end `支付方式`,
i.dealer_code `下单经销商Code`,
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
h.`退货状态` `退货状态`,
h.`退货数量` `退货数量`,
h.`退回V值` `退回V值`,
if(h.`退回时间` > '1970-01-01 08:00:00',h.`退回时间`,null) `退回时间`
from ods_orde.ods_orde_tt_order_d a    -- 订单表
left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id and c.front_category_id is not null    -- 前台spu表(获取商品前台专区ID)
left join ods_good.ods_good_item_sku_d d on b.sku_id = d.id      -- 前台sku表(获取商品DN价)
left join
(
	-- 获取部分商品正确的前台分类代码
	select e.spu_id,e.sku_id,e.front_category1_id
	from ods_good.ods_good_item_sku_channel_d e
	where e.is_deleted = 0
	and e.front_category1_id in ('195','212','219','230')
	and e.client_id = '2b9890ef-d828-11ec-be68-00163e0ebd17'   -- APP订单
) e on e.spu_id = b.spu_id and e.sku_id = b.sku_id
left join ods_good.ods_good_front_category_d f on f.id = e.front_category1_id     -- 前台专区列表(获取前台专区名称)
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
left join
(
	-- 扫一店一码对应的经销商Code
	select
	a.order_code order_code,
	a.order_product_id order_product_id,
	a.dealer_code dealer_code,
	a.create_time create_time
	from ods_orde.ods_orde_tt_order_product_ex_d a
	where 1=1
	and a.dealer_code <> ''
	and a.is_deleted = 0
) i on a.order_code = i.order_code and b.product_id = i.order_product_id
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id id,
	tcv.order_no order_no,
	tcv.coupon_id coupon_id,
	tci.coupon_name coupon_name,
	tcd.one_id one_id,
	tcd.member_id member_id,
	tcd.ticket_state ticket_state
	from ods_coup.ods_coup_tt_coupon_verify_d tcv
	inner join ods_coup.ods_coup_tt_coupon_detail_d tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join ods_coup.ods_coup_tt_coupon_info_d tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	and tcv.is_deleted = 0
) j on a.order_code = j.order_no
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id id,
	tcv.order_no order_no,
	tcv.coupon_id coupon_id,
	tci.coupon_name coupon_name,
	tcd.one_id one_id,
	tcd.member_id member_id,
	tcd.ticket_state ticket_state
	from ods_coup.ods_coup_tt_coupon_verify_d tcv
	inner join ods_coup.ods_coup_tt_coupon_detail_d tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join ods_coup.ods_coup_tt_coupon_info_d tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	and tcv.is_deleted = 0
) k on ifnull(a.parent_order_code,a.order_code) = k.order_no
	join ods_memb.ods_memb_tc_member_info_cur m on toString(a.user_id) = toString(m.id) -- 会员表(获取会员信息)
	join 
	(-- 浏览会员日活动
			-- 帖子的PVUV
		select distinct a.member_id var_memberId
		from ods_cmnt.ods_cmnt_tt_view_post_cur a
		where 1=1
		and a.create_time >='2025-01-21'
		and a.create_time <'2025-02-06'
		and a.is_deleted =0
		and a.post_id in ('bFQFQEFTj8','2iOUgPfWY3')
	)x on toString(x.var_memberId) =toString(m.id) 
	where 1=1
	and a.create_time >='2025-01-21' 
	and a.create_time <'2025-02-06'-- 订单时间
	and a.is_deleted <> 1
	and b.is_deleted <> 1
and a.type = '31011003'  -- 订单类型：沃世界商城订单
and a.separate_status = '10041002' -- 拆单状态：否
and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and h.order_code is null  -- 剔除退款订单
and `前台分类`='精品'
order by a.create_time
) m
group by 1,2,3,4
order by 7 desc



-- 商城新春活动数据需求-商品下单
select 
--distinct 
m.`下单人会员ID`,
m.`下单人手机号`,
m.member_name `会员昵称`,
m.is_vehicle `用户类型`,
m.`订单号`,
m.`下单时间`,
m.`兑换商品`,
toString(m.MSRP) MSRP,
m.num `订单数量`,
m.`兑换数量`,
--arrayStringConcat(groupArray(m.`订单号`), ', ') AS concatenated_values,
m.`实付金额(元)`,
m.`支付V值(个)`
from 
(
	-- 1、商城订单明细(CK)
	select
	distinct 
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
	m.member_name member_name,
	m.is_vehicle is_vehicle,
	b.sku_code `商品货号`,
	b.product_id `product_id`,
	d.part_number `PN号`,
	b.spu_name `兑换商品`,
	b.spu_id `商品SPU_ID`,
	b.sku_id `商品SKU_ID`,
	b.sku_code `商品编码`,
	b.sku_price/100 `商品零售含税价(元)`,
	d.price_sell/100 `MSRP`,
	d.cls12/100 `商品DN价(元)`,
	b.sku_real_point `商品单价`,
	c.front_category_id `front_category_id`,
	ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,
		case when b.spu_type = '51121001' THEN '精品'
			when b.spu_type = '51121002' THEN '生活服务'
			when b.spu_type = '51121003' THEN '售后养护'
			when b.spu_type = '51121004' THEN '精品'
			when b.spu_type = '51121006' THEN '一件代发'
			when b.spu_type = '51121007' THEN '经销商端产品'
			when b.spu_type = '51121008' THEN '售后养护'
			else null end) `前台分类`,
	case when b.spu_type = '51121001' then '沃尔沃精品'
		when b.spu_type = '51121002' then '第三方卡券' 
		when b.spu_type = '51121003' then '虚拟服务卡券' 
		when b.spu_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
		when b.spu_type = '51121006' then '一件代发'
		when b.spu_type = '51121007' then '经销商端产品'
	    when b.spu_type = '51121008' then '虚拟服务权益'
	    else null end `商品类型`,
	case when d.boutique_type = 0 then '售后附件'
		else null end `精品二级分类`,
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
	a.num num,
	a.create_time `下单时间`,
	formatDateTime(a.create_time,'%Y-%m') `下单年月`,
	a.pay_time `支付时间`,
	if(h.`退回时间` > '1970-01-01 08:00:00',h.`退回时间`,null) `退回时间`
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
	left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id and c.front_category_id is not null    -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_item_sku_d d on b.sku_id = d.id      -- 前台sku表(获取商品DN价)
	left join
	(
		-- 获取部分商品正确的前台分类代码
		select e.spu_id,e.sku_id,e.front_category1_id
		from ods_good.ods_good_item_sku_channel_d e
		where e.is_deleted = 0
		and e.front_category1_id in ('195','212','219','230')
		and e.client_id = '2b9890ef-d828-11ec-be68-00163e0ebd17'   -- APP订单
	) e on e.spu_id = b.spu_id and e.sku_id = b.sku_id
	left join ods_good.ods_good_front_category_d f on f.id = e.front_category1_id     -- 前台专区列表(获取前台专区名称)
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
		join ods_memb.ods_memb_tc_member_info_cur m on toString(a.user_id) = toString(m.id) -- 会员表(获取会员信息)
		join 
		(-- 帖子的PVUV
			select distinct a.member_id var_memberId
			from ods_cmnt.ods_cmnt_tt_view_post_cur a
			where 1=1
			and a.create_time >='2025-02-09'
			and a.create_time <'2025-02-19'
			and a.is_deleted =0
			and a.post_id ='iVwZqmBBel'
		)x on toString(x.var_memberId) =toString(m.id) 
	join 
		(
		--符合条件的精品订单
		select 
		distinct 
		m.`订单号`
		from 
		(
			-- 1、商城订单明细(CK)
			select
			a.order_code `订单号`,
			ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,
				case when b.spu_type = '51121001' THEN '精品'
					when b.spu_type = '51121002' THEN '生活服务'
					when b.spu_type = '51121003' THEN '售后养护'
					when b.spu_type = '51121004' THEN '精品'
					when b.spu_type = '51121006' THEN '一件代发'
					when b.spu_type = '51121007' THEN '经销商端产品'
					when b.spu_type = '51121008' THEN '售后养护'
					else null end) `前台分类`,
			b.sku_num `兑换数量`,
			b.spu_name `兑换商品`,
			b.spu_id `商品SPU_ID`,
			b.sku_id `商品SKU_ID`,
			a.create_time
			from ods_orde.ods_orde_tt_order_d a    -- 订单表
			left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
			left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id and c.front_category_id is not null    -- 前台spu表(获取商品前台专区ID)
			left join ods_good.ods_good_item_sku_d d on b.sku_id = d.id      -- 前台sku表(获取商品DN价)
			left join
			(
				-- 获取部分商品正确的前台分类代码
				select e.spu_id,e.sku_id,e.front_category1_id
				from ods_good.ods_good_item_sku_channel_d e
				where e.is_deleted = 0
				and e.front_category1_id in ('195','212','219','230')
				and e.client_id = '2b9890ef-d828-11ec-be68-00163e0ebd17'   -- APP订单
			) e on e.spu_id = b.spu_id and e.sku_id = b.sku_id
			left join ods_good.ods_good_front_category_d f on f.id = e.front_category1_id     -- 前台专区列表(获取前台专区名称)
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
				join ods_memb.ods_memb_tc_member_info_cur m on toString(a.user_id) = toString(m.id) -- 会员表(获取会员信息)
				join 
				(-- 帖子的PVUV
					select distinct a.member_id var_memberId
					from ods_cmnt.ods_cmnt_tt_view_post_cur a
					where 1=1
					and a.create_time >='2025-02-09'
					and a.create_time <'2025-02-19'
					and a.is_deleted =0
					and a.post_id ='iVwZqmBBel'
				)x on toString(x.var_memberId) =toString(m.id) 
				where 1=1
				and a.create_time >='2025-02-09' 
				and a.create_time <'2025-02-19'-- 订单时间
				and a.is_deleted <> 1
				and b.is_deleted <> 1
			and a.type = '31011003'  -- 订单类型：沃世界商城订单
			and a.separate_status = '10041002' -- 拆单状态：否
			and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
			and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and h.order_code is null  -- 剔除退款订单
			and `前台分类`='精品'
			order by a.create_time
			)m group by 1
			having sum(m.`兑换数量`)>=3 -- 单笔订单且下单精品≥3件的用户
		)x2 on x2.`订单号`=a.order_code
	where 1=1
	and a.create_time >='2025-02-09' 
	and a.create_time <'2025-02-19'-- 订单时间
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and h.order_code is null  -- 剔除退款订单
	and `前台分类`='精品'
--	and b.spu_id='3190'
	and a.order_code='971419392234'
--	and a.user_id='6454828'
	order by a.create_time
) m
--group by 1,2,3,4,5,6
--order by 7 desc