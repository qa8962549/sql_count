-- 埋点测试
select * from track.track t where t.usertag = '6039075' 
--and t.date>'2023-07-01' 
order by t.`date` desc

select * from member.tc_member_info tmi where tmi.member_phone = '18721762520'      -- 根据手机号拿到自己的userid，填写到上面。

select * from member.tc_member_info tmi where tmi.id =
'7746779'

-- 查库表
SELECT table_schema, table_name
FROM information_schema.tables
where table_name like'%tt_price%'
order by 1,2

select sum(add_c_num)
from "member".tt_member_score_record a
where a.member_id ='5798431'

select *
from ods_rawd.ods_rawd_events_d_di 
where distinct_id='20714191' 
--and event='page_view'
order by time desc 
limit 100

custid 20714191

select * from community_club.tr_club_friends tcf 

-- 每日新增
select 
date_format(tmi.create_time,'%Y-%m-%d')
,count(tmi.id)
from "member".tc_member_info tmi 
where 1=1
and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
group by 1
order by 1

--explode ：作用：一行数据转换成多列数据，用于array和map类型的数据。炸裂之后会有一对多，所以需要使用侧视图LATERAL VIEW 进行聚合

--event关联member表
select a.distinct_id
,m.member_phone 
from ods_rawd.ods_rawd_events_d_di a
left join ods_memb.ods_memb_tc_member_info_cur m on toString(m.cust_id) =toString(a.distinct_id)


--pgsql时间操作
--获取当前时间
select current_date

select now();

SELECT concat('Today is ', to_char(current_date, 'YYYY-MM-DD'));

--获取当前时间的前1天时间

select now() - interval '1 day'

select curdate() - interval '1 day'

select substr(now(),1,13)||':00:00'

select to_char(now(), 'YYYYMMDD') - 

--时间格式化
select to_timestamp(now(),'yyyy-mm-dd hh24:mi:ss') - interval '1 day'

--字符串转时间
to_timestamp('2022-01-22 00:00:00','yyyy-MM-dd hh24:mi:ss')

--获取年月日时分秒
select extract(year from now()) || extract(month from now()),extract(day from now()),extract(hour from now()),extract(minute from now()),extract(second from now())

--字符串截取
select substr(now(),1,19)

--获取前半个小时数据
select case when extract(minute from now())>=30 then substr(to_timestamp(now(),'yyyy-mm-dd hh24')+ interval '0 MINUTE',1,19) else substr(to_timestamp(now(),'yyyy-mm-dd hh24')- interval '30 MINUTE',1,19) end 
union all
select case when extract(minute from now())>=30 then substr(to_timestamp(now(),'yyyy-mm-dd hh24')+ interval '30 MINUTE',1,19) else substr(to_timestamp(now(),'yyyy-mm-dd hh24'),1,19) end 


-- 字典查含义
select * from dictionary.tc_code a where a.CODE_ID like '%6051100%'
order by 1 

select * from dictionary.tc_code a where a.CODE_ID  = '15061003'

-- 查车型名称
select * from basic_data.tm_model a 
-- where a.MODEL_CODE ='238'

-- 今天是今年的第几天
select DATEDIFF(CURDATE(),'2024-3-01')+1

select DATE_SUB('2023-02-13',INTERVAL '60 day') 

select dayofyear(curdate())

-- postgersql 时间加减
SELECT now()::timestamp + '1 year';  --当前时间加1年
SELECT now()::timestamp + '1 month';  --当前时间加一个月
SELECT now()::timestamp + '1 day';  --当前时间加一天
SELECT now()::timestamp + '1 hour';  --当前时间加一个小时
SELECT now()::timestamp + '1 min';  --当前时间加一分钟
SELECT now()::timestamp + '1 sec';  --加一秒钟
select now()::timestamp + '1 year 1 month 1 day 1 hour 1 min 1 sec';  --加1年1月1天1时1分1秒
SELECT now()::timestamp + (col || ' day')::interval FROM table --把col字段转换成天 然后相加

select CURRENT_TIMESTAMP::TIMESTAMP + '-5 day';
select CURRENT_TIMESTAMP::TIMESTAMP + '-3 month';
select curdate()::TIMESTAMP + '-3 month';

select * from community_club.tt_club_attr_audit_approve a

select date
from track.track t
order by date desc 

--后续绑车相关数据，从这两张表中取数：
-- 绑车流水表
select * from volvo_cms.vehicle_bind_record r
where r.deleted = 0

-- 绑车关系表
select * from volvo_cms.vehicle_bind_relation re
where re.deleted = 0


-- 窗口函数，查上一次发生的时间
select a.member_id,a.time_str ,LAG(a.time_str)over(PARTITION by a.member_id order by a.time_str) nt
from mine.sign_info a

-- 根据分组，组合值
select m.MEMBER_SEX,GROUP_CONCAT(m.REAL_NAME SEPARATOR ';') 
from `member`.tc_member_info m
group by 1

-- 分隔符
select m.id,split(m.MEMBER_EMAIL ,'@') 
from `member`.tc_member_info m
group by 1



	-- 是否授权亲友、授权身份
	select 
	a.distinct_id,a.member_id,a.是否车主,b.绑定关系 as 授权亲友
	from
	(
		select distinct_id,member_id,是否车主 from
		(
			-- 会员表 是否车主
			select
			t.cust_id distinct_id,
			t.id member_id,
			case when t.is_vehicle = 1 then '车主' else '粉丝' end 是否车主,
			row_number() over(partition by t.cust_id order by t.create_time desc) rk
			from "member".tc_member_info t
			where t.member_status <> 60341003 and t.is_deleted = 0
			and t.cust_id is not null
		)
		where rk = 1
	) a
	left join
	(
		-- 绑定关系表-绑定关系
		select * from
		(
			-- 绑定关系表
			select
			a.member_id,case when a.is_bind = 1 then '绑定' else '解绑' end 是否绑定,
			case when a.relative_type=60531001 then '好友'
				when a.relative_type=60531002 then '丈夫'
				when a.relative_type=60531003 then '妻子'
				when a.relative_type=60531004 then '儿子'
				when a.relative_type=60531005 then '女儿'
				when a.relative_type=60531006 then '父亲'
				when a.relative_type=60531007 then '母亲'
				when a.relative_type=60531008 then '亲戚'
				end 绑定关系,
			row_number() over(partition by a.`member_id` order by a.date_create desc) num
			from volvo_cms.vehicle_bind_relation a
			where a.`is_owner` <> '1'   -- 不是车主
		)
		where num = 1
		and 绑定关系 is not null
	) b on a.member_id =b.member_id

-- 用户最新绑车
	with x as(
	 select
	 r.member_id,
	 r.vin_code VIN,
	 m.member_phone ,
	-- tm.model_name,
	-- r1.bind_date,
	-- r1.member_id,
	-- r1.is_bind,
	 row_number() over(partition by r.member_id order by r.bind_date desc) rk
	 from volvo_cms.vehicle_bind_relation r
	 left join "member".tc_member_info m on m.id =r.member_id 
	-- left join volvo_cms.vehicle_bind_relation r1 on r1.vin_code =r.vin_code 
	 left join vehicle.tt_invoice_statistics_dms d on r.vin_code = d.vin and d.is_deleted = 0
	 left join vehicle.tm_vehicle tv on r.vin_code = tv.vin and tv.is_deleted = 0
	 left join basic_data.tm_model tm on ifnull(d.model_id,tv.model_id) = tm.id and tm.is_deleted = 0
	 where r.deleted = 0
	 and r.is_bind = 1   -- 绑车
	 and r.member_id in ('3063707')
)
select x.*
from x
where x.rk=1
 
 
select *
from volvo_cms.vehicle_bind_relation vbr 
where 1=1
--and vbr.vin_code ='YV1FW40C5E1208655'
and vbr.member_id ='7543256'
 
-- 商城订单明细(CK)
select
a.order_code `订单号`,
ifnull(a.parent_order_code,a.order_code) `母单号`,
case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end `订单来源`,
case when a.order_source = '51021001' then '立即下单'
	when a.order_source = '51021002' then '购物车下单'
	when a.order_source = '51021003' then '工单'
	when a.order_source = '51021004' then '秒杀'
	when a.order_source = '51021006' then '组合购订单'
	when a.order_source = '51021007' then '买赠订单'
	else null end `订单来源渠道`,
a.user_id `下单人会员ID`,
a.user_phone `下单人手机号`,
b.sku_code `商品货号`,
b.product_id `product_id`,
e.part_number `PN号`,
b.spu_name `兑换商品`,
b.spu_id `商品SPU_ID`,
b.sku_id `商品SKU_ID`,
b.sku_code `商品编码`,
b.sku_price/100 `商品零售含税价(元)`,
e.cls12/100 `商品DN价(元)`,
b.sku_real_point `商品单价`,
c.front_category_id `front_category_id`,
ifnull(f.`前台分类`,ifnull(case when d.name in('售后养护','充电专区','精品','生活服务') then d.name else null end,
	case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end)) `前台分类`,
case when b.spu_type = '51121001' then '沃尔沃精品'
	when b.spu_type = '51121002' then '第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
	when b.spu_type = '51121006' then '一件代发'
	when b.spu_type = '51121007' then '经销商端产品'
    when b.spu_type = '51121008' then '虚拟服务权益'
    else null end `商品类型`,
case when e.boutique_type = 0 then '售后附件'
	else null end `精品二级分类`,
case when b.spu_type = '51121003' and b.spu_name like '%桩%' then '是' else '否' end `是否保养类卡券_充电桩`,
b.fee/100 `总金额(元)`,
round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
b.sku_total_fee/100 `商品金额(元)`,
b.express_fee/100 `运费金额(元)`,
ifnull(j.id,k.id) `卡券唯一ID`,
ifnull(j.coupon_id,k.coupon_id) `优惠券卡券ID`,
ifnull(j.coupon_name,k.coupon_name) `优惠券名称`,
b.coupon_fee/100 `优惠券抵扣金额(元)`,
round(b.point_amount/3+b.pay_fee/100,2) `实付金额(元)`,
b.pay_fee/100 `现金支付金额(元)`,
b.point_amount `支付V值(个)`,
b.sku_num `兑换数量`,
a.create_time `下单时间`,
formatDateTime(a.create_time,'%Y-%m') `下单年月`,
a.pay_time `支付时间`,
case when b.pay_fee = 0 then '纯V值支付' when b.point_amount = 0 then '纯现金支付' else '混合支付' end `支付方式`,
i.dealer_code `下单经销商Code`,
case when b.spu_type = '51121001' then 'VOLVO仓商品' 
	when b.spu_type = '51121002' then 'VOLVO仓第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '京东仓商品'
	else null end `仓库`,
case when b.status = '51301001' then '待付款'
	when b.status = '51301002' then '待发货' 
	when b.status = '51301003' then '待收货' 
	when b.status = '51301004' then '收货确认'
	when b.status = '51301005' then '退货中'
	when b.status = '51301006' then '交易关闭'  
	else null end `订单商品状态`,
