SELECT 
distinct tmi.level_id ,
tmi.id,
a.vin `上门取车VIN`,
if(a.id is not null ,'是','否') 是否使用过上门取送车
FROM "member".tc_member_info tmi
left join `order`.tt_vehicle_deliver a on a.customer_one_id=tmi.cust_id and a.is_deleted=0 and a.order_status > '82721005' -- 剔除订单状态 取消、待确认、待接单
where 1=1
and tmi.level_id =4 -- 黑卡用户
and tmi.is_deleted =0
and tmi.is_vehicle=1 -- 车主
order by 2 