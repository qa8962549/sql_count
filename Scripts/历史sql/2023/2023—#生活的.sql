-- 发帖明细
select 
distinct 
a.member_id 会员ID,
a.post_id 文章ID,
tmi.REAL_NAME 真实姓名,
tmi.MEMBER_NAME 用户昵称,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 用户类型,
aa.bind_date 绑车时间,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or tmi.member_level = 5 then '黑卡' end 会员等级,
tmi.MEMBER_PHONE 沃世界注册手机号码,
a.create_time 发帖时间,
replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ','')  "发帖内容",
--tt.topic_name 所带话题,
group_concat(tt.topic_name) 所带话题,
char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))  "发帖字数",
pm.发帖图片数量,
a.like_count 动态点赞数,
pm.发帖图片链接  发帖图片链接,
a.post_type "帖子类型(动态1001/文章1002/活动1006/UGC文章1007)",
a.post_state "帖子状态:1上架,2下架,4审核中,5审核不通过",
a.like_count 点赞数量,
d.PV 阅读PV,
d.UV 阅读UV,
b.tt 评论数量
from community.tm_post a
left join 
	(select b.post_id,
	count(1) tt
	from community.tm_comment b 
	where b.is_deleted =0
--	and b.create_time >='2023-11-29'
	and b.create_time <'2023-12-24'
	group by 1
) b on b.post_id =a.post_id
left join community.tr_topic_post_link l on a.post_id = l.post_id and l.is_deleted = 0
left join community.tm_topic tt on l.topic_id=tt.topic_id
left join `member`.tc_member_info tmi on a.member_id =tmi.id and tmi.IS_DELETED =0
left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)aa on aa.member_id=tmi.id and aa.rk=1
left join (-- 帖子的PVUV
	select 
	a.post_id ,
	count(a.member_id) PV,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	where 1=1
--	and a.create_time >='2023-09-21'
	and a.create_time <'2023-12-24'
	and a.is_deleted =0
	group by 1) d on d.post_id=a.post_id 
left join
(
		-- 发帖内容、图片
	select
	t.post_id,
	replace(string_agg(case when t.类型='text' then t.内容 else null end ,';'),' ','') as 发帖内容,
	string_agg(case when t.类型='image' then t.内容 else null end ,';') as 发帖图片链接,
	count(case when t.类型='image' then t.内容 else null end) as 发帖图片数量
	from
	(
		select
		tpm.post_id,
		tpm.create_time,
		replace(tpm.node_content,E'\\u0000','') 发帖内容,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeType' 类型,
		json_array_elements(replace(tpm.node_content,E'\\u0000','')::json)->>'nodeContent' 内容
		from community.tt_post_material tpm
		where 1=1
--		and tpm.create_time >= '2023-11-06' and tpm.create_time < '2023-11-13'
		and tpm.is_deleted = 0
	) as t
	group by t.post_id
) pm on a.post_id = pm.post_id
where 1=1
and a.is_deleted =0
--and a.create_time >='2023-11-29'
and a.create_time <'2023-12-24'
and tt.topic_id in ('91Ks7EGFiD','qcOWn9asL5','KqshFtKPXz','Mf6ZTQXcre','ZycHQPhuHR')
and a.post_type in ('1001','1007')
--and char_length(replace(regexp_replace(regexp_replace(pm.发帖内容,'<.*?>', '', 'g'),'#(.*?)#','', 'g'),' ',''))>=200 --帖子字数不少于200字
--and pm.发帖图片数量>=3 -- 配图不少于3张的文章及动态
group by 2
order by a.create_time

-- 帖子数据汇总
select 
a.post_id
,a.create_time 
,a.post_title 
,b.点赞
,c.评论数量
,b.收藏
,d.PV
,d.UV
from community.tm_post a
left join (
	-- 0点赞 1收藏
	select
	 a.post_id,
	count(case when a.like_type=0 then a.member_id end) 点赞,
	count(case when a.like_type=1 then a.member_id end) 收藏
	from community.tt_like_post a
	left join community.tm_post b on a.post_id =b.post_id 
	where a.is_deleted <>1
--	and a.create_time >='2023-09-21'
	and a.create_time <'2023-12-24'
	group by 1
	)b on a.post_id =b.post_id 
left join (-- 评论
	select 
	a.post_id ,
	count(a.member_id) 评论数量
	from community.tm_comment a
	where a.is_deleted <>1
--	and a.create_time >='2023-09-21'
	and a.create_time <'2023-12-24'
	group by 1
	)c on c.post_id=a.post_id 
left join (-- 帖子的PVUV
	select 
	a.post_id ,
	count(a.member_id) PV,
	count(DISTINCT a.member_id) UV
	from community.tt_view_post a
	where 1=1
--	and a.create_time >='2023-09-21'
	and a.create_time <'2023-12-24'
	and a.is_deleted =0
	group by 1) d on d.post_id=a.post_id 
