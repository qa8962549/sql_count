select date(now()) - INTERVAL '12 day '

and time >= date(now()) - INTERVAL '7 day ' and time < date(now())

--社区首页PV UV
select *
from (
select 1 a,count(user_id) PV
from ods_rawd_events_d_di
where page_title in('推荐','社区推荐页')
and event='Page_view'
-- and event='Page_entry'
-- and ($lib in('iOS','Android') or channel ='App')
--and time >='2023-12-25'and time <'2024-01-01'
and time >='2023-12-25'and time <'2024-01-01'
union all
select 
2 a,count(distinct user_id)UV
from ods_rawd_events_d_di
where page_title in('推荐','社区推荐页')
and event='Page_view'
-- and ($lib in('iOS','Android') or channel ='App')
and time >='2023-12-25'and time <'2024-01-01'
union all
--此刻PVUV
select 3 a,count(user_id) PV
from ods_rawd_events_d_di
where page_title in('此刻','社区此刻页')
and event='Page_view'
and time >='2023-12-25'and time <'2024-01-01'
union all 
select 4 a,count(distinct user_id) UV
from ods_rawd_events_d_di
where page_title in('此刻','社区此刻页')
and event='Page_view'
and time >='2023-12-25'and time <'2024-01-01'
union all 
-- 集合页内容合集PVUV
select 5 a,count(user_id) PV
from ods_rawd_events_d_di
where page_title ='内容合集'
and event='Page_view'
and bussiness_name='社区'
and time >='2023-12-25'and time <'2024-01-01'
union all 
select 6 a,count(distinct user_id) UV
from ods_rawd_events_d_di
where page_title ='内容合集'
and event='Page_view'
and bussiness_name='社区'
and time >='2023-12-25'and time <'2024-01-01')
order by a 

--App周活
select count(distinct user_id)
from ods_rawd_events_d_di
where ($lib in('iOS','Android') or channel ='App')
and time >='2023-12-25'and time <'2024-01-01'
--and time < date(now())

-- 社区浏览人数 20230925更新yuhui给的sql
select count(distinct user_id)
from ods_rawd_events_d_di 
where event in ('Page_view','Page_entry') 
and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') 
and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
and time >='2023-12-25'and time <'2024-01-01'

select count(distinct user_id)
from ods_rawd_events_d_di 
where event in ('Page_view','Page_entry') 
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
and time >='2023-12-25'and time <'2024-01-01'
and bussiness_name ='社区'

select count(distinct user_id)
from ods_rawd_events_d_di 
where event in ('Page_view','Page_entry') 
and ((($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App') or ($lib='MiniProgram' or channel='Mini')) -- Mini
and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
and time >='2023-12-25'and time <'2024-01-01'

----------------------------------------------------------------------------

SET allow_experimental_window_functions = 1;

--浏览时长中位数
-- 每天每个用户浏览时长进行排序
select avg(x.num)
from 
	(
	select x.tt,
	quantile(x.view_dur) num
	from 
	(
	 -- 每个用户每天的汇总浏览时长
	      select t.user_id
	      ,t.date tt
	      ,sum(t.view_dura) view_dur
	      from
	        (
			-- 每个用户每天每次的浏览时长
			select user_id
			,$lib
			,$app_version
			,case when view_duration is null then null
			when $lib ='MiniProgram' and $app_version is null then null
			when view_duration <=0 then 0   --- 小于等于0的数据全部清洗为0 
		    when view_duration>300000 then 5   --- 超过300000全部清洗为5，不论版本和端口
		    when $app_version <'5.17.6' and view_duration>300 then 5  -- app5.17.6版本及以后得浏览时长单位均是s(秒)
			when (($app_version >='5.17.6' -- app 5.17.6版本及以后得浏览时长单位均是ms ，所以除以1000
				and $lib in ('iOS','Android'))						
				or $lib in ('MiniProgram','js'))						-- 小程序浏览时长单位均是ms，js端的浏览时长均是ms，均除以1000
				and view_duration<=300000
			then view_duration/1000
			else view_duration
			end as view_dura
			,date
			from ods_rawd.ods_rawd_events_d_di
			where 1=1
			and event in ('Page_view','Page_entry') 
        	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
			and view_duration is not null
			and time >='2023-12-25'and time <'2024-01-01'
			) t
	      group by t.user_id,t.date
	 )x group by x.tt
)x
  
-- 每个用户每天每次的浏览时长
select user_id
,$lib
,$app_version
,case when view_duration is null then null
when view_duration <=0 then 0   --- 小于等于0的数据全部清洗为0 
when view_duration>300000 then 5   --- 超过300000全部清洗为5，不论版本和端口
when $app_version <'5.17.6' and view_duration>300 then 5  -- app5.17.6版本以前浏览时长单位均是s(秒)
when (($app_version >='5.17.6' -- app 5.17.6版本及以后得浏览时长单位均是ms ，所以除以1000
	and $lib in ('iOS','Android'))						
	or $lib in ('MiniProgram','js'))						-- 小程序浏览时长单位均是ms，js端的浏览时长均是ms，均除以1000
	and view_duration<=300000
then view_duration/1000
else view_duration
end as view_dura
,date
from ods_rawd.ods_rawd_events_d_di
where 1=1
and view_duration is not null
and time >= date(now()) - INTERVAL '30 day ' 
and time < date(now())
			

 -- 取中位数 quantile(level)(expr)
select quantile(m.id) 
from ods_memb.ods_memb_tc_member_info_cur m


----------------------------------------------------------------------------------------------------------------------------

--用户文章总转发数
select count(user_id)"转发数" 
,count(distinct user_id) "人数"
from ods_rawd.ods_rawd_events_d_di
where event='Button_click'
and page_title in ('文章详情','内容详情','内容详情_分享弹窗','动态详情_分享弹窗')
and btn_name in ('微信好友','朋友圈')
and content_type='UGC'
and time >='2023-12-25'and time <'2024-01-01'


--官方文章总转发数
select count(user_id)"转发数" 
,count(distinct user_id) "人数"
from ods_rawd.ods_rawd_events_d_di
where event='Button_click'
and page_title in ('文章详情','内容详情','内容详情_分享弹窗','动态详情_分享弹窗')
and btn_name in ('微信好友','朋友圈')
and content_type='文章'
and time >='2023-12-25'and time <'2024-01-01'

--动态总转发数
select count(user_id)
,count(distinct user_id)
from ods_rawd.ods_rawd_events_d_di
where event='Button_click'
and page_title in ('动态详情','动态详情_分享弹窗')
and btn_name in ('微信好友','朋友圈')
and time >='2023-12-25'and time <'2024-01-01'

--社区内容互动
select count(distinct user_id)
from ods_rawd.ods_rawd_events_d_di
where 1=1
and event='Button_click'
and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页') or page_title like '%会员日%'or (activity_name like '2023%' and activity_id is null))
and btn_name in('点赞','文章点赞','评论点赞','文章评论发送','回复评论发送','微信好友','朋友圈','收藏')
and time >='2023-12-25'and time <'2024-01-01'

-----------------------