DROP view ods_oper_crm.20241128_dianche 

--电车车主
create view ods_oper_crm.20241128_dianche 
as 
 select
 distinct 
 r.member_id member_id,
 m.cust_id cust_id,
 m.member_phone member_phone,
 r.vin_code vin_code,
 d.create_time `购车下单时间`,
 tm.model_name `车型（BEV OR T8）`,
 m.level_id `会员等级`
 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) and m.is_deleted = 0 and m.member_status<>'60341003'
 left join ods_vehi.ods_vehi_tt_invoice_statistics_dms_cur d on r.vin_code = d.vin and d.is_deleted = 0
 left join ods_vehi.ods_vehi_tm_vehicle_d tv on r.vin_code = tv.VIN and tv.IS_DELETED = 0
 left join ods_bada.ods_bada_tm_model_cur tm on ifnull(d.model_id,tv.MODEL_ID) = tm.id and tm.is_deleted = 0
 left join ods_bada.ods_bada_tm_config_d tc2 on ifnull(d.config_code,tv.CONFIG_CODE) =tc2.CONFIG_CODE and ifnull(d.config_id,tv.CONFIG_ID) =tc2.ID
 where r.deleted = 0
 and r.is_bind = 1   -- 绑车
 and r.is_owner=1  -- 车主
 and (tm.model_name in (  -- BEV OR T8
 'C40 RECHARGE',
 'XC40 RECHARGE',
 'XC60 RECHARGE',
 'XC90 RECHARGE',
 'S60 RECHARGE',
 'S90 RECHARGE',
 'EM90','EX30','EX90')
 or tc2.CONFIG_NAME like '%T8%')

