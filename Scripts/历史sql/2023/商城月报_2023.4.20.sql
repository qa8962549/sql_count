# 商城月报，改版时间：2022.10.31
# 每月月初给Yang Huijie
# 下次加上 "陶镛"<taoyong@wedochina.cn>;

# 1、销售额数据-沃世界MAU(汇总等于把三个数字相加，小程序APP各自输入即可)
# 沃世界小程序MAU
select
count(DISTINCT m.id) 沃世界小程序MAU
from track.track t 
join
(
	# 清洗user_id，取最新注册的user_id
	select m.* from 
	(
		select
		m.id,
		m.USER_ID,
		m.IS_VEHICLE,
		m.member_time,
		m.member_source,
		row_number() over(partition by m.USER_ID order by m.create_time desc) rk
		from member.tc_member_info m
		where m.member_status <> 60341003 and m.is_deleted = 0
		and m.USER_ID is not null
	) m
	where m.rk = 1
) m on CAST(m.user_id AS varchar) = t.usertag
where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)
and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
and t.date > m.member_time


# $lib=js是H5页面，加channel=APP是从APP打开的H5页面，APP只有内容详情、动态详情、活动详情以及销售的个别页面是H5页面，其余都是原生页面

# APP MAU
select count(distinct distinct_id)
from events 
where ($lib in ('iOS','Android') or ($lib = 'js' and channel = 'App'))
and time between '2023-02-01' and '2023-02-28 23:59:59'
and distinct_id not like '%#%'
and length(distinct_id) < 9


# 2、销售额数据-沃世界商城MAU
select
count(DISTINCT t.usertag) 商城首页UV
from track.track t 
left join(
	#清洗user_id
	select m.*
	from (
	select m.id,m.USER_ID,m.IS_VEHICLE,m.member_time,m.member_source
	,row_number() over(partition by m.USER_ID order by m.create_time desc) rk
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
	and m.USER_ID is not null 
	) m
	where m.rk=1
)m on CAST(m.user_id AS varchar)=t.usertag
left join (
	#商城新老用户
	select DISTINCT a.user_id,a.订单来源 from
	(
		select
		a.order_code,
		case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
			WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
			else null end 订单来源,
		a.user_id,
		a.create_time,
		row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
		left join
		(
			#V值退款成功记录
			select
			so.order_code,
			sp.product_id,
			sum(sp.sales_return_num) 退货数量,
			sum(so.refund_point) 退回V值,
			max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code and sp.is_deleted = 0
			where so.is_deleted = 0 and so.status = 51171004    -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
	) a 
	where a.rk = 1 and a.user_id is not null
) o on m.id = o.user_id
where t.`date` >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)
and t.`date` < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
and t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V'


# APP商城MAU
select count(distinct distinct_id)
from events 
where $lib in ('iOS','Android')
and event = 'Mall_category_list_view'
and page_title in ('商城','商城首页','首页','WOW')
and time between '2023-01-01' and '2023-01-31 23:59:59'
and length(distinct_id) < 9



