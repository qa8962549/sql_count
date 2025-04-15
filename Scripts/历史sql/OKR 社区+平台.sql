--App总注册量
select count(distinct distinct_id) 
from ods_rawd.ods_rawd_events_d_di a
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
--and time >= '2022-01-01' 
and time<'2024-01-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

--App MAU
select count(distinct distinct_id) 
from ods_rawd.ods_rawd_events_d_di a
where (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and time >= '2023-01-01' 
and time<'2024-01-01' 
and distinct_id not like '%#%'
and length(distinct_id)<9

--社区 MAU   社区互动浏览人数,不累计，算单月
select 
--date_trunc('month',date) t
count(distinct distinct_id)
from 
	(
	select distinct_id,date
	from ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
	union all 
	-- 社区互动人数
	select distinct_id,date
	from ods_rawd_events_d_di 
	where event='Button_click' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id,date
	from ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
) t 
where length(distinct_id)<9 
and distinct_id not like '%#%'
--group by t 
--order by t 

-- 社区活跃用户登录APP次数
select 
--date_trunc('month',date) t
count(1)
from ods_rawd_events_d_di
where event = '$AppStart'
and left($app_version,1)='5'
and date >= '2023-01-01' 
and date<'2023-02-01' 
and distinct_id global in 
	(
	select 
	distinct distinct_id
	from 
		(
		select distinct_id,date
		from ods_rawd_events_d_di 
		where event in ('Page_view','Page_entry') 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
		union all 
		-- 社区互动人数
		select distinct_id,date
		from ods_rawd_events_d_di 
		where event='Button_click' 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
		and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
		union all 
		-- 发现 按钮点击（车主）7月开始
		select distinct_id,date
		from ods_rawd_events_d_di 
		where 1=1
		and event='$AppClick' 
		and $element_content='发现'
		and is_bind=1
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
	) t 
	where length(distinct_id)<9 
	and distinct_id not like '%#%'
	)
--group by t 
--order by t

-- 社区未活跃用户登录APP次数
select 
count(1)
from ods_rawd_events_d_di
where event = '$AppStart'
--and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
and date >= '2023-01-01' 
and date<'2023-02-01' 
and distinct_id global not in 
	(
	select 
	distinct distinct_id
	from 
		(
		select distinct_id,date
		from ods_rawd_events_d_di 
		where event in ('Page_view','Page_entry') 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
		union all 
		-- 社区互动人数
		select distinct_id,date
		from ods_rawd_events_d_di 
		where event='Button_click' 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
		and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
		union all 
		-- 发现 按钮点击（车主）7月开始
		select distinct_id,date
		from ods_rawd_events_d_di 
		where 1=1
		and event='$AppClick' 
		and $element_content='发现'
		and is_bind=1
		and date >= '2023-01-01' 
		and date<'2023-02-01' 
	) t 
	where length(distinct_id)<9 
	and distinct_id not like '%#%'
	)



--App月活社区贡献占比

--App绑车用户 MAU -- APP车主月度活跃数量
	select count(distinct distinct_id)
	  from ods_rawd.ods_rawd_events_d_di a
	  where 1=1
	  and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	  and is_bind=1  -- 车主
	  and date >= '2023-01-01' 
	  and date<'2024-01-01' 
	  and length(distinct_id)<9
	  and distinct_id not like '%#%'


--社区绑车用户 MAU
select 
--date_trunc('month',date) t
count(distinct distinct_id)
from 
	(
	select distinct_id,date,is_bind
	from ods_rawd_events_d_di 
	where event in ('Page_view','Page_entry') 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
	union all 
	-- 社区互动人数
	select distinct_id,date,is_bind
	from ods_rawd_events_d_di 
	where event='Button_click' 
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
	and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
	union all 
	-- 发现 按钮点击（车主）7月开始
	select distinct_id,date,is_bind
	from ods_rawd_events_d_di 
	where 1=1
	and event='$AppClick' 
	and $element_content='发现'
	and is_bind=1
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
) t 
where length(distinct_id)<9 
and distinct_id not like '%#%'
and t.is_bind=1
--group by t 
--order by t 

--App绑车用户 DAU
SELECT 
--date_trunc('month',x.t) t,
avg(x.num)
from 
	(
	select 
	date t,
	count(distinct distinct_id) num 
	from ods_rawd.ods_rawd_events_d_di a
	where 1=1
	and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
	and date >= '2023-01-01' 
	and date<'2024-01-01' 
	and length(distinct_id)<9
	and distinct_id not like '%#%'
	and a.is_bind=1 -- 车主
	group by t 
	order by t ) x
--group by t
--order by t

--社区绑车用户 DAU
select 
--date_trunc('month',x.t) t,
avg(x.num)
from 
	(
	select 
	date t
	,count(distinct distinct_id) num
	from 
		(
		select distinct_id,date,is_bind
		from ods_rawd_events_d_di 
		where event in ('Page_view','Page_entry') 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and (page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情') or page_title like '%会员日%' or (activity_name like '2023%' and activity_id is null))
		and date >= '2023-01-01' 
		and date<'2024-01-01' 
		union all 
		-- 社区互动人数
		select distinct_id,date,is_bind
		from ods_rawd_events_d_di 
		where event='Button_click' 
		and (($lib in('iOS','Android') and left($app_version,1)='5') or channel ='App')
		and page_title in ('文章详情','内容详情','此刻','社区此刻页','动态详情','内容合集','话题详情','推荐','社区推荐页')
		and btn_name in ('点赞','收藏','动态点赞','文章','动态','评论点赞','文章点赞','文章评论发送','回复评论发送','朋友圈','微信好友','动态评论发送','动态回复评论发送','发布','发送') 
		and date >= '2023-01-01' 
		and date<'2024-01-01' 
		union all 
		-- 发现 按钮点击（车主）7月开始
		select distinct_id,date,is_bind
		from ods_rawd_events_d_di 
		where 1=1
		and event='$AppClick' 
		and $element_content='发现'
		and is_bind=1
		and date >= '2023-01-01' 
		and date<'2024-01-01' 
	) t 
	where length(distinct_id)<9 
	and distinct_id not like '%#%'
	and t.is_bind=1 -- 车主
	group by t 
	order by t 
)x 
--group by t 
--order by t

--UGC发帖量
select 
--date_format(a.create_time,'%Y-%m'),
count(a.id) UGC发帖量
from community.tm_post a
where 1=1
and a.is_deleted =0
and a.post_type in ('1007','1001') -- 文章
and a.create_time >='2023-01-01'
and a.create_time <'2024-01-01'
--group by 1
--order by 1

--社区发帖人数
SELECT 
--date_format(a.create_time,'%Y-%m'),
count(DISTINCT a.member_id)
from community.tm_post a
where 1=1
and a.is_deleted =0
and a.create_time >='2023-01-01'
and a.create_time <'2024-01-01'
--group by 1
--order by 1

--官号数量

--OGC发帖量

--官号互动率

--平台负面率
