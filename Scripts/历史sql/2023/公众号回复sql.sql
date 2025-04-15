-- 微信公众号用户回复的总人数和总次数
select 
count(DISTINCT eco.id) 总人数,
count(ewrl.id) 总次数
from volvo_wechat_live.es_wechat_reply_log ewrl  
left join volvo_wechat_live.es_car_owners eco on ewrl.openid =eco.open_id 
where ewrl.create_time >='2022-4-01 00:00:00' and ewrl.create_time <='2022-5-15 23:59:59'

-- 公众号回复关键词清单
select 
eco.id,
ewrl.title 回复内容,
ewrl.create_time 
from volvo_wechat_live.es_wechat_reply_log ewrl 
left join volvo_wechat_live.es_car_owners eco on ewrl.openid =eco.open_id 
where ewrl.create_time >='2022-4-01 00:00:00' and ewrl.create_time <='2022-5-15 23:59:59'
order by ewrl.create_time desc


-- 四个卡片点击人数
select 
	case when t.data like '%4E9B9D5FCFFA4D908BC8FA97D8E7E548%' then '02沃家商城' 
	when t.data like '%0FFAA40EBFBD46E68B307018212E7D6C%' then '04爱车甄选' 
	when t.data like '%9CD1F531D7E7425FAC98E069D27E7F45%' then '03最新活动' 
	when t.data like '%90180CE7ADD8417C8D65294179AAF3DA%' then '01养修预约' 
	end '卡片名称',
count(DISTINCT t.usertag),
count(t.usertag)
from track.track t 
where t.date >= '2022-04-01'and t.date <='2022-5-15 23:59:59'
group by 1
order by 1


-- tcode去重
select count(b.tt)
from 
(select DISTINCT t.usertag tt
from track.track t   
where t.`date` >= '2022-04-01'and t.`date` <='2022-5-15 23:59:59'
and t.data like '%4E9B9D5FCFFA4D908BC8FA97D8E7E548%' 
union
select DISTINCT t.usertag tt
from track.track t   
where t.`date` >= '2022-04-01'and t.`date` <='2022-5-15 23:59:59'
and t.data like '%0FFAA40EBFBD46E68B307018212E7D6C%' 
union 
select DISTINCT t.usertag tt
from track.track t   
where t.`date` >= '2022-04-01'and t.`date` <='2022-5-15 23:59:59'
and t.data like '%9CD1F531D7E7425FAC98E069D27E7F45%' 
UNION 
select DISTINCT t.usertag tt
from track.track t   
where t.`date` >= '2022-04-01'and t.`date` <='2022-5-15 23:59:59'
and t.data like '%90180CE7ADD8417C8D65294179AAF3DA%' )b

-- 公众号回复1的总人数和总次数
select 
count(DISTINCT eco.id) 总人数,
count(ewrl.id) 总次数
from volvo_wechat_live.es_wechat_reply_log ewrl 
left join volvo_wechat_live.es_car_owners eco on ewrl.openid =eco.open_id 
where ewrl.create_time >='2022-4-01 00:00:00' and ewrl.create_time <='2022-5-15 23:59:59'
and ewrl.title ='1'

-- 回复在看
select
	to_char(ewrl.create_time,'YYYY-MM')
	,a.is_vehicle
	,count(distinct eco.id) 总人数
	,count(ewrl.id) 总次数
from
	volvo_wechat_live.es_wechat_reply_log ewrl
left join volvo_wechat_live.es_car_owners eco on nullif(ewrl.openid,null)::varchar = nullif(eco.open_id,null)::varchar
left join (select 
	m.id ,
	m.cust_id ,
	m.create_time ,
	m.is_vehicle,
	cast(trim(coalesce(c.union_id, u.unionid)) as varchar) as allunionid
	from member.tc_member_info m 
	left join customer.tm_customer_info c on c.id = nullif(m.cust_id, null)::varchar
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id = m.old_memberid
	where m.is_deleted = '0' and m.member_status <> '60341003'
	) a 
	on nullif(a.allunionid,null)::varchar = nullif(eco.unionid,null)::varchar
	where 
	ewrl.create_time >= '2023-01-01'
	and ewrl.create_time <'2023-05-01'
	and ewrl.title = '在看'
group by
	1,2
order by
	1,2 desc


select 
m.id ,
m.cust_id ,
m.create_time ,
case 
	when m.member_sex = '10021001' then '先生'
	when m.member_sex = '10021002' then '女士'
	else '未知' 
end as "性别",
m.member_name ,
m.real_name ,
m.member_phone ,
tmv.vin ,
c.open_id ,
coalesce(c.union_id, u.unionid) as allunionid
from member.tc_member_info m 
left join member.tc_member_vehicle tmv on m.id = tmv.member_id and tmv.is_deleted = 0
left join customer.tm_customer_info c on c.id = nullif(m.cust_id, null)::bigint
left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id = m.old_memberid
where m.is_deleted = '0' and m.member_status <> '60341003'



