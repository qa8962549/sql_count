
-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select 
 case when x.购车年龄<3 then 1
 	when x.购车年龄>=3 and x.购车年龄<5 then 2
 	when x.购车年龄>=5 and x.购车年龄<8 then 3
  	when x.购车年龄>=8 and x.购车年龄<10 then 4
  	when x.购车年龄>=10 and x.购车年龄<12 then 5
  	when x.购车年龄>=12 and x.购车年龄<15 then 6
  	when x.购车年龄>=15 then 7
  	end as '标签值',
  	count(1)
 from 
	 (
	 select 
	 tmi.MEMBER_PHONE a,
	 timestampdiff(year,t.INVOICE_DATE,curdate()) 购车年龄
	 from (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v 
	 left join vehicle.tm_vehicle t on v.vin=t.VIN
	 join `member`.tc_member_info tmi on tmi.id=v.member_id
	 where v.rk=1
	 ) x
group by 1 
order by 1
 
-- 近30内留资次数
select 
case when x.aa=1 then 1
	when x.aa=2 then 2
	when x.aa>=3 then 3
	end as '标签值',
	count(1) 数量
from 
	(	
	select 
	DISTINCT a.mobile a,
	b.SHOP_NUMBER aa
	from customer.tt_clue_info a
	left join customer_business.tt_customer_business b on b.customer_business_id = a.business_id 
	where a.is_deleted =0
	and LENGTH(a.mobile)=11
	and left(a.mobile,1)='1'
	and a.create_time >=DATE_SUB(curdate(),INTERVAL 30 day) 
)x 
group by 1
order by 1

-- 近30内到店次数
select 
case when x.aa=1 then 1
	when x.aa=2 then 2
	when x.aa>=3 then 3
	end as '标签值',
	count(1) 数量
from 
	(	
	select a.mobile a,
	count(1) aa
	from customer.tt_clue_info a
	where a.is_deleted =0
	and LENGTH(a.mobile)=11
	and left(a.mobile,1)='1'
	and a.create_time >=DATE_SUB(curdate(),INTERVAL 30 day) 
	group by 1
)x 
group by 1
order by 1