### 沃世界公众号OKR提升数据需求
select count(1) 需求一 -- 注册沃世界未关注公众号用户数
,count(case when m.IS_VEHICLE=1 then 1 else null end ) 需求二车主 -- 注册沃世界未关注公众号车主数
,count(case when m.IS_VEHICLE=0 then 1 else null end ) 需求二粉丝 -- 注册沃世界未关注公众号粉丝数
,count(case when t.usertag is not null then 1 else null end) 需求三 -- 注册沃世界未关注公众号且商城板块top1,top2用户
,count(case when t.usertag is not null and a.user_id is not null then 1 else null end) 需求四 -- 注册沃世界未关注公众号且商城板块top1,top2用户且180内下单用户
,count(case when t.usertag is not null and a.user_id is not null and f.memberid is not null then 1 else null end) 需求五 -- 注册沃世界未关注公众号且商城板块top1,top2用户且180内下单用户且签到40天以上用户
,count(case when t.usertag is not null and a.user_id is not null and f.memberid is not null and b.id is not null then 1 else null end) 需求六 -- 注册沃世界未关注公众号且商城板块top1,top2用户且180内下单用户且签到40天以上用户且21年12月-22年5月每月活跃用户
from member.tc_member_info m
left join (
	#判断是否关注公众号
	select a.mid,o.open_id
	from (
		#结合老库获取新库用户对应的 unionid
		select m.id mid,m.MEMBER_PHONE,m.member_name,IFNULL(c.union_id,u.unionid) allunionid
		from  member.tc_member_info m 
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on u.id=m.old_memberid and u.unionid<>'00000000'
		where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
	)a
	JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid and o.subscribe_status=1 and o.unionid<>'' and o.unionid is not null 
) o on m.id=o.mid
left join (
	#商城板块top1,top2用户
	select t.*
	from (
		-- 统计所有用户板块top
		select t.usertag
		,case when t.typeid = 'XWSJXCX_HOME_V' then '首页'
					when t.typeid in ('XWSJXCX_CUSTOMER_V','XWSJXCX_OWNER_V') then '爱车'
					when t.typeid = 'XWSJXCX_MALL_HOMEPAGE_V' then '商城'
					when t.typeid = 'XWSJXCX_PERSONEL_V' then '我的'
					else null end 板块
		,count(1) 触发次数
		,row_number() over(partition by t.usertag order by count(1) desc) top
		from track.track t 
		where t.date < '2022-05-24'
		and t.typeid in (
		'XWSJXCX_HOME_V',    
		'XWSJXCX_CUSTOMER_V',
		'XWSJXCX_OWNER_V',
		'XWSJXCX_MALL_HOMEPAGE_V',
		'XWSJXCX_PERSONEL_V'
		)
		GROUP BY 1,2 order by 1
	) t 
	where t.板块='商城' and t.top in (1,2)
) t on cast(m.user_id as varchar) = t.usertag
left join (
	# 180天内下单用户
	select DISTINCT a.user_id
	from order.tt_order a  -- 订单主表
	where a.status in (51031003,51031004,51031005) -- 筛选待发货,待收货,已完成订单
	and a.type = 31011003  -- 筛选沃世界商城订单
	and a.separate_status = '10041002' -- 选择拆单状态否
	and a.is_deleted <> 1  -- 剔除逻辑删除订单
	and a.create_time >= DATE_SUB('2022-05-24',INTERVAL 180 DAY)
	and a.create_time < '2022-05-24'
) a on a.user_id = m.id
left join (
	# 累计签到40天用户
	select m.id memberid,count(DISTINCT f.day_int) 签到天数
	from mine.sign_info f 
	join member.tc_member_info m on f.member_id=m.ID and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003 
	where f.create_time >= DATE_SUB('2022-05-24',INTERVAL 180 DAY)
	and f.create_time < '2022-05-24'
	GROUP BY 1 
	HAVING count(DISTINCT f.day_int) >= 40 
	order by 2 desc 
) f on f.memberid = m.id
left join (
	# 21年12月-22年5月每月活跃用户
	select t.id,count(1) 活跃月数
	from (
	SELECT DISTINCT m.id,DATE_FORMAT(t.date,'%Y-%m') 活跃月份
	FROM track.track t 
	JOIN MEMBER.tc_member_info m ON cast(m.USER_ID AS varchar) = t.usertag and m.IS_DELETED=0 and m.MEMBER_STATUS<>60341003
	WHERE t.date >= '2021-12-01' and t.date < '2022-05-24'
	and t.date > m.create_time 
	) t
	GROUP BY 1
	HAVING count(1) = 6
) b on b.id = m.id
where m.member_status<>60341003 and m.IS_DELETED=0 -- 排除黑名单用户
and m.create_time < '2022-05-24'
and o.open_id is null -- 未关注公众号用户;