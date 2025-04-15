-- 埋点测试(这里填写自己的user_id，user_id在会员表中查找)
select * from track.track t where t.usertag = '6039075' order by t.`date` desc

-- 活动PV  
select
-- DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
case 
when t.data like '%30F5FD06F7CC44ABBC987BB78A9F01CD%' then '01 525-小程序首页弹窗'
when t.data like '%246D1BF180454B4091298D290CAAD521%' then '02 525-小程序首页banner '
when t.data like '%1C23CD75838242B4AC9DC7EEE28628B7%' then '03 沃的活动首页banner'
when t.data like '%94D897A098DD48549C1F52CCB73D0AAD%' then '04 商城首页左一banner'
when t.data like '%BEB10A5438BE4A11A37593C70D430F86%' then '05 525-海报太阳码'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_活动规则' then '06 525-活动的主页-活动规则'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_onload' then '07 525-幸运大翻牌模块'
when json_extract(t.`data`,'$.embeddedpoint')= '525商城首页_点击_幸运翻牌' then '08 525-翻牌游戏活动页'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_我的奖品' then '10 525-翻牌游戏活动页-我的奖品'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-完成沃的好物活动页的浏览不低于10s' then '11 525-翻牌游戏活动页-任务-我的好物'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-完成V值抽奖活动页的浏览不低于10s' then '12 525-翻牌游戏活动页-任务-V值抽奖'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-完成1笔满299元的商城订单' then '13 525-翻牌游戏活动页-任务-商城订单'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-浏览车主故事专区点赞一条车主故事' then '14 525-翻牌游戏活动页-任务-车主故事'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-浏览KOC专区招募长图文进行评论' then '15 525-翻牌游戏活动页-任务-KOC专区'
when json_extract(t.`data`,'$.embeddedpoint')= '525翻牌页_点击_任务-浏览路书活动专区点亮想去' then '16 525-翻牌游戏活动页-任务-路书'
else null end '分类',
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-18 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-30 23:59:59'		-- 每天修改截止时间
group by 1
order by 1

-- 秒杀模块商品
select
DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
case 
when json_extract(t.`data`,'$.spuId')='2551'then'无线充电动牙刷刷头 儿童款'
when json_extract(t.`data`,'$.spuId')='2549'then'无线充电动牙刷 儿童款'
when json_extract(t.`data`,'$.spuId')='2504'then'老爷车系列 食品级硅胶 杯垫 4个装'
when json_extract(t.`data`,'$.spuId')='2451'then'商务精钻 多功能护照夹 车缝工艺'
when json_extract(t.`data`,'$.spuId')='2454'then'商务定制三角笔 环保铝身 礼盒装'
when json_extract(t.`data`,'$.spuId')='2777'then'杜邦纸 防水轻便 单肩包'
when json_extract(t.`data`,'$.spuId')='2488'then'舒享生活 记忆棉午睡枕'
when json_extract(t.`data`,'$.spuId')='2767'then'有氧生活 EVA 瑜伽砖'
when json_extract(t.`data`,'$.spuId')='2789'then'儿童12色服饰彩绘笔'
when json_extract(t.`data`,'$.spuId')='2720'then'哑光陶瓷 牛排西餐盘 9.3寸'
when json_extract(t.`data`,'$.spuId')='2718'then'哑光陶瓷 沙拉盘 8.5寸'
when json_extract(t.`data`,'$.spuId')='2579'then'老爷车系列 杯垫 食品级硅胶'
when json_extract(t.`data`,'$.spuId')='2510'then'亲子纯棉舒适亲肤连帽卫衣 儿童款'
when json_extract(t.`data`,'$.spuId')='2467'then'男士真丝 商务简约口袋巾'
when json_extract(t.`data`,'$.spuId')='2466'then'男士真丝 领带口袋巾套装礼盒'
when json_extract(t.`data`,'$.spuId')='2445'then'商务生活礼盒（保温杯、驾驶证包）'
when json_extract(t.`data`,'$.spuId')='2700'then'运动休闲防泼水 软壳外套  女款'
when json_extract(t.`data`,'$.spuId')='2696'then'杜邦抗菌环保印花T恤儿童款 蓝色'
when json_extract(t.`data`,'$.spuId')='2773'then'麋鹿毛绒玩具服装 毛衣'
when json_extract(t.`data`,'$.spuId')='2772'then'麋鹿毛绒玩具服装 卫衣'
when json_extract(t.`data`,'$.spuId')='2625'then'食品级硅胶 手绘餐垫'
when json_extract(t.`data`,'$.spuId')='2667'then'男士100%色织 真丝领带'
else null end '分类',
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-18 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-30 23:59:59'		-- 每天修改截止时间
group by 1,2
order by 1,2

