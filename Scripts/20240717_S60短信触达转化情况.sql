	select send.context__task_id maid ,send.oneid ,send.context__send_time ,b.id_member_id 
	from
	(
		SELECT context__task_id ,oneid ,context__send_time
		from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
		where a.context__send_time >= '2024-07-01' and a.context__send_time <= '2024-08-01' -- 发送时间: 同事件发生时间[event_time]
		and a.oneid not like '%whitelist%' -- 去除白名单
		and a.context__status = 'SUCCESS'
		and a.context__task_id in ('5107')
	)send
	join 
	(-- 取会员ID
		select distinct b.oneid,b.id_member_id
		from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
		where b.id_member_id is not null
	)b on send.oneid=b.oneid
	
--点击短链人数
select 
a.send_context__task_id,
count(distinct a.send_oneid)
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
where 1=1
and a.send_context__send_time >= '2024-06-01'    -- 发送时间限制上一个自然周，或者上一个自然月
and a.send_context__send_time < '2024-07-17'
and a.send_context__status = 'SUCCESS'   -- 发送状态
and a.send_context__task_id in('5107','5108')
and click_context__click_time is not null  -- 点击短链
--and click_context__click_time is null  -- 没点击短链
group by 1
order by 1
	
--	点击人群发送后到店数
select 
a.send_context__task_id,
count(distinct d.member_phone)
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(
	-- 会员ID
	select distinct b.oneid,m.id,m.cust_id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) d on a.send_oneid = d.oneid
left join ods_cyap.ods_cyap_tt_appointment_d p on d.member_phone=p.CUSTOMER_PHONE 
where 1=1
and a.send_context__send_time >= '2024-06-01'    -- 发送时间限制上一个自然周，或者上一个自然月
and a.send_context__send_time < '2024-07-17'
and a.send_context__status = 'SUCCESS'   -- 发送状态
and a.send_context__task_id in('5107','5108')
--and click_context__click_time is not null  -- 点击短链
--and toDate(a.click_context__click_time) <=toDate(p.ARRIVAL_DATE) -- 点击时间小于到店时间
and click_context__click_time is null  -- 没点击短链
and toDate(a.send_context__send_time) <=toDate(p.ARRIVAL_DATE) -- 发送时间小于到店时间
and p.ARRIVAL_DATE>'2000-01-01' -- 到店时间不为空
group by 1
order by 1 

--	点击人群到店后订单数
select 
a.send_context__task_id,
count(distinct d.member_phone)
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(
	-- 会员ID
	select distinct b.oneid,m.id,m.cust_id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) d on a.send_oneid = d.oneid
left join ods_cyap.ods_cyap_tt_appointment_d p on d.member_phone=p.CUSTOMER_PHONE 
join (
-- 下订单用户
	select
	distinct a.phone_num,a.created_at
	from
	(
		select
		o.customer_tel phone_num,
		o.created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
		where 1=1 
		and o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		UNION ALL  
		select
		o.drawer_tel phone_num,
		o.created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur o 
			where 1=1 
		and o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
		UNION ALL  
		select
		o.purchase_phone phone_num,
		o.created_at
		from ods_cydr.ods_cydr_tt_sales_orders_cur o
		where 1=1 
		and o.is_deleted  = 0
		AND o.so_status IN ('14041003', '14041008', '14041001', '14041002')
	) a
	where length(a.phone_num) = '11'
	and left(a.phone_num,1) = '1'
)x on x.phone_num=d.member_phone
where 1=1
and a.send_context__send_time >= '2024-06-01'    -- 发送时间限制上一个自然周，或者上一个自然月
and a.send_context__send_time < '2024-07-17'
and a.send_context__status = 'SUCCESS'   -- 发送状态
and a.send_context__task_id in('5107','5108')
and p.ARRIVAL_DATE>'2000-01-01' -- 到店时间不为空
and click_context__click_time is not null  -- 点击短链
and toDate(a.click_context__click_time) <=toDate(p.ARRIVAL_DATE) -- 点击时间小于到店时间
and toDate(a.click_context__click_time) <=toDate(x.created_at) -- 点击时间小于下单时间
and toDate(p.ARRIVAL_DATE)<=toDate(x.created_at) -- 到店时间小于下单时间
--and click_context__click_time is null  -- 没点击短链
--and toDate(a.send_context__send_time) <=toDate(p.ARRIVAL_DATE) -- 发送时间小于到店时间
--and toDate(a.send_context__send_time) <=toDate(x.created_at) -- 发送时间小于下单时间
--and toDate(p.ARRIVAL_DATE)<=toDate(x.created_at) -- 到店时间小于下单时间
group by 1
order by 1 





	
# MA运营周报 每周一、每月一号出数据

