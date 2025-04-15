
-- 商城新春活动数据需求-商品下单 促销商品
select 
distinct 
m.`商品SPU_ID`,
m.`原价下单销量（含退单）`,
m.`促销价下单销量（含退单）`,
m.`销量（含退单）` `不区分原价促销价的销量（包含退单）`,
m.`退单量`,
m.`销售额`,
x2.viewPV,
x2.viewUV,
x2.btnUV,
x.`加购数量`,
m.`下单用户数`,
m.`下单用户数`/x2.viewUV `下单转化率`
from 
	(
	select 
	m.`商品SPU_ID` `商品SPU_ID`,
	count(distinct m.`订单号`) `销量（含退单）`,
	count(case when `退回时间` is not null then 1 else null end) `退单量`,
	sum(m. `实付金额(元)`) `销售额`,
	count(distinct m.`下单人会员ID`) `下单用户数`,
	count(case when m.promotion_id is null then 1 else null end )`原价下单销量（含退单）`,
	count(case when m.promotion_id is not null then 1 else null end )`促销价下单销量（含退单）`
	from 
	(
		-- 1、商城订单明细(CK)
		select
		distinct 
		a.order_code `订单号`,
		ex.promotion_id promotion_id,
		a.user_id `下单人会员ID`,
		a.user_phone `下单人手机号`,
		m.member_name member_name,
		m.is_vehicle is_vehicle,
		b.sku_code `商品货号`,
		b.product_id `product_id`,
		d.part_number `PN号`,
		b.spu_name `兑换商品`,
		b.spu_id `商品SPU_ID`,
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
		left join ods_orde.ods_orde_tt_order_ex_d ex on a.order_code =ex.order_code  
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
		where 1=1
--		and a.create_time >='2025-02-01' 
--		and a.create_time <'2025-03-04'-- 订单时间
		and a.create_time >='2025-03-08' 
		and a.create_time <'2025-04-08'-- 促销时间
		and a.is_deleted <> 1
		and b.is_deleted <> 1
		and a.type = '31011003'  -- 订单类型：沃世界商城订单
		and a.separate_status = '10041002' -- 拆单状态：否
		and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
		and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	--	and h.order_code is null  -- 剔除退款订单
	--	and `前台分类`='精品'
		and b.spu_id in 
			('4118',
			'4117',
			'4119',
			'4117',
			'4036',
			'3837',
			'3966',
			'3964',
			'3109',
			'3244',
			'3581',
			'3726',
			'3892',
			'3883')
	--	and a.order_code='971419392234'
	--	and a.user_id='6454828'
		order by a.create_time
	) m
	group by 1 
	order by 1 
)m 
left join (	
		-- 购物车加购
		select
		a.item_spu_id spu_id, 
		sum(a.count) `加购数量`
		from ods_masi.ods_masi_cart_d a
		left join ods_good.ods_good_item_sku_d b on a.item_sku_id = b.id
		where 1=1
		and b.status <> '60291004'  -- 剔除已下架
--		and a.add_time>='2025-02-01'
--		and a.add_time<'2025-03-04'
		and a.add_time>='2025-03-08'
		and a.add_time<'2025-04-08'
		group by 1 )x on x.spu_id=m.`商品SPU_ID`
left join
(
	select a.var_product_id var_product_id
	,c.code PN
	,d.name `商品名称`
	,count(case when event_key='Page_entry' then usr_merged_gio_id else null end) viewPV
	,count(distinct case when event_key='Page_entry' then usr_merged_gio_id else null end) viewUV
	,count(distinct case when event_key='Button_click' then usr_merged_gio_id else null end) btnUV
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
	left join ods_good.ods_good_item_sku_d c on c.spu_id::varchar=a.var_product_id::varchar
	left join ods_good.ods_good_item_spu_d d on d.id::varchar=a.var_product_id::varchar
	where 1=1
	and client_time>='2025-02-01'
--	and event_time>='2025-02-01'
--	and event_time<'2025-03-04'
	and event_time>='2025-03-08'
	and event_time<'2025-04-08'
	and event_key in ('Page_entry','Button_click')
	and var_page_title='商品详情页'	
	and a.var_product_id in 
		('4118',
		'4117',
		'4119',
		'4117',
		'4036',
		'3837',
		'3966',
		'3964',
		'3109',
		'3244',
		'3581',
		'3726',
		'3892',
		'3883')
	group by 1,2,3
	order by 1,2,3
)x2 on x2.var_product_id::String=m.`商品SPU_ID`::String
	