where a.post_id in ('snKADzBymF',
'd3qAFH2Lvs',
'UZu89cG1JN',
'eqcDmGr1wp',
'd3gbLlzhyy',
'7NaMn5G3LH')
group by 1
order by 1


-- 投票 帖子postid：zdMtPl5v8q
select 
tvr.object_no 帖子ID,
tp.object_name 帖子名称,
tvr.vote_user_id 用户ID,
tmi.MEMBER_NAME 昵称,
tmi.MEMBER_PHONE 沃世界注册手机号,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or tmi.member_level = 5 then '黑卡' end 会员等级,
case when tmi.IS_VEHICLE = '1' then '车主'
	when tmi.IS_VEHICLE = '0' then '粉丝'
	end 是否车主,
tv.vote_title 投票标题,
x.投票名称,
tvr.create_time 投票时间,
aa.bind_date 绑车时间
from campaign.tr_vote_record tvr
left join `member`.tc_member_info tmi on tmi.id =tvr.vote_user_id and tmi.IS_DELETED =0 -- 投票记录表
left join campaign.tr_vote_bind_info tp on tvr.object_no =tp.object_no and tp.is_deleted =0 -- 投票编号映射活动id表  找到活动对应的投票组件id
left join campaign.tm_vote tv on tp.vote_no =tv.vote_no and tv.is_deleted =0-- 投票编号对应投票标题
left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)aa on aa.member_id=tmi.id and aa.rk=1
left join 
	(SELECT vote_title 投票标题,
    option ->> 'voteOption' AS voteOption,
    option ->> 'picUrl' AS picUrl,
    option ->> 'name' AS 投票名称
	from (SELECT json_array_elements(cast(tv.vote_detail as json) -> 'voteOptions') AS option 
		,tv.vote_title
     	FROM campaign.tm_vote tv) AS subquery)x on tvr.vote_option =x.voteOption
where tvr.is_deleted =0
and tvr.create_time >='2023-12-18'
and tvr.create_time <'2023-12-22'
and tvr.object_no ='d3gbLlzhyy'



--  OGC浏览数据明细
select 
x.distinct_id,
tmi.id,
tmi.member_name,
case when tmi.is_vehicle = '1' then '车主' when tmi.is_vehicle = '0' then '粉丝' end `用户类型`,
aa.bind_date `绑车时间`,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or tmi.member_level = 5 then '黑卡' end `会员等级`,
a.post_title `互动文章名称`,
x.content_id `互动文章ID`,
x.event `互动行为(阅读、点击)`,
ifnull(x.btn_name,'浏览')`互动行为(浏览、点赞、收藏、转发（朋友圈、微信好友）、评论)`,
x.vd `浏览时长`,
x.time `行为发生时间`
from 
	(
	select a.distinct_id ,
	a.content_id ,
	a.event,
	a.btn_name,
	a.view_duration_1,
	case when a.btn_name is not null then 0 else a.view_duration_1 end as vd,
	a.time
	from ods_rawd_events_d_di a
	where 1=1
	and date>='2023-11-25'
	and date<'2024-01-01'
	and LENGTH(distinct_id)<9
	and (event = 'Page_view' or (event ='Button_click' and btn_name in ('点赞','评论','收藏','微信好友','朋友圈')))
	and content_id in ('snKADzBymF',
	'd3qAFH2Lvs',
	'UZu89cG1JN',
	'eqcDmGr1wp',
	'd3gbLlzhyy',
	'7NaMn5G3LH')
)x left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id=x.content_id
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(tmi.cust_id) =toString(x.distinct_id) 
left join (
	select x.*
	from 
		(
		--		 取最近一次绑车时间
				 select
				 r.member_id,
				 m.cust_id,
				 r.bind_date,
				 r.vin_code,
				 m.member_phone,
				 row_number() over(partition by r.member_id order by r.bind_date desc) rk
				 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
				 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
				 where r.deleted = 0
				 and r.is_bind = 1   -- 绑车
				 and r.member_id is not null 
				 and r.member_id <>''
				 and m.member_phone<>'*'
				 and m.member_phone is not null 
				 Settings allow_experimental_window_functions = 1)x
	where x.rk=1
)aa on toString(aa.member_id) =toString(tmi.id) 

