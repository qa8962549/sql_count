-- 1、App 日活及总的用户数量
SELECT
event,
toDate(time) as `日期`,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event in ('$AppStart','$AppInstall','$AppClick','$AppViewScreen','$AppStartPassively','$AppEnd','$AppPageLeave')
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by event,toDate(time)
order by event,toDate(time)

-- 2、App 推荐页每日UV和PV、平均浏览进度、平均浏览时长
SELECT
toDate(time) as `日期`,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`,
avg(case when view_duration is null
then null
when $app_version in ('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration<=300000
then view_duration/1000
when $app_version in('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration>300000
then 5
when $app_version not in ('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration>300
then 5
when $lib='js' and view_duration<=300000
then view_duration/1000
when $lib='js' and view_duration>300000
then 5
else view_duration
end as view_duration_1) as `平均浏览时长`,avg(view_advance) as `平均浏览进度`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Page_view'
and page_title='推荐'
and bussiness_name='社区'
and $lib in ('iOS','Android')
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
order by toDate(time)	

3、App 每日成功养修预约人数
select 
toDate(time) as `日期`,
count(distinct distinct_id) as `成功养修预约人数`
from ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Appointment_maintainrepair_succed'
and $lib in ('iOS','Android')
and time>= '2023-05-01'
and time< '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
order by toDate(time)	

4、Mini 商城购买人数
select toDate(time) as `日期`,count(distinct distinct_id) as `UV1`
from ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Mall_pay_order_result'
and $lib in ('MiniProgram')
and time>= '2023-05-01'
and time< '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
order by toDate(time)	

5、App 推荐页每个banner每日的曝光UV和PV
SELECT
lateral_position as `banner横向位置`,
toDate(time) as `日期`,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Banner_exposure'
and page_title='推荐'
and $lib in ('iOS','Android')
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by lateral_position,toDate(time)
order by lateral_position,toDate(time)

6、App 过去30天商城搜索发起topn搜索词及返回结果数
select 
toDate(time) as `日期`,
-- search_word  as `搜索词`,
count(distinct_id) as `搜索次数`,
avg(result_amount) as `搜索返回结果条数均值`
from ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Mall_search_request_result'
and $lib in ('iOS','Android')
and time>= '2023-05-01'
and time< '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
-- ,search_word
order by toDate(time)
-- ,search_word		

7、App 我的会员页面各权益每日曝光次数	
select 
case when content_id='8' then '樊登读书7天体验卡' 
when content_id='10' then '歌帝梵55元软冰券' 
when content_id='11' then '瑞幸咖啡29元体验券' 
when content_id='9' then '樊登读书9折购书卡' 
when content_id='12' then '瑞尔齿科85折卡' 
when content_id='13' then '瑞尔760元洁牙券' 
when content_id='14' then '麦当劳板烧鸡腿堡套餐' 
when content_id='15' then '歌帝梵50-10券' 
when content_id='16' then '超级猩猩89元全国通用券' 
when content_id='20' then '东方航空100积分兑换券' 
when content_id='19' then '东方航空500积分兑换券' 
when content_id='18' then '东方航空1000积分兑换券' else null end `曝光权益`,
--case when content_id not in ('8','9','10','11','12','13','14','15','16','18','19','20')
--then 'NULL' else content_id end as `曝光权益`,
toDate(time) as `日期`,
count(distinct_id) as `曝光次数`
from ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Content_exposure'
and page_title='我的会员'
and $lib in ('iOS','Android')
and time>= '2023-05-01'
and time< '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by `曝光权益`
,toDate(time)
order by `曝光权益`		
,toDate(time)

case when content_id='8' then '樊登读书7天体验卡' 
when content_id='10' then '歌帝梵55元软冰券' 
when content_id='11' then '瑞幸咖啡29元体验券' 
when content_id='9' then '樊登读书9折购书卡' 
when content_id='12' then '瑞尔齿科85折卡' 
when content_id='13' then '瑞尔760元洁牙券' 
when content_id='14' then '麦当劳板烧鸡腿堡套餐' 
when content_id='15' then '歌帝梵50-10券' 
when content_id='16' then '超级猩猩89元全国通用券' 
when content_id='20' then '东方航空100积分兑换券' 
when content_id='19' then '东方航空500积分兑换券' 
when content_id='18' then '东方航空1000积分兑换券' else null end `曝光权益`

--8、社区每篇OGC每日的UV PV 点赞 收藏 转发		
select x.`日期`
,x.`内容id`
,x.`内容标题`
,case when x4.`分类`='点赞' then x4.`UV`  end `点赞`
,case when x3.`分类`='朋友圈' then x3.`UV` end `朋友圈`
,case when x5.`分类`='收藏' then x5.`UV` end `收藏`
,case when x2.`分类`='微信好友' then x2.`UV` end `微信好友`
,x.`PV`
,x.`UV`
from 
	(
	SELECT
	toDate(time) as `日期`,
--	'页面浏览' as `分类`,
	content_id as `内容id`,
	content_title as `内容标题`,
	count(distinct distinct_id) as `UV`,
	count(distinct_id)as `PV`
	FROM ods_rawd.ods_rawd_events_d_di o
	where 1=1 and length(distinct_id)<9
	and event='Page_view'
	and page_title in ('内容详情','动态详情')
	and content_title is not null and content_title<>''
	and time >= '2023-05-01'
	and time < '2023-05-11'
	and $receive_time>= 1682870400000
	and $receive_time< 1683734400000
	group by toDate(time),content_id,content_title
	order by toDate(time),content_id,content_title)x
left join 
	(
	SELECT
	toDate(time) as `日期`,
	btn_name as `分类`,
	content_id as `内容id`,
	content_title as `内容标题`,
	count(distinct distinct_id) as `UV`
	FROM ods_rawd.ods_rawd_events_d_di o
	where 1=1 and length(distinct_id)<9
	and event='Button_click'
	and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
	and btn_name in ('微信好友')
	and content_title is not null and content_title<>''
	and time >= '2023-05-01'
	and time < '2023-05-11'
	and $receive_time>= 1682870400000
	and $receive_time< 1683734400000
	group by toDate(time),btn_name,content_id,content_title
	order by toDate(time),btn_name,content_id,content_title)x2 on x2.`内容id`=x.`内容id` and x2.`日期`=x.`日期`
left join 
	(
	SELECT
	toDate(time) as `日期`,
	btn_name as `分类`,
	content_id as `内容id`,
	content_title as `内容标题`,
	count(distinct distinct_id) as `UV`
	FROM ods_rawd.ods_rawd_events_d_di o
	where 1=1 and length(distinct_id)<9
	and event='Button_click'
	and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
	and btn_name in ('朋友圈')
	and content_title is not null and content_title<>''
	and time >= '2023-05-01'
	and time < '2023-05-11'
	and $receive_time>= 1682870400000
	and $receive_time< 1683734400000
	group by toDate(time),btn_name,content_id,content_title
	order by toDate(time),btn_name,content_id,content_title)x3 on x3.`内容id`=x.`内容id` and x3.`日期`=x.`日期`
left join 
	(
	select
	a.`日期`,
	a.`分类`,
	a.`内容id`,
	a.`内容标题`,
	a.`UV1`-b.`UV2` as `UV`
	from
		(
		SELECT
		toDate(time) as `日期`,
		btn_name as `分类`,
		content_id as `内容id`,
		content_title as `内容标题`,
		count(distinct distinct_id) as `UV1`
		FROM ods_rawd.ods_rawd_events_d_di o
		where 1=1 and length(distinct_id)<9
		and event='Button_click'
		and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
		and btn_name in ('点赞')
		and (interaction_type ='点赞')
		and content_title is not null and content_title<>''
		and time >= '2023-05-01'
		and time < '2023-05-11'
		and $receive_time>= 1682870400000
		and $receive_time< 1683734400000
		group by toDate(time),btn_name,content_id,content_title
		order by toDate(time),btn_name,content_id,content_title
		)a
	left join
		(SELECT
		toDate(time) as `日期`,
		btn_name as `分类`,
		content_id as `内容id`,
		content_title as `内容标题`,
		count(distinct distinct_id) as `UV2`
		FROM ods_rawd.ods_rawd_events_d_di o
		where 1=1 and length(distinct_id)<9
		and event='Button_click'
		and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
		and btn_name in ('点赞')
		and (interaction_type ='取消点赞')
		and content_title is not null and content_title<>''
		and time >= '2023-05-01'
		and time < '2023-05-11'
		and $receive_time>= 1682870400000
		and $receive_time< 1683734400000
		group by toDate(time),btn_name,content_id,content_title
		order by toDate(time),btn_name,content_id,content_title
		)b on a.`日期`=b.`日期` and a.`分类`=b.`分类` and a.`内容id`=b.`内容id` and a.`内容标题`=b.`内容标题`)x4 on x4.`内容id`=x.`内容id` and x4.`日期`=x.`日期`
left join 
	(
	select
	a.`日期`,
	a.`分类`,
	a.`内容id`,
	a.`内容标题`,
	a.`UV1`-b.`UV2` as `UV`
	from
		(
		SELECT
		toDate(time) as `日期`,
		btn_name as `分类`,
		content_id as `内容id`,
		content_title as `内容标题`,
		count(distinct distinct_id) as `UV1`
		FROM ods_rawd.ods_rawd_events_d_di o
		where 1=1 and length(distinct_id)<9
		and event='Button_click'
		and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
		and btn_name in ('收藏')
		and (interaction_type ='收藏')
		and content_title is not null and content_title<>''
		and time >= '2023-05-01'
		and time < '2023-05-11'
		and $receive_time>= 1682870400000
		and $receive_time< 1683734400000
		group by toDate(time),btn_name,content_id,content_title
		order by toDate(time),btn_name,content_id,content_title
		)a
	left join
		(SELECT
		toDate(time) as `日期`,
		btn_name as `分类`,
		content_id as `内容id`,
		content_title as `内容标题`,
		count(distinct distinct_id) as `UV2`
		FROM ods_rawd.ods_rawd_events_d_di o
		where 1=1 and length(distinct_id)<9
		and event='Button_click'
		and page_title in ('内容详情','动态详情','内容详情_分享弹窗','动态详情_分享弹窗')
		and btn_name in ('收藏')
		and (interaction_type ='取消收藏')
		and content_title is not null and content_title<>''
		and time >= '2023-05-01'
		and time < '2023-05-11'
		and $receive_time>= 1682870400000
		and $receive_time< 1683734400000
		group by toDate(time),btn_name,content_id,content_title
		order by toDate(time),btn_name,content_id,content_title
		)b on a.`日期`=b.`日期` and a.`分类`=b.`分类` and a.`内容id`=b.`内容id` and a.`内容标题`=b.`内容标题`)x5 on x5.`内容id`=x.`内容id` and x5.`日期`=x.`日期`	
order by x.`日期`,x.`内容id`,x.`内容标题`
	
--9、内容合集页UV PV											
SELECT
toDate(time) as `日期`,
column_name,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Page_view'
and page_title in ('内容合集')
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time),column_name
order by toDate(time),column_name			

10、Mini 商城首页浏览人数 次数
SELECT
toDate(time) as `日期`,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`,
avg(case when view_duration is null
then null
when $app_version in ('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration<=300000
then view_duration/1000
when $app_version in('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration>300000
then 5
when $app_version not in ('5.17.6','5.17.7','5.19.0','5.19.1','5.20.0','5.20.1','5.22.0','5.22.1','5.22.2','5.22.3','5.22.4','5.23.0','5.22.5','5.22.6','5.22.7','5.22.8','5.23.0','5.24.0','5.24.1','5.24.2','5.24.3','5.25','5.26.0') and view_duration>300
then 5
when $lib='js' and view_duration<=300000
then view_duration/1000
when $lib='js' and view_duration>300000
then 5
else view_duration
end as view_duration_1) as `平均浏览时长`,avg(view_advance) as `平均浏览进度`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Mall_category_list_view'
and page_title='商城首页'
and bussiness_name='商城'
and $lib in ('MiniProgram')
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
order by toDate(time)				

11、Mini 推荐页UV PV、每个文章点赞 收藏用户数次数
SELECT
toDate(time) as `日期`,
count(distinct_id)as `PV`,count(distinct distinct_id) as `UV`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Page_view'
and page_title='推荐'
and bussiness_name='社区'
and $lib ='MiniProgram'
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time)
order by toDate(time)			

select
a.`日期`,
a.btn_name,
a.`内容id`,
a.`内容标题`,
a.`UV1`-b.`UV2` as `UV`
from
(
SELECT
toDate(time) as `日期`,
btn_name,content_id as `内容id`,content_title as `内容标题`,
count(distinct_id)as `PV1`,count(distinct distinct_id) as `UV1`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Button_click'
and $lib ='MiniProgram'
and page_title ='推荐'
and btn_name in ('点赞','收藏')
and (interaction_type ='点赞' or interaction_type ='收藏')
and content_title is not null and content_title<>''
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time),btn_name,content_id,content_title
order by toDate(time),btn_name,content_id,content_title
)a
left JOIN 
(
SELECT
toDate(time) as `日期`,
btn_name,content_id as `内容id`,content_title as `内容标题`,
count(distinct_id)as `PV2`,count(distinct distinct_id) as `UV2`
FROM ods_rawd.ods_rawd_events_d_di o
where 1=1 and length(distinct_id)<9
and event='Button_click'
and $lib ='MiniProgram'
and page_title ='推荐'
and btn_name in ('点赞','收藏')
and (interaction_type ='取消点赞' or interaction_type ='取消收藏')
and content_title is not null and content_title<>''
and time >= '2023-05-01'
and time < '2023-05-11'
and $receive_time>= 1682870400000
and $receive_time< 1683734400000
group by toDate(time),btn_name,content_id,content_title
order by toDate(time),btn_name,content_id,content_title
)b on a.`日期`=b.`日期` and a.btn_name=b.btn_name and a.`内容id`=b.`内容id` and a.`内容标题`=b.`内容标题`				
