-- 社区发帖人数 以nb为准 0401
SELECT m.is_vehicle,count(DISTINCT a.member_id)
from community.tm_post a
left join "member".tc_member_info m on m.id=a.member_id and m.is_deleted =0 and m.status <>'60341003'
where 1=1
and a.is_deleted =0
and a.create_time >='2023-10-01'
and a.create_time <'2023-10-23'
group by 1 
order by 1

-- 社区互动浏览人数 ，只要APP站内数据且已注册的会员，该指标为全年累计指标，到2月份时，为1-2月累计人数去重；会员日单独算进去
select 
--is_bind
count(distinct distinct_id)
from 
	(
	select distinct_id
	from ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
	and time >= '2024-04-01' 
	and time<'2024-05-01' 
	union all 
	-- 社区互动人数
	select distinct_id
	from ods_rawd_events_d_di 
	where event='Button_click' 
	and ((`$lib` in('iOS','Android') and left(`$app_version`,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and time >= '2024-04-01' 
	and time<'2024-05-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id
	from ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and time >= '2024-04-01' 
	and time<'2024-05-01' 
)t 
where length(distinct_id)<9 
--group by is_bind 
--order by is_bind


-- 社区互动浏览人数 by month
select 
formatDateTime(date,'%Y-%m') t
,count(distinct distinct_id)
from 
	(
	select is_bind,distinct_id,date
	from ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or ((activity_name like '2023%' or activity_name like '2022%')  and activity_id is null))
	and time >= '2022-04-01' 
	and time<'2023-10-01' 
	union all 
	-- 社区互动人数
	select is_bind,distinct_id,date
	from ods_rawd_events_d_di 
	where event='Button_click' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and time >= '2022-04-01' 
	and time<'2023-10-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select is_bind,distinct_id,date
	from ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and time >= '2022-04-01' 
	and time<'2023-10-01' 
) t 
where length(distinct_id)<9 
and distinct_id not like '%#%'
group by t  
order by t