with x1 as 
	(
	-- 进入app次数
	SELECT
	distinct_id,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '1 month' then 1 else null end) `近1个月内进入app次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '3 month' then 1 else null end) `近3个月内进入app次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '6 month' then 1 else null end) `近6个月内进入app次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '12 month' then 1 else null end) `近12个月内进入app次数`
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(event_time) >=toDate(today()) - interval '12 month' 
	and toDate(event_time) < toDate(today())
	and toDate(date) >= toDate(today()) - interval '12 month'
	and toDate(date) < toDate(today())
	and event= '$AppStart'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or  channel='App')
	group by 1 
	order by 2 desc 
),
x2 as 
	(
	--进入充电地图页面的次数
	SELECT
	distinct_id,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '1 month' then 1 else null end) `近1个月内进入充电地图页面次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '3 month' then 1 else null end) `近3个月内进入充电地图页面次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '6 month' then 1 else null end) `近6个月内进入充电地图页面次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '12 month' then 1 else null end) `近12个月内进入充电地图页面次数`
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(event_time) >=toDate(today()) - interval '12 month' 
	and toDate(event_time) < toDate(today())
	and toDate(date) >= toDate(today()) - interval '12 month'
	and toDate(date) < toDate(today())
	and event='Page_entry'
	and page_title ='充电地图'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or  channel='App')
	group by 1 
	order by 2 desc 
),
x3 as 
	(--是否充过电 只要有充电订单就行
	select distinct member_id
	from ods_chrg.ods_chrg_tt_charge_order_d 
	where is_deleted =0
),
x4 as 
	(
	--充电地图扫码按钮次数
	SELECT
	distinct_id,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '1 month' then 1 else null end) `近1个月充电地图扫码按钮次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '3 month' then 1 else null end) `近3个月充电地图扫码按钮次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '6 month' then 1 else null end) `近6个月充电地图扫码按钮次数`,
	count(case when toDate(date) < toDate(today()) and toDate(date) >= toDate(today()) - interval '12 month' then 1 else null end) `近12个月充电地图扫码按钮次数`
	from dwd_23.dwd_23_gio_tracking
	where 1=1
	and toDate(event_time) >=toDate(today()) - interval '12 month'
	and toDate(event_time) < toDate(today())
	and toDate(date) >= toDate(today()) - interval '12 month'
	and toDate(date) < toDate(today())
	and event='Button_click'
	and btn_name ='扫码充电'
	and ((`$lib` in('iOS','Android','HarmonyOS') and left(`$client_version`,1)='5') or  channel='App')
	group by 1 
	order by 2 desc
),
x5 as 
	(
	--充电成功失败次数
	select o.member_id member_id,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '1 month' and main_status='71011005' then 1 else null end) `近1个月内充电成功次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '3 month' and main_status='71011005' then 1 else null end) `近3个月内充电成功次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '6 month' and main_status='71011005' then 1 else null end) `近6个月内充电成功次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '12 month' and main_status='71011005' then 1 else null end) `近12个月内充电成功次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '1 month' and main_status<>'71011005' then 1 else null end) `近1个月内充电失败次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '3 month' and main_status<>'71011005' then 1 else null end) `近3个月内充电失败次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '6 month' and main_status<>'71011005' then 1 else null end) `近6个月内充电失败次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '12 month' and main_status<>'71011005' then 1 else null end) `近12个月内充电失败次数`
	from ods_chrg.ods_chrg_tt_charge_order_d o
	where o.is_deleted =0
	and o.create_time >=toDate(today()) - interval '12 month' 
	and o.create_time < toDate(today())
	group by 1 
	order by 2 desc
),
x6 as 
	(
	--充电评价次数
	select 
	user_id member_id,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '1 month' then 1 else null end) `近1个月充电评价次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '3 month' then 1 else null end) `近3个月充电评价次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '6 month' then 1 else null end) `近6个月充电评价次数`,
	count(case when toDate(create_time) < toDate(today()) and toDate(create_time) >= toDate(today()) - interval '12 month' then 1 else null end) `近12个月充电评价次数`
	from ods_cmmt.ods_cmmt_tm_comment_d a  -- 打星评价业务表
	where 1=1
	and object_type ='31151030' -- 充电地图
	and is_deleted ='0'
	and create_time >=toDate(today()) - interval '12 month' 
	and create_time < toDate(today())
	group by 1 
	order by 1 
),
x7 as 
(
-- 线上GMV  充电GMV
select 
m.`下单人会员ID` member_id,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '1 month'then m.`不含税的总金额`else null end) `近1个月线上GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '3 month'then m.`不含税的总金额`else null end) `近3个月线上GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '6 month'then m.`不含税的总金额`else null end) `近6个月线上GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '12 month'then m.`不含税的总金额`else null end) `近12个月线上GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '1 month'and m.fl='充电专区'then m.`不含税的总金额`else null end) `近1个月充电GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '3 month'and m.fl='充电专区'then m.`不含税的总金额`else null end) `近3个月充电GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '6 month'and m.fl='充电专区'then m.`不含税的总金额`else null end) `近6个月充电GMV`,
SUM(case when m.create_time< toDate(today())and m.create_time>= toDate(today()) - interval '12 month'and m.fl='充电专区'then m.`不含税的总金额`else null end) `近12个月充电GMV`
from 
	(-- 1、商城订单明细(CK)
select
a.order_code `订单号`,
b.spu_name `兑换商品`,
a.user_id `下单人会员ID`,
a.create_time create_time,
ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end,
	case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end) `fl`,
b.fee/100 `总金额(元)`,
round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额`
from ods_orde.ods_orde_tt_order_d a    -- 订单表
left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code and b.is_deleted <> 1   -- 订单商品表
left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id and c.front_category_id is not null    -- 前台spu表(获取商品前台专区ID)
left join ods_good.ods_good_item_sku_d d on b.sku_id = d.id      -- 前台sku表(获取商品DN价)
left join
(
	-- 获取部分商品正确的前台分类代码
	select e.spu_id,e.sku_id,e.front_category1_id
	from ods_good.ods_good_item_sku_channel_d e
	where e.is_deleted = 0
	and e.front_category1_id in ('195','212','219','230')
	and e.client_id = '2b9890ef-d828-11ec-be68-00163e0ebd17'   -- APP订单
) e on e.spu_id = b.spu_id and e.sku_id = b.sku_id
left join ods_good.ods_good_front_category_d f on f.id = e.front_category1_id     -- 前台专区列表(获取前台专区名称)
where 1=1
and a.create_time >= toDate(today()) - interval '12 month'
and a.create_time < toDate(today())   -- 订单时间
and a.is_deleted <> 1
and b.is_deleted <> 1
and a.type = '31011003'  -- 订单类型：沃世界商城订单
and a.separate_status = '10041002' -- 拆单状态：否
and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
and (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
--and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and g.order_code is not null  -- 剔除退款订单
--and `前台分类`='充电专区'
order by a.create_time) m
group by 1 
),
x8 as 
	(
	--近6个月内的充电抽奖次数
	select member_id,
	count(1) `近6个月充电抽奖次数`
	from ods_voam.ods_voam_lottery_draw_log_d 
	where 1=1
	and create_time >=  today()-interval '6 month'
	and create_time < today()
	and lottery_code like '%charge%'
	group by 1 
	order by 2 desc  
),
x9 as 
	(
	--近6个月内的会员日充电次数
	select o.member_id member_id,
	count(1) `近6个月会员日充电次数`
	from ods_chrg.ods_chrg_tt_charge_order_d o
	where o.is_deleted =0
	and o.create_time >=toDate(today()) - interval '6 month' 
	and o.create_time < toDate(today())
	and day(create_time)=25 -- 会员日
	group by 1 
	order by 2 desc
),
x10 as 
	(
	--近6个月内的周末充电次数	
	select 
	o.member_id member_id,
	count(1) `近6个月周末充电次数	`
	from ods_chrg.ods_chrg_tt_charge_order_d o
	where o.is_deleted =0
	and o.create_time >=toDate(today()) - interval '6 month' 
	and o.create_time < toDate(today())
	AND (toDayOfWeek(o.create_time) = 6 OR toDayOfWeek(o.create_time) = 7) -- 筛选周六周日
	group by 1 
	order by 2 desc
),
x11 as 
	(
	--近6个月内任务中心-每周充电完成次数
	select 
	tr.member_id member_id,
	count(1) `近6个月每周充电完成次数`
	from ods_mms.ods_mms_task_record_d tr
	where tr.task_id ='84' --每周充电任务
	and tr.deleted =0
	and toDate(tr.date_create) >=toDate(today()) - interval '6 month' 
	and toDate(tr.date_create) <toDate(today())
	group by 1
	order by 2 desc 
),
x12 as 
	(
	--近6个月内社区发动态次数
	select 
	a.member_id member_id,
	count(1) `近6个月内社区发动态次数`
	from ods_cmnt.ods_cmnt_tm_post_cur a
	where 1=1
	and a.is_deleted =0
	and toDate(a.create_time) >=toDate(today()) - interval '6 month' 
	and toDate(a.create_time) <toDate(today())
	and post_type='1001' --动态'
	group by 1 
	order by 2 desc 
),
x13 as 
	(
	--近6个月内带以下话题任一之一发动态
	--#品牌充电站# M1wVePmzZh、#充电攻略# Gb42f5THec、#最美充电路线# sNQT3JQUfH、#一起来晒“沃”的低碳足迹# MQ4w1XNm9Q
	select 
	a.member_id member_id,
	count(distinct a.id) `近6个月内社区发动态次数`
	from ods_cmnt.ods_cmnt_tm_post_cur a
	left join ods_cmnt.ods_cmnt_tr_topic_post_link_cur b on a.post_id=b.post_id
	where 1=1
	and a.is_deleted =0
	and toDate(a.create_time) >=toDate(today()) - interval '6 month' 
	and toDate(a.create_time) <toDate(today())
	and a.post_type='1001' --动态'
	and b.topic_id in ('M1wVePmzZh','Gb42f5THec','sNQT3JQUfH','MQ4w1XNm9Q')
	group by 1 
	order by 2 desc 
),
x14 as 
	(
	--是否是课代表粉丝
	SELECT a.fans_member_id member_id,
	'是' `是否是课代表粉丝`
	from ods_mine.ods_mine_tt_fans_relationship_d a
	where 1=1
	and is_deleted =0
--	and member_id ='3792864'-- 官号充电课代表id
),
x15 as 
	(
	--近6个月浏览官号充电课代表的文章次数
	select 
	a.member_id member_id,
	count(distinct a.id) `近6个月内社区发动态次数`
	from ods_cmnt.ods_cmnt_tt_view_post_cur  a
	join ods_cmnt.ods_cmnt_tm_post_cur b on a.post_id =b.post_id 
	where 1=1
	and a.is_deleted =0
	and b.is_deleted =0
	and toDate(a.create_time) >=toDate(today()) - interval '6 month' 
	and toDate(a.create_time) <toDate(today())
	and b.member_id='3792864' -- 官号充电课代表id
	group by 1 
	order by 2 desc 
),
x16 as 
	(
	-- 是否置换
	select
	distinct o.mobile mobile
	from
	(
		select
		o.customer_tel mobile,
		o.created_at t
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where o.business_type <> 14031002
		and o.so_status in (14041001,14041002,14041003,14041008) -- 有效订单
		and o.replacement_type in (70891002,70891003) -- 置换  -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		and o.is_deleted = 0
	--	and o.created_at >= '2023-07-17 9:00:00'
	--	and o.created_at <= '2023-07-23 23:59:59'
		and o.customer_tel is not null
		union all   
		select
		o.drawer_tel mobile,
		o.created_at t
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where o.business_type <> 14031002
		and o.so_status in (14041001,14041002,14041003,14041008) -- 有效订单
		and o.replacement_type in (70891002,70891003) -- 置换  -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		and o.is_deleted = 0
	--	and o.created_at >= '2023-07-17 9:00:00'
	--	and o.created_at <= '2023-07-23 23:59:59'
		and o.drawer_tel is not null
		union all
		select
		o.purchase_phone mobile,
		o.created_at t
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where o.business_type <> 14031002
		and o.so_status in (14041001,14041002,14041003,14041008) -- 有效订单
		and o.replacement_type in (70891002,70891003) -- 置换  -- 由于订单状态是动态变化的，所以这个未提交，因为不确定用户是否是继续提交订单，还是取消订单，所以一般我们就认为这条订单就是有效订单
		and o.is_deleted = 0
	--	and o.created_at >= '2023-07-17 9:00:00'
	--	and o.created_at <= '2023-07-23 23:59:59'
		and o.purchase_phone is not null
	) o
	where length(o.mobile) = '11'
	and left(o.mobile,1) = '1' 
	order by o.t	
),
x17 as 
(
--是否推荐购  -- 推荐购订单
	select 
	distinct invite_member_id member_id
	from ods_invi.ods_invi_tm_invite_record_d tir
	where 1=1 
	and tir.is_deleted = 0
	and tir.order_status in ('14041008','14041003') -- 有效订单
	and tir.order_no is not null -- 筛选订单号不为空
	and tir.cancel_large_setorder_time = '1970-01-01 08:00:00' -- 排除取消订单的情况
	and tir.red_invoice_time = '1970-01-01 08:00:00' -- 红冲发票为空
	and tir.invoice_no is not null
	and tir.be_invite_member_id is not null 
--	and tir.create_time >= '2024-01-01'
--	and tir.create_time < '2024-10-01'
),		
x18 as 
	(
--	是否二手车
	select distinct x.mobile
	from 
		(
		select `联系方式` mobile
		from ods_vlvb.ods_vlvb_nbr_form_d --ods_vlvb.ods_vlvb_nbr_form_d 认证二手车（官方授权经销商买卖）
		where categoryid='Select' --认证业务类型
		and isdeleted='false' --是否失效为0
		union all 
		select customermobile
		from ods_vlvb.ods_vlvb_nbr_form_d a
		left join  ods_vlvb.ods_vlvb_nbr_form_2_d b on a.id=b.`表单id`
		where categoryid='UCOfficialStandard' 
		and a.isdeleted='false'
--		and b.PaymentDate >='2024-01-01'
		--ods_vlvb.ods_vlvb_nbr_form_2_d 标准二手车（官方直接买卖）
	)x where length (x.mobile)=11
),
x19 as 
	(
	--"进厂次数 指近1、3、6、12月
	--最近一年工单
	select
	m.id member_id,
	count(distinct case when toDate(RO_CREATE_DATE) < toDate(today()) and toDate(RO_CREATE_DATE) >= toDate(today()) - interval '1 month' then concat(o.RELATION_RO_NO,OWNER_CODE) else null end) `近1个月售后进厂次数`,
	count(distinct case when toDate(RO_CREATE_DATE) < toDate(today()) and toDate(RO_CREATE_DATE) >= toDate(today()) - interval '3 month' then concat(o.RELATION_RO_NO,OWNER_CODE) else null end) `近3个月售后进厂次数`,
	count(distinct case when toDate(RO_CREATE_DATE) < toDate(today()) and toDate(RO_CREATE_DATE) >= toDate(today()) - interval '6 month' then concat(o.RELATION_RO_NO,OWNER_CODE) else null end) `近6个月售后进厂次数`,
	count(distinct case when toDate(RO_CREATE_DATE) < toDate(today()) and toDate(RO_CREATE_DATE) >= toDate(today()) - interval '12 month' then concat(o.RELATION_RO_NO,OWNER_CODE) else null end) `近12个月售后进厂次数`
	-- count(distinct concat(o.RELATION_RO_NO,OWNER_CODE))gd_num -- 母工单+经销商code
	from ods_cyre.ods_cyre_tt_repair_order_d o
	left join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where 1=1
	and o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
	and o.RO_CREATE_DATE < today()
	and m.id is not null 
	group by 1 
	order by 2 desc  
),
x20 as 
(
--最近一年工单
select x.id member_id,
avg(x.num) `单次产值（平均值）`,-- 母工单
sum(x.num) `年度产值（总和）`
from 
	(
	select
	m.id ,
	RELATION_RO_NO,
	sum(o.BALANCE_AMOUNT) num 
	from ods_cyre.ods_cyre_tt_repair_order_d o
	left join ods_memb.ods_memb_tc_member_info_cur m on o.DELIVERER_MOBILE = m.member_phone and m.member_status <> '60341003' and m.is_deleted = '0'
	where 1=1
	and o.IS_DELETED = 0
	and o.REPAIR_TYPE_CODE <> 'P'
	and o.RO_STATUS = '80491003'    -- 已结算工单
	and o.RO_CREATE_DATE >= today() - interval '1 year' -- 近一年
	and o.RO_CREATE_DATE < today()
	and m.id is not null 
	group by 1,2
	order by 3 desc  
)x
group by 1 
order by 2 desc  
)
select *
from ods_oper_crm.20241128_dianche x
left join x1 on x1.distinct_id::String=x.cust_id::String
left join x2 on x2.distinct_id::String=x.cust_id::String
left join x3 on x3.member_id::String=x.member_id::String
left join x4 on x4.distinct_id::String=x.cust_id::String
left join x5 on x5.member_id::String=x.member_id::String
left join x6 on x6.member_id::String=x.member_id::String
left join x7 on x7.member_id::String=x.member_id::String
left join x8 on x8.member_id::String=x.member_id::String
left join x9 on x9.member_id::String=x.member_id::String
left join x10 on x10.member_id::String=x.member_id::String
left join x11 on x11.member_id::String=x.member_id::String
left join x12 on x12.member_id::String=x.member_id::String
left join x13 on x13.member_id::String=x.member_id::String
left join x14 on x14.member_id::String=x.member_id::String
left join x15 on x15.member_id::String=x.member_id::String
left join x16 on x16.mobile::String=x.member_phone::String
left join x17 on x17.member_id::String=x.member_id::String
--left join x18 on x18.distinct_id::String=x.cust_id::String
left join x19 on x19.member_id::String=x.member_id::String
left join x20 on x20.member_id::String=x.member_id::String

select *
from ods_oper_crm.20241128_dianche x
join (	--是否是课代表粉丝
	SELECT distinct a.fans_member_id member_id,
	'是' `是否是课代表粉丝`
	from ods_mine.ods_mine_tt_fans_relationship_d a
	where 1=1
	and is_deleted =0
	and a.fans_member_id is not null 
--	and member_id ='3792864'-- 官号充电课代表id
)x1 on x1.member_id::String=x.member_id::String