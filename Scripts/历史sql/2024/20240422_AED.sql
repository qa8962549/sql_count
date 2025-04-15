--TAB整体
select 
--count(x.distinct_id),
count(distinct x.distinct_id)
from 
	(
	select event,
	page_title,
	distinct_id,
	date,
	btn_name ,
	bussiness_name,
	content_title,
	content_id ,
	lateral_position ,
	$url,
	`$lib`
	from ods_rawd.ods_rawd_events_d_di  
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	--and page_title='沃尔沃AED道路使者联盟'
	and event='Tech_network_response'
	and `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/5OgTRobTpf%' -- app 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and length(distinct_id)<9
	order by time desc 
	--limit 30
)x

-- 活动
select 
--count(x.distinct_id),
count(distinct x.distinct_id)
from 
	(
	select event,
	page_title,
	distinct_id,
	date,
	btn_name ,
	bussiness_name,
	content_title,
	content_id ,
	lateral_position ,
	$url,
	`$lib`
	from ods_rawd.ods_rawd_events_d_di  
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event='Page_entry'
--	and `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/5OgTRobTpf%' -- app 
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and length(distinct_id)<9
	and is_bind=1
	order by time desc 
	--limit 30
)x

	select event,
	page_title,
	distinct_id,
	date,
	btn_name ,
	bussiness_name,
	content_title,
	content_id ,
	lateral_position ,
	$url,
	activity_name,
	activity_id ,
	`$lib`
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
--	and page_title='沃尔沃AED道路使者联盟'
	and page_title='话题详情'
	and content_title like'%联盟%'
--	and activity_id='L0aiidtdAr'
--	and event ='Button_click'
--	and length(distinct_id)<9
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app

--首页banner 
select 
	lateral_position,
	count(distinct_id),
	count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event ='Button_click'
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and length(distinct_id)<9
group by 1
order by 1

--btn “心”活动
select 
	content_title ,
	count(distinct_id),
	count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='活动详情'
	and event ='Page_entry'
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
	and activity_id in ('L0aiidtdAr','mqcB34ul2p','Wp4sduDce9','MOOejW1AR9')
--	and length(distinct_id)<9
group by 1
order by 1 desc 

--btn “心”驻地
select 
	content_title ,
	count(distinct_id),
	count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='内容详情'
	and event ='Page_entry'
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and activity_id in ('L0aiidtdAr','mqcB34ul2p','Wp4sduDce9','MOOejW1AR9')
	and content_title like '%联盟%'
	and length(content_title)<16
--	and length(distinct_id)<9
group by 1
order by 1 desc 

-- 帖子的PVUV
select 
post_title ,
post_id,
count(a.member_id) PV,
count(DISTINCT a.member_id) UV
from ods_cmnt.ods_cmnt_tt_view_post_cur a
left join ods_cmnt.ods_cmnt_tm_post_cur oc on a.post_id =oc.post_id 
where a.post_id in ('rA69wiW35G',
'QesdRs8Qar',
'7NcVhC6AQF',
'E2KUV3eZZE',
'hOwLXEa074',
'mJ6f8vf9r6')
--and a.create_time >='2023-09-21'
--and a.create_time <'2023-10-31'
and a.is_deleted =0
group by 1,2
order by 1,2

--分享“心”的体验 btn
select 
--	content_title ,
	count(distinct_id),
	count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
--	and page_title='内容详情'
	and event ='Button_click'
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and activity_id in ('L0aiidtdAr','mqcB34ul2p','Wp4sduDce9','MOOejW1AR9')
--	and content_title like '%联盟%'
	and btn_name in ('微信好友','朋友圈')
	and content_id='log7q8ovF9'
	and length(content_title)<16
--	and length(distinct_id)<9
--group by 1
--order by 1 desc 

--btn  
select 
	btn_name ,
	count(distinct_id),
	count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event ='Button_click'
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
--	and length(distinct_id)<9
group by 1
order by 1



-- 拉新人数（App/Mini注册会员）
select 
count(distinct a.user_id)
from
	(-- 访问过活动的用户-App/Mini
	select a.user_id,distinct_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event='Page_entry'
--	and `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/5OgTRobTpf%' -- app 
--	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
)a 
join
	(-- 注册会员
	select distinct m.cust_id,m.create_time
	from ods_memb.ods_memb_tc_member_info_cur m 
	where m.member_status <> '60341003' and m.is_deleted =0 
	--and m.member_source = '60511003' -- 首次注册app用户
	and m.create_time >= '2024-04-07'
	and m.create_time <'2024-04-22'
)b on a.distinct_id=b.cust_id::varchar
where toDateTime(a.time)-toDateTime(b.create_time)<=600 
and toDateTime(a.time)-toDateTime(b.create_time)>=-600

-- 召回车主人数（促活）（App30天内未活跃车主会员）
select 
count(distinct a.user_id)
from
(-- 访问过活动的车主用户-App
select distinct a.user_id,distinct_id
from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event='Page_entry'
--	and `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/5OgTRobTpf%' -- app 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
	and length(distinct_id)<9
--and a.is_bind=1
)a
left join
(-- 注册会员
select distinct m.cust_id
from ods_memb.ods_memb_tc_member_info_cur m 
where m.member_status <> '60341003' and m.is_deleted =0 
and m.create_time >= '2023-10-18'
and m.create_time <'2023-11-01'
)b on a.distinct_id=b.cust_id::varchar
left join
(-- App 访问过活动前30天内活跃过的车主会员
select 
distinct a.user_id
from
	(-- 访问过活动的车主用户-App
	select a.user_id,`time`,time+ interval '-10 MINUTE' as `time1`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and date>='2024-04-07'
	and date<'2024-04-22'
	and page_title='沃尔沃AED道路使者联盟'
	and event='Page_entry'
--	and `$url` like '%https://mweb.digitalvolvo.com/mweb/custom/detail/5OgTRobTpf%' -- app 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App') -- app
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
	and length(distinct_id)<9
--	and a.is_bind=1
	)a 
join
	(--前30天内活跃用户
	select a.user_id,`time`
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and length(distinct_id)<9 
	and date>='2024-03-07'
	and date<'2024-03-22'
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
--	and (`$lib`='MiniProgram' or channel='Mini') -- Mini
	and length(distinct_id)<9
	)b on a.user_id=b.user_id
where a.`time`+ interval '-30 day'<= b.`time` and b.`time`<a.`time1`
)c on a.user_id=c.user_id
where 1=1
and b.cust_id is null -- 剔除新用户
and c.user_id =0 -- 剔除访问活动前30天内活跃过的车主会员

-- 报名人数

-- 活动参与人数 
select
campaign_code,
m.is_vehicle,
count(distinct a.member_id) `报名人数`
from ods_camp.ods_camp_tr_campaign_sign_up_d a
left join ods_memb.ods_memb_tc_member_info_cur m on toString( m.id)=toString(a.member_id)  
where 1=1
--and a.sign_up_time >= '2023-10-01'
--and a.sign_up_time <'2023-11-01'
and a.is_deleted = 0
and a.campaign_code in ('L0aiidtdAr',
'mqcB34ul2p',
'Wp4sduDce9')
group by 1,2
order by 1,2 desc 