--# 3、销售额数据-销售额、V值消耗
select
-- m.订单来源,
SUM(case when m.商品类型 = '保养类卡券' then m.总金额 end) 售后销售额,
SUM(case when m.商品类型 = '精品' then m.总金额 end) 精品销售额,
SUM(case when m.商品类型 = '第三方卡券' then m.总金额 end) 第三方卡券销售额,
SUM(m.支付V值) V值消耗
from
	(select a.order_code 订单编号
	,ifnull(a.parent_order_code,a.order_code) 母单号
	,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
				WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
				else null end 订单来源
	,a.user_id 会员表中id
	,a.user_name 会员姓名
	,a.user_phone 会员手机号
	,a.receiver_name 收货姓名
	,a.receiver_phone 收货手机号
	,concat (
			ifnull ( a.receiver_province_name, '' ),
			ifnull ( a.receiver_city_name, '' ),
			ifnull ( a.receiver_district_name, '' ),
			ifnull ( a.receiver_address, '' ) 
	) AS 收货地址
	,b.sku_code 商品货号
	,b.spu_name 兑换商品
	,b.sku_id
	,b.sku_real_point 商品单价
	,sk.cls12 DN价
	,j.front_category_id
	,f.`name` 前台分类
	,CASE b.spu_type 
		WHEN 51121001 THEN '精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '保养类卡券' 
		WHEN 51121004 THEN '精品'
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
	,ty.exchange_type_name　兑换类型
	,b.fee/100 总金额
	,b.sku_total_fee/ 100 商品金额
	,b.express_fee/ 100 运费金额
	,b.coupon_fee/100 优惠券抵扣金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.sku_num 兑换数量
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品' 
		WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
	,CASE a.status
			WHEN 51031002 THEN '待付款' 
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS 订单状态
	,CASE b.status
			WHEN 51301001 THEN '待付款' 
			WHEN 51301002 THEN '待发货' 
			WHEN 51301003 THEN '待收货' 
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭'  
	END AS 订单商品状态
	,a.create_time 兑换时间
	,a.pay_time 支付时间
	,b.product_id 商城兑换id
	,e.`退货状态`
	,e.退回时间
	,e.退回V值
	,e.`退货数量`
	,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
	,e.refund_express_code 退货物流单号
	,e.eclp_rtw_no 京东退货单号
	,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
	from `order`.tt_order a  -- 订单主表
	left join `order`.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
	left join (
--		#发货单表
		select d.* 
		from (
		select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
		,row_number() over(partition by d.order_code order by d.create_time desc) rk
		from `order`.tt_order_delivery d 
		where d.is_deleted=0
		) d where d.rk=1
	) d ON a.order_code = d.order_code
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
	left join goods.spu p on b.spu_bus_id=p.bus_id
	left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
	left join(
--		#V值退款成功记录
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
	where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	order by a.create_time)m
-- group by 1
-- order by 1




-- 4、用户活跃及留存
# 1、用户活跃

-- 商城MAU（车主＆粉丝）
select
DATE_FORMAT(t.`date`,'%Y-%m')年月
-- ,case when m.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
-- ,count(DISTINCT t.usertag) 商城UV
,count(DISTINCT case when m.IS_VEHICLE = 1 then t.usertag end) 车主UV
,count(DISTINCT case when m.IS_VEHICLE <> 1 or m.IS_VEHICLE is null then t.usertag end) 粉丝UV
from track.track t
left join(
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
where t.date >= '2023-01-01' and t.date <= '2023-03-31 23:59:59'    -- 用户访问时间
and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
GROUP BY 1
ORDER BY 1


-- 商城MAU（新老用户）
select
DATE_FORMAT(t.`date`,'%Y-%m')年月
,case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
,count(DISTINCT t.usertag)
-- ,count(DISTINCT case when o.user_id is null then t.usertag end) 商城新用户UV
-- ,count(DISTINCT case when o.user_id is not null then t.usertag end) 商城老用户UV
from track.track t 
left join(
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
left join (
	#商城新老用户 第一次访问商城的时间
	select DISTINCT a.user_id
	from (
	select a.order_code ,a.user_id,a.create_time
	,row_number() over(partition by a.user_id order by a.create_time) rk
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join(
		#V值退款成功记录
		select so.order_code,sp.product_id
		,sum(sp.sales_return_num) 退货数量
		,sum(so.refund_point) 退回V值
		,max(so.create_time) 退回时间
		from `order`.tt_sales_return_order so
		left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
		where so.is_deleted = 0 and so.status=51171004 -- 退款成功
		GROUP BY 1,2
	) e on a.order_code = e.order_code and b.product_id =e.product_id 
	join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
	where a.create_time < '2023-04-01'  -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	) a 
	where a.rk=1 and a.user_id is not null 
) o on m.id=o.user_id
where t.date >= '2023-01-01' and t.date < '2023-04-01'
and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
GROUP BY 1,2
order by 1


########## 新增（用户活跃及留存）
-- 活动拉新人数、排除车主
select 
date_format(t.date,'%Y-%m') 月份,
count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.date >= '2023-03-01' and t.date < '2023-04-01'
and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)
GROUP BY 1
order by 1


-- 僵尸粉-track表计算
select
date_format(a.mdate,'%Y-%m') 月份,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select 
 t.usertag,
 b.mdate,
 b.is_vehicle,
 max(t.date) tdate -- 获取访问文章活动10分钟之前的最晚访问时间
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select 
  m.is_vehicle,
  t.usertag,
  min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m 
  on t.usertag=CAST(m.user_id AS VARCHAR)
  where (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' 
  or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' 
  or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' 
  or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
  and t.`date` >= '2023-03-01' 
  and t.`date` < '2023-04-01'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1
order by 1



-- 商城MAU（车主＆粉丝） plan 1  (汇总)
select a.tt
,count(DISTINCT b.usertag) 次月留存
,count(DISTINCT c.usertag) 次年留存数
from 
	(
	#当月
	select
	DISTINCT t.usertag
	,DATE_FORMAT(t.`date`,'%Y-%m') tt
-- 	,count(DISTINCT t.usertag) 商城UV
	from track.track t
	left join(
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
	where t.date >= '2021-12-01' and t.date <= '2023-03-31 23:59:59'    -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
-- 	GROUP BY 2
	ORDER BY 2 )a 
left join 
	(
	#次月
	select
	DISTINCT t.usertag
	,DATE_FORMAT(DATE_SUB(t.date,INTERVAL 1 month),'%Y-%m') tt
	from track.track t
	left join(
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
	where t.date >= '2021-12-01' and t.date <= '2023-03-31 23:59:59'    -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
-- 	GROUP BY 1
	ORDER BY 2 )b on concat(a.usertag,a.tt)=concat(b.usertag,b.tt)
left join 
	(
	#次年
	select
	DISTINCT t.usertag
	,DATE_FORMAT(DATE_SUB(t.date,INTERVAL 1 year),'%Y-%m') tt
	from track.track t
	left join(
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
	where t.date >= '2021-12-01' and t.date <= '2023-03-31 23:59:59'    -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
-- 	GROUP BY 1
	ORDER BY 2 )c on concat(a.usertag,a.tt)=concat(c.usertag,c.tt)
group by 1
order by 1






-- 商城MAU（车主＆粉丝） plan 2   （单月）
select count(DISTINCT b.usertag) 次月留存,
count(DISTINCT c.usertag) 次年留存数
from 
	(
	#当月用户
	select
	DISTINCT t.usertag
	from track.track t
	left join(
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
	where t.date >= '2022-12-01' and t.date <= '2022-12-31 23:59:59'   -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
	)a 
left join 
	(
	#次月用户
	select
	DISTINCT t.usertag
	from track.track t
	left join(
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
	where t.date >= '2022-11-01' and t.date <= '2022-11-30 23:59:59'     -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
	)b on a.usertag=b.usertag
left join 
	(
	#次年用户
	select
	DISTINCT t.usertag
	from track.track t
	left join(
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
	where t.date >= '2021-12-01' and t.date <= '2021-12-31 23:59:59'   -- 用户访问时间
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
	)c on a.usertag=c.usertag

	
	
	
	


-- 用户复购（全类目） plan 1
SELECT a.tt,
count(a.购买人) 汇总,
count(b.购买人) 次月复购数,
count(c.购买人) 次年复购数
from 
(
	select 
	DISTINCT b.会员id 购买人
	,b.tt 
	from (
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
	,DATE_FORMAT(a.create_time,'%Y-%m') tt
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
	where a.create_time BETWEEN '2021-12-01' and '2023-03-31 23:59:59'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time
	) b
	where b.商品类型='第三方卡券'
-- 	b.商品类型='精品'
-- 	b.商品类型='保养类卡券'
-- 	GROUP BY 2 
	order by 2 
	) a 
left join 
	(
	#次月
	select 
	DISTINCT b.会员id 购买人
	,b.tt 
	from (
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
	,DATE_FORMAT(DATE_SUB(a.create_time,INTERVAL 1 month),'%Y-%m') tt -- 次月、次年 就修改成month 或者 year
-- 	,DATE_FORMAT(a.create_time,'%Y-%m') 月份
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
	where a.create_time BETWEEN '2021-12-01' and '2023-03-31 23:59:59'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time
	) b
	where b.商品类型='第三方卡券'
-- 	b.商品类型='精品'
-- 	b.商品类型='保养类卡券'
-- 	GROUP BY 2 
	order by 2 
	) b on concat(b.购买人,b.tt)=concat(a.购买人,a.tt)
	left join 
	(
	#次年
	select 
	DISTINCT b.会员id 购买人
	,b.tt 
	from (
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
	,DATE_FORMAT(DATE_SUB(a.create_time,INTERVAL 1 year),'%Y-%m') tt -- 次月、次年 就修改成month 或者 year
-- 	,DATE_FORMAT(a.create_time,'%Y-%m') 月份
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
	where a.create_time BETWEEN '2021-12-01' and '2023-03-31 23:59:59'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time
	) b
	where b.商品类型='第三方卡券'
-- 	b.商品类型='精品'
-- 	b.商品类型='保养类卡券'
-- 	GROUP BY 2 
	order by 2 
	) c on concat(c.购买人,c.tt)=concat(a.购买人,a.tt)
	group by 1
	order by 1

		
#########新增（沉睡一年用户激活）
-- 沉睡一年用户
select
date_format(a.mdate,'%Y-%m') 月份,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问小程序之前的最晚访问时间
 select 
 t.usertag,
 b.mdate,
 b.is_vehicle,
 max(t.date) tdate -- 获取访问小程序之前的最晚访问时间
 from track.track t
 join (
  -- 获取访问小程序文章活动的最早时间
  select 
  m.is_vehicle,
  t.usertag,
  min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m 
  on t.usertag=CAST(m.user_id AS VARCHAR)
  where t.`date` >= '2023-01-01'
  and t.`date` <= '2023-03-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date < b.mdate
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 1 year) -- 沉睡一年以上用户 
GROUP BY 1
order by 1


-- 沉睡一年用户激活
select
date_format(a.mdate,'%Y-%m') 月份,
count(distinct a.usertag) 激活数量
from(
 -- 获取访问文章活动10分钟之前的最晚访问时间
 select 
 t.usertag,
 b.mdate,
 b.is_vehicle,
 max(t.date) tdate -- 获取访问文章活动10分钟之前的最晚访问时间
 from track.track t
 join (
  -- 获取访问文章活动的最早时间
  select 
  m.is_vehicle,
  t.usertag,
  min(t.date) mdate 
  from track.track t 
  join member.tc_member_info m 
  on t.usertag=CAST(m.user_id AS VARCHAR)
  where (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' 
  or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' 
  or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' 
  or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
  and t.`date` >= '2023-01-01' 
  and t.`date` <= '2023-03-31 23:59:59'
  GROUP BY 1,2
 ) b on b.usertag=t.usertag
 where t.date< DATE_SUB(b.mdate,INTERVAL 10 MINUTE)
 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 1 year) -- 沉睡一年以上用户 
GROUP BY 1
order by 1



-- 商品数据
select
DISTINCT b.sku_bus_id SKU编码,
a.name 名称,
c.name 前台分类,
b.code 商品编码,
(b.price_sell/100) MSRP,
case when a.status = '60291003' then '上架中'
	when a.status = '60291004' then '已下架'
	else null end 商品状态,
a.last_up_time 上架时间,
a.lower_time 下架时间
-- case when a.lower_time is not null then DATEDIFF('day','2022-01-01',a.lower_time) + 1
-- 	when a.lower_time is null then (IF(a.last_up_time < '2022-01-01','31',DATEDIFF('day',a.last_up_time,'2022-08-31 23:59:59')+1))
-- 	end 上架天数
from goods.item_spu a
left join goods.item_sku b on a.id = b.spu_id
left join goods.front_category c on a.front_category_id = c.id
where a.status in ('60291003','60291004')   -- 商品状态：上架下架
and a.last_up_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
and (a.lower_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.lower_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY) or a.lower_time is null)
order by a.last_up_time desc


-- 
select
distinct a.id spu_id,
-- a.spu_bus_id,
b.code 商品编码,
b.id sku_id,
-- b.coupon_id 卡券ID,
-- b.coupon_name 卡券名称,
a.name 商品名称,
c1.title 一级类目,
c2.title 二级类目,
c3.title 三级类目
FROM goods.item_spu a
left join goods.item_sku b on a.id = b.spu_id
left join goods.category c1 on a.category1_id = c1.id 
left join goods.category c2 on a.category2_id = c2.id
left join goods.category c3 on a.category3_id = c3.id
order by 1
-- where b.coupon_id is not null  -- 这个不知道对不对




# 商城订单（未剔除退款订单，上架中的商品，在X月销量多少，有多少人购买）
select m.sku_bus_id,
COUNT(m.兑换数量)销量,
COUNT(DISTINCT m.会员表中id)购买用户数  from
(
	select a.order_code 订单编号
	,ifnull(a.parent_order_code,a.order_code) 母单号
	,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
		WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
		else null end 订单来源
	,a.user_id 会员表中id
	,a.user_name 会员姓名
	,a.user_phone 会员手机号
	,a.receiver_name 收货姓名
	,a.receiver_phone 收货手机号
	,concat (
			ifnull ( a.receiver_province_name, '' ),
			ifnull ( a.receiver_city_name, '' ),
			ifnull ( a.receiver_district_name, '' ),
			ifnull ( a.receiver_address, '' ) 
	) AS 收货地址
	,b.sku_code 商品货号
	,b.spu_name 兑换商品
	,b.sku_id
	,sk.sku_bus_id
	,b.sku_real_point 商品单价
	,sk.cls12 DN价
	,j.front_category_id
	,f.`name` 前台分类
	,CASE b.spu_type 
		WHEN 51121001 THEN '精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '保养类卡券' 
		WHEN 51121004 THEN '精品'
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
	,ty.exchange_type_name　兑换类型
	,b.fee/100 总金额
	,b.sku_total_fee/ 100 商品金额
	,b.express_fee/ 100 运费金额
	,b.coupon_fee/100 优惠券抵扣金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.sku_num 兑换数量
	,CASE b.spu_type 
		WHEN 51121001 THEN 'VOLVO仓商品' 
		WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
	,CASE a.status
			WHEN 51031002 THEN '待付款' 
			WHEN 51031003 THEN '待发货' 
			WHEN 51031004 THEN '待收货' 
			WHEN 51031005 THEN '已完成'
			WHEN 51031006 THEN '已关闭'  
	END AS 订单状态
	,CASE b.status
			WHEN 51301001 THEN '待付款' 
			WHEN 51301002 THEN '待发货' 
			WHEN 51301003 THEN '待收货' 
			WHEN 51301004 THEN '收货确认'
			WHEN 51301005 THEN '退货中'
			WHEN 51301006 THEN '交易关闭'  
	END AS 订单商品状态
	,a.create_time 兑换时间
	,a.pay_time 支付时间
	,b.product_id 商城兑换id
	,e.`退货状态`
	,e.退回时间
	,e.退回V值
	,e.`退货数量`
	,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
	,e.refund_express_code 退货物流单号
	,e.eclp_rtw_no 京东退货单号
	,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
	from order.tt_order a  -- 订单主表
	left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
	left join (
		#发货单表
		select d.* 
		from (
		select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
		,row_number() over(partition by d.order_code order by d.create_time desc) rk
		from `order`.tt_order_delivery d 
		where d.is_deleted=0
		) d where d.rk=1
	) d ON a.order_code = d.order_code
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
	LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
	left join goods.spu p on b.spu_bus_id=p.bus_id
	left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
	left join(
		#V值退款成功记录
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
	where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)
	and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and e.order_code is null  -- 剔除退款订单
	and sk.sku_bus_id in 
	(
		# 需要需改日期
		select distinct i.sku_bus_id from
		(
			select
			distinct b.sku_bus_id
			from goods.item_spu a
			left join goods.item_sku b on a.id = b.spu_id
			left join goods.front_category c on a.front_category_id = c.id
			where a.status in ('60291003','60291004')   -- 商品状态：上架下架
			and a.last_up_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
			and (a.lower_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.lower_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY) or a.lower_time is null)
		) i
	)
	order by a.create_time
) m
group by 1
order by 2 desc




# 小程序商城链路
-- 1、用户侧 商城新老用户
select a.*
,b.商城UV
,c.合计,c.精品详情页UV,c.售后详情页UV,c.第三方详情页UV
,c.合计/a.沃世界MAU 导流率合计
,c.精品详情页UV/a.沃世界MAU 导流率精品
,c.售后详情页UV/a.沃世界MAU 导流率售后
,c.第三方详情页UV/a.沃世界MAU 导流率第三方
,d.下单商品数合计,d.下单商品数精品,d.下单商品数售后,d.下单商品数第三方
,d.下单用户数合计,d.下单用户数精品,d.下单用户数售后,d.下单用户数第三方
,d.下单用户数合计/c.合计
,d.下单用户数精品/c.精品详情页UV
,d.下单用户数售后/c.售后详情页UV
,d.下单用户数第三方/c.第三方详情页UV
,d.订单数,d.订单数精品,d.订单数售后,d.订单数第三方
,d.客单价,d.客单价精品,d.客单价售后,d.客单价第三方
,d.销售额合计,d.销售额精品,d.销售额售后,d.销售额第三方
,d.销售额V值合计,d.销售额V值精品,d.销售额V值售后,d.销售额V值第三方
,d.销售额现金合计,d.销售额现金精品,d.销售额现金售后,d.销售额现金第三方
,d.销售额优惠券合计,d.销售额优惠券精品,d.销售额优惠券售后,d.销售额优惠券第三方
from (
	#沃世界MAU
	select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
	,count(DISTINCT m.id) 沃世界MAU
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
	left join (
		#商城新老用户
		select DISTINCT a.user_id
		from (
		select a.order_code ,a.user_id,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.date>m.member_time 
	GROUP BY 1
) a 
left join (
	#商城UV
	select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
	,count(DISTINCT t.usertag) 商城UV
	from track.track t 
	left join(
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
	left join (
		#商城新老用户
		select DISTINCT a.user_id
		from (
		select a.order_code ,a.user_id,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1 and a.user_id is not null 
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
	GROUP BY 1 
) b on a.用户分类=b.用户分类
left join (
	#商品详情页UV
	select a.用户分类
	,count(DISTINCT a.usertag) 合计
	,count(DISTINCT case when a.商品类型='精品' then a.usertag else null end) 精品详情页UV
	,count(DISTINCT case when a.商品类型='保养类卡券' then a.usertag else null end) 售后详情页UV
	,count(DISTINCT case when a.商品类型='第三方卡券' then a.usertag else null end) 第三方详情页UV
	from (
		select case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
		,t.usertag
		,cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) spuid
		,CASE p.item_type
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			-- WHEN 51121006 THEN '一件代发'
			-- WHEN 51121007 THEN '经销商端产品' 
			ELSE '精品' end 商品类型
		from track.track t 
		left join(
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
		left join (
			#商城新老用户
			select DISTINCT a.user_id
			from (
			select a.order_code ,a.user_id,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on m.id=o.user_id
		left join goods.item_spu p on cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) = p.id
		where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
		and t.typeid = 'XWSJXCX_MALL_DETAIL_V' and json_extract(t.data,'$.spuId') is not null 
	) a 
	GROUP BY 1 
) c on c.用户分类=b.用户分类
left join (
	#订单
	select o.用户分类
	,sum(o.`兑换数量`) 下单商品数合计
	,sum(case when o.商品类型='精品' then o.`兑换数量` else null end) 下单商品数精品
	,sum(case when o.商品类型='保养类卡券' then o.`兑换数量` else null end) 下单商品数售后
	,sum(case when o.商品类型='第三方卡券' then o.`兑换数量` else null end) 下单商品数第三方
	,count(DISTINCT o.`会员id`) 下单用户数合计
	,count(DISTINCT case when o.商品类型='精品' then o.`会员id` else null end) 下单用户数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.`会员id` else null end) 下单用户数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.`会员id` else null end) 下单用户数第三方
	,count(DISTINCT o.`订单编号`) 订单数
	,count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end) 订单数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end) 订单数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end) 订单数第三方
	,round(sum(o.`实付金额`)/count(DISTINCT o.`订单编号`),0) 客单价
	,round(sum(case when o.商品类型='精品' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end)) 客单价精品
	,round(sum(case when o.商品类型='保养类卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end)) 客单价售后
	,round(sum(case when o.商品类型='第三方卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end)) 客单价第三方
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
		,case when o.user_id is null then '商城新用户' else '商城老用户' end 用户分类
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
		left join (
			#商城新老用户
			select DISTINCT a.user_id
			from (
			select a.order_code ,a.user_id,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on a.user_id=o.user_id
		where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) o GROUP BY 1 
) d on d.用户分类=c.用户分类



-- 2、用户侧 车主粉丝
select a.*
,b.商城UV
,c.合计,c.精品详情页UV,c.售后详情页UV,c.第三方详情页UV
,c.合计/a.沃世界MAU 导流率合计
,c.精品详情页UV/a.沃世界MAU 导流率精品
,c.售后详情页UV/a.沃世界MAU 导流率售后
,c.第三方详情页UV/a.沃世界MAU 导流率第三方
,d.下单商品数合计,d.下单商品数精品,d.下单商品数售后,d.下单商品数第三方
,d.下单用户数合计,d.下单用户数精品,d.下单用户数售后,d.下单用户数第三方
,d.下单用户数合计/c.合计
,d.下单用户数精品/c.精品详情页UV
,d.下单用户数售后/c.售后详情页UV
,d.下单用户数第三方/c.第三方详情页UV
,d.订单数,d.订单数精品,d.订单数售后,d.订单数第三方
,d.客单价,d.客单价精品,d.客单价售后,d.客单价第三方
,d.销售额合计,d.销售额精品,d.销售额售后,d.销售额第三方
,d.销售额V值合计,d.销售额V值精品,d.销售额V值售后,d.销售额V值第三方
,d.销售额现金合计,d.销售额现金精品,d.销售额现金售后,d.销售额现金第三方
,d.销售额优惠券合计,d.销售额优惠券精品,d.销售额优惠券售后,d.销售额优惠券第三方
from (
	#沃世界MAU
	select case when m.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
	,count(DISTINCT m.id) 沃世界MAU
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
	left join (
		#商城下单车主粉丝
		select DISTINCT a.user_id,a.is_vehicle
		from (
		select a.order_code,a.user_id,m.is_vehicle,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
-- 		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
		where a.create_time <'2022-02-01'
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and t.date>m.member_time 
	GROUP BY 1
) a 
left join (
	#商城UV
	select case when m.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
	,count(DISTINCT t.usertag) 商城UV
	from track.track t 
	left join(
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
	left join (
		#商城下单车主粉丝
		select DISTINCT a.user_id,a.is_vehicle
		from (
		select a.order_code,a.user_id,m.is_vehicle,a.create_time
		,row_number() over(partition by a.user_id order by a.create_time) rk
		from order.tt_order a  -- 订单主表
		left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
		left join(
			#V值退款成功记录
			select so.order_code,sp.product_id
			,sum(sp.sales_return_num) 退货数量
			,sum(so.refund_point) 退回V值
			,max(so.create_time) 退回时间
			from `order`.tt_sales_return_order so
			left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
			where so.is_deleted = 0 and so.status=51171004 -- 退款成功
			GROUP BY 1,2
		) e on a.order_code = e.order_code and b.product_id =e.product_id 
		join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
		where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		) a 
		where a.rk=1 and a.user_id is not null 
	) o on m.id=o.user_id
	where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
	and (t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' or json_extract(t.data,'$.embeddedpoint') = 'shop_banner_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'loveCar_shopPart_CLICK' or json_extract(t.data,'$.embeddedpoint') = 'shop_search_CLICK')
	GROUP BY 1 
) b on a.用户分类=b.用户分类
left join (
	#商品详情页UV
	select a.用户分类
	,count(DISTINCT a.usertag) 合计
	,count(DISTINCT case when a.商品类型='精品' then a.usertag else null end) 精品详情页UV
	,count(DISTINCT case when a.商品类型='保养类卡券' then a.usertag else null end) 售后详情页UV
	,count(DISTINCT case when a.商品类型='第三方卡券' then a.usertag else null end) 第三方详情页UV
	from (
		select case when m.IS_VEHICLE = 1 then '车主' else '粉丝' end 用户分类
		,t.usertag
		,cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) spuid
		,CASE p.item_type
			WHEN 51121001 THEN '精品' 
			WHEN 51121002 THEN '第三方卡券' 
			WHEN 51121003 THEN '保养类卡券' 
			WHEN 51121004 THEN '精品'
			-- WHEN 51121006 THEN '一件代发'
			-- WHEN 51121007 THEN '经销商端产品' 
			ELSE '精品' end 商品类型
		from track.track t 
		left join(
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
		left join (
			#商城下单车主粉丝
			select DISTINCT a.user_id,a.IS_VEHICLE
			from (
			select a.order_code,a.user_id,m.IS_VEHICLE,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)   -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null 
		) o on m.id=o.user_id
		left join goods.item_spu p on cast(replace(json_extract(t.data,'$.spuId'),'"','') as int) = p.id
		where t.date >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and t.date < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
		and t.typeid = 'XWSJXCX_MALL_DETAIL_V' and json_extract(t.data,'$.spuId') is not null 
	) a 
	GROUP BY 1 
) c on c.用户分类=b.用户分类
left join (
	#订单
	select o.用户分类
	,sum(o.`兑换数量`) 下单商品数合计
	,sum(case when o.商品类型='精品' then o.`兑换数量` else null end) 下单商品数精品
	,sum(case when o.商品类型='保养类卡券' then o.`兑换数量` else null end) 下单商品数售后
	,sum(case when o.商品类型='第三方卡券' then o.`兑换数量` else null end) 下单商品数第三方
	,count(DISTINCT o.`会员id`) 下单用户数合计
	,count(DISTINCT case when o.商品类型='精品' then o.`会员id` else null end) 下单用户数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.`会员id` else null end) 下单用户数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.`会员id` else null end) 下单用户数第三方
	,count(DISTINCT o.`订单编号`) 订单数
	,count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end) 订单数精品
	,count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end) 订单数售后
	,count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end) 订单数第三方
	,round(sum(o.`实付金额`)/count(DISTINCT o.`订单编号`),0) 客单价
	,round(sum(case when o.商品类型='精品' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='精品' then o.订单编号 else null end)) 客单价精品
	,round(sum(case when o.商品类型='保养类卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='保养类卡券' then o.订单编号 else null end)) 客单价售后
	,round(sum(case when o.商品类型='第三方卡券' then o.实付金额 else 0 end)/count(DISTINCT case when o.商品类型='第三方卡券' then o.订单编号 else null end)) 客单价第三方
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
		,case when h.IS_VEHICLE = 1 then '车主' else '粉丝' END 用户分类
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
		left join (
			#商城下单车主粉丝
			select DISTINCT a.user_id
			from (
			select a.order_code,a.user_id,m.IS_VEHICLE,a.create_time
			,row_number() over(partition by a.user_id order by a.create_time) rk
			from order.tt_order a  -- 订单主表
			left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
			left join(
				#V值退款成功记录
				select so.order_code,sp.product_id
				,sum(sp.sales_return_num) 退货数量
				,sum(so.refund_point) 退回V值
				,max(so.create_time) 退回时间
				from `order`.tt_sales_return_order so
				left join `order`.tt_sales_return_order_product sp on so.refund_order_code=sp.refund_order_code and sp.is_deleted=0
				where so.is_deleted = 0 and so.status=51171004 -- 退款成功
				GROUP BY 1,2
			) e on a.order_code = e.order_code and b.product_id =e.product_id 
			join member.tc_member_info m on a.user_id = m.id and m.is_deleted=0 and m.MEMBER_STATUS<>60341003  -- 会员表(获取会员信息)
			where a.create_time < DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH)  -- 订单时间
			and a.is_deleted <> 1  -- 剔除逻辑删除订单
			and a.type = 31011003  -- 筛选沃世界商城订单
			and a.separate_status = '10041002' -- 选择拆单状态否
			and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
			AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
			and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
			and e.order_code is null  -- 剔除退款订单
			) a 
			where a.rk=1 and a.user_id is not null
		) o on a.user_id=o.user_id
		where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
		and a.is_deleted <> 1  -- 剔除逻辑删除订单
		and a.type = 31011003  -- 筛选沃世界商城订单
		and a.separate_status = '10041002' -- 选择拆单状态否
		and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
		AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
		and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
		and e.order_code is null  -- 剔除退款订单
		order by a.create_time
	) o GROUP BY 1 
) d on d.用户分类=c.用户分类
order by 1 desc 



-- 3、在线商品数（SPU、SKU）
select count(DISTINCT a.spu_bus_id) 在线商品数spu
,count(DISTINCT case when a.item_type in (51121001,51121004) then a.spu_bus_id else null end) 精品spu
,count(DISTINCT case when a.item_type = 51121003 then a.spu_bus_id else null end) 售后spu
,count(DISTINCT case when a.item_type = 51121002 then a.spu_bus_id else null end) 第三方spu
,count(DISTINCT b.sku_bus_id) 在线商品数sku
,count(DISTINCT case when a.item_type in (51121001,51121004) then b.sku_bus_id else null end) 精品sku
,count(DISTINCT case when a.item_type = 51121003 then b.sku_bus_id else null end) 售后sku
,count(DISTINCT case when a.item_type = 51121002 then b.sku_bus_id else null end) 第三方sku
from goods.item_spu a
LEFT JOIN goods.item_sku b ON a.id = b.spu_id
-- where a.`status`= 60291003
where (a.`status`= 60291003 or (a.lower_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.lower_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY) and a.`status`=60291004))
and a.item_type in (51121001,51121002,51121003,51121004)
and a.date_create <= DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY);


-- 4、动销商品数
select count(DISTINCT b.spu_bus_id) 动销商品数spu
,count(DISTINCT case when j.item_type in (51121001,51121004) then b.spu_bus_id else null end) 精品spu
,count(DISTINCT case when j.item_type = 51121003 then b.spu_bus_id else null end) 售后spu
,count(DISTINCT case when j.item_type = 51121002 then b.spu_bus_id else null end) 第三方spu
,count(DISTINCT b.sku_bus_id) 动销商品数sku
,count(DISTINCT case when j.item_type in (51121001,51121004) then b.sku_bus_id else null end) 精品sku
,count(DISTINCT case when j.item_type = 51121003 then b.sku_bus_id else null end) 售后sku
,count(DISTINCT case when j.item_type = 51121002 then b.sku_bus_id else null end) 第三方sku
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
left join
(
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
-- where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单






# 商城订单（未剔除退款订单）
select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end 订单来源
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
	#V值退款成功记录
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
where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and e.order_code is null  -- 剔除退款订单
order by a.create_time;





# 退款明细
select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end 订单来源
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
	#V值退款成功记录
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
where a.create_time >= DATE_sub(CURDATE()-DAY(CURDATE())+1,INTERVAL 1 MONTH) and a.create_time < DATE_ADD(CURDATE(),INTERVAL -DAY(CURDATE())+1 DAY)   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is not null  -- 剔除退款订单
order by a.create_time;












--------------- 2023.1.30 临时需求
# 商城订单保养类卡券明细
select a.order_code 订单编号
,ifnull(a.parent_order_code,a.order_code) 母单号
,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
			WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
			else null end 订单来源
,a.user_id 会员表中id
,a.user_name 会员姓名
,a.user_phone 会员手机号
,a.receiver_name 收货姓名
,a.receiver_phone 收货手机号
,concat (
		ifnull ( a.receiver_province_name, '' ),
		ifnull ( a.receiver_city_name, '' ),
		ifnull ( a.receiver_district_name, '' ),
		ifnull ( a.receiver_address, '' ) 
) AS 收货地址
,b.sku_code 商品货号
,b.spu_name 兑换商品
,b.sku_id
,b.sku_real_point 商品单价
,sk.cls12 DN价
,j.front_category_id
,f.`name` 前台分类
,CASE b.spu_type 
	WHEN 51121001 THEN '精品' 
	WHEN 51121002 THEN '第三方卡券' 
	WHEN 51121003 THEN '保养类卡券' 
	WHEN 51121004 THEN '精品'
	WHEN 51121006 THEN '一件代发'
	WHEN 51121007 THEN '经销商端产品' ELSE null end 商品类型
,ty.exchange_type_name　兑换类型
,b.fee/100 总金额
,b.sku_total_fee/ 100 商品金额
,b.express_fee/ 100 运费金额
,b.coupon_fee/100 优惠券抵扣金额
,b.pay_fee/100 现金支付金额
,b.point_amount 支付V值
,b.sku_num 兑换数量
,CASE b.spu_type 
	WHEN 51121001 THEN 'VOLVO仓商品' 
	WHEN 51121002 THEN 'VOLVO仓第三方卡券' 
	WHEN 51121003 THEN '虚拟服务卡券' 
	WHEN 51121004 THEN '京东仓商品' ELSE NULL END AS 仓库
,CASE a.status
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
END AS 订单状态
,CASE b.status
		WHEN 51301001 THEN '待付款' 
		WHEN 51301002 THEN '待发货' 
		WHEN 51301003 THEN '待收货' 
		WHEN 51301004 THEN '收货确认'
		WHEN 51301005 THEN '退货中'
		WHEN 51301006 THEN '交易关闭'  
END AS 订单商品状态
,a.create_time 兑换时间
,a.pay_time 支付时间
,b.product_id 商城兑换id
,e.`退货状态`
,e.退回时间
,e.退回V值
,e.`退货数量`
,CASE a.close_reason WHEN 51091003 THEN '用户退款' WHEN 51091004 THEN '用户退货退款' WHEN 51091005 THEN '商家退款' END AS 退货原因
,e.refund_express_code 退货物流单号
,e.eclp_rtw_no 京东退货单号
,d.delivery_status,d.express_company 快递公司,d.express_code 快递单号
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
-- LEFT JOIN ORDER.tt_order_delivery d ON a.order_code = d.order_code AND d.is_deleted <> 1
left join (
	#发货单表
	select d.* 
	from (
	select d.order_code,d.delivery_code,d.delivery_status,d.express_company,d.express_code 
	,row_number() over(partition by d.order_code order by d.create_time desc) rk
	from `order`.tt_order_delivery d 
	where d.is_deleted=0
	) d where d.rk=1
) d ON a.order_code = d.order_code
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join goods.item_spu j on b.spu_id = j.id  and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
left join goods.front_category f on f.id=j.front_category_id -- 前台专区列表(获取前天专区名称)
LEFT JOIN goods.item_sku sk on sk.id=b.sku_id -- 前台sku表(获取商品DN价)
left join goods.spu p on b.spu_bus_id=p.bus_id
left join goods.exchange_type ty on p.exchange_type_id=ty.exchange_type_id
left join(
	#V值退款成功记录
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
where a.create_time >= '2022-01-01' and a.create_time <= '2022-12-31 23:59:59'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and b.spu_type = '51121003'   -- 保养类卡券
order by a.create_time