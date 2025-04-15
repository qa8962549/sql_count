-- 评论明细
select
teh.user_id 会员ID,
tmi.MEMBER_PHONE 沃世界注册手机号,
teh.content 评论内容,
teh.create_time 评论时间,
-- teh.evaluation_source 评论来源,
teh.liked_count 点赞数
from comment.tt_evaluation_history teh 
left join `member`.tc_member_info tmi on teh.user_id = tmi.ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where teh.object_id='Huu6fD7tsT'
and teh.is_deleted = 0
order by teh.liked_count desc

-- 商城简洁版
select x.会员id,
x.沃世界注册手机号,
sum(x.实付金额)
from 
(
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,h.MEMBER_PHONE 沃世界注册手机号
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.sku_code
,b.sku_real_point 商品单价
,b.coupon_fee/100 优惠券抵扣金额
,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,a.create_time 兑换时间
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
left join(
	#V值退款成功记录
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
where a.create_time >= '2022-02-12 12:00:00' 
-- and a.create_time < '2022-02-17'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and b.spu_id in (2595,
2790,
2789,
2939,
2961,
2547,
2581
)  -- 筛选7种商品
order by a.create_time
) x group by 1
order by 3 desc 