case when a.status = '51031001' then '预创建'
	when a.status = '51031002' then '待付款'
	when a.status = '51031003' then '待发货'
	when a.status = '51031004' then '待收货'
	when a.status = '51031005' then '已完成'
	when a.status = '51031006' then '交易关闭'
	when a.status = '51031007' then '创建失败'
	else null end `订单状态`,
case when a.close_reason = '51091001' then '超时未支付'
	when a.close_reason = '51091002' then '用户取消订单'
	when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end `订单关闭原因`,
case when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end `退货原因`,
h.`退货状态` `退货状态`,
h.`退货数量` `退货数量`,
h.`退回V值` `退回V值`,
if(h.`退回时间` > '1970-01-01 08:00:00',h.`退回时间`,null) `退回时间`
from ods_orde.ods_orde_tt_order_d a    -- 订单表
left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
left join ods_good.ods_good_item_spu_d c on b.spu_id = c.id    -- 前台spu表(获取商品前台专区ID)
left join ods_good.ods_good_front_category_d d on d.id = c.front_category1_id     -- 前台专区列表(获取前台专区名称)
left join ods_good.ods_good_item_sku_d e on e.id = b.sku_id      -- 前台sku表(获取商品DN价)
left join
(
	-- 获取前台分类[充电专区]的商品 
	select distinct j.id as spu_id,j.name `name`,f2.name as `前台分类`
	from ods_good.ods_good_item_spu_d j
	left join ods_good.ods_good_item_sku_d i on j.id =i.spu_id 
	left join ods_good.ods_good_item_sku_channel_d s on i.id =s.sku_id 
	left join ods_good.ods_good_front_category_d f2 on s.front_category1_id=f2.id
	where 1=1
	and f2.name='充电专区'
	and s.is_deleted ='0'
	and f2.is_deleted ='0'
) f on f.spu_id = b.spu_id
left join
(
	-- 退单明细
	select
	so.refund_order_code,
	so.order_code,
	sp.product_id,
	case when so.status = '51171001' then  '待审核' 
		when so.status = '51171002' then  '待退货入库' 
		when so.status = '51171003' then  '待退款' 
		when so.status = '51171004' then  '退款成功' 
		when so.status = '51171005' then  '退款失败' 
		when so.status = '51171006' then  '作废退货单'
		else null end `退货状态`,
	sum(sp.sales_return_num) `退货数量`,
	sum(so.refund_point) `退回V值`,
	max(so.create_time) `退回时间`
	from ods_orde.ods_orde_tt_sales_return_order_d so
	left join ods_orde.ods_orde_tt_sales_return_order_product_d sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = '0'
	and sp.is_deleted = '0'
	GROUP BY 1,2,3,4
) h on a.order_code = h.order_code and b.product_id = h.product_id
left join
(
	-- 扫一店一码对应的经销商Code
	select
	a.order_code order_code,
	a.order_product_id order_product_id,
	a.dealer_code dealer_code,
	a.create_time create_time
	from ods_orde.ods_orde_tt_order_product_ex_d a
	where 1=1
	and a.dealer_code <> ''
	and a.is_deleted = 0
) i on a.order_code = i.order_code and b.product_id = i.order_product_id    -- 这里先用子单号关联，可能存在问题。
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id id,
	tcv.order_no order_no,
	tcv.coupon_id coupon_id,
	tci.coupon_name coupon_name,
	tcd.one_id one_id,
	tcd.member_id member_id,
	tcd.ticket_state ticket_state
	from ods_coup.ods_coup_tt_coupon_verify_d tcv
	inner join ods_coup.ods_coup_tt_coupon_detail_d tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join ods_coup.ods_coup_tt_coupon_info_d tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	-- and tcv.is_deleted = 0
) j on a.order_code = j.order_no
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id id,
	tcv.order_no order_no,
	tcv.coupon_id coupon_id,
	tci.coupon_name coupon_name,
	tcd.one_id one_id,
	tcd.member_id member_id,
	tcd.ticket_state ticket_state
	from ods_coup.ods_coup_tt_coupon_verify_d tcv
	inner join ods_coup.ods_coup_tt_coupon_detail_d tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join ods_coup.ods_coup_tt_coupon_info_d tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	-- and tcv.is_deleted = 0
) k on ifnull(a.parent_order_code,a.order_code) = k.order_no
where 1=1
and a.create_time >= '2024-07-01' and a.create_time < now()   -- 订单时间
and a.is_deleted <> 1
and b.is_deleted <> 1
and a.type = '31011003'  -- 订单类型：沃世界商城订单
and a.separate_status = '10041002' -- 拆单状态：否
and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and g.order_code is not null  -- 剔除退款订单
order by a.create_time


	
-- 是否授权亲友、授权身份
	select 
	a.distinct_id,a.member_id,a.是否车主,b.绑定关系 as 授权亲友
	from
	(
		select distinct_id,member_id,是否车主 from
		(
			-- 会员表 是否车主
			select
			t.cust_id distinct_id,
			t.id member_id,
			case when t.is_vehicle = 1 then '车主' else '粉丝' end 是否车主,
			row_number() over(partition by t.cust_id order by t.create_time desc) rk
			from "member".tc_member_info t
			where t.member_status <> 60341003 and t.is_deleted = 0
			and t.cust_id is not null
		)
		where rk = 1
	) a
	left join
	(
		-- 绑定关系表-绑定关系
		select * from
		(
			-- 绑定关系表
			select
			a.member_id,case when a.is_bind = 1 then '绑定' else '解绑' end 是否绑定,
			case when a.relative_type=60531001 then '好友'
				when a.relative_type=60531002 then '丈夫'
				when a.relative_type=60531003 then '妻子'
				when a.relative_type=60531004 then '儿子'
				when a.relative_type=60531005 then '女儿'
				when a.relative_type=60531006 then '父亲'
				when a.relative_type=60531007 then '母亲'
				when a.relative_type=60531008 then '亲戚'
				end 绑定关系,
			row_number() over(partition by a.`member_id` order by a.date_create desc) num
			from volvo_cms.vehicle_bind_relation a
			where a.`is_owner` <> '1'   -- 不是车主
		)
		where num = 1
		and 绑定关系 is not null
	) b on a.member_id =b.member_id


-- 商城订单明细(PGSQL)
select
a.order_code 订单号,
ifnull(a.parent_order_code,a.order_code) 母单号,
case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	WHEN LEFT(a.client_id,1) = '2' then 'APP订单'
	else null end 订单来源,
case when a.order_source = '51021001' then '立即下单'
	when a.order_source = '51021002' then '购物车下单'
	when a.order_source = '51021003' then '工单'
	when a.order_source = '51021004' then '秒杀'
	when a.order_source = '51021006' then '组合购订单'
	when a.order_source = '51021007' then '买赠订单'
	else null end 订单来源渠道,
a.user_id `下单人会员ID`,
a.user_phone 下单人手机号,
b.sku_code 商品货号,
b.product_id,
e.part_number `PN号`,
b.spu_name 兑换商品,
b.spu_id `商品SPU_ID`,
b.sku_id `商品SKU_ID`,
b.sku_code 商品编码,
b.sku_price/100 `商品零售含税价(元)`,
e.cls12/100 `商品DN价(元)`,
b.sku_real_point 商品单价,
c.front_category_id,
ifnull(f.`前台分类`,ifnull(case when d.name in('售后养护','充电专区','精品','生活服务') then d.name else null end,
	case when b.spu_type = '51121001' THEN '精品'
		when b.spu_type = '51121002' THEN '生活服务'
		when b.spu_type = '51121003' THEN '售后养护'
		when b.spu_type = '51121004' THEN '精品'
		when b.spu_type = '51121006' THEN '一件代发'
		when b.spu_type = '51121007' THEN '经销商端产品'
		when b.spu_type = '51121008' THEN '售后养护'
		else null end)) 前台分类,
case when b.spu_type = '51121001' then '沃尔沃精品'
	when b.spu_type = '51121002' then '第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '非沃尔沃精品'    -- 还会新增一个子分类
	when b.spu_type = '51121006' then '一件代发'
	when b.spu_type = '51121007' then '经销商端产品'
    when b.spu_type = '51121008' then '虚拟服务权益'
    else null end 商品类型,
case when e.boutique_type = 0 then '售后附件'
	else null end `精品二级分类`,
case when b.spu_type = '51121003' and b.spu_name like '%桩%' then '是' else '否' end 是否保养类卡券_充电桩,
b.fee/100 `总金额(元)`,
round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
b.sku_total_fee/100 `商品金额(元)`,
b.express_fee/100 `运费金额(元)`,
ifnull(j.id,k.id) `卡券唯一ID`,
ifnull(j.coupon_id,k.coupon_id) `优惠券卡券ID`,
ifnull(j.coupon_name,k.coupon_name) `优惠券名称`,
b.coupon_fee/100 `优惠券抵扣金额(元)`,
round(b.point_amount/3+b.pay_fee/100,2) `实付金额(元)`,
b.pay_fee/100 `现金支付金额(元)`,
b.point_amount `支付V值(个)`,
b.sku_num 兑换数量,
a.create_time 下单时间,
date_format(a.create_time,'%Y-%m') 下单年月,
a.pay_time 支付时间,
case when b.pay_fee = 0 then '纯V值支付' when b.point_amount = 0 then '纯现金支付' else '混合支付' end 支付方式,
i.dealer_code `下单经销商Code`,
case when b.spu_type = '51121001' then 'VOLVO仓商品' 
	when b.spu_type = '51121002' then 'VOLVO仓第三方卡券' 
	when b.spu_type = '51121003' then '虚拟服务卡券' 
	when b.spu_type = '51121004' then '京东仓商品'
	else null end 仓库,
case when b.status = '51301001' then '待付款'
	when b.status = '51301002' then '待发货' 
	when b.status = '51301003' then '待收货' 
	when b.status = '51301004' then '收货确认'
	when b.status = '51301005' then '退货中'
	when b.status = '51301006' then '交易关闭'  
	else null end 订单商品状态,
case when a.status = '51031001' then '预创建'
	when a.status = '51031002' then '待付款'
	when a.status = '51031003' then '待发货'
	when a.status = '51031004' then '待收货'
	when a.status = '51031005' then '已完成'
	when a.status = '51031006' then '交易关闭'
	when a.status = '51031007' then '创建失败'
	else null end 订单状态,
case when a.close_reason = '51091001' then '超时未支付'
	when a.close_reason = '51091002' then '用户取消订单'
	when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end 订单关闭原因,
case when a.close_reason = '51091003' then '用户退款'
	when a.close_reason = '51091004' then '用户退货退款'
	when a.close_reason = '51091005' then '商家退款'
	else null end 退货原因,
