SELECT a.CUST_ID 
,case when a.IS_VEHICLE =1 then'车主' end as 车主身份
,a.MEMBER_PHONE 
from `member`.tc_member_info a
where a.IS_VEHICLE =1

select a.id,a.MEMBER_NAME 姓名,a.MEMBER_PHONE 
from track.track t 
left join `member`.tc_member_info a on cast(a.USER_ID as varchar) = t.usertag 
where json_extract(t.data,'$.embeddedpoint')='memberDay9_home_即刻加入瓜分_click'

select a.id,a.MEMBER_NAME 姓名,a.MEMBER_PHONE 手机号
from `member`.tc_member_info a
where cast(a.USER_ID as varchar) in (
select t.usertag 
from track.track t 
where json_extract(t.data,'$.embeddedpoint')='memberDay9_home_即刻加入瓜分_click')

select decode(a.IS_VEHICLE,1,'车主','粉丝'),count(1)
from `member`.tc_member_info a
group by 1


-- 截至9月29日18时，会员日优惠券未使用的用户  9-4-1
select DISTINCT x.沃世界绑定手机号
FROM 
(
SELECT
		a.id,
		a.one_id,
		b.id coupon_id,
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
		and v.operate_date >= '2022-09-25'
		and v.operate_date <= '2022-09-29 14:00:00' -- 核销时间
		order by v.create_time 
		) v ON v.coupon_detail_id = a.id
		WHERE a.coupon_id in ('3906','3905','3907')  -- 9月 
		and a.get_date >= '2022-09-25'
		and a.get_date <= '2022-09-29 14:00:00'
		and a.ticket_state='31061001' -- 已领用
		and a.is_deleted = 0 
		order by a.get_date
)x 
where LENGTH(x.沃世界绑定手机号)=11 and `LEFT`(x.沃世界绑定手机号,1)='1'


-- 10-1-1 9月15日~9月30日新注册会员
select 
DISTINCT m.手机号
from 
(
 select
 m.id 会员ID,
 m.create_time 注册时间,
 m.MEMBER_PHONE 手机号
 from member.tc_member_info m 
 where m.CREATE_TIME >= '2022-09-15'
 and m.CREATE_TIME <= '2022-09-30 9:00:00'
 and m.IS_DELETED = 0
 and m.MEMBER_STATUS <> 60341003
 order by m.create_time desc
)m
where LENGTH(m.手机号) = 11 and left(m.手机号,1) = '1' -- 排除无效手机号
and m.手机号 not in (select DISTINCT x.沃世界绑定手机号
FROM 
(
SELECT
		a.id,
		a.one_id,
		b.id coupon_id,
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
		and v.operate_date >= '2022-09-25'
		and v.operate_date <= '2022-09-29 14:00:00' -- 核销时间
		order by v.create_time 
		) v ON v.coupon_detail_id = a.id
		WHERE a.coupon_id in ('3906','3905','3907')  -- 9月 
		and a.get_date >= '2022-09-25'
		and a.get_date <= '2022-09-29 14:00:00'
		and a.ticket_state='31061001' -- 已领用
		and a.is_deleted = 0 
		order by a.get_date
)x 
where LENGTH(x.沃世界绑定手机号)=11 and `LEFT`(x.沃世界绑定手机号,1)='1')