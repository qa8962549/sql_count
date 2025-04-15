
select if(x.是否关注公众号='否'and x.该VIN是否沃世界绑车='否','是','否')未双关
,x.*
from 
(
select case when v.create_time is null then '否' else '是' end 该VIN是否沃世界绑车
,"" 该VIN是否沃世界授权
,v.member_id
,a.mtime
,v.create_time
,case when o.id is null then '否' else '是' end 是否关注公众号
,IFNULL(o.subscribe_time,o.create_time) 公众号关注时间
,case when t.mid is null then '否' else '是' end 30天是否登录
,v.vin
from (
	 #清洗VIN
	 select v.vin,v.member_id,v.create_time
	 from (
	 select v.VIN,v.MEMBER_ID,v.CREATE_TIME
	 ,row_number() over(partition by v.vin order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 where v.IS_DELETED=0
	 ) v
	 where v.rk=1 
) v 
LEFT JOIN (
	 #结合老库获取新库用户对应的 unionid
	 select m.id mid,IFNULL(c.union_id,u.unionid) allunionid,m.create_time mtime
	 from  member.tc_member_info m 
	 left join customer.tm_customer_info c on c.id=m.cust_id
	 left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
	 where m.member_status<>60341003 and m.is_deleted=0 
	) a on v.member_id=a.mid
left JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.unionid<>'' and o.subscribe_status=1
left join (
select DISTINCT m.id mid
from track.track t 
join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag and m.is_deleted=0 and m.member_status<>60341003
where t.date>=DATE_SUB(CURDATE() ,INTERVAL 1 MONTH)
) t on v.member_id=t.mid
)x

-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select v.vin,
 case when v.vin is not null then '是'
 	else null end as 'app是否绑车',
 	v.create_time 'app绑车时间',
 case when t.mid is not null then '是'
  		else '否'end as '22年3月30日后是否登录app'
 from (
 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
 where v.IS_DELETED=0 
 ) v 
 left join vehicle.tm_vehicle t on v.vin=t.VIN
 left join basic_data.tm_model m on t.MODEL_ID=m.ID
 left join (
select DISTINCT m.id mid
from track.track t 
join member.tc_member_info m on CAST(m.user_id AS VARCHAR)=t.usertag and m.is_deleted=0 and m.member_status<>60341003
where t.date>='2022-03-30'
) t on v.member_id=t.mid
 where v.rk=1
 