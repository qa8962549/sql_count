-- 预约试驾
select
DISTINCT 
tmi.REAL_NAME 试驾人姓名,
tmi.MEMBER_NAME 会员姓名,
tmi.ID 会员ID,
tmi.MEMBER_PHONE 会员手机号,
case when tmi.MEMBER_SOURCE='60511001' then '小程序'
	when tmi.MEMBER_SOURCE='60511001' then'APP'
	else null end as 会员首次注册来源,
tmi.CREATE_TIME 会员注册时间,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
t.create_time 会员最新绑车时间,
p.drive_e_at 最新试驾完成时间
from  `member`.tc_member_info tmi 
join 
	(select p.mobile,
	p.drive_e_at,
	row_number() over(PARTITION by p.mobile order by p.drive_e_at desc) rk
	from `drive-service`.tt_testdrive_plan p 
	where p.drive_e_at >= '2023-03-01'
	and p.drive_e_at< '2023-04-25'
	and p.is_deleted=0
)p on p.MOBILE =tmi.MEMBER_PHONE and p.rk=1
left join
	(
	# 车系
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型,v.create_time
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) t on tmi.id=t.member_id
where 1=1
-- and p.CREATED_AT >= '2023-03-01'
-- and p.CREATED_AT< '2023-04-25'
and tmi.IS_DELETED =0
and p.MOBILE is not null 

# 试驾工单表，用户是否试驾数据
select
*
from `drive-service`.tt_testdrive_plan p      -- 试驾工单表（只要数据存在，那么就算这个人试驾了。）
where p.DRIVE_S_AT >= '2021-10-01'    -- 试驾开始时间
and p.DRIVE_S_AT <= '2021-10-31 23:59:59'
and p.IS_DELETED = 0