-- 查验【有退款流水但是没有逆向退单】
-- 退款时间没有、退款状态只选退款成功的订单、核查金额是否一致、逻辑删除是否正常
select distinct *
from 
(-- 支付2.0现金退款流水
	select 
	distinct 
	a.bus_order_no,
	a.transaction_flow_no,
	a.business_refund_no 业务线现金退款幂等退款单号, 
	a.refund/100 "退款金额(元)"
	,a.plat_success_time 
	from payment.tl_refund_transaction_flow a
	inner join payment.tl_payment_transaction_flow b on a.payment_transaction_flow_no = b.transaction_flow_no
	where 1=1
	and a.is_deleted = 0
	and a.status = 'SUCCESS'   -- 退款成功
	and b.payment_product in ('lakala-alipay_method-User_Scan','lakala-weixin_method-Mini_Program')   -- 现金退款
	and a.bus_order_no='673235556724'
--	and a.transaction_flow_no in ('86021000217219866699016062',
--'86021000217222742090583196',
--'86021000217222742170341507',
--'86021000217227062092958272',
--'86021000217235702089478645',
--'86021000217235703363822878',
--'86021000217235703384911977',
--'86021000217235703407364230',
--'86021000217238294084589511',
--'86021000217239158094839845',
--'86021000217240022091468814',
--'86021000217244342090393758',
--'86021000217245206093253511')
)a
left join
(-- 退单表
	select so.refund_order_code 退货单号,ifnull(so.refund_time,so.point_refund_time) 实际退款时间
	,case when so.status=51171001 then '待审核' when so.status=51171002 then '待退货入库'
		when so.status=51171003 then '待退款' when so.status=51171004 then '退款成功'
		when so.status=51171005 then '退款失败' when so.status=51171006 then '作废退货单' end as 退货状态,so.is_deleted,sp.is_deleted
	from `order`.tt_sales_return_order_product sp 
	left join `order`.tt_sales_return_order so on so.refund_order_code = sp.refund_order_code
)b on b.退货单号 = a.业务线现金退款幂等退款单号
order by 2



-- 正向订单核查  看一下关闭原因是什么
SELECT x.order_code ,
x.parent_order_code ,
x.is_deleted,
x.type,
x.status,
x.close_reason,
x.pay_fee/100 金额
FROM "order".tt_order x
WHERE order_code in (
	select bus_order_no
	from payment.tl_payment_transaction_flow x
	where transaction_flow_no in 
	(
--	'88021000217219598718342836',
	'88021000217219631173115623'
	)
	group by bus_order_no
)


select order_no ,payer_amount/100 ,refund_amount/100 ,is_deleted ,create_time 
from payment.tt_lkl_transaction_flow 
where order_no = '673235556724'

select order_code ,status 
	,refund_fee/100 ,refund_time 
	,refund_point_fee ,point_refund_time 
	,is_deleted ,create_time
from "order".tt_sales_return_order so
where so.order_code = '673235556724'


