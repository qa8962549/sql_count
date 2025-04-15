-- 截止5月30日18时，沃世界V值余额大于等于50V值，且本月未活跃的沃世界绑车车主 5-4-1
select DISTINCT m.MEMBER_PHONE
from member.tc_member_info m 
left join (
	# 4月活跃用户
	select DISTINCT t.usertag
	from track.track t 
	join member.tc_member_info m on CAST(m.USER_ID AS VARCHAR) = t.usertag
	where t.date >='2022-05-01' and t.date <= '2022-05-30 18:00:00'
	and t.date > m.create_time
) t on CAST(m.USER_ID AS VARCHAR) = t.usertag
where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
and t.usertag is  null -- 5月未活跃用户
and m.MEMBER_V_NUM>= 50
and LENGTH(m.member_phone)=11 and `LEFT`(m.member_phone,1)='1'
and m.IS_VEHICLE=1

-- 5-11-2 未下过沃世界商城订单且当前有效V值≥500的用户
select 
DISTINCT p.手机号
from 
(select
tmi.ID 会员ID,
tmi.MEMBER_PHONE 手机号,
tmi.MEMBER_V_NUM V值
from `member`.tc_member_info tmi 
left join 
(
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,a.create_time 兑换时间
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
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
order by a.create_time
)x on tmi.ID =x.会员id
where x.会员id is null -- 剔除订单用户
and tmi.MEMBER_V_NUM >= '500'
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
order by 3 desc
) p

-- 6-1-1 近30天将有大额过期积分，9月1号和10月1号即将过期V值总和大于等于1,500 V值的人

# 2022年8月人群包

select c.*
from (
select a.*
,case when b.手机 is not null then 1 else null end 重复
from (
	### 9月即将过期V值
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
			else '1' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-08-31 23:59:59'
			and a.CREATE_TIME>='2020-08-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC
	union all 
	### 10月即将过期V值
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '4'
			else '3' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-09-30 23:59:59'
			and a.CREATE_TIME>='2020-09-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
			and b.id not in (
				select a.member_id
				from (
						select a.MEMBER_ID,
						b.real_name 姓名,
						b.member_phone 手机,
						b.member_v_num V值余额,
						b.is_vehicle,
						sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
						case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
						else '1' end 区间
						from `member`.tt_member_score_record a
						join `member`.tc_member_info b on a.MEMBER_ID = b.id
						where a.IS_DELETED=0
						and a.CREATE_TIME<='2020-08-31 23:59:59'
						and a.CREATE_TIME>='2020-08-01'
						and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
						AND b.is_deleted = 0
						AND b.member_status = 60341001
						GROUP BY 1,2,3,4,5
						ORDER BY 6 DESC
				) a 
	)
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC 
) a 
left join (
	### 手机号重复会员ID
	select a.手机,count(1)
	from(
	select
			a.MEMBER_ID,
			b.real_name 姓名,
			b.member_phone 手机,
			b.member_v_num V值余额,
			b.is_vehicle,
			sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL) 未使用V值,
			case when sum(a.ADD_V_NUM - a.CONSUMPTION_INTEGRAL)<1500 then '2'
			else '1' end 区间
	from `member`.tt_member_score_record a
	join `member`.tc_member_info b on a.MEMBER_ID = b.id
	where a.IS_DELETED=0
			and a.CREATE_TIME<='2020-09-30 23:59:59'
			and a.CREATE_TIME>='2020-08-01'
			and a.ADD_V_NUM > a.CONSUMPTION_INTEGRAL
			AND b.is_deleted = 0
			AND b.member_status = 60341001
	GROUP BY 1,2,3,4,5
	ORDER BY 6 DESC
	) a 
	group by 1 
	having count(1)>1 
) b on a.手机=b.手机
order by 8 desc,3
) c 
where c.重复 is null 
and LENGTH(c.手机)=11 and `LEFT`(c.手机,1)='1'
and c.区间=1

