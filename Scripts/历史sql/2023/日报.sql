select 
a.`日期`
,j.绑定车主数
,a.`注册数`-j.`绑定车主数` 总粉丝数
,a.`注册数`+g.`公众号总关注数`-f.`交集用户数` 总用户数
,f.`交集用户数`
,g.`公众号总关注数`
,a.`注册数`
,a.`注册数`+g.`公众号总关注数`-f.`交集用户数`-j.`绑定车主数` 非车主数
,h.`公众号新增关注数`,h.`公众号新增关注数`-i.`公众号净增关注数` 取消关注数,i.`公众号净增关注数`
,k.`小程序新增注册数`
,j.`绑定车辆数`
,l.总计启动人数,l.启动车主数,l.启动粉丝数,l.启动游客数
,b.总计活跃用户数,b.活跃车主数,b.活跃粉丝数
,e.销售额合计,e.销售额精品,e.销售额售后,e.销售额第三方
,e.下单用户数合计,e.下单用户数精品,e.下单用户数售后,e.下单用户数第三方
,e.订单数,e.订单数精品,e.订单数售后,e.订单数第三方
from (
	#小程序注册数--a
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 注册数
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.create_time <CURDATE()
	GROUP BY 1 
) a 
left join (
	#交集用户--f
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY)日期,count(a.allunionid) 交集用户数
	from (
		#结合老库获取新库用户对应的 unionid
		select m.id mid,m.MEMBER_PHONE,m.member_name,IFNULL(c.union_id,u.unionid) allunionid
		from  member.tc_member_info m 
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
		where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
		and m.create_time < CURDATE() and c.create_time< CURDATE()
	)a
	JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid 
	and o.subscribe_status=1
	and o.unionid<>'' and o.unionid is not null 
	and IFNULL(o.subscribe_time,o.create_time)<CURDATE() -- sbuscirbe_status=1 为订阅用户
	GROUP BY 1
) f on f.日期=a.日期
left join (
	# 公众号总关注数--g
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 公众号总关注数
	from volvo_wechat_live.es_car_owners o 
	where o.subscribe_status=1
	and IFNULL(o.subscribe_time,o.create_time)<CURDATE()
	GROUP BY 1 
) g on g.日期=a.日期
left join (
	# 公众号新增关注数--h
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 公众号新增关注数
	from volvo_wechat_live.es_car_owners o 
	where IFNULL(o.subscribe_time,o.create_time)>= DATE_SUB(CURDATE(),INTERVAL 1 DAY) 
	and IFNULL(o.subscribe_time,o.create_time)<CURDATE()
	GROUP BY 1
) h on h.日期=a.日期
left join (
	# 公众号净关注数--i
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 公众号净增关注数
	from volvo_wechat_live.es_car_owners o 
	where o.subscribe_status=1
	and IFNULL(o.subscribe_time,o.create_time)>= DATE_SUB(CURDATE(),INTERVAL 1 DAY) 
	and IFNULL(o.subscribe_time,o.create_time)<CURDATE()
	GROUP BY 1 
) i on i.日期=a.日期
left join (
	#沃世界去重绑定车主数--g
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期
	,count(v.MEMBER_ID) 绑定车辆数
	,count(DISTINCT member_id) 绑定车主数
	from member.tc_member_vehicle v
	where v.IS_DELETED=0
	and v.create_time<CURDATE()
	GROUP BY 1
) j on j.日期=a.日期
left join (
	#小程序新增注册数--k
	select DATE_SUB(CURDATE(),INTERVAL 1 DAY) 日期,count(1) 小程序新增注册数
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.create_time >=DATE_SUB(CURDATE(),INTERVAL 1 DAY) and m.create_time <CURDATE()
	GROUP BY 1
) k on k.日期=a.日期
left join (
	# 小程序当日启动用户数--l
	select DATE(t.date) 日期
	,count(DISTINCT t.usertag) 总计启动人数
	,count(DISTINCT case when IFNULL(m.is_vehicle,2)= 0 then t.usertag else null end) 启动粉丝数
	,count(DISTINCT case when IFNULL(m.is_vehicle,2)= 1 then t.usertag else null end) 启动车主数
	,count(DISTINCT case when IFNULL(m.is_vehicle,2)= 2 then t.usertag else null end) 启动游客数
	from track.track t 
	left join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	where t.date >= DATE_SUB(CURDATE(),INTERVAL 1 day) and t.date<CURDATE()
	GROUP BY 1 
) l on l.日期=a.日期
left join (
	# 小程序当日活跃数--m
	select DATE(t.date) 日期
	,count(DISTINCT m.id) 总计活跃用户数
	,count(DISTINCT case when m.is_vehicle=1 then m.id else null end) 活跃车主数
	,count(DISTINCT case when m.is_vehicle=0 then m.id else null end) 活跃粉丝数
	from track.track t 
	join(
		#清洗user_id
		select m.*
		from (
		select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time
		,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status<>60341003 and m.is_deleted=0
		and m.USER_ID is not null 
		) m
		where m.rk=1
	)m on CAST(m.user_id AS varchar)=t.usertag
	where t.date >= DATE_SUB(CURDATE(),INTERVAL 1 DAY) and t.date<CURDATE()
	and t.date>m.member_time 
	GROUP BY 1 
) b on a.日期=b.日期
left join (
	#订单--e
	select DATE(o.兑换时间) 日期
	,count(DISTINCT o.`会员id`) 下单用户数合计
	,count(DISTINCT case when o.商品类型='精品' then o.`会员id` else null end) 下单用户数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.`会员id` else null end) 下单用户数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.`会员id` else null end) 下单用户数第三方

	,sum(o.`兑换数量`) 下单商品数合计
	,sum(case when o.商品类型='精品' then o.`兑换数量` else null end) 下单商品数精品
	,sum(case when o.商品类型='保养类卡券' then o.`兑换数量` else null end) 下单商品数售后
	,sum(case when o.商品类型='第三方卡券' then o.`兑换数量` else null end) 下单商品数第三方

	,count(DISTINCT o.`订单编号`) 订单数
	,count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end) 订单数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end) 订单数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end) 订单数第三方

	,sum(o.总金额) 销售额合计
	,sum(case when o.商品类型='精品' then o.总金额 else null end) 销售额精品
	,sum(case when o.商品类型='保养类卡券' then o.总金额 else null end) 销售额售后
	,sum(case when o.商品类型='第三方卡券' then o.总金额 else null end) 销售额第三方

	,ROUND(sum(o.支付V值)/3) 销售额V值合计
	,sum(case when o.商品类型='精品' then o.支付V值 else null end) 销售额V值精品
	,sum(case when o.商品类型='保养类卡券' then o.支付V值 else null end) 销售额V值售后
	,sum(case when o.商品类型='第三方卡券' then o.支付V值 else null end) 销售额V值第三方

	,sum(o.现金支付金额) 销售额现金合计
	,sum(case when o.商品类型='精品' then o.现金支付金额 else null end) 销售额现金精品
	,sum(case when o.商品类型='保养类卡券' then o.现金支付金额 else null end) 销售额现金售后
	,sum(case when o.商品类型='第三方卡券' then o.现金支付金额 else null end) 销售额现金第三方

	,sum(o.优惠券抵扣金额) 销售额优惠券合计
	,sum(case when o.商品类型='精品' then o.优惠券抵扣金额 else null end) 销售额优惠券精品
	,sum(case when o.商品类型='保养类卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券售后
	,sum(case when o.商品类型='第三方卡券' then o.优惠券抵扣金额 else null end) 销售额优惠券第三方
	from (
		select a.order_code 订单编号
		,b.product_id 商城兑换id
		,a.user_id 会员id
		,a.user_name 会员姓名
		,b.spu_name 兑换商品
		,b.sku_real_point 商品单价
		,CASE b.spu_type 
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			WHEN 51121006 THEN '精品'-- '一件代发'
			WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
		,b.fee/100 总金额
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
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 
			and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		where a.create_time >= DATE_SUB(CURDATE(),INTERVAL 1 DAY) and a.create_time < CURDATE()   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) o GROUP BY 1 
) e on e.日期=a.`日期`