-- 秒杀模块商品
select
-- DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-18 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-30 23:59:59'		-- 每天修改截止时间
AND json_extract(t.`data`,'$.spuId') in 
(
'2551',
'2549',
'2504',
'2451',
'2454',
'2777',
'2488',
'2767',
'2789',
'2720',
'2718',
'2579',
'2510',
'2467',
'2466',
'2445',
'2700',
'2696',
'2773',
'2772',
'2625',
'2667'
)
-- group by 1
order by 1

-- 爆款模块商品
select
-- DATE_FORMAT(t.`date`,'%Y-%m-%d')日期,
COUNT(t.usertag) PV,
COUNT(distinct t.usertag) UV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-05-18 00:00:00'   -- 每天修改起始时间
and t.`date` <= '2022-05-30 23:59:59'		-- 每天修改截止时间
AND json_extract(t.`data`,'$.spuId') in 
(
'2765',
'2766',
'2768',
'2719',
'2717',
'2564',
'2560',
'2545',
'2489',
'2484',
'2616',
'2618',
'2611',
'2508',
'2519',
'2525',
'2763',
'2580',
'2586',
'2597',
'2595',
'2526',
'2613',
'2587',
'2604',
'2511',
'2615',
'2761',
'2456',
'2450',
'2496',
'2469',
'2495',
'2497',
'2698',
'2442',
'2442',
'2492',
'2531',
'2512',
'2530',
'2534',
'2524',
'2533',
'2471',
'2486',
'2567',
'2550',
'2552',
'2673',
'2674',
'2557',
'2553',
'2566',
'2472',
'2771',
'2440',
'2527',
'2602',
'2603',
'2461',
'2609',
'2626',
'2523',
'2774',
'2638',
'2776',
'2642',
'2701',
'2644',
'2778',
'2470',
'2619',
'2762',
'2591',
'2628',
'2629',
'2503',
'2475',
'2477',
'2479',
'2659',
'2446',
'2449',
'2516',
'2444',
'2780',
'2764',
'2529',
'2535',
'2462',
'2500',
'2735',
'2538',
'2666',
'2598',
'2592',
'2581',
'2547',
'2655',
'2651',
'2594',
'2521',
'2548'
)
-- group by 1
order by 1

-- 翻牌记录
select 
b.日期,
b.翻牌几次,
count(b.会员ID)
from 
(select
DATE_FORMAT(a.create_date,'%Y-%m-%d')日期,
a.member_id 会员ID,
COUNT(a.id)翻牌几次
from volvo_online_activity.shop_flop_record a
where a.create_date >= '2022-05-27'
and a.create_date <= '2022-05-30 23:59:59'
and a.is_delete = 0
group by 1,2
order by 1)b
group by 1,2
order by 1,2

-- 奖品统计
select
DATE_FORMAT(a.create_date,'%Y-%m-%d')日期,
count(a.id)-count(a.prize_code) 未中奖,
count(case when a.prize_code='3V值' then a.id end) 3V,
count(case when a.prize_code='6V值' then a.id end) 6V,
count(case when a.prize_code='9V值' then a.id end) 9V,
count(case when a.prize_code='60V值' then a.id end) 60V,
count(case when a.prize_code='90V值' then a.id end) 90V,
count(case when a.prize_code='满100减5' then a.id end) 满100减5,
count(case when a.prize_code='满300减20' then a.id end) 满300减20,
count(case when a.prize_code='满1000减100' then a.id end) 满1000减100,
count(case when a.prize_code='花点时间券' then a.id end) 花点时间券,
count(case when a.prize_code='金属商务深色宝珠笔' then a.id end) 金属商务深色宝珠笔,
count(case when a.prize_code='麋鹿毛绒玩偶-暖暖白色' then a.id end) '麋鹿毛绒玩偶-暖暖白色'
from volvo_online_activity.shop_flop_record a
where a.create_date >= '2022-05-27'
and a.create_date <= '2022-05-30 23:59:59'
and a.is_delete = 0
group by 1
order by 1