-- 注册时间大于365天小于730天，且365天内未回沃世界的人群5-5-1
select 手机号
from 
(select
m.id 会员ID,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号
from member.tc_member_info m 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(m.USER_ID as varchar)
where m.CREATE_TIME >DATE_SUB('2022-5-17 23:59:59',INTERVAL 730 DAY)
and m.CREATE_TIME<DATE_SUB('2022-5-17 23:59:59',INTERVAL 365 DAY)
and (a.max_date < DATE_SUB('2022-5-17 23:59:59',INTERVAL 365 DAY) or a.max_date is null)  -- (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > m.MEMBER_TIME or a.max_date is null)
and m.IS_DELETED =0
and m.MEMBER_STATUS <> 60341003
order by a.max_date desc)
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号

-- 当前有效V值大于等于1,500 V的人群5-5-2
select
tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi 
where tmi.MEMBER_V_NUM >= '1500'
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号

-- 近730天商城有正向订单的会员 5-6-1
select 
DISTINCT x.手机号
from (
select a.order_code 订单编号
,a.create_time 
,h.MEMBER_PHONE 手机号
,h.id
,a.user_id 会员id
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join `member`.tc_member_vehicle tmv on h.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
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
where a.create_time >= DATE_SUB('2022-5-17 23:59:59',INTERVAL 730 day)   -- 近730天的订单时间
and a.create_time <='2022-5-17 23:59:59'
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) x
where LENGTH(x.手机号) = 11 and left(x.手机号,1) = '1' -- 排除无效手机号 

-- 近365天新注册会员 5-6-2
select 
DISTINCT 手机号
from 
(select
m.id 会员ID,
m.create_time 注册时间,
m.MEMBER_PHONE 手机号
from member.tc_member_info m 
where m.CREATE_TIME >=DATE_SUB('2022-5-17 23:59:59',INTERVAL 365 DAY)
and m.CREATE_TIME<='2022-5-17 23:59:59'
and m.IS_DELETED =0
and m.MEMBER_STATUS <> 60341003
order by m.create_time desc)
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号

-- 525商城活动领取优惠券但未使用的用户（Huijie为准） 5-7-1
select 
DISTINCT x.沃世界绑定手机号
from 
(
SELECT 
a.id,
a.one_id,
b.id coupon_id卡券ID,
b.coupon_name 卡券名称,
a.left_value/100 面额,
b.coupon_code 券号,
tmi.ID 沃世界会员ID,
tmi.MEMBER_NAME 会员昵称,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界绑定手机号,
a.vin 购买VIN,
a.get_date 获得时间,
CASE a.coupon_source 
  WHEN 83241001 THEN 'VCDC发券'
  WHEN 83241002 THEN '沃世界领券'
  WHEN 83241003 THEN '商城购买'
END AS 卡券来源,
CASE a.ticket_state
  WHEN 31061001 THEN '已领用'
  WHEN 31061002 THEN '已锁定'
  WHEN 31061003 THEN '已核销' 
  WHEN 31061004 THEN '已失效'
  WHEN 31061005 THEN '已作废'
END AS 卡券状态
FROM coupon.tt_coupon_detail a 
JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID 
WHERE
a.get_date <= '2022-05-28 11:00:00'
and b.id in('3468','3467','3466','2759')
and a.is_deleted=0 
and a.ticket_state=31061001 -- 卡券状态为已领用
order by a.get_date desc
) x

