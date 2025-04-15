-- 用户绑车
 select r.VIN
 ,r1.车主绑车人数
 ,r1.车主绑车次数
 ,r2.亲友绑车人数
 ,r2.亲友绑车次数
 from 
	 (
	 select distinct r.vin_code VIN
	 from volvo_cms.vehicle_bind_relation r
	 where 1=1
	 and r.bind_date>= curdate() - interval '1 year'
	 and r.deleted=0
	 and r.is_bind = 1 
	  )r
left join 
	 (
	 select r.vin_code VIN
	 ,count(distinct r.member_id)车主绑车人数
	 ,count(r.member_id) 车主绑车次数
	 from volvo_cms.vehicle_bind_relation r
	 where 1=1
	 and r.bind_date>= curdate() - interval '1 year'
	 and r.deleted=0
	 and r.is_bind = 1 
	 and r.is_owner =1 -- chezhu
	 group by 1
	  )r1 on r1.vin=r.vin
left join 
	 (
	 select r.vin_code VIN
	 ,count(distinct r.member_id)亲友绑车人数
	 ,count(r.member_id) 亲友绑车次数
	 from volvo_cms.vehicle_bind_relation r
	 where 1=1
	 and r.bind_date>= curdate() - interval '1 year'
	 and r.deleted=0
	 and r.is_bind = 1 
	 and r.is_owner =0 -- not chezhu
	 group by 1
	  )r2 on r2.vin=r.vin
