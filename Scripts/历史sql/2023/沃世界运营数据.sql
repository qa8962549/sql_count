-- l  小程序2019年底用户量，车主占比%和粉丝占比%
select 
case when m.IS_VEHICLE = '1' then '车主'
	when m.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
count(m.id)
from `member`.tc_member_info m
where m.CREATE_TIME <'2020-01-01'
and m.member_status<>60341003 
and m.is_deleted=0
group by 1 with rollup
order by 1

-- l  小程序2020年底用户量，车主占比%和粉丝占比%
select 
case when m.IS_VEHICLE = '1' then '车主'
	when m.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
count(m.id)
from `member`.tc_member_info m
where m.CREATE_TIME <'2021-01-01'
and m.member_status<>60341003 
and m.is_deleted=0
group by 1 with rollup
order by 1

-- l  小程序粉丝月活量、车主月活量；App粉丝月活量、车主月活量
SELECT DATE_FORMAT(t.date,'%Y-%m'),
count(DISTINCT case when tmi.IS_VEHICLE =1 then tmi.id end) 车主数量,
count(DISTINCT case when tmi.IS_VEHICLE =0 then tmi.id end) 粉丝数量
FROM track.track t 
JOIN MEMBER.tc_member_info tmi ON cast(tmi.USER_ID AS varchar) = t.usertag
WHERE 
-- t.date between '2022-10-27' AND '2022-11-30 23:59:59'
-- WHERE t.date between DATE_SUB(CURDATE(),INTERVAL 7 DAY) AND CURDATE()
  t.date > tmi.member_time
    AND tmi.IS_DELETED = 0 
    AND tmi.MEMBER_STATUS <> 60341003
GROUP BY 1 -- with rollup
order by 1

-- l  小程序&App活跃车主重合度%、小程序&App活跃粉丝重合度%


-- l  小程序已试驾留资，但未到店的粉丝量
-- 预约试驾
-- 1 预约试驾
SELECT 
count(1) 预约试驾提交数
,count(case when a.预约状态<>'已到店' and a.is_vehicle=0 then 1 else null end ) 已试驾留资但未到店的粉丝量
-- ,count(case when a.预约状态='已到店' then 1 else null end ) 到店人数
-- ,count(case when a.预约状态='已到店' and a.订单状态 is not null then 1 else null end ) 订单数
FROM(
	SELECT DISTINCT ta.APPOINTMENT_ID
	,ta.OWNER_CODE 经销商
	,ta.ONE_ID
	,CAST(ta.CUSTOMER_BUSINESS_ID AS varchar) 商机ID
	,cast(ta.POTENTIAL_CUSTOMERS_ID AS varchar) 潜客ID
	,ta.CUSTOMER_NAME 姓名
	,ta.CUSTOMER_PHONE 手机号
	,tc.CODE_CN_DESC 预约状态
	,ta.DATA_SOURCE
	,ta.CREATED_AT
	,ta.IS_DELETED
	,ta.INVITATIONS_DATE 预计到店日期
	,ta.ARRIVAL_DATE 实际到店日期
	,tso.CREATED_AT 订单日期
	,tc1.CODE_CN_DESC 订单状态
	,m.IS_VEHICLE 
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN (
		# 车辆订单
		SELECT *,ROW_NUMBER() over(PARTITION BY CUSTOMER_BUSINESS_ID,CUSTOMER_ACTIVITY_ID ORDER BY CREATED_AT DESC) rk
		FROM cyxdms_retail.tt_sales_orders
		WHERE IS_DELETED = 0 
		AND SO_STATUS IN (14041002,14041003,14041008,14041011)
	) tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID AND tso.created_at > ta.CREATED_AT 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS 
	left join `member`.tc_member_info m on m.CUST_ID =ta.ONE_ID and m.member_status<>60341003 and m.is_deleted=0
	WHERE 
-- 	ta.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
	 ta.APPOINTMENT_TYPE = 70691002
	AND ta.DATA_SOURCE = 'C'
) a ;


-- l  2020、2021、2022年每年通过小程序试驾留资并转化成订单数

SELECT 
DATE_FORMAT(a.CREATED_AT,'%Y')
,count(a.CUSTOMER_BUSINESS_ID) 预约试驾提交数
-- ,count(case when a.预约状态<>'已到店' and a.is_vehicle=0 then 1 else null end ) 已试驾留资但未到店的粉丝量
-- ,count(case when a.预约状态='已到店' then 1 else null end ) 到店人数
-- ,count(case when a.预约状态='已到店' and a.订单状态 is not null then 1 else null end ) 订单数
FROM(
	SELECT DISTINCT ta.APPOINTMENT_ID
	,ta.OWNER_CODE 经销商
	,ta.ONE_ID
	,CAST(ta.CUSTOMER_BUSINESS_ID AS varchar) 商机ID
	,cast(ta.POTENTIAL_CUSTOMERS_ID AS varchar) 潜客ID
	,ta.CUSTOMER_NAME 姓名
	,ta.CUSTOMER_PHONE 手机号
	,tc.CODE_CN_DESC 预约状态
	,ta.DATA_SOURCE
	,ta.CREATED_AT
	,ta.IS_DELETED
	,ta.INVITATIONS_DATE 预计到店日期
	,ta.ARRIVAL_DATE 实际到店日期
	,tso.CREATED_AT 订单日期
	,tso.CUSTOMER_BUSINESS_ID
	,tc1.CODE_CN_DESC 订单状态
	,m.IS_VEHICLE 
	FROM cyx_appointment.tt_appointment ta
	LEFT JOIN dictionary.tc_code tc ON tc.CODE_ID = ta.IS_ARRIVED
	LEFT JOIN (
		# 车辆订单
		SELECT *,ROW_NUMBER() over(PARTITION BY CUSTOMER_BUSINESS_ID,CUSTOMER_ACTIVITY_ID ORDER BY CREATED_AT DESC) rk
		FROM cyxdms_retail.tt_sales_orders
		WHERE IS_DELETED = 0 
		AND SO_STATUS IN (14041002,14041003,14041008,14041011)
	) tso ON tso.CUSTOMER_BUSINESS_ID = ta.CUSTOMER_BUSINESS_ID AND tso.created_at > ta.CREATED_AT 
	LEFT JOIN dictionary.tc_code tc1 ON tc1.CODE_ID = tso.SO_STATUS 
	left join `member`.tc_member_info m on m.CUST_ID =ta.ONE_ID and m.member_status<>60341003 and m.is_deleted=0
	WHERE 
-- 	ta.CREATED_AT BETWEEN '2022-08-22' AND '2022-08-28 23:59:59'
	 ta.APPOINTMENT_TYPE = 70691002
	AND ta.DATA_SOURCE = 'C'
) a group by 1
order by 1

select 
DATE_FORMAT(x.订单时间,'%Y'),
count(x.商机id)
from 
(
	select a.CUSTOMER_BUSINESS_ID 商机id ,max(a.CREATED_AT) 订单时间
	from cyxdms_retail.tt_sales_orders a 
	left join dictionary.tc_code g on g.code_id = a.SO_STATUS
	where a.BUSINESS_TYPE<>14031002
	and a.IS_DELETED = 0
-- 	and a.CREATED_AT BETWEEN '2022-10-01 00:00:00' and '2022-10-31 23:59:59'
	and g.code_cn_desc in ('提交待审批','审批通过','已交车','退车中')
	GROUP BY 1 
)x group by 1
order by 1