h.退货状态,
h.退货数量,
h.`退回V值`,
h.退回时间
from "order".tt_order a   -- 订单表
left join "order".tt_order_product b on a.order_code = b.order_code    -- 订单商品表
left join goods.item_spu c on b.spu_id = c.id    -- 前台spu表(获取商品前台专区ID)
left join goods.front_category d on d.id = c.front_category1_id     -- 前台专区列表(获取前台专区名称)
left join goods.item_sku e on e.id = b.sku_id      -- 前台sku表(获取商品DN价)
left join
(
	-- 获取前台分类[充电专区]的商品 
	select distinct j.id as spu_id,j.name `name`,f2.name as `前台分类`
	from goods.item_spu j
	left join goods.item_sku i on j.id =i.spu_id 
	left join goods.item_sku_channel s on i.id =s.sku_id 
	left join goods.front_category f2 on s.front_category1_id=f2.id
	where 1=1
	and f2.name='充电专区'
	and s.is_deleted = 0
	and f2.is_deleted = 0
) f on f.spu_id = b.spu_id
left join
(
	-- 退单明细
	select
	so.refund_order_code,
	so.order_code,
	sp.product_id,
	case when so.status = '51171001' then  '待审核' 
		when so.status = '51171002' then  '待退货入库' 
		when so.status = '51171003' then  '待退款' 
		when so.status = '51171004' then  '退款成功' 
		when so.status = '51171005' then  '退款失败' 
		when so.status = '51171006' then  '作废退货单'
		else null end 退货状态,
	sum(sp.sales_return_num) 退货数量,
	sum(so.refund_point) `退回V值`,
	max(so.create_time) 退回时间
	from "order".tt_sales_return_order so
	left join "order".tt_sales_return_order_product sp on so.refund_order_code = sp.refund_order_code
	where 1=1
	and so.status = '51171004'     -- 退款成功
	and so.is_deleted = 0
	and sp.is_deleted = 0
	GROUP BY 1,2,3,4
) h on a.order_code = h.order_code and b.product_id = h.product_id
left join
(
	-- 扫一店一码对应的经销商Code
	select
	a.order_code order_code,
	a.order_product_id order_product_id,
	a.dealer_code dealer_code,
	a.create_time create_time
	from "order".tt_order_product_ex a
	where 1=1
	and a.dealer_code <> ''
	and a.is_deleted = 0
) i on a.order_code = i.order_code and b.product_id = i.order_product_id    -- 这里先用子单号关联，可能存在问题。
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id,
	tcv.order_no,
	tcv.coupon_id,
	tci.coupon_name,
	tcd.one_id,
	tcd.member_id,
	tcd.ticket_state
	from coupon.tt_coupon_verify tcv
	inner join coupon.tt_coupon_detail tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join coupon.tt_coupon_info tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	-- and tcv.is_deleted = 0
) j on a.order_code = j.order_no
left join
(
	-- 根据订单号匹配优惠券抵扣金额
	select
	tcv.id,
	tcv.order_no,
	tcv.coupon_id,
	tci.coupon_name,
	tcd.one_id,
	tcd.member_id,
	tcd.ticket_state
	from coupon.tt_coupon_verify tcv
	inner join coupon.tt_coupon_detail tcd on tcv.coupon_detail_id = tcd.id-- and tcd.is_deleted = 0
	left join coupon.tt_coupon_info tci on tcd.coupon_id = tci.id--  and tci.is_deleted = 0
	where 1=1
	-- and tcd.ticket_state = '31061003'   -- 卡券状态：已核销
	and tcv.order_no is not null
	-- and tcv.is_deleted = 0
) k on ifnull(a.parent_order_code,a.order_code) = k.order_no
where 1=1
--and a.create_time >= '2024-01-01' and a.create_time < '2024-07-11'   -- 订单时间
and a.is_deleted <> 1
and b.is_deleted <> 1
--and a.type = '31011003'  -- 订单类型：沃世界商城订单
--and a.separate_status = '10041002' -- 拆单状态：否
--and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
--AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
-- and g.order_code is not null  -- 剔除退款订单
and b.spu_id in ( '3866', 
 '3915', 
 '3862', 
 '3863', 
 '3861', 
 '3875', 
 '3864', 
 '3859')
order by a.create_time



-- 根据会员ID匹配默认收货地址
select 
tma.MEMBER_ID 会员ID,
tma.CONSIGNEE_NAME 收货人姓名,
tma.CONSIGNEE_PHONE 收货人手机号,
CONCAT(ifnull(tr.REGION_NAME,''),ifnull(tr2.REGION_NAME,''),ifnull(tr3.REGION_NAME,''),ifnull(tma.MEMBER_ADDRESS,''))收货地址
from `member`.tc_member_address tma
left join dictionary.tc_region tr on tma.ADDRESS_PROVINCE = tr.REGION_CODE
left join dictionary.tc_region tr2 on tma.ADDRESS_CITY = tr2.REGION_CODE
left join dictionary.tc_region tr3 on tma.ADDRESS_REGION = tr3.REGION_CODE
where tma.IS_DELETED = 0
and tma.IS_DEFAULT = 1  -- 默认收货地址
-- and tma.CONSIGNEE_PHONE=18721762520

		-- 22Q4之后推荐购有效订单数
		select
		r.invite_member_id 邀请人会员ID,
		r.invite_mobile 邀请人手机号,
		r.be_invite_member_id 被邀请人会员ID,
		r.be_invite_mobile 被邀请人手机号,
		r.order_no 订单号,
		r.invoice_no 发票号,
		r.blue_invoice_time 蓝票开票时间,
		r.order_time 订单时间,
		r.payment_time 定金支付时间,
		case when r.is_large_set = 1 then '是'
			when r.is_large_set = 2 then '否'
			end 是否大定订单,
		r.vehicle_name 车型,
		r.create_time 留资时间,
		case when r.order_status = '14041008' then '已交车'
			when r.order_status = '14041003' then '审核已通过'
			else null end 订单状态,
		tso.OWNER_CODE 经销商编号,
		tso.DRAWER_NAME 开票人姓名,
		tsov.SALES_VIN 车架号
		from invite.tm_invite_record r
		-- left join dictionary.tc_code tc on r.order_status::int8 = tc.CODE_ID and tc.IS_DELETED = 0 and tc.code_id <> ''
		left join cyxdms_retail.tt_sales_orders tso on r.order_no = tso.SO_NO and tso.BUSINESS_TYPE <> 14031002 and tso.IS_DELETED = 0
		left join cyxdms_retail.tt_sales_order_vin tsov on tsov.VI_NO = tso.SO_NO
		where r.is_deleted = 0
		and r.order_status in ('14041008','14041003')   -- 有效订单 已交车、审核已通过
		and r.order_no is not NULL   -- 筛选订单号不为空
		and r.cancel_large_setorder_time is null    -- 取消订单时间为空，排除取消订单的情况
		and r.red_invoice_time is null   -- 红冲发票为空
--		and r.create_time >= '2023-01-01'
--		and r.create_time <'2023-12-16'
--		and r.blue_invoice_time >= '2023-01-01'
--		and r.blue_invoice_time <'2023-12-16'
		order by r.create_time	

-- 邀约试驾 当月总留资量
SELECT t2.code 邀约code, 
	t2.member_id 邀请人会员ID,
	tmi.MEMBER_PHONE  邀请人手机号,
	t2.create_time 邀约时间,
	t1.be_invite_member_id 被邀请人会员ID,
	t1.be_invite_mobile 被邀请人会员手机号,
	t1.reserve_time 留资时间,
	t1.be_invite_mobile 被邀请人手机号,
	t1.vehicle_name 留资车型,
	t1.drive_time 实际试驾时间,
	tmi.cust_id as distinct_id
FROM invite.tm_invite_code t2
left join invite.tm_invite_record t1 on t1.invite_code = t2.code 
left join `member`.tc_member_info tmi on t2.member_id = tmi.id
WHERE t2.create_time BETWEEN '2023-01-01' and '2023-09-25 23:59:59'

-- 卡券核销代码
SELECT 
        b.coupon_name 卡券名称,
        b.id coupon_id卡券ID,
        a.left_value/100 面额,
        b.coupon_code 券号,
        tmi.ID 沃世界会员ID,
        tmi.MEMBER_NAME 会员昵称,
        tmi.real_name 姓名,
        tmi.MEMBER_PHONE 沃世界绑定手机号,
        t.associate_vin 购买关联VIN,
        declear_list.company_code 经销商code,
        t.associate_dealer 购买关联经销商,
        a.get_date 获得时间,
        a.activate_date 激活时间,
        a.expiration_date 卡券失效日期,
        CAST(a.exchange_code as varchar) 核销码,
        CASE a.ticket_state
            WHEN 31061001 THEN '已领用'
            WHEN 31061002 THEN '已锁定'
            WHEN 31061003 THEN '已核销' 
            WHEN 31061004 THEN '已失效'
            WHEN 31061005 THEN '已作废'
        END AS 卡券状态,
        v.核销经销商,
        v.核销VIN,
        v.核销时间
        FROM coupon.tt_coupon_detail a  -- 卡券信息表
        JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id 
        left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID  -- 会员表
        left join `order`.tt_order_product t on a.order_code = t.order_code  -- 商品购买关联经销商，Vin
        left join (
                select company_code,code_name,row_number() over(partition by code_name order by bz) as bz
                from (
                    (select company_code ,company_short_name_cn as code_name,'1' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and company_short_name_cn is not null )
                    union all 
                    select company_code,official_dealer_name as code_name,'2' as bz
                    from organization.tm_company
                    where IS_DELETED = 0 AND COMPANY_TYPE = 15061003 and official_dealer_name is not null and official_dealer_name<>''
                    )
        ) declear_list
        on declear_list.code_name = t.associate_dealer and declear_list.bz='1'
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
        from coupon.tt_coupon_verify v  -- 卡券核销信息表
        where  v.is_deleted=0
        order by v.create_time 
        ) v ON v.coupon_detail_id = a.id
        where 1=1
        and a.get_date >='2024-08-01'
        and a.get_date <curdate() 
        and a.is_deleted=0 
        and b.coupon_code='KQ202405240026'
        and tmi.is_deleted=0
        order by 6;

-- 默认收货地址（取用户创建的最新默认地址）
select c.MEMBER_ID,收货人姓名,收货人手机号,收货地址 from
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
)c where c.rk = 1

-- 卡券领用核销明细
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
where 1=1
--and a.get_date >= '2023-09-25'
--and a.get_date <= '2022-07-31 23:59:59'
--and a.is_deleted=0
and v.核销时间 >= '2023-01-01'  
and v.核销时间 <= '2023-01-31 23:59:59'   
and a.ticket_state = '31061003'  
order by a.get_date desc 


-- 沃尔沃伙伴计划丨一款有态度的环保袋评论明细
select
teh.user_id 会员ID,
tmi.MEMBER_PHONE 沃世界注册手机号,
teh.content 评论内容,
teh.create_time 评论时间,
-- teh.evaluation_source 评论来源,
teh.liked_count 点赞数
from comment.tt_evaluation_history teh 
left join `member`.tc_member_info tmi on teh.user_id = tmi.ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where teh.object_id='sLO4M0eIzp'
and teh.is_deleted = 0
order by teh.liked_count desc


