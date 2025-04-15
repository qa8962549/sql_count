--'11月会员日','沃尔沃汽车服务节','WOW商城·双11'
--'10月商城亲子季','10月会员日','WOW商城·双11'
-- ('WOW商城-开箱季','9月会员日','WOW商城-开学季')
-- ('8月会员日','WOW商城-开学季')
-- ('1月会员日','好物迎春 献礼新岁','2月会员日','3月会员日','4月会员日','沃的好物 魅力节',
-- '情人节活动','商城出行季活动','525车主节','6月会员日','618活动','夏服活动','WOW商城-消暑季','7月会员日')
--page_title='12月会员日'
--activity_name='2023年12月会员日'

-- 拉新人数（App/Mini注册会员） 通过活动 总
select 
count(distinct a.user_id)
from
	(-- 访问过活动的用户-App/Mini
	select a.user_id,distinct_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event ='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-05-01'
	and date<'2023-06-01'
--	and activity_name='2023年5月车主节活动'
	and page_title in ('11月会员日','沃尔沃汽车服务节','WOW商城·双11')
--	and a.channel='App' --'Mini'
)a 
join
	(-- 注册会员
	select distinct m.cust_id,m.create_time
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
--	and m.member_source <> '60511003' -- 首次注册app用户
	and m.create_time >= '2023-05-01'
	and m.create_time <'2023-06-01'
)b on a.distinct_id=b.cust_id::varchar
where toDateTime(a.time)-toDateTime(b.create_time)<=600 
and toDateTime(a.time)-toDateTime(b.create_time)>=-600

-- 拉新人数（App/Mini注册会员） 通过活动 APP
select 
count(distinct a.user_id)
from
	(-- 访问过活动的用户-App/Mini
	select a.user_id,distinct_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event ='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-11-01'
	and date<'2023-12-01'
	and page_title in ('11月会员日','沃尔沃汽车服务节','WOW商城·双11')
	and a.channel='App'
)a 
join
	(-- 注册会员
	select distinct m.cust_id,m.create_time
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.member_source = '60511003' -- 首次注册app用户
	and m.create_time >= '2023-11-01'
	and m.create_time <'2023-12-01'
)b on a.distinct_id=b.cust_id::varchar
where toDateTime(a.time)-toDateTime(b.create_time)<=600 
and toDateTime(a.time)-toDateTime(b.create_time)>=-600