-- 2022.1.1~2022.5.31参与签到的人群（根据最新签到时间取前6W） 5-9-15
select DISTINCT 微信公众号open_id
from 
	(
		select a.手机号,
		a.最新签到时间,
		(eco.open_id)微信公众号open_id
		from 
			(
			select
			si2.member_id 会员id,
			si2.mtime 最新签到时间,
			m.MEMBER_PHONE 手机号,
			IFNULL(c.union_id,u.unionid) allunionid
			from 
				(
				select 
				si.member_id,
				max(si.create_time) mtime
				from mine.sign_info si
				where si.is_delete =0
				group by 1
				) si2
			left join `member`.tc_member_info m on si2.member_id =m.ID
			left join customer.tm_customer_info c on c.id=m.cust_id
			left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid 
			) a
		left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
		and eco.subscribe_status = 1 -- 状态为关注
		and eco.open_id is not null 
		and eco.open_id <> ''
		where LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
		and a.最新签到时间 >= '2022-1-1'
		and a.最新签到时间 <='2022-5-31 23:59:59'
		order by 2 desc 
	)
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 100000

-- 商城购买过用户（剔除退单用户），根据订单创建时间在2022年倒叙排列取前10W用户（10W为除重后的人数），去除525已发短信用户 5-9-16
select 
distinct m.手机号
from (
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,h.MEMBER_PHONE 手机号
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
where a.create_time >= '2022-01-01' and a.create_time <='2022-05-26 23:59:59'       -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time desc)m
where LENGTH(m.手机号) = 11 and left(m.手机号,1) = '1' -- 排除无效手机号
limit 150000

