-- 
SELECT 
DISTINCT 
row_number() over(order by a.create_time) 报名时间顺序,
a.contact_name 客户姓名,
a.phone 客户手机号,
a.create_time 报名时间,
c.place 报名站点,
case when e.IS_VEHICLE = '1' then '是'
	when e.IS_VEHICLE = '0' then '否'
	end 是否车主,
t.车型,
x.开票经销商,
DATE_FORMAT(c.start_time, '%Y-%m-%d') 场次,
c.session_name 场次名称,
a.ex_field_1 意向车型,
case when a.deleted =0 then '报名成功' ELSE '报名失败' END 报名状态,
a.activity_session_code 活动场次code,
now() 取数时间
FROM volvo_online_activity_module.activity_capital_info a
left join volvo_online_activity_module.activity_capital_retention b on a.capital_retention_id =b.id
left JOIN volvo_online_activity_module.activity_session c on c.code = a.activity_session_code 
left join `member`.tc_member_info e on e.id = a.member_id 
left join
	(
	 select v.member_id,v.vin,ifnull(m.MODEL_NAME,v.model_name)车型
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 left join basic_data.tm_model m on t.MODEL_ID=m.ID
	 where v.rk=1
) t on e.id=t.member_id
	left join (
	select 
	    tisd.dealer_code 开票经销商,
	    YEAR(tisd.first_invoice_date) 年,
	    month(tisd.first_invoice_date) 月,
	    tisd.vin 车架号,
	    tisd.resource 发票来源,
	    tisd.salesType Vista销售类型,
	    date_format(tisd.first_invoice_date,'%Y-%m-%d') 开票时间
	from vehicle.tt_invoice_statistics_dms tisd
	where tisd.IS_DELETED = 0
) x on x.车架号 =t.vin
WHERE 1=1
and e.MEMBER_STATUS <> 60341003 and e.IS_DELETED <>1
-- and a.phone ='13687678323'
and a.create_time >='2023-02-01'
and a.create_time <now()
and c.placeOfTime in ('昆明 2.04-2.05',
'青岛 2.04-2.05',
'广州 2.11-2.12',
'西安 2.18-2.19',
'长沙 2.25-2.26',
'重庆 2.25-2.26',
'无锡 3.18-3.19',
'南京 3.11-3.12')
order by 4 desc 
-- group by 1