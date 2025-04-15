-- 社区互动浏览人数 ，只要APP站内数据且已注册的会员，该指标为全年累计指标，到2月份时，为1-2月累计人数去重；会员日单独算进去
-- 社区互动浏览人数会员等级
select date_trunc('week',t.date) t
,l.level_code 
,l.level_name
,count(distinct t.distinct_id)
from 
	(
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2024%' and activity_id is null))
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
	union all 
	-- 社区互动人数
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event='Button_click' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
) t 
join ads_crm.ads_crm_events_member_d m on toString(m.distinct_id)=toString(t.distinct_id) 
left join ods_memb.ods_memb_tc_level_cur l on toString(m.member_level)=toString(l.level_code) 
where length(t.distinct_id)<9 
and l.is_deleted=0
group by t,level_code,level_name
order by level_code,t,level_name


-- 社区互动浏览人数车主粉丝
select 
date_trunc('week',t.date) t
,m.is_owner
,count(distinct t.distinct_id)
from 
	(
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2024%' and activity_id is null))
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
	union all 
	-- 社区互动人数
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where event='Button_click' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id,date
	from ods_rawd.ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and date >= '2024-01-01' 
	and date<'2024-02-01' 
) t 
join ads_crm.ads_crm_events_member_d m on toString(m.distinct_id)=toString(t.distinct_id) 
left join ods_memb.ods_memb_tc_level_cur l on toString(m.member_level)=toString(l.level_code) 
where length(t.distinct_id)<9 
and l.is_deleted=0
group by t,is_owner
order by is_owner desc,t

-- 帖子的PVUV
	select 
	to_char(a.create_time,'IYYY-IW'),
	a.post_id ,
	tp.post_title,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	left join community.tm_post tp on a.post_id =tp.post_id 
	where 1=1
	and a.create_time >='2024-01-01'
	and a.create_time <'2024-02-01'
	and a.is_deleted =0
	and a.post_id in ('cMqyUUuz2x',
	'YZwz3xvkBZ',
	'Q8OaJ8Aa10',
	'G6a2HRit5i',
	'ZFstX6nnJV')
	group by 1,2
	order by 2,1

-- 话题数据
	select 
	to_char(a.create_time,'IYYY-IW'),
	l.topic_id,
	tt.topic_name ,
	count(distinct a.member_id) UV
	from community.tr_topic_post_link l
	left join community.tt_view_post a on a.post_id = l.post_id and l.is_deleted = 0 
	left join community.tm_topic tt on tt.topic_id =l.topic_id 
	where 1=1
	and l.topic_id in ('yheQamH0c2',
	'VqwBAp14aB',
	'oveujYK99G',
	'8b8aRuGNXN',
	'fAczyBtzcR')
	and l.create_time >='2024-01-01'
	and l.create_time <'2024-02-01'
	and l.is_deleted =0
	and a.is_deleted =0
	group by 1,2
	order by 2,1

-- 1月会员日
	select 
	count(distinct user_id)
from ods_rawd.ods_rawd_events_d_di
where 1=1
and `date` = '2024-01-25'
and event='Page_entry'
and page_title ='1月会员日'
and activity_name = '2024年1月会员日'
and (($lib in('iOS','Android') and left($app_version,1)='5') or $lib ='MiniProgram' or  channel in ('Mini', 'App'))

-- APP push
	select 
	date_trunc('week',date) t,
	case when $url ='https://mweb.digitalvolvo.com/mweb/community/posts/detail/Ua6N9yqRE3' then '011_社区话题：#窝窝镜头日记#'-- MA
		when $url ='https://mweb.digitalvolvo.com/mweb/community/posts/detail/cMqyUUuz2x?postId=cMqyUUuz2x&memberId=5973084&postType=1002&reviewType=0' then '012_2023年度报告'-- MA
		when $url ='https://newbie.digitalvolvo.com/volvo-activity-h5/index.html#/doubleDan/index' then '01_12月会员日'
		when $url = 'https://mweb.digitalvolvo.com/mweb/community/posts/detail/Ua6N9yqRE3?postId=owArbeJehN&memberId=5973084&postType=1002&reviewType=0' then '02_【社区话题】#窝窝镜头日记#'
		when $url = 'https://newbie.digitalvolvo.com/volvo-activity-h5/index.html#/yearReview/index' then '03_2023年度报告'
		when $url= 'https://mweb.digitalvolvo.com/mweb/community/posts/detail/mzeEiQAogL?postId=mzeEiQAogL&memberId=5973084&postType=1002&reviewType=0' then '04_【社区话题】CNY共创征集'
		when $url = 'https://mweb.digitalvolvo.com/mweb/community/posts/detail/G6a2HRit5i?postId=G6a2HRit5i&memberId=5973084&postType=1002&reviewType=0' then '05_【社区话题】用户共创投票'
		end as push,
		count(distinct distinct_id)
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
	and event='Page_entry'
	and date>='2024-01-01'
	and date<'2024-02-01'
	group by t,push
	order by push,t

-- APP push test
	select 
 	distinct_id ,
 	time,
 	event,
 	$url
	from ods_rawd.ods_rawd_events_d_di
	where 1=1
--	and event='Page_entry'
	and date>='2024-01-01'
	and $url like 'https://mweb.digitalvolvo.com/mweb/community/posts/detail/cMqyUUuz2x?postId=cMqyUUuz2x&memberId=5973084&postType=1002&reviewType=0'
