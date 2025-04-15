-- 整体沃世界里面XC90车主是多少
SELECT count(x.member_id) XC90车主数量
from 
	(
	select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
	 )x
where x.车型='XC90'


-- 获取过V值的XC90车主数和平均获取V值量
SELECT 
count(tmi.id) 获取过V值的XC90车主数,
sum(b.获得V值) 获取V值总数,
ROUND(sum(b.获得V值)/count(tmi.id),2) 平均获取V值量
from (
		SELECT x.member_id
		from 
			(
			select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
				 from (
				 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
				 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
				 from member.tc_member_vehicle v 
				 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
				 where v.IS_DELETED=0 
				 ) v 
			 left join vehicle.tm_vehicle t on v.vin=t.VIN
			 left join basic_data.tm_model m on t.MODEL_ID=m.ID
			 where v.rk=1
			 )x
	where x.车型='XC90') tmv
join `member`.tc_member_info tmi on tmi.ID = tmv.MEMBER_ID 
join 
	(
	-- 获得过V值的用户
	select b.member_id,
	sum(case when b.RECORD_TYPE =0 then b.integral else 0 end) 获得V值
	from `member`.tt_member_flow_record b
	where b.is_deleted =0 
	group by 1 
	)b on tmi.ID =b.MEMBER_ID 
where tmi.MEMBER_STATUS <>60341003
and tmi.IS_DELETED =0

-- XC90车主参与兑换的车主数，以及平均兑换商品的价值
SELECT 
count(tmv.member_id) XC90参与兑换的车主数,
SUM(x.总金额) 兑换总金额,
ROUND(SUM(x.总金额)/sum(x.兑换数量),2) 平均兑换商品的价值
from (
		SELECT x.member_id
		from 
			(
			select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
				 from (
				 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
				 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
				 from member.tc_member_vehicle v 
				 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
				 where v.IS_DELETED=0 
				 ) v 
			 left join vehicle.tm_vehicle t on v.vin=t.VIN
			 left join basic_data.tm_model m on t.MODEL_ID=m.ID
			 where v.rk=1
			 )x
	where x.车型='XC90') tmv
join 
	(select a.order_code 订单编号
	,b.product_id 商城兑换id
	,a.user_id 会员id
	,a.user_name 会员姓名
	,b.spu_name 兑换商品
	,b.spu_id
	,b.sku_id
	,b.sku_code
	,b.sku_real_point 商品单价
	,b.fee/100 总金额
	,b.coupon_fee/100 优惠券抵扣金额
	,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.sku_num 兑换数量
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
	where 
	-- a.create_time >= '2022-02-12 12:00:00' and a.create_time < '2022-02-17'   -- 订单时间
	a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time)x on x.会员id=tmv.member_id
