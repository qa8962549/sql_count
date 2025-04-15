-- 销售概览
select 
m.平台
,SUM(m.总金额) GMV汇总
,SUM(case when m.商品类型2='保养类卡券' then m.总金额 else null end) "售后（元）"
,SUM(case when m.商品类型2='充电产品' then m.总金额 else null end) "充电（元）"
,SUM(case when m.商品类型2='精品' then m.总金额 else null end) "精品（元）"
,SUM(case when m.商品类型2='第三方卡券' then m.总金额 else null end) "第三方卡券（元）"
--SUM(m.支付V值) V值消耗,
-- sum(m.总金额) 商城销售额,
-- 	count(distinct m.订单编号) 商城订单数,
--,count(distinct m.会员ID)下单用户数
--,round((sum(m.总金额)/count(distinct m.会员ID)),1)/round((sum(m.兑换数量)/count(distinct m.会员ID)),1) "客单价/客单件数"
-- sum(m.现金支付金额) 现金,
-- sum(m.兑换数量) 总件数
from 
(select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.spu_bus_id
,b.sku_code
,b.sku_real_point 商品单价
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,CASE  
	WHEN b.spu_type=51121001 THEN '精品' 
	WHEN b.spu_type=51121002 THEN '第三方卡券' 
	WHEN b.spu_type=51121003 and f.name not like '%充电%' THEN '保养类卡券' 
	WHEN f.name like '%充电%' THEN '充电产品' 
	WHEN b.spu_type=51121004 THEN '精品'
	WHEN b.spu_type=51121006 THEN '一件代发'
	WHEN b.spu_type=51121007 THEN '经销商端产品' ELSE null end 商品类型2
,b.fee/100 总金额
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
,f.name 分类
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 商品状态
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因
,e.`退货状态`
,e.`退货数量`
,e.退回V值
,e.退回时间
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
where a.create_time >= '2023-06-01' and a.create_time <'2023-06-19'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) m
group by 1 
order by 1 


-- 销售商品概览2  _注意修改时间
select 
m.spu_id,
m.兑换商品,
 sum(m.兑换数量) 总件数,
  sum(m.总金额) 商城销售额
from 
(select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.spu_bus_id
,b.sku_code
,b.sku_real_point 商品单价
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,CASE  
	WHEN b.spu_type=51121001 THEN '精品' 
	WHEN b.spu_type=51121002 THEN '第三方卡券' 
	WHEN b.spu_type=51121003 and f.name not like '%充电%' THEN '保养类卡券' 
	WHEN f.name like '%充电%' THEN '充电产品' 
	WHEN b.spu_type=51121004 THEN '精品'
	WHEN b.spu_type=51121006 THEN '一件代发'
	WHEN b.spu_type=51121007 THEN '经销商端产品' ELSE null end 商品类型2
,b.fee/100 总金额
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
,f.name 分类
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 商品状态
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 关闭原因
,e.`退货状态`
,e.`退货数量`
,e.退回V值
,e.退回时间
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
where 1=1
--and a.create_time >= '2023-05-01' and a.create_time <'2023-05-19'   -- 518
and a.create_time >= '2023-06-01' and a.create_time <'2023-06-19'   -- 618
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and b.spu_id in 
('3357','3261','3328','3624','3513','3214',
'3511','3215','3595','3596','3597')
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) m
group by 1 
order by 1 


-- 卡券领用核销明细 售后卡券 总
select 
date_format(x.获得时间,'%Y-%m-%d') 日期,
x.coupon_id,
x.卡券状态,
concat(x.coupon_id,x.卡券状态),
 count(case when x.IS_VEHICLE=1 then x.id else null end) 车主,
 count(case when x.IS_VEHICLE=0 then x.id else null end) 粉丝,
count(x.id)
from 
	(
	SELECT 
	distinct 
	a.id,
	a.one_id,
	a.coupon_id,
	tmi.IS_VEHICLE,
	b.id coupon_id卡券ID,
	b.coupon_name 卡券名称,
	a.left_value/100 面额,
	b.coupon_code 券号,
	tmi.ID 沃世界会员ID,
	tmi.MEMBER_NAME 会员昵称,
	tmi.REAL_NAME 姓名,
	tmi.MEMBER_PHONE 沃世界绑定手机号,
--	a.vin 购买VIN,
	a.get_date 获得时间,
	a.activate_date 激活时间,
	c.associate_vin vin,
	c.associate_dealer 经销商,
	tc.company_code 经销商code,
	a.expiration_date 卡券失效日期,
	CAST(a.exchange_code as varchar) 核销码,
-- 	case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
--  	WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台类型,
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
	left join 
	(select tmi.*
	,row_number ()over(partition by tmi.cust_id order by tmi.create_time desc ) rk
	from `member`.tc_member_info tmi 
	where tmi.is_deleted = 0 and tmi.member_status <> '60341003'
	)tmi on a.one_id = tmi.CUST_ID and tmi.member_phone <>'*' and tmi.rk=1
	left join "order".tt_order_product c on a.order_code = c.order_code and c.is_deleted <> 1 -- 订单商品表
	left join organization.tm_company tc on c.associate_dealer =tc.company_short_name_cn and tc.is_deleted <>1 --经销商表
	LEFT JOIN (
	select v.coupon_detail_id
	,v.customer_name 核销用户名
	,v.customer_mobile 核销手机号
	,v.verify_amount 
	,v.dealer_code 核销经销商
	,v.vin 核销VIN
	,v.operate_date 核销时间
	,v.order_no 订单号
	,v.PLATE_NUMBER
	from coupon.tt_coupon_verify v 
	where  v.is_deleted=0
	order by v.create_time 
	) v ON v.coupon_detail_id = a.id
	WHERE 1=1
	and a.coupon_id in ('4898',
'4899')
--	and a.coupon_id ='4659'
	and a.get_date >= '2023-06-01'
	and a.get_date < curdate() 
	and a.is_deleted=0 
	order by a.get_date desc 
)x 
where x.卡券状态='已失效' or x.卡券状态='已核销'
group by 1,2,3
order by 1 desc,2,3