-- app每月新增注册用户
select 
date_trunc('month',mt) t
,count(distinct x.distinct_id)
from 
  (
	select distinct_id,
  	min(time) mt
     from ods_rawd_events_d_di 
     WHERE  (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
     and length(distinct_id) < 9 -- 会员
     and date< '2023-12-01'
  	 and date>= '2022-01-01'
  	 group by distinct_id
)x 
group by t
order by t

--APP用户数
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

--APP活跃用户数
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-11-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

--APP活跃用户数 总
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-01-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP车主总数
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1
--Settings allow_experimental_window_functions = 1

-- APP车主月度活跃数量
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-11-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- 访问过活动的用户-App 线上活动活跃用户数
	select count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event ='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-11-01'
	and date<'2023-12-01'
	and page_title in ('11月会员日','沃尔沃汽车服务节','WOW商城·双11')
	and a.channel='App'


-- 访问过活动的用户-App 线上活动活跃用户数 车主
	select count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event ='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-11-01'
	and date<'2023-12-01'
	and page_title in ('11月会员日','沃尔沃汽车服务节','WOW商城·双11')
	and a.channel='App'
	and is_bind =1
	
-- 访问过活动的用户-App 线上活动活跃用户数 当年  车主/总数
	select count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and event ='Page_entry'
	and length(distinct_id)<9 
	and date>='2023-01-01'
	and date<'2023-12-01'
	and (page_title in (
				'11月会员日','沃尔沃汽车服务节','WOW商城·双11', -- 11
				'10月商城亲子季','10月会员日','WOW商城·双11',  -- 10
				'WOW商城-开箱季','9月会员日','WOW商城-开学季',  -- 9月
				'WOW商城-开学季','8月会员日','夏服活动',   -- 8月
				'7月会员日','WOW商城-消暑季','夏服活动',    -- 7月
				'6月会员日','618活动' ,  --6月
	--			'525车主节',  --  5月
				'4月会员日','商城出行季活动', -- 4月
				'3月会员日' ,'沃的好物 魅力季', -- 3月
				'2月会员日' ,'沃的好物 魅力季','情人节活动',  -- 2月
				'1月会员日','好物迎春 献礼新岁'  -- 1月
				) 
			or activity_name='2023年5月车主节活动')
	and a.channel='App'	
	and is_bind =1  -- 注意分开使用
	
	

-- 2023APP 总数
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP活跃用户数 当月
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-11-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP活跃用户数 当年
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-01-01' 
and time<'2023-12-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP车主总数
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2022-02-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- APP车主总数 当年
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-01-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- APP车主月度活跃数量
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-11-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- APP车主月度活跃数量 今年
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-01-01' 
and time<'2023-12-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- 总站销售额
select 
SUM(m.`总金额`) `GMV汇总`
from 
	(select a.order_code `订单编号`
	,b.product_id `商城兑换id`
	,a.user_id `会员id`
	,a.user_name `会员姓名`
	,b.spu_name `兑换商品`
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point `商品单价`
--	,case WHEN LEFT(a.client_id,1) = 6 then '小程序订单'
--	 WHEN LEFT(a.client_id,1) = 2 then 'APP订单' else null end `平台`
	,CASE b.spu_type 
		WHEN 51121001 THEN '精品'
		WHEN 51121002 THEN '第三方卡券`'
		WHEN 51121003 THEN '保养类卡券' 
		WHEN 51121004 THEN '精品'
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品' ELSE null end `商品类型`
	,ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '精品' --一件代发
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'-- '车辆权益'
		ELSE null end) `商品类型2`
	,b.fee/100 `总金额`
	,b.coupon_fee/100 `优惠券抵扣金额`
	,round(b.point_amount/3+b.pay_fee/100,2) `实付金额`
	,b.pay_fee/100 `现金支付金额`
	,b.point_amount `支付V值`
	,b.sku_num `兑换数量`
	,a.create_time `兑换时间`
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
	left join ods_good.ods_good_item_spu_d j on b.spu_id = j.id   -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_front_category_d f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
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
--	and toDate(a.create_time) >= '2023-01-01' 
	and toDate(a.create_time) >= '2023-11-01' 
	and toDate(a.create_time) <'2023-12-01'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m

	
-- 销售概览分类型 活动引流
select 
date_trunc('month',m.tt) tt 
,m.fl
,SUM(m.`总金额`) `GMV汇总`
from 
	(select a.order_code `订单编号`
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
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
					'11月会员日','沃尔沃汽车服务节','WOW商城·双11' -- 11
--					'10月商城亲子季','10月会员日','WOW商城·双11'  -- 10
--					'WOW商城-开箱季','9月会员日','WOW商城-开学季'  -- 9月
--					'WOW商城-开学季','8月会员日','夏服活动'   -- 8月
--					'7月会员日','WOW商城-消暑季','夏服活动'    -- 7月
--					'6月会员日','618活动'  --6月
		--			'525车主节',  --  5月
--					'4月会员日','商城出行季活动' -- 4月
--					'3月会员日' ,'沃的好物 魅力季' -- 3月
--					'2月会员日' ,'沃的好物 魅力季','情人节活动'  -- 2月
--					'1月会员日','好物迎春 献礼新岁'  -- 1月
					) 
--				and activity_name='2023年5月车主节活动'--  5月
				)
			and date>='2023-11-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
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
	and toDate(a.create_time) >= '2023-11-01' 
	and toDate(a.create_time) <'2023-12-01'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and b.is_deleted <> 1
	and h.is_deleted <> 1
--	and j.front_category_id is not null
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = 10041002 -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m
group by tt,fl
order by tt,fl desc 

--活动引流参与充电订单数量
select date_trunc('month',c.create_time) tt
,count(c.id)
from ods_orde.ods_orde_tt_charge_order_d c
global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(c.member_id) = toString(h.id)   -- 会员表(获取会员信息)
global join (
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
				'11月会员日','沃尔沃汽车服务节','WOW商城·双11', -- 11
				'10月商城亲子季','10月会员日','WOW商城·双11',  -- 10
				'WOW商城-开箱季','9月会员日','WOW商城-开学季',  -- 9月
				'WOW商城-开学季','8月会员日','夏服活动',   -- 8月
				'7月会员日','WOW商城-消暑季','夏服活动',    -- 7月
				'6月会员日','618活动' ,  --6月
	--			'525车主节',  --  5月
				'4月会员日','商城出行季活动', -- 4月
				'3月会员日' ,'沃的好物 魅力季', -- 3月
				'2月会员日' ,'沃的好物 魅力季','情人节活动',  -- 2月
				'1月会员日','好物迎春 献礼新岁'  -- 1月
				) 
				or activity_name='2023年5月车主节活动'
				)
			and date>='2023-01-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
where c.is_deleted =0
and c.create_time >='2023-01-01'
and c.create_time <'2023-12-01'
group by tt


-- 邀约试驾 当月总留资量
SELECT 
date_trunc('month',t1.reserve_time) tt ,
count(t1.be_invite_member_id) `被邀请人会员ID`
FROM ods_invi.ods_invi_tm_invite_record_d t1
global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(t1.be_invite_member_id) = toString(h.id)   -- 会员表(获取会员信息)
global join (
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
				'11月会员日','沃尔沃汽车服务节','WOW商城·双11', -- 11
				'10月商城亲子季','10月会员日','WOW商城·双11',  -- 10
				'WOW商城-开箱季','9月会员日','WOW商城-开学季',  -- 9月
				'WOW商城-开学季','8月会员日','夏服活动',   -- 8月
				'7月会员日','WOW商城-消暑季','夏服活动',    -- 7月
				'6月会员日','618活动' ,  --6月
	--			'525车主节',  --  5月
				'4月会员日','商城出行季活动', -- 4月
				'3月会员日' ,'沃的好物 魅力季', -- 3月
				'2月会员日' ,'沃的好物 魅力季','情人节活动',  -- 2月
				'1月会员日','好物迎春 献礼新岁'  -- 1月
				) or activity_name='2023年5月车主节活动')
			and date>='2023-01-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
