
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
and r.create_time >= '2022-10-01'
and r.create_time <= '2023-05-17 23:59:59'
order by r.create_time



-- 22Q4之前推荐购成功购车数
-- 推荐购 22Q2、22Q3
SELECT
m.member_name 推荐人姓名
,m.member_phone 推荐人手机号
,m.id 推荐人mmberid
,v.vin 推荐人VIN
,r.invitee_name 被推荐人姓名
,r.invitee_member_id 被推荐人memberid
,r.phone 被推荐人留资手机号
,r.province  被推荐人省份
,r.city  被推荐人城市
,d.simple_name 被推荐人意向经销商
,r.dealer_code 经销商代码
,r.intent_car 意向车型
,t.invitations_date 预约日期
,r.create_time 被推荐人留资时间
,rr.phone 手机号
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end 领券状态
,c.*
-- 获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record r 
-- 获取推荐人信息
left join member.tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
left join (
	--匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from member.tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id::VARCHAR=m.id::VARCHAR
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left JOIN(
	-- 核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer 核销经销商
	,replace(json_extract_path_text(cast(t.other_info as json),'$.new_car_buyer'),'"','') 核销用户名
	,m.member_phone 核销手机号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_vincode'),'"','') 新车车架号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_carmodel'),'"','') 新车车型
	,t.operate_date 微信核销时间
	from "coupon".tt_coupon_verify t
	join(
		--one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status <> 60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid = m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id in ('3420','3652')     -- 22Q2、Q3卡券ID
    and t.create_time < CURDATE()
	order by t.operate_date desc
) c on c.coupon_detail_id::VARCHAR=rr.coupon_id::VARCHAR
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where c.核销经销商 is not null
union all
-- 推荐购 22Q1
SELECT
m.member_name 推荐人姓名
,m.member_phone 推荐人手机号
,m.id 推荐人mmberid
,v.vin 推荐人VIN
,r.invitee_name 被推荐人姓名
,r.invitee_member_id 被推荐人memberid
,r.phone 被推荐人留资手机号
,r.province  被推荐人省份
,r.city  被推荐人城市
,d.simple_name 被推荐人意向经销商
,r.dealer_code 经销商代码
,r.intent_car 意向车型
,t.invitations_date 预约日期
,r.create_time 被推荐人留资时间
,rr.phone 手机号
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end 领券状态
,c.*
--获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record_2022q1 r 
--获取推荐人信息
left join "member".tc_member_info m on m.id=r.inviter_member_id and m.is_deleted=0 and m.member_status<>60341003
left join (
	--匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from member.tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id::VARCHAR=m.id::VARCHAR
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left JOIN(
	--核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer 核销经销商
	,replace(json_extract_path_text(cast(t.other_info as json),'$.new_car_buyer'),'"','') 核销用户名
	,m.member_phone 核销手机号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_vincode'),'"','') 新车车架号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_carmodel'),'"','') 新车车型
	,t.operate_date 微信核销时间
	from "coupon".tt_coupon_verify t 
	join(
		--one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status<>60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid=m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id = '3135'     -- 22Q1卡券ID
	-- 推荐人推荐被推荐人购车，被推荐人会领取一张新人礼包券，推荐购每季度卡券ID不同，需要找业务要
	-- 21年Q1 : 2812,2827,2828
	-- 21年Q2 : 2837,2838
	-- 21年Q3 : 2920
	-- 21年Q4 : 2949
	-- 22年Q1 : 3135
	-- 22年Q2 : 3420
    and t.create_time < CURDATE()
	order by t.operate_date desc
) c on c.coupon_detail_id::VARCHAR=rr.coupon_id::VARCHAR
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where c.核销经销商 is not null
union all
-- 推荐购 21Q4
SELECT
m.member_name 推荐人姓名
,m.member_phone 推荐人手机号
,m.id 推荐人mmberid
,v.vin 推荐人VIN
,r.invitee_name 被推荐人姓名
,r.invitee_member_id 被推荐人memberid
,r.phone 被推荐人留资手机号
,r.province  被推荐人省份
,r.city  被推荐人城市
,d.simple_name 被推荐人意向经销商
,r.dealer_code 经销商代码
,r.intent_car 意向车型
,t.invitations_date 预约日期
,r.create_time 被推荐人留资时间
,rr.phone 手机号
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end 领券状态
,c.*
-- 获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record_2021q4 r 
--获取推荐人信息
left join "member".tc_member_info m on m.id::VARCHAR=r.inviter_member_id::VARCHAR and m.is_deleted=0 and m.member_status<>60341003
left join (
	--匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from "member".tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id::VARCHAR=m.id::VARCHAR
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left JOIN(
	--核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer 核销经销商
	,replace(json_extract_path_text(cast(t.other_info as json),'$.new_car_buyer'),'"','') 核销用户名
	,m.member_phone 核销手机号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_vincode'),'"','') 新车车架号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_carmodel'),'"','') 新车车型
	,t.operate_date 微信核销时间
	from "coupon".tt_coupon_verify t
	join(
		--one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status<>60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid=m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id = '2949'     -- 21Q4卡券ID
    and t.create_time < CURDATE()
	order by t.operate_date desc
) c on c.coupon_detail_id::VARCHAR=rr.coupon_id::VARCHAR
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where c.核销经销商 is not null
union all 
-- 推荐购 21Q3
SELECT
m.member_name 推荐人姓名
,m.member_phone 推荐人手机号
,m.id 推荐人mmberid
,v.vin 推荐人VIN
,r.invitee_name 被推荐人姓名
,r.invitee_member_id 被推荐人memberid
,r.phone 被推荐人留资手机号
,r.province  被推荐人省份
,r.city  被推荐人城市
,d.simple_name 被推荐人意向经销商
,r.dealer_code 经销商代码
,r.intent_car 意向车型
,t.invitations_date 预约日期
,r.create_time 被推荐人留资时间
,rr.phone 手机号
,case when rr.member_id is null then '未领券/不符合SMM条件' else '发送成功' end 领券状态
,c.*
--获取推荐记录
from volvo_online_activity.recommend_buyv6_invite_record_bakqthired r 
--获取推荐人信息
left join "member".tc_member_info m on m.id::VARCHAR=r.inviter_member_id::VARCHAR and m.is_deleted=0 and m.member_status<>60341003
left join (
	--匹配推荐人VIN(取最近绑定VIN)
	select a.*
	from(
		select v.*,row_number() over(partition by v.member_id order by v.create_time desc ) rk
		from member.tc_member_vehicle v
		where v.is_deleted=0 ) a 
	where a.rk=1 
) v on v.member_id::VARCHAR=m.id::VARCHAR
left join volvo_online_activity.recommend_buyv6_reward_record rr on rr.reward_invite_id=r.id and rr.reward_type='00'
left join volvo_online_activity.recommend_buyv6_dealer d on r.dealer_code=d.code
left join
(	-- 核销信息
	select --  t.coupon_id,
	m.id member_id,m.member_name username,t.coupon_detail_id
	,t.dealer 核销经销商
	,replace(json_extract_path_text(cast(t.other_info as json),'$.new_car_buyer'),'"','') 核销用户名
	,m.member_phone 核销手机号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_vincode'),'"','') 新车车架号
	,replace(json_extract_path_text(cast(t.other_info as json),'$.newcar_carmodel'),'"','') 新车车型
	,t.operate_date 微信核销时间
	from "coupon".tt_coupon_verify t
	join(
		--one_id与memberid一对多,取最近的memberid
		select m.*
		from(
		select m.CUST_ID,max(m.ID) mid
		from member.tc_member_info m 
		where m.member_status<>60341003 and m.is_deleted=0
		GROUP BY 1) a
		left join member.tc_member_info m on a.mid=m.ID
	)m on m.cust_id =t.customer_id 
	where t.coupon_id = '2920'     -- 21Q3卡券ID
    and t.create_time < CURDATE()
	order by t.operate_date desc
) c on c.coupon_detail_id::VARCHAR=rr.coupon_id::VARCHAR
left join cyx_appointment.tt_appointment t on r.test_drive_id=t.appointment_id
where c.核销经销商 is not null