-- 商城新春活动数据需求-商品下单
select 
distinct 
m.`商品SPU_ID`,
m.`销量（含退单）`,
m.`退单量`,
m.`销售额`,
x2.viewPV,
x2.viewUV,
x2.btnUV,
x.`加购数量`,
m.`下单用户数`,
m.`下单用户数`/x2.viewUV `下单转化率`
from 
	(
	select 
	m.`商品SPU_ID` `商品SPU_ID`,
	count(distinct m.`订单号`) `销量（含退单）`,
	count(case when `退回时间` is not null then 1 else null end) `退单量`,
	sum(m. `实付金额(元)`) `销售额`,
	count(distinct m.`下单人会员ID`) `下单用户数`
	from 
	(
		-- 1、商城订单明细(CK)
		select
		distinct 
		a.order_code `订单号`,
		a.user_id `下单人会员ID`,
		a.user_phone `下单人手机号`,
		m.member_name member_name,
		m.is_vehicle is_vehicle,
		b.sku_code `商品货号`,
		b.product_id `product_id`,
		d.part_number `PN号`,
		b.spu_name `兑换商品`,
		b.spu_id `商品SPU_ID`,
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
		where 1=1
		and a.create_time >='2025-02-01' 
		and a.create_time <'2025-03-04'-- 订单时间
--		and a.create_time >='2025-03-08' 
--		and a.create_time <'2025-04-08'-- 促销时间
		and a.is_deleted <> 1
		and b.is_deleted <> 1
		and a.type = '31011003'  -- 订单类型：沃世界商城订单
		and a.separate_status = '10041002' -- 拆单状态：否
		and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
		and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	--	and h.order_code is null  -- 剔除退款订单
	--	and `前台分类`='精品'
		and b.spu_id in 
			('4118',
			'4117',
			'4119',
			'4117',
			'4036',
			'3837',
			'3966',
			'3964',
			'3109',
			'3244',
			'3581',
			'3726',
			'3892',
			'3883')
	--	and a.order_code='971419392234'
	--	and a.user_id='6454828'
		order by a.create_time
	) m
	group by 1 
	order by 1 
)m 
left join (	
		-- 购物车加购
		select
		a.item_spu_id spu_id, 
		sum(a.count) `加购数量`
		from ods_masi.ods_masi_cart_d a
		left join ods_good.ods_good_item_sku_d b on a.item_sku_id = b.id
		where 1=1
		and b.status <> '60291004'  -- 剔除已下架
		and a.add_time>='2025-02-01'
		and a.add_time<'2025-03-04'
--		and a.add_time>='2025-03-08'
--		and a.add_time<'2025-04-08'
		group by 1 )x on x.spu_id=m.`商品SPU_ID`
left join
(
	select a.var_product_id var_product_id
	,c.code PN
	,d.name `商品名称`
	,count(case when event_key='Page_entry' then usr_merged_gio_id else null end) viewPV
	,count(distinct case when event_key='Page_entry' then usr_merged_gio_id else null end) viewUV
	,count(distinct case when event_key='Button_click' then usr_merged_gio_id else null end) btnUV
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
	left join ods_good.ods_good_item_sku_d c on c.spu_id::varchar=a.var_product_id::varchar
	left join ods_good.ods_good_item_spu_d d on d.id::varchar=a.var_product_id::varchar
	where 1=1
	and client_time>='2025-02-01'
	and event_time>='2025-02-01'
	and event_time<'2025-03-04'
--	and event_time>='2025-03-08'
--	and event_time<'2025-04-08'
	and event_key in ('Page_entry','Button_click')
	and var_page_title='商品详情页'	
	and a.var_product_id in 
		('4118',
		'4117',
		'4119',
		'4117',
		'4036',
		'3837',
		'3966',
		'3964',
		'3109',
		'3244',
		'3581',
		'3726',
		'3892',
		'3883')
	group by 1,2,3
	order by 1,2,3
)x2 on x2.var_product_id::String=m.`商品SPU_ID`::String
	
	



-- 到店产品核销明细
select 
distinct 
	tci.coupon_name 卡券名称
	,if(dt.vin is not null ,'是','否') 是否下发过
	,dt.跟进状态 跟进状态
	,tcd.coupon_id 卡券id
	,tci.coupon_value/100 卡券面额
	,tci.coupon_code 券号
	,tcd.member_id 会员id
	,tcd.one_id cust_id
	,tmi.member_name 会员昵称
	,tmi.real_name 姓名
