-- 一店一码
select 
distinct 
a.order_code 订单编号
	,b.product_id 商城兑换id
	,concat(year(a.create_time),'-',EXTRACT(QUARTER FROM a.create_time))季度
	,date_format(a.create_time,'%Y-%m') 月份
	,a.user_id 会员id
	,h.cust_id 
	,a.user_name 会员姓名
	,b.spu_name 兑换商品
	,b.sku_code
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point 商品单价
	,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
    ,ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,
		case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end) 前台分类
	,b.fee/100 总金额
	,b.coupon_fee/100 优惠券抵扣金额
	,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) 不含税的总金额
	,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.sku_num 兑换数量
	,b.sku_price 指导价
	,cv.verify_amount 优惠券核销金额
	,tci.coupon_name 使用优惠券名称
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
	,c.dealer_code 推荐经销商
    ,c.advisor_no 销售顾问
--    ,tu.member_id
    ,ifnull(tu.user_id,0) 顾问编号
    ,ifnull(te.employee_name,c.advisor_no)销售人员
    ,activity 活动信息
    ,channel_code 渠道码
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join "order".tt_order_product_ex c on a.order_code = c.order_code and b.product_id=c.order_product_id  and c.is_deleted <> 1 -- 一店一码订单表
	left join authentication.tm_user tu on cast(tu.user_id as varchar)=c.advisor_no
	left join authentication.tm_emp te on te.emp_id=tu.emp_id
	left join coupon.tt_coupon_verify cv on cv.order_no =b.order_code and cv.is_deleted <>1 -- 优惠券核销表 核销金额
	left join coupon.tt_coupon_info tci on cv.coupon_id =tci.id 
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id and j.is_deleted =0 and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join (
		select spu_id,sku_id,front_category1_id
		from goods.item_sku_channel 
		where is_deleted =0
		and front_category1_id in (195,212,219,230)
		and client_id='2b9890ef-d828-11ec-be68-00163e0ebd17'
		) isc on isc.spu_id=b.spu_id and isc.sku_id=b.sku_id 
left join goods.front_category f on f.id = isc.front_category1_id     -- 前台专区列表(获取前台专区名称)
--	left join goods.front_category f on f.id=j.front_category1_id -- 前台专区列表(获取前天专区名称)
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
	and a.create_time >= '2025-01-01' 
