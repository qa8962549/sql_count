-- 访问过活动的车主用户-App
	select count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
    and event='Page_entry'
	and ($url like '%cLacz4Z6Cr%'
or $url like '%dVgHX9jjCU%'
or $url like '%t0q2G1BKGT%'
or $url like '%UWaoxjLKs6%'
or $url like '%ts655omKcS%'
or $url like '%1ygJghseaa%'
or $url like '%ibcJfKGt2M%'
or $url like '%5HgpUpOvVN%'
or $url like '%fQuC7dxU1o%'
or $url like '%kQOsaywkNN%'
or $url like '%2jsLYgWo34%'
or $url like '%AYA7Y8GIZb%'
or $url like '%VYQR6sIzvx%'
or $url like '%1cgvnflRz6%'
or $url like '%6PqoP97P57%'
or $url like '%Q2qSWr28kz%'
or $url like '%blqYpcZDQ8%'
or $url like '%Xycn07LK2T%'
)
    and length(distinct_id)<9 
--    and channel='App'
    and date>='2023-10-01'
    and date<'2023-11-01'
--    and a.is_bind=1


-- 召回车主人数（促活）（App30天内未活跃车主会员）
select 
count(distinct a.user_id)
from
	(-- 访问过活动的车主用户-App
	select distinct a.user_id,distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
    and event='Page_entry'
	and ($url like '%cLacz4Z6Cr%'
or $url like '%dVgHX9jjCU%'
or $url like '%t0q2G1BKGT%'
or $url like '%UWaoxjLKs6%'
or $url like '%ts655omKcS%'
or $url like '%1ygJghseaa%'
or $url like '%ibcJfKGt2M%'
or $url like '%5HgpUpOvVN%'
or $url like '%fQuC7dxU1o%'
or $url like '%kQOsaywkNN%'
or $url like '%2jsLYgWo34%'
or $url like '%AYA7Y8GIZb%'
or $url like '%VYQR6sIzvx%'
or $url like '%1cgvnflRz6%'
or $url like '%6PqoP97P57%'
or $url like '%Q2qSWr28kz%'
or $url like '%blqYpcZDQ8%'
or $url like '%Xycn07LK2T%'
)
    and length(distinct_id)<9 
    and channel='App'
    and date>='2023-10-01'
    and date<'2023-11-01'
    and a.is_bind=1
)a
left join
	(-- 注册会员
	select distinct m.cust_id
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2023-10-01'
	and m.create_time <'2023-11-01'
)b on a.distinct_id=b.cust_id::varchar
left join
	(-- App 访问过活动前30天内活跃过的车主会员
	select 
	distinct a.user_id
	from
		(-- 访问过活动的车主用户-App
		select a.user_id,`time`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
	    and event='Page_entry'
		and ($url like '%cLacz4Z6Cr%'
		or $url like '%dVgHX9jjCU%'
		or $url like '%t0q2G1BKGT%'
		or $url like '%UWaoxjLKs6%'
		or $url like '%ts655omKcS%'
		or $url like '%1ygJghseaa%'
		or $url like '%ibcJfKGt2M%'
		or $url like '%5HgpUpOvVN%'
		or $url like '%fQuC7dxU1o%'
		or $url like '%kQOsaywkNN%'
		or $url like '%2jsLYgWo34%'
		or $url like '%AYA7Y8GIZb%'
		or $url like '%VYQR6sIzvx%'
		or $url like '%1cgvnflRz6%'
		or $url like '%6PqoP97P57%'
		or $url like '%Q2qSWr28kz%'
		or $url like '%blqYpcZDQ8%'
		or $url like '%Xycn07LK2T%'
)
	    and length(distinct_id)<9 
	    and channel='App'
	    and date>='2023-09-21'
	    and date<'2023-10-31'
	    and a.is_bind=1
		)a 
	join
		(--前30天内活跃车主用户
		select a.user_id,`time`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2023-09-01'
		and date<'2023-11-01'
		and a.channel='App'
		and a.is_bind=1
		)b on a.user_id=b.user_id
	where a.time+ interval '-30 day'<= b.`time` and b.`time`<a.time
)c on a.user_id=c.user_id
where 1=1
and b.cust_id is null -- 剔除新用户
and c.user_id =0 -- 剔除访问活动前30天内活跃过的车主会员