-- UGC浏览数据明细
select 
x.distinct_id,
tmi.id,
tmi.member_name,
case when tmi.is_vehicle = '1' then '车主' when tmi.is_vehicle = '0' then '粉丝' end `用户类型`,
aa.bind_date `绑车时间`,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or tmi.member_level = 5 then '黑卡' end `会员等级`,
a.post_title `互动文章名称`,
x.content_id `互动文章ID`,
x2.topic_name `互动话题topic_id`,
x.event `互动行为(阅读、点击)`,
ifnull(x.btn_name,'浏览')`互动行为(浏览、点赞、收藏、转发（朋友圈、微信好友）、评论)`,
x.vd `浏览时长`,
x.time `行为发生时间`
from 
	(
	select a.distinct_id ,
	a.content_id ,
	a.event,
	a.btn_name,
	a.view_duration_1,
	case when a.btn_name is not null then 0 else a.view_duration_1 end as vd,
	a.time
	from ods_rawd_events_d_di a
	where 1=1
	and date>='2023-11-29'
	and date<'2023-12-24'
	and LENGTH(distinct_id)<9
	and (event = 'Page_view' or (event ='Button_click' and btn_name in ('点赞','评论','收藏','微信好友','朋友圈')))
	and content_id global in (
		select distinct t.post_id
		from ods_cmnt.ods_cmnt_tr_topic_post_link_cur t
		where t.topic_id in ('91Ks7EGFiD','qcOWn9asL5','KqshFtKPXz','Mf6ZTQXcre','ZycHQPhuHR')
		and t.create_time>='2023-11-29'
		and t.create_time<'2023-12-24'
		)
)x left join ods_cmnt.ods_cmnt_tm_post_cur a on a.post_id=x.content_id
left join (
		select t.post_id,groupUniqArray(t.topic_id) topic_name
		from ods_cmnt.ods_cmnt_tr_topic_post_link_cur t
--		left join ods_cmnt.t tt on l.topic_id=tt.topic_id
		where t.topic_id in ('91Ks7EGFiD','qcOWn9asL5','KqshFtKPXz','Mf6ZTQXcre','ZycHQPhuHR')
		and t.create_time>='2023-11-29'
		and t.create_time<'2023-12-24'
		group by post_id
		order by post_id
		)x2 on x2.post_id =x.content_id
left join ods_memb.ods_memb_tc_member_info_cur tmi on toString(tmi.cust_id) =toString(x.distinct_id) 
left join (
	select x.*
	from 
		(
		--		 取最近一次绑车时间
				 select
				 r.member_id,
				 m.cust_id,
				 r.bind_date,
				 r.vin_code,
				 m.member_phone,
				 row_number() over(partition by r.member_id order by r.bind_date desc) rk
				 from ods_vocm.ods_vocm_vehicle_bind_relation_cur r
				 left join ods_memb.ods_memb_tc_member_info_cur m on toString(r.member_id) =toString(m.id) 
				 where r.deleted = 0
				 and r.is_bind = 1   -- 绑车
				 and r.member_id is not null 
				 and r.member_id <>''
				 and m.member_phone<>'*'
				 and m.member_phone is not null 
				 Settings allow_experimental_window_functions = 1)x
	where x.rk=1
)aa on toString(aa.member_id) =toString(tmi.id) 

-------------------------------------------------------------------------------------------

-- UGC浏览数据明细
select a.member_id,
tmi.REAL_NAME 真实姓名,
tmi.MEMBER_NAME 用户昵称,
case when tmi.IS_VEHICLE = '1' then '车主' when tmi.IS_VEHICLE = '0' then '粉丝' end 用户类型,
aa.bind_date 绑车时间,
case when tmi.member_level = 1 then '银卡'
     when tmi.member_level = 2 then '金卡'
     when tmi.member_level = 3 then '白金卡' 
     when tmi.member_level = 4 or tmi.member_level = 5 then '黑卡' end 会员等级,
tp.post_title 互动文章名称,
a.post_id 互动文章ID,
a.act "互动行为(阅读、点赞、收藏、转发、评论)",
a.create_time 行为发生时间
from 
	(
--	互动行为(阅读、点赞、收藏、转发、评论)
	select a.member_id 
	,a.post_id 
	,a.create_time 
	,case when a.like_type=0 then '点赞' else '收藏' end as act
	from community.tt_like_post a 
	where a.is_deleted =0
	union all
	select a.member_id 
	,a.post_id 
	,a.create_time 
	,'评论' act 
	from community.tm_comment a 
	where a.is_deleted =0
	union all 
	select a.member_id 
	,a.post_id 
	,a.create_time 
	,'浏览' act 
	from community.tt_view_post a 
	where a.is_deleted =0
) a
left join community.tm_post tp on tp.post_id=a.post_id
left join `member`.tc_member_info tmi on a.member_id =tmi.id
left join(
		select a.member_id
		,a.vin_code
		,a.bind_date
		,b.model_name 拥车车型
		,row_number()over(partition by a.member_id order by a.bind_date desc) rk 
		from volvo_cms.vehicle_bind_relation a
		left join basic_data.tm_model b on a.series_code =b.model_code
		where a.deleted = 0
		and a.is_bind=1
		)aa on aa.member_id=tmi.id and aa.rk=1
where 1=1
and a.post_id in ('snKADzBymF',
'd3qAFH2Lvs',
'UZu89cG1JN',
'eqcDmGr1wp',
'd3gbLlzhyy',
'7NaMn5G3LH')