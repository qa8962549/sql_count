# 购车经销商城市
select DISTINCT a.cust_id ONEID,a.MEMBER_ID memberid,c.city_name
from (
	select m.cust_id,v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
	from (
			select v.MEMBER_ID,v.VIN
			,row_number() over(partition by v.MEMBER_ID order by v.create_time desc) rk
			from member.tc_member_vehicle v 
			where v.is_deleted=0 and v.MEMBER_ID is not null
	) v
	left join vehicle.tm_vehicle vv on v.vin =vv.vin and vv.IS_DELETED=0
	left join vehicle.tt_invoice_statistics_dms d on v.vin=d.vin and d.IS_DELETED=0
	left join member.tc_member_info m  on v.member_id=m.id
	where v.rk=1 -- 获取用户最后绑车记录
) a left join organization.tm_company c on c.company_code=a.dealer_code and c.COMPANY_TYPE=15061003
where c.CITY_NAME ='上海市'
union
#会员表城市
select DISTINCT m.cust_id ONEID,m.id memberid,c.region_name
from member.tc_member_info m  
left join dictionary.tc_region c on m.member_city=c.REGION_ID
where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
and c.region_name ='上海市' and m.is_vehicle=1
union
#收货地址城市
select DISTINCT m.cust_id ONEID,m.id memberid,cc.region_name
from member.tc_member_info m 
left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID
where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
and cc.region_name ='上海市' and m.is_vehicle=1
union 
#养修预约经销商城市
select DISTINCT p.one_id ONEID,p.memberid memberid,p.city_name
from (
	select DISTINCT p.one_id,p.owner_code,c.city_name,m.id memberid
	from cyx_appointment.tt_appointment p
	left join organization.tm_company c on c.company_code=p.owner_code and c.COMPANY_TYPE=15061003
	join member.tc_member_info m on p.one_id=m.cust_id and m.is_vehicle=1
	where p.appointment_type=70691005 
	and p.one_id is not null 
	and c.city_name  ='上海市'
) p ;