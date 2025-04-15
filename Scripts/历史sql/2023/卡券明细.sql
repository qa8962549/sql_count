select 
f.*,
e.ticket_state 最新卡券状态,
e.get_date 卡券最新获得时间,
e.expiration_date 卡券最新失效时间
from (select 
c.卡券ID,
c.卡券名称,
c.面额,
c.券号,
group_concat(distinct c.卡券来源) 卡券来源,
group_concat(distinct c.卡券状态) 卡券状态，
c.creator 卡券创建人
from (SELECT b.id 卡券ID,
b.coupon_name 卡券名称,
a.left_value/100 面额,
b.coupon_code 券号,
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
b.creator
FROM coupon.tt_coupon_detail a
JOIN coupon.tt_coupon_info b ON a.coupon_id = b.id
WHERE a.is_deleted=0  -- 剔除无效记录
group by 1,2,3,4,5,6)c
group by 1,2,3,4)f
left join (select d.* from
(select a.coupon_id,
CASE a.ticket_state
        WHEN 31061001 THEN '已领用'
        WHEN 31061002 THEN '已锁定'
        WHEN 31061003 THEN '已核销'
        WHEN 31061004 THEN '已失效'
        WHEN 31061005 THEN '已作废'
END AS ticket_state,
a.create_time,
a.get_date,
a.expiration_date,
row_number()over(partition by coupon_id order by create_time desc) rk
from coupon.tt_coupon_detail a)d
where d.rk= 1)e
on f.卡券ID = e.coupon_id