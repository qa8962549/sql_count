-- ICUP车架号匹配当前绑定车主ONE ID & Member ID
select v.VIN
,if(m.IS_VEHICLE='1','是','否') 车辆是否绑车
,m.cust_id oneID
,v.member_id memberID
from 
	(
	 #获取全量VIN
	 select v.*
	 from (
	   select v.MEMBER_ID,v.VIN
	   ,row_number() over(partition by v.vin order by v.create_time desc) rk
	   from member.tc_member_vehicle v 
	   where v.is_deleted=0 and v.MEMBER_ID is not null
	 ) v
	 where v.rk=1 
	) v
left join member.tc_member_info m on v.member_id=m.id
order by 1


-- 会员最新绑定VIN
select v.*
 from (
   select v.MEMBER_ID,v.VIN,tmi.CUST_ID 
   ,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
   from member.tc_member_vehicle v 
   left join `member`.tc_member_info tmi on v.member_id =tmi.ID 
   where v.is_deleted=0 and v.MEMBER_ID is not null
 ) v
 where v.rk=1 
 and v.member_id IN 
 (
 '3015178',
'3016040',
'3018737',
'3023845',
'3026040',
'3034054',
'3045309',
'3048070',
'3049829'
 )