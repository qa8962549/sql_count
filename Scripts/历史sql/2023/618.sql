select x.*,
y.截止下单前前V值余额
from 
	(
		select a.order_code 订单编号
		,b.product_id 商城兑换id
		,a.user_id 会员id
		,a.user_name 会员姓名
		,b.spu_name 兑换商品
		,b.spu_id
		,b.sku_id
		,b.sku_code
		,b.sku_real_point 商品单价
		,CASE b.spu_type 
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			WHEN 51121006 THEN '一件代发'
			WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
		,b.fee/100 总金额
		,b.coupon_fee/100 优惠券抵扣金额
		,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
		,b.pay_fee/100 现金支付金额
		,b.point_amount 支付V值
		,b.sku_num 兑换数量
		,a.create_time 兑换时间
		,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
		,f.name 分类
		,h.MEMBER_V_NUM 当前V值余额
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
		where a.create_time BETWEEN '2022-05-31' and '2022-06-18 23:59:59'  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		-- and b.spu_type= 51121004  -- 筛选精品
		order by a.create_time
     )x	
left join 
	( #当前V值减去下单时间至现在获取的V值，就是下单前的V值
		select 
		a.order_id 订单ID,
		a.order_code 订单编号,
		ts.MEMBER_ID,
		tmi.USER_ID,
		a.下单时间,
		tmi.MEMBER_V_NUM 当前V值余额,
		tmi.MEMBER_V_NUM-sum(case when TIMESTAMPDIFF(SECOND, ts.create_time,a.下单时间)<3 then 
	   	 	case when ts.RECORD_TYPE=1 then -ts.INTEGRAL when ts.RECORD_TYPE=0 then ts.INTEGRAL else 0 end 
	   	 	else 0 end) 截止下单前前V值余额
		from `member`.tt_member_flow_record ts
		join 
			(
			#每个用户这段时间第一次下单时间
				select a.user_id,a.create_time 下单时间,a.order_id,a.order_code
				from (
					select a.order_id,a.user_id,a.create_time,a.order_code
					,row_number() over(partition by a.user_id order by a.create_time) rk 
					from `order`.tt_order a 
					where a.create_time >= '2022-05-31' and a.create_time <='2022-06-18 23:59:59'   -- 订单时间
					and a.is_deleted <> 1  -- 剔除逻辑删除订单
					and a.type = 31011003  -- 筛选沃世界商城订单
					and a.separate_status = '10041002' -- 选择拆单状态否
					and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
					AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
					order by a.create_time desc 
					) a 
				where a.rk=1
			)a on a.user_id=ts.MEMBER_ID
		join `member`.tc_member_info tmi on tmi.id=ts.MEMBER_ID and tmi.STATUS <>60341003 and tmi.IS_DELETED =0
		where ts.IS_DELETED =0 -- 未删除 
		group by 3
		order by 5 desc )y on x.会员id=y.MEMBER_ID