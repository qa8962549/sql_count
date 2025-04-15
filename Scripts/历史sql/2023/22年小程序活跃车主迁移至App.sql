-- 由于小程序仍有大量22年活跃车主未迁移至App，因此需要帮忙拉一批名单，进行定向沟通；
-- 
--  
-- 
-- 基盘数： 22年1月1号至今登入过沃世界小程序2次及以上的车主会员；
-- 
-- 分子数： 基盘车主会员中有多少已登入过App，有多少尚未登入过App；
-- 
-- 帮忙拉一下“未登入过App“的Member ID，公众号open ID， One ID，要定向沟通；


-- 基盘数： 22年1月1号至今登入过沃世界小程序2次及以上的车主会员；
select count(1)
from 
(
SELECT t.usertag,
m.ID,
m.CUST_ID
from track.track t 
left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag and m.is_deleted=0 and m.member_status<>60341003
where t.date>='2022-01-01'
and t.date<CURDATE() 
and m.IS_VEHICLE =1
and t.typeid='XWSJXCX_HOME_V'
group by 1
HAVING count(1)>=2
)x

-- 
SELECT m.ID,
m.CUST_ID oneid,
x.微信公众号open_id
from track.track t 
left join `member`.tc_member_info m on cast(m.USER_ID as varchar)=t.usertag and m.is_deleted=0 and m.member_status<>60341003
left join (
	-- 根据各种条件匹配微信公众号openid
	select a.会员ID,a.客户ID,a.会员昵称,a.姓名,a.性别,a.手机号,a.VIN,a.微信小程序open_id,(eco.open_id)微信公众号open_id,a.注册时间
	from
	(
	select 
	m.id 会员ID,
	m.cust_id 客户ID,
	m.create_time 注册时间,
	case when m.member_sex = '10021001' then '先生'
		when m.member_sex = '10021002' then '女士'
		else '未知' end 性别,
	m.member_name 会员昵称,
	m.real_name 姓名,
	m.MEMBER_PHONE 手机号,
	tmv.VIN,
	c.open_id 微信小程序open_id,
	IFNULL(c.union_id,u.unionid) allunionid
	from member.tc_member_info m 
	left join `member`.tc_member_vehicle tmv on m.ID = tmv.MEMBER_ID and tmv.IS_DELETED = 0
	left join customer.tm_customer_info c on c.id=m.cust_id
	left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid
	where m.is_deleted = 0 and m.member_status <> '60341003'
	) a 
	left join volvo_wechat_live.es_car_owners eco on a.allunionid = eco.unionid 
	and eco.subscribe_status = 1 -- 状态为关注
	and eco.open_id is not null 
	and eco.open_id <> ''
	order by a.注册时间 DESC)x on x.会员ID=m.id
where t.date>='2022-01-01'
and t.date<CURDATE() 
and m.IS_VEHICLE =1
and t.typeid='XWSJXCX_HOME_V'
group by 1
HAVING count(1)>=2