# 注意事项
CDP/MA的表（MA发送表，ods_cdp库所有表），每日同步时间在下午2-3点，所以保守的话下午4点才能拿到前一天的数据，各位在使用时请注意，如果要跑前一天的数据，请下午四点以后再跑，谢谢。

注意：每天下午4点以后才有前一天的数据
CDP点击发送表：ods_oper_crm.ods_oper_crm_ma_send_click_d_si


-- 新版MA周报(每周一下午5点跑)
select
a.send_context__task_id `画布ID`,
a.send_context__task_name `画布名称`,
a.send_channel_new `推送渠道`,
a.send_context__content_model_id `模板ID`,
a.send_context__content_model_name `模板名称`,
MIN(a.send_context__send_time) `推送日期`,
COUNT(DISTINCT a.send_oneid) `发送成功人数`,
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' then a.click_oneid else null end) `点击人数`,
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' then b.oneid else null end) `点击后全渠道留资`,
-- EM90
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'EM90' then b.oneid else null end) `点击后全渠道EM90留资`,
-- EX30
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'EX30' then b.oneid else null end) `点击后全渠道EX30留资`,
-- C40
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'C40 RECHARGE' then b.oneid else null end) `点击后全渠道C40留资`,
-- XC40 燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC40' then b.oneid else null end) `点击后全渠道XC40留资`,
-- XC60 燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC60' then b.oneid else null end) `点击后全渠道XC60留资`,
-- XC90燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC90' then b.oneid else null end) `点击后全渠道XC90留资`,
-- S60 S60L S60 II
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name in ('S60','S60L','S60 II') then b.oneid else null end) `点击后全渠道S60留资`,
-- S90
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'S90' then b.oneid else null end) `点击后全渠道S90留资`,
-- V60只要这一个
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'V60' then b.oneid else null end) `点击后全渠道V60留资`,
-- V90 Cross Country
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'V90 Cross Country' then b.oneid else null end) `点击后全渠道V90 CC留资`,
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(c.context__ro_create_date) and c.oneid is not null and c.oneid <> '' then c.oneid else null end) `点击后售后回厂`,
ROUND(ifnull(sum(case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(e.create_time) then e.`不含税的总金额(元)` else null end),0),2) `点击后商城GMV`
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(
	-- 全渠道留资线索
	select
	a.oneid,
	a.context__intend_model_name,
	a.context__event_time
	from ods_cdp.ods_cdvo_event_flat_leads_create_d a
	where 1=1
	and a.event_date_ts >= '2024-06-10'
	and a.event_date_ts < '2024-06-17'
) b on a.send_oneid = b.oneid
left join
(
	-- 售后工单创建(只要工单存在即可)
	select
	a.oneid oneid,
	a.context__ro_create_date context__ro_create_date
	from ods_cdp.ods_cdp_event_flat_cust_af_order_create_d a
	where 1=1 
	and event_date_ts >= '2024-06-10'
	and event_date_ts < '2024-06-17'
) c on a.send_oneid = c.oneid
left join
(
	-- 会员ID
	select distinct b.oneid,m.id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) d on a.send_oneid = d.oneid
left join
(
	-- 商城订单明细(CK)
	select
	a.order_code order_code,
	a.user_id user_id,
	round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
	a.create_time create_time
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
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
	where 1=1
	and a.create_time >= '2024-06-10' and a.create_time < '2024-06-17'
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
) e on toString(d.id) = toString(e.user_id)
where 1=1
and a.send_context__send_time >= '2024-06-10'    -- 发送时间限制上一个自然周，或者上一个自然月
and a.send_context__send_time < '2024-06-17'
and a.send_context__status = 'SUCCESS'   -- 发送状态
and a.send_context__task_id = '4402'
group by 1,2,3,4,5
order by 6 asc