--    and a.create_time <'2024-10-01'   --  date(now())
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--	and (b.spu_type in (51121001,51121004,51121006,51121007,51121008) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--	and e.order_code is null  -- 剔除退款订单
--	and c.dealer_code ='TJF'
	and c.dealer_code <>''
--	and sku_code='31422885'
	order by a.create_time desc 

	
--QTD PVUV报表
select 
concat(x.platform,'_',x.`PN`,'_',x.`推荐经销商`) plat_sku_code_de,
x.`月份`,
x.`推荐经销商`,
x.`PN`,
x.`商品名称`,
x.platform,
round(x.PV/x2.num,3) PV,
round(x.UV/x2.num,3) UV
from 
	(
	select 
	formatDateTime(client_time,'%Y-%m') `月份`
--	toString(toQuarter(event_time)) `季度`
	,a.var_dealer_code `推荐经销商`
--	,a.var_sales_id `销售人员`
	,a.var_product_id var_product_id
	,c.code PN
	--,c.coupon_name 
	,d.name `商品名称`
	,case when $platform='MinP' then 'mini'
	        when $platform in('iOS','HarmonyOS','Android') then 'app'
	        else null end as platform
	,count(1) PV
	,count(distinct b.usr_merged_gio_id) UV
	--event_key,usr_merged_gio_id,var_page_title,var_dealer_code,$platform,$os,client_time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
	left join ods_good.ods_good_item_sku_d c on c.spu_id::varchar=a.var_product_id::varchar
	left join ods_good.ods_good_item_spu_d d on d.id::varchar=a.var_product_id::varchar
	where 1=1
	--and date(client_time) >='2025-01-01'
	and client_time>='2025-01-01'
	and event_time>='2025-01-01'
	and event_key ='Page_entry'
	and var_dealer_code is not null 
	and var_page_title='商品详情页'
	group by 1,2,3,4,5,6
	order by 1,2,3,4,5,6
)x
left join (
	select c.id spuid,count(distinct d.code) num 
	from  ods_good.ods_good_item_spu_d c  -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_item_sku_d d on c.id::varchar=d.spu_id::varchar
	--where id ='3618'
	group by 1 )x2 on x2.spuid::varchar=x.var_product_id::varchar


	
--QTD PVUV报表 一人一码
select 
concat(x.platform,'_',x.`PN`,'_',x.`推荐经销商`,'_',x.`月份`) plat_sku_code_de,
x.`月份`,
x.`推荐经销商`,
x.`销售人员`,
x.`PN`,
x.`商品名称`,
x.platform,
round(x.PV/x2.num,3) PV,
round(x.UV/x2.num,3) UV
from 
	(
	select 
	formatDateTime(client_time,'%Y-%m') `月份`
--	toString(toQuarter(event_time)) `季度`
	,a.var_dealer_code `推荐经销商`
	,a.var_sales_id `销售人员`
	,a.var_product_id var_product_id
	,c.code PN
	--,c.coupon_name 
	,d.name `商品名称`
	,case when $platform='MinP' then 'mini'
	        when $platform in('iOS','HarmonyOS','Android') then 'app'
	        else null end as platform
	,count(1) PV
	,count(distinct b.usr_merged_gio_id) UV
	--event_key,usr_merged_gio_id,var_page_title,var_dealer_code,$platform,$os,client_time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
	left join ods_good.ods_good_item_sku_d c on c.spu_id::varchar=a.var_product_id::varchar
	left join ods_good.ods_good_item_spu_d d on d.id::varchar=a.var_product_id::varchar
	where 1=1
	--and date(client_time) >='2025-01-01'
	and client_time>='2025-01-01'
	and event_time>='2025-01-01'
	and event_key ='Page_entry'
	and var_dealer_code in ('JNG',
'JNF',
'TJF',
'BJT',
'SHK',
'WHA',
'WHC',
'SZH',
'GZH',
'CDF',
'KME')
	and var_page_title='商品详情页'
	group by 1,2,3,4,5,6,7
	order by 1,2,3,4,5,6,7
)x
left join (
	select c.id spuid,count(distinct d.code) num 
	from  ods_good.ods_good_item_spu_d c  -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_item_sku_d d on c.id::varchar=d.spu_id::varchar
	--where id ='3618'
	group by 1 )x2 on x2.spuid::varchar=x.var_product_id::varchar
order by PV desc 
	

	

------------------------------------------------------------------------

--QTD PVUV报表  广州车展
select 
concat(x.platform,'_',x.`PN`,'_',x.`推荐经销商`) plat_sku_code_de,
x.`季度`,
x.`推荐经销商`,
x.`PN`,
x.`商品名称`,
x.platform,
--round(x.PV/x2.num,3) PV,
round(x.UV/x2.num,3) UV
from 
	(
	select 
	concat(toString(year(event_time)),'-',toString(toQuarter(event_time))) `季度`
	,a.var_dealer_code `推荐经销商`
	,a.var_product_id var_product_id
	,c.code PN
	--,c.coupon_name 
	,d.name `商品名称`
	,case when $platform='MinP' then 'mini'
	        when $platform in('iOS','HarmonyOS','Android') then 'app'
	        else null end as platform
	,count(1) PV
	,count(distinct b.usr_merged_gio_id) UV
	--event_key,usr_merged_gio_id,var_page_title,var_dealer_code,$platform,$os,client_time
	from ods_gio.ods_gio_event_d a
	left join ods_gio.ods_gio_user_d b on toString(a.gio_id)=toString(b.gio_id)
	left join ods_good.ods_good_item_sku_d c on c.spu_id::varchar=a.var_product_id::varchar
	left join ods_good.ods_good_item_spu_d d on d.id::varchar=a.var_product_id::varchar
	where 1=1
	and client_time>='2024-11-01'
	and event_time>='2024-11-01'
	and event_time<'2024-11-25'
	and event_key ='Page_entry'
	and var_page_title='商品详情页'	
	and var_channel_activity_id='AA2024GZAUTO' -- 广州车展
	group by 1,2,3,4,5,6
	order by 1,2,3,4,5,6
)x
left join (
	select c.id spuid,count(distinct d.code) num 
	from  ods_good.ods_good_item_spu_d c  -- 前台spu表(获取商品前台专区ID)
	left join ods_good.ods_good_item_sku_d d on c.id::varchar=d.spu_id::varchar
	--where id ='3618'
	group by 1 )x2 on x2.spuid::varchar=x.var_product_id::varchar

