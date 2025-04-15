select 
x.code,
--x.t,
x.PV,
x.UV,
x2.`销量`,
x2.`订单金额`
from 
	(select 
	b.code code,
--	toDate(dt) t,
	count(a.gio_id) as `PV`,
	count(distinct a.gio_id) as `UV`
	from ods_gio.ods_gio_event_d a
	left join ods_good.ods_good_item_sku_d b on b.spu_id::varchar=a.var_product_id::varchar
	where 1=1 
	and a.event_key ='Button_click'
	and a.var_bussiness_name ='商城'
	and a.var_page_title in('商城首页','商品列表页面')
	and toDate(a.dt) >= '2024-01-01'
	and toDate(a.dt) <toDate(now())
--	and (((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App')or (`$platform` in('MiniProgram')or channel ='Mini' ))
	and ((`$platform` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or channel = 'App') -- app
--	and ((`$platform` in('MinP')or channel ='Mini' )) -- mini 
	and a.var_product_id in ('3836',
'3791',
'3832',
'3841',
'3837',
'3853',
'3833',
'3777',
'3582',
'3851',
'3839',
'3778',
'3840',
'3834',
'3798',
'3808',
'3726',
'3852',
'3797')
	group by 1
	order by 1)x
left join 
	(
	-- 会员日活动销量
	select 
	--m.`客户端`,
	m.sku_code sp,
--	toDate(m.tt) t,
	sum(m.`总金额`) `订单金额`,
	sum(m.`兑换数量`) `销量`
	from 
		(select a.order_code `订单编号`
		,b.product_id `商城兑换id`
		,a.user_id `会员id`
		,a.user_name `会员姓名`
		,b.spu_name `兑换商品`
		,client.client_name `客户端`
		,b.spu_id spu_id
		,b.sku_id
		,b.spu_bus_id
		,b.sku_code sku_code
		,b.sku_real_point `商品单价`
		,ifnull(ifnull(f2.fl,case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end)
		,CASE WHEN b.spu_type =51121001 THEN '精品'
			WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
			WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
			WHEN b.spu_type =51121004 THEN '精品'
			WHEN b.spu_type =51121006 THEN '一件代发'
			WHEN b.spu_type =51121007 THEN '经销商端产品'
			WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
			ELSE null end) `fl`
	,CASE b.spu_type
			WHEN 51121001 THEN '沃尔沃精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '虚拟服务卡券' 
			WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
			WHEN 51121006 THEN '一件代发'
			WHEN 51121007 THEN '经销商端产品'
		    WHEN 51121008 THEN '虚拟服务权益'
		    ELSE null end `商品类型`
		,b.fee/100 `总金额`
		,b.coupon_fee/100 `优惠券抵扣金额`
		,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
		,b.pay_fee/100 `现金支付金额`
		,b.point_amount `支付V值`
		,b.sku_num `兑换数量`
		,a.create_time as tt
		,case 
			when b.pay_fee=0 then '纯V值支付'
			when b.point_amount=0 then '纯现金支付' else '混合支付' end `支付方式`
		,f.name `分类`
		,CASE b.spu_type 
			WHEN 51121001 THEN 'VOLVO仓商品'
			WHEN 51121002 THEN 'VOLVO仓第三方卡券'
			WHEN 51121003 THEN '虚拟服务卡券'
			WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS `仓库`
		,CASE b.status
				WHEN 51301001 THEN '待付款'
				WHEN 51301002 THEN '待发货'
				WHEN 51301003 THEN '待收货'
				WHEN 51301004 THEN '收货确认'
				WHEN 51301005 THEN '退货中'
				WHEN 51301006 THEN '交易关闭' 
		END AS `商品状态`
		,CASE a.status
				WHEN 51031002 THEN '待付款'
				WHEN 51031003 THEN '待发货' 
				WHEN 51031004 THEN '待收货' 
				WHEN 51031005 THEN '已完成'
				WHEN 51031006 THEN '已关闭'  
		END AS `订单状态`
		,CASE a.close_reason 
		WHEN 51091003 THEN '用户退款' 
		WHEN 51091004 THEN '用户退货退款' 
		WHEN 51091005 THEN '商家退款' END AS `关闭原因`
		,e.`退货状态` `退货状态`
		,e.`退货数量` `退货数量`
		,e.`退回V值` `退回V值`
		,e.`退回时间` `退回时间`
		from ods_orde.ods_orde_tt_order_d a  -- 订单主表
		left join ods_good.ods_good_client_d client on client.client_id =a.client_id 
		left join ods_orde.ods_orde_tt_order_product_d  b on a.order_code = b.order_code  -- 订单商品表
		left join (
			-- 清洗cust_id
			select m.*
			from 
				(-- 清洗cust_id
				select m.*,
				row_number() over(partition by m.cust_id order by m.create_time desc) rk
				from ods_memb.ods_memb_tc_member_info_cur m
				where m.member_status<>'60341003' and m.is_deleted=0
				and m.cust_id is not null 
				Settings allow_experimental_window_functions = 1
				) m
			where m.rk=1) h on toString(a.user_id) = toString(h.id)   -- 会员表(获取会员信息)
		left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
		left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
		left join
		(
			-- 获取前台分类[充电专区]的商品 
			select distinct j.id as spu_id ,
			j.name,
			f2.name as fl
			from ods_good.ods_good_item_spu_d j
			left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
			left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
			left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
			where 1=1
			and f2.name='充电专区'
	--		and j.is_deleted ='0' -- 该表该字段全为空
	--		and i.is_deleted ='0' -- 该表该字段全为空
			and s.is_deleted ='0'
			and f2.is_deleted ='0'
		)f2 on f2.spu_id=b.spu_id
		left join(
		--	#V值退款成功记录
			select so.order_code
			,sp.product_id
			,CASE 
				WHEN so.status ='51171001' THEN '待审核'
				WHEN so.status ='51171002' THEN '待退货入库'
				WHEN so.status ='51171003' THEN '待退款'
				WHEN so.status ='51171004' THEN '退款成功'
				WHEN so.status ='51171005' THEN '退款失败'
				WHEN so.status ='51171006' THEN '作废退货单' END as `退货状态`
			,sum(sp.sales_return_num) `退货数量`
			,sum(so.refund_point) `退回V值`
			,max(so.create_time) `退回时间`
			from ods_orde.ods_orde_tt_sales_return_order_d so
			left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code=sp.refund_order_code 
			where so.is_deleted = 0 
			and so.status='51171004' -- 退款成功
			and sp.is_deleted=0
			GROUP BY order_code,product_id,`退货状态`
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		where 1=1
		and toDate(a.create_time) >=  '2024-01-01'
		and toDate(a.create_time) < toDate(now()) 
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and b.is_deleted <> 1
		and h.is_deleted <> 1
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = 10041002 -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	--	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	--	and e.order_code is null  -- 剔除退款订单
		and client.client_name='APP端'
--		and client.client_name='小程序'
		and b.sku_code in ('32355690',
'32355691',
'32355692',
'32355488',
'32355487',
'32355489',
'32355494',
'32355495',
'32355496',
'32355681',
'32355682',
'32355688',
'32355531',
'32355532',
'32355534',
'32355500',
'32284810',
'32355473',
'32355381')
		order by a.create_time) m
		group by 1
		order by 1
)x2 on x2.sp=x.code 
--and toDate(x2.t)=x.t

	
select distinct code,
spu_id 
from ods_good.ods_good_item_sku_d a
where 1=1
and is_deleted =0
and a.code in ('32355690',
'32355691',
'32355692',
'32355488',
'32355487',
'32355489',
'32355494',
'32355495',
'32355496',
'32355681',
'32355682',
'32355688',
'32355531',
'32355532',
'32355534',
'32355500',
'32284810',
'32355473',
'32355381')