-- 30天以上90天内未登录的车主&粉丝 5-9-17
select
DISTINCT tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB('2022-5-26 23:59:59',INTERVAL 30 DAY) or a.max_date is null) -- (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > DATE_SUB('2022-5-26 23:59:59',INTERVAL 90 DAY) or a.max_date is null) -- (a.max_date > DATE_SUB(CURDATE(),INTERVAL 180 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003   -- 剔除黑名单
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号

-- 参与过沃世界大活动的用户（沃窝森林、宝华韦健、英超、西甲、欧洲杯、温网、四季服、十二服、推荐购、万圣节、双旦、嘟嘟贺岁、C40预售、春服、525车主节），注意整体合并后除重，去除525已发短信用户 5-9-18

-- 最新绑定的新车主（根据绑定时间倒叙排列，取前10W车主），去除525已发短信用户 5-9-19
select  distinct m.手机号
from
(select
top 200000 m.MEMBER_PHONE 手机号,
m.id 会员ID,
d.first_invoice_date 开票时间
from vehicle.tt_invoice_statistics_dms d
join member.tc_member_vehicle v on d.vin = v.VIN and v.IS_DELETED = 0
left join member.tc_member_info m on v.member_id=m.id
where d.IS_DELETED = 0
and d.first_invoice_date<='2022-5-26 23:59:59'
and LENGTH(m.member_phone) = 11 and left(m.member_phone,1) = '1' -- 排除无效手机号
order by d.first_invoice_date desc )m
 
-- 2022年参与预约试驾人群(沃世界提交，并到店，根据完成预约试驾的时间降序排，2022年取前10W)，去除525已发短信用户 5-9-20
select DISTINCT 手机号
from 
(select b.手机号
from
(select 
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "手机号",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       ta.CREATED_AT "预约时间"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >='2022-1-1'
and ta.CREATED_AT <='2022-5-26 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
order by b.预约时间 desc )
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 150000

-- 525车主节参加活动人
select 
distinct tmi.MEMBER_PHONE
from track.track t 
join `member`.tc_member_info tmi on t.usertag = cast(tmi.USER_ID as varchar) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-23'
and t.`date` <= '2022-05-26 23:59:59'
and (json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_预热_click' or json_extract(t.`data`,'$.embeddedpoint') = 'collectionPage_home_正式_click')



-- 5-9-2  21年车展活动收集到的所有线索（分为4个sheet，每个sheet为一个季度收集到的线索。注意除重，重复的保存在任意一个sheet即可） 
select 
 case when x.线索创建时间 between '2021-01-01' and '2021-3-31 23:59:59' then '第一季度'
 when x.线索创建时间 between '2021-04-01' and '2021-6-30 23:59:59' then '第二季度'
 when x.线索创建时间 between '2021-07-01' and '2021-9-30 23:59:59' then '第三季度'
 when x.线索创建时间 between '2021-10-01' and '2021-12-31 23:59:59' then '第四季度'
 end '季度',
 x.客户电话,
 x.线索创建时间
from (
 select 
     a.mobile 客户电话,
     min(a.create_time) 线索创建时间
 from customer.tt_clue_clean a 
 left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
 left join activity.cms_active c on a.campaign_id = c.uid
 left join customer_business.tm_clue_source d on d.ID = c.active_channel
 where a.create_time between '2021-01-01' and '2021-12-31 23:59:59' 
 and (d.CLUE_NAME = ('总部车展') or c.active_name like ('%基盘挖掘%'))
 and a.mobile > 13000000000
 and a.mobile < 19999999999
 and LENGTH(a.mobile) = 11
 group by 1
 order by 2
) x 
order by 3


-- 5-9-3 商城购买过用户（剔除退单用户），根据订单创建时间在2022年倒叙排列取前10W用户（10W为除重后的人数） 
select 
distinct m.手机号
from (
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,h.MEMBER_PHONE 手机号
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
where a.create_time >= '2022-01-01' and a.create_time <='2022-05-17 23:59:59'       -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time desc)m
where LENGTH(m.手机号) = 11 and left(m.手机号,1) = '1' -- 排除无效手机号


-- 5-9-4 2022年参加过签到的人群（截止当前所有的签到人群，注意除重） 
select
distinct tmi.MEMBER_PHONE 手机号
from mine.sign_info si
join `member`.tc_member_info tmi on si.member_id = tmi.ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where si.create_time >= '2022-01-01'and si.create_time <='2022-05-17 23:59:59'
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号
and si.is_delete = 0


-- 5-9-5 90天以上180天内未登录的粉丝 
select
DISTINCT tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB('2022-5-17 23:59:59',INTERVAL 90 DAY) or a.max_date is null) -- (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > DATE_SUB('2022-5-17 23:59:59',INTERVAL 180 DAY) or a.max_date is null) -- (a.max_date > DATE_SUB(CURDATE(),INTERVAL 180 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003   -- 剔除黑名单
and tmi.IS_VEHICLE = 0   -- 筛选粉丝
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号

-- 5-9-6 90天以上180天内未登录的车主
select
DISTINCT tmi.MEMBER_PHONE 手机号
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB('2022-5-17 23:59:59',INTERVAL 90 DAY) or a.max_date is null) -- (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > DATE_SUB('2022-5-17 23:59:59',INTERVAL 180 DAY) or a.max_date is null) -- (a.max_date > DATE_SUB(CURDATE(),INTERVAL 180 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003   -- 剔除黑名单
and tmi.IS_VEHICLE = 1   -- 筛选车主
and LENGTH(tmi.MEMBER_PHONE) = 11 and left(tmi.MEMBER_PHONE,1) = '1' -- 排除无效手机号


-- 5-9-7 最新绑定的新车主（根据绑定时间倒叙排列，取前10W车主）
select  distinct m.手机号
from
(select
top 300000 m.MEMBER_PHONE 手机号,
m.id 会员ID,
d.first_invoice_date 开票时间
from vehicle.tt_invoice_statistics_dms d
join member.tc_member_vehicle v on d.vin = v.VIN and v.IS_DELETED = 0
left join member.tc_member_info m on v.member_id=m.id
where d.IS_DELETED = 0
and d.first_invoice_date<=curdate()
and LENGTH(m.member_phone) = 11 and left(m.member_phone,1) = '1' -- 排除无效手机号
order by d.first_invoice_date desc )m

-- 参与预约试驾人群(沃世界提交，并到店，根据完成预约试驾的时间降序排，2022年取前10W) 5-9-8
select DISTINCT 手机号
from 
(select b.手机号
from
(select 
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "手机号",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       ta.CREATED_AT "预约时间"
from cyx_appointment.tt_appointment  ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >='2022-1-1'
and ta.CREATED_AT <='2022-5-17 23:59:59'
and ta.DATA_SOURCE ="C"
and ta.APPOINTMENT_TYPE =70691005)b
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
order by b.预约时间 desc )
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 200000

-- 参与预约养修人群(沃世界提交，状态为进场，根据完成养修预约的时间降序排，2022年取前10W) 5-9-9
select DISTINCT 手机号
from 
(
select DISTINCT a.手机号,
a.预约时间
from 
(
select 
m.ID "会员ID",
m.MEMBER_PHONE "手机号",
ta3.最近预约时间 "预约时间",
tam.MAINTAIN_STATUS "养修状态code",
tc.CODE_CN_DESC "养修状态"
from cyx_appointment.tt_appointment ta
join (select ta2.ONE_ID,
ta2.APPOINTMENT_ID,
max(ta2.CREATED_AT) 最近预约时间
from cyx_appointment.tt_appointment ta2 
group by 1 
) ta3
on ta.APPOINTMENT_ID =ta3.APPOINTMENT_ID 
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE and ta.DATA_SOURCE ="C" and ta.APPOINTMENT_TYPE =70691005
left join dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info m on ta.ONE_ID = m.CUST_ID and m.IS_VEHICLE=1
order by ta3.最近预约时间
) a
where a.预约时间 >= '2022-1-1'
and a.预约时间<='2022-5-17 23:59:59'
and LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
and a.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
order by a.预约时间 desc)
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 100000

-- 2021.5.20~2022.5.20期间绑车，但在2022.4.20~2022.5.20之间未活跃（根据最后活跃时间倒叙取前6W） 5-9-13
select
DISTINCT 微信公众号open_id
from 
	(select 
	a.手机号,
	a.最近活跃时间,
	(eco.open_id)微信公众号open_id
	from 
		(
		select 
		m.id 会员ID,
		a.max_date 最近活跃时间,
		m.MEMBER_PHONE 手机号,
		IFNULL(c.union_id,u.unionid) allunionid
		from 
			(
			select t.usertag,max(t.`date`) max_date
			from track.track t
			group by 1
		) a 
		left join member.tc_member_info m on a.usertag = cast(m.USER_ID as varchar) and m.is_vehicle=1
		left join 
			(
			select tmv.MEMBER_ID,
			max(tmv.create_time) mtime
			from `member`.tc_member_vehicle tmv 
			where tmv.IS_DELETED = 0
			group by 1
		) b on m.ID = b.MEMBER_ID 
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
		where (a.max_date < '2022-4-20' or a.max_date is null) -- (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
		and (a.max_date > m.MEMBER_TIME or a.max_date is null)
		and b.mtime>='2021-5-20'and b.mtime<='2022-5-20 23:59:59' -- 绑车时间
	) a
	left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
	and eco.subscribe_status = 1 -- 状态为关注
	and eco.open_id is not null 
	and eco.open_id <> ''
	order by a.最近活跃时间 desc )
where LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
limit 60001


-- 参与预约养修人群(沃世界提交，状态为进场，根据完成养修预约的时间降序排，取前6W) 5-9-14
select 
DISTINCT 微信公众号open_id
from 
(
select DISTINCT a.手机号,
a.预约时间,
(eco.open_id)微信公众号open_id
from 
(
select 
m.ID "会员ID",
m.MEMBER_PHONE "手机号",
ta3.最近预约时间 "预约时间",
tam.MAINTAIN_STATUS "养修状态code",
tc.CODE_CN_DESC "养修状态",
IFNULL(c.union_id,u.unionid) allunionid
from cyx_appointment.tt_appointment ta
join (select ta2.ONE_ID,
ta2.APPOINTMENT_ID,
max(ta2.CREATED_AT) 最近预约时间
from cyx_appointment.tt_appointment ta2 
group by 1 
) ta3
on ta.APPOINTMENT_ID =ta3.APPOINTMENT_ID 
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE and ta.DATA_SOURCE ="C" and ta.APPOINTMENT_TYPE =70691005
left join dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info m on ta.ONE_ID = m.CUST_ID and m.IS_VEHICLE=1
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
order by ta3.最近预约时间
) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
where LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
and a.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')
order by a.预约时间 desc)
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 60001

-- 2022.1.1~2022.5.31参与签到的人群（根据最新签到时间取前6W） 5-9-15
select DISTINCT 手机号,
微信公众号open_id
from 
(
select a.手机号,
a.最新签到时间,
(eco.open_id)微信公众号open_id
from 
(
select
si2.member_id 会员id,
si2.mtime 最新签到时间,
m.MEMBER_PHONE 手机号,
IFNULL(c.union_id,u.unionid) allunionid
from (
select 
si.member_id,
max(si.create_time) mtime
from mine.sign_info si
where si.is_delete =0
group by 1
) si2
left join `member`.tc_member_info m on si2.member_id =m.ID
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid 
) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
where LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
and a.最新签到时间 >= '2022-1-1'
and a.最新签到时间 <='2022-5-31 23:59:59'
order by 2 desc )
where LENGTH(手机号) = 11 and left(手机号,1) = '1' -- 排除无效手机号
limit 150000

-- 近180天商城有正向订单的用户的人群； 5-2-3
select 
DISTINCT x.手机号,
(eco.open_id)微信公众号open_id,
x.create_time 
from (
select a.order_code 订单编号
,a.create_time 
,h.MEMBER_PHONE 手机号
,h.id
,h.CUST_ID 
,h.OLD_MEMBERID 
,IFNULL(c.union_id,u.unionid) allunionid
,a.user_id 会员id
from order.tt_order a  -- 订单主表
left join order.tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
left join `member`.tc_member_vehicle tmv on h.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=h.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=h.old_memberid
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
where a.create_time >DATE_SUB(CURDATE(),INTERVAL 180 day)   -- 近180天的订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time) x
left join volvo_wechat_live.es_car_owners eco on x.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
where LENGTH(x.手机号) = 11 and left(x.手机号,1) = '1' -- 排除无效手机号
order by 3 

-- 4月在沃世界活跃过，但在5月1日~5月21日未活跃的人群； 5-2-4
select 
a.会员ID,
a.user_id,
a.手机号,
(eco.open_id)微信公众号open_id,
a.最近活跃时间
from
(
select 
DISTINCT m.id 会员ID,
m.USER_ID ,
m.create_time 注册时间,
a.max_date 最近活跃时间,
m.MEMBER_PHONE 手机号,
IFNULL(c.union_id,u.unionid) allunionid
from member.tc_member_info m
left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
left join customer.tm_customer_info c on c.id=m.cust_id
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
left join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(m.USER_ID as varchar)
where m.is_deleted = 0 and m.member_status <> '60341003'
and (a.max_date > '2022-4-1 00:00:00' or a.max_date is null) -- 最近活跃时间在4月，没有在5月
and (a.max_date<'2022-5-1 00:00:00'or a.max_date is null)
and (a.max_date > m.MEMBER_TIME or a.max_date is null)
) a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
where LENGTH(a.手机号) = 11 and left(a.手机号,1) = '1' -- 排除无效手机号
order by 5 DESC

select * from track.track t  where t.usertag ='6218640' order by t.date desc 

-- 21年车展活动收集到的所有线索（分为4个sheet，每个sheet为一个季度收集到的线索。注意除重，重复的保存在任意一个sheet即可） 5-9-2
select 
 case when x.线索创建时间 between '2021-01-01' and '2021-3-31 23:59:59' then '第一季度'
 when x.线索创建时间 between '2021-04-01' and '2021-6-30 23:59:59' then '第二季度'
 when x.线索创建时间 between '2021-07-01' and '2021-9-30 23:59:59' then '第三季度'
 when x.线索创建时间 between '2021-10-01' and '2021-12-31 23:59:59' then '第四季度'
 end '季度',
 x.客户电话,
 x.线索创建时间
from (
	select 
	    a.mobile 客户电话,
	    min(a.create_time) 线索创建时间
	from customer.tt_clue_clean a 
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	left join activity.cms_active c on a.campaign_id = c.uid
	left join customer_business.tm_clue_source d on d.ID = c.active_channel
	where a.create_time between '2021-01-01' and '2021-12-31 23:59:59' 
	and (d.CLUE_NAME = ('总部车展') or c.active_name like ('%基盘挖掘%'))
	and a.mobile > 13000000000
	and a.mobile < 19999999999
	and LENGTH(a.mobile) = 11 and left(a.mobile,1) = '1'
	group by 1
	order by 2
) x 
order by 3


-- 商城购买过用户（剔除退单用户），根据订单创建时间在2022年倒叙排列取前10W用户（10W为除重后的人数） 5-9-3
select 
DISTINCT x.手机号
from (
select a.order_code 订单编号
,h.MEMBER_PHONE 手机号
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
where a.create_time >'2022-1-1'   -- 订单时间
and a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
order by a.create_time)x
where LENGTH(x.手机号) = 11 and left(x.手机号,1) = '1' -- 排除无效手机号
limit 100000

-- 2022年参加过签到的人群（截止当前所有的签到人群，注意除重） 5-9-4
select
DISTINCT tmi.MEMBER_PHONE
from mine.sign_info si
left join `member`.tc_member_info tmi on si.member_id =tmi.id
where si.create_time >= '2022-1-1 00:00:00'
and LENGTH(tmi.member_phone) = 11 and left(tmi.member_phone,1) = '1' -- 排除无效手机号
and si.is_delete = 0


-- 90天以上180天内未登录的粉丝 5-9-5
select
DISTINCT tmi.MEMBER_PHONE,
a.max_date
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > DATE_SUB(CURDATE(),INTERVAL 180 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_VEHICLE = 0
and LENGTH(tmi.member_phone) = 11 and left(tmi.member_phone,1) = '1' -- 排除无效手机号
order by 2 desc

-- 90天以上180天内未登录的车主 5-9-6
select
DISTINCT tmi.MEMBER_PHONE,
a.max_date
from `member`.tc_member_info tmi 
join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB(CURDATE(),INTERVAL 90 DAY) or a.max_date is null)
and (a.max_date > DATE_SUB(CURDATE(),INTERVAL 180 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
and tmi.IS_VEHICLE = 1
and LENGTH(tmi.member_phone) = 11 and left(tmi.member_phone,1) = '1' -- 排除无效手机号
order by 2 desc

-- 最新绑定的新车主（根据绑定时间倒叙排列，取前10W车主） 5-9-7
select
m.id 会员ID,
m.MEMBER_PHONE 手机号,
d.first_invoice_date 开票时间
from vehicle.tt_invoice_statistics_dms d
join member.tc_member_vehicle v on d.vin = v.VIN and v.IS_DELETED = 0
left join member.tc_member_info m on v.member_id=m.id
where d.IS_DELETED = 0
and LENGTH(m.member_phone) = 11 and left(m.member_phone,1) = '1' -- 排除无效手机号
order by d.first_invoice_date desc 
limit 100000


-- 匹配5-12-1openid的手机号
select 
(eco.open_id) openid,
a.手机号
from 
	(
	select 
	m.ID 会员ID,
	m.MEMBER_PHONE 手机号,
	IFNULL(c.union_id,u.unionid) allunionid
	from `member`.tc_member_info m 
	left join customer.tm_customer_info c on c.id=m.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
	) a
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
group by 1