-- 新版MA月报(每月一号下午5点跑)
select
a.send_context__task_id `画布ID`,
a.send_context__task_name `画布名称`,
a.send_channel_new `推送渠道`,
a.send_context__content_model_id `模板ID`,
a.send_context__content_model_name `模板名称`,
MIN(a.send_context__send_time) `推送日期`,
COUNT(DISTINCT a.send_oneid) `发送成功人数`,
COUNT(DISTINCT case when toDate(a.click_context__click_time) >= toDate(toStartOfMonth(today() - interval 1 month)) and toDate(a.click_context__click_time) < toDate(toStartOfMonth(today())) then a.click_oneid else null end) `点击人数`,
COUNT(DISTINCT case when toDate(a.click_context__click_time) >= toDate(toStartOfMonth(today() - interval 1 month)) and toDate(a.click_context__click_time) < toDate(toStartOfMonth(today())) and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' then b.oneid else null end) `点击后全渠道留资`,
-- EM90
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'EM90' then b.oneid else null end) `点击后全渠道EM90留资`,
-- EX30
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'EX30' then b.oneid else null end) `点击后全渠道EX30留资`,
-- C40
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'C40 RECHARGE' then b.oneid else null end) `点击后全渠道C40留资`,
-- XC40 燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC40' then b.oneid else null end) `点击后全渠道XC40留资`,
-- XC60 燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC60' then b.oneid else null end) `点击后全渠道XC60留资`,
-- XC90燃油车
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'XC90' then b.oneid else null end) `点击后全渠道XC90留资`,
-- S60 S60L S60 II
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name in ('S60','S60L','S60 II') then b.oneid else null end) `点击后全渠道S60留资`,
-- S90
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'S90' then b.oneid else null end) `点击后全渠道S90留资`,
-- V60只要这一个
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'V60' then b.oneid else null end) `点击后全渠道V60留资`,
-- V90 Cross Country
COUNT(DISTINCT case when a.click_context__click_time >= '2024-06-10' and a.click_context__click_time < '2024-06-17' and toDateTime(a.click_context__click_time) <= toDateTime(b.context__event_time) and b.oneid is not null and b.oneid <> '' and b.context__intend_model_name = 'V90 Cross Country' then b.oneid else null end) `点击后全渠道V90 CC留资`,
COUNT(DISTINCT case when toDate(a.click_context__click_time) >= toDate(toStartOfMonth(today() - interval 1 month)) and toDate(a.click_context__click_time) < toDate(toStartOfMonth(today())) and toDateTime(a.click_context__click_time) <= toDateTime(c.context__ro_create_date) and c.oneid is not null and c.oneid <> '' then c.oneid else null end) `点击后售后回厂`,
ROUND(ifnull(sum(case when toDate(a.click_context__click_time) >= toDate(toStartOfMonth(today() - interval 1 month)) and toDate(a.click_context__click_time) < toDate(toStartOfMonth(today())) and toDateTime(a.click_context__click_time) <= toDateTime(e.create_time) then e.`不含税的总金额(元)` else null end),0),2) `点击后商城GMV`
from ods_oper_crm.ods_oper_crm_ma_send_click_d_si a
left join
(
	-- 全渠道留资线索
	select
	a.oneid,
	a.context__intend_model_name,
	a.context__event_time
	from ods_cdp.ods_cdvo_event_flat_leads_create_d a
	where 1=1
	and toDate(a.event_date_ts) >= toDate(toStartOfMonth(today() - interval 1 month))
	and toDate(a.event_date_ts) < toDate(toStartOfMonth(today()))
) b on a.send_oneid = b.oneid
left join
(
	-- 售后工单创建(只要工单存在即可)
	select
	a.oneid oneid,
	a.context__ro_create_date context__ro_create_date
	from ods_cdp.ods_cdp_event_flat_cust_af_order_create_d a
	where 1=1 
	and toDate(event_date_ts) >= toDate(toStartOfMonth(today() - interval 1 month))
	and toDate(event_date_ts) < toDate(toStartOfMonth(today()))
) c on a.send_oneid = c.oneid
left join
(
	-- 会员ID
	select distinct b.oneid,m.id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) d on a.send_oneid = d.oneid