-- 中奖明细
select
DATE_FORMAT(a.create_date,'%Y-%m-%d')日期,
a.prize_code 奖品名称,
COUNT(a.member_id)中奖人数
from volvo_online_activity.shop_flop_record a
where a.create_date >= '2022-05-27'
and a.create_date <= '2022-05-30 23:59:59'
and a.is_delete = 0
group by 1,2
order by 1,2



-- 奖品发放明细
select
a.member_id,
b.MEMBER_PHONE 沃世界注册手机号,
a.prize_code 奖品名称,
a.create_date 中奖时间,
c.收货人姓名,
c.收货人手机号,
c.收货地址
from volvo_online_activity.shop_flop_record a
left join `member`.tc_member_info b on a.member_id = b.ID 
left join
(select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
(
select 
tma.MEMBER_ID,
tma.CONSIGNEE_NAME 收货人姓名,
tma.CONSIGNEE_PHONE 收货人手机号,
CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""),ifnull(tr3.REGION_NAME,""),ifnull(tma.MEMBER_ADDRESS,""))收货地址,
row_number() over(partition by tma.member_address order by tma.create_time desc) rk
from `member`.tc_member_address tma
left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
where tma.IS_DELETED = 0
and tma.IS_DEFAULT = 1   -- 默认收货地址
)c where c.rk = 1)c on a.member_id = c.member_id 
where a.create_date >= '2022-05-18'
and a.create_date <= '2022-05-30 23:59:59'
and a.is_delete = 0
and a.prize_code in ('金属商务深色宝珠笔','麋鹿毛绒玩偶-暖暖白色')
order by a.create_date



-- 卡券领用核销明细
SELECT 
a.id,
a.one_id,
b.id coupon_id,
b.coupon_name 卡券名称,
a.left_value/100 面额,
b.coupon_code 券号,
tmi.ID 沃世界会员ID,
tmi.MEMBER_NAME 会员昵称,
tmi.REAL_NAME 姓名,
tmi.MEMBER_PHONE 沃世界绑定手机号,
a.vin 购买VIN,
a.get_date 获得时间,
a.activate_date 激活时间,
a.expiration_date 卡券失效日期,
CAST(a.exchange_code as varchar) 核销码,
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
END AS 卡券状态,
v.*
FROM coupon.tt_coupon_detail a 
JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID 
LEFT JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
,v.customer_mobile 核销手机号
,v.verify_amount 
,v.dealer_code 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
,v.order_no 订单号
,v.PLATE_NUMBER
from coupon.tt_coupon_verify v 
where  v.is_deleted=0
order by v.create_time 
) v ON v.coupon_detail_id = a.id
WHERE a.coupon_id in ('3517','3466','3467','3468')
-- and a.get_date >= '2022-03-23'
-- and a.get_date < '2022-04-12'
and a.is_deleted=0 
order by a.get_date desc 




-- 商城数据
select a.order_code 订单编号
,b.product_id 商城兑换id
,a.user_id 会员id
,a.user_name 会员姓名
,b.spu_name 兑换商品
,b.spu_id
,b.sku_id
,b.spu_bus_id
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
where a.is_deleted <> 1  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
and e.order_code is null  -- 剔除退款订单
and a.order_code in 
('182844893956',
'265818770340',
'671329567934',
'763264288821',
'947987919704',
'470972177340',
'305777457070',
'688548367670',
'853206935963',
'242166622129',
'980597228901',
'944100124737',
'746216678280',
'836131754173',
'693750470686',
'388626681405',
'482806804671',
'849331908920',
'400959844427',
'692963550211',
'480589785999',
'568557912260',
'228537268065',
'205406824737',
'951979991227',
'309401162825',
'111806793907',
'844829997264',
'878900350087',
'254586569108'
)
order by a.create_time



