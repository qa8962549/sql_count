###############################   推荐购周报_每周一   ###############################
# 每周修改下时间，跑数后贴在隐藏的2个Sheet中即可，修改下Sheet1时间即可

# 一店一码扫码
select
l.qr_code_id,
count(1)PV,
count(DISTINCT l.open_id) UV
from volvo_wechat_live.es_qr_code_logs l 
where l.create_time >= '2022-08-01'    -- 每周修改时间
and l.create_time <= '2022-08-07 23:59:59'  	-- 每周修改时间
and l.qr_code_id in
(
	# 提取并去重长度为3的经销商CODE
	select DISTINCT d.qr_code_id
	from volvo_wechat_live.es_dealer_qrcode d 
	where LENGTH(d.campaign) = 3   -- 筛选长度为3的经销商CODE
) 
GROUP BY 1 order by 2 desc;


# 留资数据
select
	r.dealer_code 经销商代码,
	count(case when r.intent_car_code='536' then 1 else null end) XC40,
	count(case when r.intent_car_code='536ED' then 1 else null end) XC40bev,
	count(case when r.intent_car_code='246' then 1 else null end) XC60,
	count(case when r.intent_car_code='256' then 1 else null end) XC90,
	count(case when r.intent_car_code='224' then 1 else null end) S60,
	count(case when r.intent_car_code='238' then 1 else null end) S90,
	count(case when r.intent_car_code='225' then 1 else null end) V60,
	count(case when r.intent_car_code='236' then 1 else null end) V90,
	count(case when r.intent_car_code='539' then 1 else null end) C40
from volvo_online_activity.recommend_buyv6_invite_record r    -- 推荐购邀请人、被邀请人留资、试驾、购车数据表
where r.create_time >= '2022-08-01'    -- 邀请人邀请时间
and r.create_time <= '2022-08-07 23:59:59'
and r.period = '2022q3'    -- 限制推荐购活动为22Q3
GROUP BY 1;


# 试驾数据
select
	r.dealer_code 经销商代码,
	count(case when r.试驾车型='XC40' then 1 else null end) XC40,
	count(case when r.试驾车型='XC40bev' then 1 else null end) XC40bev,
	count(case when r.试驾车型='XC60' then 1 else null end) XC60,
	count(case when r.试驾车型='XC90' then 1 else null end) XC90,
	count(case when r.试驾车型='S60' then 1 else null end) S60,
	count(case when r.试驾车型='S90' then 1 else null end) S90,
	count(case when r.试驾车型='V60' then 1 else null end) V60,
	count(case when r.试驾车型='V90' then 1 else null end) V90,
	count(case when r.试驾车型='C40' then 1 else null end) C40
from
(
	select r.dealer_code,
	case when r.test_drive_car='全新纯电C40' then 'C40'
		when r.test_drive_car='XC40 RECHARGE' then 'XC40bev'
		when r.test_drive_car='V90 Cross Country' then 'V90'
		else r.test_drive_car end 试驾车型
	from volvo_online_activity.recommend_buyv6_invite_record r    -- 推荐购邀请人、被邀请人留资、试驾、购车数据表
	where r.test_drive_status = 'Y'     -- 是否试驾 Y:已试驾   N：未试驾
	and r.create_time >= '2022-08-01'
	and r.create_time <= '2022-08-07 23:59:59'
	and r.period = '2022q3'    -- 限制推荐购活动为22Q3
) r
GROUP BY 1;