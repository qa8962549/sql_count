
# 购车时间在2021.8.1~2022.5.30
# 的全部XC40 BEV车主，及同时段6000名XC60车主及6000名S90车主

# 购车时间在2021.8.1~2022.5.30
# 的全部XC40 BEV车主，及同时段6000名XC60车主及6000名S90车主
select
	a.config_year 年款,
	tv.MODEL_NAME 车型,
	a.first_invoice_date 开票时间,
	b.auth_type 客户类型,
	case when tmi.member_sex = '10021001' then '先生'
		 when tmi.member_sex = '10021002' then '女士'
		 else '未知' end 性别,
	tmi.MEMBER_PHONE 车主手机号,
	tmi.MEMBER_EMAIL 车主邮箱
from vehicle.tm_vehicle tv	
join vehicle.tt_invoice_statistics_dms a on tv.VIN = a.vin 
left join volvo_cms.vehicle_owner_auth_detail b on tv.vin=b.vin_code 
left join member.tc_member_info tmi on tv.CUSTOMER_ID = tmi.CUST_ID 
where a.first_invoice_date >='2021-8-1 00:00:00' 
and a.first_invoice_date <='2022-5-30 23:59:59'
and tv.MODEL_NAME='S90'
and	tmi.IS_VEHICLE = 1 
and tmi.IS_DELETED = 0
and b.auth_type = 60421001 -- 个人认证 私人用户    60421002企业认证
order by 3 desc 
limit 6000


-- 匹配手机号
select
a.VIN,
a.buy_name 购车人姓名,
a.config_year 车辆年款,
b.MODEL_NAME 车辆型号,
a.first_invoice_date 购车时间,
d.CODE_CN_DESC 客户类型,
e.B2C姓名,
e.B2C手机号,
f.member_id,
f.phone,
g.MEMBER_PHONE,
g.MEMBER_NAME,
g.REAL_NAME,
g.MEMBER_EMAIL
from vehicle.tt_invoice_statistics_dms a
left join basic_data.tm_model b on a.model_code = b.MODEL_CODE 
left join volvo_cms.vehicle_owner_auth_detail c on a.vin = c.vin_code
left join dictionary.tc_code d on c.auth_type = d.CODE_ID
left join
(
	-- CDB B2C数据
	SELECT 
	x.VIN,
	IF (x.手机号 is not null, x.姓名, a.姓名) B2C姓名,
	-- CASE WHEN x.手机号 IS not NULL THEN x.手机号 else a.手机号 END ,
	IF (x.手机号 is not null, x.手机号, a.手机号) B2C手机号,
	IF (x.手机号 is not null, x.Relationship_Type, a.Relationship_Type) Relationship_Type,
	IF (x.手机号 is not null, x.Relationship_Start_Date, a.Relationship_Start_Date) Relationship_Start_Date
	FROM (
	SELECT 
		ccoad.CDB_ID,
		CONCAT(ccoad.Last_Name,ccoad.First_Name) 姓名,
		ccoad.Mobile_Phone_num 手机号,
		ccoad.VIN ,
		cdr.Dealer_Number,
		cdr.Dealer_Name,
		ccoad.Relationship_Type,
		ccoad.Relationship_Start_Date,
		ROW_NUMBER() OVER(PARTITION BY ccoad.VIN ORDER BY ccoad.Relationship_Type DESC, ccoad.Relationship_Start_Date DESC) AS rk
	FROM customer.contacts_customers_owns_and_drives ccoad 
	LEFT JOIN customer.contacts_dealer_relation cdr ON cdr.CDB_ID = ccoad.CDB_ID 
	WHERE -- ccoad.Telephone <> 'Negative'
		  ccoad.SMS <> 'Negative') x
	LEFT JOIN (
				SELECT y.*
				FROM (
				SELECT 
					ccoad2.CDB_ID,
					CONCAT(ccoad2.Last_Name,ccoad2.First_Name) 姓名,
					ccoad2.Mobile_Phone_num 手机号,
					ccoad2.VIN 车架号,
					cdr2.Dealer_Number,
					cdr2.Dealer_Name,
					ccoad2.Relationship_Type,
					ccoad2.Relationship_Start_Date,
					ROW_NUMBER() OVER(PARTITION BY ccoad2.VIN ORDER BY ccoad2.Relationship_Start_Date DESC) AS rs
				FROM customer.contacts_customers_owns_and_drives ccoad2
				LEFT JOIN customer.contacts_dealer_relation cdr2 ON cdr2.CDB_ID = ccoad2.CDB_ID 
				WHERE ccoad2.Relationship_Type = 'Drives'
					  -- and ccoad2.Telephone <> 'Negative'
					  AND ccoad2.SMS <> 'Negative') y
				WHERE y.rs = 1
				) a ON a.车架号 = x.VIN  
	WHERE x.rk = 1
	and x.Relationship_Type = 'Owns'
)e on a.vin = e.VIN
left join
(
	select
	f.vin_code,
	f.member_id,
	f.phone
	from volvo_cms.vehicle_bind_record f
	where f.event_type = 1   -- 绑定
	and f.is_owner = 1   -- 车主
	and f.deleted = 0
)f on a.vin = f.vin_code
left join `member`.tc_member_info g on f.member_id = g.ID
where a.first_invoice_date >= '2021-08-01'
and a.first_invoice_date <= '2022-05-30 23:59:59'
and c.auth_type = 60421001 -- 个人认证 私人用户    60421002企业认证
and b.MODEL_NAME in ('XC40 RECHARGE','XC60','S90')
and a.IS_DELETED = 0
order by a.first_invoice_date