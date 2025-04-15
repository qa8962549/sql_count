-- 1、商城售后卡券订单
select
date_format(a.兑换时间,'%Y-%m') 年月,
sum(a.总金额) 商城售后卡券销售金额,
count(distinct a.会员ID) 商城售后卡券购买用户数,
count(distinct a.订单编号) 商城售后卡券订单数
from
(
select
a.order_code 订单编号,
ifnull(a.parent_order_code,a.order_code) 母单号,
case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end 订单来源,
a.user_id 会员ID,
h.cust_id 会员One_ID,
a.user_name 会员姓名,
a.user_phone 会员手机号,
b.sku_code 商品货号,
b.spu_name 兑换商品,
b.spu_bus_id,
b.sku_id,
b.sku_real_point 商品单价,
sk.cls12 DN价,
sk.coupon_id,
sk.coupon_code,
sk.coupon_name,
j.front_category_id,
ifnull(f.name,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '生活服务' 
	WHEN 51121003 THEN '售后养护' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '精品'
	WHEN 51121007 THEN '经销商端产品' ELSE null end) 前台分类,
CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券'
	WHEN 51121003 THEN '保养类卡券'
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型,
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
left join coupon.tt_coupon_detail dd on sk.coupon_id = dd.coupon_id
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
where a.create_time >= '2022-01-01' and a.create_time < '2023-09-01'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and b.spu_type = '51121003'   -- 保养类卡券
and b.spu_name not in
(
'12L加热款车载冰箱',
'40元无门槛代驾抵扣券',
'625单读图书兑换券',
'FIKA券',
'FIKA券 上海iapm环贸店可用',
'测试01',
'车载冰箱优惠券',
'单读图书专属主题套餐兑换券',
'儿童增高座椅',
'帆书（原樊登读书）年卡兑换券',
'精品200元无门槛抵扣券',
'三亚XC40纯电单日体验券',
'商城精品满100元减50元优惠券',
'售后200元无门槛抵扣券',
'无门槛代驾抵扣券40元',
'星巴克服务兑换券',
'星巴克服务兑换券 指定4S店用',
'星巴克咖啡服务兑换券',
'验证SKU浮层',
'婴儿安全座椅'
)
order by a.create_time
) a
group by 1
order by 1


-- 2、售后工单总金额、人数、工单数
select
date_format(o.ro_create_date,'%Y-%m') 年月,
sum(o.balance_amount) 工单总金额,
count(distinct o.owner_one_id) 人数三,
count(distinct o.ro_no) 工单数 
from cyx_repair.tt_repair_order o
where o.is_deleted = 0
and o.repair_type_code <> 'P'
and o.ro_status = '80491003'    -- 已结算工单
and o.ro_create_date >= '2022-01-01'
group by 1
order by 1




-------------------------------------- 研发提供的逻辑，根据逻辑写的SQL --------------------------------------

我们目前调研到的逻辑，
1、是通过结算单表tt_balance_accounts表，关联工单优惠明细表 (库：cyx_repair，表：tt_ro_preferential），
关联主键：结算单号balance_no+经销商代码owner_code，如果关联到优惠明细表中卡券id和卡券领用id不为空（coupons_id，receive_id），（需要与开发确认该逻辑）则这个结算单是是用了售后卡券的；
2、如果还需要限制使用的卡券是商城购买的售后卡券，需要把卡券领用id 关联卡券明细表（库：coupon，表：tt_coupon_detail）关联主键 tt_ro_preferential.receive_id = tt_coupon_detail.id，限制卡券来源coupon_source字段 = 83241003 商城购买；
3、再把卡券ID 关联卡券主数据表（库：coupon，表：tt_coupon_info），关联主键 tt_ro_preferential.coupons_id = tt_coupon_info.id，限制使用场景use_scenes字段 = 83171002 线下门店；
4、最后把筛选出的结算单，再关联回工单表，关联主键：tt_balance_accounts.repair_no + owner_code = tt_repair_order.RO_NO + OWNER_CODE，统计结算金额、送修人手机号、和工单数

-- 3、根据逻辑写SQL（逻辑肯定有问题，字段重复，无法关联商城用户购买的卡券，需要重新对字段进行探查）
select date_format(x.工单开单时间,'%Y-%m') 年月,
sum(x.工单金额) 线下工单（使用商城售后卡券）销售金额,
count(distinct x.id) 线下工单（使用商城售后卡券）用户数,
count(distinct x.工单号) 线下工单（使用商城售后卡券）工单数
from 
	(
	select
	distinct
	a.ro_no 工单号,
--	c.one_id,
	m.id,
	e.balance_amount 工单金额,
	e.ro_create_date 工单开单时间,
	a.owner_code 经销商Code,
	a.balance_no 结算单号,
	--a.ro_no 工单号,
	a.labour_amount 工时费,
	a.repair_part_amount 维修材料费,
	a.sum_amount 汇总金额,
	a.receive_amount 收款金额,
	a.balance_time 结算时间,
	a.real_labour_fee 实收工时费,
	--e.balance_amount 工单金额,
	a.par_real_sum 实收材料费,
--	b.order_no 业务单据,
--	b.preferential_name 卡券名称,
--	b.preferential_amount 优惠金额,
--	c.coupon_id 卡券ID,
--	c.vin,
--	c.ticket_state 卡券状态,
	------ CAST(c.exchange_code as varchar) 核销码,
	e.deliverer_mobile 送修人手机号
	from cyx_repair.tt_balance_accounts a
	left join (select b.*
		,row_number ()over(partition by b.receive_id order by b.created_at desc )rk
		from cyx_repair.tt_ro_preferential b
		where b.is_deleted=0 )b
	on a.balance_no = b.balance_no and a.owner_code = b.owner_code and b.rk=1   -- 关联优惠明细表
	left join coupon.tt_coupon_detail c on b.receive_id = c.id and c.coupon_source = '83241003'   -- 限制卡券来源：商城购买
	-- left join coupon.tt_coupon_info d on c.coupon_id = d.id and d.use_scenes = '83171002'    -- 限制卡券是线下门店使用
	left join
	(
		-- 一个one_id对应多个会员ID
		select
		m.cust_id,m.id
		from
		(
			select
			m.CUST_ID,
			max(m.ID) mid
			from member.tc_member_info m 
			where m.member_status <> 60341003 and m.is_deleted = 0
			GROUP BY 1
		) a
		left join member.tc_member_info m on a.mid = m.ID
	) m on c.one_id = m.cust_id
	join cyx_repair.tt_repair_order e on a.ro_no = e.ro_no and a.owner_code = e.owner_code
	where a.is_deleted = 0
	and b.coupons_id is not null and b.receive_id is not null   -- 优惠明细表中卡券id和卡券领用id不为空，能说明是用户使用了售后卡券
--	and b.preferential_type='优惠券'
	and c.id is not null   -- 使用的卡券来源是商城购买的售后卡券
	and c.coupon_state <>'31061004' -- 剔除已失效卡券
	and e.repair_type_code <> 'P'
	and e.is_deleted =0
	-- and d.id is not null   -- 仅限线下门店使用
	-- and a.pay_off='10041001' -- 订单是否结清
	and e.ro_create_date >= '2022-01-01')x 
group by 1 
order by 1

select count(distinct owner_one_id )
from cyx_repair.tt_repair_order
where  owner_one_id  is not null 

select count(distinct one_id  )
from cyx_repair.tm_owner 
where  one_id is not null 