-- 商品下架明细
select
b.code 商品ID,
a.name 商品名称,
fc.name 所属前台分类,
a.last_up_time 最近上架时间,
a.lower_time 下架时间,
(a.min_price/100) 最低售价,
a.lower_reason 下架原因,
a.sale_limit 是否限购,
co.orient_name 面向客户人群,
c.client_name 终端名称
from goods.item_spu a  -- 商品主表
left join goods.item_sku b on a.id = b.spu_id  -- 匹配商品ID
left join goods.front_category fc on a.front_category_id  = fc.id  -- 匹配商品所属前台分类
left join goods.client c on a.client_id = c.client_id   -- 匹配终端名称
left join goods.client_orient co on a.orient_id = co.id  -- 匹配面向客户人群
where a.lower_time >= '2022-01-01'
and a.status = 60291004

-- 根据各种条件匹配微信公众号openid
select a.会员ID
,a.客户ID
,a.会员昵称
,a.姓名
,a.性别
,a.手机号
,a.VIN
,a.微信小程序open_id
,(eco.open_id)微信公众号open_id
,a.注册时间
,eco.subscribe_time 
from
	(	select 
	m.id 会员ID,
	m.cust_id 客户ID,
	m.create_time 注册时间,
	case when m.member_sex = '10021001' then '先生'
		when m.member_sex = '10021002' then '女士'
		else '未知' end 性别,
	m.member_name 会员昵称,
	m.real_name 姓名,
	m.MEMBER_PHONE 手机号,
	tmv.VIN,
	c.open_id 微信小程序open_id,
	ifnull(c.union_id,u.unionid) allunionid
	from member.tc_member_info m 
	left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
	left join customer.tm_customer_info c on c.id=m.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id::varchar=m.old_memberid::varchar
	where m.is_deleted = 0 and m.member_status <> '60341003'
	and IFNULL(c.union_id,u.unionid) is not null 
	and u.unionid <> '00000000') a 
left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
where 1=1
-- and a.手机号 in ('13818961761')
and eco.subscribe_status = 1 -- 状态为关注
and eco.open_id is not null 
and eco.open_id <> ''
order by a.注册时间 DESC

-- 是否俱乐部成员
select
distinct b.member_id ,
a.content,
b.create_time
from community_club.tt_club_attr_audit a --俱乐部信息表
left join community_club.tr_club_friends b --俱乐部成员信息表
on a.club_id  = b.club_id and b.is_deleted = 0
where a.attr_type  = '10010'--俱乐部信息 10010俱乐部名称
and a.is_deleted = 0

-- 小程序各等级对应的会员数
select
tl.LEVEL_NAME 会员等级,
COUNT(tmi.ID)用户数
from `member`.tc_member_info tmi 
left join 
(select distinct tl.LEVEL_CODE,tl.LEVEL_NAME
from `member`.tc_level tl
where tl.LEVEL_CODE is not null) tl on tmi.LEVEL_ID = tl.LEVEL_CODE 
where tmi.MEMBER_STATUS <> '60341003'
and tmi.IS_DELETED = 0
group by tl.LEVEL_NAME
order by tl.LEVEL_CODE

-- 沃世界会员数量，区分车主粉丝
select
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
	COUNT(tmi.ID)会员数量
from `member`.tc_member_info tmi
where tmi.MEMBER_STATUS <> '60341003'
and tmi.IS_DELETED = 0
group by 1

-- V值发放（获取）明细
select
a.MEMBER_ID,
b.USER_ID,
b.REAL_NAME 姓名,
b.MEMBER_PHONE 手机号,
a.EVENT_DESC V值获取途径,
a.INTEGRAL V值数额,
a.CREATE_TIME V值获取时间
from `member`.tt_member_flow_record a
left join `member`.tc_member_info b on a.MEMBER_ID = b.ID 
where a.RECORD_TYPE = 0  -- 0：获取  1：消耗
and a.STATUS = 1
and a.IS_DELETED = 0
order by a.CREATE_TIME

-- 销售重要警示数据取数逻辑：根据提供的VIN，在绑定关系表中获取会员ID，会员ID关联会员表会员ID关联，从而获取到会员信息。
select
vbr.vin_code,
vbr.member_id 会员ID,
tmi.MEMBER_NAME 会员昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.MEMBER_PHONE 沃世界绑定手机号
from volvo_cms.vehicle_bind_relation vbr  -- 绑定关系表
left join `member`.tc_member_info tmi on tmi.ID = vbr.member_id and tmi.IS_DELETED = 0 and tmi.MEMBER_STATUS <> '60341003'  -- 关联会员表，去掉逻辑删除和黑名单
where vbr.is_owner = 1  -- 这里筛选车主
and vbr.deleted = 0  -- 逻辑删除
and vbr.vin_code = 'LYVXEAED4NL681138'

-- 销售额
select 
SUM(m.总金额) GMV汇总,
SUM(case when m.商品类型2='精品' then m.总金额 else null end) "精品（元）",
SUM(case when m.商品类型2='售后养护' then m.总金额 else null end) "售后（元）",
SUM(case when m.商品类型2='充电专区' then m.总金额 else null end) "充电（元）",
SUM(case when m.商品类型2='生活服务' then m.总金额 else null end) "第三方卡券（元）",
SUM(m.支付V值) GMV汇总V值,
SUM(case when m.商品类型2='精品' then m.支付V值 else null end) `精品（元）V值`,
SUM(case when m.商品类型2='售后养护' then m.支付V值 else null end) `售后（元）V值`,
SUM(case when m.商品类型2='充电专区' then m.支付V值 else null end) `充电（元）V值`,
SUM(case when m.商品类型2='生活服务' then m.支付V值 else null end) `生活服务（元）V值`,
SUM(m.`现金支付金额`) `GMV汇总现金`,
SUM(case when m.`商品类型2`='精品' then m.`现金支付金额` else null end) `精品（元）现金`,
SUM(case when m.`商品类型2`='售后养护' then m.`现金支付金额` else null end) `售后（元）现金`,
SUM(case when m.`商品类型2`='充电专区' then m.`现金支付金额` else null end) `充电（元）现金`,
SUM(case when m.`商品类型2`='生活服务' then m.`现金支付金额` else null end) `生活服务（元）现金`,
SUM(m.优惠券抵扣金额) GMV汇总优惠券抵扣金额,
SUM(case when m.商品类型2='精品' then m.优惠券抵扣金额 else null end) `精品（元）优惠券抵扣金额`,
SUM(case when m.商品类型2='售后养护' then m.优惠券抵扣金额 else null end) `售后（元）优惠券抵扣金额`,
SUM(case when m.商品类型2='充电专区' then m.优惠券抵扣金额 else null end) `充电（元）优惠券抵扣金额`,
SUM(case when m.商品类型2='生活服务' then m.优惠券抵扣金额 else null end) `生活服务（元）优惠券抵扣金额`
from 
	(select a.order_code 订单编号
	,b.product_id 商城兑换id
	,a.user_id 会员id
	,h.cust_id 
	,a.user_name 会员姓名
	,b.spu_name 兑换商品
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id
	,b.sku_code
	,b.sku_real_point 商品单价
	,case WHEN LEFT(a.client_id,1) = '6' then '小程序订单'
	 WHEN LEFT(a.client_id,1) = '2' then 'APP订单' else null end 平台
	,ifnull(f2.前台分类,ifnull(case when f.name in('售后养护','充电专区','精品','生活服务') then f.name else null end
	,CASE WHEN b.spu_type =51121001 THEN '精品'
		WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
		WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
		WHEN b.spu_type =51121004 THEN '精品'
		WHEN b.spu_type =51121006 THEN '一件代发'
		WHEN b.spu_type =51121007 THEN '经销商端产品'
		WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
		ELSE null end)) 商品类型2
	,CASE b.spu_type
		WHEN 51121001 THEN '沃尔沃精品' 
		WHEN 51121002 THEN '第三方卡券' 
		WHEN 51121003 THEN '虚拟服务卡券' 
		WHEN 51121004 THEN '非沃尔沃精品'    -- 还会新增一个子分类
		WHEN 51121006 THEN '一件代发'
		WHEN 51121007 THEN '经销商端产品'
	    WHEN 51121008 THEN '虚拟服务权益'
	    ELSE null end 商品类型
	,b.fee/100 总金额
	,b.coupon_fee/100 优惠券抵扣金额
	,round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) 不含税的总金额
	,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.sku_num 兑换数量
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
	from "order".tt_order a  -- 订单主表
	left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted <> 1 -- 订单商品表
	left join coupon.tt_coupon_verify cv on cv.order_no =b.order_code and cv.is_deleted <>1 -- 优惠券核销表 核销金额
	left join coupon.tt_coupon_info tci on cv.coupon_id =tci.id 
	left join member.tc_member_info h on a.user_id = h.id and h.is_deleted <> 1  -- 会员表(获取会员信息)
	left join goods.item_spu j on b.spu_id = j.id and j.is_deleted =0 and j.front_category_id is not null -- 前台spu表(获取商品前台专区ID)
	left join goods.front_category f on f.id=j.front_category1_id -- 前台专区列表(获取前天专区名称)
	left join
	(
		-- 获取前台分类[充电专区]的商品 
		select distinct j.id as spu_id ,j."name" ,f2."name" as 前台分类
		from "goods".item_spu j
		left join goods.item_sku i on j.id =i.spu_id 
		left join goods.item_sku_channel s on i.id =s.sku_id 
		left join goods.front_category f2 on s.front_category1_id=f2.id
		where f2."name"='充电专区'
		and j.is_deleted =0
		and i.is_deleted =0
		and s.is_deleted =0
		and f2.is_deleted =0
	)f2 on f2.spu_id=b.spu_id
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
	and a.create_time >= '2023-10-18' and a.create_time <'2023-11-01'
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
	AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
	and (b.spu_type in (51121001,51121004,51121006,51121007,51121008) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	and e.order_code is null  -- 剔除退款订单
	order by a.create_time) m

	-- 带优惠券相关明细的订单明细
	select 
--	订单信息
	a.order_code 订单编号
	,a.create_time 兑换时间
	,CASE a.status
		when 51031001 then '预创建'
		WHEN 51031002 THEN '待付款' 
		WHEN 51031003 THEN '待发货' 
		WHEN 51031004 THEN '待收货' 
		WHEN 51031005 THEN '已完成'
		WHEN 51031006 THEN '已关闭'  
		when 51031007 then '创建失败'
		when 51031009 then '待付尾款'
	END AS 订单状态
	,a.client_id 
	,client.client_name 客户端
	,b.product_id 商城兑换id
--	用户信息
	,a.user_id 会员id
	,h.cust_id 
	,a.user_name 会员姓名
