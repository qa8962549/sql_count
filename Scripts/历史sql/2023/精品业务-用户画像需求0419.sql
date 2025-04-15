-- 购买和购买后
select a.会员id
,b.兑换时间 精品订单首次购买时间
,c.精品订单累计订单数
,d.精品订单号
,e.'PN号(商品编码)'
,e.产品名
,e.购买数量
,f.精品订单累计订单金额
,f.精品订单累计支付V值
,f.精品订单累计支付现金
,g.精品订单累计退换货次数
,g.七天无理由
,g.质量问题
,g.其他
from 
	(
	#下单精品的用户id
	select distinct a.user_id 会员id
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
	where 1=1
-- 	and a.create_time >= '2022-02-12 12:00:00' 
	and a.create_time < '2023-04-18'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and b.spu_type in (51121001,51121004)-- 筛选出精品
	-- and e.order_code is null  -- 剔除退款订单
) a
left join 
		(
		#精品订单首次购买时间
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
	,ROW_NUMBER()over(partition by a.user_id order by a.create_time) rk
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
	where 1=1
	-- a.create_time >= '2022-02-12 12:00:00' 
	and a.create_time < '2023-04-18'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and b.spu_type in (51121001,51121004)-- 筛选出精品
	-- and e.order_code is null  -- 剔除退款订单
	order by a.create_time
) b on a.会员id=b.会员id and b.rk=1
left join 
		(
	select 
	a.user_id 会员id
	,count(distinct a.order_code) 精品订单累计订单数
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
	where 1=1
	-- a.create_time >= '2022-02-12 12:00:00' 
	and a.create_time < '2023-04-18'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and b.spu_type in (51121001,51121004)-- 筛选出精品
	-- and e.order_code is null  -- 剔除退款订单
	group by 1
) c on a.会员id=c.会员id
left join 
		(
	#精品订单号
	select a.会员id
	,GROUP_CONCAT(a.order_code ORDER BY a.create_time desc SEPARATOR '\\') 精品订单号
	from 
		(
		select 
		a.会员id
		,a.order_code 
		,a.create_time 
		,ROW_NUMBER()over(partition by a.会员id,a.order_code order by a.create_time desc) rk
		from 
			(
			#因为一个订单对应多个商品 所以需要去重
			select 
			distinct a.user_id 会员id
			,a.order_code 
			,a.create_time 
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
			where 1=1
-- 			and a.create_time >= '2022-02-12 12:00:00' 
			and a.create_time < '2023-04-18'   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and b.spu_type in (51121001,51121004)-- 筛选出精品
	-- 		and a.user_id ='3015322'
			)a 
		)a where a.rk<=10
		group by 1
) d on a.会员id=d.会员id
left join 
		(
		#精品订单累计购买数量最多产品
	select a.会员id,
	a.sku_code 'PN号(商品编码)',
	a.spu_name 产品名,
	max(a.bb) 购买数量
	from 
		(
		select 
		a.user_id 会员id
		,b.sku_code
		,b.spu_name
		,count(b.sku_code) aa -- 购买数量最多产品
		,sum(b.sku_num) bb -- 购买数量
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
		where 1=1
-- 		and a.create_time >= '2022-02-12 12:00:00' 
		and a.create_time < '2023-04-18'   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and b.spu_type in (51121001,51121004)-- 筛选出精品
		group by 1,2
		)a
		group by 1
		order by 4 desc 
) e on a.会员id=e.会员id
left join 
		(
		#精品订单累计
		select 
		a.user_id 会员id
		,sum(b.fee/100) 精品订单累计订单金额
		,sum(b.point_amount) 精品订单累计支付V值
		,sum(b.pay_fee/100) 精品订单累计支付现金
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
		where 1=1
-- 		and  a.create_time >= '2022-02-12 12:00:00' 
		and a.create_time < '2023-04-18'   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and b.spu_type in (51121001,51121004)-- 筛选出精品
		group by 1
) f on a.会员id=f.会员id
left join 
		(
		#退换货
		select a.会员id
		,count(1) 精品订单累计退换货次数
		,count(case when a.退货原因='七天无理由' then 1 else null end) '七天无理由'
		,count(case when a.退货原因='质量问题' then 1 else null end) '质量问题'
		,count(case when a.退货原因='其他' then 1 else null end) '其他'
		from 
			(
			select 
			distinct a.user_id 会员id
			,a.order_code 
			,case when e.refund_reason ='7天无理由退货' then '七天无理由'
				when e.refund_reason ='商品质量问题' then '质量问题'
				else '其他' end 退货原因
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
			left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
			left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
			left join(
				#V值退款成功记录
				select so.order_code
				,sp.product_id
				,so.refund_reason
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
			where 1=1
-- 			and a.create_time >= '2022-02-12 12:00:00' 
			and a.create_time < '2023-04-18'   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and b.spu_type in (51121001,51121004)-- 筛选出精品
			and e.order_code is not null 
			)a
		group by 1
) g on a.会员id=g.会员id