where t1.is_deleted =0
and t1.reserve_time >='2023-01-01' 
and t1.reserve_time <'2023-12-01'
group by tt



-- 预约试驾
	SELECT
	date_trunc('month', ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
	FROM ods_cyap.ods_cyap_tt_appointment_d ta
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global join (
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
				'11月会员日','沃尔沃汽车服务节','WOW商城·双11', -- 11
				'10月商城亲子季','10月会员日','WOW商城·双11',  -- 10
				'WOW商城-开箱季','9月会员日','WOW商城-开学季',  -- 9月
				'WOW商城-开学季','8月会员日','夏服活动',   -- 8月
				'7月会员日','WOW商城-消暑季','夏服活动',    -- 7月
				'6月会员日','618活动' ,  --6月
	--			'525车主节',  --  5月
				'4月会员日','商城出行季活动', -- 4月
				'3月会员日' ,'沃的好物 魅力季', -- 3月
				'2月会员日' ,'沃的好物 魅力季','情人节活动',  -- 2月
				'1月会员日','好物迎春 献礼新岁'  -- 1月
				) or activity_name='2023年5月车主节活动')
			and date>='2023-01-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
	WHERE ta.CREATED_AT >= '2023-01-01'
	AND ta.CREATED_AT <'2023-12-01'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
	group by tt 

select * from ods_bada.ods_bada_tm_model_cur
	
-- 养修预约

select 
	date_trunc('month', ta.CREATED_AT) tt,
	count(distinct ta.ONE_ID)
from ods_cyap.ods_cyap_tt_appointment_d ta 
left join ods_cyap.ods_cyap_tt_appointment_maintain_d tam on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID 
	global left join (
		-- 清洗cust_id
		select m.id,m.cust_id
		from 
			(-- 清洗cust_id
			select m.*,
			row_number() over(partition by m.cust_id order by m.create_time desc) rk
			from ods_memb.ods_memb_tc_member_info_cur m
			where m.member_status<>'60341003' and m.is_deleted=0
			and m.cust_id is not null 
			Settings allow_experimental_window_functions = 1
			) m
		where m.rk=1) h on toString(ta.ONE_ID) = toString(h.cust_id)   -- 会员表(获取会员信息)
	global join (
		-- 参加活动的用户
			select 
			distinct distinct_id 
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in('Page_entry','Page_view','Button_click')
			and (page_title in (
				'11月会员日','沃尔沃汽车服务节','WOW商城·双11', -- 11
				'10月商城亲子季','10月会员日','WOW商城·双11',  -- 10
				'WOW商城-开箱季','9月会员日','WOW商城-开学季',  -- 9月
				'WOW商城-开学季','8月会员日','夏服活动',   -- 8月
				'7月会员日','WOW商城-消暑季','夏服活动',    -- 7月
				'6月会员日','618活动' ,  --6月
	--			'525车主节',  --  5月
				'4月会员日','商城出行季活动', -- 4月
				'3月会员日' ,'沃的好物 魅力季', -- 3月
				'2月会员日' ,'沃的好物 魅力季','情人节活动',  -- 2月
				'1月会员日','好物迎春 献礼新岁'  -- 1月
				) or activity_name='2023年5月车主节活动')
			and date>='2023-01-01'
			and date<'2023-12-01'
			and length(distinct_id)<=9
			)x on toString(x.distinct_id)=toString(h.cust_id) 
where 1=1
and tam.IS_DELETED <>1
and ta.CREATED_AT >= '2023-01-01'
and ta.CREATED_AT <'2023-12-01'
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005
--	and tc.CODE_CN_DESC in ('提前进厂','准时进厂','延迟进厂','待评价','已评价') -- 进厂
group by tt
	
	

-- 会员日邀约试驾 oneid
SELECT DISTINCT
o.distinct_id
,toDate(o.time) apptime
FROM ods_rawd.ods_rawd_events_d_di o
WHERE length(o.distinct_id) < 9
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and o.event ='Button_click'
and o.page_title ='9月会员日'
and o.activity_name ='2023年9月会员日'
and o.content_title ='邀约试驾 驭享好礼'
and o.btn_name='立即邀请'
AND toDate(o.time)='2023-09-25'

	
-- 会员日养修预约oneid
SELECT DISTINCT
o.distinct_id
,toDate(o.time) apptime
FROM ods_rawd.ods_rawd_events_d_di o
WHERE length(o.distinct_id) < 9
-- and o.`$lib` in ('iOS','Android')
and o.channel ='App'
and o.event ='Button_click'
and o.page_title ='9月会员日'
and o.activity_name ='2023年9月会员日'
and o.content_title ='预约养修 尊享赠礼'
AND toDate(o.time)='2023-09-25'