--	,tmi.member_phone 沃世界注册手机号
--	,top.associate_vin 购买关联vin
	,top.fee/100 总金额
	,top.create_time 下单时间
	,top.pay_fee/100 现金支付金额
	,top.point_amount 支付v值
	,declear_list.company_code 购买关联经销商code
	,top.associate_dealer 购买关联经销商
	,tcd.get_date 获得时间
	,tcd.activate_date 激活时间
	,tcd.expiration_date 卡券失效日期
	,tcd.exchange_code 核销码
	,tc.code_cn_desc 卡券状态
	,tcd.id 卡券领取id
	,tcv.核销用户名
	,tcv.核销手机号
	,tcv.核销金额
	,tcv.核销经销商
	,tcv.核销vin
	,tcv.核销时间
	,tcv.核销工单号
	,tcv.核销车牌
	,top.spu_id
	,tcd.is_refunded 是否退款
	,h.退回时间
from coupon.tt_coupon_detail tcd 
left join coupon.tt_coupon_info tci on tci.id =tcd.coupon_id and tci.is_deleted =0
left join "member".tc_member_info tmi on tmi.id =tcd.member_id and tmi.is_deleted =0
left join "order".tt_order_rt_coupon torc on torc.coupon_id =tcd.id and torc.is_deleted =0
left join "order".tt_order_product top on top.order_code =torc.order_code and top.product_id = torc.product_id and top.is_deleted =0
left join "order".tt_order to2 on to2.order_code =top.order_code 
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
		else null end 退货状态,
	sum(sp.sales_return_num) 退货数量,
	sum(so.refund_point) `退回V值`,
	max(so.create_time) 退回时间
	from "order".tt_sales_return_order so
	left join "order".tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = 0
	and sp.is_deleted = 0
	GROUP BY 1,2,3,4
) h on to2.order_code = h.order_code and top.product_id = h.product_id
left join organization.tm_company declear_list on declear_list.company_name_cn = top.associate_dealer and declear_list.IS_DELETED = 0 and COMPANY_TYPE = 15061003 
left join "dictionary".tc_code tc on tc.code_id =tcd.ticket_state and tc.is_deleted ='N'
left join (
	select v.coupon_detail_id
	,string_agg(v.customer_name,';' order by id) 核销用户名
	,string_agg(v.customer_mobile,';' order by id) 核销手机号
	,string_agg(round(v.verify_amount/100,2),';' order by id) 核销金额
	,string_agg(v.dealer_code,';' order by id) 核销经销商
	,string_agg(v.vin,';' order by id) 核销VIN
	,string_agg(v.operate_date,';' order by id) 核销时间
	,string_agg(v.order_no,';' order by id) 核销工单号
	,string_agg(v.PLATE_NUMBER,';' order by id) 核销车牌
	from coupon.tt_coupon_verify v  -- 卡券核销信息表
	where  v.is_deleted=0
	group by v.coupon_detail_id
) tcv on tcv.coupon_detail_id =tcd.id
left join(
		SELECT
		    a.vin,
		    a.tel,
		    b.code_cn_desc AS 跟进状态,
		    a.item_name,
		    advise_in_date,
		    (string_to_array(a.item_name, '-'))[1] AS part1, -- 拆分后的第一部分
		    (string_to_array(a.item_name, '-'))[2] AS part2 -- 拆分后的第二部分
		FROM dms_manage.tt_invite_vehicle_record a
		LEFT JOIN dictionary.tc_code b ON a.follow_status = b.code_id
		WHERE a.created_at >= '2025-03-08'
		    AND a.invite_type = 82381011  --厂端自建
		    AND a.advise_in_date = '2025-04-30 00:00:00.000' -- 业务手动录入，对应春服
		    ) dt on dt.vin =top.associate_vin and tci.coupon_name  like concat('%',part1,'%')
	where 1=1
	and date(tcd.get_date) >= '2025-03-08' 
	and date(tcd.get_date) < '2025-04-08' 
	and tcd.is_deleted=0 
--	and tci.coupon_code in ('KQ202411190003',
--'KQ202411190004',
--'KQ202411210001',
--'KQ202411190002',
--'KQ202411190001'
--)
	and top.spu_id in ( '4111', 
 '4114', 
 '4120', 
 '4118', 
 '4119', 
 '4117', 
 '4112', 
 '4113', 
 '3930', 
 '4125', 
 '3741', 
 '4077', 
 '3214', 
 '4078', 
 '3215', 
 '4109', 
 '3319')
order by tcd.get_date desc 




	-- 养修预约
	select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.company_name_cn "经销商名称",
       ta.ONE_ID "车主oneid",
