-- 
-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select 
 DISTINCT tmi.id,
 tmi.MEMBER_PHONE,
 tmi.CUST_ID,
 xx.certificate_no 身份证号,
 x1.city 所在城市,
case when tmi.IS_VEHICLE = '1' then '车主'
when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
 '' 最近登录App时间,
 x2.tt 最近登录沃世界时间,
 tmi.LEVEL_ID,
 ''客诉情况,
 IF(md.medal_id is not null,'是','否') 
 from `member`.tc_member_info tmi 
 left join
	 (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v on v.member_id=tmi.ID 
left join vehicle.tm_vehicle t on v.vin=t.VIN
left join basic_data.tm_model m on t.MODEL_ID=m.ID
left join vehicle.tt_invoice_statistics_dms xx on v.vin=xx.vin
left join (
	select m.id,m.member_phone ,ifnull(c1.region_name , IFNULL(c2.region_name,c3.region_name) ) city 
	from member.tc_member_info m 
	left join (
	 #最后绑定经销商城市
	 select a.member_id,c.city_name region_name-- ,a.model_name
	 from (
	  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
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
	) c1 on c1.member_id = m.id
	left join (
	 #会员表城市
	 select m.id,c.REGION_NAME
	 from member.tc_member_info m  
	 left join dictionary.tc_region c on m.member_city=c.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c2 on c2.id= m.id
	left join (
	 #收货地址城市
	 select m.id,cc.REGION_NAME
	 from member.tc_member_info m 
	 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
	 left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c3 on c3.id= m.id
	where m.MEMBER_STATUS<>60341003 
	and m.IS_DELETED=0 
	and m.id<>3014773 -- 测试ID;
	)x1 on v.member_id=x1.id
left join (
	select t.usertag,
	m.ID,
	max(t.date) tt 
	from track.track t
	left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag
	group by 1
)x2 on x2.id=v.member_id 
left join mine.madal_detail md on md.user_id =tmi.id and md.medal_id =2
 where v.rk=1
 and tmi.MEMBER_PHONE in 
 ('13335026219',
'18980092119',
'15380392756',
'15928682914',
'18030701227',
'13311581626',
'18101846616',
'17707216766',
'18980046826',
'15609799588',
'15574559251',
'13488900795',
'15608195382',
'13808221666',
'17739322008',
'13917261793',
'15882134626',
'18981175188',
'15682539008',
'13880901356',
'18809846781',
'18981990803',
'18583378596',
'13908283052',
'18090449525',
'13880316968',
'18606536162',
'13648031961',
'13728762083',
'13979773280',
'18183270120',
'18284561285',
'13118052183',
'15902852539',
'13282236993',
'18771074364',
'18328496454',
'15376566299',
'18113312020',
'13905272952',
'18755950621',
'13691000450',
'13582729558',
'18628282058',
'13986149860',
'17600113343',
'13808215996',
'13716359808',
'15267101542',
'18845115999',
'18906451876',
'13013851026',
'17780508849',
'18001700353',
'18224404674',
'15982211956',
'15100786829',
'18121107623',
'19950158806',
'18919566618',
'16621037636',
'13819231754',
'13307446233',
'13625209566',
'15901906942',
'18621949052',
'15044467711',
'13880706380',
'18601676546',
'13701916140',
'15808068978',
'13601678656',
'13018275866',
'13917255527',
'15003601266',
'13601943649',
'13810204687',
'15620382226',
'19934309828',
'13817655731',
'18523167813',
'15801130096',
'15003177295',
'15901919903',
'18908387091',
'15881025359',
'18810820878',
'17602552747',
'13848638050'
)

-- 会员ID绑定最新车辆信息，这里rk=1取的是最新绑定
 select 
 DISTINCT 
--  tmi.id,
--  tmi.MEMBER_PHONE,
 tmi.CUST_ID,
--  v.vin,
--  xx.certificate_no 身份证号,
case when tmi.IS_VEHICLE = '1' then '车主'
when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
TIMESTAMPDIFF(month,xx.first_invoice_date,CURDATE())/12 购车年龄,
x1.city,
ifnull(m.MODEL_NAME,v.model_name)车型,
tmi.MEMBER_LEVEL 会员等级,
tmi.MEMBER_V_NUM V值余额
 from `member`.tc_member_info tmi 
 left join
	 (
	 select v.MEMBER_ID,v.VEHICLE_CODE,m.model_name,v.vin,v.create_time
	 ,row_number() over(PARTITION by v.MEMBER_ID order by v.create_time desc) rk
	 from member.tc_member_vehicle v 
	 left join basic_data.tm_model m on v.vehicle_code=m.MODEL_CODE
	 where v.IS_DELETED=0 
	 ) v on v.member_id=tmi.ID 
left join vehicle.tm_vehicle t on v.vin=t.VIN
left join basic_data.tm_model m on t.MODEL_ID=m.ID
left join vehicle.tt_invoice_statistics_dms xx on v.vin=xx.vin
left join (
	select m.id,m.member_phone ,ifnull(c1.region_name , IFNULL(c2.region_name,c3.region_name) ) city 
	from member.tc_member_info m 
	left join (
	 #最后绑定经销商城市
	 select a.member_id,c.city_name region_name-- ,a.model_name
	 from (
	  select v.member_id,ifnull(d.dealer_code,vv.dealer_code) dealer_code,vv.model_name
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
	) c1 on c1.member_id = m.id
	left join (
	 #会员表城市
	 select m.id,c.REGION_NAME
	 from member.tc_member_info m  
	 left join dictionary.tc_region c on m.member_city=c.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c2 on c2.id= m.id
	left join (
	 #收货地址城市
	 select m.id,cc.REGION_NAME
	 from member.tc_member_info m 
	 left join member.tc_member_address a on m.id=a.member_id and a.IS_DEFAULT=1 and a.status=0
	 left join dictionary.tc_region cc on a.ADDRESS_CITY=cc.REGION_ID
	 where m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	) c3 on c3.id= m.id
	where m.MEMBER_STATUS<>60341003 
	and m.IS_DELETED=0 
	and m.id<>3014773 -- 测试ID;
	)x1 on tmi.id=x1.id
	
--  where tmi.CUST_ID =22798428

