-- 私域会员总数 （APP 小程序 公众号）  要拿sql跑的数据和+APP会员总数-APP小程序交集用户数
--截止去年年8月31日的私域用户总数（含公众号）、注册会员总数（不含公众号）、App绑车用户数（神策所有app的distinct_id去tc_member_info表匹身份，is_bind不能用）
select 
a.`日期`
,a.`注册数`+g.`公众号总关注数`-f.`交集用户数` 总用户数
from (
--	#小程序注册数--a
	select curdate() - interval '1 day' 日期,count(1) 注册数
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
-- 	and m.MEMBER_SOURCE <>'60511003' -- 剔除首次注册app用户
	and m.create_time <'2023-01-01'
	GROUP BY 1 
) a 
left join (
	-- 交集用户--f
	select current_date-1 日期,count(a.allunionid) 交集用户数 -- 5月4日及之前的结果1539090
	from (
		-- 结合老库获取新库用户对应的 unionid
		select m.id mid,m.MEMBER_PHONE,m.member_name,IFNULL(c.union_id,u.unionid) allunionid
		from  member.tc_member_info m 
		left join customer.tm_customer_info c on c.id=m.cust_id
		left join dl_vcdc.ods_volvowechat_dbo_owneruserinfoes u on cast(u.id as varchar)=m.old_memberid and u.unionid<>'00000000'
		where m.member_status<>60341003 and m.is_deleted=0 -- 排除黑名单用户
		and nullif(m.create_time,'1970-01-01 00:00:00') <'2023-01-01'
		and nullif(c.create_time,'1970-01-01 00:00:00') <'2023-01-01'
	)a
	JOIN volvo_wechat_live.es_car_owners o on a.allunionid=o.unionid 
	and o.subscribe_status=1
	and o.unionid<>'' and o.unionid is not null 
	and IFNULL(nullif(o.subscribe_time,'1970-01-01 00:00:00'),nullif(o.create_time,'1970-01-01 00:00:00'))<'2023-01-01' -- sbuscirbe_status=1 为订阅用户
	GROUP BY 1
) f on f.日期=a.日期
left join (
	--  公众号总关注数--g
	select current_date-1  日期,count(1)  公众号总关注数
	from volvo_wechat_live.es_car_owners o 
	where o.subscribe_status=1
	and IFNULL(nullif(o.subscribe_time,'1970-01-01 00:00:00'),nullif(o.create_time,'1970-01-01 00:00:00'))<'2023-01-01'
	GROUP BY 1 
) g on g.日期=a.日期

--	#小程序注册数--a
select x.t ,
x.num,
sum(x.num) over(order by x.t asc) 小程序注册数
from 
	(select date_format(m.create_time,'%Y-%m') t
	,count(1) num
	from member.tc_member_info m
	where m.member_status<>60341003 and m.is_deleted=0
-- 	and m.MEMBER_SOURCE <>'60511003' -- 剔除首次注册app用户
	and m.create_time <'2023-01-01'
	GROUP BY 1 
	order by 1)x

-- App绑车用户数（神策所有app的distinct_id去tc_member_info表匹身份，is_bind不能用）
-- 2022年7月份之前is_bind为空
select 
count(distinct did)
from 
	(
	-- 最近一次进入App时间
	select cast(distinct_id as int) did
	  ,*
	  ,m.is_vehicle
	  ,row_number() over(partition by distinct_id order by time desc) rk
	  from ods_rawd.ods_rawd_events_d_di a
	  left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.distinct_id) = toString(m.cust_id) 
	  where 1=1
	  and (`$lib` in('iOS','Android') or channel='App')
--	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  and date<'2023-01-01'
	  Settings allow_experimental_window_functions = 1
	)a 
where a.rk=1 
and a.is_vehicle=1 -- 利用member表的车主身份

-- 2022年7月份之前is_bind为空
	-- App绑车用户MAU
	select DATE_TRUNC('month',date) t
	  ,count(distinct a.distinct_id) MAU
	  from ods_rawd.ods_rawd_events_d_di a
	  left join ods_memb.ods_memb_tc_member_info_cur m on toString(a.distinct_id) = toString(m.cust_id) 
	  where 1=1
	  and (`$lib` in('iOS','Android') or channel='App')
--	  and event ='$AppViewScreen'
	  and length(distinct_id)<9 
	  and left($app_version,1)>='5'
	  and date<'2023-01-01'
	  and m.is_vehicle=1 -- 利用member表的车主身份
	  group by t 
	  order by t
