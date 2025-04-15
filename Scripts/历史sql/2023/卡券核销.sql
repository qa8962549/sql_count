SELECT a.id,
a.one_id,
b.id 卡券ID,
b.coupon_name 卡券名称,
a.left_value/100 面额,
b.coupon_code 券号,
a.vin 购买VIN,
a.get_date 获得时间,
a.activate_date 激活时间,
a.expiration_date 卡券失效日期,
a.exchange_code 核销码,
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
LEFT JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
,v.customer_mobile 核销手机号
,v.verify_amount 核销金额
,IFNULL(v.dealer_code,v.`dealer`) 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
,v.order_no 订单号
,v.PLATE_NUMBER
from coupon.tt_coupon_verify v
where v.is_deleted = 0
order by v.create_time
) v ON v.coupon_detail_id = a.id
WHERE v.核销时间 >= '2022-07-01'  
and v.核销时间 <'2022-10-01'   
and a.ticket_state = '31061003'  
and a.is_deleted = 0
-- and a.one_id =7644622
order by v.核销时间 desc


SELECT a.id,
a.one_id,
b.id 卡券ID,
b.coupon_name 卡券名称,
a.left_value/100 面额,
b.coupon_code 券号,
-- tmi.ID 沃世界会员ID,
-- tmi.MEMBER_NAME 会员昵称,
-- tmi.REAL_NAME 姓名,
-- tmi.MEMBER_PHONE 沃世界绑定手机号,
a.vin 购买VIN,
a.get_date 获得时间,
a.activate_date 激活时间,
a.expiration_date 卡券失效日期,
a.exchange_code 核销码,
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
-- left join `member`.tc_member_info tmi on a.one_id = tmi.CUST_ID
LEFT JOIN (
select v.coupon_detail_id
,v.customer_name 核销用户名
,v.customer_mobile 核销手机号
,v.verify_amount 核销金额
,IFNULL(v.dealer_code,v.`dealer`) 核销经销商
,v.vin 核销VIN
,v.operate_date 核销时间
,v.order_no 订单号
,v.PLATE_NUMBER
from coupon.tt_coupon_verify v
where v.is_deleted = 0
order by v.create_time
) v ON v.coupon_detail_id = a.id
WHERE 
-- v.核销时间 >= '2022-07-01'  and v.核销时间 <'2022-10-01'   
-- and a.ticket_state = '31061003'  
a.is_deleted = 0
and b.id in ('2936','3801')
-- and a.one_id =7644622
order by v.核销时间 desc