--	商品信息
	,b.spu_name 兑换商品
	,b.promotion_id 促销id
	,b.spu_id
	,b.sku_id
	,b.spu_bus_id 
	,b.sku_code 商品编码
	,b.sku_real_point/3 建议零售价_元
	,b.sku_price/100 折扣价_元
	,get2.exchange_type_name 商品类型
	,b.spu_pay_type 
	,b.fee/100 总金额
	,b.coupon_fee/100 优惠券抵扣金额
	,round(b.point_amount/3+b.pay_fee/100,2) 实付金额
	,b.pay_fee/100 现金支付金额
	,b.point_amount 支付V值
	,b.point_fee/100 V值抵扣金额
	,b.sku_num 兑换数量
	,case when b.pay_fee=0 then '纯V值支付' when b.point_amount=0 then '纯现金支付' else '混合支付' end 支付方式
	,f."name" 分类
	,f1."name" 分类2
	,ifnull(case when f."name" in('售后养护','充电专区','精品','生活服务') then f."name" else null end
		,ifnull(case when f."name" in('售后养护','充电专区','精品','生活服务') then f."name" else null end
			,CASE WHEN b.spu_type =51121001 THEN '精品'
					WHEN b.spu_type =51121002 THEN '生活服务' --第三方卡券`
					WHEN b.spu_type =51121003 THEN '售后养护' --保养类卡券
					WHEN b.spu_type =51121004 THEN '精品'
					WHEN b.spu_type =51121006 THEN '一件代发'
					WHEN b.spu_type =51121007 THEN '经销商端产品'
					WHEN b.spu_type =51121008 THEN '售后养护'   -- '车辆权益'
				ELSE null end)
	) 前端分类
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
--	优惠券相关数据
	,cv.coupon_id 使用优惠券id
	,tci.coupon_name 使用优惠券名称
	,cv.coupon_detail_id 使用优惠券的领取id
	,tcd.create_time 使用优惠券的领取时间
--	退款信息
	,CASE a.close_reason 
		WHEN 51091003 THEN '用户退款' 
		WHEN 51091004 THEN '用户退货退款' 
		WHEN 51091005 THEN '商家退款' 
		END AS 关闭原因
	,e.`退货状态`
	,e.`退货数量`
	,e.退回V值
	,e.退回时间
from "order".tt_order a  -- 订单主表
left join "order".tt_order_product b on a.order_code = b.order_code and b.is_deleted = 0 -- 订单商品表
left join goods.client client on client.client_id =a.client_id 
left join goods.goods_exchange_type get2 on get2.exchange_type_id =b.spu_type and get2.is_deleted =0
left join coupon.tt_coupon_verify cv on cv.order_no =b.order_code and cv.is_deleted =0 -- 优惠券核销表 核销金额
left join coupon.tt_coupon_info tci on cv.coupon_id =tci.id and tci.is_deleted =0 --卡券表
left join coupon.tt_coupon_detail tcd on tcd.id =cv.coupon_detail_id and tcd.is_deleted =0
left join member.tc_member_info h on a.user_id = h.id and h.is_deleted = 0  -- 会员表(获取会员信息)
	left join (
	select spu_id,client_id,sku_id,max(front_category1_id) as front_category1_id
	from goods.item_sku_channel
	where is_deleted =0 and id <>'12803'
	group by spu_id,client_id,sku_id
) isc on isc.spu_id =b.spu_id  and isc.client_id=a.client_id and isc.sku_id = b.sku_id
left join goods.front_category f on f.id=isc.front_category1_id -- 前台专区列表(获取前天专区名称)
left join goods.item_spu is2 on is2.id =b.spu_id and is2.client_id =a.client_id and is2.is_deleted =0
left join goods.front_category f1 on f1.id=is2.front_category1_id -- 前台专区列表(获取前天专区名称)
left join(
--	V值退款成功记录
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
where 1=1
and date(a.create_time) >= '2024-01-17' 
and date(a.create_time) <'2024-01-25'
and a.is_deleted = 0  -- 剔除逻辑删除订单
and a.type = 31011003  -- 筛选沃世界商城订单
and a.separate_status = '10041002' -- 选择拆单状态否
and a.status  NOT IN (51031001,51031007) -- 去除预创建和创建失败订单
AND (a.close_reason NOT IN (51091001,51091002) OR a.close_reason IS NULL ) -- 去除超时未支付和取消订单
--and (b.spu_type in (51121001,51121004,51121006,51121007,51121008) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
--and e.order_code is null  -- 剔除退款订单
and b.sku_code in ('31422886',
'32355219',
'32284878',
'32355380',
'31422756',
'32284836',
'31422881',
'31422752',
'32355259',
'32355258'
)
order by a.create_time
	
	
--任务周度完成情况
select case when t.event_desc =('完成App车主首次发文章') then '完成App车主首次发文章任务'
	 when t.event_desc =('完成App粉丝首次发文章') then '完成App粉丝首次发文章任务'
	 when t.event_desc =('完成App车主首次发动态') then '完成App车主首次发动态任务'
	 when t.event_desc =('完成App粉丝首次发动态') then '完成App粉丝首次发动态任务'
     when t.event_desc = '完成预约并试驾任务' then '完成首次预约并试驾任务'
else t.event_desc
end as event_desc,
		COUNT(DISTINCT t.MEMBER_ID) 人数,
		COUNT(t.MEMBER_ID) 次数
FROM `member`.tt_member_score_record t
left join member.tc_member_info b on t.member_id = b.id
WHERE (t.event_type in ('60731011','60731003','60731013','60731041','60731052','60731049','60731055','60731006','60731050','60731051','60731056','60731054','60741230','60741231') or 
t.event_desc in('完成App文章浏览（10秒）任务','完成App签到任务','完成App社区点赞任务','完成App文章加精任务','完成App文章被推荐任务','完成WOW商城每月首次下单任务')) -- 任务类型
--and t.CREATE_TIME BETWEEN '{start_time_1}' and '{end_time}'  -- 时间
and t.CREATE_TIME BETWEEN '2023-07-11' and '2023-07-17 235959'
and t.IS_DELETED =0 and b.member_status<>60341003
GROUP by 1

-- 文章明细	 
select o.ref_id,c.title-- ,c.上线时间
				,SUM(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,SUM(case when o.type='SUPPORT' then 1 else 0 end) 点赞量
				,SUM(CASE when o.type='SHARE' then 1 else 0 end) 转发量
				,SUM(CASE when o.type='COLLECTION' then 1 else 0 end) 收藏量
	from cms_center.cms_operate_log o
	left join (
--				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from cms_center.cms_content c 
			where c.deleted=0 
			union all 
--			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.is_deleted=0
			-- and a.modifier like '%Wedo%' 
			and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and date_create <'2023-05-01' and date_create >='2023-04-01'
	and o.ref_id='ox4e67qM97' 
	GROUP BY 1,2;

-- tcodePV UV  
select
--date_format(t.date,'%Y-%m'),
case when json_extract_path_text(data::json,'tcode')='59B01F634DAC432CB87BC90D713A1591' then '小程序-置顶Banner' 
when json_extract_path_text(data::json,'tcode')='A0F0CF729F1E42BB8469FDCA05FF7799' then '小程序-商城banner' 
--when json_extract_path_text(data::json,'tcode')='BAB9DA6818364949A822DC4C35B65555' then '小程序-弹窗' 
else null end 分类,
count(t.usertag) PV,
count(distinct t.usertag) UV,
--count(case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主PV,
--count(case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝PV,
count(distinct case when tmi.IS_VEHICLE = 1 then t.usertag end) 车主UV,
count(distinct case when tmi.IS_VEHICLE = 0 then t.usertag end) 粉丝UV
from track.track t
join `member`.tc_member_info tmi on t.usertag=CAST(tmi.user_id AS VARCHAR)and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >='2023-04-01'   -- 每天修改起始时间
and t.`date` <'2023-05-01' -- 每天修改截止时间
group by 1


-- 拉新
select count(DISTINCT m.id)
from 'cms-center'.cms_operate_log l
join member.tc_member_info m on l.user_id=m.user_id and m.is_vehicle=0
where l.date_create >='2022-08-01 00:00:00' and l.date_create <= '2022-08-31 23:59:59' 
and l.ref_id='bVKItdYobG'and l.type ='VIEW' 
and m.create_time<date_add(l.date_create,INTERVAL 10 minute) and m.create_time>=DATE_sub(l.date_create,INTERVAL 10 MINUTE) ;

-- 激活
select '04激活沉睡用户数' 类目
,count(DISTINCT a.usertag ) 总数
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.is_vehicle,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select m.is_vehicle,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from 'cms-center'.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			-- where l.date_create BETWEEN '2022-02-21' and '2022-03-20 23:59:59'  
			where l.date_create >='2022-08-01 00:00:00' and l.date_create <= '2022-08-31 23:59:59' 
			and l.ref_id='bVKItdYobG'
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL 10  MINUTE)
		GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.ldate,INTERVAL 30 DAY) ; 

-- PV UV
select case when t.`data` like '%7FFF588EA0904E918B326E5271CDF2D8%' then '01 首页banner'
	when t.`data` like '%B9B33DD6B1F047C2AB417729A42C20DE%' then '02 首页活动banner'	
    when json_extract(t.`data`,'$.path')='/src/pages/common/common-auth/index?returnUrl=%2Fsrc%2Fpages%2Flovecar-package%2Fappointment%2Fappointment%3Fchid%3DM236PK4RPN%26chcode%3DIBDMAUGS900SFGZS2022VCCN%26chtype%3D1' then '03 前往预约试驾'		
    else null end 分类,
-- tmi.IS_VEHICLE 是否车主,
COUNT(t.usertag) PV,
COUNT(DISTINCT t.usertag) UV
from track.track t
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-01 00:00:00' and t.`date` <= '2022-08-31 23:59:59'
group by 1
order by 1

-- 活动各项监控数据
select o.ref_id,o.title,o.PV,o.UV,o.车主数,o.粉丝数,o.游客数,o.点赞量,o.转发量,o.收藏量
,e.one 一级评论数,e.two 二级评论数,e.lyl 总评论数,f.xin 拉新,d.sli 僵尸粉数
,o.上线时间 
from (
	select o.ref_id,c.title,c.上线时间
				,sum(case when o.type='VIEW' then 1 else 0 end)  PV
				,count(distinct case when o.type='VIEW' then o.user_id else null end) UV
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=1 then o.user_id else null end) 车主数
				,count(DISTINCT case when o.type='VIEW' and m.is_vehicle=0 then o.user_id else null end) 粉丝数
				,count(DISTINCT case when o.type='VIEW' and m.id is null then o.user_id else null end) 游客数
				,sum(case when o.type='SUPPORT' then 1 else 0 end) 点赞量
				,sum(CASE when o.type='SHARE' then 1 else 0 end) 转发量
				,sum(CASE when o.type='COLLECTION' then 1 else 0 end) 收藏量
	from cms_center.cms_operate_log o
	left join (
--				#查询文章pageid
			select c.page_id
			,c.title 
			,c.publish_date 上线时间
			from cms_center.cms_content c 
			where c.deleted=0 
			union all 
--			#查询活动pageid
			select a.page_id,a.active_name title,a.date_create 上线时间
			from activity.cms_active a 
			where a.active_locate='沃尔沃汽车沃世界'
			and a.is_deleted=0 and a.page_id is not null and a.page_id<>''
	) c on o.ref_id=c.page_id
	left join (
			select mm.id,mm.user_id,mm.is_vehicle
			from (
			select m.user_id,max(m.id) mid
			from member.tc_member_info m 
			where m.is_deleted=0 and m.member_status<>60341003
			GROUP BY 1  ) m
			LEFT JOIN member.tc_member_info mm on mm.id=m.mid
	)m on m.user_id=o.user_id
	where o.type in ('VIEW','SUPPORT','SHARE','COLLECTION') 
	and o.ref_id='Dg82cQK2sq'
	GROUP BY 1,2,3
) o left join (
	select object_id,
	-- count(object_id) lyl 
	sum(case when top_id is null then 1 else 0 end) one,
	sum(case when top_id is not null then 1 else 0 end) two,
	count(object_id) lyl 
	from comment.tt_evaluation_history 
	where object_id ='Dg82cQK2sq'
	group by 1
) e on e.object_id=o.ref_id
left join (
select a.ref_id,count(a.usertag) sli
from(
		-- 获取访问文章活动10分钟之前的最晚访问时间
		select t.usertag,b.ldate,b.ref_id,max(t.date) tdate
		from track.track t
		join (
			-- 获取访问文章活动的最早时间
			select ref_id,cast(l.user_id as varchar) user_id,min(date_create) ldate 
			from cms_center.cms_operate_log l
			join member.tc_member_info m on l.user_id=m.user_id
			where l.ref_id='Dg82cQK2sq' 
			and l.type ='VIEW' 
			GROUP BY 1,2
		) b on b.user_id=t.usertag
		where t.date< DATE_SUB(b.ldate,INTERVAL '10' MINUTE)
		GROUP BY 1,2,3
	) a
	where a.tdate < DATE_SUB(a.ldate,INTERVAL '30' DAY) 
	GROUP BY 1
) d on d.ref_id=o.ref_id 
left join (
	select 'Dg82cQK2sq' ref_id,count(DISTINCT m.id) xin
	from track.track t
	join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
	where 
	json_extract_path_text(t.data::json,'pageId')='Dg82cQK2sq' 
--	json_extract(t.`data`,'$.pageId')='Dg82cQK2sq' 
	and m.create_time>=date_sub(t.date,interval '10' MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL '10' MINUTE)
	and t.date>='2023-08-31'
) f on f.ref_id=o.ref_id


-- 活动拉新人数、排除车主
select count(DISTINCT m.id)拉新人数
from track.track t
join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR) and m.is_vehicle = 0  -- 排除车主
where t.date >= '2022-03-13' and t.date < '2022-03-14' 
and json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
and m.create_time>=date_sub(t.date,interval 10 MINUTE) and m.create_time<=DATE_ADD(t.date,INTERVAL 10 MINUTE)


-- 僵尸粉-track表计算
select
a.is_vehicle 是否车主,
-- ,a.usertag
count(distinct a.usertag) 激活数量
	from(
	 -- 获取访问文章活动10分钟之前的最晚访问时间
	 select t.usertag
	 ,b.mdate -- 获取访问文章活动的最早时间
	 ,b.is_vehicle
	 ,max(t.date) tdate
	 from track.track t
		 join (
		  -- 获取访问文章活动的最早时间
		  select m.is_vehicle,t.usertag,min(t.date) mdate 
		  from track.track t 
		  join member.tc_member_info m on t.usertag=CAST(m.user_id AS VARCHAR)
		  where json_extract(t.`data`,'$.embeddedpoint')='C40YUSHOU_C40ZHONGCHOU_ONLOAD'
		  and t.`date` >= '2022-03-13' and t.`date` < '2022-03-14'
		  GROUP BY 1,2
		 ) b on b.usertag=t.usertag
	 where t.date< DATE_SUB(b.mdate,INTERVAL 10  MINUTE)
	 GROUP BY 1,2,3
) a
where a.tdate < DATE_SUB(a.mdate,INTERVAL 30 DAY) 
GROUP BY 1;


-- 樊登书店合作活动报名人数及名单
select
car.active_id 活动ID,
ca.active_name 活动名称,
car.custom_id 会员ID,
car.custom_name 姓名,
car.custom_tel 电话,
car.member_level_name 会员等级,
--CONCAT(ifnull(tr.REGION_NAME,""),ifnull(tr2.REGION_NAME,""))省市,
car.register_time 报名时间
from activity.cms_active_register car
left join activity.cms_active ca on ca.uid = car.active_id 
left join `member`.tc_member_info tmi on tmi.ID = car.custom_id
left join dictionary.tc_region tr on tr.REGION_CODE = tmi.MEMBER_PROVINCE 
left join dictionary.tc_region tr2 on tr2.REGION_ID = tmi.MEMBER_CITY 
where 1=1
--and car.active_id = 'mY8eJO3jE4'
and car.is_registered = 1
order by car.register_time desc 



-- 养修预约评价数据
-- 以下为养修预约评价数据提取逻辑.
-- 另需注意 : 
-- 在给养修预约/去送车服务匹配评价数据的时候，不能仅仅用工单进行关联，因为2家经销商可能会存在同一个工单号，
--工单号在不同的经销商处是独立存在的。也就是说你匹配的时候得同时关联工单和经销商编码（代码)
SELECT distinct
a.id 评价ID,
a.create_time 评价时间,
b.CODE_CN_DESC 评价类型,
a.dealer_code 经销商代码,
a.object_id 评价对象ID,
CASE WHEN f.OWNER_ONE_ID IS NULL THEN k.CUST_ID ELSE f.OWNER_ONE_ID END 客户ONEID,
CASE WHEN f.CONTACT_NAME IS NULL THEN IFNULL(k.REAL_NAME,k.MEMBER_NAME ) ELSE f.CONTACT_NAME END 联系人名称,
CASE WHEN f.CONTACT_PHONE IS NULL THEN k.MEMBER_PHONE ELSE f.CONTACT_PHONE END 联系人电话,
CASE WHEN f.MAINTAIN_ID IS NULL THEN d.APP_ID ELSE f.MAINTAIN_ID END 养修主键ID,
CASE when f.vin IS NULL THEN d.VIN ELSE f.VIN END VIN,
CASE WHEN f.WORK_ORDER_NUMBER IS NULL THEN d.RO_NO ELSE f.WORK_ORDER_NUMBER END 工单号,
s.score 得分
-- , GROUP_CONCAT (h.phrase_id) phrase_id, GROUP_CONCAT (j.phrase) phrase
FROM comment.tt_evaluation_history a
left join comment.tc_evaluation_score s on s.evaluation_id =a.id
left join dictionary.tc_code b on a.object_type =b.CODE_ID
left join cyx_appointment.tt_appointment_maintain f on f.APPOINTMENT_ID=a.object_id
left join cyx_repair.tt_repair_order d on d.RO_NO = a.object_id and a.dealer_code =d.OWNER_CODE
left join member.tc_member_vehicle j on j.vin=d.VIN
left join member.tc_member_info k on k.ID =j.MEMBER_ID
where a.create_time between '2022-01-01 00:00:00' and '2022-03-31 23:59:59'
and a.object_type ='31151003'
order by a.id desc


-- 30天未登陆、且V值大于1000的人群
select
tmi.ID 会员ID,
tmi.MEMBER_PHONE,
tmi.MEMBER_V_NUM V值
from `member`.tc_member_info tmi 
left join 
(select t.usertag,max(t.`date`) max_date
	from track.track t
	group by 1) a on a.usertag = cast(tmi.USER_ID as varchar) 
where (a.max_date < DATE_SUB(CURDATE(),INTERVAL 31 DAY) or a.max_date is null)
and (a.max_date > tmi.MEMBER_TIME or a.max_date is null)
and tmi.MEMBER_V_NUM >= '1000'
and tmi.IS_DELETED = 0
and tmi.MEMBER_STATUS <> 60341003
order by 3 desc

-- 预约试驾
	SELECT
	DISTINCT ta.APPOINTMENT_ID 预约ID,
	ta.CREATED_AT 预约时间,
	ta.ARRIVAL_DATE 实际到店日期,
	ca.active_name 活动名称,
	ta.one_id 客户ID,
	ta.customer_name 姓名,
	ta.customer_phone 手机号,
	tm2.MODEL_NAME 预约车型,
	h.大区,
	h.小区,
	ta.OWNER_CODE 经销商,
	CASE tad.status
		WHEN 70711001 THEN '待试驾'
	    WHEN 70711002 THEN '已试驾' 
	    WHEN 70711003 THEN '已取消'
	    END 试驾状态,
	tad.drive_s_at 试驾开始时间,
	tad.drive_e_at 试驾结束时间
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
	LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
	LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
	LEFT JOIN (
	    select 
	        DISTINCT
	        tm.COMPANY_CODE,
	        tg2.ORG_NAME 大区,
	        tg1.ORG_NAME 小区
	    from organization.tm_company tm
	    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
	    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
	    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
	    inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
	    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	    ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
	left join basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID and tm2.IS_DELETED = 0
	WHERE  1=1
--	and ta.CREATED_AT >= '2023-09-01'
--	AND ta.CREATED_AT <'2023-10-26'
--	and ta.APPOINTMENT_ID='1840957490624815106'
	and ta.customer_phone='18916879351'
	AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
	AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
--	and ca.active_code = 'IBDMAUGMIXSJXCXD2023VCCN'   -- 小程序
	order by ta.CREATED_AT

-- 4、预约试驾明细  试驾工单表
	SELECT
    DISTINCT 
    ta.APPOINTMENT_ID 预约ID,
    ta.CREATED_AT 预约时间,
--     ta.ARRIVAL_DATE 实际到店日期,
--    case when f.到店时间 > ta.CREATED_AT then f.到店时间 else null end 到店时间,
    ca.active_name 活动名称,
    ta.one_id 客户ID,
    tmi.id MemberID,
    ta.customer_name 姓名,
    tmi.member_phone 注册手机号,
    ta.customer_phone 手机号,
    tm2.model_name 留资车型,
    h.大区,
    h.小区,
    ta.OWNER_CODE 经销商,
    tc2.COMPANY_NAME_CN 经销商名称,
    CASE tad.status
    	WHEN 70711001 THEN '待试驾'
        WHEN 70711002 THEN '已试驾' 
        WHEN 70711003 THEN '已取消'
        END 预约试驾表试驾状态,
	case when (e.DRIVE_STATUS = 20211001 or e.DRIVE_STATUS = 20211004) then  '待试驾'
     when e.DRIVE_STATUS = 20211003  then  '已试驾'
     when e.DRIVE_STATUS = 20211002  then  '已取消'
          else null end 工单表试驾状态,
    tad.drive_s_at 预约试驾表试驾开始时间,
	tad.drive_e_at 预约试驾表试驾结束时间,
    case when e.试驾开始时间 > ta.CREATED_AT then e.试驾开始时间 else tad.drive_s_at end 工单表试驾开始时间,
    case when e.试驾结束时间 > ta.CREATED_AT then e.试驾结束时间 else tad.drive_e_at end 工单表试驾结束时间,
    e.TEST_DRIVE_SOURCE
    FROM cyx_appointment.tt_appointment ta
    left join `member`.tc_member_info tmi on ta.one_id =tmi.CUST_ID and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
    LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
    LEFT JOIN 
	    (
	    select
	    tc2.COMPANY_CODE , tc2.COMPANY_NAME_CN
	    from
	    (
	    select 
	    tc2.COMPANY_CODE, tc2.COMPANY_NAME_CN
	    ,row_number() over(partition by tc2.COMPANY_CODE  order by tc2.create_time desc) rk
	    from
	    organization.tm_company tc2)tc2
	    where rk=1
	    )tc2 on ta.OWNER_CODE = tc2.COMPANY_CODE 
    LEFT JOIN cyx_appointment.tt_appointment_drive tad ON tad.APPOINTMENT_ID = ta.APPOINTMENT_ID 
    LEFT JOIN basic_data.tm_model tm2 on tad.THIRD_ID = tm2.ID 
    LEFT JOIN cyxdms_retail.tt_sales_orders tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID
    LEFT JOIN activity.cms_active ca ON ca.uid = ta.CHANNEL_ID 
    LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS
    LEFT JOIN (
        select 
            DISTINCT
            tm.COMPANY_CODE,
            tg2.ORG_NAME 大区,
            tg1.ORG_NAME 小区
        from organization.tm_company tm
        inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
        inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
        inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
        inner JOIN organization.tm_org tg2 ON tg2.id = tr2.parent_org_id and tg2.ORG_TYPE = 15061005 
        where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
        ORDER BY tm.COMPANY_CODE ASC) h on h.COMPANY_CODE = ta.owner_code
    LEFT JOIN 
	(
		--  历史试驾数据(存在一个商机ID对应多条试驾信息)
		select 
		*,
		p.CUSTOMER_BUSINESS_ID
-- 		p.MOBILE 试驾手机号
		,p.DRIVE_S_AT 试驾开始时间
		,p.DRIVE_E_AT 试驾结束时间
		,p.drive_status
		,p.APPOINTMENT_ID
		,p.TEST_DRIVE_SOURCE
		from drive_service.tt_testdrive_plan p    -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
		where 1=1
		and DATE_FORMAT(p.DRIVE_S_AT ,'%Y-%m-%d') >= '2023-09-01' 
		and DATE_FORMAT(p.DRIVE_S_AT ,'%Y-%m-%d') <= '2023-10-25 23:59:59' 
		and p.IS_DELETED = 0
--		and CUSTOMER_BUSINESS_ID='1718857734293647361'
	) e on 
--	ta.CUSTOMER_BUSINESS_ID = e.CUSTOMER_BUSINESS_ID and 
	e.APPOINTMENT_ID=ta.appointment_id 
	LEFT JOIN 
		( -- 存在一个商机ID对应多条到店信息
		select
		q.CUSTOMER_BUSINESS_ID 
		,q.ARRIVE_DATE 到店时间
		from
		cyx_passenger_flow.tt_passenger_flow_info q
		where q.IS_DELETED =0
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') >= '2023-09-01'
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') <= '2023-10-25 23:59:59'
		and q.CUSTOMER_BUSINESS_ID is not null
		) f on ta.CUSTOMER_BUSINESS_ID = f.CUSTOMER_BUSINESS_ID
    WHERE 1=1
    and ta.CREATED_AT >= '2024-03-26'
    AND ta.CREATED_AT < '2024-03-27'
    AND ta.APPOINTMENT_TYPE = 70691002     -- 预约试乘试驾
    AND ta.DATA_SOURCE = 'C'   -- 数据来源B端C端
    and ta.CUSTOMER_PHONE not in ('18774245716','18758197483','15237325515','17802166389','13611757536','17521318891','16601707464')   -- 剔除测试信息
--    and tmi.id='7408958'
--    and ta.appointment_id ='1718857734293647361'
    order by ta.CREATED_AT

     -- 存在一个商机ID对应多条到店信息
		select*
		from
		cyx_passenger_flow.tt_passenger_flow_info q
		where q.IS_DELETED =0
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') >= '2023-09-01'
		and DATE_FORMAT(q.ARRIVE_DATE ,'%Y-%m-%d') <= '2023-09-01 23:59:59'
		and q.CUSTOMER_BUSINESS_ID is not null
		
    
-- 养修预约
select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
       ta.APPOINTMENT_ID "预约ID",
       ta.OWNER_CODE "经销商代码",
       tc2.COMPANY_NAME_CN "经销商名称",
       ta.ONE_ID "车主oneid",
       tam.OWNER_ONE_ID ,
       ta.CUSTOMER_NAME "联系人姓名",
       ta.CUSTOMER_PHONE "联系人手机号",
       tmi.ID "会员ID",
       tmi.MEMBER_PHONE "沃世界绑定手机号",
       tam.CAR_MODEL "预约车型",
       tam.CAR_STYLE "预约车款",
       tam.VIN "车架号",
       case when tam.IS_TAKE_CAR = 10041001 then '是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
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
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where 1=1
--and ta.CREATED_AT >= '2022-02-04 12:00:00'
--and ta.CREATED_AT < '2022-02-11 12:00:00'
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005;

select *
from cyx_appointment.tt_appointment  ta

-- 成功提交养修预约并进厂人数
select COUNT(b.养修预约ID)成功提交养修预约并进厂人数 from
(select
distinct tmi.ID 会员ID
from track.track t 
join `member`.tc_member_info tmi on t.usertag = CAST(tmi.USER_ID AS VARCHAR) and tmi.MEMBER_STATUS <> 60341003 and tmi.IS_DELETED = 0
where t.`date` >= '2022-08-22' and t.`date` < now()
and t.`data` like '%AF9147DC3554496293F1A1A5D325B2AC%')a
join
-- 预约养修
(select cast(tam.MAINTAIN_ID as varchar) "养修预约ID",
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
       case when tam.IS_TAKE_CAR = 10041001 then'是'
    when tam.IS_TAKE_CAR = 10041002 then '否'
     end  "是否取车",
       case when tam.IS_GIVE_CAR = 10041001 then '是'
         when tam.IS_GIVE_CAR = 10041002 then '否'
       end "是否送车",
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态",
       tam.CREATED_AT "创建时间",
       tam.UPDATED_AT "修改时间",
--       ta."CREATE123D_AT" "预约时间",
       tam.WORK_ORDER_NUMBER "工单号"
from cyx_appointment.tt_appointment ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where ta.CREATED_AT >= '2022-08-22'
and ta.CREATED_AT < now()
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005)b
on a.会员ID = b.会员ID
where b.养修状态 in ('提前进厂','准时进厂','延迟进厂','待评价','已评价')

select distinct 
       tam.MAINTAIN_STATUS "养修状态code",
       tc.CODE_CN_DESC "养修状态"
from cyx_appointment.tt_appointment ta
left join cyx_appointment.tt_appointment_maintain tam  on tam.APPOINTMENT_ID =ta.APPOINTMENT_ID and tam.IS_DELETED <>1
left join organization.tm_company tc2 on tc2.COMPANY_CODE =ta.OWNER_CODE 
left JOIN dictionary.tc_code tc on tc.CODE_ID =tam.MAINTAIN_STATUS 
left join `member`.tc_member_info tmi on ta.ONE_ID = tmi.CUST_ID 
where 1=1
and ta.CREATED_AT >= '2022-08-22'
and ta.CREATED_AT < now()
and ta.DATA_SOURCE ='C'
and ta.APPOINTMENT_TYPE =70691005
and tam.MAINTAIN_STATUS in ('80671007','80671011','80671012')
group by tam.MAINTAIN_STATUS
order by 1

select min(t.date)
from track.track t 

-- 会员常用信息
select
--tmi.USER_ID,
tmi.ID "会员ID",
--IFNULL(tmi.REAL_NAME,tmi.MEMBER_NAME) "姓名",
tmi.MEMBER_PHONE "手机号"
--tmi.MEMBER_URL "会员头像",
--case when tmi.IS_VEHICLE='1' then '绑定'
--	else '未绑定' end 是否绑定车辆,
--t.vin_code,
--tisd.dealer_code 经销商代码,
--t.车型,
--tr.REGION_NAME 所在地,
--tc.CODE_CN_DESC "性别",
--tmi.MEMBER_BIRTHDAY "生日",
--tmi.MEMBER_HOBBY "爱好兴趣"
from `member`.tc_member_info tmi 
left join
( 
--# 车系
 select v.member_id,v.vin_code,ifnull(m.MODEL_NAME,v.model_name)车型
 from (
 select v.MEMBER_ID,v.series_code,m.model_name,v.vin_code
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.bind_date desc) rk
 from volvo_cms.vehicle_bind_relation v 
 left join basic_data.tm_model m on v.series_code=m.MODEL_CODE
 where v.DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin_code=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 where v.rk=1
) t on tmi.id=t.member_id
left join dictionary.tc_code tc on tc.CODE_ID =tmi.MEMBER_SEX
left join dictionary.tc_region tr on tmi.MEMBER_PROVINCE = tr.REGION_CODE
left join vehicle.tt_invoice_statistics_dms tisd on t.vin_code = tisd.vin 
where tmi.IS_DELETED =0 
and tmi.MEMBER_STATUS <>60341003
--and (t.车型 like '%T8%' 
--or t.车型='XC90')
and tmi.id in ('8636418',
'6365605',
'5786286',
'6365605',
'6365605',
'7067097',
'4526373',
'4658543',
'5296180',
'4807598',
'5774870',
'3632507',
'5942308',
'8040696',
'3408999',
'6222498',
'6763589',
'7265960',
'5680367',
'6659079',
'6821813',
'5563361',
'6218444',
'4263767',
'5947357',
'3473145',
'5693070',
'7316062',
'3509554',
'6148576',
'5866588',
'5375750',
'3211883',
'5915468',
'5509400',
'4801208',
'6254901',
'7727019',
'6784030',
'6036610',
'7194364',
'3776713',
'5555399',
'6120534',
'7320942',
'6343959',
'6657362',
'6164632',
'3603292',
'3804639',
'4002518',
'5591518',
'4552724',
'6254883',
'8094245',
'5912250',
'6123546',
'4735543',
'5856748',
'3310421',
'3317624',
'6405872',
'6058383',
'4085488',
'5874208',
'6008386'
)



-- 会员对应城市，根据优先级排序：1、最后绑定经销商城市 2、会员表城市 3、默认收货地址城市
	select
	m.id,
	m.is_vehicle,
--	m.member_phone,
--	ifnull(c1.region_name,IFNULL(c2.region_name,c3.region_name)) 省份,
	ifnull(c1.city_name,IFNULL(c2.city_name,c3.city_name)) 城市
--	c1.COMPANY_CODE
	from member.tc_member_info m 
	left join
	(
	 -- 最后绑定经销商城市
	 select a.member_id,c.PROVINCE_NAME region_name,c.city_name city_name,c.COMPANY_CODE,c.COMPANY_NAME_CN 
	 from
	 (
		  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
		  from
		  (
		    select v.MEMBER_ID,v.VIN
		    ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
		    from member.tc_member_vehicle v 
		    where v.is_deleted=0 and v.MEMBER_ID is not null
		  ) v
		  left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
		  left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
		  left join member.tc_member_info m  on v.member_id=m.id
		  where v.rk=1 -- 获取用户最后绑车记录
	 ) a left join organization.tm_company c on c.company_code=a.dealer_code and c.COMPANY_TYPE=15061003
	) c1 on c1.member_id = m.id
	left join (
	 -- 会员表城市
	 select m.id,c.REGION_NAME,c1.region_name city_name
	 from member.tc_member_info m  
	 left join dictionary.tc_region c on m.MEMBER_PROVINCE=c.REGION_ID
	 left join "dictionary".tc_region c1 on m.member_city = c1.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c2 on c2.id= m.id
	left join (
	 -- 收货地址城市
	 select m.id,cc.REGION_NAME,cc1.region_name city_name
	 from member.tc_member_info m 
	 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
	 left join dictionary.tc_region cc on a.address_province=cc.REGION_ID
	 left join "dictionary".tc_region cc1 on a.address_city=cc1.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	 and a.address_city != 'undefined'
	) c3 on c3.id= m.id
	where m.MEMBER_STATUS<>60341003 and m.IS_DELETED=0 and m.id<>3014773  -- 测试ID


-- #收货地址城市
-- select m.id
-- ,cast(replace(cc.REGION_NAME,'\','\\') as bytea)
-- from member.tc_member_info m 
-- left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0 and a.ADDRESS_CITY is not null 
-- left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID and cc.REGION_ID is not null 
-- where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003

select *
from  member.tc_member_address
 
####### APP社区相关sql
-- app评论
select 
a.id,
a.member_id 会员ID,
tmi.MEMBER_NAME 昵称,
case when tmi.member_sex = '10021001' then '先生'
	when tmi.member_sex = '10021002' then '女士'
	else '未知' end 性别,
tmi.real_name 姓名,
tmi.MEMBER_PHONE 手机号码,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
'' 评论tag,
a.create_time 评论日期,
a.comment_content 评论内容,
(length(a.comment_content)-CHAR_LENGTH(a.comment_content))/2  评论字数,
a.images 上传图片
from community.tm_comment a
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
where a.is_deleted =0
and a.create_time >='2022-11-03' 
and a.create_time <'2022-11-22'
and a.post_id ='0sOqdQTFMf'
-- and tmi.MEMBER_PHONE=13516121816


--EM90下订时间
			select
			tmi.id,
			date_format(a.created_at,'%Y-%m-%d')t
			FROM cyxdms_retail.tt_sales_orders  a
			left join cyxdms_retail.tt_sales_order_vin  b on a.`so_no`  = b.`vi_no` 
			left join cyxdms_retail.tt_sales_order_detail c on c.SALES_OEDER_DETAIL_ID = b.SALES_OEDER_DETAIL_ID
			left join "member".tc_member_info tmi on a.customer_tel =tmi.member_phone and tmi.is_deleted = 0 and tmi.member_status <> '60341003'
			WHERE b.`sale_type` = 20131010
--			and a.`so_status` in (14041001,14041002,14041003,14041008,14041030)
--			and a.`is_deposit` in (10421009,10041001,10041002,70961001,70961002)
			and a.is_deposit='10421009' -- 付定金
			and c.second_id = '1111'    -- basic_data里面的id，对应EM90
			and a.created_at >= '2023-01-01'      
			and a.created_at < '2024-01-01'
			and a.so_no not in ('VVD2023111300052','VVD2023111200042','VVD2023111200001')    -- 测试订单，剔除掉
			and a.`is_deleted` ='0'
			and b.`is_deleted` ='0'
			and tmi.id is not null 
			order by 1
		
--- Newbie 线索表
select 
    a.clue_id 线索编号,
    cast(a.business_id as varchar) 商机id,
    a.dealer_code 经销商代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.name 客户姓名,
    a.mobile 客户电话,
    i.CODE_CN_DESC 客户性别,
    a.campaign_id 活动代码id,
    c.active_code 市场活动代码,
    c.active_name 市场活动名称,
    d.CLUE_NAME 来源渠道,
    f.model_name 意向车型,
    b.SHOP_NUMBER 到店次数,
    if(b.SHOP_NUMBER>0,'Y','N') 是否到店,
    g.FIRST_DRIVE_TIME 首次试驾时间,
    b.TEST_DRIVE_TIME 试驾次数,
    if(b.TEST_DRIVE_TIME>0,'Y','N') 是否试驾,
    a.allot_time 线索下发时间,
    b.FATE_AFFIRM_TIME 首次跟进时间,
    b.NEW_ACTION_TIME 最后跟进时间,
    a.handle_time 采集时间,
    b.created_at 商机创建时间,
    a.create_time 线索创建时间,
    e.CODE_CN_DESC 线索状态,
    a.smmclueid 线索id_SMM,
    if(a.smmclueid is null,'NEWBIE','SMM') 来源系统,
    a.smmcustid 潜客id_SMM,
    g.FIRST_ORDER_TIME 首次下单时间,
    g.DEFEAT_DATE 战败时间,
    g.MIN_WORK_CALL_TIME 最早工作号外呼时间,
    g.MAX_WORK_CALL_TIME 最新工作号外呼时间,
    g.TOTAL_CALL_NUM newbie外呼次数,
    g.WORK_CALL_NUM 工作号通话次数,
    g.WORK_CONNECT_NUM 工作号接通次数,
    g.WORK_CONNECT_TIMES 工作号累计通话时长
from customer.tt_clue_clean a 
left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
left join activity.cms_active c on a.campaign_id = c.uid
left join customer_business.tm_clue_source d on d.ID = c.active_channel
left join dictionary.tc_code e on a.clue_status = e.CODE_ID
left join basic_data.tm_model f on a.model_id = f.id
left join customer_business.tt_business_statistics g on g.CUSTOMER_BUSINESS_ID = a.business_id
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,	
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.dealer_code
 left join dictionary.tc_code i on i.code_id = a.gender
where a.create_time >= '2022-04-14'
and a.create_time <= '2022-6-30 23:59:59' 
and c.active_code ='IBDMAPRWSJC40RYS2022VCCN'

-- 历史订单产生数量、订单车型
select 
    a.SO_NO_ID 销售订单ID,
    a.SO_NO 销售订单号,
    a.COMPANY_CODE 公司代码,
    h.COMPANY_NAME_CN 经销商名称,
    h.GROUP_COMPANY_NAME 集团,
    h.ORG_NAME_big 大区,
    h.ORG_NAME_small 小区,
    a.OWNER_CODE 经销商代码,
    a.CREATED_AT 订单日期,
    a.SHEET_CREATE_DATE 开单日期,
    cast(a.CUSTOMER_BUSINESS_ID as varchar) 商机id ,
    a.CUSTOMER_NAME 客户姓名,
    a.DRAWER_NAME 开票人姓名,
    a.CONTACT_NAME 联系人姓名,
    a.CUSTOMER_TEL 潜客电话,
    a.DRAWER_TEL 开票人电话,
    a.PURCHASE_PHONE 下单人手机号,
    g.CODE_CN_DESC 订单状态,
    case when instr('提交待审批,审批通过,已交车,退车中',g.CODE_CN_DESC) then 'Y' else 'N' end 订单是否有效,
    i.CODE_CN_DESC BUSINESS_TYPE,
    a.smmOrderId 订单id_smm,
    a.smmCustId 潜客id_smm,
    a.CUSTOMER_ID ,
    a.CUSTOMER_NO ,
    a.CUSTOMER_ACTIVITY_ID 活动代码id,
    c.CLUE_NAME 来源渠道,
    b.active_code 市场活动代码,
    b.active_name 市场活动名称,
    d.SALES_VIN 车架号,
    f.model_name 车型,
    j.CODE_CN_DESC 线索客户类型,
    k.CODE_CN_DESC 客户性别,
    l.CODE_CN_DESC 交车状态,
    n.CODE_CN_DESC 订单购买类型,
    a.VEHICLE_RETURN_DATE 退车完成日期,
    m.CODE_CN_DESC 退车状态,
    a.RETURN_REASON 退单原因,
    a.RETURN_REMARK 退单备注,
    a.IS_DELETED
from cyxdms_retail.tt_sales_orders a 
left join activity.cms_active b on b.uid = a.CUSTOMER_ACTIVITY_ID
left join customer_business.tm_clue_source c on c.ID = b.active_channel
left join cyxdms_retail.tt_sales_order_vin d on d.VI_NO = a.SO_NO
left join cyxdms_retail.tt_sales_order_detail e on e.SALES_OEDER_DETAIL_ID = d.SALES_OEDER_DETAIL_ID
left join basic_data.tm_model f on f.id = e.SECOND_ID
left join dictionary.tc_code g on g.code_id = a.SO_STATUS
left join (
    select 
        tm.id 经销商表ID,
        tm.ORG_ID 经销商组织ID,
        tm.COMPANY_CODE ,
        tL2.ID 大区组织ID,
        tL2.ORG_NAME ORG_NAME_big,
        tg1.ID 小区组织ID,
        tg1.ORG_NAME ORG_NAME_small,
        tm.COMPANY_NAME_CN ,
        tm.GROUP_COMPANY_NAME
    from organization.tm_company tm
    inner JOIN organization.tr_org tr1 ON tr1.org_id = tm.org_id
    inner JOIN organization.tm_org tg1 ON tg1.id = tr1.parent_org_id and tg1.ORG_TYPE = 15061007
    inner JOIN organization.tr_org tr2 ON tr2.org_id = tr1.parent_org_id
    inner JOIN organization.tm_org tL2 ON tL2.id = tr2.parent_org_id and tL2.ORG_TYPE = 15061005 
    where tm.IS_DELETED = 0 AND tm.COMPANY_TYPE = 15061003 
	) h on h.COMPANY_CODE = a.COMPANY_CODE
 left join dictionary.tc_code i on i.code_id = a.BUSINESS_TYPE
 left join dictionary.tc_code j on j.code_id = a.CUSTOMER_SOURCE
 left join dictionary.tc_code k on k.code_id = a.GENDER
 left join dictionary.tc_code l on l.code_id = a.HAND_CAR_STATUS
 left join dictionary.tc_code m on m.code_id = a.VEHICLE_RETURN_STATUS
left join dictionary.tc_code n on n.code_id = a.PURCHASS_CODE
where a.BUSINESS_TYPE<>14031002
and a.IS_DELETED = 0