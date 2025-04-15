-- 过去6个月使用过沃世界养修预约功能的车主
select 
-- count(DISTINCT x.沃世界绑定手机号),
DISTINCT x.沃世界绑定手机号
from 
	(
	select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
	       ta.APPOINTMENT_ID "预约ID",
	       ta.OWNER_CODE "经销商代码",
	       tc2.COMPANY_NAME_CN "经销商名称",
	       ta.ONE_ID "车主oneid",
	       tam.OWNER_ONE_ID,
	       ta.CUSTOMER_NAME "联系人姓名",
	       ta.CUSTOMER_PHONE "联系人手机号",
	       tmi.ID "会员ID",
	       tmi.MEMBER_PHONE "沃世界绑定手机号",
	       tam.CAR_MODEL "预约车型",
	       tam.CAR_STYLE "预约车款",
	       tam.VIN "车架号",
	       case when tam.IS_TAKE_CAR = "10041001" then "是" 
	    when tam.IS_TAKE_CAR = "10041002" then "否" 
	     end  "是否取车",
	       case when tam.IS_GIVE_CAR = "10041001" then "是"
	         when tam.IS_GIVE_CAR = "10041002" then "否"
	       end "是否送车",
	       tam.MAINTAIN_STATUS "养修状态code",
	       tc.CODE_CN_DESC "养修状态",
	       tam.CREATED_AT "创建时间",
	       tam.UPDATED_AT "修改时间",
	       ta.CREATED_AT "预约时间",
	       tam.WORK_ORDER_NUMBER "工单号"
	from cyx_appointment.tt_appointment  ta
	left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
	left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
	left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
	left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID and tmi.IS_DELETED =0 and tmi.IS_VEHICLE =1
	where ta.CREATED_AT >= DATE_SUB('2022-07-20 23:59:59',INTERVAL 6 MONTH) 
	and ta.CREATED_AT < '2022-07-20 23:59:59' 
	and ta.DATA_SOURCE ="C"
	and ta.APPOINTMENT_TYPE =70691005
	)x

-- 过去6个月在商城有过购买记录的车主
select 
-- COUNT(DISTINCT x.沃世界注册手机号) 
DISTINCT x.沃世界注册手机号
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
	where a.create_time >= DATE_SUB('2022-07-20 23:59:59',interval 6 month) and a.create_time <= '2022-07-20 23:59:59'   -- 订单时间
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	-- and b.spu_id in ('2269','2270','2210','2358','2356','2289','2266')  -- 筛选7种商品
	order by a.create_time
	)x
	
-- 参加过今年525、春服、冬服、去年秋服、夏服的车主
select DISTINCT tmi.member_phone
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.date>='2022-05-23'
and json_extract(t.`data`,'$.embeddedpoint') in ('collectionPage_home_预热_click','collectionPage_home_正式_click')
union 
select DISTINCT tmi.member_phone
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-01-01'   -- 时间自行修改
and json_extract(t.`data`,'$.embeddedpoint')  = 'CHUNFU2022_SHOUYE_ONLOAD'

-- 2021年7月8日-2021年8月31日 2021年10月30日-2021年12月31日活跃车主
select DISTINCT tmi.member_phone
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 
where t.`date` >= '2021-07-08'   -- 时间自行修改
and t.date<'2021-09-01'
and tmi.IS_VEHICLE =1 -- 车主
union 
select DISTINCT tmi.member_phone
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0 
where t.`date` >= '2021-10-30'   -- 时间自行修改
and t.date<'2022-01-01'
and tmi.IS_VEHICLE =1 -- 车主


-- 过去6个月点击过【沃讲堂】系列文章的车主
select DISTINCT tmi.member_phone
from `member`.tc_member_info tmi 
join 
	(
	select a.user_id,a.date_create,a.ref_id
	from `cms-center`.cms_operate_log a
	where a.deleted=0
	and a.date_create >=DATE_SUB('2022-07-20 23:59:59',INTERVAL 6 MONTH) and a.date_create <='2022-07-20 23:59:59'  
	group by 1 -- 分组自动获取最新时间的记录
	order by 2 desc
	)x on x.user_id=tmi.USER_ID
where x.ref_id in('AT82CIgMPs','mNMJ3Su0Vt','sLwJ0MjELp')
and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
