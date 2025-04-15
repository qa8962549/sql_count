-- 1、【支付1.0】微信支付正向流水
select
a.order_id 订单号,
a.out_trade_no 商户订单号,
a.create_time 支付时间
from payment.tt_payment_record a
where a.is_deleted = 0
and a.result_code = 'SUCCESS'

-- 2、【支付1.0】微信支付退单流水
select
b.order_no 订单号,
b.create_time 退单时间
from payment.tt_refund_record b
where b.is_deleted = 0

-- 3、【支付1.0】拉卡拉流水表
select
c.order_no 订单号,
c.out_trade_no 商户订单号,
case when c.trade_type in ('PAY','APP-PAY') then '支付'
	when c.trade_type in ('REFUND','APP-REFUND') then '退款'
	else null end 交易类型,
c.create_time 交易时间
from payment.tt_lkl_transaction_flow c
where c.is_deleted = 0

-- 4、【支付2.0】正向支付流水
select
d.bus_order_no 订单号,
d.transaction_flow_no 商户订单号,
case when status = 'PAID' then '已支付'
	when status = 'FAIL' then '支付失败'
	when status = 'CANCELED' then '已取消'
	when status = 'PENDING_PAYMENT' then '未支付'
	else null end 支付状态,
d.paid_time 支付时间,
d.create_time 创建时间
from payment.tl_payment_transaction_flow d
where d.is_deleted = 0

-- 5、【支付2.0】退款流水
select
e.bus_order_no,
e.transaction_flow_no 商户订单号,
case when status = 'SUCCESS' then '支付成功'
	when status = 'ABNORMAL' then '支付失败'
	else null end 支付状态,
e.success_time 退款成功时间,
e.refund_create_time 退款创建时间,
e.create_time 创建时间
from payment.tl_refund_transaction_flow e
where e.is_deleted = 0