--       tam.OWNER_ONE_ID,
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
       x2.date_create `提交预约（任务列表)`
	from ods_cyap.ods_cyap_tt_appointment_d ta
	left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	left join ods_orga.ods_orga_tm_company_cur tc2 on tc2.company_code =ta.OWNER_CODE 
	left JOIN ods_dict.ods_dict_tc_code_d tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join ods_memb.ods_memb_tc_member_info_cur tmi on ta.ONE_ID = tmi.cust_id 
	join 
		(-- 浏览过活动页-活动: 通过活动页面-点击回厂养护，并提交养修预约。点击时间早于预约时间
		select distinct a.`user` as distinct_id,
		toDateTime(a.client_time ) as `time`
		from ods_gio.ods_gio_event_d a
		where length(a.`user`)<9 
		and date(a.event_time) >= date('2025-03-08') -- and date(a.event_time) < date( '2025-04-08'  )+INTERVAL 7 day
		and a.client_time >= '2025-03-09'  
		and a.client_time <  '2025-04-08'  
		and event_key='Button_click'
		and var_page_title ='好礼集盒 打卡100%有奖'
		and var_activity_name='2025年沃尔沃汽车春季服务节'
--		and var_subtitle_name ='本轮限定任务'
		and var_content_title ='预约养修'
		and var_btn_name ='去完成'
		and (((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App'))--app	
		)x on toString(x.distinct_id) =toString(ta.ONE_ID) 
	left join 
			(select distinct m.cust_id,
			tr.date_create
		from ods_mms.ods_mms_task_record_d tr
		join ods_memb.ods_memb_tc_member_info_cur m on tr.member_id =m.id::varchar
		where tr.task_id in (162,166,170,174) -- C_预约养修
		and tr.deleted =0
		and tr.date_create >= '2025-03-08' 
		and tr.date_create < '2025-04-08' 
		)x2 on  toString(x2.cust_id) =toString(ta.ONE_ID) 
	where 1=1
	and toDateTime(x2.date_create)<=ta.CREATED_AT
	and tam.IS_DELETED <>1
	and ta.CREATED_AT >= '2025-03-09'
	and ta.CREATED_AT <'2025-04-08'
	and ta.DATA_SOURCE ='C'
	and ta.APPOINTMENT_TYPE =70691005
	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂
	

	
-- 浏览过活动页-活动: 通过活动页面-点击回厂养护，并提交养修预约。点击时间早于预约时间
		select distinct a.`user` as distinct_id,
		toDateTime(a.client_time ) as `time`
		from ods_gio.ods_gio_event_d a
		where length(a.`user`)<9 
		and date(a.event_time) >= date('2025-03-08') -- and date(a.event_time) < date( '2025-04-08'  )+INTERVAL 7 day
		and a.client_time >= '2025-03-09'  
		and a.client_time <  '2025-04-08'  
		and event_key='Button_click'
		and var_page_title ='好礼集盒 打卡100%有奖'
		and var_activity_name='2025年沃尔沃汽车春季服务节'
--		and var_subtitle_name ='本轮限定任务'
		and var_content_title ='预约养修'
		and var_btn_name ='去完成'
		and (((a.`$platform` in('iOS','Android','HarmonyOS') and left(a.`$client_version`,1)='5') or a.var_channel ='App'))--app	
		
	
select
case when tr.task_id in (161,165,169,173) then 'A_分享活动'
	when tr.task_id in (160) then 'B_完善个人信息'
	when tr.task_id in (162,166,170,174) then 'C_预约养修'
	when tr.task_id in (163,167,171,175) then 'D_预约试驾'
	when tr.task_id in (164,168,172,176) then 'E_商城下单299元' 
	end as behavior_name,
count(distinct case when m.is_vehicle =1 then tr.id end) as `完成任务次数（车主）`,
count(distinct case when m.is_vehicle =0 then tr.id end) as `完成任务次数（粉丝）`,
count(distinct case when m.is_vehicle =1 then tr.member_id end) as `完成任务人数（车主）`,
count(distinct case when m.is_vehicle =0 then tr.member_id end) as `完成任务人数（粉丝）`
from ods_mms.ods_mms_task_record_d tr
join ods_memb.ods_memb_tc_member_info_cur m on tr.member_id =m.id::varchar
where tr.task_id in (160,
161,
162,
163,
164,
165,
166,
167,
168,
169,
170,
171,
172,
173,
174,
175,
176)
and tr.deleted =0
and tr.date_create >= '2025-03-08' and tr.date_create < '2025-03-29' 
group by behavior_name
	
	