left join
(
	-- 商城订单明细(CK)
	select
	a.order_code order_code,
	a.user_id user_id,
	round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
	a.create_time create_time
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
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
	where 1=1
	and toDate(a.create_time) >= toDate(toStartOfMonth(today() - interval 1 month)) and toDate(a.create_time) < toDate(toStartOfMonth(today()))
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
) e on toString(d.id) = toString(e.user_id)
where 1=1
and toDate(a.send_context__send_time) >= toDate(toStartOfMonth(today() - interval 1 month))    -- 发送时间限制上一个自然周，或者上一个自然月
and toDate(a.send_context__send_time) < toDate(toStartOfMonth(today()))
and a.send_context__status = 'SUCCESS'   -- 发送状态
group by 1,2,3,4,5
order by 6 asc






















-- 新版MA周报
select
send.context__task_id `画布ID`,
send.context__task_name `画布名称`,
send.context__touch_channel `推送渠道`,
send.context__content_model_id `模板ID`,
send.context__content_model_name `模板名称`,
MIN(send.context__send_time) `推送日期`,
COUNT(distinct send.oneid) `发送成功人数`,
COUNT(distinct case when click.oneid is not null then click.oneid else null end) `点击人数`,
COUNT(distinct case when toDateTime(click.click_time) <= toDateTime(leads.context__event_time) and leads.oneid is not null then leads.oneid else null end) `点击后全渠道留资`,
COUNT(distinct case when toDateTime(click.click_time) <= toDateTime(leads.context__event_time) and leads.oneid is not null and leads.context__intend_model_name = 'EM90' then leads.oneid else null end) `点击后全渠道EM90留资`,
COUNT(distinct case when toDateTime(click.click_time) <= toDateTime(leads.context__event_time) and leads.oneid is not null and leads.context__intend_model_name = 'EX30' then leads.oneid else null end) `点击后全渠道EX30留资`,
COUNT(case when toDateTime(click.click_time) <= toDateTime(service.context__ro_create_date) and service.oneid is not null then service.oneid else null end) `点击后售后回厂`,
ROUND(ifnull(sum(case when toDateTime(click.click_time) <= toDateTime(mall.create_time) then mall.`不含税的总金额(元)` else null end),0),2) `点击后商城GMV`
from
(
	-- 发送表
	select
	a.context__task_id,    -- 画布ID
	a.context__task_name,
	a.context__touch_channel,    -- 推送渠道
	a.oneid,    -- one_id
	a.context__content_model_id,    -- 内容ID
	a.context__content_model_name,
	a.context__original_url,
	a.context__individual_id,
	toDateTime(a.context__send_time) context__send_time -- 最后再取最早时间
	from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
	where 1=1 -- 发送时间: 同事件发生时间[event_time]
	and a.context__send_time >= '2024-06-10'
	and a.context__send_time < '2024-06-17'
	and a.context__status = 'SUCCESS'
) send
left join
(
	-- 点击表
	select
	a.context__task_id,
	a.context__touch_channel,
	a.oneid,
	toDateTime(min(a.context__click_time)) click_time
	from
	(
		-------------------------------[点击表]关联[发送表] v1-----------------------------
		select send.context__touch_channel ,click.context__task_id ,click.oneid ,click.context__click_time
		from
		(	-- 点击
			SELECT distinct oneid,context__task_id,context__channel_type,context__content_model_id,context__original_url,context__individual_id,context__click_time
			from ods_cdp.ods_cdvo_event_flat_volvo_event_url_click_customer_profilebase_d click
			where click.context__channel_type is not null
			and click.context__channel_type in ('app_push')    -- APP PUSH
		)click
		join
		(	-- 发送
			SELECT distinct oneid,context__task_id,context__touch_channel,context__content_model_id,context__original_url,context__individual_id,context__send_time
			from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a
			where a.context__touch_channel in ('app_push')
		)send on send.oneid=click.oneid -- 用户oneid  
			and send.context__task_id =click.context__task_id -- 画布ID
			and send.context__touch_channel=click.context__channel_type -- 触达渠道
			and send.context__content_model_id=click.context__content_model_id -- 内容模版ID
			and send.context__original_url=click.context__original_url -- 原始链接url
		where send.context__send_time <= click.context__click_time   -- 发送时间小于等于点击时间
		and click.context__click_time >= '2024-06-10'
		and click.context__click_time < '2024-06-17'
		group by 1,2,3,4
		union all
		-------------------------------[点击表]关联[发送表] v2-------------------------------------------------------------------------------------------------------------------------55555
		SELECT  
			case when send.context__touch_channel in ('instation_mini_program','instation_app') then 'instation' else send.context__touch_channel end context__touch_channel
			,click.context__task_id ,click.oneid ,click.context__click_time
		from
		(	-- 点击
			SELECT distinct oneid,context__task_id
			,case when context__channel_type='public_account_template_message' then 'wechat_mp_template' else context__channel_type end context__channel_type
			,context__content_model_id,context__original_url,context__individual_id,context__click_time  
			from ods_cdp.ods_cdvo_event_flat_volvo_event_url_click_customer_profilebase_d click    -- 点击表
			where click.context__channel_type is not null
			and click.context__channel_type not in ('app_push')  -- 非APP PUSH
		)click
		join
		(	-- 发送
			SELECT distinct oneid,context__task_id,context__touch_channel,context__content_model_id,context__original_url,context__individual_id,context__send_time
			from ods_cdp.ods_cdvo_event_flat_volvo_event_send_customer_profilebase_d a   -- 发送表
			where a.context__touch_channel not in ('app_push')
		)send on send.oneid=click.oneid -- 用户oneid
			and send.context__task_id =click.context__task_id -- 画布ID
			and send.context__touch_channel=click.context__channel_type -- 触达渠道
			and send.context__content_model_id=click.context__content_model_id -- 内容模版ID
			and send.context__original_url=click.context__original_url -- 原始链接url
			and send.context__individual_id=click.context__individual_id -- 发送主体ID(APP PUSH没有这个条件，原因是不一致)
		where send.context__send_time <= click.context__click_time
		and click.context__click_time >= '2024-06-10'
		and click.context__click_time < '2024-06-17'
		group by 1,2,3,4
	) a
	group by 1,2,3
) click on send.oneid = click.oneid and send.context__task_id = click.context__task_id and send.context__touch_channel = click.context__touch_channel
left join
(
	-- 全渠道留资线索
	select
	a.oneid,
	a.context__intend_model_name,
	a.context__event_time
	from ods_cdp.ods_cdvo_event_flat_leads_create_d a
	where 1=1
	and a.event_date_ts >= '2024-06-10'
	and a.event_date_ts < '2024-06-17'
) leads on send.oneid = leads.oneid
left join
(
	-- 售后工单创建(只要工单存在即可)
	select
	a.oneid,
	MIN(a.context__ro_create_date) context__ro_create_date
	from ods_cdp.ods_cdp_event_flat_cust_af_order_create_d a
	where 1=1 
	and event_date_ts >= '2024-06-10'
	and event_date_ts < '2024-06-17'
	group by 1
) service on send.oneid = service.oneid
left join
(
	-- 会员ID
	select distinct b.oneid,m.id,m.member_phone 
	from ods_cdp.ods_cdvo_rtp_customer_profilebase_attribute_d b -- 清洗后的会员表
	join ods_memb.ods_memb_tc_member_info_cur m on b.id_member_id =m.id::varchar  
	where b.id_member_id is not null
) user on send.oneid = user.oneid
left join
(
	-- 商城订单明细(CK)
	select
	a.order_code order_code,
	a.user_id user_id,
	round(((b.fee/100) - (b.coupon_fee/100))/1.13,2) `不含税的总金额(元)`,
	a.create_time create_time
	from ods_orde.ods_orde_tt_order_d a    -- 订单表
	left join ods_orde.ods_orde_tt_order_product_d b on a.order_code = b.order_code    -- 订单商品表
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
	where 1=1
	and a.create_time >= '2024-06-10' and a.create_time < '2024-06-17'
	and a.is_deleted <> 1
	and b.is_deleted <> 1
	and a.type = '31011003'  -- 订单类型：沃世界商城订单
	and a.separate_status = '10041002' -- 拆单状态：否
	and a.status not in ('51031001','51031007') -- 订单状态:剔除预创建和创建失败订单
	AND (a.close_reason not in ('51091001','51091002') or a.close_reason is null) -- 订单关闭原因：去除超时未支付和取消订单，为空的是2017年及之前的订单
	-- and (b.spu_type in (51121001,51121004,51121006,51121007) or (b.spu_type in (51121002,51121003) and a.status<>51031006 )) -- 剔除虚拟商品已关闭订单
	-- and g.order_code is not null  -- 剔除退款订单
) mall on toString(user.id) = toString(mall.user_id)
group by 1,2,3,4,5
order by 6 asc




