-- App 访问过活动前30天内活跃过的车主会员
	select 
	distinct *
	from
		(-- 访问过活动的车主用户-App
		select a.user_id,`time`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
	    and event='Page_entry'
		and ($url like '%cLacz4Z6Cr%'
		or $url like '%dVgHX9jjCU%'
		or $url like '%t0q2G1BKGT%'
		or $url like '%UWaoxjLKs6%'
		or $url like '%ts655omKcS%'
		or $url like '%1ygJghseaa%'
		or $url like '%ibcJfKGt2M%'
		or $url like '%5HgpUpOvVN%'
		or $url like '%fQuC7dxU1o%'
		or $url like '%kQOsaywkNN%'
		or $url like '%2jsLYgWo34%'
		or $url like '%AYA7Y8GIZb%'
		or $url like '%VYQR6sIzvx%'
		or $url like '%1cgvnflRz6%'
		or $url like '%6PqoP97P57%'
		or $url like '%Q2qSWr28kz%'
		or $url like '%blqYpcZDQ8%'
		or $url like '%Xycn07LK2T%'
)
	    and length(distinct_id)<9 
	    and channel='App'
	    and date>='2023-09-21'
	    and date<'2023-10-31'
	    and a.is_bind=1
		)a 
	join
		(--前30天内活跃车主用户
		select a.user_id,`time`
		from ods_rawd.ods_rawd_events_d_di a
		where 1=1
		and length(distinct_id)<9 
		and date>='2023-09-01'
		and date<'2023-11-01'
		and a.channel='App'
		and a.is_bind=1
		)b on a.user_id=b.user_id
	where a.time+ interval '-30 day'<= b.`time` and b.`time`<a.time


-- 拉新人数（App/Mini注册会员）
select 
count(distinct a.user_id)
from
	(-- 访问过活动的车主用户-App
	select a.user_id,distinct_id,time
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
    and event='Page_entry'
	and ($url like '%cLacz4Z6Cr%'
or $url like '%dVgHX9jjCU%'
or $url like '%t0q2G1BKGT%'
or $url like '%UWaoxjLKs6%'
or $url like '%ts655omKcS%'
or $url like '%1ygJghseaa%'
or $url like '%ibcJfKGt2M%'
or $url like '%5HgpUpOvVN%'
or $url like '%fQuC7dxU1o%'
or $url like '%kQOsaywkNN%'
or $url like '%2jsLYgWo34%'
or $url like '%AYA7Y8GIZb%'
or $url like '%VYQR6sIzvx%'
or $url like '%1cgvnflRz6%'
or $url like '%6PqoP97P57%'
or $url like '%Q2qSWr28kz%'
or $url like '%blqYpcZDQ8%'
or $url like '%Xycn07LK2T%'
)
    and length(distinct_id)<9 
--    and channel='App'
--    and channel='Mini'
    and date>='2023-10-01'
    and date<'2023-11-01'
--    and a.is_bind=1
)a 
join
	(-- 注册会员
	select distinct m.cust_id,m.create_time
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.member_source = '60511003' -- 首次注册app用户
	and m.create_time >= '2023-10-01'
	and m.create_time <'2023-11-01'
)b on a.distinct_id=b.cust_id::varchar
where toDateTime(a.time)-toDateTime(b.create_time)<=600 
and toDateTime(a.time)-toDateTime(b.create_time)>=-600

-- 话题数据汇总
select count(distinct x.post_id)
from 
	(		
	select 
	a.topic_id 
	,b.id 
	,b.post_id 
	,b.member_id 
	,tmi.member_name 
	,b.create_time 
	from community.tr_topic_post_link a
	left join community.tm_post b on a.post_id =b.post_id and b.is_deleted =0
	left join "member".tc_member_info tmi on b.member_id =tmi.id and tmi.is_deleted =0
	where a.topic_id in 
	('Ll4EHX3tl6',
		'7Xg7VbcsUL',
		'hVMHss3cAq')
	and a.create_time >='2023-10-01'
	and a.create_time <'2023-11-01')x
	
-- 话题数据汇总  总
select count(distinct x.post_id)
from 
	(		
	select 
	a.topic_id 
	,b.id 
	,b.post_id 
	,b.member_id 
	,tmi.member_name 
	,b.create_time 
	from community.tr_topic_post_link a
	left join community.tm_post b on a.post_id =b.post_id and b.is_deleted =0
	left join "member".tc_member_info tmi on b.member_id =tmi.id and tmi.is_deleted =0
	where a.create_time >='2023-10-01'
	and a.create_time <'2023-11-01'
	and a.topic_id is not null 
	)x

-- 活动参与人数 
select
count(distinct a.member_id) 报名人数
from campaign.tr_campaign_sign_up a
where a.sign_up_time >= '2023-10-01'
and a.sign_up_time <'2023-11-01'
and a.is_deleted = 0
and a.campaign_code in 
('cLacz4Z6Cr',
'dVgHX9jjCU',
't0q2G1BKGT',
'UWaoxjLKs6',
'ts655omKcS',
'1ygJghseaa',
'ibcJfKGt2M',
'5HgpUpOvVN',
'fQuC7dxU1o',
'kQOsaywkNN',
'2jsLYgWo34',
'AYA7Y8GIZb',
'VYQR6sIzvx',
'1cgvnflRz6',
'6PqoP97P57',
'Q2qSWr28kz',
'blqYpcZDQ8',
'Xycn07LK2T')
	
