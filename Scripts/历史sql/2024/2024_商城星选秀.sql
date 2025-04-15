-- 活动首页UV
	select date t
	,count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_view'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<'2024-01-25'
	and page_title='商城星选季'
	and activity_name='2024年1月商城星选季'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--	and a.is_bind=1
	group by ROLLUP(t)
	order by t
	
--许愿二级页UV	
	select date t
	,count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Page_entry'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<'2024-01-25'
	and page_title ='商城星选季_星光闪耀 礼遇登场页面'
	and activity_name='2024年1月商城星选季'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--	and a.is_bind=1
	group by ROLLUP(t)
	order by t

--许愿用户数-总计	
	select date t
	,count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<'2024-01-25'
	and page_title ='商城星选季_星光闪耀 礼遇登场页面'
	and btn_name='去许愿'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--	and a.is_bind=1
	group by rollup(t)
	order by t
	
--兑奖用户数-总计
	select date t
	,count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<='2024-01-25'
	and page_title ='商城星选季_星光闪耀 礼遇登场页面'
	and btn_name='领取星礼'
--	and (btn_name='领取星礼'or btn_name='去许愿')
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and a.is_bind=1
	group by rollup(t)
	order by t
	
--分享星愿数	
	select date t
	,count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event='Button_click'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<'2024-01-25'
	and page_title ='商城星选季_许愿成功弹窗'
	and btn_name='分享星愿'
--	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--	and a.is_bind=1
	group by rollup(t)
	order by t

-- 浏览活动主页且参与兑奖活动用户数
	select count(distinct a.distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	global join (	
		select distinct a.distinct_id
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and event='Button_click'
		and length(distinct_id)<9 
		and date='2024-01-20'
		and page_title ='商城星选季_星光闪耀 礼遇登场页面'
		and btn_name='领取星礼')x on x.distinct_id=a.distinct_id
	where 1=1
	and event='Page_view'
	and length(distinct_id)<9 
	and date>='2024-01-17'
	and date<'2024-01-20'
	and page_title='商城星选季'
	and activity_name='2024年1月商城星选季'



-- 订单明细
select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,x.distinct_id
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
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
--	优惠券相关数据
	,cv.coupon_id `使用优惠券id`
	,tci.coupon_name `使用优惠券名称`
	,cv.coupon_detail_id `使用优惠券的领取id`
	,tcd.create_time `使用优惠券的领取时间`
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
	join (
			select distinct distinct_id
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and length(distinct_id)<=9
			and event='Page_entry'
			and date>='2024-01-17'
			and date<'2024-01-25'
			and page_title='商城星选季'
			and activity_name='2024年1月商城星选季'
--			and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App') )
		)x on toString(x.distinct_id) =toString(h.cust_id) 
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
		left join ods_coup.ods_coup_tt_coupon_verify_d cv on toString(cv.order_no)=toString(b.order_code)   -- 优惠券核销表 核销金额
		left join ods_coup.ods_coup_tt_coupon_info_d tci on toString(cv.coupon_id)=toString(tci.id) --卡券表
		left join ods_coup.ods_coup_tt_coupon_detail_d tcd on toString(tcd.id) =toString( cv.coupon_detail_id) 
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
	and date(a.create_time) >= '2024-01-17' 
	and date(a.create_time) <'2024-01-25'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and cv.is_deleted =0
--	and tci.is_deleted =0 
--	and tcd.is_deleted =0
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	--and (b.spu_type in (51121001,51121004,51121006,51121007,51121008) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	--and e.order_code is null  -- 剔除退款订单
--	and b.sku_code in ('31422886',
--	'32355219',
--	'32284878',
--	'32355380',
--	'31422756',
--	'32284836',
--	'31422881',
--	'31422752',
--	'32355259',
--	'32355258'
--	)
	order by a.create_time