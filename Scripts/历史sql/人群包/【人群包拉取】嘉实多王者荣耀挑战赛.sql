-- 沃世界绑车时间在21年7月1日~22年7月20日的车主的手机号
 select DISTINCT tmi.MEMBER_PHONE,v.create_time
 from (select v.*
 from 
 (select v.MEMBER_ID,v.VEHICLE_CODE,v.vin,v.create_time
 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
 from member.tc_member_vehicle v 
 where v.IS_DELETED=0 
 and v.create_time>='2021-07-01' and v.create_time<'2022-07-21'
 )v where v.rk=1
 ) v 
 left join `member`.tc_member_info tmi on v.member_id=tmi.id and tmi.STATUS <>60341003 and tmi.IS_DELETED =0
where LENGTH(tmi.MEMBER_PHONE)=11 and `LEFT`(tmi.MEMBER_PHONE,1)='1'
 order by 2