-- 活动参与人数 全量
select
count(distinct a.member_id) 报名人数
from campaign.tr_campaign_sign_up a
where a.sign_up_time >= '2023-10-01'
and a.sign_up_time <'2023-11-01'
and a.is_deleted = 0

-- 2023APP 总数
select count(distinct distinct_id) 
from ods_rawd_events_d_di 
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-10-01' 
and time<'2023-11-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

-- APP车主总数
select count(distinct distinct_id)
from ods_rawd_events_d_di
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-10-01' 
and time<'2023-11-01' 
and length(distinct_id)<9
and distinct_id not like '%#%'
and is_bind=1

-- 公众号拉新
select count(distinct tci.id)
from ods_cust.ods_cust_tm_customer_info_d tci
global join (
    select unionid, min(create_time) first_subscribe_time
    from ods_vwl.ods_vwl_es_car_owners_d
    where unionid<>'' 
    and subscribe_status=1 -- 关注
    group by unionid   
    ) t2 on tci.union_id = t2.unionid
left join (-- 访问过活动的车主用户-App
	select a.user_id,distinct_id,time
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
    and event='Page_entry'
	and ($url like '%cLacz4Z6Cr%'
	or $url like '%dVgHX9jjCU%'
	or $url like '%t0q2G1BKGT%'
	or $url like '%UWaoxjLKs6%'
	or $url like '%ts655omKcS%'
	or $url like '%1ygJghseaa%'
	or $url like '%ibcJfKGt2M%'
	or $url like '%5HgpUpOvVN%'
	or $url like '%fQuC7dxU1o%'
	or $url like '%kQOsaywkNN%'
	or $url like '%2jsLYgWo34%'
	or $url like '%AYA7Y8GIZb%'
	or $url like '%VYQR6sIzvx%'
	or $url like '%1cgvnflRz6%'
	or $url like '%6PqoP97P57%'
	or $url like '%Q2qSWr28kz%'
	or $url like '%blqYpcZDQ8%'
	or $url like '%Xycn07LK2T%'
)
    and length(distinct_id)<9 
--    and channel='App'
--    and channel='Mini'
    and date>='2023-10-01'
    and date<'2023-11-01'
--    and a.is_bind=1
)x on toString(x.distinct_id) =toString(tci.id) 
where DATEDIFF('minute',t2.first_subscribe_time,x.time)<=10
and DATEDIFF('minute',t2.first_subscribe_time,x.time)>=-10


--激活代码
SELECT 
	count(distinct a.distinct_id) as jh
--	a.`date` d0,a.distinct_id u0,b.d1,b.u1,b.d2,b.u2,c.cust_id,date_diff(day,b.d2, b.d1)
	from (
	--访问活动页的日期和用户ID
	select date,a.distinct_id
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App') )
	and page_title = '推荐购_邀请好友'
	and length(distinct_id)<9 
	and date>='2023-10-01'
	and date<'2023-11-01'
	and a.is_bind=1
	group by date,a.distinct_id
	order by a.`date` ,a.distinct_id
) a
	left join (
	--访问日期及上次访问日期&日期差
	SELECT level2_1.distinct_id u1,level2_1.date as d1,level2_1.rk rk1,level2_2.distinct_id u2,level2_2.date as d2,level2_2.rk rk2
		from (
		SELECT level1.date,level1.distinct_id,row_number() over(partition by level1.distinct_id order by level1.date desc) as rk
			from (
			select date,a.distinct_id
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App') )
			and length(distinct_id)<9 
			and date>='2023-09-01'
			and date<'2023-11-01'
			and a.is_bind=1
			group by date,a.distinct_id
			order by a.`date` ,a.distinct_id
			) level1
		Settings allow_experimental_window_functions = 1
		) level2_1
		left join (
		SELECT level1.date,level1.distinct_id,row_number() over(partition by level1.distinct_id order by level1.date desc) as rk
			from (
			select date,a.distinct_id
			from ods_rawd.ods_rawd_events_d_di a
			where 1=1
			and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App') )
			and length(distinct_id)<9 
			and date>='2023-09-01'
			and date<'2023-11-01'
			and a.is_bind=1
			group by date,a.distinct_id
			order by a.`date` ,a.distinct_id
			) level1
		Settings allow_experimental_window_functions = 1
		) level2_2
	on level2_2.distinct_id=level2_1.distinct_id and cast(level2_2.rk-1 as int)=cast(level2_1.rk as int)
) b
on b.u1=a.distinct_id and b.d1=a.`date` 
	left join (
	--会员表识别是否为新用户
	select m.cust_id,min(m.create_time) mtime
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	and m.create_time >= '2023-10-01'
	and m.create_time <'2023-11-01'
	group by m.cust_id
) c 
on c.cust_id::varchar = a.distinct_id
where 1=1
and date_diff(day,b.d2, b.d1)>=30
--and (date_diff(day,b.d2, b.d1)>=30 or b.u2 is null)
and c.cust_id is null